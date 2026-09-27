#!/usr/bin/env python3
"""Count source-level work and exercise the pinned C CRB algorithm on saved inputs.

This is not a timing benchmark or a SPARK proof. The scalar Python CRB mirror
consumes C's cinert/cdof caches, so it does not validate a port of those caches.
Requires mujoco==3.14.0 and numpy in the existing movement oracle environment.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

import mujoco
import numpy as np

REPO = Path(__file__).resolve().parents[2]
REVISION = '9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'
MODELS = ('hinge_motor', 'branched_multijoint', 'chain_12')


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def inert_vec(i, v):
    # engine_util_spatial.c:mju_mulInertVec; ordinary scalar double operations.
    return [i[0]*v[0] + i[3]*v[1] + i[4]*v[2] - i[8]*v[4] + i[7]*v[5],
            i[3]*v[0] + i[1]*v[1] + i[5]*v[2] + i[8]*v[3] - i[6]*v[5],
            i[4]*v[0] + i[5]*v[1] + i[2]*v[2] - i[7]*v[3] + i[6]*v[4],
            i[8]*v[1] - i[7]*v[2] + i[9]*v[3],
            i[6]*v[2] - i[8]*v[0] + i[9]*v[4],
            i[7]*v[0] - i[6]*v[1] + i[9]*v[5]]


def dot6(a, b):
    # engine_inline.h:mji_dot6, including its non-sequential reduction order.
    return ((a[0]*b[0] + a[2]*b[2]) + (a[1]*b[1] + a[3]*b[3])) + (a[4]*b[4] + a[5]*b[5])


def crb(m, d):
    # This fixture excludes sleep, tendons, actuator armature, and simple DOFs.
    composite = d.cinert.tolist()
    motion = d.cdof.tolist()
    for body in reversed(range(m.nbody)):
        parent = int(m.body_parentid[body])
        if parent > 0:
            for k in range(10):
                composite[parent][k] += composite[body][k]
    mass = np.zeros(m.nC)
    products = dots = 0
    for row in range(m.nv):
        address = int(m.M_rowadr[row] + m.M_rownnz[row] - 1)
        mass[address] = m.dof_armature[row]
        buf = inert_vec(composite[int(m.dof_bodyid[row])], motion[row])
        products += 1
        col = row
        while col >= 0:
            assert m.M_colind[address] == col
            mass[address] += dot6(motion[col], buf)
            dots += 1
            address -= 1
            col = int(m.dof_parentid[col])
    return mass, products, dots


def topology_counts(m):
    n, bodies = int(m.nv), int(m.nbody - 1)
    ancestry = []
    for body in range(1, m.nbody):
        ancestor, count = body, 0
        while ancestor > 0:
            count += int(m.body_dofnum[ancestor])
            ancestor = int(m.body_parentid[ancestor])
        ancestry.append(count)
    # Source loop counts, NOT instruction counts or timings. All fixtures have
    # enabled, positive joint damping, hence two matrices are factorized.
    return dict(nv=n, moving_and_fixed_bodies=bodies, ancestor_dofs_per_body=ancestry,
        ada_mass_contributions=bodies*n*(n+1)//2,
        ada_inertia_vector_calls=bodies*n*(n+1)//2,
        candidate_hoisted_inertia_vector_calls=bodies*n,
        candidate_ancestor_only_mass_contributions=sum(k*(k+1)//2 for k in ancestry),
        candidate_ancestor_hoisted_inertia_vector_calls=sum(ancestry),
        c_crb_inertia_vector_calls=n, c_crb_dot6_calls=int(m.nC),
        ada_force_body_dof_projections=bodies*n, c_rne_final_dot6_calls=n,
        ada_stored_mass_entries=n*n, c_stored_lower_mass_entries=int(m.nC),
        full_lower_triangle_entries=n*(n+1)//2,
        ada_factorizations_per_step=2, c_factorizations_per_step=2,
        ada_condition_rhs_solves_per_step=2*n,
        ada_physical_rhs_solves_per_step=2, c_physical_rhs_solves_per_step=2,
        c_condition_rhs_solves_per_step=0,
        c_factor_scalar_update_terms= sum(int(k)*(int(k)-1)//2 for k in m.M_rownnz),
        ada_factor_inner_sum_terms=n*(n-1)*(n+1)//6)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--fixtures', type=Path, required=True,
                   help='Saved movement timings directory, or this audit output/fixtures')
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    revision = subprocess.check_output(['git', '-C', str(REPO/'mujoco'), 'rev-parse', 'HEAD'], text=True).strip()
    assert revision == REVISION
    a.out.mkdir(parents=True, exist_ok=False)
    saved = a.out/'fixtures'; saved.mkdir()
    sources = ['mujoco/src/engine/engine_core_smooth.c', 'mujoco/src/engine/engine_forward.c',
               'mujoco/src/engine/engine_util_spatial.c', 'mujoco/src/engine/engine_inline.h',
               'experimental/smooth/src/mj-data-inertia.adb',
               'experimental/smooth/src/mj-data-kinematics.adb',
               'experimental/smooth/src/mj-data-forces.adb',
               'experimental/smooth/src/mj-smooth_dynamics.adb']
    subprocess.run(['git', '-C', str(REPO/'mujoco'), 'diff', '--exit-code', 'HEAD', '--',
                    *(name.removeprefix('mujoco/') for name in sources if name.startswith('mujoco/'))],
                   check=True, capture_output=True)
    report = dict(complete=False, scope='source loop counts and CRB mirror; no timings or formal proof',
                  upstream=revision, oracle=mujoco.__version__, numpy=np.__version__,
                  source_sha256={name: digest(REPO/name) for name in sources},
                  oracle_library_sha256={p.name: digest(p) for p in Path(mujoco.__file__).parent.glob('libmujoco*')},
                  script_sha256=digest(Path(__file__)), models=[])
    for name in MODELS:
        xml = a.fixtures/(name+'.xml'); shutil.copy2(xml, saved/xml.name)
        m = mujoco.MjModel.from_xml_path(str(xml))
        assert m.nq == m.nv == m.njnt and m.nv > 0
        assert all(int(t) in (mujoco.mjtJoint.mjJNT_HINGE, mujoco.mjtJoint.mjJNT_SLIDE) for t in m.jnt_type)
        assert m.opt.enableflags == 0 and m.opt.disableflags == int(mujoco.mjtDisableBit.mjDSBL_CONSTRAINT)
        assert m.ntendon == m.neq == 0 and not np.any(m.dof_simplenum)
        assert np.all(m.jnt_actuatorid == -1) and np.any(m.dof_damping > 0)
        assert np.all(m.dof_dampingpoly == 0)
        counts = topology_counts(m)
        item = dict(name=name, counts=counts, states=[], rownnz=m.M_rownnz.tolist(),
                    dof_parentid=m.dof_parentid.tolist(), xml_sha256=digest(xml))
        for state in range(3):
            src = a.fixtures/f'{name}-{state}.input'; shutil.copy2(src, saved/src.name)
            values = np.fromstring(src.read_text(), sep=' ')
            assert values.size == 3*m.nv + m.nu
            d = mujoco.MjData(m)
            n = m.nv
            d.qpos[:] = values[:n]; d.qvel[:] = values[n:2*n]
            d.ctrl[:] = values[2*n:2*n+m.nu]; d.qfrc_applied[:] = values[2*n+m.nu:]
            d.time = .125
            maximum = 0.0
            for step in range(100):
                mujoco.mj_forward(m, d)
                mass, products, dots = crb(m, d)
                assert products == counts['c_crb_inertia_vector_calls']
                assert dots == counts['c_crb_dot6_calls']
                error = np.abs(mass-d.M)
                assert np.all(error <= 2e-12 + 2e-12*np.abs(d.M)), (name, state, step, error)
                maximum = max(maximum, float(np.max(error)))
                mujoco.mj_step(m, d)
                assert not np.any(d.warning.number)
            item['states'].append(dict(state=state, input_sha256=digest(src), steps=100,
                                       scalar_comparisons=100*m.nC, max_absolute_error=maximum))
        report['models'].append(item)
        print(name, json.dumps(counts), flush=True)
    report['complete'] = True
    (a.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')


if __name__ == '__main__':
    main()
