"""Keep negative shell order outside the unchanged 27-body positive API."""
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
    if not prior['passed'] or len(prior['records']) != 48:
        raise RuntimeError('requires the 48 accepted owned shell endpoint fixtures')
    expected = 'case UNSUPPORTED_FEATURE\nbodies\nweights\n'*2
    (a.out / 'expected.txt').write_text(expected)
    records = []
    for r in prior['records']:
        model = Path(r['model_path'])
        requests = json.loads((a.fixtures / (r['model']+'.requests.json')).read_text())
        f = requests[0]['flex']
        payload = (f'2\n{f} 0 999999 999999 999999 999999 0 0 0 0\n'
                   f'{f} 1 0 0 0 0 1 0 0 0\n')
        infile = a.out / (r['model']+'.input')
        infile.write_text(payload)
        run = subprocess.run([str(a.binary),str(model)],input=payload,text=True,
                             capture_output=True,timeout=120)
        out = a.out / (r['model']+'.output')
        out.write_text(run.stdout+run.stderr)
        records.append(dict(model=r['model'],model_path=str(model),model_sha256=digest(model),
            input_sha256=digest(infile),output_sha256=digest(out),exit=run.returncode,
            passed=run.returncode == 0 and run.stdout == expected and not run.stderr))
    result = dict(cases=2*len(records),passed=2*sum(r['passed'] for r in records),records=records,
        binary_sha256=digest(a.binary),runner_sha256=digest(Path(__file__)),
        receipt_sha256=digest(a.fixtures / 'results.json'))
    (a.out / 'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(result['passed'],'/',result['cases'],flush=True)
    raise SystemExit(result['passed'] != result['cases'])


if __name__ == '__main__':
    main()
