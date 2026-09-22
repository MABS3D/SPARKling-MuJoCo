#!/usr/bin/env python3
"""Build and run the declared Ada tests, Python gate tests and C comparisons."""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import re
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]


def declared_tests(project: Path) -> list[str]:
    code = re.sub(r"--[^\n]*", "", project.read_text(encoding="utf-8"))
    match = re.search(r"\bfor\s+Main\s+use\s*\((.*?)\)\s*;", code, re.I | re.S)
    entries = re.findall(r'"([^\"]*)"', match[1]) if match else []
    remainder = re.sub(r'"[^\"]*"|[\s,]', "", match[1]) if match else ""
    if (not entries or remainder or len(set(entries)) != len(entries)
            or any(not re.fullmatch(r"test_[A-Za-z0-9_]+\.adb", e) for e in entries)):
        raise ValueError("tests.gpr must declare a nonempty, unique list of test_*.adb mains")
    return [e[:-4] for e in entries]


def checked_executables(directory: Path, names: list[str], since_ns: int,
                        suffix: str) -> list[Path]:
    if not names:
        raise ValueError("no tests were declared")
    result = []
    for name in names:
        path = directory / (name + suffix)
        if not path.is_file():
            raise ValueError(f"missing test executable: {path}")
        if path.stat().st_mtime_ns < since_ns:
            raise ValueError(f"stale test executable: {path}")
        result.append(path)
    return result


def guard(command: list[str], timeout: int = 900, cap_mb: int = 4000) -> list[str]:
    if os.name == "nt":
        return ["powershell.exe", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
                str(ROOT / "tools/guarded.ps1"), "-CapMB", str(cap_mb),
                "-TimeoutSec", str(timeout), "--", *command]
    return [sys.executable, str(ROOT / "tools/guarded.py"), "--cap-mb", str(cap_mb),
            "--timeout", str(timeout), "--", *command]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=["development", "validation", "release"], default="validation")
    parser.add_argument("--jobs", type=int, choices=range(1, 9), default=2)
    parser.add_argument("--alire", action="store_true")
    args = parser.parse_args()
    env = os.environ.copy()
    build_root = Path(env.get("SPARKLING_BUILD_ROOT", str(ROOT))).resolve()
    env["SPARKLING_BUILD_ROOT"] = str(build_root)
    prefix = ["alr", "exec", "--"] if args.alire else []
    try:
        names = declared_tests(ROOT / "tests/tests.gpr")
        since_ns = time.time_ns()
        subprocess.run(guard([*prefix, "gprbuild", "-P", "tests/tests.gpr",
                       f"-XSPARKLING_BUILD_MODE={args.mode}", f"-j{args.jobs}", "-f", "-p", "-q"]),
                       cwd=ROOT, env=env, check=True)
        paths = checked_executables(build_root / "bin", names, since_ns,
                                    ".exe" if os.name == "nt" else "")
        failed = []
        for path in paths:
            print(f"== {path.name}", flush=True)
            if subprocess.run(guard([str(path)]), cwd=ROOT, env=env).returncode:
                failed.append(path.name)
        if failed:
            raise ValueError("failed tests: " + ", ".join(failed))
        subprocess.run([sys.executable, "-m", "unittest", "discover", "-s", "tests",
                        "-p", "test_*.py", "-v"], cwd=ROOT, env=env, check=True)
        subprocess.run([sys.executable, "tools/compare_blas.py", "--mode", args.mode,
                        *(["--alire"] if args.alire else [])], cwd=ROOT, env=env, check=True)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"TESTS FAILED: {error}", file=sys.stderr)
        return 1
    print(f"All {len(paths)} declared Ada tests, Python tests and BLAS comparisons passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
