"""Full Ada-generated contacts/adhesion/constraints/step versus native C."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np


def fixtures():
    options = ('<option timestep=".001" solver="{solver}" iterations="300" '
               'tolerance="1e-12" cone="{cone}" jacobian="sparse">'
               '<flag warmstart="disable" island="disable"/></option>')
    def xml(body, actuator, dim=3, cone='pyramidal', solver='Newton', flags=''):
        return ('<mujoco><compiler angle="radian"/>' + options.format(solver=solver, cone=cone)
                + '<default><joint damping=".2"/><geom condim="' + str(dim)
                + '" friction=".6 .015 .004" solref=".025 1.1"/></default>'
                + '<worldbody><geom type="plane" size="10 10 .1"/>' + body
                + '</worldbody><actuator>' + actuator + '</actuator></mujoco>').replace(
                    '<flag warmstart=', '<flag ' + flags + ' warmstart=')
    sphere = ('<body name="b" pos="0 0 .095"><joint name="z" type="slide" axis="0 0 1"/>'
              '<geom type="sphere" size=".1" mass="1"/></body>')
    for cone in ('pyramidal', 'elliptic'):
        for dim in (1, 3, 4, 6):
            for solver in ('PGS', 'CG', 'Newton'):
                yield f'slide_{cone}_{dim}_{solver}', xml(
                    sphere, '<adhesion body="b" gain="3" ctrlrange="0 1"/>', dim, cone, solver)
        body = ('<body name="b" pos="0 0 .095"><freejoint/>'
                '<geom type="sphere" pos=".04 -.03 0" size=".1" mass="1"/></body>')
        yield 'free_offset_' + cone, xml(body, '<adhesion body="b" gain="2" ctrlrange="0 1"/>', 6, cone)
        yield 'ball_offset_' + cone, xml(body.replace('<freejoint/>', '<joint type="ball"/>'),
            '<adhesion body="b" gain="2" ctrlrange="0 1"/>', 4, cone)
        yield 'hinge_offset_' + cone, xml(body.replace('<freejoint/>', '<joint type="hinge" axis="0 1 0"/>'),
            '<adhesion body="b" gain="2" ctrlrange="0 1"/>', 3, cone)
        body = ('<body name="b" pos="0 0 .095"><freejoint/>'
                '<geom type="box" size=".1 .1 .1" mass="1"/></body>')
        yield 'box_average_' + cone, xml(body, '<adhesion body="b" gain="4" ctrlrange="0 1"/>', 3, cone)
        body = ('<body name="b" pos="0 0 .095"><freejoint/>'
                '<geom type="sphere" pos="-.12 0 0" size=".1" mass="1" margin=".004" gap=".015"/>'
                '<geom type="sphere" pos=".12 0 .017" size=".1" mass="1" margin=".004" gap=".015"/></body>')
        yield 'active_and_gap_' + cone, xml(body, '<adhesion body="b" gain="3" ctrlrange="0 1"/>', 3, cone)
        yield 'gap_only_' + cone, xml(sphere.replace('.095', '.112').replace(
            'mass="1"', 'mass="1" margin=".004" gap=".015"'),
            '<adhesion body="b" gain="3" ctrlrange="0 1"/>', 3, cone)
        body = ('<body name="b" pos="0 0 .5"><freejoint/>'
                '<geom type="sphere" size=".03" mass="1" contype="0" conaffinity="0"/>'
                '<body name="left" pos="-.08 0 0"><joint type="slide" axis="1 0 0"/>'
                '<geom type="sphere" size=".1" mass="1"/></body>'
                '<body name="right" pos=".08 0 0"><joint type="slide" axis="1 0 0"/>'
                '<geom type="sphere" size=".1" mass="1"/></body></body>')
        yield 'shared_ancestors_' + cone, xml(body,
            '<adhesion body="left" gain="2" ctrlrange="0 1"/>'
            '<adhesion body="right" gain="3" ctrlrange="0 1"/>', 4, cone)
    yield 'no_contacts', xml(sphere.replace('.095', '1'), '<adhesion body="b" gain="3" ctrlrange="0 1"/>')
    yield 'irrelevant_body', xml(sphere + '<body name="other" pos="1 0 1"><freejoint/>'
                                '<geom type="sphere" size=".1" mass="1"/></body>',
                                '<adhesion body="other" gain="3" ctrlrange="0 1"/>')
    for kind in ('integrator', 'filter', 'filterexact'):
        for early in ('false', 'true'):
            yield kind + '_early_' + early, xml(sphere,
                f'<general body="b" gainprm="3" dyntype="{kind}" dynprm=".02" actearly="{early}" '
                'actlimited="true" actrange="0 .8" ctrllimited="true" ctrlrange="0 1" '
                'forcelimited="true" forcerange="-.5 .9"/>')
    yield 'motor_and_adhesion', xml(sphere, '<motor joint="z" gear="2"/>'
                                   '<adhesion body="b" gain="3" ctrlrange="0 1"/>')
    yield 'interleaved_actuators', xml(sphere, '<adhesion body="b" gain="2" ctrlrange="0 1"/>'
                                      '<motor joint="z" gear="2"/>'
                                      '<adhesion body="b" gain="3" ctrlrange="0 1"/>'
                                      '<motor joint="z" gear="-1"/>')
    yield 'two_adhesive_actuators', xml(sphere, '<adhesion body="b" gain="2" ctrlrange="0 1"/>'
                                       '<adhesion body="b" gain="3" ctrlrange="0 1"/>')
    yield 'force_clamping', xml(sphere, '<general body="b" gainprm="3" ctrllimited="true" ctrlrange="0 1" '
                                'forcelimited="true" forcerange="-.1 .4"/>')
    yield 'gear_ignored', xml(sphere, '<general body="b" gear="2 3 4 5 6 7" gainprm="3"/>')
    for flag in ('actuation', 'clampctrl', 'contact', 'constraint'):
        yield 'disable_' + flag, xml(sphere, '<adhesion body="b" gain="3" ctrlrange="0 1"/>',
                                     flags=flag + '="disable"')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--samples', type=int, default=8)
    parser.add_argument('--steps', type=int, default=100)
    args = parser.parse_args()
    assert mujoco.__version__ == '3.14.0'
    source = args.build / 'source/experimental/constrained-step/tests/compare.py'
    spec = importlib.util.spec_from_file_location('base_compare', source)
    base = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(base)
    args.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(421002)
    results, failures = [], []
    for name, xml in fixtures():
        m = mujoco.MjModel.from_xml_string(xml)
        path = args.out / (name + '.mjb')
        mujoco.mj_saveModel(m, str(path))
        (args.out / (name + '.xml')).write_text(xml)
        inputs, expected = [], []
        body_mask = m.actuator_trntype == mujoco.mjtTrn.mjTRN_BODY
        for i in range(args.samples):
            q = m.qpos0.copy()
            if i: mujoco.mj_integratePos(m, q, rng.uniform(-1, 1, m.nv), .004)
            v = rng.uniform(-.05, .05, m.nv)
            applied = rng.uniform(-.1, .1, m.nv)
            ctrl = np.array([-.3, 0., .2, .7, 1.3, .5, .8, 1.][i % 8] * np.ones(m.nu))
            act = rng.uniform(.05, .7, m.na)
            loads = rng.uniform(-.02, .02, (m.nbody, 6))
            inputs.extend([0., *q, *v, *applied, *ctrl, *act, *loads.ravel()])
            reference = base.oracle(m, q, v, applied, args.steps, ctrl, loads, act)
            d = mujoco.MjData(m)
            d.qpos[:], d.qvel[:], d.ctrl[:], d.act[:] = q, v, ctrl, act
            d.qfrc_applied[:], d.xfrc_applied[:] = applied, loads
            mujoco.mj_forward(m, d)
            moment = np.zeros((m.nu, m.nv))
            for row in range(m.nu):
                adr, count = d.moment_rowadr[row], d.moment_rownnz[row]
                moment[row, d.moment_colind[adr:adr+count]] = d.actuator_moment[adr:adr+count]
            reference.update(adhesion=d.actuator_force[body_mask] @ moment[body_mask],
                             act_force=d.actuator_force.copy(), act_vel=d.actuator_velocity.copy(),
                             moment=np.where(body_mask[:, None], moment, 0.))
            expected.append(reference)
        data = f'{args.samples} {args.steps}\n' + ' '.join(format(x, '.17g') for x in inputs) + '\n'
        run = subprocess.run([str(args.binary), str(path), 'loads', 'adhesion'], input=data,
                             capture_output=True, text=True, timeout=180)
        (args.out / (name + '.input')).write_text(data)
        (args.out / (name + '.output')).write_text(run.stdout + run.stderr)
        lines = run.stdout.splitlines()
        if run.returncode or not lines or not lines[0].startswith('counts '):
            failures.append(dict(model=name, output=(run.stdout+run.stderr)[-1400:]))
            print('FAIL', name, failures[-1], flush=True)
            continue
        standard, extra = [], []
        for line in lines:
            key = line.split()[0]
            if key == 'counts': extra.append({'moment': []})
            if key in ('adhesion', 'act_force', 'act_vel', 'moment'):
                value = np.fromstring(line[len(key):], sep=' ')
                if key == 'moment': extra[-1][key].append(value)
                else: extra[-1][key] = value
            else: standard.append(line)
        actual = base.parse('\n'.join(standard), m.nv, m.na)
        assert len(actual) == len(expected) == len(extra)
        for i, (values, additions, reference) in enumerate(zip(actual, extra, expected)):
            additions['moment'] = np.asarray(additions['moment']).reshape(m.nu, m.nv)
            values.update(additions)
            errors = {}
            for key, target in reference.items():
                tol = 3e-6 if key in ('acc', 'force', 'qfrc', 'state', 'activation') else 2e-10
                # This getter intentionally exposes the body-transmission
                # velocity; unrelated smooth transmissions have their own tests.
                x, y = values[key], target
                if key == 'act_vel': x, y = x[body_mask], y[body_mask]
                errors[key] = dict(max_abs=float(np.max(np.abs(x-y))) if y.size else 0.,
                                   passed=bool(x.shape == y.shape and np.allclose(x, y, atol=tol, rtol=1e-8)))
            record = dict(model=name, sample=i, passed=all(e['passed'] for e in errors.values()), errors=errors)
            results.append(record)
            if not record['passed']:
                failures.append(record)
                print('FAIL', name, i, {k:v for k,v in errors.items() if not v['passed']}, flush=True)
        print(name, 'checked', flush=True)
    summary = dict(reference=mujoco.__version__, cases=len(results), passed=sum(r['passed'] for r in results),
                   steps=args.steps, failures=failures, records=results,
                   binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest())
    (args.out / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
    print('RESULT', summary['passed'], summary['cases'], 'failures', len(failures))
    if failures: raise SystemExit(1)


if __name__ == '__main__':
    main()
