#!/usr/bin/env python3
"""Checked/release Ada vs MuJoCo 3.14.0, using native assembled AR and b.

No C solver is used by the Ada implementation. C is only the test oracle.
"""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import numpy as np
import mujoco
from evidence import ROOT, freeze, environment, digest, unchanged, versions

ap = argparse.ArgumentParser()
ap.add_argument('--out', type=Path, required=True)
ap.add_argument('--mode', choices=['validation', 'release'], default='validation')
args = ap.parse_args()
out = args.out.resolve()
snapshot, manifest = freeze(out)
env = environment(out)
env['FRICTION_MODE'] = args.mode
assert mujoco.__version__ == '3.14.0', 'the reference version must be re-reviewed'
cmd = ['gprbuild', '-p', '-P', str(snapshot / 'friction.gpr'), '-j1']
p = subprocess.run(cmd, cwd=ROOT, env=env, text=True, capture_output=True)
(out / 'build.log').write_text(p.stdout + p.stderr)
p.check_returncode()
probe = out / 'build' / args.mode / 'bin/friction_probe'
libpath = Path(mujoco.__file__).parent / 'libmujoco.so.3.14.0'
solver_path = ROOT / 'mujoco/src/engine/engine_solver.c'
source = solver_path.read_text()

def extract(name):
    start = source.index('static ', source.index(name) - 30)
    brace = source.index('{', start)
    depth = 1
    end = brace + 1
    while depth:
        depth += (source[end] == '{') - (source[end] == '}')
        end += 1
    return source[start:end]

# Extract the original routines, including the otherwise unused vector branch.
oracle = out / 'oracle.c'
oracle.write_text('#include <stdint.h>\n#include <mujoco/mujoco.h>\n'
    + extract('costChange(') + '\n'
    + 'typedef struct {uint64_t state; uint64_t inc;} pcg32_state;\n'
    + extract('pcg32_next(') + '\n'
    + '''
uint32_t rng_next(uint64_t* state) {
  pcg32_state rng = {*state, 1};
  uint32_t out = pcg32_next(&rng); *state = rng.state; return out;
}
void scalar_step(int kind, double old, double res, double inv, double bound,
                 double* accepted, double* force, double* change) {
  *force = old - res*inv;
  if (kind == 1) {
    if (*force < -bound) *force = -bound;
    else if (*force > bound) *force = bound;
  } else if (kind == 2 && *force < 0) *force = 0;
  *accepted = (*force >= -1e20 && *force <= 1e20);
  if (!*accepted) { *force = old; *change = 0; return; }
  double A = 1/inv;
  *change = costChange(&A, force, &old, &res, 1);
}
''')
compile_cmd = ['gcc', '-shared', '-fPIC', '-O3', '-ffp-contract=off',
               '-I' + str(ROOT / 'mujoco/include'), str(oracle), str(libpath),
               '-Wl,-rpath,' + str(libpath.parent), '-o', str(out / 'oracle.so')]
subprocess.run(compile_cmd, check=True, capture_output=True)
native = ctypes.CDLL(str(out / 'oracle.so'))
engine = ctypes.CDLL(str(libpath))
double = ctypes.c_double
pointer = ctypes.POINTER(double)
for name in ('mju_encodePyramid', 'mju_decodePyramid'):
    getattr(engine, name).argtypes = [pointer, pointer, pointer, ctypes.c_int]

def encode(p, f, mu, dim):
    engine.mju_encodePyramid(p.ctypes.data_as(pointer), f.ctypes.data_as(pointer),
                             mu.ctypes.data_as(pointer), dim)

def decode(f, p, mu, dim):
    engine.mju_decodePyramid(f.ctypes.data_as(pointer), p.ctypes.data_as(pointer),
                             mu.ctypes.data_as(pointer), dim)
native.scalar_step.argtypes = [ctypes.c_int, double, double, double, double, pointer, pointer, pointer]
native.rng_next.argtypes = [ctypes.POINTER(ctypes.c_uint64)]
native.rng_next.restype = ctypes.c_uint32
records = []
inputs = []
expectations = []
rng = np.random.default_rng(3140101)

def add(name, values, expected, exact=True, meta=None):
    inputs.append(' '.join(format(float(x), '.17g') for x in values))
    expectations.append((name, np.asarray(expected, dtype=np.float64).copy(), exact, meta))

