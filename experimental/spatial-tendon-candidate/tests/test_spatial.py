"""Differential wrapping/path/Jacobian/force tests against MuJoCo 3.14.0."""
import argparse
import ctypes
import hashlib
import json
import subprocess
from datetime import datetime, timezone

import mujoco as mj
import numpy as np
from common import ROOT, REPO, SCRATCH, PIN, build, reference_library, source_hashes

RNG = np.random.default_rng(20260930)
IDENTITY = np.eye(3)


def tokens(values):
    return " ".join(str(v) if isinstance(v, (int, np.integer)) else repr(float(v)) for v in values)


def probe(exe, commands):
    result = subprocess.run([str(exe)], input="\n".join(commands) + "\n", text=True,
                            capture_output=True, timeout=180)
    if result.returncode:
        raise AssertionError(result.stderr + "\n" + result.stdout[-1000:])
    lines = result.stdout.splitlines()
    assert len(lines) == len(commands), (len(lines), len(commands))
    return [line.split() for line in lines]


def geometry_cases():
    cases = []
    for kind in (0, 1):
        for a, b, radius in [((-2, .3, 0), (2, .3, 1), .7),
                             ((-2, 2, 0), (2, 2, 0), .7),
                             ((0, 0, 0), (2, 0, 0), 1),
                             ((.1, 0, 0), (2, 0, 0), 1),
                             ((-2, 0, 0), (2, 0, 0), 1),
                             ((2, 0, 0), (2, 0, 0), 1),
                             ((-2, 1, 0), (2, 1, 0), 1),
                             ((-2, 0, -1), (2, 0, 2), 0),
                             ((-2, 0, -1), (2, 0, 2), 1e-16),
                             ((1, 0, 0), (0, 1, 0), 1),
                             ((2, 0, 0), (3, 0, 1), 1),
                             ((2, .2, 0), (2, -.2, .1), 1)]:
            for side in (None, np.array([0., 2., 0.]), np.array([0., -2., 0.]), np.zeros(3)):
                cases.append((kind, radius, np.array(a), np.array(b), np.zeros(3), IDENTITY, side))
        for _ in range(2000):
            q = RNG.normal(size=4); q /= np.linalg.norm(q)
            rotation = np.zeros(9); mj.mju_quat2Mat(rotation, q); rotation = rotation.reshape(3, 3)
            radius = 10 ** RNG.uniform(-5, 3)
            center = RNG.uniform(-3, 3, 3) * radius
            a, b = RNG.normal(size=(2, 3)) * radius * 2
            side_mode = RNG.integers(0, 4)
            side = None if side_mode == 0 else (
                np.zeros(3) if side_mode == 1 else RNG.normal(size=3) * radius * 3)
            cases.append((kind, radius, rotation @ a + center, rotation @ b + center,
                          center, rotation, None if side is None else rotation @ side + center))
    # Pinned near-tangent case: upstream acos argument rounds above one.
    # It returns NaN; the candidate must report Numeric_Limit, never clamp it.
    a = np.array([12182.935010613193, 5010.740327607607, 0.])
    b = np.array([12182.93479469836, 5010.740852575189, 0.])
    cases.append((1, 13173.132660970885, a, b, np.zeros(3), IDENTITY, -2*a))
    return cases


