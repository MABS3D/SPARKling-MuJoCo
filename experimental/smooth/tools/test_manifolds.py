#!/usr/bin/env python3
"""Checked free/ball dynamics, scalar/tendon regressions and quaternion edges.

Requires the official mujoco==3.14.0 Python package, NumPy and GNAT/GPRbuild.
Builds and outputs stay outside the source tree in a fresh report directory.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys

import mujoco

from compare_numerics import build, fixtures
from prove_fragments import isolated_project


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--repo', type=Path, default=Path(__file__).resolve().parents[3])
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path)
    parser.add_argument('--expect-scalar-tendons', action='store_true',
                        help='Validate the current loader rejection of quaternion+tendon models')
    args = parser.parse_args()
    repo, out = args.repo.resolve(), args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    probe = build(repo, out, args.toolchain_root)
    manifest = json.loads((out / 'manifest.json').read_text())
    # Use the same immutable source snapshot for both checked executables.
    snapshot = Path(manifest['snapshot'])
    smooth = repo / 'experimental/smooth'
    joint_fixtures = smooth / 'tests/manifold-fixtures'
    command = [sys.executable, str(smooth / 'tools/compare_numerics.py'),
               '--repo', str(repo), '--report-dir', str(out / 'joints'),
               '--probe', str(probe), '--extra-fixtures', str(joint_fixtures),
               '--samples', '16', '--trajectory-steps', '100', '--external']
    # The capacity test avoids the intentionally costly dense-matrix getter.
    excluded = {'ball_spatial_tendon', 'free_spatial_tendon'} if args.expect_scalar_tendons else set()
    for model in [*fixtures(), *[p.stem for p in sorted(joint_fixtures.glob('*.xml'))
                                if not p.stem.startswith('capacity_') and p.stem not in excluded]]:
        command += ['--model', model]
    subprocess.run(command, check=True)
    if excluded:
        rejected = []
        for name in sorted(excluded):
            model = mujoco.MjModel.from_xml_path(str(joint_fixtures / (name+'.xml')))
            path = out / (name+'.mjb')
            mujoco.mj_saveModel(model, str(path))
            run = subprocess.run([str(probe), str(path)], text=True,
                                 capture_output=True, timeout=60, check=True)
            (out / (name+'.output')).write_text(run.stdout+run.stderr)
            assert run.stdout.strip() == 'create UNSUPPORTED_FEATURE', run.stdout
            rejected.append(dict(model=name, create='UNSUPPORTED_FEATURE'))
        (out / 'unsupported-manifold-tendons.json').write_text(json.dumps(rejected, indent=2)+'\n')
    subprocess.run([sys.executable, str(smooth / 'tools/compare_numerics.py'),
                    '--repo', str(repo), '--report-dir', str(out / 'tendons'),
                    '--probe', str(probe), '--extra-fixtures',
                    str(smooth / 'tests/tendon-regression-fixtures'),
                    '--samples', '8', '--trajectory-steps', '100', '--external'], check=True)
    subprocess.run([sys.executable, str(smooth / 'tools/check_manifold_edges.py'),
                    '--probe', str(probe), '--out', str(out / 'edges'),
                    '--fixtures', str(joint_fixtures)], check=True)
    work = out / 'capacity'
    work.mkdir()
    project = isolated_project(snapshot, work, 'manifold_capacity')
    project.write_text(project.read_text().replace('project Fragment is',
        'project Fragment is\n   for Main use ("manifold_capacity.adb");\n'
        '   for Exec_Dir use "bin";'))
    env = os.environ.copy()
    if args.toolchain_root:
        env['PATH'] = os.pathsep.join(str(p) for name in ('gnat', 'gprbuild', 'gnatprove')
            for p in (args.toolchain_root / name).glob('*/bin')) + os.pathsep + env['PATH']
    with (work / 'build.log').open('w') as log:
        subprocess.run(['python3', str(repo / 'tools/guarded.py'), '--cap-mb', '3000',
                        '--min-free-mb', '12000', '--timeout', '360', '--',
                        'gprbuild', '-P', str(project), '-j2'],
                       env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    model = mujoco.MjModel.from_xml_path(str(joint_fixtures / 'capacity_ball_210.xml'))
    model_path = work / 'capacity.mjb'
    mujoco.mj_saveModel(model, str(model_path))
    binary = work / 'bin/manifold_capacity'
    run = subprocess.run(['python3', str(repo / 'tools/guarded.py'), '--cap-mb', '1000',
                          '--min-free-mb', '4000', '--timeout', '90', '--',
                          str(binary), str(model_path)],
                         text=True, capture_output=True, check=True)
    (work / 'output.log').write_text(run.stdout + run.stderr)
    assert 'capacity PASS: nq=280 nv=210' in run.stdout
    (work / 'results.json').write_text(json.dumps(dict(status='passed', nq=model.nq,
        nv=model.nv, binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest()), indent=2)+'\n')
    print('Manifold dynamics regression passed:', out)


if __name__ == '__main__':
    main()
