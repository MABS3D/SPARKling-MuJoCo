#!/usr/bin/env python3
"""Prove the entire library, one unit at a time, and validate fresh reports."""
from __future__ import annotations

import argparse
import hashlib
import importlib.util
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import time

import prove_report

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("test_runner", ROOT / "tests/run.py")
RUNNER = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(RUNNER)


def source_hashes() -> dict[str, str]:
    paths = [*ROOT.glob("src/**/*.ad?"), ROOT / "sparkling_mujoco.gpr"]
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}


def archive_reports(build: Path) -> None:
    """GNATprove's exit status can include failures from old unselected reports."""
    directory = build / "obj/development/gnatprove"
    previous = [*directory.glob("*.spark"), *directory.glob("*.invocation.json")]
    summary = directory / "gnatprove.out"
    if summary.exists():
        previous.append(summary)
    if previous:
        destination = build / "proof-history" / str(time.time_ns())
        destination.mkdir(parents=True)
        for path in previous:
            shutil.move(str(path), str(destination / path.name))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--alire", action="store_true")
    parser.add_argument("--jobs", type=int, choices=range(1, 9), default=1)
    parser.add_argument("--cap-mb", type=int, default=4000)
    parser.add_argument("--guard-timeout", type=int, default=3600)
    parser.add_argument("--unit", action="append", default=[],
                        help="prove selected complete units; omitted means the entire library")
    parser.add_argument("extra", nargs=argparse.REMAINDER)
    args = parser.parse_args()
    extra = args.extra[1:] if args.extra[:1] == ["--"] else args.extra
    if any(x == "-u" or x.startswith("--limit-") for x in extra):
        parser.error("use --unit for complete units; line/subprogram-limited runs are diagnostic only")
    env = os.environ.copy()
    build = Path(env.get("SPARKLING_BUILD_ROOT", str(ROOT))).resolve()
    env["SPARKLING_BUILD_ROOT"] = str(build)
    prefix = ["alr", "exec", "--"] if args.alire else []
    hashes = source_hashes()
    started = time.time()
    try:
        annotations = sum(len(re.findall(r"\bpragma\s+Annotate\s*\(\s*GNATprove", prove_report.source_code(p), re.I))
                          for p in ROOT.glob("src/**/*.ad?"))
        ledger = sum(line.startswith("- ") for line in (ROOT / "docs/proof-justifications.md").read_text().splitlines())
        if annotations != ledger:
            raise ValueError(f"{annotations} annotations but {ledger} justification entries")
        required = prove_report.required_units()
        units = sorted(set(args.unit) if args.unit else required)
        if set(units) - required:
            raise ValueError("unknown proof units: " + ", ".join(sorted(set(units) - required)))
        if not units:
            raise ValueError("no proof units found")
        archive_reports(build)
        for unit in units:
            sources = list(ROOT.glob(f"src/**/{unit}.adb")) or list(ROOT.glob(f"src/**/{unit}.ads"))
            if len(sources) != 1:
                raise ValueError(f"ambiguous proof source for {unit}")
            print(f"== proving {unit}", flush=True)
            unit_started = time.time()
            command = [*prefix, "gnatprove", "-P", "sparkling_mujoco.gpr",
                           "-XSPARKLING_BUILD_MODE=development", "-u", sources[0].name,
                           f"-j{args.jobs}", "--level=2", "--timeout=20", "--report=all",
                           "--checks-as-errors=on", "--warnings=continue", *extra]
            subprocess.run(RUNNER.guard(command,
                           timeout=args.guard_timeout, cap_mb=args.cap_mb), cwd=ROOT, env=env, check=True)
            if source_hashes() != hashes:
                raise ValueError("sources changed during the proof run")
            prove_report.record_invocation(build / "obj/development/gnatprove", unit,
                                           unit_started, hashes, command)
            # Also catches failed child processes for which Alire returned zero.
            if prove_report.main(["--build-root", str(build), "--since", str(unit_started), "--unit", unit]):
                raise ValueError(f"proof report rejected for {unit}")
        if source_hashes() != hashes:
            raise ValueError("sources changed during the proof run")
        scope = [arg for unit in units for arg in ("--unit", unit)] if args.unit else []
        if prove_report.main(["--build-root", str(build), "--since", str(started), *scope]):
            raise ValueError("whole-library reports rejected")
    except (ValueError, OSError, subprocess.CalledProcessError) as error:
        print(f"PROOF FAILED: {error}", file=sys.stderr)
        return 1
    print(f"PROOF OK: {len(units)} complete units; {ledger} documented annotations; "
          f"scope={'selected units' if args.unit else 'whole library'}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
