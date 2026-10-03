"""C differential trajectories with smooth forces and active rigid constraints.

Ada receives only a model, state, controls and loads, never C-computed forces.
"""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

import mujoco
import numpy as np
from compare import model_xml, oracle, parse


def mixed_xml(joint, kind, early, fluid, solver="Newton", flag="", tendon="mixed"):
    j = ('<freejoint name="j"/>' if joint == "free" else
         f'<joint name="j" type="{joint}" damping=".03" frictionloss=".02"' +
         (' axis="0 0 1" limited="true" range="0 .2" margin=".015"' if joint == "slide" else
          ' limited="true" range="0 .15" margin=".02"' if joint == "ball" else
          ' axis="0 1 0" limited="true" range="-.12 .12" margin=".02"') + '/>')
    ellipsoid = ('<geom type="ellipsoid" size=".07 .05 .04" fluidshape="ellipsoid" '
                 'contype="0" conaffinity="0"/>' if fluid == "ellipsoid" else "")
    body = f'''<site name="start" pos="-1 .15 .2"/>
      <geom name="wrap" type="sphere" pos="0 0 .2" size=".3" contype="0" conaffinity="0"/>
      <body pos="1 .15 .09">{j}
      <inertial pos=".015 .01 .02" mass="1.3" diaginertia=".02 .03 .04"/>
      <geom type="sphere" size=".1"/>{ellipsoid}<site name="end" pos=".2 .1 0"/>
      <body pos=".1 .2 .3"><joint name="fslide" type="slide" axis="1 0 0" damping=".03"/>
      <joint name="fhinge" type="hinge" axis="0 1 0" damping=".02"/>
      <inertial pos=".05 0 0" mass=".7" diaginertia=".08 .1 .12"/></body></body>'''
    options = (f'actearly="{str(early).lower()}" actlimited="true" actrange="-.2 .8" '
               'ctrllimited="true" ctrlrange="0 1" forcelimited="true" forcerange="-1 1"')
    if kind == "muscle":
        curve = '.75 1.05 .3 200 .5 1.6 1.5 1.3 1.2'
        actuator = (f'<general joint="j" dyntype="muscle" dynprm=".01 .04 .1" '
                    f'gaintype="muscle" biastype="muscle" gainprm="{curve}" biasprm="{curve}" '
                    f'lengthrange="-1 2" {options}/>')
    elif kind == "motor":
        actuator = '<motor joint="j" gear=".4"/>'
    else:
        actuator = (f'<general joint="j" dyntype="{kind}" dynprm=".03" gainprm=".4" '
                    f'biastype="affine" biasprm=".01 -.1 -.02" {options}/>')
    actuator = '<motor joint="j" gear=".1"/>' + actuator + '<motor joint="j" gear=".2"/>'
    fixed = '''<fixed stiffness=".2 .01 .001" damping=".04" springlength="-.1 .2" armature=".2">
      <joint joint="fslide" coef=".7"/><joint joint="fhinge" coef="-.3"/>
      <joint joint="fslide" coef="-.1"/></fixed>
      <fixed stiffness=".3" damping=".05 .02 .001" armature=".1">
      <joint joint="fhinge" coef="1.2"/><joint joint="fslide" coef="-.7"/></fixed>'''
    spatial = '''<spatial stiffness=".2" damping=".01" springlength="1">
      <site site="start"/><geom geom="wrap"/><site site="end"/></spatial>'''
    txml = (fixed if tendon in ("fixed", "mixed") else "") + (spatial if tendon in ("spatial", "mixed") else "")
    dim = {"integrator": 1, "filter": 3, "filterexact": 4, "muscle": 6, "motor": 3}[kind]
    xml = model_xml(body, dim=dim, solver=solver)
    if fluid != "none":
        xml = xml.replace('timestep="0.001"', 'timestep="0.001" density="1.2" viscosity=".00002" wind=".3 -.1 .2"')
    if flag:
        xml = xml.replace('island="disable"', f'island="disable" {flag}="disable"')
    return xml.replace('</mujoco>', f'<tendon>{txml}</tendon><actuator>{actuator}</actuator></mujoco>')


