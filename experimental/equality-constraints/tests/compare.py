#!/usr/bin/env python3
"""Compare connect/weld geometry with official C rows and arithmetic kernels."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np

LIBRARY = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
LIB = ctypes.CDLL(str(LIBRARY))
PTR = np.ctypeslib.ndpointer(dtype=np.float64, flags='C_CONTIGUOUS')
for name in ['mju_mulQuat', 'mju_mulQuatAxis', 'mju_mulMatVec3']:
    function = getattr(LIB, name)
    function.argtypes = [PTR, PTR, PTR]
    function.restype = None


def multiply(a, b):
    out = np.empty(4)
    LIB.mju_mulQuat(out, np.ascontiguousarray(a), np.ascontiguousarray(b))
    return out


def anchor(r, t, local):
    out = np.empty(3)
    LIB.mju_mulMatVec3(out, np.ascontiguousarray(r), np.ascontiguousarray(local))
    for i in range(3):
        out[i] += t[i]
    return out


def kernel_reference(kind, torque, p0, p1, a, b, j0, j1):
    pos = p0 - p1
    jac = j0 - j1
    if kind:
        conjugate = np.array([b[0], -b[1], -b[2], -b[3]])
        pos = np.r_[pos, multiply(conjugate, a)[1:] * torque]
        for c in range(j0.shape[1]):
            axis_product = np.empty(4)
            LIB.mju_mulQuatAxis(axis_product, conjugate, np.ascontiguousarray(jac[3:, c]))
            jac[3:, c] = (0.5 * multiply(axis_product, a)[1:]) * torque
    return np.r_[pos, jac.ravel()]


def payload(kind, site, torque, r0, t0, l0, r1, t1, l1, q0, q1, rel0, rel1, j0, j1):
    return [kind, j0.shape[1], site, torque, *r0.ravel(), *t0, *l0,
            *r1.ravel(), *t1, *l1, *q0, *q1, *rel0, *rel1, *j0.ravel(), *j1.ravel()]


def dense_jacobian(m, d):
    if not mujoco.mj_isSparse(m):
        return d.efc_J.reshape(d.nefc, m.nv).copy()
    result = np.zeros((d.nefc, m.nv))
    for row in range(d.nefc):
        address = d.efc_J_rowadr[row]
        width = d.efc_J_rownnz[row]
        result[row, d.efc_J_colind[address:address+width]] = d.efc_J[address:address+width]
    return result


def models():
    leaf0 = '<body name="a" pos=".1 .05 .3"><JOINT0/><geom size=".1" mass="1"/><site name="s0" pos=".03 -.02 .04" euler="10 20 -30"/></body>'
    leaf1 = '<body name="b" pos=".5 -.1 .6"><JOINT1/><geom size=".12" mass="2"/><site name="s1" pos="-.02 .05 .03" euler="-20 5 40"/></body>'
    for topology in ['world', 'independent', 'shared']:
        if topology == 'world':
            bodies = leaf0.replace('<JOINT0/>', '<freejoint/>') + '<site name="s1" pos=".5 -.1 .6"/>'
        elif topology == 'independent':
            bodies = leaf0.replace('<JOINT0/>', '<freejoint/>') + leaf1.replace('<JOINT1/>', '<freejoint/>')
        else:
            bodies = '<body name="parent" pos=".2 -.3 .5"><freejoint/><geom size=".2" mass="3"/>' + leaf0.replace('<JOINT0/>', '<joint type="hinge" axis="0 0 1"/>') + leaf1.replace('<JOINT1/>', '<joint type="hinge" axis="1 0 0"/>') + '</body>'
        for site in [False, True]:
            objects = 'site1="s0" site2="s1"' if site else 'body1="a"' + (' body2="b"' if topology != 'world' else '')
            for kind, name in enumerate(['connect', 'weld']):
                for torque in ([-2.0, 0.0, 1e-6, 1.0, 3.0, 1e4] if kind else [1.0]):
                    for layout in ['dense', 'sparse']:
                        properties = ('anchor=".2 .1 .4"' if not site else '') if not kind else f'torquescale="{torque}"' + (' relpose=".1 -.2 .05 .9238795325 0 .3826834324 0"' if not site else '')
                        xml = f'<mujoco><option jacobian="{layout}"><flag contact="disable" warmstart="disable" island="disable"/></option><worldbody>{bodies}</worldbody><equality><{name} {objects} {properties}/></equality></mujoco>'
                        yield f'{name}-{topology}-{int(site)}-{torque}-{layout}', xml


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--samples', type=int, default=4)
    args = parser.parse_args()
    assert mujoco.__version__ == '3.14.0'
    args.out.mkdir(parents=True, exist_ok=False)
    rng = np.random.default_rng(20261002)
    cases, inputs, expected = [], [], []
    identity = np.array([1., 0., 0., 0.])
    for name, xml in models():
        m = mujoco.MjModel.from_xml_string(xml)
        (args.out/(name+'.xml')).write_text(xml)
        for sample in range(args.samples):
            d = mujoco.MjData(m)
            mujoco.mj_integratePos(m, d.qpos, rng.uniform(-1, 1, m.nv), 0.1*sample)
            if sample == args.samples-1:
                for joint in range(m.njnt):
                    if m.jnt_type[joint] == mujoco.mjtJoint.mjJNT_FREE:
                        address = m.jnt_qposadr[joint]+3
                        d.qpos[address:address+4] *= -1
            mujoco.mj_fwdPosition(m, d)
            kind = int(m.eq_type[0]); site = int(m.eq_objtype[0] == mujoco.mjtObj.mjOBJ_SITE)
            obj0, obj1 = int(m.eq_obj1id[0]), int(m.eq_obj2id[0])
            b0, b1 = (int(m.site_bodyid[obj0]), int(m.site_bodyid[obj1])) if site else (obj0, obj1)
            if site:
                l0, l1 = m.site_pos[obj0], m.site_pos[obj1]
                rel0, rel1 = m.site_quat[obj0], m.site_quat[obj1]
                point0, point1 = d.site_xpos[obj0], d.site_xpos[obj1]
            else:
                l0, l1 = (m.eq_data[0, 3:6], m.eq_data[0, :3]) if kind else (m.eq_data[0, :3], m.eq_data[0, 3:6])
                rel0, rel1 = (m.eq_data[0, 6:10] if kind else identity), identity
                point0 = anchor(d.xmat[b0], d.xpos[b0], l0)
                point1 = anchor(d.xmat[b1], d.xpos[b1], l1)
            jp0 = np.zeros((3, m.nv)); jr0 = np.zeros_like(jp0)
            jp1 = np.zeros_like(jp0); jr1 = np.zeros_like(jp0)
            mujoco.mj_jac(m, d, jp0, jr0, point0, b0)
            mujoco.mj_jac(m, d, jp1, jr1, point1, b1)
            j0, j1 = (np.r_[jp0, jr0], np.r_[jp1, jr1]) if kind else (jp0, jp1)
            nrow = 6 if kind else 3
            assert d.nefc == nrow
            inputs.append(payload(kind, site, m.eq_data[0, 10], d.xmat[b0], d.xpos[b0], l0,
                                  d.xmat[b1], d.xpos[b1], l1, d.xquat[b0], d.xquat[b1], rel0, rel1, j0, j1))
            expected.append(np.r_[d.efc_pos, dense_jacobian(m, d).ravel()])
            cases.append(dict(name=name, sample=sample, source='mj_fwdPosition', nv=m.nv))
    native_cases = len(cases)
    for case in range(320):
        kind = case % 2; site = (case//2) % 2; rows = 6 if kind else 3
        width = [0, 1, 2, 3, 4, 7, 12, 65, 128][case % 9]
        scale = [1e-30, 1e-10, 1., 1e10, 1e20][case % 5]
        torque = [-1e10, -2., -1e-8, 0., 1e-15, 1., 1e10][case % 7]
        quats = []
        for unused in range(4):
            q = rng.normal(size=4); q /= np.linalg.norm(q); quats.append(q)
        q0, q1, rel0, rel1 = quats
        r0 = np.empty(9); r1 = np.empty(9)
        mujoco.mju_quat2Mat(r0, q0); mujoco.mju_quat2Mat(r1, q1)
        coordinates = rng.uniform(-1, 1, (4, 3)) * (1e10 if case % 3 == 0 else 1.)
        t0, t1, l0, l1 = coordinates
        j0, j1 = rng.uniform(-1, 1, (2, rows, width)) * scale
        a = multiply(q0, rel0); b = multiply(q1, rel1) if site else q1
        inputs.append(payload(kind, site, torque, r0, t0, l0, r1, t1, l1, q0, q1, rel0, rel1, j0, j1))
        expected.append(kernel_reference(kind, torque, anchor(r0, t0, l0), anchor(r1, t1, l1), a, b, j0, j1))
        cases.append(dict(name=f'kernel-{case}', source='native C kernels', nv=width))
    text = str(len(inputs))+'\n'+'\n'.join(' '.join(format(float(v), '.17g') for v in row) for row in inputs)+'\n'
    (args.out/'inputs.txt').write_text(text)
    run = subprocess.run([str(args.binary)], input=text, capture_output=True, text=True, timeout=120)
    (args.out/'output.txt').write_text(run.stdout)
    (args.out/'stderr.txt').write_text(run.stderr)
    if run.returncode:
        raise RuntimeError(run.stderr[-2000:])
    lines = run.stdout.splitlines()
    assert len(lines) == len(cases), (len(lines), len(cases))
    for record, line, ref in zip(cases, lines, expected):
        actual = np.fromstring(line, sep=' ')
        record['passed'] = actual.shape == ref.shape and bool(np.allclose(actual, ref, atol=2e-11, rtol=2e-12))
        record['max_abs_error'] = float(np.max(np.abs(actual-ref)))
        record['max_scaled_error'] = float(np.max(np.abs(actual-ref)/(2e-11+2e-12*np.abs(ref))))
    failures = [r for r in cases if not r['passed']]
    result = dict(reference=mujoco.__version__, library_sha256=hashlib.sha256(LIBRARY.read_bytes()).hexdigest(),
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(), cases=len(cases),
                  native_engine_cases=native_cases, kernel_cases=len(cases)-native_cases,
                  passed=len(cases)-len(failures), failures=failures, records=cases)
    (args.out/'results.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k:v for k,v in result.items() if k not in ['records']}))
    raise SystemExit(bool(failures))


if __name__ == '__main__':
    main()
