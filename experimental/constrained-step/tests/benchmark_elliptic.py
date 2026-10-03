"""Time equivalent full elliptic-contact trajectories with the native C engine."""
import argparse
import ctypes
import hashlib
import json
import os
import platform
import subprocess
from pathlib import Path

import mujoco
import numpy as np

from compare_elliptic import elliptic_fixtures

p = argparse.ArgumentParser()
p.add_argument('--binary', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--blocks', type=int, default=12)
p.add_argument('--batches', type=int, default=16)
p.add_argument('--steps', type=int, default=100)
args = p.parse_args()
assert args.blocks >= 3 and args.batches >= 1 and args.steps >= 1
assert mujoco.__version__ == '3.14.0'
args.out.mkdir(parents=True, exist_ok=False)
wheel = Path(mujoco.__file__).parent
library = wheel / 'libmujoco.so.3.14.0'
helper = Path(__file__).with_name('benchmark.c')
command = ['gcc', '-O3', '-march=native', '-ffp-contract=off', '-shared', '-fPIC',
           str(helper), '-I' + str(wheel / 'include'), str(library),
           '-Wl,-rpath,' + str(wheel), '-o', str(args.out / 'benchmark.so')]
subprocess.run(command, check=True)
native = ctypes.CDLL(str(args.out / 'benchmark.so')).constrained_time
native.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
native.restype = ctypes.c_double
selected = ['sphere_Newton_3_0.2', 'sphere_Newton_4_0.2',
            'sphere_Newton_6_0.2', 'box_multiple_6']
records = []
for name, xml in elliptic_fixtures():
    if name not in selected:
        continue
    m = mujoco.MjModel.from_xml_string(xml)
    d = mujoco.MjData(m)
    path = args.out / (name + '.mjb')
    mujoco.mj_saveModel(m, str(path))
    (args.out / (name + '.xml')).write_text(xml)
    q = m.qpos0.copy()
    velocity = np.linspace(-.03, .03, m.nv)
    force = np.linspace(-.05, .05, m.nv)
    sample = ' '.join(format(value, '.17g') for value in [0., *q, *velocity, *force]) + '\n'
    input_path = args.out / (name + '.input')
    input_path.write_text(f'{args.batches + 1} {args.steps}\n' + sample * (args.batches + 1))
    timings = {'ada': [], 'c': []}
    maximum = 0.
    for block in range(args.blocks):
        states = {}
        for language in (['ada', 'c'] if block % 2 == 0 else ['c', 'ada']):
            if language == 'ada':
                output_path = args.out / (name + '.output')
                with input_path.open() as source, output_path.open('w') as target:
                    subprocess.run([str(args.binary), str(path), 'benchmark'], stdin=source,
                                   stdout=target, stderr=subprocess.STDOUT, check=True, timeout=240)
                lines = output_path.read_text().splitlines()
                assert len(lines) == 2 * (args.batches + 1)
                times = [float(lines[i].split()[1]) for i in range(0, len(lines), 2)]
                states[language] = np.array([np.fromstring(lines[i][6:], sep=' ')
                                            for i in range(1, len(lines), 2)])
            else:
                times, values = [], []
                for batch in range(args.batches + 1):
                    mujoco.mj_resetData(m, d)
                    d.qpos[:] = q
                    d.qvel[:] = velocity
                    d.qfrc_applied[:] = force
                    times.append(native(m._address, d._address, args.steps))
                    values.append(np.r_[d.qpos, d.qvel, d.time].copy())
                states[language] = np.array(values)
            timings[language].append([value / args.steps * 1e6 for value in times[1:]])
        assert np.allclose(states['ada'], states['c'], atol=3e-6, rtol=1e-8), name
        maximum = max(maximum, float(np.max(abs(states['ada'] - states['c']))))
    medians = {language: float(np.median(values)) for language, values in timings.items()}
    paired = np.median(timings['ada'], axis=1) / np.median(timings['c'], axis=1)
    rng = np.random.default_rng(20261002)
    bootstrap = np.median(rng.choice(paired, (5000, len(paired)), replace=True), axis=1)
    record = dict(model=name, nv=m.nv, condim=m.geom_condim.tolist(),
                  medians_us=medians, paired_ratio=float(np.median(paired)),
                  bootstrap_95=np.percentile(bootstrap, [2.5, 97.5]).tolist(),
                  p95_us={language: float(np.percentile(values, 95))
                          for language, values in timings.items()},
                  trajectory_max_abs=maximum, raw_us=timings)
    records.append(record)
    print({key: value for key, value in record.items() if key != 'raw_us'}, flush=True)
report = dict(reference=mujoco.__version__, blocks=args.blocks, batches=args.batches,
              steps=args.steps, hardware=platform.uname()._asdict(),
              cpu=Path('/proc/cpuinfo').read_text().split('model name')[1].splitlines()[0],
              affinity=sorted(os.sched_getaffinity(0)), command=command,
              library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
              binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
              helper_sha256=hashlib.sha256(helper.read_bytes()).hexdigest(),
              driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              results=records)
(args.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