def fixtures():
    for solver in ("PGS", "CG", "Newton"):
        for joint in ("slide", "hinge", "ball", "free"):
            for kind in ("integrator", "filter", "filterexact", "muscle"):
                for early in (False, True):
                    for fluid in ("box", "ellipsoid"):
                        name = f'{solver}-{joint}-{kind}-{early}-{fluid}'
                        yield name, mixed_xml(joint, kind, early, fluid, solver)
    for flag in ("actuation", "clampctrl", "gravity", "spring", "damper", "eulerdamp",
                 "contact", "limit", "frictionloss", "constraint"):
        for fluid in ("box", "ellipsoid"):
            yield f'flag-{flag}-{fluid}', mixed_xml("ball", "filterexact", True, fluid, flag=flag)
    for joint in ("slide", "hinge", "ball", "free"):
        for tendon in ("fixed", "spatial", "mixed"):
            yield f'tendon-{joint}-{tendon}', mixed_xml(joint, "motor", False, "none", tendon=tendon)
    # Constraints disabled individually: these tendon rows must not be required.
    base = mixed_xml("slide", "filter", False, "box", flag="limit")
    yield 'disabled-tendon-limit', base.replace('<fixed stiffness=', '<fixed limited="true" range="-.1 .1" stiffness=', 1)
    base = mixed_xml("slide", "filter", False, "box", flag="frictionloss")
    yield 'disabled-tendon-friction', base.replace('<fixed stiffness=', '<fixed frictionloss=".1" stiffness=', 1)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--samples', type=int, default=4)
    ap.add_argument('--steps', type=int, default=100)
    ap.add_argument('--only')
    args = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    args.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(20261002)
    records, failures = [], []
    for name, xml in fixtures():
        if args.only and args.only not in name:
            continue
        m = mujoco.MjModel.from_xml_string(xml)
        path = args.out / (name + '.mjb')
        mujoco.mj_saveModel(m, str(path))
        (args.out / (name + '.xml')).write_text(xml)
        requests, expected = [], []
        for sample in range(args.samples):
            q = m.qpos0.copy()
            if sample:
                mujoco.mj_integratePos(m, q, rng.uniform(-1, 1, m.nv), .008)
            if m.jnt_type[0] == mujoco.mjtJoint.mjJNT_BALL:
                q[:4] = [np.cos(.11), 0, np.sin(.11), 0]
            if m.jnt_type[0] == mujoco.mjtJoint.mjJNT_HINGE:
                q[0] = .13
            v = rng.uniform(-.1, .1, m.nv)
            applied = rng.uniform(-.05, .05, m.nv)
            ctrl = rng.uniform(-.3, 1.3, m.nu)
            act = rng.uniform(-.25, .9, m.na)
            loads = rng.uniform(-.05, .05, (m.nbody, 6))
            requests.extend([0, *q, *v, *applied, *ctrl, *act, *loads.ravel()])
            expected.append(oracle(m, q, v, applied, args.steps, ctrl, loads, act))
        data = f'{args.samples} {args.steps}\n' + ' '.join(format(x, '.17g') for x in requests) + '\n'
        (args.out / (name + '.input')).write_text(data)
        run = subprocess.run([str(args.binary), str(path), 'loads'], input=data, text=True,
                             capture_output=True, timeout=180)
        (args.out / (name + '.output')).write_text(run.stdout + run.stderr)
        try:
            if run.returncode or run.stdout.startswith('create'):
                raise ValueError(run.stdout[-1500:])
            actual = parse(run.stdout, m.nv, m.na)
            assert len(actual) == len(expected)
        except Exception as error:
            failures.append(dict(model=name, error=str(error)))
            print('FAIL', name, str(error), flush=True)
            continue
        for sample, (got, want) in enumerate(zip(actual, expected, strict=True)):
            errors = {}
            for key, value in want.items():
                tol = 2e-10 if key in ('counts', 'free', 'jac', 'aref', 'reg', 'act_dot', 'activation') else 3e-6
                same_shape = got[key].shape == value.shape
                passed = same_shape and bool(np.allclose(got[key], value, atol=tol,
                           rtol=1e-8 if tol > 1e-8 else 2e-12))
                errors[key] = dict(passed=passed, max_abs=float(np.max(abs(got[key]-value))) if same_shape and value.size else 0.)
            row = dict(model=name, sample=sample, passed=all(v['passed'] for v in errors.values()), errors=errors)
            records.append(row)
            if not row['passed']:
                failures.append(row)
                print('FAIL', name, sample, {k:v for k,v in errors.items() if not v['passed']}, flush=True)
        print(name, 'checked', flush=True)
    result = dict(reference=mujoco.__version__, binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  steps=args.steps, cases=len(records), passed=sum(r['passed'] for r in records),
                  failures=failures, records=records)
    (args.out / 'results.json').write_text(json.dumps(result, indent=2) + '\n')
    print('RESULT', result['passed'], result['cases'], 'failures', len(failures), flush=True)
    if failures:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
