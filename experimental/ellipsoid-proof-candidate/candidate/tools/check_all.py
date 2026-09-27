#!/usr/bin/env python3
"""Local/CI entry point: generation, all build profiles, tools, then full proof."""
import argparse
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import time

from check_gen import RUNNER

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--alire", action="store_true")
    args = parser.parse_args()
    extra = ["--alire"] if args.alire else []
    prefix = ["alr", "exec", "--"] if args.alire else []
    env = os.environ.copy()
    build = Path(env.get("SPARKLING_BUILD_ROOT", str(ROOT))).resolve()
    env["SPARKLING_BUILD_ROOT"] = str(build)
    try:
        subprocess.run([sys.executable, "tools/check_gen.py", *extra], cwd=ROOT, env=env, check=True)
        for mode in ["development", "validation", "release"]:
            subprocess.run([sys.executable, "tests/run.py", "--mode", mode, *extra],
                           cwd=ROOT, env=env, check=True)
        started = time.time_ns()
        subprocess.run(RUNNER.guard([*prefix, "gprbuild", "-P", "tools/tools.gpr",
                       "-XSPARKLING_BUILD_MODE=validation", "-f", "-j2", "-p", "-q"]),
                       cwd=ROOT, env=env, check=True)
        executable = RUNNER.checked_executables(build / "bin", ["mjinfo"], started,
                                               ".exe" if os.name == "nt" else "")[0]
        with tempfile.TemporaryDirectory(prefix="mjinfo-check-", dir=build) as temporary:
            for arguments, status in [([], 2), (["tests/out/corpus/model__humanoid__humanoid.mjb"], 0),
                                      ([str(Path(temporary) / "missing.mjb")], 1)]:
                result = subprocess.run(RUNNER.guard([str(executable), *arguments]), cwd=ROOT, env=env)
                if result.returncode != status:
                    raise ValueError(f"mjinfo exited {result.returncode}, expected {status}")
        subprocess.run([sys.executable, "tools/prove.py", *extra], cwd=ROOT, env=env, check=True)
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"CHECKS FAILED: {error}", file=sys.stderr)
        return 1
    print("ALL CHECKS PASSED: generation, profiles, tests, tools and whole-library proof")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
