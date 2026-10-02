#!/usr/bin/env python3
"""Check observable compatibility with a saved candidate executable.

Optional timings are process wall times for repeated assembled solver problems,
including startup and I/O. They diagnose Ada regressions; they are neither a
MuJoCo C timing comparison nor a full movement-step performance measurement.
"""
import argparse
import hashlib
import json
from pathlib import Path
import statistics
import sys
import time
sys.dont_write_bytecode = True
import numpy as np
from differential import fixtures, native_problem, analytic, run


def identical(left, right):
    if left.keys() != right.keys():
        return False
    return all(a.tobytes() == right[k].tobytes() if isinstance(a, np.ndarray)
               else a.hex() == right[k].hex() if isinstance(a, float)
               else a == right[k] for k, a in left.items())


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--before', type=Path, required=True)
    ap.add_argument('--after', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--timing-repeats', type=int, default=0)
    ap.add_argument('--rounds', type=int, default=7)
    args = ap.parse_args()
    native = [native_problem(name, xml, method)[0]
              for name, xml in fixtures() for method in range(3)]
    native += [native_problem(name, xml, 0, iterations=7, tolerance=0)[0]
               for name, xml in fixtures() if 'box_' in name or 'mixed' in name]
    native += [native_problem(name, xml, method, seed=seed)[0]
               for name, xml in fixtures() if 'box_' in name or 'mixed_' in name
               for method in range(3) for seed in range(8)]
    problems = native + [p for p, _ in analytic()]
    left, right = run(args.before, problems), run(args.after, problems)
    failures = [dict(index=i, name=p['name'], method=p['method'])
                for i, (p, a, b) in enumerate(zip(problems, left, right))
                if not identical(a, b)]
    report = dict(cases=len(problems), identical=len(problems)-len(failures),
                  failures=failures, passed=not failures,
                  before_sha256=hashlib.sha256(args.before.read_bytes()).hexdigest(),
                  after_sha256=hashlib.sha256(args.after.read_bytes()).hexdigest())
    if args.timing_repeats:
        timings = {}
        for method in range(3):
            batch = [dict(p, repeat=args.timing_repeats)
                     for p in native if p['method'] == method]
            samples = {'before': [], 'after': []}
            for round_number in range(args.rounds):
                order = ['before', 'after'] if round_number % 2 == 0 else ['after', 'before']
                for label in order:
                    start = time.perf_counter()
                    run(getattr(args, label), batch)
                    samples[label].append(time.perf_counter()-start)
            ratios = [b/a for a, b in zip(samples['before'], samples['after'])]
            timings[str(method)] = dict(problems=len(batch), repeats=args.timing_repeats,
                samples_seconds=samples, paired_ratios=ratios,
                median_ratio=statistics.median(ratios), min_ratio=min(ratios), max_ratio=max(ratios))
        report['timing_scope'] = 'Process wall time, startup and I/O included; diagnostic only'
        report['timings'] = timings
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k != 'timings'}, indent=2))
    if report.get('timings'):
        print({k:v['median_ratio'] for k,v in report['timings'].items()})
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
