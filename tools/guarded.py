#!/usr/bin/env python3
"""Linux counterpart of guarded.ps1: bounded memory, time, and process group.

Use a separate SPARKLING_BUILD_ROOT when switching operating systems.
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import resource
import signal
import subprocess
import time


def available_mb() -> int:
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1]) // 1024
    raise RuntimeError("MemAvailable is unavailable")


def group_rss_mb(pgid: int) -> float:
    pages = 0
    for entry in Path("/proc").iterdir():
        if not entry.name.isdecimal():
            continue
        try:
            # comm may contain spaces and parentheses; fields after it start
            # at field 3 (state). pgrp is field 5, rss is field 24.
            fields = (entry / "stat").read_text().rsplit(")", 1)[1].split()
            if int(fields[2]) == pgid:
                pages += int(fields[21])
        except (FileNotFoundError, ProcessLookupError, PermissionError):
            pass
    return pages * os.sysconf("SC_PAGE_SIZE") / 1024**2


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--cap-mb", type=int, default=4000)
    parser.add_argument("--min-free-mb", type=int, default=12000)
    parser.add_argument("--timeout", type=int, default=900)
    parser.add_argument("command", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    command = args.command[1:] if args.command[:1] == ["--"] else args.command
    if not command or min(args.cap_mb, args.timeout) <= 0 or args.min_free_mb < 0:
        parser.error("a command and positive resource limits are required")
    if available_mb() < args.min_free_mb:
        print("WATCHDOG: insufficient available memory before launch", flush=True)
        return 99

    def limits() -> None:
        limit = args.cap_mb * 1024**2
        resource.setrlimit(resource.RLIMIT_AS, (limit, limit))
        resource.setrlimit(resource.RLIMIT_CORE, (0, 0))

    start = time.monotonic()
    peak = 0.0
    proc = subprocess.Popen(command, start_new_session=True, preexec_fn=limits)
    try:
        while proc.poll() is None:
            peak = max(peak, group_rss_mb(proc.pid))
            if (time.monotonic() - start > args.timeout
                    or peak > args.cap_mb
                    or available_mb() < args.min_free_mb):
                print("WATCHDOG: time or memory limit exceeded", flush=True)
                return 99
            time.sleep(0.25)
        return proc.returncode if proc.returncode >= 0 else 128 - proc.returncode
    finally:
        # Clean up only our process group, including orphaned provers.
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
        proc.wait()
        print(f"guarded: elapsed {time.monotonic() - start:.1f} s, "
              f"peak group RSS {peak:.0f} MB", flush=True)


if __name__ == "__main__":
    raise SystemExit(main())
