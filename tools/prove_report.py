#!/usr/bin/env python3
"""Report SPARK results and reject missing, stale, or incomplete unit reports.

Use --unit NAME (repeatable) for an explicitly partial check. With no --unit,
all source packages declaring subprograms must have complete proof reports.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent

# These are the existing, explicit trusted boundaries. Every other reported
# entity must have its body in SPARK, not just its specification.
TRUSTED_SPEC_ONLY = {
    "mj-file_io": {"mj.file_io", "mj.file_io.read_file", "mj.file_io.write_file"},
    "mj-bytes": {"mj.bytes.bits_to_real", "mj.bytes.bits_to_float"},
}


def source_hashes() -> dict[str, str]:
    paths = [*ROOT.glob("src/**/*.ad?"), ROOT / "sparkling_mujoco.gpr"]
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}


def record_invocation(directory: Path, unit: str, started: float,
                      sources: dict[str, str], command: list[str]) -> None:
    """Bind a complete-unit command to its report; called only by the driver."""
    report = directory / (unit + ".spark")
    receipt = {"schema": 1, "unit": unit, "started": started,
               "sources": sources, "command": command,
               "report_sha256": hashlib.sha256(report.read_bytes()).hexdigest()}
    (directory / (unit + ".invocation.json")).write_text(json.dumps(receipt, indent=2) + "\n")


def invocation_matches(path: Path, unit: str, sources: dict[str, str], since: float) -> bool:
    """Entity coverage alone cannot detect --limit-region/--limit-line reports."""
    try:
        receipt = json.loads(path.with_suffix(".invocation.json").read_text())
        command = receipt["command"]
        position = command.index("-u")
        return (receipt["schema"] == 1 and receipt["unit"] == unit
                and receipt["sources"] == sources and receipt["started"] >= since
                and receipt["report_sha256"] == hashlib.sha256(path.read_bytes()).hexdigest()
                and isinstance(command, list) and command.count("-u") == 1
                and command[position + 1] in (unit + ".ads", unit + ".adb")
                and not any(arg.startswith("--limit-") for arg in command))
    except (OSError, ValueError, KeyError, TypeError, IndexError, AttributeError):
        return False


def source_code(path: Path) -> str:
    # Match strings and comments together so "--" inside a string is not a comment.
    return re.sub(r'--[^\n]*|"(?:[^"]|"")*"', "", path.read_text(encoding="utf-8"))


def required_units() -> set[str]:
    result = set()
    for source in (ROOT / "src").rglob("*.ad?"):
        code = source_code(source)
        # Separate bodies are analyzed with their parent, not as extra units.
        if re.search(r"^\s*separate\s*\(", code, re.IGNORECASE | re.MULTILINE):
            continue
        if re.search(r"\b(function|procedure)\b", code, re.IGNORECASE):
            result.add(source.stem)
    return result


def required_subprograms(unit: str) -> set[str]:
    """Names declared by this project's unit, including its separate bodies."""
    result = set()
    for source in (ROOT / "src").rglob("*.ad?"):
        code = source_code(source)
        separate = re.search(r"\bseparate\s*\(\s*([\w.]+)\s*\)", code, re.IGNORECASE)
        owner = separate[1].replace(".", "-").lower() if separate else source.stem
        if owner != unit:
            continue
        # GNATprove does not report bodies for these compiler intrinsics inside
        # the two trusted bit-conversion routines in MJ.Bytes.
        code = re.sub(r"\bfunction\s+\w+\s+is\s+new\s+Ada\.Unchecked_Conversion"
                      r"\s*\([^;]*\);", "", code, flags=re.IGNORECASE)
        result.update(name.lower() for name in
                      re.findall(r"\b(?:function|procedure)\s+(\w+)", code, re.IGNORECASE))
    return result


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("-v", "--verbose", action="store_true")
    parser.add_argument("--unit", action="append", default=[])
    parser.add_argument("--mode", default="development")
    parser.add_argument("--build-root", type=Path,
                        default=Path(os.environ.get("SPARKLING_BUILD_ROOT", ROOT)))
    parser.add_argument("--since", type=float, default=0,
                        help="reject reports older than this Unix timestamp")
    args = parser.parse_args(argv)
    directory = args.build_root / "obj" / args.mode / "gnatprove"
    units = {Path(u).stem for u in args.unit} if args.unit else required_units()
    newest_source = max(p.stat().st_mtime for p in (ROOT / "src").rglob("*.ad?")
                        if p.suffix in (".ads", ".adb"))
    cutoff = max(args.since, newest_source)
    sources = source_hashes()
    total_ok = total_bad = total_warnings = total_trusted = 0
    invalid = False
    for unit in sorted(units):
        path = directory / (unit + ".spark")
        if not path.exists():
            print(f"{unit:<28} MISSING")
            invalid = True
            continue
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (OSError, ValueError) as error:
            print(f"{unit:<28} INVALID: {error}")
            invalid = True
            continue
        sections = ("flow", "proof", "warn_error", "skip_proof", "skip_flow_proof", "pragma_assume")
        if (not isinstance(data, dict)
                or any(not isinstance(data.get(section), list) for section in sections)
                or not isinstance(data.get("entities"), dict)
                or not isinstance(data.get("spark"), dict)
                or any(not isinstance(entity, dict) or not isinstance(entity.get("name"), str)
                       for entity in data["entities"].values())
                or any(key not in data["entities"] for key in data["spark"])
                or any(not isinstance(entry, dict)
                       for section in ("flow", "proof", "warn_error")
                       for entry in data[section])):
            print(f"{unit:<28} INVALID: missing or malformed report sections")
            invalid = True
            continue
        problems = []
        if not invocation_matches(path, unit, sources, args.since):
            problems.append("UNATTESTED (run tools/prove.py)")
        if path.stat().st_mtime < cutoff:
            problems.append("STALE")
        if (data.get("progress") != "PROGRESS_PROOF"
                or data.get("stop_reason") != "STOP_REASON_NONE"):
            problems.append("INCOMPLETE")
        if data.get("skip_proof") or data.get("skip_flow_proof"):
            problems.append("SKIPPED")
        if data["pragma_assume"]:
            problems.append("ASSUMED")
        # A --limit-subp run can have PROGRESS_PROOF and no skip_proof entries.
        # The subprogram names in this project are distinct within each unit;
        # check declarations, including leaf routines absent from the call graph.
        reported = {data["entities"][key]["name"].rsplit(".", 1)[-1].lower()
                    for key in data["spark"]}
        declared = required_subprograms(unit)
        missing = declared - reported
        if missing:
            problems.append(f"PARTIAL ({len(missing)} subprograms absent)")
            if args.verbose:
                print("    Not analyzed: " + ", ".join(sorted(missing)))
        outside = []
        trusted = 0
        for key, mode in data["spark"].items():
            name = data["entities"][key]["name"].lower()
            if mode == "all":
                continue
            if mode == "spec" and name in TRUSTED_SPEC_ONLY.get(unit, set()):
                trusted += name.rsplit(".", 1)[-1] in declared
            else:
                outside.append(name)
        if outside:
            problems.append(f"OUTSIDE_SPARK ({len(outside)} entities)")
            if args.verbose:
                print("    Bodies not in SPARK: " + ", ".join(sorted(outside)))
        entries = [(section, entry) for section in ("flow", "proof", "warn_error")
                   for entry in data.get(section, [])]
        ok = bad = warnings = 0
        for section, entry in entries:
            severity = entry.get("severity", "")
            if severity == "info":
                # Frontend notes (e.g. loop unrolling) are not proved checks.
                if section != "warn_error":
                    ok += 1
            elif severity == "warning":
                warnings += 1
            else:
                bad += 1
            if args.verbose and (severity != "info" or section == "warn_error"):
                message = entry.get("message", {})
                message = message.get("text", "") if isinstance(message, dict) else str(message)
                print(f"    {entry.get('file')}:{entry.get('line')}:{entry.get('col')} "
                      f"{entry.get('rule')} {severity}: {message}")
        total_ok += ok
        total_bad += bad
        total_warnings += warnings
        total_trusted += trusted
        invalid |= bool(problems)
        print(f"{unit:<28} proved={ok:6} unproved={bad:4} warnings={warnings:4} "
              + (f"trusted-bodies={trusted} " if trusted else "") + " ".join(problems))
    print(f"TOTAL proved={total_ok} unproved={total_bad} warnings={total_warnings}; "
          f"scope={'selected units' if args.unit else 'all subprogram units'}; "
          f"trusted-bodies={total_trusted}")
    return 2 if invalid or total_bad else 0


if __name__ == "__main__":
    raise SystemExit(main())
