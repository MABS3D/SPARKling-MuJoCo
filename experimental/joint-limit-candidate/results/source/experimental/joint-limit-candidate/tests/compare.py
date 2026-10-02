#!/usr/bin/env python3
"""Compare every assembled limit row with the actual MuJoCo 3.14.0 library."""
from pathlib import Path
import argparse, json, math, random, subprocess
import mujoco
import numpy as np
from evidence import snapshot, digest

# kind, enabled, joint/dof ids, q, range, margin, quat, local velocity,
# solref, solimp, timestep, refsafe, discrete, approximate diagonal.
DEFAULT = [3, 1, 0, 0, 0., -1., 1., 0., 1., 0., 0., 0., 0., 0., 0.,
           .02, 1., .9, .95, .001, .5, 2, .002, 1, 0, 1., 0., 0.]

def xml(c, sparse=False):
    name = {0: 'free', 1: 'ball', 2: 'slide', 3: 'hinge'}[c[0]]
    joint = ('<freejoint/>' if c[0] == 0 else
             f'<joint type="{name}" limited="true" range="{c[5]} {c[6]}" margin="{c[7]}" '
             f'solreflimit="{c[15]} {c[16]}" solimplimit="{c[17]} {c[18]} {c[19]} {c[20]} {c[21]}"/>')
    return f'''<mujoco><compiler angle="radian"/><option timestep="{c[22]}" gravity="0 0 0"
       integrator="Euler" solver="PGS" jacobian="{'sparse' if sparse else 'dense'}">
       <flag warmstart="disable" limit="{'enable' if c[1] else 'disable'}"
       refsafe="{'enable' if c[23] else 'disable'}"/></option><worldbody><body>
       {joint}<geom type="sphere" size=".1" mass="2" contype="0" conaffinity="0"/>
       </body></worldbody></mujoco>'''

def cases():
    rows, names = [], []
    fields = dict(kind=0, enabled=1, q=4, low=5, high=6, margin=7, ref0=15, ref1=16,
                  d0=17, dw=18, width=19, mid=20, power=21, h=22, refsafe=23)
    def add(name, quat=None, velocity=None, **kw):
        c = DEFAULT.copy()
        for k, v in kw.items(): c[fields[k]] = v
        if quat is not None: c[8:12] = quat
        if velocity is not None: c[12:15] = velocity
        rows.append(c); names.append(name)
    for kind in [2, 3]:
        for margin in [-.05, 0., .05, 2.]:
            for boundary in [-1. - margin, -1. + margin, 0., 1. - margin, 1. + margin]:
                for q in [math.nextafter(boundary, -math.inf), boundary,
                          math.nextafter(boundary, math.inf)]:
                    add('strict-boundary', kind=kind, q=q, margin=margin)
        for q in [-1.1, 0., 1.1]:
            add('disabled', kind=kind, q=q, enabled=0)
        for power in [1, 2]:
            for d0, dw in [(.9,.95), (.95,.9), (.9,.9), (-.2,2.), (2.,-.2)]:
                for width in [-1., 0., 1e-15, .001, .1]:
                    for mid in [-1., .0001, .3, .9999, 2.]:
                        for offset in [.00001, .00025, .0005, .001]:
                            add('impedance', kind=kind, q=1.+offset, power=power,
                                d0=d0, dw=dw, width=width, mid=mid, velocity=[-.2,0,0])
        for refs in [(.02,1.), (.0001,.5), (-100.,-3.), (0.,0.), (0.,-2.), (-2.,0.),
                     (.02,-1.), (-1.,1.), (1e-10,1e-10)]:
            for refsafe in [0,1]:
                add('solref', kind=kind, q=-1.01, ref0=refs[0], ref1=refs[1],
                    refsafe=refsafe, velocity=[.3,0,0])
    for quat in [[1.,0,0,0], [-1.,0,0,0], [0.,0,0,0], [0.,1.,0,0],
                 [1.,1e-16,0,0], [-1.,1e-16,0,0], [1e-20,0,0,0], [.5,.5,.5,.5]]:
        for margin in [-.1, 0., .1, 2.]:
            add('ball-singular', kind=1, low=0., high=1., quat=quat, margin=margin,
                velocity=[.3,-.7,.2])
    for angle in [0., 1e-16, 1e-15, 1., math.nextafter(math.pi,0.), math.pi,
                  math.nextafter(math.pi,math.inf), 2*math.pi]:
        for scale in [1e-20, 1e-15, 1., math.nextafter(1.,0.), math.nextafter(1.,math.inf)]:
            for sign in [-1.,1.]:
                q = [sign*scale*math.cos(angle/2), sign*scale*math.sin(angle/2),0.,0.]
                add('ball-normalization-boundary', kind=1, low=0., high=1., quat=q,
                    velocity=[.3,-.7,.2])
    rng = random.Random(20261001)
    for _ in range(400):
        axis = np.array([rng.uniform(-1,1) for _ in range(3)])
        axis /= np.linalg.norm(axis)
        angle = rng.uniform(-2*math.pi, 2*math.pi)
        scale = 10**rng.uniform(-4,4)
        quat = scale*np.r_[math.cos(angle/2), axis*math.sin(angle/2)]
        add('ball-random', kind=1, low=0., high=rng.uniform(.05,3.1),
            margin=rng.uniform(0,.2), quat=quat.tolist(),
            velocity=[rng.uniform(-2,2) for _ in range(3)],
            ref0=10**rng.uniform(-3,-.3), ref1=rng.uniform(.1,2),
            mid=rng.uniform(.05,.95), width=10**rng.uniform(-4,0))
    add('free', kind=0)
    return names, rows

