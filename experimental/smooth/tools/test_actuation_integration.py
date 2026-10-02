#!/usr/bin/env python3
"""Compare owned activation, muscles and manifold/tendon Euler steps with C."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco as mj
import numpy as np
from compare_numerics import parse_output


def fixtures(fluid="none", fixed=False):
    for joint in ("slide", "hinge", "ball", "free"):
        jxml = '<freejoint name="j"/>' if joint == "free" else f'<joint name="j" type="{joint}" damping=".03"/>'
        body = f'''<body pos="1 .15 .2">{jxml}
          <inertial pos=".1 -.05 .02" mass="1.3" diaginertia=".2 .3 .4"/>
          <site name="end" pos=".2 .1 0"/>
          <geom type="ellipsoid" size=".15 .25 .35" fluidshape="{'ellipsoid' if fluid == 'ellipsoid' else 'none'}"/></body>'''
        if fixed:
            body = body.replace('</body>', '''<body pos=".1 .2 .3">
              <joint name="fixed_slide" type="slide" axis="1 0 0" damping=".03"/>
              <joint name="fixed_hinge" type="hinge" axis="0 1 0" damping=".02"/>
              <inertial pos=".05 0 0" mass=".7" diaginertia=".08 .1 .12"/>
              </body></body>''')
        for kind in ("integrator", "filter", "filterexact", "muscle"):
            for early in (False, True):
                for flag in ("", 'actuation="disable"', 'clampctrl="disable"'):
                    options = f'''actearly="{str(early).lower()}" actlimited="true"
                      actrange="-.2 .8" ctrllimited="true" ctrlrange="0 1"
                      forcelimited="true" forcerange="-1 1"'''
                    if kind == "muscle":
                        curve = '.75 1.05 .3 200 .5 1.6 1.5 1.3 1.2'
                        actuator = f'''<general joint="j" dyntype="muscle" dynprm=".01 .04 .1"
                          gaintype="muscle" biastype="muscle" gainprm="{curve}" biasprm="{curve}"
                          lengthrange="-1 2" {options}/>'''
                    else:
                        actuator = f'<general joint="j" dyntype="{kind}" dynprm=".03" gainprm=".4" biastype="affine" biasprm=".01 -.1 -.02" {options}/>'
                    # A stateless motor on each side exercises nontrivial actadr.
                    actuator = '<motor joint="j" gear=".1"/>' + actuator + '<motor joint="j" gear=".2"/>'
                    for tendon in (False, True):
                        txml = '''<tendon><spatial stiffness=".2" damping=".01" springlength="1">
                          <site site="start"/><geom geom="wrap"/><site site="end"/>
                          </spatial></tendon>''' if tendon else ""
                        if fixed:
                            f1 = '<fixed stiffness=".2 .01 .001" damping=".04" springlength="-.1 .2" armature=".2"><joint joint="fixed_slide" coef=".7"/><joint joint="fixed_hinge" coef="-.3"/><joint joint="fixed_slide" coef="-.1"/></fixed>'
                            f2 = '<fixed stiffness=".3" damping=".05 .02 .001" armature=".1"><joint joint="fixed_hinge" coef="1.2"/><joint joint="fixed_slide" coef="-.7"/></fixed>'
                            txml = txml.replace('<tendon>', '<tendon>' + f1).replace('</tendon>', f2 + '</tendon>') if tendon else '<tendon>' + f1 + f2 + '</tendon>'
                        fluid_options = 'density="1.2" viscosity=".00002" wind=".3 -.1 .2"' if fluid != 'none' else ''
                        xml = f'''<mujoco><compiler angle="radian"/><option timestep=".001" gravity="0 0 -1" {fluid_options}>
                          <flag constraint="disable" {flag}/></option><worldbody>
                          <site name="start" pos="-1 .15 .2"/>
                          <geom name="wrap" type="sphere" size=".3"/>{body}
                          </worldbody>{txml}<actuator>{actuator}</actuator></mujoco>'''
                        yield f'{joint}-{kind}-{early}-{flag[:5] or "normal"}-{tendon}', xml


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--probe', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--fixed', action='store_true', help='Mix fixed armature tendons with spatial paths')
    ap.add_argument('--fluid', default='none', choices=['none', 'box', 'ellipsoid'])
    ap.add_argument('--policy', default='Compatible', choices=['Compatible', 'Strict'])
    args = ap.parse_args()
    assert mj.__version__ == "3.14.0", mj.__version__
    args.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(20261002)
    results = []
    comparisons = 0
    for name, xml in fixtures(args.fluid, args.fixed):
        m = mj.MjModel.from_xml_string(xml)
        path = args.out / (name + '.mjb')
        mj.mj_saveModel(m, str(path))
        (args.out / (name + '.xml')).write_text(xml)
        requests, expected = [], []
        for sample in range(6):
            d = mj.MjData(m)
            mj.mj_integratePos(m, d.qpos, rng.uniform(-.15, .15, m.nv), 1)
            d.qvel[:] = rng.uniform(-.2, .2, m.nv)
            d.ctrl[:] = rng.uniform(-.3, 1.3, m.nu)
            d.qfrc_applied[:] = rng.uniform(-.05, .05, m.nv)
            d.act[:] = rng.uniform(-.25, .9, m.na)
            d.xfrc_applied[1:] = rng.uniform(-.05, .05, (m.nbody - 1, 6))
            d.time = .125
            steps = 100 if sample % 2 else 1
            requests.append(' '.join(map(str, [*d.qpos, *d.qvel, *d.ctrl,
                *d.qfrc_applied, *d.act, *d.xfrc_applied.ravel(), d.time, steps])))
            mj.mj_forward(m, d)
            want = {k: np.array(v, copy=True) for k, v in dict(qacc=d.qacc,
                force=d.actuator_force, actuation=d.qfrc_actuator,
                length=d.actuator_length, velocity=d.actuator_velocity,
                act_dot=d.act_dot, passive=d.qfrc_passive).items()}
            mass = np.zeros((m.nv, m.nv))
            mj.mj_fullM(m, d, mass)
            want["mass"] = mass.ravel()
            for _ in range(steps):
                mj.mj_step(m, d)
            assert not np.any(d.warning.number), (name, d.warning)
            want.update(qpos=d.qpos.copy(), qvel=d.qvel.copy(), act=d.act.copy(), time=np.array([d.time]))
            expected.append(want)
        inputs = str(len(requests)) + '\n' + '\n'.join(requests) + '\n'
        (args.out / (name + '.input')).write_text(inputs)
        run = subprocess.run([str(args.probe), str(path), args.policy, 'external'],
                             input=inputs, text=True, capture_output=True, timeout=90)
        (args.out / (name + '.output')).write_text(run.stdout + run.stderr)
        assert run.returncode == 0, (name, run.stderr)
        maxima = {}
        rows = parse_output(run.stdout)
        for row, want in zip(rows, expected, strict=True):
            assert row['forward'] == row['step'] == 'SUCCESS', (name, row)
            for key, value in want.items():
                actual = np.asarray(row[key])
                assert actual.shape == value.shape, (name, key)
                error = np.abs(actual - value)
                assert np.all(error <= 2e-10 + 2e-10 * np.abs(value)), (name, key, actual, value)
                maxima[key] = max(maxima.get(key, 0), float(error.max(initial=0)))
                comparisons += value.size
        results.append(dict(model=name, cases=len(rows), max_error=maxima))
        print(name, 'PASS', flush=True)
    report = dict(status='passed', oracle=mj.__version__, policy=args.policy, fluid=args.fluid, fixed=args.fixed,
        probe=str(args.probe), probe_sha256=hashlib.sha256(args.probe.read_bytes()).hexdigest(),
        scenarios=sum(r['cases'] for r in results), comparisons=comparisons, results=results)
    (args.out / 'summary.json').write_text(json.dumps(report, indent=2) + '\n')
    print(report['scenarios'], 'scenarios,', comparisons, 'comparisons')


if __name__ == '__main__':
    main()
