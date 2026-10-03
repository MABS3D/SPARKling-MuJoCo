#!/usr/bin/env python3
"""Check bounded malformed-cycle rejection and complete failure preservation.

These cases deliberately do not call C, whose malformed-cycle path is fatal.
The independent visited-set model also tests valid cycles and awake counters.
"""
import argparse
import hashlib
import json
import random
from pathlib import Path
from differential import case, run


def expected(values, start, value):
    if start not in range(len(values)):
        return -1, 1, 0, values
    if values[start] < 0:
        after = values.copy()
        after[start] = min(after[start], value)
        return -1, 0, 0, after
    visited = set()
    current = start
    while current in range(len(values)) and current not in visited:
        visited.add(current)
        current = values[current]
    if current != start:
        return -1, 1, 0, values
    after = values.copy()
    for node in visited:
        after[node] = value
    return min(visited), 0, len(visited), after


def fixtures():
    yield [], 0
    for values in [[0], [-11], [1], [1, 1, 2], [1, 2, 0], [2, -1, 1], [3, 1, 2]]:
        for start in range(-1, len(values)+1):
            yield values, start
    n = 1024
    yield list(range(1, n))+[0], n-1
    yield list(range(1, n))+[n-1], 0
    rng = random.Random(20261003)
    for _ in range(500):
        n = rng.choice([1, 2, 3, 8, 32])
        yield [rng.randint(-11, n+2) for _ in range(n)], rng.randint(-1, n)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    results = []
    for i, (values, start) in enumerate(fixtures()):
        data = case(len(values), values=values, operations=[[0, start], [1, start, -5]])
        rows = run(args.binary, data)
        cycle, status, woke, after = expected(values, start, -5)
        before, actual = rows
        wanted = before.copy()
        wanted[:2] = [status, woke]
        wanted[2:2+len(values)] = after
        passed = before[0] == cycle and actual == wanted
        results.append(dict(case=i, passed=passed, length=len(values), start=start))
        if not passed:
            (args.out/f'{i}.input').write_text(data)
            (args.out/f'{i}.json').write_text(json.dumps(dict(actual=rows, cycle=cycle, wanted=wanted)))
    result = dict(cases=len(results), passed=sum(x['passed'] for x in results),
        scope='Native bounded rejection policy; no C fatal-path comparison', records=results,
        hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest()
                for p in [args.binary, Path(__file__), Path(__file__).with_name('differential.py')]})
    (args.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print('RESULT', result['passed'], result['cases'])
    raise SystemExit(result['passed'] != result['cases'])

if __name__ == '__main__':
    main()