def geometry_test(exe):
    library = ctypes.CDLL(str(reference_library()))
    realp = np.ctypeslib.ndpointer(dtype=np.float64, flags="C_CONTIGUOUS")
    library.mju_wrap.argtypes = [realp, realp, realp, realp, realp, ctypes.c_double,
                                ctypes.c_int, ctypes.POINTER(ctypes.c_double)]
    library.mju_wrap.restype = ctypes.c_double
    cases = geometry_cases()
    commands = ["W " + tokens([k, r, int(s is not None), *a, *b, *c, *m.flat,
                               *(np.zeros(3) if s is None else s)]) for k, r, a, b, c, m, s in cases]
    actual = probe(exe, commands)
    counts = {"cases": len(cases), "wrapped": 0, "no_wrap": 0, "nonfinite_c_rejected": 0}
    error = 0.0
    for idx, ((kind, radius, a, b, c, mat, side), values) in enumerate(zip(cases, actual)):
        points = np.zeros(6)
        side_ptr = None if side is None else np.ascontiguousarray(side).ctypes.data_as(ctypes.POINTER(ctypes.c_double))
        length = library.mju_wrap(points, np.ascontiguousarray(a, dtype=float),
                                 np.ascontiguousarray(b, dtype=float), np.ascontiguousarray(c, dtype=float),
                                 np.ascontiguousarray(mat, dtype=float), radius,
                                 int(mj.mjtWrap.mjWRAP_SPHERE if kind == 0 else mj.mjtWrap.mjWRAP_CYLINDER), side_ptr)
        state = int(values[0]); obtained = np.array(values[1:], dtype=float)
        if not np.isfinite(length) or (length >= 0 and not np.all(np.isfinite(points))):
            assert state == 2, (idx, length, obtained)
            counts["nonfinite_c_rejected"] += 1
        elif length < 0:
            assert state == 0 and np.all(obtained == 0), (idx, state, length, obtained)
            counts["no_wrap"] += 1
        else:
            assert state == 1, (idx, state, length, cases[idx])
            expected = np.r_[length, points]
            delta = np.max(np.abs(obtained - expected))
            error = max(error, float(delta))
            np.testing.assert_allclose(obtained, expected, atol=3e-10 * max(1, radius), rtol=3e-11,
                                       err_msg=f"geometry case {idx}: {cases[idx]}")
            counts["wrapped"] += 1
    # Analytic, symmetric cylinder path in XY: two tangent legs plus short arc.
    a, b = np.array([-2., 0., 0.]), np.array([2., 0., 0.])
    line = "W " + tokens([1, 1., 0, *a, *b, *np.zeros(3), *IDENTITY.flat, *np.zeros(3)])
    result = np.array(probe(exe, [line])[0], float)
    total = np.linalg.norm(a-result[2:5]) + result[1] + np.linalg.norm(b-result[5:8])
    np.testing.assert_allclose(total, 2*np.sqrt(3) + np.pi/3, rtol=1e-14)
    counts["max_absolute_error"] = error
    return counts


def model(kind="sphere", side="outer", pulley=False, multi=False, static=False, chain=False):
    side_attr = "" if side == "none" else ' sidesite="side"'
    side_pos = "0 0 0" if side == "inner" else "0 2 0"
    geom_size = ".7" if kind == "sphere" else ".7 2"
    free = "" if static else "<freejoint/>"
    extra = '<site site="c"/><geom geom="wrap2"/><site site="d"/>' if multi else ""
    if pulley:
        extra += '<pulley divisor="2"/><site site="c"/><site site="d"/>'
        extra += '<pulley divisor="3"/><site site="a"/><site site="b"/>'
    if chain:
        return mj.MjModel.from_xml_string(f'''<mujoco>
          <option gravity="0 0 0"><flag contact="disable"/></option>
          <default><geom contype="0" conaffinity="0"/><site size=".02"/></default>
          <worldbody><body pos=".1 -.3 .2" euler=".2 -.1 .1">
            <joint type="hinge" axis="1 2 3"/><geom size=".05" mass="1"/>
            <body pos="-2 .25 -.2"><joint type="slide" axis="1 .3 .2"/>
              <geom size=".05" mass="1"/><site name="a" pos=".2 .3 .1"/></body>
            <body pos="2 .25 .7"><joint type="ball"/>
              <geom size=".05" mass="1"/><site name="b" pos=".1 -.2 .3"/></body>
            <body><joint type="ball"/>
              <geom name="wrap" type="{kind}" size="{geom_size}" pos=".1 -.1 .2" mass="1"/>
              <site name="side" pos="{side_pos}"/></body>
          </body></worldbody>
          <tendon><spatial stiffness="3.1" damping=".8" springlength=".5">
            <site site="a"/><geom geom="wrap"{side_attr}/><site site="b"/>
          </spatial></tendon></mujoco>''')
    return mj.MjModel.from_xml_string(f'''<mujoco>
      <option gravity="0 0 0"><flag contact="disable"/></option>
      <default><geom contype="0" conaffinity="0"/><site size=".02"/></default>
      <worldbody>
       <body name="left" pos="-2 .25 -.2">{free}<geom size=".05" mass="1"/><site name="a"/></body>
       <body name="right" pos="2 .25 .7">{free}<geom size=".05" mass="1"/><site name="b"/></body>
       <body name="obstacle" pos="0 0 0">{free}
        <geom name="wrap" type="{kind}" size="{geom_size}" mass="1"/><site name="side" pos="{side_pos}"/>
       </body>
       <site name="c" pos="3 1 .5"/><site name="d" pos="5 1 .5"/>
       <geom name="wrap2" type="sphere" size=".8" pos="4 1.1 .5"/>
      </worldbody>
      <tendon><spatial name="t" stiffness="3.1" damping=".8" springlength=".5">
        <site site="a"/><geom geom="wrap"{side_attr}/><site site="b"/>{extra}
      </spatial></tendon>
    </mujoco>''')