for dim in (3, 4, 6):
    for n in range(160):
        mu = 10.0 ** rng.uniform(-5, 3, size=5)
        f = rng.normal(size=6) * 10.0 ** rng.uniform(-9, 9)
        if n == 0:
            f[:] = -0.0
        p = np.zeros(10)
        encode(p, f, mu, dim)
        add('encode-' + str(dim), [1, dim, *mu, *f], p)
        edges = rng.normal(size=10) * 10.0 ** rng.uniform(-8, 15)
        if n == 0:
            edges[:] = -0.0
        decoded = np.zeros(6)
        decode(decoded, edges, mu, dim)
        add('decode-' + str(dim), [2, dim, *mu, *edges], decoded)
        # Nonnegative pyramid coordinates must obey the polyhedral cone within
        # rounding tolerance; this is a test, not a real-arithmetic proof.
        positive = abs(edges)
        decode(decoded, positive, mu, dim)
        assert np.sum(abs(decoded[1:dim] / mu[:dim - 1])) <= decoded[0] * (1 + 1e-14)
        add('decode-positive-' + str(dim), [2, dim, *mu, *positive], decoded)
mu = np.ones(5)
for f in ([2, 0, 0, 0, 0, 0], [-0.0, 0, 0, 0, 0, 0]):
    add('frictionless-encode-extension', [1, 1, *mu, *f], [f[0], *([0] * 9)])
    add('frictionless-decode', [2, 1, *mu, f[0], *([0] * 9)], f)
state = ctypes.c_uint64(0)
random_values = [native.rng_next(ctypes.byref(state)) for _ in range(1024)]
add('pcg32-original-C', [4, 1024], random_values)
for kind in (0, 1, 2):
    for n in range(180):
        old, res = rng.normal(size=2) * 10.0 ** rng.uniform(-8, 15)
        inv = 10.0 ** rng.uniform(-20, 20)
        bound = 10.0 ** rng.uniform(-8, 18)
        accepted, f, change = double(), double(), double()
        native.scalar_step(kind, old, res, inv, bound,
                           ctypes.byref(accepted), ctypes.byref(f), ctypes.byref(change))
        add('scalar-step-' + str(kind), [3, kind, old, res, inv, bound],
            [accepted.value, f.value, change.value])

def add_solve(name, ar, b, kinds, loss, force, expected, iterations=100,
              tolerance=1e-10, scale=1.0, nesterov=True, status=None, native_iterations=None, exact=False):
    n = len(b)
    values = [5, n, iterations, tolerance, scale, int(nesterov),
              *kinds, *loss, *b, *force, *np.asarray(ar).ravel()]
    add(name, values, expected, exact=exact,
        meta=dict(status=status, iterations=native_iterations, rows=n))

# Scalar and failure paths; errors must preserve the initial force.
add_solve('empty', np.empty((0, 0)), [], [], [], [], [], status=0, native_iterations=0)
add_solve('joint-friction-saturation', [[2]], [-4], [1], [.3], [0], [.3])
add_solve('unilateral-inactive', [[2]], [4], [2], [0], [0], [0])
add_solve('equality-signed', [[2]], [4], [0], [0], [0], [-2])
add_solve('invalid-diagonal', [[0]], [-4], [2], [0], [2], [2], status=2)
add_solve('invalid-AR', [[float('inf')]], [-4], [2], [0], [2], [2], status=2)
# Infinity cannot be read by Ada Text_IO: use a finite, out-of-domain coefficient.
inputs[-1] = inputs[-1].replace('inf', '1e100')
add_solve('invalid-initial-feasibility', [[1]], [-4], [2], [0], [-2], [-2], status=2)
add_solve('numeric-limit-preserves-input', [[1e-20]], [-1e20], [0], [0], [3], [3], status=3)
add_solve('zero-iteration-preserves-warmstart', [[1]], [-4], [2], [0], [2], [2], iterations=0, status=1)
# A coupled system with analytic constrained solution and feasible warm start.
add_solve('coupled-dry-contact', [[2, .2], [.2, 1]], [-3, -2], [1, 2], [.5, 0], [0, 0], [.5, 1.9])
add_solve('coupled-no-momentum', [[2, .2], [.2, 1]], [-3, -2], [1, 2], [.5, 0], [.1, .1], [.5, 1.9], nesterov=False)

# Reduction remainders and the supported row-capacity boundary.
for n in (1, 2, 3, 4, 5, 6, 7, 255, 256):
    solution = np.linspace(.1, 2, n)
    add_solve('diagonal-boundary-' + str(n), np.eye(n), -solution,
              np.full(n, 2), np.zeros(n), np.zeros(n), solution, exact=True)
add_solve('row-capacity-rejection', np.eye(257), np.zeros(257), np.full(257, 2),
          np.zeros(257), np.ones(257), np.ones(257), status=2, exact=True)

