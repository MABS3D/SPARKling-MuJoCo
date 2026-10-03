"""Raw mocap inputs, owned reset and complete trajectories against MuJoCo C."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path
import mujoco
import numpy as np


def fixtures():
    dynamic = '<body pos="0 0 .4"><freejoint/><geom type="sphere" size=".08" mass="1"/></body>'
    hinge = '<body pos=".3 0 .7"><joint axis="0 1 0" damping=".1"/><geom type="capsule" size=".05 .15" mass="1"/></body>'
    names = [
        ('only_mocap', '<body mocap="true" pos=".1 .2 .3"><geom size=".04"/></body>'),
        ('free_sibling', dynamic + '<body mocap="true" pos="1 0 .2" quat=".7 .1 .2 .3"><geom size=".06"/></body>'),
        ('scalar_child', '<body mocap="true" pos=".2 .1 .5" quat=".7 .1 .2 .3"><geom size=".02"/>' + hinge + '</body>'),
        ('ball_child', '<body mocap="true" pos=".2 .1 .5"><geom size=".02"/><body pos=".3 0 .2"><joint type="ball" damping=".1"/><geom type="box" size=".04 .05 .06" mass="1"/></body></body>'),
        ('multiple', hinge + '<body mocap="true" pos="1 0 .2"><geom size=".06"/></body><body mocap="true" pos="-1 .3 .2" quat=".7 .1 .2 .3"><geom type="box" size=".03 .04 .05"/></body>'),
        ('moving_plane', dynamic + '<body mocap="true" pos="0 0 .32"><geom type="plane" size="5 5 .1"/></body>'),
        ('spatial_tendon', '<body pos="0 0 .4"><freejoint/><geom size=".08" mass="1"/><site name="b" pos=".02 .03 .04"/></body><body mocap="true" pos=".5 .1 .6" quat=".13 .27 .31 .83"><site name="a" pos=".1 .05 .03"/></body>'),
        ('fluid_child', '<body mocap="true" pos=".2 .1 .5" quat=".13 .27 .31 .83"><geom size=".02"/>' + hinge + '</body>'),
        ('no_mocap', hinge),
    ]
    for name, bodies in names:
        fluid = ' density=".2" viscosity=".01" wind=".3 .2 .1"' if name == 'fluid_child' else ''
        tendon = '<tendon><spatial stiffness="2" damping=".1" springlength=".2"><site site="a"/><site site="b"/></spatial></tendon>' if name == 'spatial_tendon' else ''
        yield name, '<mujoco><option timestep=".001" tolerance="1e-12"' + fluid + '><flag warmstart="disable" island="disable"/></option><worldbody>' + bodies + '</worldbody>' + tendon + '</mujoco>'


def oracle(m, q, v, positions, quaternions, steps, constrained):
    d = mujoco.MjData(m)
    d.qpos[:] = q
    d.qvel[:] = v
    d.mocap_pos[:] = positions
    d.mocap_quat[:] = quaternions
    mujoco.mj_forward(m, d)
    expected = dict(mocap=np.r_[positions.ravel(), quaternions.ravel()],
                    poses=np.c_[d.xpos, d.xquat].ravel(), acc=d.qacc.copy(),
                    counts=np.array([d.ncon, d.nefc] if constrained else [0, 0]))
    for _ in range(steps):
        mujoco.mj_step(m, d)
    expected['state'] = np.r_[d.qpos, d.qvel, d.time, d.act, d.mocap_pos.ravel(), d.mocap_quat.ravel()]
    return expected


def poses(m, sample, rng):
    positions = m.body_pos[m.body_mocapid >= 0].copy()
    quaternions = m.body_quat[m.body_mocapid >= 0].copy()
    if sample:
        positions += rng.uniform(-.02, .02, positions.shape)
    cases = [None, [0, 0, 0, 0], [2, -.4, .6, -.8], [-1, 0, 0, 0],
             [9e-16] * 4, [4e-16] * 4, [1e6, -2e6, 3e6, 4e6],
             [1 + 2e-15, 0, 0, 0]]
    if sample and m.nmocap:
        quaternions[0] = cases[sample % len(cases)] or quaternions[0]
    return positions, quaternions


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--samples', type=int, default=16)
    p.add_argument('--steps', type=int, default=100)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    rng = np.random.default_rng(20261002)
    records, failures = [], []
    for name, xml in fixtures():
        for mode in ['smooth', 'constrained']:
            if name == 'only_mocap' and mode == 'constrained':
                continue  # Existing constrained scope requires at least one DOF.
            m = mujoco.MjModel.from_xml_string(xml)
            if mode == 'smooth':
                m.opt.disableflags |= int(mujoco.mjtDisableBit.mjDSBL_CONSTRAINT)
            file = a.out / (name + '-' + mode + '.mjb')
            mujoco.mj_saveModel(m, str(file))
            (a.out / (name + '-' + mode + '.xml')).write_text(xml)
            data, refs = [], []
            for s in range(a.samples):
                q = m.qpos0.copy()
                if s and m.nv:
                    mujoco.mj_integratePos(m, q, rng.uniform(-1, 1, m.nv), .01)
                v = rng.uniform(-.02, .02, m.nv)
                pos, quat = poses(m, s, rng)
                data.extend(q)
                data.extend(v)
                for i in range(m.nmocap):
                    data.extend(pos[i]); data.extend(quat[i])
                refs.append(oracle(m, q, v, pos, quat, a.steps, mode == 'constrained'))
            text = f'{a.samples} {a.steps}\n' + ' '.join(format(x, '.17g') for x in data) + '\n'
            r = subprocess.run([str(a.binary), str(file), mode], input=text, text=True, capture_output=True, timeout=180)
            (a.out / (name + '-' + mode + '.output')).write_text(r.stdout + r.stderr)
            if r.returncode:
                failures.append(dict(model=name, mode=mode, error=r.stdout[-2500:] + r.stderr[-500:]))
                print('FAIL', name, mode, r.stdout[-1000:], flush=True)
                continue
            actual = []; current = None; reset = None
            for line in r.stdout.splitlines():
                key, *values = line.split()
                if key == 'mocap':
                    current = {}; actual.append(current)
                if key in refs[0]:
                    current[key] = np.array([float(v) for v in values])
                elif key == 'reset':
                    reset = np.array([float(v) for v in values])
            assert len(actual) == len(refs)
            for s, (x, y) in enumerate(zip(actual, refs)):
                errors = {}; passed = True
                for key in y:
                    ok = x[key].shape == y[key].shape and np.allclose(x[key], y[key], atol=2e-10, rtol=2e-10)
                    errors[key] = dict(passed=bool(ok), max_abs=float(np.max(np.abs(x[key] - y[key]))) if y[key].size and x[key].shape == y[key].shape else 0.)
                    passed &= ok
                record = dict(model=name, mode=mode, sample=s, passed=bool(passed), errors=errors)
                records.append(record)
                if not passed:
                    failures.append(record)
            initial = mujoco.MjData(m)
            expected_reset = np.r_[initial.mocap_pos.ravel(), initial.mocap_quat.ravel()]
            if not np.array_equal(reset, expected_reset):
                failures.append(dict(model=name, mode=mode, error='reset differs from raw model pose',
                                     actual=None if reset is None else reset.tolist(), expected=expected_reset.tolist()))
            if 'edges PASS' not in r.stdout:
                failures.append(dict(model=name, mode=mode, error='lifecycle/atomicity checks failed'))
            print(name, mode, 'checked', flush=True)
    report = dict(reference=mujoco.__version__, test_source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  cases=len(records), passed=sum(r['passed'] for r in records), steps=a.steps, failures=failures, records=records)
    (a.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    print('RESULT', report['passed'], report['cases'], 'failures', len(failures))
    if failures:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
