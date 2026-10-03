"""Equivalent complete-step surface-motion timings, with trajectory checks."""
import argparse, ctypes, hashlib, json, os, platform, subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare import model_xml

p = argparse.ArgumentParser()
p.add_argument('--binary', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
p.add_argument('--steps', type=int, default=256)
p.add_argument('--rounds', type=int, default=15)
a = p.parse_args()
a.out.mkdir(parents=True, exist_ok=False)
cpu = min(os.sched_getaffinity(0))
os.sched_setaffinity(0, {cpu})
wheel = Path(mujoco.__file__).parent
lib = wheel / 'libmujoco.so.3.14.0'
source = a.out / 'timer.c'
source.write_text('''#define _POSIX_C_SOURCE 200809L
#include <time.h>
#include <mujoco/mujoco.h>
double surface_time(const mjModel* m, mjData* d, int steps) {
  struct timespec before, after;
  clock_gettime(CLOCK_MONOTONIC, &before);
  for (int k = 0; k < steps; ++k) mj_step(m, d);
  clock_gettime(CLOCK_MONOTONIC, &after);
  return (after.tv_sec-before.tv_sec) + 1e-9*(after.tv_nsec-before.tv_nsec);
}
''')
native = a.out / 'timer.so'
cmd = ['gcc', '-O3', '-march=native', '-ffp-contract=off', '-shared', '-fPIC',
       str(source), '-I' + str(wheel / 'include'), str(lib),
       '-Wl,-rpath,' + str(wheel), '-o', str(native)]
subprocess.run(cmd, check=True)
timer = ctypes.CDLL(str(native)).surface_time
timer.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
timer.restype = ctypes.c_double
rows = []
for name, velocity, dim in [('zero', '0 0 0 0 0 0', 3),
                            ('belt', '.5 -.1 0 0 0 0', 3),
                            ('spin', '0 0 0 0 0 .8', 6)]:
    xml = model_xml('<body pos=".31 -.23 .095"><joint type="free"/>'
                    '<geom type="sphere" size=".1" mass="1"/></body>', dim=dim)
    xml = xml.replace('type="plane" size="2 2 .1"',
                      f'type="plane" size="2 2 .1" surfacevel="{velocity}"')
    m = mujoco.MjModel.from_xml_string(xml)
    d = mujoco.MjData(m)
    path = a.out / (name + '.mjb')
    mujoco.mj_saveModel(m, str(path))
    data = f'1 {a.steps}\n' + ' '.join(format(x, '.17g')
                for x in [0, *m.qpos0, *np.zeros(m.nv), *np.zeros(m.nv)]) + '\n'
    times = {'ada': [], 'c': []}
    worst = 0.0
    for repeat in range(a.rounds + 2):
        states = {}
        for lang in (['ada', 'c'] if repeat % 2 == 0 else ['c', 'ada']):
            if lang == 'ada':
                run = subprocess.run([str(a.binary), str(path), 'benchmark'],
                    input=data, capture_output=True, text=True, check=True, timeout=120)
                lines = run.stdout.splitlines()
                assert lines[0].startswith('seconds '), run.stdout
                elapsed = float(lines[0].split()[1])
                states[lang] = np.fromstring(lines[1][6:], sep=' ')
            else:
                mujoco.mj_resetData(m, d)
                elapsed = timer(m._address, d._address, a.steps)
                states[lang] = np.r_[d.qpos, d.qvel, d.time].copy()
            if repeat >= 2:
                times[lang].append(elapsed / a.steps * 1e6)
        error = float(np.max(abs(states['ada'] - states['c'])))
        worst = max(worst, error)
        assert np.allclose(states['ada'], states['c'], atol=3e-6, rtol=1e-8), (name, error)
    summary = {lang: dict(median_us=float(np.median(values)),
        p10_us=float(np.percentile(values, 10)), p90_us=float(np.percentile(values, 90)),
        p95_us=float(np.percentile(values, 95))) for lang, values in times.items()}
    paired = np.array(times['ada']) / np.array(times['c'])
    rng = np.random.default_rng(20261002)
    boot = np.median(rng.choice(paired, (10000, len(paired))), axis=1)
    row = dict(model=name, nv=m.nv, steps=a.steps, rounds=a.rounds, times_us=times,
        summary=summary, paired_ratio=float(np.median(paired)),
        ratio_ci95=np.percentile(boot, [2.5, 97.5]).tolist(), trajectory_max_abs=worst)
    rows.append(row)
    print({k: v for k, v in row.items() if k != 'times_us'}, flush=True)
report = dict(reference=mujoco.__version__, reference_sha256=hashlib.sha256(lib.read_bytes()).hexdigest(),
    binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(), cpu_affinity=cpu,
    hardware=platform.uname()._asdict(), compiler_command=cmd,
    compiler=subprocess.check_output(['gcc', '--version'], text=True).splitlines()[0],
    cpuinfo=Path('/proc/cpuinfo').read_text(), results=rows)
(a.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')
