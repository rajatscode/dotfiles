# /// script
# requires-python = ">=3.11"
# dependencies = ["pytest>=8", "pyyaml>=6"]
# ///
"""Behavior tests for dot_local/bin/executable_memory-groom.

Run: uv run --script tests/test_memory_groom.py
"""

from __future__ import annotations

import importlib.machinery
import importlib.util
import os
import subprocess
import sys
import time
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parent.parent / "dot_local" / "bin" / "executable_memory-groom"
sys.dont_write_bytecode = True
loader = importlib.machinery.SourceFileLoader("memory_groom", str(SCRIPT))
spec = importlib.util.spec_from_loader("memory_groom", loader)
mg = importlib.util.module_from_spec(spec)
sys.modules["memory_groom"] = mg
loader.exec_module(mg)

NOW = time.time()
DAY = 86400


def write_memory(directory: Path, name: str, *, age_days: float = 0, frontmatter: dict | None = None, body: str = "body\n"):
    path = directory / name
    if frontmatter is None:
        path.write_text(body)
    else:
        lines = ["---"]
        meta = frontmatter.pop("metadata", None)
        for key, value in frontmatter.items():
            lines.append(f"{key}: {value}")
        if meta:
            lines.append("metadata:")
            lines += [f"  {k}: {v}" for k, v in meta.items()]
        lines += ["---", "", body]
        path.write_text("\n".join(lines))
    stamp = NOW - age_days * DAY
    os.utime(path, (stamp, stamp))
    return path


def memory(name: str, type_: str, description: str = "a memory", **meta) -> dict:
    return {"name": name, "description": description, "metadata": {"type": type_, **meta}}


def git(directory: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(directory), *args], capture_output=True, text=True, check=True).stdout


def groom(directory: Path, days: float = 21, dry_run: bool = False):
    return mg.groom(directory, days, dry_run, now=NOW)


@pytest.fixture
def mem(tmp_path: Path, monkeypatch) -> Path:
    for key, value in {
        "GIT_AUTHOR_NAME": "t", "GIT_AUTHOR_EMAIL": "t@example.com",
        "GIT_COMMITTER_NAME": "t", "GIT_COMMITTER_EMAIL": "t@example.com",
    }.items():
        monkeypatch.setenv(key, value)
    directory = tmp_path / "proj" / "memory"
    directory.mkdir(parents=True)
    (directory / "MEMORY.md").write_text("# Memory Index\n")
    return directory


@pytest.mark.parametrize(
    ("type_", "age_days", "extra", "archived"),
    [
        ("project", 30, {}, True),
        ("project", 10, {}, False),
        ("project", 30, {"pinned": "true"}, False),
        ("feedback", 90, {}, False),
        ("reference", 90, {}, False),
        ("user", 90, {}, False),
    ],
)
def test_archive_rule(mem: Path, type_, age_days, extra, archived):
    write_memory(mem, "m.md", age_days=age_days, frontmatter=memory("M", type_, **extra))
    report = groom(mem)
    assert (mem / "archive" / "m.md").exists() is archived
    assert (mem / "m.md").exists() is not archived
    index = (mem / "MEMORY.md").read_text()
    if archived:
        assert report.archived == ["m.md"]
        assert "](m.md)" not in index
        assert "archive/INDEX.md" in index
        assert "- [M](m.md) — a memory" in (mem / "archive" / "INDEX.md").read_text()
    else:
        assert "- [M](m.md) — a memory" in index
        assert "archive/" not in index


def test_recent_commit_keeps_file_with_old_mtime(mem: Path):
    path = write_memory(mem, "p.md", frontmatter=memory("P", "project"))
    groom(mem)
    stamp = NOW - 60 * DAY
    os.utime(path, (stamp, stamp))
    groom(mem)
    assert (mem / "p.md").exists()


@pytest.mark.parametrize(
    ("days", "archived"),
    [(5, True), (21, False)],
)
def test_archive_threshold_is_configurable(mem: Path, days, archived):
    write_memory(mem, "p.md", age_days=10, frontmatter=memory("P", "project"))
    groom(mem, days=days)
    assert (mem / "archive" / "p.md").exists() is archived