def route_nodes(m):
    nodes = []
    for typ, ident, prm in zip(m.wrap_type, m.wrap_objid, m.wrap_prm):
        typ = int(typ)
        if typ == mj.mjtWrap.mjWRAP_SITE:
            nodes.append([0, int(ident), -1, 1.])
        elif typ == mj.mjtWrap.mjWRAP_PULLEY:
            nodes.append([2, 0, -1, float(prm)])
        else:
            assert typ in (mj.mjtWrap.mjWRAP_SPHERE, mj.mjtWrap.mjWRAP_CYLINDER)
            nodes.append([1, int(ident), int(prm), 1.])
    return nodes


def path_command(m, d, force, initial, nodes=None):
    nodes = route_nodes(m) if nodes is None else nodes
    data = [m.nsite, m.ngeom, m.nbody, m.nv, len(nodes)]
    for b, p in zip(m.site_bodyid, d.site_xpos):
        data += [int(b), *p]
    for i in range(m.ngeom):
        # Unused inertial/test geoms can also be represented as spheres here.
        kind = int(int(m.geom_type[i]) == mj.mjtGeom.mjGEOM_CYLINDER)
        data += [int(m.geom_bodyid[i]), kind, m.geom_size[i, 0], *d.geom_xpos[i], *d.geom_xmat[i]]
    for b in range(m.nbody):
        lin, ang = np.zeros((3, m.nv)), np.zeros((3, m.nv))
        mj.mj_jac(m, d, lin, ang, d.xpos[b], b)
        data += list(d.xpos[b])
        for k in range(m.nv):
            data += [*lin[:, k], *ang[:, k]]
    for n in nodes:
        data += n
    data += [*d.qvel, force, *initial]
    return "P " + tokens(data)


def tendon_row(m, d):
    row = np.zeros(m.nv)
    start = int(m.ten_J_rowadr[0]); count = int(m.ten_J_rownnz[0])
    row[m.ten_J_colind[start:start+count]] = d.ten_J[start:start+count]
    return row


