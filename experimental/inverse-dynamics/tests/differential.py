"""Independent mj_inverse oracle, arbitrary qacc, forward/inverse round trips."""
import argparse, hashlib, importlib.util, json, os, shutil, subprocess, sys
from pathlib import Path
import mujoco
import numpy as np

ROOT = Path(__file__).resolve().parents[3]

def module(path, name):
    spec = importlib.util.spec_from_file_location(name, path)
    value = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(value)
    return value

def fixtures(out):
    providers = {}
    for relative, name in [('experimental/smooth/tools/compare_numerics.py', 'inverse_smooth_fixtures'),
                           ('experimental/smooth/tools/prove_fragments.py', 'fixture_import_dependency'),
                           ('experimental/smooth/tools/test_actuation_integration.py', 'inverse_force_fixtures'),
                           ('experimental/constrained-step/tests/compare.py', 'inverse_contact_fixtures'),
                           ('experimental/adhesion-contact-integration/tests/compare_adhesion.py', 'inverse_adhesion_fixtures')]:
        path = ROOT / relative
        data = path.read_bytes()
        target = out / 'providers' / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        providers[relative] = hashlib.sha256(data).hexdigest()
    sys.path.insert(0, str(out / 'providers/experimental/smooth/tools'))
    simple = module(out / 'providers/experimental/smooth/tools/compare_numerics.py', 'inverse_simple')
    mixed = module(out / 'providers/experimental/smooth/tools/test_actuation_integration.py', 'inverse_mixed')
    contacts = module(out / 'providers/experimental/constrained-step/tests/compare.py', 'inverse_contacts')
    (out / 'providers.json').write_text(json.dumps(providers, indent=2) + '\n')
    for name, xml in simple.fixtures().items():
        yield 'smooth-' + name, xml, False
    for folder in ['experimental/smooth/tests/manifold-fixtures', 'experimental/smooth/tests/tendon-fixtures']:
        for path in sorted((ROOT / folder).glob('*.xml')):
            yield 'smooth-' + path.parent.name + '-' + path.stem, path.read_text(), False
    # Joint type, activation kind, early/control flags, mixed fixed/spatial paths,
    # and both fluid models. The corpus intentionally includes stateless motors.
    for fluid in ['none', 'box', 'ellipsoid']:
        for name, xml in mixed.fixtures(fluid=fluid, fixed=True):
            yield 'smooth-mixed-' + fluid + '-' + name, xml, False
    for name, xml in contacts.fixtures():
        yield 'constraint-' + name, xml, True
    adhesion = module(out / 'providers/experimental/adhesion-contact-integration/tests/compare_adhesion.py', 'inverse_adhesion')
    for name, xml in adhesion.fixtures():
        yield 'constraint-adhesion-' + name, xml, True

