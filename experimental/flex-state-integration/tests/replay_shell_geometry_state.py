"""Replay accepted C geometry records against a changed owned-state binary."""
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
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(128*1024**2,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    roots = [Path('/var/tmp/sparkling-recovery-shell-state1-20261003/validation') / n
             for n in ('positive','ordinary')]
    roots += sorted(Path('/var/tmp/sparkling-recovery-shell-state2-20261003/validation').iterdir())
    rows = []
    for base in roots:
        if not base.is_dir() or not (base / 'results.json').is_file():
            continue
        prior = json.loads((base / 'results.json').read_text())
        if prior['passed'] != prior['cases'] or prior.get('failures'):
            raise RuntimeError('reference receipt failed: ' + str(base))
        for infile in sorted(base.glob('*.input')):
            if infile.name.endswith('.pending.input'):
                continue
            name = infile.stem
            model,core = base / (name + '.mjb'),base / (name + '-core.mjb')
            expected = base / (name + '.output')
            r = subprocess.run([str(a.binary),str(model),str(core)],input=infile.read_bytes(),
                               capture_output=True,timeout=180)
            output = a.out / (name + '.output')
            output.write_bytes(r.stdout+r.stderr)
            rows.append(dict(model=name,exit=r.returncode,passed=r.returncode == 0 and
                output.read_bytes() == expected.read_bytes(),source=str(base),
                previous_receipt_sha256=digest(base / 'results.json'),model_sha256=digest(model),
                core_sha256=digest(core),input_sha256=digest(infile),
                expected_sha256=digest(expected),actual_sha256=digest(output)))
            print(name,'PASS' if rows[-1]['passed'] else 'FAIL',flush=True)
    result = dict(cases=len(rows),passed=sum(r['passed'] for r in rows),records=rows,
        binary_sha256=digest(a.binary),runner_sha256=digest(Path(__file__)),
        scope='Byte-identical replay of 936 previously accepted C samples across 141 models; no timing or dynamics claim.')
    (a.out / 'results.json').write_text(json.dumps(result,indent=2)+'\n')
    if len(rows) != 141:
        raise RuntimeError('missing accepted model')
    raise SystemExit(result['passed'] != result['cases'])


if __name__ == '__main__':
    main()