def path_tests(exe):
    commands, expectations, finite_differences = [], [], []
    for kind in ("sphere", "cylinder"):
        for side in ("none", "outer", "inner"):
            for layout in ("single", "pulley", "multi", "static", "chain"):
                m = model(kind, side, layout == "pulley", layout == "multi", layout == "static", layout == "chain")
                for sample in range(10):
                    d = mj.MjData(m)
                    if m.nv:
                        mj.mj_integratePos(m, d.qpos, RNG.normal(size=m.nv), .07)
                        d.qvel[:] = RNG.normal(size=m.nv)
                    mj.mj_forward(m, d)
                    row = tendon_row(m, d)
                    force = -3.1 * (d.ten_length[0] - .5) - .8 * d.ten_velocity[0]
                    initial = RNG.normal(size=m.nv)
                    commands.append(path_command(m, d, force, initial))
                    count = int(d.ten_wrapnum[0]); start = int(d.ten_wrapadr[0])
                    # wrap_xpos/wrap_obj Python views have an extra paired-point dimension.
                    points = d.wrap_xpos.reshape(-1, 3)[start:start+count].copy()
                    objects = d.wrap_obj.reshape(-1)[start:start+count].copy()
                    expectations.append((m.nv, float(d.ten_length[0]), row, float(d.ten_velocity[0]),
                                         d.qfrc_passive.copy()+initial, points, objects))
                    np.testing.assert_allclose(d.qfrc_passive, row*force, atol=2e-11, rtol=2e-11)
                    if sample == 0 and m.nv:
                        fd = []
                        eps = 2e-7
                        for k in range(m.nv):
                            lengths = []
                            for sign in (-1, 1):
                                changed = mj.MjData(m); changed.qpos[:] = d.qpos
                                v = np.zeros(m.nv); v[k] = sign
                                mj.mj_integratePos(m, changed.qpos, v, eps)
                                mj.mj_forward(m, changed)
                                commands.append(path_command(m, changed, 0., np.zeros(m.nv)))
                                expectations.append((m.nv, float(changed.ten_length[0]), tendon_row(m, changed),
                                  0., np.zeros(m.nv), changed.wrap_xpos.reshape(-1,3)[:int(changed.ten_wrapnum[0])].copy(),
                                  changed.wrap_obj.reshape(-1)[:int(changed.ten_wrapnum[0])].copy()))
                                lengths.append(len(commands)-1)
                            fd.append(lengths)
                        finite_differences.append((row, fd, eps))
    actual = probe(exe, commands)
    max_errors = np.zeros(4)
    lengths = []
    for idx, (line, expected) in enumerate(zip(actual, expectations)):
        assert line[0] == "0", (idx, line)
        nv, length, row, velocity, forces, points, objects = expected
        values = np.array(line, float)
        count = int(values[2]); obtained_row = values[3:3+nv]
        obtained_vel = values[3+nv]; obtained_forces = values[4+nv:4+2*nv]
        obtained_points = values[4+2*nv:].reshape(-1, 4)
        assert count == len(points), (idx, count, len(points))
        np.testing.assert_array_equal(obtained_points[:, 0], objects)
        np.testing.assert_allclose(obtained_points[:, 1:], points, atol=3e-10, rtol=3e-11)
        np.testing.assert_allclose(values[1], length, atol=3e-10, rtol=3e-11)
        np.testing.assert_allclose(obtained_row, row, atol=3e-10, rtol=3e-11)
        np.testing.assert_allclose(obtained_vel, velocity, atol=3e-10, rtol=3e-11)
        np.testing.assert_allclose(obtained_forces, forces, atol=3e-9, rtol=3e-11)
        lengths.append(values[1])
        errors = [abs(values[1]-length), np.max(abs(obtained_row-row), initial=0),
                  abs(obtained_vel-velocity), np.max(abs(obtained_forces-forces), initial=0)]
        max_errors = np.maximum(max_errors, errors)
    fd_error = 0.
    for row, indices, eps in finite_differences:
        fd = np.array([(lengths[plus]-lengths[minus])/(2*eps) for minus, plus in indices])
        fd_error = max(fd_error, float(np.max(abs(fd-row))))
        np.testing.assert_allclose(fd, row, atol=2e-7, rtol=2e-6)
    # Runtime topology gate rejects malformed paths; no out-of-bounds access.
    m = model(); d = mj.MjData(m); mj.mj_forward(m, d); nodes = route_nodes(m)
    bad = [nodes[1:], nodes[:-1], [nodes[0]], [nodes[0], [2,0,-1,0.], nodes[-1]],
           [nodes[0], [1, 999, -1, 1.], nodes[-1]],
           [nodes[0], [1, nodes[1][1], 999, 1.], nodes[-1]],
           [nodes[0], [2,0,-1,2.], nodes[-1]]]
    invalid = probe(exe, [path_command(m, d, 0., np.zeros(m.nv), b) for b in bad])
    assert all(line == ["invalid"] for line in invalid)
    # A successful branch followed by a numeric failure must discard both the
    # accumulated length and all emitted points (transactional publication).
    broken = model(kind="cylinder", static=False)
    state = mj.MjData(broken); mj.mj_forward(broken, state)
    ids = {name: mj.mj_name2id(broken, mj.mjtObj.mjOBJ_SITE, name)
           for name in ("a", "b", "side", "c", "d")}
    geom = mj.mj_name2id(broken, mj.mjtObj.mjOBJ_GEOM, "wrap")
    a = np.array([12182.935010613193, 5010.740327607607, 0.])
    state.site_xpos[ids["a"]] = a
    state.site_xpos[ids["b"]] = [12182.93479469836, 5010.740852575189, 0.]
    state.site_xpos[ids["side"]] = -2*a
    state.geom_xpos[geom] = 0; state.geom_xmat[geom] = IDENTITY.ravel()
    broken.geom_size[geom, 0] = 13173.132660970885
    broken_nodes = [[0,ids["a"],-1,1.], [0,ids["b"],-1,1.], [2,0,-1,2.],
                    [0,ids["a"],-1,1.], [1,geom,ids["side"],1.], [0,ids["b"],-1,1.]]
    state.qvel[:] = 1.0
    initial = np.arange(broken.nv, dtype=float) * .1
    failed = probe(exe, [path_command(broken, state, -7., initial, broken_nodes)])[0]
    np.testing.assert_array_equal(np.array(failed, float),
                                  np.r_[1., 0., 0., np.zeros(broken.nv), 0., initial])
    return {"cases": len(commands), "invalid_paths": len(bad), "atomic_failure_cases": 1,
            "finite_difference_rows": len(finite_differences), "finite_difference_max_error": fd_error,
            "max_error_length_jacobian_velocity_force": max_errors.tolist()}


def main():
    parser = argparse.ArgumentParser(); parser.add_argument("--mode", default="validation")
    args = parser.parse_args(); before = source_hashes(); exe = build(args.mode)
    result = {"timestamp": datetime.now(timezone.utc).isoformat(), "mode": args.mode,
              "reference": {"version": mj.__version__, "commit": PIN},
              "geometry": geometry_test(exe), "paths": path_tests(exe)}
    result["sha256"] = source_hashes()
    assert result["sha256"] == before, "Sources changed during tests"
    out = ROOT / "evidence" / ("tests-" + args.mode + ".json")
    out.parent.mkdir(parents=True, exist_ok=True); out.write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
