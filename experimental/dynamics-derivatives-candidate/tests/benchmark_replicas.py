"""Measure full movement with identical binary replicas and nested uncertainty.

Run with all compiler/prover/heavy jobs idle. A prepared movement build and
previous full-session fixtures supply the pinned binaries, inputs and oracle.
Copy placement is a measured nuisance variable, not an identified cache or
allocator mechanism. This Linux diagnostic does not establish full-port parity.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import re
import shutil
import subprocess

import numpy as np


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def dump(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n')


def libraries(binary):
    output = subprocess.check_output(['ldd', str(binary)], text=True)
    return {line.split()[0]: digest(Path(match[1]))
            for line in output.splitlines()
            if (match := re.search(r'=> (/[^ ]+)', line))}


def nested_ratio(numerator, denominator, rng):
    """Resample matching replica groups, then matching blocks within each group."""
    a = np.median(np.asarray(numerator), axis=2)
    b = np.median(np.asarray(denominator), axis=2)
    replicas, blocks = a.shape
    assert a.shape == b.shape and replicas >= 3
    groups = rng.integers(0, replicas, size=(4000, replicas, 1))
    samples = rng.integers(0, blocks, size=(4000, replicas, blocks))
    boot_a = np.median(a[groups, samples].reshape(4000, -1), axis=1)
    boot_b = np.median(b[groups, samples].reshape(4000, -1), axis=1)
    return dict(median=float(np.median(a) / np.median(b)),
                ci95=[float(x) for x in np.quantile(boot_a / boot_b, [.025, .975])])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build', type=Path, required=True)
    parser.add_argument('--fixtures', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--replicas', type=int, default=3)
    parser.add_argument('--blocks', type=int, default=36)
    parser.add_argument('--samples', type=int, default=8)
    parser.add_argument('--warmups', type=int, default=32)
    parser.add_argument('--cpu', type=int, default=12)
    parser.add_argument('--seed', type=int, default=2026102507)
    parser.add_argument('--models', nargs='+')
    args = parser.parse_args()
    assert args.replicas >= 3 and min(args.samples, args.warmups) > 0
    args.out.mkdir(parents=True, exist_ok=False)
    shutil.copy2(Path(__file__), args.out / 'runner.py')
    provider = args.out / 'provider.py'
    shutil.copy2(Path(__file__).with_name('benchmark_movement.py'), provider)
    spec = importlib.util.spec_from_file_location('replica_provider', provider)
    helpers = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helpers)
    meta = json.loads((args.build / 'build.json').read_text())
    fixtures = json.loads((args.fixtures / 'results.json').read_text())
    assert meta['reference'] == fixtures['reference'] == '3.17.0'
    assert not args.models or set(args.models) <= {row['model'] for row in fixtures['records']}
    steps = {row['steps'] for row in fixtures['records']}
    assert len(steps) == 1
    steps = steps.pop()
    original = {name: Path(meta['builds'][name]['binary'])
                for name in ['baseline', 'current', 'c']}
    expected = {name: meta['builds'][name]['binary_sha256'] for name in original}
    assert all(digest(path) == expected[name] for name, path in original.items())
    c_library = Path(meta['builds']['c']['library'])
    assert digest(c_library) == meta['builds']['c']['library_sha256']
    copies = args.out / 'copies'
    copies.mkdir()
    binaries = {}
    roles = {}
    links = {}
    tasks = [(name, replica) for name in original for replica in range(args.replicas)]
    np.random.default_rng(args.seed).shuffle(tasks)
    width = len(str(len(tasks) - 1))
    for ordinal, (name, replica) in enumerate(tasks):
        source = original[name]
        if name not in links:
            links[name] = libraries(source)
        # Randomize copy creation and assignment to equal-length paths, instead
        # of clustering physical copies or naming paths by implementation role.
        key = 'p' + format(ordinal, '0' + str(width) + 'd')
        binary = copies / key
        shutil.copy2(source, binary)
        assert digest(binary) == expected[name]
        assert libraries(binary) == links[name]
        binaries[key] = binary
        roles[key] = dict(role=name, replica=replica,
                          sha256=expected[name], original=str(source))
    names = list(binaries)
    assert args.blocks >= 2 * len(names) and args.blocks % (2 * len(names)) == 0
    orders = []
    for sequence in [names, names[::-1]]:
        orders += [sequence[i:] + sequence[:i] for i in range(len(sequence))]
    os.sched_setaffinity(0, {args.cpu})
    rng = np.random.default_rng(2026102506)
    records = []
    commands = []
    dump(args.out / 'binaries.json', dict(roles=roles, shared_libraries=links))
    try:
        for case in fixtures['records']:
            model, state = case['model'], case['state']
            if args.models and model not in args.models:
                continue
            key = model + '-' + str(state)
            model_path = args.fixtures / (model + '.mjb')
            input_path = args.fixtures / (key + '.input')
            text = input_path.read_text()
            oracle = np.asarray(json.loads(
                (args.fixtures / (key + '-oracle.json')).read_text()))
            times = {name: [] for name in names}
            checks = 0
            for block in range(args.blocks):
                values = {}
                for name in orders[(block + len(records)) % len(orders)]:
                    argv = ['movement-probe', str(model_path), str(steps),
                            str(args.samples), str(args.warmups)]
                    run = subprocess.run(argv, executable=str(binaries[name]),
                                         input=text, text=True, capture_output=True,
                                         timeout=120)
                    output = args.out / (key + f'-{block:02}-' + name + '.output')
                    output.write_text(run.stdout + run.stderr)
                    commands.append(dict(argv=argv, executable=str(binaries[name]),
                                         input=str(input_path), output=str(output),
                                         exit=run.returncode))
                    assert run.returncode == 0, (name, run.stderr)
                    rows = helpers.parse(run.stdout, case['nq'], case['nv'], args.samples)
                    values[name] = [row[1] for row in rows]
                    times[name].append([row[0] / steps for row in rows])
                    assert all(np.allclose(v, oracle, atol=2e-10, rtol=2e-10)
                               for v in values[name])
                    checks += sum(len(v) for v in values[name])
                ada = [name for name in names if roles[name]['role'] != 'c']
                assert all(all(np.array_equal(a, b) for a, b in
                               zip(values[ada[0]], values[name])) for name in ada[1:])
            grouped = {role: [times[name] for name in sorted(
                (n for n in names if roles[n]['role'] == role),
                key=lambda n: roles[n]['replica'])] for role in original}
            result = dict(model=model, state=state, nq=case['nq'], nv=case['nv'],
                          steps=steps, blocks=args.blocks, samples=args.samples,
                          replicas=args.replicas, checked_values=checks,
                          model_sha256=digest(model_path), input_sha256=digest(input_path),
                          timings_seconds_per_step=times,
                          statistics={n: helpers.stats(np.ravel(v)) for n, v in times.items()},
                          current_over_baseline=nested_ratio(grouped['current'], grouped['baseline'], rng),
                          current_over_c=nested_ratio(grouped['current'], grouped['c'], rng),
                          same_code_replica_ratios={role: [helpers.ratio(v, grouped[role][0], rng)
                                                         for v in grouped[role][1:]] for role in original})
            records.append(result)
            dump(args.out / 'partial.json', records)
            print(key, 'current/base', result['current_over_baseline'], flush=True)
        assert all(digest(path) == roles[name]['sha256'] for name, path in binaries.items())
        assert all(digest(path) == expected[name] for name, path in original.items())
        assert digest(c_library) == meta['builds']['c']['library_sha256']
        dump(args.out / 'results.json', dict(
            passed=True, unchanged_binaries=True, identical_shared_libraries=True,
            reference='3.17.0', build_sha256=digest(args.build / 'build.json'),
            fixtures_sha256=digest(args.fixtures / 'results.json'),
            replicas=args.replicas, cpu=args.cpu, creation_seed=args.seed,
            selected_models=args.models, records=records,
            scope='Supported integrated smooth Euler movement. Identical-SHA replicas '
                  'at equal-length paths, normalized argv0, shared immutable fixtures, '
                  'balanced cyclic/reverse orders and replica-then-block bootstrap. '
                  'Placement variability included; no identified allocator/cache cause, '
                  'universal C equivalence, full port or overall C-parity claim.'))
    except BaseException as error:
        dump(args.out / 'failure.json', dict(error=repr(error), completed_cases=len(records)))
        raise
    finally:
        dump(args.out / 'commands.json', commands)


if __name__ == '__main__':
    main()
