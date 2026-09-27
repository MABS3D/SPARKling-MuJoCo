#!/usr/bin/env python3
"""Compare immutable matrix binaries in balanced four-treatment timing blocks.

Each binary must accept: BACKEND OP NR NC NK REPS PATTERN SEED, with backend 0=C and 1=Ada.
All confidence intervals are individual, per-case bootstrap intervals for the
median of paired ratios within this session. They are not simultaneous bounds,
independent-session evidence, or proof that an interval containing 1 is parity.
"""

import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import random
import statistics
import subprocess
import time


OPERATIONS = {1: 'Copy9', 2: 'MulMatVec3', 3: 'MulMatTVec3', 4: 'MulMatMat3', 5: 'MulMatTMat3', 6: 'MulMatMatT3', 7: 'MulMatVec', 8: 'MulMatTVec', 9: 'MulVecMatVec', 10: 'Transpose', 11: 'Symmetrize', 12: 'Eye', 13: 'CopyRows', 14: 'MulMatMat', 15: 'MulMatTMat', 16: 'MulMatMatT', 17: 'Gram', 18: 'WeightedGram', 19: 'WeightedGram.lower', 20: 'Gram.lower'}

TREATMENTS = ("baseline_c", "baseline_ada", "candidate_c", "candidate_ada")
# Williams design: in each group of four blocks every treatment occupies every
# position once, and every directed adjacent-treatment pair occurs once.
ORDERS = ((0, 1, 3, 2), (1, 2, 0, 3), (2, 3, 1, 0), (3, 0, 2, 1))
METRICS = {
    "candidate_ada_over_baseline_ada": ("candidate_ada", "baseline_ada"),
    "candidate_c_over_baseline_c": ("candidate_c", "baseline_c"),
    "baseline_ada_over_c": ("baseline_ada", "baseline_c"),
    "candidate_ada_over_c": ("candidate_ada", "candidate_c"),
}


def now():
    return datetime.now(timezone.utc).isoformat()


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def write_report(path, report):
    temporary = path.with_name(path.name + ".tmp")
    temporary.write_text(json.dumps(report, indent=2, allow_nan=False) + "\n")
    temporary.replace(path)


def selected(text, allowed, name):
    try:
        values = [int(value.strip()) for value in text.split(",")]
    except ValueError as exc:
        raise argparse.ArgumentTypeError(f"{name}: use comma-separated integers") from exc
    if not values or len(set(values)) != len(values) or not set(values) <= set(allowed):
        raise argparse.ArgumentTypeError(f"{name}: distinct values required from {list(allowed)}")
    return values


def cpu_description(cpu):
    source = Path("/proc/cpuinfo")
    if not source.exists():
        return None
    for section in source.read_text().split("\n\n"):
        fields = dict(line.split(":", 1) for line in section.splitlines() if ":" in line)
        fields = {key.strip(): value.strip() for key, value in fields.items()}
        if fields.get("processor") == str(cpu):
            return section
    return None


def distribution(values, rng, draws):
    median = statistics.median(values)
    boot = sorted(statistics.median(rng.choices(values, k=len(values)))
                  for _ in range(draws))
    lo = boot[max(0, math.floor(0.025 * draws))]
    hi = boot[min(draws - 1, math.ceil(0.975 * draws) - 1)]
    return {
        "median": median,
        "mad": statistics.median(abs(value - median) for value in values),
        "bootstrap_median_95": [lo, hi],
        "status": "slower" if lo > 1 else "faster" if hi < 1 else "within_noise",
        "ratios": values,
    }


