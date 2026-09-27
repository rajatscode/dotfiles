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

CURATED = """# Memory Index

Standing rules live elsewhere, not here.

## Active Projects
- [Alpha hub](alpha-hub.md) — ACTIVE: every alpha file
- [Beta](beta.md) — hand-written hook

## Reference
- [Gamma](gamma.md) — short hook
- Loose note with no link
- [Deep results](sub/RESULTS.md) — lives in a subdirectory

## Archive
- [Archived projects](archive/INDEX.md) — finished work
"""


def write_memory(directory: Path, name: str, *, age_days: float = 0, frontmatter: dict | None = None, body: str = "body\n"):
    path = directory / name
    if frontmatter is None:
        path.write_text(body)
    else:
        frontmatter = dict(frontmatter)
        meta = frontmatter.pop("metadata", None)
        lines = ["---", *(f"{k}: {v}" for k, v in frontmatter.items())]
        if meta:
            lines += ["metadata:", *(f"  {k}: {v}" for k, v in meta.items())]
        lines += ["---", "", body]
        path.write_text("\n".join(lines))
    stamp = NOW - age_days * DAY
    os.utime(path, (stamp, stamp))
    return path


def memory(title: str, type_: str, description: str = "a memory", **meta) -> dict:
    return {"name": title.lower(), "title": title, "description": description, "metadata": {"type": type_, **meta}}


def git(directory: Path, *args: str) -> str:
    return subprocess.run(["git", "-C", str(directory), *args], capture_output=True, text=True, check=True).stdout


def groom(directory: Path, days: float = 21, dry_run: bool = False, now: float = NOW):
    return mg.groom(directory, days, dry_run, now=now)


def index(directory: Path) -> str:
    return (directory / "MEMORY.md").read_text()


@pytest.fixture(autouse=True)
def git_identity(monkeypatch):
    for key in ("GIT_AUTHOR_NAME", "GIT_COMMITTER_NAME"):
        monkeypatch.setenv(key, "t")
    for key in ("GIT_AUTHOR_EMAIL", "GIT_COMMITTER_EMAIL"):
        monkeypatch.setenv(key, "t@example.com")


@pytest.fixture
def mem(tmp_path: Path) -> Path:
    directory = tmp_path / "proj" / "memory"
    directory.mkdir(parents=True)
    (directory / "MEMORY.md").write_text("# Memory Index\n")
    return directory


@pytest.fixture
def curated(mem: Path) -> Path:
    write_memory(mem, "alpha-hub.md", frontmatter=memory("Alpha hub", "project", pinned="true"),
                 body="- [[alpha-one]] — first\n- [Two](alpha-two.md) — second\nSee also [[beta]].\n")
    write_memory(mem, "alpha-one.md", frontmatter=memory("Alpha one", "project", pinned="true"))
    write_memory(mem, "alpha-two.md", frontmatter=memory("Alpha two", "project", pinned="true"))
    write_memory(mem, "beta.md", frontmatter=memory("Beta", "project", "frontmatter hook differs"))
    write_memory(mem, "gamma.md", frontmatter=memory("Gamma", "reference"))
    write_memory(mem, "rule.md", frontmatter=memory("Rule", "feedback", in_claude_md="true"))
    (mem / "archive").mkdir()
    write_memory(mem / "archive", "done.md", frontmatter=memory("Done", "project"))
    (mem / "archive" / "INDEX.md").write_text("# Archived\n\n- [Done](done.md) — old hook\n")
    (mem / "MEMORY.md").write_text(CURATED)
    return mem


def test_curated_index_is_left_byte_for_byte(curated: Path):
    report = groom(curated)
    assert index(curated) == CURATED
    assert (curated / "archive" / "INDEX.md").read_text() == "# Archived\n\n- [Done](done.md) — old hook\n"
    assert report.added == []
    assert report.unlinked == ["- Loose note with no link"]
    assert report.dangling == ["- [Deep results](sub/RESULTS.md) — lives in a subdirectory"]


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
    if archived:
        assert report.archived == ["m.md"]
        assert "](m.md)" not in index(mem)
        assert "(archive/INDEX.md)" in index(mem)
        assert "- [M](m.md) — a memory" in (mem / "archive" / "INDEX.md").read_text()
    else:
        assert "- [M](m.md) — a memory" in index(mem)
        assert "archive/" not in index(mem)


