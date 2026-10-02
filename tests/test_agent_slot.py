import importlib.machinery
import importlib.util
import os
import selectors
import subprocess
import sys
from pathlib import Path

import pytest

SCRIPT = Path(__file__).resolve().parents[1] / "dot_local/bin/executable_agent-slot"
sys.dont_write_bytecode = True
loader = importlib.machinery.SourceFileLoader("agent_slot", str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
agent_slot = importlib.util.module_from_spec(spec)
loader.exec_module(agent_slot)


@pytest.mark.parametrize(
    "cores,ram_gib,slots",
    [(1, 2, 1), (4, 8, 1), (6, 64, 2), (12, 24, 4), (12, 64, 5),
     (32, 16, 3), (32, 32, 6), (64, 64, 12)],
)
def test_capacity_reserves_cpu_and_memory(cores, ram_gib, slots):
    assert agent_slot.slot_capacity(cores, ram_gib * agent_slot.GIB) == slots


def test_linux_physical_cores_count_packages_and_ignore_smt(tmp_path):
    for cpu, package, core in [(0, 0, 0), (1, 0, 0), (2, 0, 1), (3, 1, 0)]:
        topology = tmp_path / f"cpu{cpu}" / "topology"
        topology.mkdir(parents=True)
        (topology / "physical_package_id").write_text(str(package))
        (topology / "core_id").write_text(str(core))
    assert agent_slot.linux_cores(tmp_path) == 3


def test_linux_virtual_cpu_fallback(tmp_path, monkeypatch):
    monkeypatch.setattr(agent_slot.os, "cpu_count", lambda: 8)
    assert agent_slot.linux_cores(tmp_path) == 8


def test_mac_resources_use_physical_cores(monkeypatch):
    monkeypatch.setattr(agent_slot.sys, "platform", "darwin")

    def sysctl(command, text):
        assert command == ["sysctl", "-n", "hw.physicalcpu", "hw.memsize"]
        return f"12\n{24 * agent_slot.GIB}\n"

    monkeypatch.setattr(agent_slot.subprocess, "check_output", sysctl)
    assert agent_slot.device_resources() == (12, 24 * agent_slot.GIB)


def test_linux_resources_use_total_memory(monkeypatch):
    monkeypatch.setattr(agent_slot.sys, "platform", "linux")
    monkeypatch.setattr(agent_slot, "linux_cores", lambda: 8)
    monkeypatch.setattr(agent_slot.os, "sysconf", lambda key: {
        "SC_PHYS_PAGES": 4 * 1024**2, "SC_PAGE_SIZE": 4096,
    }[key])
    assert agent_slot.device_resources() == (8, 16 * agent_slot.GIB)


def read_ready(process):
    with selectors.DefaultSelector() as selector:
        selector.register(process.stdout, selectors.EVENT_READ)
        assert selector.select(timeout=5), "wrapped dummy command did not start"
    assert process.stdout.readline() == "ready\n"


@pytest.mark.parametrize("capacity", [1, 2, 4])
def test_shared_slots_queue_and_release_after_command_exit(tmp_path, capacity):
    processes = []
    launcher = (
        "import importlib.machinery, sys; "
        f"m = importlib.machinery.SourceFileLoader('slot', {str(SCRIPT)!r}).load_module(); "
        f"m.device_resources = lambda: ({capacity * 2 + 2}, 64 * m.GIB); "
        "sys.argv = ['agent-slot', '--', sys.executable, '-c', "
        "'import sys; print(\"ready\", flush=True); sys.stdin.readline(); sys.exit(7)']; "
        "sys.exit(m.main())"
    )
    env = os.environ | {"XDG_STATE_HOME": str(tmp_path), "PYTHONDONTWRITEBYTECODE": "1"}

    def start():
        process = subprocess.Popen(
            [sys.executable, "-c", launcher], env=env, stdin=subprocess.PIPE,
            stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True,
        )
        processes.append(process)
        return process

    try:
        for _ in range(capacity):
            read_ready(start())
        queued = start()
        with selectors.DefaultSelector() as selector:
            selector.register(queued.stdout, selectors.EVENT_READ)
            assert not selector.select(timeout=0.2), "command exceeded shared capacity"
        processes[0].stdin.write("done\n")
        processes[0].stdin.flush()
        assert processes[0].wait(timeout=5) == 7
        read_ready(queued)
        for process in processes[1:]:
            process.stdin.write("done\n")
            process.stdin.flush()
            assert process.wait(timeout=5) == 7
    finally:
        for process in processes:
            if process.poll() is None:
                process.stdin.write("done\n")
                process.stdin.flush()
                process.wait(timeout=5)
            process.stdin.close()
            process.stdout.close()
            process.stderr.close()
