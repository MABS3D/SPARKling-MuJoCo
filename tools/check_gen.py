#!/usr/bin/env python3
"""Regenerate in an isolated directory and compare with the working sources."""
from __future__ import annotations

import argparse
import importlib.util
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("test_runner", ROOT / "tests/run.py")
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--alire", action="store_true")
    args = parser.parse_args()
    prefix = ["alr", "exec", "--"] if args.alire else []
    build = Path(os.environ.get("SPARKLING_BUILD_ROOT", str(ROOT))).resolve()
    scratch = build / "obj" / "check-gen"
    scratch.mkdir(parents=True, exist_ok=True)
    try:
        with tempfile.TemporaryDirectory(dir=scratch) as temp:
            target = Path(temp)
            (target / "tools").mkdir()
            shutil.copyfile(ROOT / "tools/gen.py", target / "tools/gen.py")
            engine = target / "mujoco/src/engine"
            engine.mkdir(parents=True)
            shutil.copyfile(ROOT / "mujoco/src/engine/engine_io.c", engine / "engine_io.c")
            suffix = ".exe" if os.name == "nt" else ""
            for name, output in [("xmacro_dump", "fields.txt"), ("layout_dump", "layout.txt")]:
                started = time.time_ns()
                executable = target / (name + suffix)
                subprocess.run(RUNNER.guard([*prefix, "gcc", "-std=c11", "-Wall", "-I",
                               str(ROOT / "mujoco/include"), str(ROOT / f"tools/{name}.c"),
                               "-o", str(executable)]), cwd=ROOT, check=True)
                RUNNER.checked_executables(target, [name], started, suffix)
                subprocess.run([str(executable), str(target / "tools" / output)], check=True, timeout=30)
            subprocess.run([sys.executable, str(target / "tools/gen.py")], cwd=target, check=True, timeout=60)
            generated = [p.relative_to(target) for pattern in ["src/gen/*", "tests/gen/*", "tools/*.txt"]
                         for p in target.glob(pattern) if p.is_file()]
            existing = [p.relative_to(ROOT) for pattern in ["src/gen/*", "tests/gen/*"]
                        for p in ROOT.glob(pattern) if p.is_file()]
            paths = set(generated) | set(existing)
            different = [str(p) for p in sorted(paths) if not (ROOT / p).exists()
                         or not (target / p).exists()
                         or (ROOT / p).read_bytes().replace(b"\r\n", b"\n")
                         != (target / p).read_bytes().replace(b"\r\n", b"\n")]
            if different:
                raise ValueError("generated files differ: " + ", ".join(different))
    except (ValueError, OSError, subprocess.SubprocessError) as error:
        print(f"GENERATION CHECK FAILED: {error}", file=sys.stderr)
        return 1
    print(f"Generation check passed: {len(paths)} files match; working files unchanged")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