def test_regenerate_groups_by_type_in_fixed_order(mem: Path):
    write_memory(mem, "r.md", frontmatter=memory("Ref", "reference"))
    write_memory(mem, "p.md", frontmatter=memory("Proj", "project"))
    write_memory(mem, "f.md", frontmatter=memory("Fb", "feedback"))
    write_memory(mem, "u.md", frontmatter=memory("Me", "user"))
    write_memory(mem, "s.md", frontmatter=memory("Style", "feedback", section="Style"))
    groom(mem)
    index = (mem / "MEMORY.md").read_text()
    headings = [line for line in index.splitlines() if line.startswith("## ")]
    assert headings == ["## User", "## Feedback", "## Style", "## Projects", "## Reference"]


def test_top_level_type_frontmatter_is_read(mem: Path):
    (mem / "old.md").write_text("---\nname: Old style\ndescription: flat keys\ntype: feedback\n---\nbody\n")
    groom(mem)
    assert "## Feedback\n- [Old style](old.md) — flat keys" in (mem / "MEMORY.md").read_text()


@pytest.mark.parametrize(
    ("description", "expected"),
    [
        ("short hook", "short hook"),
        ("word " * 30, None),
    ],
)
def test_description_cut_at_word_boundary(mem: Path, description, expected):
    write_memory(mem, "d.md", frontmatter=memory("D", "feedback", description=description.strip()))
    report = groom(mem)
    line = next(l for l in (mem / "MEMORY.md").read_text().splitlines() if "(d.md)" in l)
    rendered = line.split(" — ", 1)[1]
    assert len(rendered) <= 100
    if expected:
        assert rendered == expected
        assert report.overlong_description == []
    else:
        assert rendered.endswith("word…")
        assert report.overlong_description == ["d.md"]


def test_untyped_memory_is_listed_and_flagged(mem: Path):
    (mem / "t.md").write_text("---\nname: T\ndescription: no type\n---\nbody\n")
    report = groom(mem)
    assert report.missing_type == ["t.md"]
    assert "## Other\n- [T](t.md) — no type" in (mem / "MEMORY.md").read_text()


def test_in_claude_md_files_are_omitted(mem: Path):
    write_memory(mem, "c.md", frontmatter=memory("C", "feedback", in_claude_md="true"))
    (mem / "MEMORY.md").write_text("- [C](c.md) — old hook\n")
    report = groom(mem)
    assert "c.md" not in (mem / "MEMORY.md").read_text()
    assert report.unfiled == []


def test_curated_titles_and_order_survive(mem: Path):
    write_memory(mem, "a.md", frontmatter=memory("a-slug", "feedback", description="A"))
    write_memory(mem, "b.md", frontmatter=memory("b-slug", "feedback", description="B"))
    (mem / "MEMORY.md").write_text("- [Bee title](b.md) — old\n- [Ay title](a.md) — old\n")
    groom(mem)
    lines = [l for l in (mem / "MEMORY.md").read_text().splitlines() if l.startswith("- ")]
    assert lines == ["- [Bee title](b.md) — B", "- [Ay title](a.md) — A"]


@pytest.mark.parametrize(
    "line",
    [
        "- Always use worktrees for team agents",
        "- [Deep results](sub/RESULTS.md) — lives in a subdirectory",
        "- [Gone](deleted.md) — file no longer exists",
    ],
)
def test_unlinked_bullets_are_preserved_verbatim(mem: Path, line):
    write_memory(mem, "f.md", frontmatter=memory("F", "feedback"))
    (mem / "MEMORY.md").write_text(f"# Memory Index\n\n## Prefs\n{line}\n- [F](f.md) — x\n")
    report = groom(mem)
    index = (mem / "MEMORY.md").read_text()
    assert report.unfiled == [line]
    assert f"## Unfiled\n{line}\n" in index


