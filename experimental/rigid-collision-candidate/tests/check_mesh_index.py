"""Require indexed and scanning feature recovery to emit identical precontacts."""
import argparse
import json
import subprocess
from pathlib import Path


def run(out):
    lines = (out/'advanced-input.txt').read_text().splitlines()
    original = '\n'.join(lines)+'\n'
    scanning = '\n'.join('7 '+line.partition(' ')[2] for line in lines)+'\n'
    reports = {}
    for profile in ['validation', 'release']:
        binary = str(out/'build'/profile/'bin/contact_probe')
        indexed = subprocess.run([binary], input=original, text=True, capture_output=True, timeout=240)
        fallback = subprocess.run([binary], input=scanning, text=True, capture_output=True, timeout=240)
        left, right = indexed.stdout.splitlines(), fallback.stdout.splitlines()
        failures = [dict(case=i, indexed=a, scanning=b) for i, (a, b) in
                    enumerate(zip(left, right)) if a != b or not a.startswith('SUCCESS ')]
        reports[profile] = dict(cases=len(lines), indexed_count=len(left), scanning_count=len(right),
                                indexed_exit=indexed.returncode, scanning_exit=fallback.returncode,
                                indexed_stderr=indexed.stderr, scanning_stderr=fallback.stderr, failures=failures)
        print(profile, 'index/scanning', len(lines), 'differences', len(failures), flush=True)
    (out/'mesh-index-numerics.json').write_text(json.dumps(reports, indent=2)+'\n')
    return all(not r['indexed_exit'] and not r['scanning_exit'] and not r['failures']
               and r['indexed_count'] == r['scanning_count'] == r['cases'] for r in reports.values())


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    raise SystemExit(0 if run(args.out.resolve()) else 1)
