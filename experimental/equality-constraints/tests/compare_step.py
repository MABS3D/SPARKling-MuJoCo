#!/usr/bin/env python3
"""Compare owned equality assembly, response, solve and integration against C.

Only MJB, qpos/qvel, applied forces and controls enter Ada. Native equality
rows, contacts, response coefficients and forces are never input to the port.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np
from compare import models, dense_jacobian

spec = importlib.util.spec_from_file_location('step_compare', Path(__file__).resolve().parents[2]/'constrained-step/tests/compare.py')
step_compare = importlib.util.module_from_spec(spec)
spec.loader.exec_module(step_compare)


def fixtures():
    for name, xml in models():
        for solver in ['PGS', 'CG', 'Newton']:
            yield solver+'-'+name, xml.replace('<option ', f'<option solver="{solver}" timestep=".001" iterations="200" tolerance="1e-12" ')
    base = '''<mujoco><option timestep=".001" iterations="200" tolerance="1e-12" jacobian="sparse"><flag warmstart="disable" island="disable"/></option><worldbody><geom type="plane" size="2 2 .1"/>
    <body name="a" pos="0 0 .098"><freejoint/><geom size=".1" mass="1"/><site name="s0" pos=".03 0 .05"/></body>
    <body name="b" pos=".35 0 .15"><joint type="slide" name="j" axis="0 0 1" frictionloss=".02" limited="true" range="0 .2" margin=".01"/><geom size=".1" mass="2"/><site name="s1" pos="0 0 -.1"/></body>
    </worldbody><equality><connect body1="a" body2="b" anchor=".1 0 .15"/><weld body1="b" active="false"/></equality></mujoco>'''
    yield 'mixed-friction-limit-contact', base
    yield 'disabled-equality', base.replace('island="disable"', 'island="disable" equality="disable"')
    yield 'disabled-constraint', base.replace('island="disable"', 'island="disable" constraint="disable"')
    yield 'inactive-equality', base.replace('<connect body1=', '<connect active="false" body1=')
    yield 'two-active-equalities', base.replace('active="false"', 'active="true"')
    static = '<body name="fixed" pos=".5 0 .4"><geom size=".03"/></body>'
    yield 'static-empty-chain', base.replace('</worldbody>', static+'</worldbody>').replace('<connect body1="a" body2="b" anchor=".1 0 .15"/>', '<connect body1="fixed" anchor=".5 0 .4"/>')


def reference(m, q, v, forces, loads, steps):
    d = mujoco.MjData(m)
    d.qpos[:] = q; d.qvel[:] = v; d.qfrc_applied[:] = forces
    d.xfrc_applied[:] = loads
    mujoco.mj_forward(m, d)
    result = {k: np.array(val).copy() for k, val in dict(
        counts=[d.ncon, d.nefc], free=d.qacc_smooth, acc=d.qacc,
        qfrc=d.qfrc_constraint, aref=d.efc_aref, reg=d.efc_R,
        force=d.efc_force, jac=dense_jacobian(m, d)).items()}
    for unused in range(steps):
        mujoco.mj_step(m, d)
    result['state'] = np.r_[d.qpos, d.qvel, d.time]
    return result


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--samples', type=int, default=3)
    p.add_argument('--steps', type=int, default=30)
    p.add_argument('--only')
    a = p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    a.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(20261002)
    records, failures = [], []
    for name, xml in fixtures():
        if a.only and a.only not in name:
            continue
        m = mujoco.MjModel.from_xml_string(xml)
        (a.out/(name+'.xml')).write_text(xml)
        path = a.out/(name+'.mjb'); mujoco.mj_saveModel(m, str(path))
        inputs, expected = [], []
        for sample in range(a.samples):
            q = m.qpos0.copy()
            if sample:
                mujoco.mj_integratePos(m, q, rng.uniform(-1, 1, m.nv), .008)
            v = rng.uniform(-.1, .1, m.nv)
            forces = rng.uniform(-.1, .1, m.nv)
            loads = rng.uniform(-.02, .02, (m.nbody, 6))
            inputs.extend([0, *q, *v, *forces, *loads.ravel()])
            expected.append(reference(m, q, v, forces, loads, a.steps))
        text = f'{a.samples} {a.steps}\n'+' '.join(format(x, '.17g') for x in inputs)+'\n'
        (a.out/(name+'.input')).write_text(text)
        run = subprocess.run([str(a.binary), str(path), 'loads'], input=text,
                             capture_output=True, text=True, timeout=120)
        (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
        try:
            if run.returncode:
                raise ValueError(run.stderr[-1500:])
            actual = step_compare.parse(run.stdout, m.nv)
            assert len(actual) == len(expected)
        except Exception as exc:
            fail = dict(model=name, error=str(exc), output=run.stdout[-1500:])
            failures.append(fail); print('FAIL', fail, flush=True)
            continue
        for sample, (got, want) in enumerate(zip(actual, expected, strict=True)):
            errors = {}
            for key, value in want.items():
                tol = 2e-10 if key in ('counts', 'free', 'jac', 'aref', 'reg') else 3e-6
                shape = got[key].shape == value.shape
                passed = shape and bool(np.allclose(got[key], value, atol=tol, rtol=1e-8 if tol>1e-8 else 2e-12))
                errors[key] = dict(passed=passed, max_abs=float(np.max(abs(got[key]-value))) if shape and value.size else 0.)
            record = dict(model=name, sample=sample, passed=all(v['passed'] for v in errors.values()), errors=errors)
            records.append(record)
            if not record['passed']:
                failures.append(record)
                print('FAIL', name, sample, {k:v for k,v in errors.items() if not v['passed']}, flush=True)
    result = dict(reference=mujoco.__version__, binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  samples=a.samples, steps=a.steps, cases=len(records), passed=sum(r['passed'] for r in records),
                  failures=failures, records=records)
    (a.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print('RESULT', result['passed'], result['cases'], 'failures', len(failures))
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
