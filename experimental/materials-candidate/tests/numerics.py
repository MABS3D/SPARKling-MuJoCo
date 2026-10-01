#!/usr/bin/env python3
"""Material algebra plus real MuJoCo-compiled flexes and generated contacts."""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import mujoco
import numpy as np
from reference import build

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
SEED = 3140930

def numbers(values):
    return ' '.join(format(float(x), '.17g') for x in values)

def run(binary, inputs):
    p = subprocess.run([str(binary)], input='\n'.join(inputs)+'\n',
                       capture_output=True, text=True, check=True, timeout=120)
    assert len(p.stdout.splitlines()) == len(inputs), p.stderr[-2000:]
    return p.stdout

def surface(rng, kind=0):
    return [kind, int(rng.integers(-2, 3)), int(rng.choice([1, 3, 4, 6])),
        float(rng.choice([0., 1e-16, 1e-15, 0.2, 1., 10.])),
        *rng.uniform(-10, 10, 2), *rng.uniform(-10, 10, 5),
        *rng.uniform(0, 3, 3), float(rng.choice([0., 0.5, 2.])),
        float(rng.uniform(-0.1, 0.1)), float(rng.uniform(0, 0.1))]

def pair(rng, enabled):
    return [enabled, int(rng.choice([1, 3, 4, 6])), *rng.uniform(-10, 10, 2),
            *rng.choice([0., -0., 0.2, -3.], 2), *rng.uniform(0, 1, 5),
            *rng.uniform(-1, 3, 5), float(rng.choice([0., 0.7])), 0.03, 0.01]

def override(rng, enabled):
    return [enabled, *rng.uniform(-10, 10, 2), *rng.uniform(0, 1, 5),
            *rng.uniform(-1, 3, 5), 0.04]