def summarize(blocks, reps, case_seed, draws):
    result = {}
    for metric_index, (name, (numerator, denominator)) in enumerate(METRICS.items()):
        metric = {}
        for clock_index, clock in enumerate(("cpu_ns", "wall_ns")):
            ratios = [block["samples"][numerator][clock] /
                      block["samples"][denominator][clock] for block in blocks]
            rng = random.Random(case_seed + 100 * metric_index + clock_index)
            summary = distribution(ratios, rng, draws)
            # Expose treatment-order sensitivity rather than filtering samples.
            groups = {"numerator_first": [], "denominator_first": []}
            for block, ratio in zip(blocks, ratios):
                key = ("numerator_first" if block["order"].index(numerator) <
                       block["order"].index(denominator) else "denominator_first")
                groups[key].append(ratio)
            summary["order_strata"] = {
                key: {"n": len(values), "median": statistics.median(values)}
                for key, values in groups.items() if values
            }
            metric[clock] = summary
        result[name] = metric
    treatment_summary = {}
    for treatment in TREATMENTS:
        rows = [block["samples"][treatment] for block in blocks]
        treatment_summary[treatment] = {
            "median_cpu_ns_per_call": statistics.median(row["cpu_ns"] / reps for row in rows),
            "median_wall_ns_per_call": statistics.median(row["wall_ns"] / reps for row in rows),
            "median_wall_over_cpu": statistics.median(row["wall_ns"] / row["cpu_ns"] for row in rows),
            "median_switches": statistics.median(row["switches"] for row in rows),
            "total_switches": sum(row["switches"] for row in rows),
            "positions": dict(Counter(block["order"].index(treatment) + 1 for block in blocks)),
        }
    return result, treatment_summary


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", type=Path, required=True)
    parser.add_argument("--candidate", type=Path, required=True)
    parser.add_argument("--baseline-ada-backend", type=int, choices=(1,2), default=1,
                        help="use 2 for the baseline Ada copy in the shared executable")
    parser.add_argument("--cases", type=Path, required=True,
                        help="JSON list of [op, nr, nc, nk, pattern] cases")
    parser.add_argument("--pairs", type=int, default=31,
                        help="four-treatment blocks per case (default: 31); multiples of 4 are exactly balanced")
    parser.add_argument("--ms", type=float, default=40.0,
                        help="target CPU milliseconds for fastest treatment per sample")
    parser.add_argument("--cpu", type=int, default=0)
    parser.add_argument("--seed", type=int, default=20260924,
                        help="recorded seed for case order, order rotation and bootstrap")
    parser.add_argument("--bootstrap", type=int, default=5000)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    cases = json.loads(args.cases.read_text())
    if (not isinstance(cases, list) or not cases or
        any(not isinstance(case, list) or len(case) != 5 or
            any(type(value) is not int for value in case) or
            case[0] not in OPERATIONS or min(case[1:4]) < 0 or
            max(case[1:4]) > 128 or case[4] not in (0, 1) for case in cases)):
        parser.error("cases must be nonempty valid [op,nr,nc,nk,pattern] integer lists; dimensions 0..128")
    cases = [tuple(case) for case in cases]
    if len(set(cases)) != len(cases):
        parser.error("duplicate cases")
    if args.pairs < 5 or not math.isfinite(args.ms) or args.ms <= 0 or args.bootstrap < 1000:
        parser.error("require pairs >= 5, finite ms > 0, bootstrap >= 1000")
    binaries = {"baseline": args.baseline.resolve(), "candidate": args.candidate.resolve()}
    for name, binary in binaries.items():
        if not binary.is_file() or not os.access(binary, os.X_OK):
            parser.error(f"{name} must name an executable file: {binary}")
    output = args.output.resolve()
    if output in binaries.values() or output == Path(__file__).resolve():
        parser.error("output must not overwrite a binary or this script")
    allowed_cpus = sorted(os.sched_getaffinity(0))
    if args.cpu not in allowed_cpus:
        parser.error(f"CPU {args.cpu} unavailable; allowed CPUs: {allowed_cpus}")
    os.sched_setaffinity(0, {args.cpu})
    output.parent.mkdir(parents=True, exist_ok=True)
    requested_cases = [dict(zip(("op", "nr", "nc", "nk", "pattern"), case)) for case in cases]
    random.Random(args.seed).shuffle(cases)
    comparator_hash = sha256(Path(__file__).resolve())
    report = {
        "complete": False, "recorded_at_utc": now(), "platform": platform.platform(),
        "cpu": args.cpu, "allowed_cpus_before_pinning": allowed_cpus,
        "cpuinfo": cpu_description(args.cpu),
        "binary_paths": {name: str(path) for name, path in binaries.items()},
        "binary_sha256": {name: sha256(path) for name, path in binaries.items()},
        "script_sha256": comparator_hash,
        "source_sha256": {Path(__file__).name: comparator_hash},
        "input_seed": 71, "baseline_ada_backend": args.baseline_ada_backend,
        "case_selection": "explicit",
        "requested_cases": requested_cases,
        "case_order": [dict(zip(("op", "nr", "nc", "nk", "pattern"), case)) for case in cases],
        "pairs": args.pairs, "target_ms": args.ms, "seed": args.seed,
        "bootstrap_draws": args.bootstrap,
        "method": {
            "unit": "one block contains baseline C, baseline Ada, candidate C, candidate Ada",
            "orders": [[TREATMENTS[i] for i in row] for row in ORDERS],
            "balance": "exact position and adjacent-pair balance per four blocks; incomplete final cycles retained",
            "repetitions": "identical for all four treatments, calibrated from all four CPU-time probes",
            "preparation_checksum": "outside both clocks according to unchanged matrix driver",
            "switch_scope": "whole driver sample, including preparation and checksum",
            "intervals": "individual per-case percentile bootstrap 95% CI of within-block ratio median; no multiplicity correction",
            "limitations": "within-session intervals do not capture independent-session drift; within_noise is inconclusive, not proven equivalence",
            "retention": "all samples retained; no context-switch or outlier filtering",
            "comparison_scope": "candidate C/baseline C is a drift or code-generation/layout control, not an assumed constant",
        },
        "results": [],
    }
    write_report(output, report)
    last_checkpoint = time.monotonic()

    def checkpoint(force=False):
        nonlocal last_checkpoint
        # Avoid repeated large JSON writes between treatments. Completed raw
        # samples remain in memory and are also flushed by the exception path.
        if force or time.monotonic() - last_checkpoint >= 15.0:
            write_report(output, report)
            last_checkpoint = time.monotonic()

    def sample(treatment, op, nr, nc, nk, reps, pattern):
        build, language = treatment.rsplit("_", 1)
        backend = (args.baseline_ada_backend if build == "baseline" else 1) if language == "ada" else 0
        command = [str(binaries[build]), str(backend), str(op), str(nr), str(nc), str(nk), str(reps), str(pattern), "71"]
        started_at = now()
        started = time.monotonic_ns()
        completed = subprocess.run(command, check=True, text=True, capture_output=True)
        elapsed = time.monotonic_ns() - started
        row = json.loads(completed.stdout)
        expected = {"backend": backend, "op": op, "nr": nr, "nc": nc, "nk": nk, "pattern": pattern, "reps": reps}
        if any(row.get(key) != value for key, value in expected.items()):
            raise RuntimeError(f"driver metadata mismatch for {treatment}: {row}")
        if not all(isinstance(row.get(key), int) and row[key] > 0 for key in ("cpu_ns", "wall_ns")):
            raise RuntimeError(f"invalid clocks for {treatment}: {row}")
        if not isinstance(row.get("switches"), int) or row["switches"] < 0 or not math.isfinite(row["sink"]):
            raise RuntimeError(f"invalid switch count or checksum for {treatment}: {row}")
        return {**row, "started_at_utc": started_at, "finished_at_utc": now(),
                "process_elapsed_ns": elapsed, "stderr": completed.stderr}

    try:
        for case_index, (op, nr, nc, nk, pattern) in enumerate(cases):
            offset = (args.seed + case_index) % len(ORDERS)
            probe_order = [TREATMENTS[i] for i in ORDERS[offset]]
            current = {"operation": OPERATIONS[op], "op": op, "nr": nr, "nc": nc, "nk": nk, "pattern": pattern,
                       "started_at_utc": now(), "probe_reps": 1000,
                       "probe_order": probe_order, "probes": {}, "blocks": []}
            report["current_case"] = current
            checkpoint(force=True)
            for treatment in probe_order:
                current["pending_treatment"] = treatment
                current["probes"][treatment] = sample(treatment, op, nr, nc, nk, current["probe_reps"], pattern)
                current.pop("pending_treatment")
            if len({row["sink"] for row in current["probes"].values()}) != 1:
                raise RuntimeError(f"probe checksum mismatch in op={op}, pattern={pattern}")
            requested_reps = math.ceil(current["probe_reps"] * args.ms * 1e6 /
                                      min(row["cpu_ns"] for row in current["probes"].values()))
            reps = max(1000, min(50000000, requested_reps))
            current.update(reps=reps, requested_reps=requested_reps,
                           calibration_capped=reps != requested_reps, order_offset=offset)
            for index in range(args.pairs):
                order = [TREATMENTS[i] for i in ORDERS[(offset + index) % len(ORDERS)]]
                block = {"index": index, "order": order, "samples": {}}
                current["blocks"].append(block)
                for treatment in order:
                    current["pending_treatment"] = treatment
                    block["samples"][treatment] = sample(treatment, op, nr, nc, nk, reps, pattern)
                    current.pop("pending_treatment")
                if len({row["sink"] for row in block["samples"].values()}) != 1:
                    raise RuntimeError(f"checksum mismatch in op={op}, pattern={pattern}, block={index}")
                checkpoint()
            metrics, treatments = summarize(current["blocks"], reps,
                                             args.seed + case_index * 100000,
                                             args.bootstrap)
            current.update(metrics=metrics, treatment_summary=treatments, finished_at_utc=now())
            report["results"].append(current)
            report.pop("current_case")
            checkpoint(force=True)
            pieces = []
            for key, short in (("candidate_ada_over_baseline_ada", "Ada cand/base"),
                               ("candidate_c_over_baseline_c", "C cand/base"),
                               ("baseline_ada_over_c", "base Ada/C"),
                               ("candidate_ada_over_c", "cand Ada/C")):
                values = metrics[key]["cpu_ns"]
                lo, hi = values["bootstrap_median_95"]
                pieces.append(f"{short}={values['median']:.4f} [{lo:.4f},{hi:.4f}]")
            print(f"{OPERATIONS[op]} {nr}x{nc}x{nk} pattern={pattern}: " + "; ".join(pieces), flush=True)
        final_hashes = {name: sha256(path) for name, path in binaries.items()}
        report["final_binary_sha256"] = final_hashes
        if final_hashes != report["binary_sha256"]:
            raise RuntimeError("one or both binaries changed during measurement")
        if sha256(Path(__file__).resolve()) != report["script_sha256"]:
            raise RuntimeError("measurement script changed during measurement")
        report["status_counts"] = {
            name: dict(Counter(row["metrics"][name]["cpu_ns"]["status"]
                               for row in report["results"])) for name in METRICS
        }
        report["complete"] = True
    except BaseException as exc:
        report["error"] = {"type": type(exc).__name__, "message": str(exc)}
        raise
    finally:
        report["finished_at_utc"] = now()
        write_report(output, report)
    print(json.dumps(report["status_counts"], sort_keys=True), flush=True)
    slower = report["status_counts"]["candidate_ada_over_c"].get("slower", 0)
    return 2 if slower else 0


if __name__ == "__main__":
    raise SystemExit(main())