def test_archiving_carries_the_hand_line_into_archive_index(curated: Path):
    path = curated / "gamma.md"
    path.write_text(path.read_text().replace("reference", "project"))
    os.utime(path, (NOW - 40 * DAY,) * 2)
    groom(curated)
    text = index(curated)
    assert "gamma.md" not in text
    assert "## Reference\n- Loose note with no link\n" in text
    assert (curated / "archive" / "INDEX.md").read_text().endswith("- [Gamma](gamma.md) — short hook\n")


def test_emptied_section_heading_is_removed(mem: Path):
    write_memory(mem, "old.md", age_days=40, frontmatter=memory("Old", "project"))
    (mem / "MEMORY.md").write_text("# Memory Index\n\n## Stale\n- [Old](old.md) — hook\n")
    groom(mem)
    assert "## Stale" not in index(mem)


def test_recent_commit_keeps_file_with_old_mtime(mem: Path):
    path = write_memory(mem, "p.md", frontmatter=memory("P", "project"))
    groom(mem)
    os.utime(path, (NOW - 60 * DAY,) * 2)
    groom(mem)
    assert (mem / "p.md").exists()


@pytest.mark.parametrize(("days", "archived"), [(5, True), (21, False)])
def test_archive_threshold_is_configurable(mem: Path, days, archived):
    write_memory(mem, "p.md", age_days=10, frontmatter=memory("P", "project"))
    groom(mem, days=days)
    assert (mem / "archive" / "p.md").exists() is archived


@pytest.mark.parametrize(
    ("name", "frontmatter", "expected"),
    [
        ("delta.md", memory("Delta", "project"), "- [Beta](beta.md) — hand-written hook\n- [Delta](delta.md) — a memory\n"),
        ("eps.md", memory("Eps", "reference"), "- [Deep results](sub/RESULTS.md) — lives in a subdirectory\n- [Eps](eps.md) — a memory\n"),
        ("zeta.md", memory("Zeta", "reference", section="Active Projects"), "- [Beta](beta.md) — hand-written hook\n- [Zeta](zeta.md) — a memory\n"),
    ],
)
def test_new_file_joins_the_section_holding_its_type(curated: Path, name, frontmatter, expected):
    write_memory(curated, name, frontmatter=frontmatter)
    report = groom(curated)
    assert report.added == [name]
    assert expected in index(curated)
    assert index(curated).endswith("## Archive\n- [Archived projects](archive/INDEX.md) — finished work\n")


def test_new_type_gets_new_section_before_archive_in_type_order(curated: Path):
    write_memory(curated, "me.md", frontmatter=memory("Me", "user"))
    write_memory(curated, "fb.md", frontmatter=memory("Fb", "feedback"))
    write_memory(curated, "raw.md", frontmatter=None)
    report = groom(curated)
    headings = [l for l in index(curated).splitlines() if l.startswith("## ")]
    assert headings == ["## User", "## Feedback", "## Active Projects", "## Reference", "## Missing frontmatter", "## Archive"]
    assert report.missing_frontmatter == ["raw.md"]
    assert "## Missing frontmatter\n- [raw](raw.md)\n" in index(curated)


def test_empty_index_groups_by_type_in_fixed_order(mem: Path):
    for name, type_ in (("r.md", "reference"), ("p.md", "project"), ("f.md", "feedback"), ("u.md", "user")):
        write_memory(mem, name, frontmatter=memory(name[0].upper(), type_))
    groom(mem)
    headings = [l for l in index(mem).splitlines() if l.startswith("## ")]
    assert headings == ["## User", "## Feedback", "## Projects", "## Reference"]


@pytest.mark.parametrize("reached", ["alpha-one.md", "alpha-two.md"])
def test_files_reached_through_a_hub_bullet_are_not_added(curated: Path, reached):
    groom(curated)
    assert reached not in index(curated)


