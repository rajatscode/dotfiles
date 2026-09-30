---
name: agent-slot
description: Use the shared two-slot runner for CPU or memory-heavy tests, builds, and jobs.
---

Run heavy commands as `agent-slot -- command [args...]`. It waits for one of
two machine-wide slots; use it for test suites and builds, not lightweight
inspection.
