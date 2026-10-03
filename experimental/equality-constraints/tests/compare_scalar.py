#!/usr/bin/env python3
"""Joint/tendon equality geometry against MuJoCo's native row assembly.

Only scalar positions, model coefficients and each object's uncoupled Jacobian
enter the kernel. Native equality rows are comparison outputs, never inputs.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np
from compare import dense_jacobian


def models():
    bodies = '''<site name="w0" pos="-.3 .2 .5"/><site name="w1" pos=".5 -.2 .5"/>
    <body name="a" pos="0 0 .5"><joint name="j0" type="hinge" axis="0 0 1" ref=".2"/>
      <geom size=".05" mass="1"/><site name="s0" pos=".1 .2 .1"/></body>
    <body name="b" pos=".4 .1 .5"><joint name="j1" type="slide" axis="1 0 0" ref="-.1"/>
      <geom size=".05" mass="2"/><site name="s1" pos=".1 .1 .2"/></body>'''
    for kind in ['joint', 'fixed', 'spatial']:
        tendons = ''
        if kind == 'fixed':
            tendons = '''<tendon><fixed name="t0"><joint joint="j0" coef=".7"/>
              <joint joint="j1" coef="-.2"/></fixed><fixed name="t1">
              <joint joint="j0" coef="-.3"/><joint joint="j1" coef="1.2"/></fixed></tendon>'''
        elif kind == 'spatial':
            tendons = '''<tendon><spatial name="t0"><site site="w0"/><site site="s0"/>
              <site site="s1"/></spatial><spatial name="t1"><site site="w1"/>
              <site site="s1"/><site site="s0"/></spatial></tendon>'''
        tag, obj = ('joint', 'j') if kind == 'joint' else ('tendon', 't')
        for second in [False, True]:
            eq = f'<{tag} {tag}1="{obj}0"'
            if second:
                eq += f' {tag}2="{obj}1"'
            eq += ' polycoef=".1 .8 .2 -.1 .05"/>'
            for mode in ['dense', 'sparse']:
                xml = f'''<mujoco><compiler angle="radian"/>
                <option jacobian="{mode}"><flag contact="disable" island="disable"/></option>
                <worldbody>{bodies}</worldbody>{tendons}<equality>{eq}</equality></mujoco>'''
                yield f'{kind}-{int(second)}-{mode}', kind, second, xml


def tendon_jacobian(m, d, tendon):
    row = np.zeros(m.nv)
    first, width = int(m.ten_J_rowadr[tendon]), int(m.ten_J_rownnz[tendon])
    for k in range(first, first+width):
        row[m.ten_J_colind[k]] += d.ten_J[k]
    return row


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    a.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(20261003)
    coefficients = [[0, 1, 0, 0, 0], [.3, -.8, .4, -.2, .1],
                    [-.2, 0, 0, 0, 0], [0, 0, 0, 0, 1],
                    [1e-20, -1e-20, 1e-20, -1e-20, 1e-20],
                    [1e10, -1e10, 1e10, -1e10, 1e10]]
    payload, expected, records = [], [], []
    for name, kind, second, xml in models():
        m = mujoco.MjModel.from_xml_string(xml)
        (a.out/(name+'.xml')).write_text(xml)
        for ci, coef in enumerate(coefficients):
            m.eq_data[0, :5] = coef
            for sample in range(6):
                d = mujoco.MjData(m)
                scale = [0, 1e-10, .1, 1, 10, 1e3][sample]
                d.qpos[:] = m.qpos0 + rng.uniform(-1, 1, m.nq)*scale
                mujoco.mj_fwdPosition(m, d)
                assert d.nefc == 1, (name, ci, sample, d.nefc)
                if kind == 'joint':
                    pos = d.qpos[m.jnt_qposadr[:2]]
                    ref = m.qpos0[m.jnt_qposadr[:2]]
                    j0, j1 = np.eye(m.nv)
                else:
                    pos, ref = d.ten_length[:2], m.tendon_length0[:2]
                    j0, j1 = (tendon_jacobian(m, d, i) for i in range(2))
                inputs = [m.nv, int(second), pos[0], ref[0], pos[1], ref[1], *coef]
                inputs.extend(np.stack([j0, j1], axis=1).ravel())
                payload.append(inputs)
                expected.append(np.r_[d.efc_pos, dense_jacobian(m, d).ravel()])
                records.append(dict(model=name, coefficient_case=ci, sample=sample))
    text = str(len(payload))+'\n'+'\n'.join(' '.join(format(float(x), '.17g') for x in row) for row in payload)+'\n'
    (a.out/'inputs.txt').write_text(text)
    run = subprocess.run([str(a.binary)], input=text, text=True, capture_output=True, timeout=90)
    (a.out/'output.txt').write_text(run.stdout)
    (a.out/'stderr.txt').write_text(run.stderr)
    if run.returncode:
        raise RuntimeError(run.stderr[-2000:])
    lines = run.stdout.splitlines()
    assert len(lines) == len(records)
    for record, line, want in zip(records, lines, expected, strict=True):
        values = np.fromstring(line, sep=' ')
        got = np.r_[values[:1], values[2:]]  # derivative is not an exported efc field
        record['passed'] = got.shape == want.shape and bool(np.allclose(got, want, atol=2e-12, rtol=2e-12))
        record['max_abs_error'] = float(np.max(np.abs(got-want))) if got.shape == want.shape else None
        record['exact'] = bool(np.array_equal(got, want))
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))
    result = dict(reference=mujoco.__version__,
                  binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
                  script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  cases=len(records), passed=sum(r['passed'] for r in records),
                  exact=sum(r['exact'] for r in records),
                  failures=[r for r in records if not r['passed']], records=records)
    (a.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k != 'records'}))
    raise SystemExit(bool(result['failures']))


if __name__ == '__main__':
    main()
