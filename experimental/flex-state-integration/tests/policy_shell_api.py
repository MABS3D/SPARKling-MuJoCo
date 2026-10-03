"""Reject positive and ordinary flexes at the separate shell endpoint API."""
import argparse
import hashlib
import json
from pathlib import Path
import resource
import subprocess


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--fixtures', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK, (128*1024**2, resource.getrlimit(resource.RLIMIT_STACK)[1]))
    prior = json.loads((a.fixtures / 'results.json').read_text())
    if not prior['passed'] or len(prior['records']) != 12:
        raise RuntimeError('requires the twelve accepted mixed positive endpoint fixtures')
    payload = ('4\n0 1 0 0 0 0 1 0 0 0\n1 1 0 0 0 0 1 0 0 0\n'
               '1 0 999999 999999 999999 999999 0 0 0 0\n2 0 0 0 0 0 0 0 0 0\n')
    expected = ''.join('case ' + status + '\nbodies\nweights\nbits\n' for status in
        ('UNSUPPORTED_FEATURE', 'UNSUPPORTED_FEATURE', 'UNSUPPORTED_FEATURE', 'INVALID_INPUT'))
    (a.out / 'input.txt').write_text(payload)
    (a.out / 'expected.txt').write_text(expected)
    rows = []
    for case in prior['records']:
        name = case['name']
        model = a.fixtures / (name + '.mjb')
        r = subprocess.run([str(a.binary), str(model)], input=payload, text=True,
                           capture_output=True, timeout=120)
        output = a.out / (name + '.output')
        output.write_text(r.stdout + r.stderr)
        rows.append(dict(model=name, model_path=str(model), model_sha256=digest(model),
            output_sha256=digest(output), exit=r.returncode,
            passed=r.returncode == 0 and r.stdout == expected and not r.stderr))
    result = dict(cases=4*len(rows), passed=4*sum(r['passed'] for r in rows), records=rows,
        binary_sha256=digest(a.binary), runner_sha256=digest(Path(__file__)),
        input_sha256=digest(a.out / 'input.txt'), previous_receipt_sha256=digest(a.fixtures / 'results.json'))
    (a.out / 'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(result['passed'], '/', result['cases'], flush=True)
    raise SystemExit(result['passed'] != result['cases'])


if __name__ == '__main__':
    main()
