#!/usr/bin/env python3
"""Checked SPARK smooth dynamics against the official MuJoCo 3.14 C library.

Run with a Python environment containing mujoco==3.14.0 and numpy. All builds,
models and captured inputs/outputs live in a new report directory or /tmp.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

import mujoco
import numpy as np
from prove_fragments import isolated_project


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def model_xml(body, actuator="", flags="", *, gravity="0 0 -9.81", timestep="0.002"):
    return f'''<mujoco><compiler angle="radian"/>
    <option timestep="{timestep}" gravity="{gravity}" integrator="Euler">
      <flag constraint="disable" {flags}/></option>
    <worldbody>{body}</worldbody><actuator>{actuator}</actuator></mujoco>'''


def fixtures():
    inertia = '<inertial pos=".17 -.12 .31" mass="2.3" diaginertia=".21 .32 .43" quat=".8 .2 -.3 .1"/>'
    hinge = f'<body pos=".3 -.2 1" quat=".9 .1 .2 -.1"><joint name="j" axis="1 2 -1" pos=".1 -.2 .05" ref=".23" springref="-.31" stiffness="1.7" damping=".18" armature=".04"/>{inertia}</body>'
    slide = f'<body pos=".3 -.2 1"><joint name="j" type="slide" axis="1 2 3" ref=".2" springref="-.1" stiffness="2.7" damping=".3" armature=".02"/>{inertia}</body>'
    multi = f'''<body pos=".2 .1 .9" quat=".9 .1 -.3 .2">
      <joint name="j" axis="1 2 3" pos=".1 .2 -.1" damping=".2" armature=".08"/>
      <joint name="k" type="slide" axis="-2 1 1" damping=".1" armature=".05"/>
      <joint name="l" axis="2 -1 3" pos="-.2 .1 .3" damping=".3" armature=".03"/>
      {inertia}<body pos=".4 -.2 .1"><joint name="m" axis="0 1 0" stiffness=".7" armature=".04"/>{inertia}
      <body pos=".1 .2 .4">{inertia}</body></body>
      <body pos="-.3 .2 .1" quat=".7 -.2 .1 .4"><joint name="n" type="slide" axis="0 1 2" armature=".02"/>{inertia}</body></body>'''
    motor = '<motor joint="j" gear="-2.3" ctrllimited="true" ctrlrange="-.8 .6" forcelimited="true" forcerange="-1.1 1.4"/>'
    affine = '<general joint="j" gear="1.4" gainprm="3.2" biastype="affine" biasprm=".3 -2.1 -.7" ctrllimited="true" ctrlrange="-1 2"/>'
    cases = {
        'world': model_xml(''),
        'fixed': model_xml(f'<body pos=".1 .2 .3" quat=".8 -.1 .2 .3">{inertia}</body>'),
        'slide': model_xml(slide),
        'hinge_motor': model_xml(hinge, motor),
        'hinge_affine': model_xml(hinge, affine),
        'branched_multijoint': model_xml(multi, motor + '<position joint="k" kp="2" kv=".4" gear="-.7"/>' + '<velocity joint="l" kv="1.3"/>'),
        'shared_actuators': model_xml(hinge, motor + affine),
    }
    for flag in ('gravity', 'spring', 'damper', 'actuation', 'clampctrl', 'eulerdamp'):
        cases['disable_' + flag] = model_xml(multi, motor + '<velocity joint="k" kv=".7"/>', f'{flag}="disable"')
    cases['small_inertia'] = model_xml('<body><joint type="slide"/><inertial pos="0 0 0" mass="1e-10" diaginertia="1e-12 1e-12 1e-12"/></body>')
    chain = ''
    for index in reversed(range(12)):
        kind = 'slide' if index % 3 == 0 else 'hinge'
        chain = f'<body pos=".15 -.07 .2" quat=".9 .1 -.2 .05"><joint type="{kind}" axis="1 2 -3" pos=".1 0 -.05" armature=".03" damping=".2" stiffness=".4"/>{inertia}{chain}</body>'
    cases['chain_12'] = model_xml(chain)
    return cases


def build(repo, out, toolchain):
    work = Path(tempfile.mkdtemp(prefix='sparkling-smooth-numerical-'))
    snapshot = work / 'source'
    files = [repo / 'sparkling_mujoco.gpr']
    for directory in ('src', 'experimental/smooth'):
        files += [p for p in (repo / directory).rglob('*') if p.suffix in ('.ads', '.adb', '.gpr')]
    hashes = {}
    for path in sorted(files):
        relative = path.relative_to(repo)
        target = snapshot / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(path, target)
        hashes[str(relative)] = digest(target)
    if any(digest(path) != hashes[str(path.relative_to(repo))] for path in files):
        raise RuntimeError('sources changed while taking the snapshot; retry after they stabilize')
    env = os.environ.copy()
    if toolchain:
        env['PATH'] = os.pathsep.join(str(p) for name in ('gnat', 'gprbuild', 'gnatprove')
                                     for p in (toolchain / name).glob('*/bin')) + os.pathsep + env['PATH']
    # Compile only the actual dependency closure. Unrelated units may be under
    # simultaneous development in the main thread; they are not dependencies.
    project = isolated_project(snapshot, work, 'smooth_probe')
    project.write_text(project.read_text().replace('project Fragment is',
        'project Fragment is\n   for Main use ("smooth_probe.adb");\n'
        '   for Exec_Dir use "bin";\n   package Binder is\n'
        '      for Switches ("Ada") use ("-Es");\n   end Binder;'))
    command = ['gprbuild', '-P', str(project), '-j2']
    (out / 'manifest.json').write_text(json.dumps(dict(snapshot=str(snapshot), hashes=hashes,
        build_command=command, project=project.read_text(), mujoco=mujoco.__version__, numpy=np.__version__,
        harness={name: digest(Path(__file__).with_name(name))
                 for name in ('compare_numerics.py', 'prove_fragments.py')},
        libraries={str(p): digest(p) for p in Path(mujoco.__file__).parent.glob('libmujoco*')}), indent=2))
    with (out / 'build.log').open('w') as log:
        subprocess.run(['python3', str(repo / 'tools/guarded.py'), '--cap-mb', '3000',
                        '--min-free-mb', '12000', '--timeout', '360', '--', *command],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    return work / 'bin/smooth_probe'


def parse_output(text):
    rows = []
    current = None
    for line in text.splitlines():
        key, *values = line.split()
        if key == 'create':
            if values != ['SUCCESS']:
                raise AssertionError(line)
        elif key == 'lifecycle':
            assert values == ['PASS']
        else:
            if key == 'reset_qpos':
                current = {}
                rows.append(current)
            if key in ('forward', 'step'):
                current[key] = values[0]
            elif key in ('position', 'quaternion'):
                current.setdefault(key, []).append([float(x) for x in values])
            else:
                current[key] = np.array([float(x) for x in values])
    assert text.rstrip().endswith('lifecycle PASS')
    return rows


def reference(m, q, v, ctrl, applied, clock, steps):
    d = mujoco.MjData(m)
    d.qpos[:] = q
    d.qvel[:] = v
    d.ctrl[:] = ctrl
    d.qfrc_applied[:] = applied
    d.time = clock
    mujoco.mj_forward(m, d)
    mass = np.zeros((m.nv, m.nv))
    mujoco.mj_fullM(m, d, mass)
    # Separate gravity and velocity bias using a second C evaluation at v=0.
    rest = mujoco.MjData(m)
    rest.qpos[:] = q
    mujoco.mj_forward(m, rest)
    values = dict(reset_qpos=m.qpos0.copy(), reset_qvel=np.zeros(m.nv),
                  qacc=d.qacc.copy(), mass=mass.ravel(), gravity=-rest.qfrc_bias.copy(),
                  bias=(d.qfrc_bias - rest.qfrc_bias).copy(), passive=d.qfrc_passive.copy(),
                  actuation=d.qfrc_actuator.copy(), length=d.actuator_length.copy(),
                  velocity=d.actuator_velocity.copy(), force=d.actuator_force.copy(),
                  position=d.xpos.copy(), quaternion=d.xquat.copy(), unchanged_qpos=q,
                  unchanged_qvel=v, unchanged_time=np.array([clock]))
    for _ in range(steps):
        mujoco.mj_step(m, d)
    values.update(qpos=d.qpos.copy(), qvel=d.qvel.copy(), time=np.array([d.time]))
    assert not np.any(d.warning.number), d.warning
    return values


def rejection_tests(probe, out):
    """Policy errors have different semantics from MuJoCo's warning/autoreset.

    Assert our documented statuses and exact state atomicity, without treating
    them as C-equivalence scenarios.
    """
    inertial = '<inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/>'
    slide = '<body><joint type="slide"/>' + inertial + '</body>'
    ordinary = model_xml(slide, gravity='0 0 0')
    requests = [
        ('time_limit', ordinary, 'SUCCESS', 'NUMERIC_LIMIT', 0., 0., 0., 1e10),
        ('position_limit', ordinary, 'SUCCESS', 'NUMERIC_LIMIT', 1e10, 1., 0., .25),
        ('velocity_limit', ordinary, 'SUCCESS', 'NUMERIC_LIMIT', 0., 1e10, 1e10, .25),
        ('acceleration_limit', ordinary.replace('mass="1"', 'mass=".1"'),
         'NUMERIC_LIMIT', 'NUMERIC_LIMIT', 0., 0., 1e10, .25),
        ('singular', model_xml('<body><joint type="slide"/><joint type="slide"/>' + inertial + '</body>'),
         'SINGULAR_INERTIA', 'SINGULAR_INERTIA', 0., 0., 0., .25),
        ('ill_conditioned', model_xml(slide.replace('mass="1"', 'mass="1e8"') + '<body><joint type="slide"/><inertial pos="0 0 0" mass="1e-6" diaginertia="1e-6 1e-6 1e-6"/></body>'),
         'ILL_CONDITIONED_INERTIA', 'ILL_CONDITIONED_INERTIA', 0., 0., 0., .25),
        ('coupled_condition', model_xml('<body><joint type="slide" armature="3e-14"/><joint type="slide" armature="3e-14"/>' + inertial + '</body>'),
         'ILL_CONDITIONED_INERTIA', 'ILL_CONDITIONED_INERTIA', 0., 0., 0., .25),
    ]
    results = []
    for name, xml, forward, step, position, velocity, force, clock in requests:
        m = mujoco.MjModel.from_xml_string(xml)
        path = out / ('reject_' + name + '.mjb')
        mujoco.mj_saveModel(m, str(path))
        inputs = [position]*m.nq + [velocity]*m.nv + [0.]*m.nu + [force]*m.nv + [clock, 1]
        input_text = '1\n' + ' '.join(map(str, inputs[:-1])) + ' 1\n'
        run = subprocess.run([str(probe), str(path), "Strict"], input=input_text, text=True, capture_output=True, timeout=30)
        (out / ('reject_' + name + '.xml')).write_text(xml)
        (out / ('reject_' + name + '.input')).write_text(input_text)
        (out / ('reject_' + name + '.output')).write_text(run.stdout + run.stderr)
        run.check_returncode()
        row, = parse_output(run.stdout)
        assert row['forward'] == forward and row['step'] == step, (name, row)
        assert np.array_equal(row['qpos'], [position]*m.nq), name
        assert np.array_equal(row['qvel'], [velocity]*m.nv), name
        assert row['time'][0] == clock, name
        results.append(dict(name=name, forward=forward, step=step, state_unchanged=True))
    unsupported = {
        'ball': (model_xml('<body><joint type="ball"/>' + inertial + '</body>'), 'UNSUPPORTED_JOINT'),
        'free': (model_xml('<body><freejoint/>' + inertial + '</body>'), 'UNSUPPORTED_JOINT'),
        'rk4': (ordinary.replace('integrator="Euler"', 'integrator="RK4"'), 'UNSUPPORTED_FEATURE'),
        'discrete': (ordinary.replace('integrator="Euler"', 'integrator="discrete"'), 'UNSUPPORTED_FEATURE'),
        'ipc': (ordinary.replace('integrator="Euler"', 'integrator="discrete" solver="CG"')
                .replace('constraint="disable"', 'constraint="disable" ipc="enable"'), 'UNSUPPORTED_FEATURE'),
        'constraints': (ordinary.replace('constraint="disable"', 'constraint="enable"'), 'UNSUPPORTED_FEATURE'),
        'fluid': (ordinary.replace('integrator="Euler"', 'integrator="Euler" viscosity=".01"'), 'UNSUPPORTED_FEATURE'),
    }
    for name, (xml, status) in unsupported.items():
        path = out / ('unsupported_' + name + '.mjb')
        m = mujoco.MjModel.from_xml_string(xml)
        mujoco.mj_saveModel(m, str(path))
        run = subprocess.run([str(probe), str(path)], text=True, capture_output=True, timeout=30)
        (out / ('unsupported_' + name + '.output')).write_text(run.stdout + run.stderr)
        run.check_returncode()
        assert run.stdout.strip() == 'create ' + status, (name, run.stdout)
        results.append(dict(name=name, create=status))
    return results


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument('--report-dir', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path)
    parser.add_argument('--samples', type=int, default=24)
    parser.add_argument('--probe', type=Path, help='Reuse an already checked executable; no build')
    parser.add_argument('--policy', choices=('Compatible','Strict'), default='Compatible')
    parser.add_argument('--extra-fixtures', type=Path,
                        help='Directory of additional XML fixtures; existing names may not be replaced')
    args = parser.parse_args()
    if args.samples < 1:
        parser.error('--samples must be positive')
    assert mujoco.__version__ == '3.14.0', 'Pinned oracle version is required'
    out = args.report_dir.resolve()
    out.mkdir(parents=True, exist_ok=False)
    probe = args.probe or build(args.repo.resolve(), out, args.toolchain_root)
    rng = np.random.default_rng(20260923)
    summary = dict(status='incomplete', policy=args.policy, seed=20260923, samples_per_model=args.samples, oracle=mujoco.__version__,
                   probe=str(probe), probe_sha256=digest(probe), normalization_edge_cases=7,
                   comparisons=0, scenarios=0, fixtures=[], failures=[])
    start = time.monotonic()
    # Mixed absolute/relative tolerances, never relative error near zero alone.
    atol, rtol = 2e-10, 2e-10
    cases = fixtures()
    if args.extra_fixtures:
        for path in sorted(args.extra_fixtures.glob('*.xml')):
            if path.stem in cases:
                parser.error('extra fixture shadows a built-in case: '+path.stem)
            cases[path.stem] = path.read_text()
    for name, xml in cases.items():
        print(name, flush=True)
        (out / (name + '.xml')).write_text(xml)
        m = mujoco.MjModel.from_xml_string(xml)
        path = out / (name + '.mjb')
        mujoco.mj_saveModel(m, str(path))
        scenarios, lines = [], [str(args.samples)]
        for index in range(args.samples):
            q = m.qpos0 + rng.uniform(-.8, .8, m.nq)
            v = rng.uniform(-2, 2, m.nv)
            ctrl = rng.uniform(-4, 4, m.nu)
            applied = rng.uniform(-.4, .4, m.nv)
            if name == 'small_inertia':
                applied *= 1e-10
            if index == 0:
                q, v, ctrl, applied = m.qpos0.copy(), v*0, ctrl*0, applied*0
            if name == 'crb_wide_fallback':
                # Each permitted scalar position stays inside Tier0, while
                # their accumulated world position exceeds the CRB fast domain.
                q += 6e9
            steps = 100 if index % 8 == 0 else 1
            clock = .125
            scenarios.append((q, v, ctrl, applied, clock, steps))
            lines.append(' '.join(format(float(x), '.17g') for x in np.concatenate((q, v, ctrl, applied))))
            lines.append(f'{clock} {steps}')
        input_text = '\n'.join(lines) + '\n'
        (out / (name + '.input')).write_text(input_text)
        run = subprocess.run([str(probe), str(path), args.policy], input=input_text, text=True, capture_output=True, timeout=60)
        (out / (name + '.output')).write_text(run.stdout)
        (out / (name + '.stderr')).write_text(run.stderr)
        run.check_returncode()
        actual = parse_output(run.stdout)
        assert len(actual) == len(scenarios)
        record = dict(name=name, scenarios=len(scenarios), comparisons=0, max_absolute=0., max_tolerance_ratio=0.)
        for index, (row, scenario) in enumerate(zip(actual, scenarios)):
            assert row['forward'] == row['step'] == 'SUCCESS', (name, index, row)
            assert row['forward_clamped'][0] == row['step_clamped'][0] == -1, (name, 'unexpected clamp')
            matrix = row['mass'].reshape(m.nv, m.nv)
            assert np.array_equal(matrix, matrix.T), (name, 'mass symmetry')
            if m.nv:
                np.linalg.cholesky(matrix)
            rhs = row['gravity'] - row['bias'] + row['passive'] + row['actuation'] + scenario[3]
            residual = matrix @ row['qacc'] - rhs
            residual_scale = np.abs(matrix) @ np.abs(row['qacc']) + np.abs(rhs)
            assert np.all(np.abs(residual) <= 1e-11*(1+residual_scale)), (name, 'dynamics residual')
            expected = reference(m, *scenario)
            for field, want in expected.items():
                got = np.asarray(row[field])
                assert got.shape == want.shape, (field, got.shape, want.shape)
                if field == 'quaternion':
                    got = got * np.where(np.sum(got * want, axis=1) < 0, -1., 1.)[:, None]
                error = np.abs(got-want)
                ratio = error / (atol + rtol*np.abs(want))
                record['comparisons'] += want.size
                record['max_absolute'] = max(record['max_absolute'], float(error.max(initial=0)))
                record['max_tolerance_ratio'] = max(record['max_tolerance_ratio'], float(ratio.max(initial=0)))
                if not np.all(np.isfinite(got)) or np.any(ratio > 1):
                    summary['failures'].append(dict(fixture=name, sample=index, field=field,
                        actual=got.tolist(), expected=want.tolist(), max_ratio=float(ratio.max(initial=0))))
        summary['fixtures'].append(record)
        summary['scenarios'] += record['scenarios']
        summary['comparisons'] += record['comparisons']
        (out / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
    summary['policy_tests_mode'] = 'Strict'
    summary['policy_tests'] = rejection_tests(probe, out)
    summary.update(status='failed' if summary['failures'] else 'passed',
                   seconds=time.monotonic()-start, atol=atol, rtol=rtol)
    (out / 'results.json').write_text(json.dumps(summary, indent=2) + '\n')
    print(json.dumps({k: v for k, v in summary.items() if k not in ('fixtures', 'failures')}, indent=2))
    print('failures:', len(summary['failures']))
    return bool(summary['failures'])


if __name__ == '__main__':
    raise SystemExit(main())
