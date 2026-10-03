"""Replay preserved native assembled problems, retaining numerical diagnostics.

This does not replace the exporting trajectory test or change its thresholds.
The complete input, binary and runner hashes identify each diagnostic replay.
"""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np

from differential import run


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--input', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    cases = json.loads(args.input.read_text())
    results = run(args.binary, [case['problem'] for case in cases])
    records = []
    for case, result in zip(cases, results):
        records.append(dict(model=case['model'], sample=case['sample'],
            first_failing_step=case.get('first_failing_step'),
            status=result['status'], iterations=result['iterations'],
            native_iterations=case['native_iterations'],
            acceleration_error=float(np.max(np.abs(
                result['a'] - case['expected_acceleration']), initial=0)),
            force_error=float(np.max(np.abs(
                result['f'] - case['expected_force']), initial=0)),
            acceleration=result['a'].tolist(), force=result['f'].tolist()))
    report = dict(diagnostic_only=True, cases=len(cases),
        input=str(args.input.resolve()),
        input_sha256=hashlib.sha256(args.input.read_bytes()).hexdigest(),
        binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
        runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        records=records)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(report, indent=2) + '\n')
    for record in records:
        print({k: v for k, v in record.items()
               if k not in ('acceleration', 'force')})


if __name__ == '__main__':
    main()
