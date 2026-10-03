#!/usr/bin/env python3
"""Compare assembled candidate solves with the official native MuJoCo solver.

Run with the MuJoCo 3.14.0 Python environment. Cold-start, dense Jacobians,
Euler damping disabled, no islands/IPC/noslip: M is exactly the effective metric.
This is a correctness test, not a performance comparison of whole pipelines.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import numpy as np
import mujoco


def row(kind=2, dimension=1, r=0.1, bound=0., mu=1., friction=None):
    return [kind, dimension, r, 1/r, bound, mu, *(friction if friction is not None else [1.]*5)]


def encode(p):
    n, k = len(p['free']), len(p['ref'])
    fields = [n, k, p['method'], p.get('repeat', 1), p.get('iterations', 1000),
              p.get('ls_iterations', 100), p.get('tolerance', 1e-12), .01, p.get('scale', 1.)]
    for name in ['M', 'J', 'free', 'ref', 'a0', 'f0', 'rows']:
        fields.extend(np.asarray(p[name]).ravel())
    return ' '.join(format(float(x), '.17g') for x in fields) + '\n'


def run(binary, problems):
    p = subprocess.run([str(binary)], input=''.join(map(encode, problems)), text=True,
                       capture_output=True, timeout=120)
    if p.returncode:
        raise RuntimeError(p.stderr + p.stdout[-2000:])
    lines = p.stdout.splitlines()
    assert len(lines) == len(problems), (len(lines), len(problems), p.stdout)
    out = []
    for line, problem in zip(lines, problems):
        s = line.split(); n = len(problem['free'])
        out.append(dict(status=s[0], iterations=int(s[1]), evaluations=int(s[2]),
                        restarts=int(s[3]), line_search_limits=int(s[4]), curvature_repairs=int(s[5]),
                        cost=float(s[6]), gradient=float(s[7]), improvement=float(s[8]),
                        a=np.array(s[9:9+n], float), f=np.array(s[9+n:], float)))
    return out


def fixture(name, body, equality='', tendon='', contact='', cone='elliptic'):
    xml = f'''<mujoco><option cone="{cone}" jacobian="dense" iterations="1000"
      tolerance="1e-12" ls_iterations="100" noslip_iterations="0">
      <flag warmstart="disable" island="disable" eulerdamp="disable"/></option>
      <worldbody>{body}</worldbody>{tendon}{equality}{contact}</mujoco>'''
    return name, xml


def fixtures():
    for kind in ['connect', 'weld']:
        anchor = 'anchor="0 0 0"' if kind == 'connect' else ''
        yield fixture('slide_' + kind, '''<body name="slider" pos="0 0 2">
          <joint type="slide" axis="1 0 0"/><geom size=".1" mass="2"
          contype="0" conaffinity="0"/></body>''',
          f'<equality><{kind} body1="slider" {anchor}/></equality>')
    yield fixture('large_reference_slide', '''<body name="slider" pos="0 0 2">
      <joint type="slide" axis="1 0 0"/><geom size=".1" mass="2"
      contype="0" conaffinity="0"/></body>''',
      '<equality><connect body1="slider" anchor="0 0 0" solref="-1e12 -1"/></equality>')
    yield fixture('joint_equality', '''<body pos="0 0 2"><joint name="a" type="slide" axis="1 0 0"/>
      <geom size=".1" mass="2" contype="0" conaffinity="0"/>
      <body pos="0 0 .3"><joint name="b" type="slide" axis="0 1 0"/>
      <geom size=".1" mass="1" contype="0" conaffinity="0"/></body></body>''',
      '<equality><joint joint1="a" joint2="b" polycoef=".1 2 0 0 0"/></equality>')
    yield fixture('dof_tendon_friction', '''<body pos="0 0 2"><joint name="a" type="slide" axis="1 0 0" frictionloss="1"/>
      <geom size=".1" contype="0" conaffinity="0"/><body pos="0 0 .3">
      <joint name="b" type="slide" axis="0 1 0" frictionloss=".6"/>
      <geom size=".1" contype="0" conaffinity="0"/></body></body>''',
      tendon='<tendon><fixed frictionloss=".4"><joint joint="a" coef="1"/><joint joint="b" coef="2"/></fixed></tendon>')
    yield fixture('joint_limit', '''<body pos="0 0 2"><joint name="a" type="slide" axis="1 0 0" limited="true" range="-.05 .05"/>
      <geom size=".1" contype="0" conaffinity="0"/></body>''')
    for cone in ['pyramidal', 'elliptic']:
        for dim in [1, 3, 4, 6]:
            for motion in ['rest', 'slide', 'spin']:
                yield fixture(f'sphere_{cone}_{dim}_{motion}', f'''
                  <geom type="plane" size="2 2 .1" friction=".8 .02 .003" condim="{dim}"/>
                  <body pos="0 0 .08"><freejoint/><geom type="sphere" size=".1" mass="1"
                  friction=".8 .02 .003" condim="{dim}"/></body>''', cone=cone)
        yield fixture(f'box_{cone}', '''<geom type="plane" size="2 2 .1" friction=".7 .02 .003" condim="6"/>
          <body pos="0 0 .08"><freejoint/><geom type="box" size=".2 .15 .1" mass="2"
          friction=".7 .02 .003" condim="6"/></body>''', cone=cone)
        yield fixture(f'mixed_{cone}', '''<geom type="plane" size="2 2 .1"/>
          <body pos="0 0 .08"><joint name="z" type="slide" axis="0 0 1"/>
          <joint name="x" type="slide" axis="1 0 0" frictionloss=".7"/>
          <geom type="box" size=".2 .15 .1" mass="2"/>
          <body pos=".5 0 0"><joint name="y" type="slide" axis="0 1 0"/>
          <geom type="sphere" size=".07" mass=".4"/></body></body>''',
          equality='<equality><joint joint1="x" joint2="y" polycoef=".01 1 0 0 0"/></equality>', cone=cone)


def native_problem(name, xml, method, iterations=1000, tolerance=1e-12, seed=None, jacobian='dense'):
    m = mujoco.MjModel.from_xml_string(xml)
    m.opt.jacobian = 1 if jacobian == 'sparse' else 0
    m.opt.solver = method; m.opt.iterations = iterations; m.opt.tolerance = tolerance
    d = mujoco.MjData(m)
    if name == 'large_reference_slide':
        d.qpos[:] = .02
    elif 'slide' in name or 'box_' in name:
        d.qvel[:] = np.linspace(1.1, -.35, m.nv)
    elif 'spin' in name:
        d.qvel[3:] = [2., -1., 3.]
    elif name == 'joint_limit':
        d.qpos[0] = .08; d.qvel[0] = .1
    elif 'friction' in name:
        d.qvel[:] = [.02, -.05]; d.qfrc_applied[:] = [2., -1.]
    elif 'mixed' in name:
        d.qvel[:] = [.2, .3, -.2]
    elif 'equality' in name:
        d.qpos[:] = [.3, -.1]; d.qfrc_applied[:] = [1., -2.]
    if seed is not None:
        rng = np.random.default_rng(seed)
        d.qvel[:] = rng.uniform(-2., 2., m.nv)
        d.qfrc_applied[:] = rng.uniform(-5., 5., m.nv)
        m.opt.impratio = [0.1, 0.5, 2., 10.][seed % 4]
        name += f'-seed{seed}-impratio{m.opt.impratio}'
    mujoco.mj_forward(m, d)
    full_m = np.zeros((m.nv, m.nv))
    mujoco.mj_fullM(m, d, full_m)
    rows = []
    i = 0
    while i < d.nefc:
        typ = int(d.efc_type[i])
        kind = 0 if typ == 0 else 1 if typ in [1, 2] else 3 if typ == 7 else 2
        if kind == 3:
            con = d.contact[d.efc_id[i]]
            for t in range(con.dim):
                rows.append(row(3, con.dim if t == 0 else 0, d.efc_R[i+t],
                                d.efc_frictionloss[i+t], con.mu, con.friction))
                rows[-1][3] = d.efc_D[i+t]
            i += con.dim
        else:
            rows.append(row(kind, r=d.efc_R[i], bound=d.efc_frictionloss[i]))
            rows[-1][3] = d.efc_D[i]; i += 1
    jac = np.zeros((d.nefc, m.nv))
    if mujoco.mj_isSparse(m):
        for r in range(d.nefc):
            start, count = d.efc_J_rowadr[r], d.efc_J_rownnz[r]
            jac[r, d.efc_J_colind[start:start+count]] = d.efc_J[start:start+count]
    else:
        jac[:] = d.efc_J.reshape(d.nefc, m.nv)
    p = dict(name=name, method=method+(3 if jacobian == 'sparse' else 0), M=full_m, J=jac,
             free=d.qacc_smooth.copy(), ref=d.efc_aref.copy(), a0=d.qacc_smooth.copy(),
             f0=np.zeros(d.nefc), rows=rows, scale=1/(m.stat.meaninertia*max(1, m.nv)),
             iterations=iterations, tolerance=tolerance)
    return p, d.qacc.copy(), d.efc_force.copy(), int(d.solver_niter[0])


def analytic():
    for method in range(3):
        for kind, ref, bound, expected in [(0, 3., 0., 2.), (2, 3., 0., 2.),
                (2, -3., 0., 0.), (1, 3., .4, .4), (1, -3., .4, -.4), (1, .3, 1., .2)]:
            yield dict(name=f'analytic-{kind}-{ref}', method=method, M=[[1.]], J=[[1.]],
                       free=[0.], ref=[ref], a0=[0.], f0=[0.], rows=[row(kind, r=.5, bound=bound)]), expected


def certificate(p, a, f):
    """Independent convex primal/dual gap; bounds distance to the unique optimum.

    These are floating-point diagnostics, not interval-certified proofs.
    R > 0 makes the feasible dual objective strongly convex with modulus at
    least min(R). M > 0 gives the analogous primal acceleration bound. Scalar
    Fenchel terms are factored to avoid cancellation close to the solution.
    """
    LD = np.longdouble
    a = np.array(a, dtype=LD); f = np.array(f, dtype=LD)
    J = np.array(p['J'], dtype=LD); M = np.array(p['M'], dtype=LD)
    jar = J @ a - np.array(p['ref'], dtype=LD)
    da = a-np.array(p['free'], dtype=LD)
    imbalance = M @ da - J.T @ f
    gap = LD(.5) * imbalance @ np.linalg.solve(np.asarray(M, float), np.asarray(imbalance, float))
    cost = LD(.5) * da @ M @ da
    rmin = min((r[2] for r in p['rows']), default=1.)
    feasible = True
    i = 0
    while i < len(jar):
        kind, dim, r, d, bound, mu, *friction = p['rows'][i]
        dim = int(dim); r, d, bound, mu = map(LD, (r, d, bound, mu))
        x = jar[i]; v = f[i]
        if kind == 0 or (kind == 1 and -r*bound < x < r*bound) or (kind == 2 and x < 0):
            gap += LD(.5)*r*(v+d*x)**2; cost += LD(.5)*d*x*x
        elif kind == 1:
            if x <= -r*bound:
                gap += LD(.5)*r*(v-bound)**2+(v-bound)*(x+r*bound)
                cost += -LD(.5)*r*bound*bound-bound*x
            else:
                gap += LD(.5)*r*(v+bound)**2+(v+bound)*(x-r*bound)
                cost += -LD(.5)*r*bound*bound+bound*x
        elif kind == 2:
            gap += v*x+LD(.5)*r*v*v
        else:
            scales = np.array([mu, *friction[:dim-1]], dtype=LD)
            u = jar[i:i+dim]*scales; n=u[0]; t=np.sqrt(u[1:]@u[1:])
            rs=np.array([v[2] for v in p['rows'][i:i+dim]], dtype=LD)
            if n >= mu*t: c=LD(0)
            elif mu*n+t <= 0: c=LD(.5)*np.sum(jar[i:i+dim]**2/rs)
            else: c=LD(.5)*d/(mu*mu*(1+mu*mu))*(n-mu*t)**2
            block=f[i:i+dim]
            gap += c + block@jar[i:i+dim] + LD(.5)*np.sum(rs*block*block)
            cost += c
            feasible &= bool(block[0] >= -1e-10 and np.linalg.norm(block[1:]/scales[1:]) <= block[0]+1e-8)
        if kind == 1: feasible &= bool(abs(v) <= bound+1e-10)
        if kind == 2: feasible &= bool(v >= -1e-10)
        i += dim
    floor = 1e-12*max(1., abs(float(cost)))
    assert float(gap) >= -floor, float(gap)
    gap = max(0., float(gap))
    mmin = float(np.linalg.eigvalsh(np.asarray(M, float))[0])
    return dict(gap=gap, cost=float(cost), feasible=feasible,
                force_bound=float(np.sqrt(2*gap/rmin)), acceleration_bound=float(np.sqrt(2*gap/mmin)))


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--jacobian', choices=['dense', 'sparse'], default='dense'); args = ap.parse_args()
    assert mujoco.__version__ == '3.14.0', mujoco.__version__
    refs = [native_problem(name, xml, method, jacobian=args.jacobian) for name, xml in fixtures() for method in range(3)]
    # Fixed-work PGS exercises shuffle and momentum, independent of stopping.
    refs += [native_problem(name, xml, 0, iterations=7, tolerance=0, jacobian=args.jacobian)
             for name, xml in fixtures() if 'box_' in name or 'mixed' in name]
    refs += [native_problem(name, xml, method, seed=seed, jacobian=args.jacobian)
             for name, xml in fixtures() if 'box_' in name or 'mixed_' in name
             for method in range(3) for seed in range(8)]
    records, failures = [], []
    outputs = run(args.binary, [r[0] for r in refs])
    for (p, ca, cf, ci), o in zip(refs, outputs):
        ae = float(np.max(np.abs(o['a']-ca))); fe = float(np.max(np.abs(o['f']-cf), initial=0.))
        # Convergence criteria are cost-based in C: compare forces with a scale-aware tolerance.
        atol = 2e-7 + 1e-8 * float(np.max(np.abs(ca), initial=0.))
        ftol = 2e-7 + 1e-8 * float(np.max(np.abs(cf), initial=0.))
        ac = certificate(p, o['a'], o['f']); cc = certificate(p, ca, cf)
        strict = ae < atol and fe < ftol
        gap_checked = (ac['feasible'] and cc['feasible']
            and max(ac['gap'], cc['gap']) < max(1e-9, 100*p['tolerance']/p['scale'])
            and ae < atol + ac['acceleration_bound'] + cc['acceleration_bound']
            and fe < ftol + ac['force_bound'] + cc['force_bound'])
        passed = (strict or gap_checked) and ac['feasible'] and o['curvature_repairs'] == 0 and o['status'] in ['CONVERGED', 'ITERATION_LIMIT', 'STALLED']
        rec = dict(name=p['name'], method=p['method'], rows=len(p['ref']), dofs=len(p['free']),
                   status=o['status'], iterations=o['iterations'], c_iterations=ci,
                   line_search_limits=o['line_search_limits'], curvature_repairs=o['curvature_repairs'],
                   strict_match=bool(strict), gap_checked=bool(gap_checked), candidate_certificate=ac, c_certificate=cc,
                   acceleration_error=ae, force_error=fe, acceleration_tolerance=atol, force_tolerance=ftol, passed=bool(passed))
        records.append(rec)
        if not passed: failures.append(rec); print('FAIL', rec, flush=True)
    cases = list(analytic())
    for (p, expected), o in zip(cases, run(args.binary, [c[0] for c in cases])):
        passed = o['status'] == 'CONVERGED' and np.allclose(o['a'], expected, atol=1e-10, rtol=0) and np.allclose(o['f'], expected, atol=1e-10, rtol=0)
        rec = dict(name=p['name'], method=p['method'], passed=bool(passed), status=o['status'])
        records.append(rec)
        if not passed: failures.append(rec); print('FAIL', rec, o)
    # Invalid problem data and SPD rejection must be atomic.
    base = cases[0][0]
    rejects = [dict(base, name='indefinite', M=[[-1.]], a0=[.7], f0=[.8]),
               dict(base, name='below-minimum-regularization', rows=[row(0, r=1e-16)], a0=[.7], f0=[.8]),
               dict(base, name='bad-reciprocal', rows=[[0, 1, .1, .1, 0, 1, 1, 1, 1, 1, 1]], a0=[.7], f0=[.8]),
               dict(base, name='truncated-cone', rows=[row(3, 3)], a0=[.7], f0=[.8])]
    for p, o in zip(rejects, run(args.binary, rejects)):
        expected = 'NOT_POSITIVE_DEFINITE' if p['name'] == 'indefinite' else 'INVALID_INPUT'
        passed = o['status'] == expected and np.array_equal(o['a'], p['a0']) and np.array_equal(o['f'], p['f0'])
        rec = dict(name=p['name'], passed=bool(passed), status=o['status']); records.append(rec)
        if not passed: failures.append(rec)
    # Zero constraints, zero iteration budgets, and non-progressing line searches.
    empty = [dict(base, name='empty', method=method, J=np.zeros((0, 1)), ref=[],
                  a0=[7.], f0=[], rows=[]) for method in range(3)]
    budgets = [dict(base, name='zero-budget', method=method, iterations=0) for method in range(3)]
    for p, o in zip(empty+budgets, run(args.binary, empty+budgets)):
        passed = (o['status'] == 'CONVERGED' and o['a'][0] == 0.) if p['name'] == 'empty' else (o['status'] == 'ITERATION_LIMIT' and o['iterations'] == 0 and o['a'][0] == 0.)
        rec = dict(name=p['name'], method=p['method'], passed=bool(passed), status=o['status']); records.append(rec)
        if not passed: failures.append(rec)
    # Repeatability and warm starts on every native fixture and algorithm.
    warm = [dict(p, a0=o['a'], f0=o['f'], repeat=2) for (p, *_), o in zip(refs, outputs) if p['tolerance'] > 0]
    for p, o in zip(warm, run(args.binary, warm)):
        passed = o['status'] in ['CONVERGED', 'STALLED'] and np.allclose(o['a'], p['a0'], atol=2e-5, rtol=1e-6)
        rec = dict(name=p['name']+'-warm', method=p['method'], passed=bool(passed), status=o['status']); records.append(rec)
        if not passed: failures.append(rec); print('FAIL', rec)
    result = dict(mujoco=mujoco.__version__, jacobian=args.jacobian,
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  total=len(records), passed=len(records)-len(failures), failures=failures, results=records)
    args.out.parent.mkdir(parents=True, exist_ok=True); args.out.write_text(json.dumps(result, indent=2)+'\n')
    print(f"{result['passed']}/{result['total']} passed")
    raise SystemExit(bool(failures))

if __name__ == '__main__': main()