def test_missing_frontmatter_is_listed_and_flagged(mem: Path):
    write_memory(mem, "raw.md", frontmatter=None, body="# just notes\n")
    report = groom(mem)
    assert report.missing_frontmatter == ["raw.md"]
    assert "## Missing frontmatter\n- [raw](raw.md)" in (mem / "MEMORY.md").read_text()


def test_initializes_repo_and_commits(mem: Path):
    write_memory(mem, "f.md", frontmatter=memory("F", "feedback"))
    groom(mem)
    assert (mem / ".git").is_dir()
    assert git(mem, "status", "--porcelain") == ""
    assert git(mem, "log", "-1", "--format=%s").startswith("memory-groom: ")
    assert git(mem, "remote") == ""


def test_archive_is_a_git_rename(mem: Path):
    write_memory(mem, "p.md", frontmatter=memory("P", "project"))
    groom(mem)
    stamp = NOW - 60 * DAY
    os.utime(mem / "p.md", (stamp, stamp))
    later = NOW + 60 * DAY
    mg.groom(mem, 21, False, now=later)
    status = git(mem, "show", "--name-status", "--format=", "HEAD")
    assert "R100\tp.md\tarchive/p.md" in status


@pytest.mark.parametrize("repo_first", [True, False])
def test_second_run_changes_nothing(mem: Path, repo_first):
    if repo_first:
        git(mem, "init", "-q")
    write_memory(mem, "old.md", age_days=40, frontmatter=memory("Old", "project"))
    write_memory(mem, "new.md", frontmatter=memory("New", "project"))
    write_memory(mem, "raw.md", frontmatter=None)
    (mem / "MEMORY.md").write_text("- loose note\n- [Old title](old.md) — hook\n")
    groom(mem)
    head = git(mem, "rev-parse", "HEAD")
    snapshot = {p: p.read_text() for p in mem.rglob("*.md")}
    report = groom(mem)
    assert not report.changed
    assert git(mem, "rev-parse", "HEAD") == head
    assert {p: p.read_text() for p in mem.rglob("*.md")} == snapshot
    assert "- [Old title](old.md) — a memory" in (mem / "archive" / "INDEX.md").read_text()


def test_dry_run_changes_nothing_and_prints_diff(mem: Path, capsys):
    write_memory(mem, "old.md", age_days=40, frontmatter=memory("Old", "project"))
    write_memory(mem, "f.md", frontmatter=memory("F", "feedback"))
    before = {p: p.read_text() for p in mem.rglob("*")  if p.is_file()}
    mg.main(["--dry-run", "--dir", str(mem)])
    out = capsys.readouterr().out
    assert {p: p.read_text() for p in mem.rglob("*") if p.is_file()} == before
    assert not (mem / ".git").exists()
    assert "+- [F](f.md) — a memory" in out
    assert "rename old.md => archive/old.md" in out


def test_over_budget_warning(mem: Path, capsys):
    for i in range(80):
        write_memory(mem, f"f{i}.md", frontmatter=memory(f"F{i}", "feedback", description="x " * 45))
    mg.main(["--dir", str(mem), "--budget", "6144"])
    assert "over the 6144-byte budget" in capsys.readouterr().out


def test_root_scan_finds_only_dirs_with_index(tmp_path: Path, monkeypatch, capsys):
    for key in ("GIT_AUTHOR_NAME", "GIT_COMMITTER_NAME"):
        monkeypatch.setenv(key, "t")
    for key in ("GIT_AUTHOR_EMAIL", "GIT_COMMITTER_EMAIL"):
        monkeypatch.setenv(key, "t@example.com")
    (tmp_path / "a" / "memory").mkdir(parents=True)
    (tmp_path / "a" / "memory" / "MEMORY.md").write_text("")
    (tmp_path / "b" / "memory").mkdir(parents=True)
    mg.main(["--root", str(tmp_path)])
    out = capsys.readouterr().out
    assert str(tmp_path / "a" / "memory") in out
    assert str(tmp_path / "b" / "memory") not in out
    assert not (tmp_path / "b" / "memory" / ".git").exists()


if __name__ == "__main__":
    sys.exit(pytest.main([__file__, "-q", "-p", "no:cacheprovider", *sys.argv[1:]]))
