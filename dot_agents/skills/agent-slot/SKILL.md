---
name: agent-slot
description: Use the shared runner for CPU or memory-heavy tests, builds, and jobs.
---

Run heavy commands as `agent-slot -- command [args...]`. All harnesses share
machine-wide locks; capacity is derived from physical cores and RAM. Use it
for test suites, builds, and other expensive jobs; lightweight inspection
does not need a slot. `agent-slot --status` shows the detected capacity.

Each slot covers a whole command. The runner does not pin cores or limit
parallelism within the command.
