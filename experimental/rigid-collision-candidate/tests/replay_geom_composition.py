"""Replay the same C states with two geom rotation composition orders.

This is a contact differential, not a time/performance benchmark. The source
asset corpus and rigid build are supplied explicitly so a failing pose remains
replayable even while integration sources change.
"""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

import mujoco
import numpy as np

from check_contacts import serialize_objects, library, match
from check_advanced import mesh_asset, mesh_graph

KINDS = {0: 'plane', 1: 'hfield', 2: 'sphere', 3: 'capsule',
         4: 'ellipsoid', 5: 'cylinder', 6: 'box', 7: 'mesh'}


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def rotation(quat):
    result = np.empty(9)
    mujoco.mju_quat2Mat(result, quat)
    return result.reshape(3, 3)


def matrix_product(left, right):
    # Same parenthesization as Generate_Contacts; no BLAS reassociation.
    return np.array([[(left[i, 0] * right[0, j]
                       + left[i, 1] * right[1, j])
                      + left[i, 2] * right[2, j]
                      for j in range(3)] for i in range(3)])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--assets', type=Path, required=True)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--model', action='append')
    parser.add_argument('--frames', type=int, default=30)
    parser.add_argument('--local-angle', type=float, default=0.0,
                        help='Rotate each moving geom locally around normalized (0.3,-0.5,0.8)')
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    names = args.model or ['mesh_cylinder_False', 'heightfield_mesh_9_False',
                           'heightfield_cylinder_9_False']
    binary = args.build / 'build/validation/bin/contact_probe'
    lib = library(args.build)
    sources = [Path(__file__), Path(__file__).with_name('check_contacts.py'),
               Path(__file__).with_name('check_advanced.py')]
    report = dict(mujoco=mujoco.__version__, frames=args.frames,
                  binary_sha256=digest(binary),
                  sources={str(p): digest(p) for p in sources}, models=[], complete=False)
    for name in names:
        model_file = args.assets / (name + '.mjb')
        input_file = args.assets / (name + '.input')
        model = mujoco.MjModel.from_binary_path(str(model_file))
        if model.ngeom != 2:
            raise ValueError('Replay requires a two-geom asset: ' + name)
        if args.local_angle != 0.0:
            axis = np.array([0.3, -0.5, 0.8]); axis /= np.linalg.norm(axis)
            local = np.empty(4)
            mujoco.mju_axisAngle2Quat(local, axis, args.local_angle)
            for geom in range(model.ngeom):
                if model.geom_bodyid[geom] != 0:
                    original = model.geom_quat[geom].copy()
                    mujoco.mju_mulQuat(model.geom_quat[geom], original, local)
                    # The compiler's identity-frame shortcut no longer applies.
                    model.geom_sameframe[geom] = 0
        replay_model = args.out / (name + '.mjb')
        mujoco.mj_saveModel(model, str(replay_model), None)
        data = mujoco.MjData(model)
        values = np.array([float(x) for x in input_file.read_text().split()[2:]])
        sample = values[:1 + model.nq + 2 * model.nv + 6 * model.nbody]
        data.time = sample[0]
        data.qpos[:] = sample[1:1 + model.nq]
        start = 1 + model.nq
        data.qvel[:] = sample[start:start + model.nv]
        data.qfrc_applied[:] = sample[start + model.nv:start + 2 * model.nv]
        data.xfrc_applied[:] = sample[start + 2 * model.nv:].reshape(model.nbody, 6)
        order = sorted(range(model.ngeom), key=lambda g: (model.geom_type[g], g))
        kinds = [KINDS[model.geom_type[g]] for g in order]
        vertices, facets, graphs, seeds = ([[], []] for _ in range(4))
        heightfield = None
        for i, geom in enumerate(order):
            if kinds[i] == 'mesh':
                vertices[i], facets[i] = mesh_asset(model, geom)
                graphs[i], seeds[i] = mesh_graph(model, geom)
            if kinds[i] == 'hfield':
                h = int(model.geom_dataid[geom])
                nr, nc, address = (int(model.hfield_nrow[h]), int(model.hfield_ncol[h]),
                                   int(model.hfield_adr[h]))
                heightfield = [nr, nc, *model.hfield_size[h],
                               *model.hfield_data[address:address + nr * nc].astype(float)]
        payloads = {kind: '' for kind in ('native', 'matrix', 'quaternion')}
        expected, errors = [], {kind: [] for kind in payloads}
        for frame in range(args.frames):
            mujoco.mj_forward(model, data)
            output = np.zeros(500)
            count = lib.rigid_contacts(model._address, data._address, *order, 0., output)
            if count < 0 or count > 50:
                raise RuntimeError('Oracle contact capacity/status')
            expected.append(output[:10 * count].reshape(-1, 10).copy())
            matrices = {kind: np.empty((model.ngeom, 9)) for kind in payloads}
            matrices['native'][:] = data.geom_xmat
            for geom in range(model.ngeom):
                body = int(model.geom_bodyid[geom])
                matrices['matrix'][geom] = matrix_product(
                    rotation(data.xquat[body]), rotation(model.geom_quat[geom])).ravel()
                composed = np.empty(4)
                mujoco.mju_mulQuat(composed, data.xquat[body], model.geom_quat[geom])
                matrices['quaternion'][geom] = rotation(composed).ravel()
            for kind in payloads:
                errors[kind].append(float(np.max(np.abs(matrices[kind] - data.geom_xmat))))
                payloads[kind] += serialize_objects(
                    kinds, model.geom_size[order], data.geom_xpos[order], matrices[kind][order],
                    vertices=vertices, facets=facets, graphs=graphs, seeds=seeds,
                    heightfield=heightfield, mode=3 if heightfield else 0)
            mujoco.mj_step(model, data)
        row = dict(model=name, sources={str(p): digest(p) for p in (model_file, input_file)},
                   replay_model_sha256=digest(replay_model), local_angle=args.local_angle,
                   geom_quat=model.geom_quat.tolist(), variants={})
        for kind, payload in payloads.items():
            input_path = args.out / (name + '-' + kind + '.input')
            input_path.write_text(payload)
            run = subprocess.run([str(binary), str(model.opt.ccd_iterations),
                                  str(model.opt.ccd_tolerance)], input=payload, text=True,
                                 capture_output=True, timeout=180)
            (args.out / (name + '-' + kind + '.output')).write_text(run.stdout + run.stderr)
            differences = []
            lines = run.stdout.splitlines()
            for frame, (line, want) in enumerate(zip(lines, expected)):
                fields = line.split()
                actual = np.array(fields[2:], float).reshape(-1, 10)
                error = match(actual, want, tolerance=1e-10)
                if error:
                    differences.append(dict(frame=frame, error=error, actual=actual.tolist(),
                                            expected=want.tolist()))
            row['variants'][kind] = dict(exit=run.returncode, samples=len(lines),
                matrix_max_error=max(errors[kind]), differences=differences,
                input_sha256=digest(input_path))
        report['models'].append(row)
        (args.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
        print(name, {k: dict(differences=len(v['differences']), matrix=v['matrix_max_error'])
                     for k, v in row['variants'].items()}, flush=True)
    report['complete'] = True
    (args.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
    raise SystemExit(any(v['exit'] != 0 or v['samples'] != args.frames
                         for row in report['models'] for v in row['variants'].values()))


if __name__ == '__main__':
    main()
