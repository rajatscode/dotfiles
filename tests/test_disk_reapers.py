import os
import subprocess
from pathlib import Path

import pytest


BIN = Path(__file__).resolve().parents[1] / "dot_local/bin"


def executable(path: Path, content: str) -> None:
    path.write_text(content)
    path.chmod(0o755)


@pytest.mark.parametrize("free_kib, pressure", [(10_000_000, True), (100_000_000, False)])
def test_orb_reap_prunes_unused_images_only_under_pressure(
    tmp_path: Path, free_kib: int, pressure: bool
) -> None:
    commands = tmp_path / "docker-commands"
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    executable(bin_dir / "orb", "#!/bin/sh\n[ \"$1\" = status ] && echo Running\n")
    executable(
        bin_dir / "docker",
        '#!/bin/sh\nprintf "%s\\n" "$*" >> "$DOCKER_COMMANDS"\n'
        'case "$1" in info|ps) exit 0 ;; *) echo "Total: 0B" ;; esac\n',
    )
    executable(
        bin_dir / "df",
        f'#!/bin/sh\nprintf "Filesystem 1024-blocks Used Available Capacity Mounted on\\nmock 100000000 0 {free_kib} 0%% /\\n"\n',
    )
    env = os.environ | {
        "PATH": f"{bin_dir}:{os.environ['PATH']}",
        "HOME": str(tmp_path),
        "DOCKER_COMMANDS": str(commands),
        "ORB_REAP_LOG": str(tmp_path / "orb.log"),
    }

    result = subprocess.run([BIN / "executable_orb-reap", "--apply"], env=env, capture_output=True, text=True)

    assert result.returncode == 0, result.stderr
    calls = commands.read_text()
    if pressure:
        assert "image prune -a -f --filter until=24h" in calls
        assert "builder prune -a -f --filter until=24h" in calls
    else:
        assert "image prune -f" in calls
        assert "image prune -a" not in calls


@pytest.mark.parametrize("state", ["idle", "active", "locked"])
def test_wt_reap_trims_ignored_dependencies_but_keeps_unpublished_worktree(
    tmp_path: Path, state: str
) -> None:
    repo = tmp_path / "repo"
    wt = tmp_path / "unpublished"
    repo.mkdir()
    bin_dir = tmp_path / "bin"
    bin_dir.mkdir()
    executable(bin_dir / "pgrep", "#!/bin/sh\nexit 1\n")
    executable(bin_dir / "lsof", f"#!/bin/sh\n{'echo n' + str(wt) if state == 'active' else ':'}\n")
    env = os.environ | {
        "PATH": f"{bin_dir}:{os.environ['PATH']}",
        "HOME": str(tmp_path),
        "WT_REAP_LOG": str(tmp_path / "wt.log"),
        "GIT_AUTHOR_NAME": "Test",
        "GIT_AUTHOR_EMAIL": "test@example.com",
        "GIT_COMMITTER_NAME": "Test",
        "GIT_COMMITTER_EMAIL": "test@example.com",
        "GIT_AUTHOR_DATE": "2020-01-01T00:00:00+00:00",
        "GIT_COMMITTER_DATE": "2020-01-01T00:00:00+00:00",
    }

    def git(*args: str) -> None:
        subprocess.run(["git", *args], cwd=repo, env=env, check=True, capture_output=True)

    git("init", "-b", "main")
    (repo / ".gitignore").write_text("node_modules/\n.venv/\nlinked\n")
    git("add", ".gitignore")
    git("commit", "-m", "initial")
    git("worktree", "add", "-b", "unpublished", str(wt))
    if state == "locked":
        git("worktree", "lock", str(wt))
    os.utime(wt / ".git", (1_577_836_800, 1_577_836_800))
    cache = wt / "node_modules"
    cache.mkdir()
    (cache / "generated").write_text("rebuildable")
    outside = tmp_path / "outside"
    (outside / ".venv").mkdir(parents=True)
    (wt / "linked").symlink_to(outside, target_is_directory=True)

    result = subprocess.run(
        [BIN / "executable_wt-reap", "--repo", str(repo), "--apply"],
        env=env,
        cwd=tmp_path,
        capture_output=True,
        text=True,
    )

    assert result.returncode == 0, result.stderr
    assert wt.is_dir()
    assert cache.is_dir() is (state != "idle")
    assert (outside / ".venv").is_dir()
    assert "unpushed commits" in result.stdout