def engine_contacts(out):
    inputs, expected, labels = [], [], []
    for i in range(96):
        explicit, over = bool(i % 2), bool((i//2) % 2)
        dist = [-0.02, 0.0, 0.005, 0.009][(i//4) % 4]
        xml = '<mujoco><worldbody><geom name="plane" type="plane" size="1 1 .1"/><body><freejoint/><geom name="sphere" size=".1" mass="1"/></body></worldbody>'
        if explicit:
            xml += '<contact><pair geom1="plane" geom2="sphere" condim="6"/></contact>'
        xml += '</mujoco>'
        m = mujoco.MjModel.from_xml_string(xml)
        m.geom_priority[:] = [i % 3, (i//3) % 3]
        m.geom_condim[:] = [[1, 3, 4, 6][i % 4], [6, 4, 3, 1][i % 4]]
        m.geom_solmix[:] = [[0., 0.2, 1.][i % 3], [1., 0., 2.][i % 3]]
        m.geom_solref[:] = [[0.02, 1.3], [-1100, -30] if i % 3 == 0 else [0.08, 0.7]]
        m.geom_solimp[:] = [[0.3, 0.8, 0.01, 0.4, 2.], [0.6, 0.9, 0.02, 0.6, 3.]]
        m.geom_friction[:] = [[0., 0.004, 0.002], [0.8, 0.002, 0.0002]]
        m.geom_adhesion[:] = [0.25 if i % 5 == 0 else 0., 0.]
        m.geom_margin[:] = [0.005, 0.003]
        m.geom_gap[:] = [0.001, 0.002]
        p = pair(np.random.default_rng(i), False)
        if explicit:
            m.pair_dim[0] = [1, 3, 4, 6][i % 4]
            m.pair_solref[0] = [-2000, -50] if i % 3 == 0 else [0.04, 0.9]
            m.pair_solreffriction[0] = [0., -0.] if i % 3 == 0 else [-500, -20]
            m.pair_solimp[0] = [0.4, 0.7, 0.01, 0.6, 2.]
            m.pair_friction[0] = [0.2, 0.7, 0.003, 0.002, 0.0001]
            m.pair_adhesion[0] = 0.4 if i % 5 == 0 else 0.
            m.pair_margin[0] = 0.007
            m.pair_gap[0] = 0.01
            p = [1, m.pair_dim[0], *m.pair_solref[0], *m.pair_solreffriction[0],
                 *m.pair_solimp[0], *m.pair_friction[0], m.pair_adhesion[0],
                 m.pair_margin[0], m.pair_gap[0]]
        m.opt.o_solref[:] = [0.07, 0.6]
        m.opt.o_solimp[:] = [0.5, 0.7, 0.01, 0.5, 2.]
        m.opt.o_friction[:] = [0., 0.3, 0.001, 0.002, 0.003]
        m.opt.o_margin = 0.012
        if over: m.opt.enableflags |= int(mujoco.mjtEnableBit.mjENBL_OVERRIDE)
        d = mujoco.MjData(m)
        d.qpos[2] = 0.1 + dist
        mujoco.mj_kinematics(m, d)
        mujoco.mj_collision(m, d)
        assert d.ncon == 1, (i, d.ncon)
        con = d.contact[0]
        a = [[0, m.geom_priority[g], m.geom_condim[g], m.geom_solmix[g],
              *m.geom_solref[g], *m.geom_solimp[g], *m.geom_friction[g],
              m.geom_adhesion[g], m.geom_margin[g], m.geom_gap[g]] for g in [0, 1]]
        o = [over, *m.opt.o_solref, *m.opt.o_solimp, *m.opt.o_friction, m.opt.o_margin]
        inputs.append(numbers([2, *a[0], *a[1], *p, *o, con.dist, 0]))
        expected.append([con.dim, *con.solref, *con.solreffriction,
                         *con.solimp, *con.friction, con.adhesion,
                         con.includemargin,
                         m.pair_gap[0] if explicit else sum(m.geom_gap), con.exclude])
        labels.append(dict(case=i, pair=explicit, override=over, distance=float(con.dist)))
    (out/'engine-contact-cases.json').write_text(json.dumps(labels, indent=2)+'\n')
    return inputs, np.asarray(expected)

def compiled_flexes(reference, out):
    inputs, expected, labels = [], [], []
    for dim in [2, 3]:
        positions = [(0., 0., 0.), (1., 0., 0.), (0., 1., 0.)]
        if dim == 3: positions.append((0., 0., 1.))
        flat = [x for p in positions for x in p] + ([0., 0., 0.] if dim == 2 else [])
        geometry = np.fromstring(run(reference, [numbers([3, dim-2, *flat])]), sep=' ')
        for young in [1., 1e3, 1e6, 2e11]:
            for nu in [0., 0.1, 0.3, 0.49]:
                thickness = 0.03
                bodies = ''.join(f'<body name="v{i}" pos="{numbers(p)}"><freejoint/><geom size=".01" mass="1" contype="0" conaffinity="0"/></body>' for i, p in enumerate(positions))
                mode = 'stretch' if dim == 2 else 'none'
                xml = f'<mujoco><worldbody>{bodies}</worldbody><deformable><flex name="f" dim="{dim}" body="'+ ' '.join(f'v{i}' for i in range(len(positions)))+'" vertex="'+' '.join('0 0 0' for _ in positions)+'" element="'+' '.join(str(i) for i in range(len(positions)))+f'"><elasticity young="{young}" poisson="{nu}" thickness="{thickness}" elastic2d="{mode}"/></flex></deformable></mujoco>'
                m = mujoco.MjModel.from_xml_string(xml)
                assert m.flex_stiffness.shape == (21,)
                inputs.append(numbers([1, dim-2, young, nu, thickness, 0., geometry[0],
                                       0.001, 1., 1., 0., 1, 1, *geometry[1:]]))
                expected.append(m.flex_stiffness.copy())
                labels.append(dict(dim=dim, young=young, poisson=nu))
                (out/f'flex-{len(labels):02}.xml').write_text(xml)
    (out/'compiled-flex-cases.json').write_text(json.dumps(labels, indent=2)+'\n')
    return inputs, np.asarray(expected)

def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    reference = build(out/'reference')
    rng = np.random.default_rng(SEED)
    inputs = []
    for i in range(1536):
        young = float(rng.choice([0., 1., 1e6, 2e11, 1e15]))
        nu = float(rng.choice([0., 0.3, 0.49, np.nextafter(0.5, 0.)]))
        thick = float(rng.choice([0., 0.001, 1., 1e10]))
        rayleigh = float(rng.choice([0., 0.01, 1e10]))
        h = float(rng.choice([0., 1e-15, 0.001, 1.]))
        basis = rng.uniform(-1, 1, (6, 9)) * float(rng.choice([1e-10, 1., 1e10]))
        measure = float(rng.choice([-1e30, -1., 0., 0.5, 1e30]))
        length, rest = rng.uniform(0, 1e10, 2)
        velocity = float(rng.choice([0., -1e10, 0.3, 1e10]))
        inputs.append(numbers([1, i % 2, young, nu, thick, rayleigh, measure, h,
            length, rest, velocity, i % 3 != 0, i % 5 != 0, *basis.ravel()]))
    for i in range(1536):
        kinds = [int(rng.integers(0, 2)), int(rng.integers(0, 2))]
        a, b = [surface(rng, k) for k in kinds]
        a[3], b[3] = [0., 1e-16, 1e-15, 1., 1e10, -1.][i % 6], [1e10, 1., 1e-15, 1e-16, 0., -1.][i % 6]
        p = pair(rng, i % 3 == 0 and kinds == [0, 0])
        o = override(rng, i % 4 == 0)
        inputs.append(numbers([2, *a, *b, *p, *o, float(rng.uniform(-0.2, 0.2)),
                               kinds == [1, 1] and i % 2 == 0]))
    manifest = args.binary.resolve().parents[3]/'sources.json'
    source_hashes = json.loads(manifest.read_text())
    for rel, expected_hash in source_hashes.items():
        assert hashlib.sha256((ROOT/rel).read_bytes()).hexdigest() == expected_hash, rel
    raw_c = run(reference, inputs)
    raw_ada = run(args.binary, inputs)
    (out/'input.txt').write_text('\n'.join(inputs)+'\n')
    (out/'c-output.txt').write_text(raw_c)
    (out/'ada-output.txt').write_text(raw_ada)
    values, identical, bits_identical, max_scaled = 0, 0, 0, 0.
    for i, (a, b) in enumerate(zip(raw_ada.splitlines(), raw_c.splitlines())):
        aa, bb = np.fromstring(a, sep=' '), np.fromstring(b, sep=' ')
        assert aa.shape == bb.shape and aa.size, (i, a)
        assert np.array_equal(aa, bb), (i, aa-bb)
        values += aa.size
        identical += int(np.count_nonzero(aa == bb))
        bits_identical += int(np.count_nonzero(aa.view(np.uint64) == bb.view(np.uint64)))
        max_scaled = max(max_scaled, float(np.max(np.abs(aa-bb)/(1+np.abs(bb)))))
    # Compare signed-zero ties explicitly after changing comparison lowering.
    ties = []
    for i, line in enumerate(inputs[1536:1600]):
        row = line.split()
        row[1] = row[18] = row[2] = row[19] = '0'
        row[4] = row[21] = '1'
        row[35] = row[54] = row[-1] = '0'
        for k in [5, 6, 22, 23, 12, 13, 14, 29, 30, 31]:
            row[k] = '-0' if (i >> (k % 4)) % 2 else '0'
        ties.append(' '.join(row))
    ties_c, ties_ada = run(reference, ties), run(args.binary, ties)
    tc = np.asarray([np.fromstring(s, sep=' ') for s in ties_c.splitlines()])
    ta = np.asarray([np.fromstring(s, sep=' ') for s in ties_ada.splitlines()])
    assert np.array_equal(ta.view(np.uint64), tc.view(np.uint64))
    (out/'signed-zero-input.txt').write_text('\n'.join(ties)+'\n')
    (out/'signed-zero-c.txt').write_text(ties_c)
    (out/'signed-zero-ada.txt').write_text(ties_ada)
    ci, ce = engine_contacts(out)
    contact_output = run(args.binary, ci)
    (out/'engine-contact-output.txt').write_text(contact_output)
    cr = np.asarray([np.fromstring(s, sep=' ')[16:] for s in contact_output.splitlines()])
    assert cr.shape == ce.shape, (cr.shape, ce.shape)
    assert np.array_equal(cr, ce), np.max(np.abs(cr-ce))
    fi, fe = compiled_flexes(reference, out)
    flex_output = run(args.binary, fi)
    (out/'compiled-flex-output.txt').write_text(flex_output)
    fr = np.asarray([np.fromstring(s, sep=' ')[10:] for s in flex_output.splitlines()])
    assert np.array_equal(fr, fe), np.max(np.abs(fr-fe))
    (out/'engine-contact-input.txt').write_text('\n'.join(ci)+'\n')
    (out/'engine-contact-expected.json').write_text(json.dumps(ce.tolist())+'\n')
    (out/'compiled-flex-input.txt').write_text('\n'.join(fi)+'\n')
    (out/'compiled-flex-expected.json').write_text(json.dumps(fe.tolist())+'\n')
    # Rejections are Ada domain/precondition tests, not alleged C equivalence.
    base = list(map(float, inputs[0].split()))
    rejects = []
    for index, value in [(2, -1.), (2, 1e16), (3, -0.1), (3, 0.5), (4, -1.),
                         (5, -1.), (6, 1e31), (7, -1.), (7, 1e-20)]:
        row = base.copy(); row[index] = value; row[11] = 1.
        rejects.append(numbers(row))
    # Release trusts the typed caller; foreign-input rejection is checked-only.
    is_checked = '/release/' not in str(args.binary)
    rejection_count = 0
    if is_checked:
        result = run(args.binary, rejects).splitlines()
        assert result == ['REJECTED']*len(rejects), result
        rejection_count = len(rejects)
    summary = dict(passed=True, seed=SEED, oracle=mujoco.__version__,
        algebra_cases=len(inputs), algebra_values=values, equal_values=identical,
        bit_identical_values=bits_identical, max_scaled_error=max_scaled,
        real_engine_contacts=len(ci), real_compiled_flexes=len(fi),
        checked_rejections=rejection_count, signed_zero_cases=len(ties),
        source_hashes=source_hashes,
        harness_hashes={p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (HERE/'tests').glob('*.py')},
        evidence_hashes={str(p.relative_to(out)): hashlib.sha256(p.read_bytes()).hexdigest() for p in out.rglob('*') if p.is_file()},
        binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest())
    (out/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
    print(json.dumps(summary, indent=2))

if __name__ == '__main__':
    main()
