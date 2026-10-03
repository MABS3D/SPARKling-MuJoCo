"""Full elliptic-contact steps against C, with no imported C intermediates.

Uses the existing step oracle and tolerances unchanged. Nonconstant impedance,
direct solref, impratio and torsion/rolling exercise coupled row preparation.
"""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

import mujoco
import numpy as np

from compare import fixtures, model_xml, oracle, parse


def elliptic_fixtures():
    for name, xml in fixtures():
        yield name, xml.replace('cone="pyramidal"', 'cone="elliptic"')
    body = '<body pos="0 0 .095"><joint type="free"/><geom type="sphere" size=".1" mass="1"/></body>'
    for solver in ['PGS', 'CG', 'Newton']:
        for dim in [3, 4, 6]:
            for ratio in [.1, 1, 10, 100]:
                for direct in [False, True]:
                    xml = model_xml(body, dim=dim, solver=solver)
                    xml = xml.replace('cone="pyramidal"', f'cone="elliptic" impratio="{ratio}"')
                    ref = '-250 -8' if direct else '.03 1.2'
                    xml = xml.replace('solref="0.025 1.1"',
                                      f'solref="{ref}" solimp=".3 .9 .05 .4 2"')
                    yield f'variable_imp_{solver}_{dim}_{ratio}_{direct}', xml
    for dim in [4, 6]:
        xml = model_xml('<body pos="0 0 .095"><joint type="free"/><geom type="box" size=".1 .1 .1" mass="1"/></body>', dim=dim)
        yield f'box_multiple_{dim}', xml.replace('cone="pyramidal"', 'cone="elliptic"')


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--samples', type=int, default=8)
    p.add_argument('--steps', type=int, default=100)
    p.add_argument('--only')
    p.add_argument('--solver-tolerance', type=float,
                   help='Use the same requested solver tolerance in both engines; comparison tolerances stay fixed.')
    args = p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    args.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(241002)
    records, failures = [], []
    for name, xml in elliptic_fixtures():
        if args.only and args.only not in name:
            continue
        if args.solver_tolerance is not None:
            xml = xml.replace('tolerance="1e-12"', f'tolerance="{args.solver_tolerance:.17g}"')
        m = mujoco.MjModel.from_xml_string(xml)
        path = args.out / (name + '.mjb')
        mujoco.mj_saveModel(m, str(path))
        (args.out / (name + '.xml')).write_text(xml)
        samples, refs = [], []
        for sample in range(args.samples):
            q = m.qpos0.copy()
            if sample:
                mujoco.mj_integratePos(m, q, rng.uniform(-1, 1, m.nv), .008)
            if name == 'ball_limit':
                q[:] = [np.cos(.11), 0, np.sin(.11), 0]
            if name == 'hinge_contact':
                q[:] = .11
            v = rng.uniform(-.1, .1, m.nv)
            applied = rng.uniform(-.1, .1, m.nv)
            ctrl = rng.uniform(-.2, .2, m.nu)
            loads = rng.uniform(-.1, .1, (m.nbody, 6))
            samples.extend([0., *q, *v, *applied, *ctrl, *loads.ravel()])
            refs.append(oracle(m, q, v, applied, args.steps, ctrl, loads))
        data = f'{args.samples} {args.steps}\n' + ' '.join(format(x, '.17g') for x in samples) + '\n'
        (args.out / (name + '.input')).write_text(data)
        run = subprocess.run([str(args.binary), str(path), 'loads'], input=data,
                             text=True, capture_output=True, timeout=180)
        (args.out / (name + '.output')).write_text(run.stdout + run.stderr)
        try:
            if run.returncode:
                raise RuntimeError(f'exit {run.returncode}: {run.stdout[-1200:]}')
            actual = parse(run.stdout, m.nv)
            if len(actual) != len(refs):
                raise ValueError('sample count differs')
        except Exception as error:
            failures.append(dict(model=name, error=str(error)))
            print('FAIL', name, str(error), flush=True)
            continue
        for sample, (x, y) in enumerate(zip(actual, refs)):
            errors = {}
            for key in y:
                if x[key].shape != y[key].shape:
                    errors[key] = dict(shape_ada=x[key].shape, shape_c=y[key].shape)
                    continue
                delta = float(np.max(np.abs(x[key] - y[key]))) if y[key].size else 0.
                tolerance = 2e-10 if key in ['counts', 'free', 'jac', 'aref', 'reg'] else 3e-6
                passed = bool(np.allclose(x[key], y[key], atol=tolerance,
                                         rtol=1e-8 if tolerance > 1e-8 else 2e-12))
                errors[key] = dict(max_abs=delta, passed=passed)
            passed = all(error.get('passed', False) for error in errors.values())
            record = dict(model=name, sample=sample, passed=passed, errors=errors)
            records.append(record)
            if not passed:
                failures.append(record)
                print('FAIL', name, sample, {k: v for k, v in errors.items() if not v.get('passed', False)}, flush=True)
        print(name, 'checked', flush=True)
    report = dict(reference=mujoco.__version__,
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  steps=args.steps, cases=len(records),
                  solver_tolerance=args.solver_tolerance,
                  passed=sum(record['passed'] for record in records),
                  failures=failures, records=records)
    (args.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    print('RESULT', report['passed'], report['cases'], 'failures', len(failures), flush=True)
    if failures:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