def parse(text):
    lines = text.splitlines()
    if not lines or lines[0] != 'create SUCCESS':
        raise ValueError(text[-2000:])
    result = []
    for line in lines[1:]:
        if not line:
            continue
        key, _, values = line.partition(' ')
        if key == 'inverse':
            result.append({})
        if key not in ('inverse', 'roundtrip', 'rows'):
            raise ValueError(text[-2000:])
        result[-1][key] = np.fromstring(values, sep=' ')
    return result

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--samples', type=int, default=4)
    parser.add_argument('--only')
    parser.add_argument('--corpus', type=Path, help='Replay an archived XML corpus in its recorded order')
    args = parser.parse_args()
    binary = args.binary.resolve()
    out = args.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    os.chdir(out)  # MuJoCo's optional compilation log belongs to this run.
    assert mujoco.__version__ == '3.14.0'
    rng = np.random.default_rng(20261002)
    records, failures = [], []
    scenarios = comparisons = 0
    if args.corpus:
        corpus = args.corpus.resolve()
        old = json.loads((corpus / 'summary.json').read_text())
        sources = ((r['model'], (corpus / (r['model'] + '.xml')).read_text(),
                    r['model'].startswith('constraint-')) for r in old['records'])
        (out / 'corpus.json').write_text(json.dumps(dict(origin=str(corpus),
            files={r['model']: hashlib.sha256((corpus/(r['model']+'.xml')).read_bytes()).hexdigest()
                   for r in old['records']}), indent=2) + '\n')
    else:
        sources = fixtures(out)
    for name, xml, constrained in sources:
        if args.only and args.only not in name:
            continue
        m = mujoco.MjModel.from_xml_string(xml)
        path = out / (name + '.mjb')
        mujoco.mj_saveModel(m, str(path))
        (out / (name + '.xml')).write_text(xml)
        requests, expected = [], []
        for sample in range(args.samples):
            d = mujoco.MjData(m)
            mujoco.mj_integratePos(m, d.qpos, rng.uniform(-1, 1, m.nv), .004)
            if 'ball_limit' in name:
                d.qpos[:] = [np.cos(.11), 0, np.sin(.11), 0]
            if 'hinge_contact' in name:
                d.qpos[:] = .11
            d.qvel[:] = rng.uniform(-.15, .15, m.nv)
            d.ctrl[:] = rng.uniform(-.2, .8, m.nu)
            d.qfrc_applied[:] = rng.uniform(-.1, .1, m.nv)
            d.act[:] = rng.uniform(0, .5, m.na)
            d.xfrc_applied[1:] = rng.uniform(-.05, .05, (m.nbody - 1, 6))
            acceleration = np.zeros(m.nv) if sample == 0 else rng.uniform(-30, 30, m.nv)
            requests.append(np.r_[d.qpos, d.qvel, acceleration, d.ctrl, d.qfrc_applied,
                                  d.act, d.xfrc_applied.ravel()])
            mujoco.mj_forward(m, d)
            forward_acc = d.qacc.copy()
            mujoco.mj_inverse(m, d)
            want = {'roundtrip': d.qfrc_inverse.copy()}
            d.qacc[:] = acceleration
            mujoco.mj_inverse(m, d)
            assert np.array_equal(d.qacc, acceleration), name
            want['inverse'] = d.qfrc_inverse.copy()
            if constrained:
                want['rows'] = d.efc_force.copy()
            expected.append(want)
        data = str(len(requests)) + '\n' + '\n'.join(' '.join(format(x, '.17g') for x in r)
                                                     for r in requests) + '\n'
        (out / (name + '.input')).write_text(data)
        run = subprocess.run([str(binary), str(path), 'constraints' if constrained else 'smooth'],
                             input=data, text=True, capture_output=True, timeout=120)
        (out / (name + '.output')).write_text(run.stdout + run.stderr)
        try:
            if run.returncode:
                raise ValueError(run.stdout[-2000:] + run.stderr[-1000:])
            actual = parse(run.stdout)
            if len(actual) != len(expected):
                raise ValueError('wrong sample count')
            maxima = {}
            for got, want in zip(actual, expected, strict=True):
                for key, value in want.items():
                    if got[key].shape != value.shape:
                        raise ValueError(f'{key} shape {got[key].shape} != {value.shape}')
                    delta = np.abs(got[key] - value)
                    # Roundtrip inherits the forward solver's finite stopping error.
                    atol, rtol = (3e-6, 1e-8) if constrained and key == 'roundtrip' else (2e-10, 2e-10)
                    if not np.all(delta <= atol + rtol * np.abs(value)):
                        raise ValueError(f'{key}: max difference {delta.max(initial=0):.8g}; Ada={got[key]}; C={value}')
                    maxima[key] = max(maxima.get(key, 0), float(delta.max(initial=0)))
                    comparisons += value.size
            scenarios += len(actual)
            records.append(dict(model=name, cases=len(actual), maxima=maxima))
        except Exception as error:
            failures.append(dict(model=name, error=str(error)))
            print('FAIL', name, str(error)[:800], flush=True)
    report = dict(reference='MuJoCo 3.14.0', binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),
                  models=len(records), scenarios=scenarios, comparisons=comparisons,
                  failures=failures, records=records)
    (out / 'summary.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({k: v for k, v in report.items() if k != 'records'}), flush=True)
    if failures:
        raise SystemExit(1)

if __name__ == '__main__':
    main()