def xml(dim, shape, dry=False, equality=False):
    joint = ('<body pos=".8 0 .2"><joint type="slide" axis="1 0 0" frictionloss=".7"/>'
             '<geom type="sphere" size=".03" mass=".2" contype="0" conaffinity="0"/></body>' if dry else '')
    eq = '<equality><connect body1="contact" anchor="0 0 .095"/></equality>' if equality else ''
    geom = ('type="sphere" size=".1"' if shape == 'sphere' else 'type="box" size=".1 .08 .1"')
    return ('<mujoco><option solver="PGS" cone="pyramidal" jacobian="dense" iterations="100" tolerance="1e-10">'
            '<flag warmstart="disable" island="disable"/></option><worldbody><geom type="plane" size="2 2 .1"/>'
            '<body name="contact" pos="0 0 .095"><freejoint/><geom ' + geom + ' mass="1" condim="' + str(dim) +
            '" friction=".8 .02 .003"/></body>' + joint + '</worldbody>' + eq + '</mujoco>')

native_cases = []
for dim in (3, 4, 6):
    for shape in ('sphere', 'box'):
        for dry, equality in ((False, False), (True, False), (True, True)):
            for limit in (1, 2, 5, 25, 100):
                m = mujoco.MjModel.from_xml_string(xml(dim, shape, dry, equality))
                m.opt.iterations = limit
                d = mujoco.MjData(m)
                d.qvel[:6] = [.3, -.2, -.1, .1, -.2, .3]
                if dry:
                    d.qvel[-1] = .2
                    d.qfrc_applied[-1] = .4
                mujoco.mj_forward(m, d)
                assert d.nefc and np.all(d.efc_type != 7), 'no elliptic rows supported'
                kinds = np.where(d.efc_type == 0, 0, np.where(np.isin(d.efc_type, [1, 2]), 1, 2))
                scale = 1 / (m.stat.meaninertia * max(1, m.nv))
                name = f'native-C-dim{dim}-{shape}-dry{dry}-eq{equality}-iter{limit}'
                add_solve(name, d.efc_AR.reshape(d.nefc, d.nefc), d.efc_b,
                          kinds, d.efc_frictionloss, np.zeros(d.nefc), d.efc_force.copy(),
                          iterations=limit, scale=scale, native_iterations=int(d.solver_niter[0]), exact=True)
                native_cases.append(dict(name=name, rows=d.nefc, contacts=d.ncon,
                                         iterations=int(d.solver_niter[0])))

payload = '\n'.join(inputs) + '\n'
(out / 'inputs.txt').write_text(payload)
p = subprocess.run([str(probe)], input=payload, text=True, capture_output=True)
(out / 'probe.stdout').write_text(p.stdout)
(out / 'probe.stderr').write_text(p.stderr)
p.check_returncode()
lines = p.stdout.splitlines()
assert len(lines) == len(expectations), (len(lines), len(expectations))
worst = 0.0
for line, (name, expected, exact, meta) in zip(lines, expectations):
    actual = np.fromstring(line, sep=' ')
    if meta is not None:
        status, iters, restarts, improvement = actual[:4]
        actual = actual[4:]
        if meta['status'] is not None:
            assert status == meta['status'], (name, status, meta)
        else:
            assert status in (0, 1), (name, status)
        if meta['iterations'] is not None:
            assert iters == meta['iterations'], (name, iters, meta)
        assert np.isfinite(improvement)
    assert actual.shape == expected.shape, (name, actual.shape, expected.shape)
    if exact:
        assert np.array_equal(actual.view(np.uint64), expected.view(np.uint64)), (name, actual, expected)
    else:
        error = np.max(abs(actual - expected) / (1 + abs(expected)), initial=0.0)
        worst = max(worst, float(error))
        assert np.allclose(actual, expected, rtol=2e-10, atol=2e-10), (name, error, actual, expected)
    records.append(dict(name=name, passed=True, exact=exact))
assert unchanged(manifest), 'candidate changed during checks'
receipt = dict(passed=True, cases=len(records), mode=args.mode,
               native_solver_cases=native_cases, max_scaled_force_error=worst,
               sources=manifest, versions=versions(env), mujoco=mujoco.__version__,
               native_library_sha256=digest(libpath), solver_source_sha256=digest(solver_path),
               oracle_source_sha256=digest(oracle), commands=[cmd, compile_cmd],
               cases_detail=records)
(out / 'results.json').write_text(json.dumps(receipt, indent=2) + '\n')
print(json.dumps({k: receipt[k] for k in ('passed', 'cases', 'mode', 'max_scaled_force_error')}))
