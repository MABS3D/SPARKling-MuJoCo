"""Alternate baseline Ada, candidate Ada and C on identical full trajectories.

Each Ada process runs several reset trajectories. Reset, parsing and output are
outside the measured region in the existing probe. The first trajectory of each
block warms both implementations and is excluded. C uses the same reset policy.
"""
import argparse
import ctypes
import hashlib
import itertools
import json
import os
import platform
import subprocess
from pathlib import Path

import mujoco
import numpy as np
from compare import fixtures, model_xml


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--blocks', type=int, default=15)
    p.add_argument('--batches', type=int, default=16)
    p.add_argument('--steps', type=int, default=100)
    p.add_argument('--only')
    a = p.parse_args()
    assert a.blocks >= 3 and a.batches >= 1 and a.steps >= 1
    assert mujoco.__version__ == '3.14.0'
    a.out.mkdir(parents=True, exist_ok=False)
    wheel = Path(mujoco.__file__).parent
    library = wheel / 'libmujoco.so.3.14.0'
    helper = Path(__file__).with_name('benchmark.c')
    command = ['gcc', '-O3', '-march=native', '-ffp-contract=off', '-shared',
               '-fPIC', str(helper), '-I' + str(wheel / 'include'), str(library),
               '-Wl,-rpath,' + str(wheel), '-o', str(a.out / 'benchmark.so')]
    subprocess.run(command, check=True)
    native = ctypes.CDLL(str(a.out / 'benchmark.so')).constrained_time
    native.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
    native.restype = ctypes.c_double
    names = ['sphere_Newton_3_0.2', 'coupled_limits_friction',
             'box_multiple', 'shared_ancestors']
    models = [(n, x) for n, x in fixtures() if n in names]
    for count in (4, 8, 16):
        body = ''.join(
            f'<body pos="{.4*(i % 4)} {.4*(i // 4)} .095">'
            '<joint type="free"/><geom type="sphere" size=".1" mass="1"/></body>'
            for i in range(count))
        models.append((f'{count}_free_bodies', model_xml(body)))
    orders = list(itertools.permutations(('baseline', 'ada', 'c')))
    rng = np.random.default_rng(20261002)
    results = []
    for name, xml in models:
        if a.only and a.only not in name:
            continue
        m = mujoco.MjModel.from_xml_string(xml)
        d = mujoco.MjData(m)
        model = a.out / (name + '.mjb')
        mujoco.mj_saveModel(m, str(model))
        (a.out / (name + '.xml')).write_text(xml)
        q = m.qpos0.copy()
        v = np.linspace(-.03, .03, m.nv)
        force = np.linspace(-.05, .05, m.nv)
        ctrl = np.zeros(m.nu)
        assert m.na == 0
        sample = ' '.join(format(x, '.17g') for x in [0., *q, *v, *force, *ctrl]) + '\n'
        data = f'{a.batches + 1} {a.steps}\n' + sample * (a.batches + 1)
        input_path = a.out / (name + '.input')
        input_path.write_text(data)
        raw = {lang: [] for lang in orders[0]}
        maximum = {'baseline': 0., 'ada': 0.}
        for block in range(a.blocks):
            states = {}
            for lang in orders[block % len(orders)]:
                if lang == 'c':
                    times = []
                    values = []
                    for batch in range(a.batches + 1):
                        mujoco.mj_resetData(m, d)
                        d.qpos[:] = q
                        d.qvel[:] = v
                        d.qfrc_applied[:] = force
                        d.ctrl[:] = ctrl
                        times.append(native(m._address, d._address, a.steps))
                        values.append(np.r_[d.qpos, d.qvel, d.time].copy())
                    states[lang] = np.array(values)
                else:
                    binary = a.binary if lang == 'ada' else a.baseline
                    # File redirection keeps the pinned Python parent asleep.
                    # With pipes, servicing large multi-trajectory input/output
                    # can preempt the timed child on the same logical CPU.
                    output_path = a.out / (name + '-' + lang + '.output')
                    with input_path.open('r') as source, output_path.open('w') as target:
                        subprocess.run([str(binary), str(model), 'benchmark'],
                                       stdin=source, stdout=target,
                                       stderr=subprocess.STDOUT, check=True, timeout=240)
                    output = output_path.read_text()
                    lines = output.splitlines()
                    assert len(lines) == 2 * (a.batches + 1), output[-2000:]
                    assert all(line.startswith('seconds ') for line in lines[::2])
                    assert all(line.startswith('state ') for line in lines[1::2])
                    times = [float(line.split()[1]) for line in lines[::2]]
                    states[lang] = np.array([np.fromstring(line[6:], sep=' ')
                                             for line in lines[1::2]])
                raw[lang].append((np.array(times[1:]) * 1e6 / a.steps).tolist())
            for lang in ('baseline', 'ada'):
                error = float(np.max(np.abs(states[lang] - states['c'])))
                maximum[lang] = max(maximum[lang], error)
                assert np.allclose(states[lang], states['c'], atol=3e-6, rtol=1e-8), (name, lang, error)
        means = {lang: np.mean(raw[lang], axis=1) for lang in raw}
        def ratio(numerator, denominator):
            paired = means[numerator] / means[denominator]
            draws = np.median(rng.choice(paired, (5000, len(paired)), replace=True), axis=1)
            return {'median': float(np.median(paired)),
                    'bootstrap_95': np.percentile(draws, [2.5, 97.5]).tolist()}
        row = dict(model=name, nv=m.nv, nefc=d.nefc, trajectory_max_abs=maximum,
                   us_per_step={lang: float(np.median(means[lang])) for lang in raw},
                   p95_trajectory_us={lang: float(np.percentile(raw[lang], 95) * a.steps) for lang in raw},
                   ada_over_c=ratio('ada', 'c'), ada_over_baseline=ratio('ada', 'baseline'),
                   samples_us_per_step=raw)
        results.append(row)
        print(json.dumps({k: v for k, v in row.items() if k != 'samples_us_per_step'}), flush=True)
    sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    report = dict(reference=mujoco.__version__, reference_sha256=sha(library),
                  candidate_sha256=sha(a.binary), baseline_sha256=sha(a.baseline),
                  driver_sha256=sha(Path(__file__)), helper_sha256=sha(helper),
                  fixtures_sha256=sha(Path(__file__).with_name('compare.py')),
                  native_compile_command=command, hardware=platform.uname()._asdict(),
                  affinity=sorted(os.sched_getaffinity(0)),
                  blocks=a.blocks, batches=a.batches, steps=a.steps,
                  warmup_trajectories_per_block=1, results=results)
    (a.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