def test_prose_wikilink_does_not_count_as_hub_entry(mem: Path):
    write_memory(mem, "hub.md", frontmatter=memory("Hub", "project", pinned="true"), body="See [[leaf]] for more.\n")
    write_memory(mem, "leaf.md", frontmatter=memory("Leaf", "project"))
    (mem / "MEMORY.md").write_text("# Memory Index\n\n## Projects\n- [Hub](hub.md) — h\n")
    report = groom(mem)
    assert report.added == ["leaf.md"]


@pytest.mark.parametrize(
    ("index_text", "listed"),
    [
        ("# Memory Index\n", False),
        ("# Memory Index\n\n## Reference\n- [Rule](rule.md) — kept by hand\n", True),
    ],
)
def test_in_claude_md_files_are_never_added_and_hand_lines_stay(mem: Path, index_text, listed):
    write_memory(mem, "rule.md", frontmatter=memory("Rule", "feedback", in_claude_md="true"))
    (mem / "MEMORY.md").write_text(index_text)
    report = groom(mem)
    assert ("(rule.md)" in index(mem)) is listed
    assert report.added == []


def test_top_level_type_frontmatter_is_read(mem: Path):
    (mem / "old.md").write_text("---\nname: Old style\ndescription: flat keys\ntype: feedback\n---\nbody\n")
    groom(mem)
    assert "## Feedback\n- [Old style](old.md) — flat keys" in index(mem)


@pytest.mark.parametrize(("description", "overlong"), [("short hook", False), (" ".join(["word"] * 30), True)])
def test_added_description_cut_at_word_boundary(mem: Path, description, overlong):
    write_memory(mem, "d.md", frontmatter=memory("D", "feedback", description=description))
    report = groom(mem)
    line = next(l for l in index(mem).splitlines() if "(d.md)" in l)
    rendered = line.split(" — ", 1)[1]
    assert len(rendered) <= 100
    assert rendered.endswith("word…") is overlong
    assert (report.overlong_description == ["d.md"]) is overlong


def test_untyped_memory_is_flagged(mem: Path):
    (mem / "t.md").write_text("---\nname: T\ndescription: no type\n---\nbody\n")
    report = groom(mem)
    assert report.missing_type == ["t.md"]
    assert "- [T](t.md) — no type" in index(mem)


def test_unindexed_archive_file_is_added_to_archive_index(curated: Path):
    write_memory(curated / "archive", "later.md", frontmatter=memory("Later", "project"))
    groom(curated)
    assert (curated / "archive" / "INDEX.md").read_text().endswith("- [Later](later.md) — a memory\n")


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
    os.utime(mem / "p.md", (NOW - 60 * DAY,) * 2)
    groom(mem, now=NOW + 60 * DAY)
    assert "R100\tp.md\tarchive/p.md" in git(mem, "show", "--name-status", "--format=", "HEAD")


@pytest.mark.parametrize("repo_first", [True, False])
def test_second_run_changes_nothing(curated: Path, repo_first):
    if repo_first:
        git(curated, "init", "-q")
    write_memory(curated, "old.md", age_days=40, frontmatter=memory("Old", "project"))
    write_memory(curated, "new.md", frontmatter=memory("New", "reference"))
    write_memory(curated, "raw.md", frontmatter=None)
    groom(curated)
    head = git(curated, "rev-parse", "HEAD")
    snapshot = {p: p.read_text() for p in curated.rglob("*.md")}
    report = groom(curated)
    assert not report.changed
    assert git(curated, "rev-parse", "HEAD") == head
    assert {p: p.read_text() for p in curated.rglob("*.md")} == snapshot


def test_dry_run_changes_nothing_and_prints_diff(mem: Path, capsys):
    write_memory(mem, "old.md", age_days=40, frontmatter=memory("Old", "project"))
    write_memory(mem, "f.md", frontmatter=memory("F", "feedback"))
    before = {p: p.read_text() for p in mem.rglob("*") if p.is_file()}
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


def test_root_scan_finds_only_dirs_with_index(tmp_path: Path, capsys):
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