def expected(c, m, d):
    active = d.nefc
    mixed = (c[15]>0) != (c[16]>0)
    out = [0., float(active), float(mixed)]
    jac = np.zeros((active, m.nv))
    if m.opt.jacobian == mujoco.mjtJacobian.mjJAC_SPARSE:
        for i in range(active):
            addr = d.efc_J_rowadr[i]; n = d.efc_J_rownnz[i]
            jac[i, d.efc_J_colind[addr:addr+n]] = d.efc_J[addr:addr+n]
    else:
        jac = d.efc_J.reshape(active, m.nv)
    for i in range(2):
        if i < active:
            assert d.efc_type[i] == mujoco.mjtConstraint.mjCNSTR_LIMIT_JOINT
            j = np.zeros(3); j[:m.nv] = jac[i]
            side = 2 if c[0] == 1 else (0 if j[0] == 1. else 1)
            kb = d.efc_KBIP[i]
            out += [float(d.efc_id[i]), 0., 3. if c[0]==1 else 1., float(side),
                    d.efc_pos[i], d.efc_margin[i], *j, 0., d.efc_vel[i],
                    kb[2], kb[3], kb[0], kb[1], d.efc_R[i], d.efc_D[i], d.efc_aref[i]]
        else:
            out += [0.,0.,1.,0.,0.,0.,0.,0.,0.,1.,0.,0.,0.,0.,0.,1e-15,0.,0.]
    generalized = np.zeros(3)
    if c[0] != 0: generalized[:m.nv] = d.qfrc_constraint
    out += generalized.tolist()
    return out

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    assert mujoco.__version__ == '3.14.0'
    sources = snapshot(); args.out.mkdir(parents=True, exist_ok=True)
    names, inputs = cases(); reference = []
    # Use the model's actual approximate weight and check dense AND sparse C paths.
    doubled, labels = [], []
    for c, name in zip(inputs, names):
        for sparse in [False, True]:
            m = mujoco.MjModel.from_xml_string(xml(c, sparse)); d = mujoco.MjData(m)
            if c[0] == 1: d.qpos[:] = c[8:12]; d.qvel[:] = c[12:15]
            elif c[0] in [2,3]: d.qpos[0] = c[4]; d.qvel[0] = c[12]
            mujoco.mj_forward(m, d)
            actual_input = c.copy(); actual_input[25] = float(m.dof_invweight0[0])
            actual_input[26:28] = [0.,0.]
            actual_input[26:26+d.nefc] = d.efc_force.tolist()
            reference.append(expected(c, m, d)); doubled.append(actual_input)
            labels.append(name + ('-sparse' if sparse else '-dense'))
    data = ''.join(' '.join(format(x, '.17g') for x in c)+'\n' for c in doubled)
    p = subprocess.run([str(args.binary.resolve())], input=data, text=True, capture_output=True)
    (args.out/'input.txt').write_text(data); (args.out/'output.txt').write_text(p.stdout)
    (args.out/'stderr.txt').write_text(p.stderr)
    assert p.returncode == 0, p.stderr
    actual = [list(map(float, line.split())) for line in p.stdout.splitlines()]
    assert len(actual) == len(reference)
    maximum = [0.]*42; scaled = [0.]*42; comparisons = 0
    exact = {0,1,2,3,4,5,6,12,21,22,23,24,30}
    for i, (a,b,c) in enumerate(zip(actual, reference, doubled)):
        assert len(a) == len(b) == 42
        for col, (v,w) in enumerate(zip(a,b)):
            maximum[col] = max(maximum[col], abs(v-w))
            scaled[col] = max(scaled[col], abs(v-w)/(1+abs(w)))
            assert math.isfinite(v)
            if col in exact: assert v == w, (i,labels[i],col,v,w,c)
            else: assert math.isclose(v,w,rel_tol=3e-11,abs_tol=3e-11), (i,labels[i],col,v,w,c)
            comparisons += 1
    # Metadata, clearing and unsupported-integrator behavior use independent assertions.
    checks = []
    for kind, q, margin in [(3,0.,2.), (2,1.1,0.), (1,0.,2.)]:
        c = DEFAULT.copy(); c[0]=kind; c[2:4]=[7,9]; c[4]=q; c[7]=margin
        checks.append(c)
    c = DEFAULT.copy(); c[4]=1.1; c[24]=1; checks.append(c)
    q = subprocess.run([str(args.binary.resolve())], input=''.join(
        ' '.join(format(x,'.17g') for x in c)+'\n' for c in checks), text=True, capture_output=True)
    assert q.returncode == 0, q.stderr
    extra = [list(map(float,l.split())) for l in q.stdout.splitlines()]
    assert extra[0][1] == 2 and extra[0][3:5] == [7,9] and extra[0][21:23] == [7,9]
    assert extra[1][1] == 1 and extra[1][3:5] == [7,9]
    assert extra[2][1] == 1 and extra[2][3:5] == [7,9]
    assert extra[3][12] == 2 and extra[3][13:18] == [0.]*5
    assert sources == snapshot()
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
    summary = dict(passed=True, cases=len(actual), scalar_comparisons=comparisons,
                   analytic_cases=len(extra), reference='MuJoCo 3.14.0 dense and sparse',
                   atol=3e-11, rtol=3e-11, max_abs_error_by_column=maximum,
                   max_scaled_error_by_column=scaled, binary_sha256=digest(args.binary),
                   library_sha256=digest(library), sources=sources)
    (args.out/'reference.json').write_text(json.dumps(reference)+'\n')
    (args.out/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
    print(json.dumps({k:v for k,v in summary.items() if k!='sources'}, indent=2))

if __name__ == '__main__': main()
