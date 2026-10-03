"""Alternate full flex trajectories against baseline Ada and native C.

Consumes the exact MJB/input files from a completed numerical corpus. Parsing,
creation, reset and output are outside the measured region. Run only during a
coordinated quiet window before drawing performance conclusions.
"""
import argparse
import ctypes
import hashlib
import itertools
import json
import os
import platform
import resource
import shutil
import subprocess
from pathlib import Path

import mujoco
import numpy as np


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--cases', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--blocks', type=int, default=12)
    p.add_argument('--batches', type=int, default=8)
    p.add_argument('--steps', type=int, default=100)
    p.add_argument('--sample', type=int, default=1)
    p.add_argument('--only')
    p.add_argument('--cpu', type=int)
    p.add_argument('--quiet-window', action='store_true',
                   help='Record that other agents/jobs were coordinated to be idle')
    a = p.parse_args()
    if min(a.blocks, a.batches, a.steps) < 1 or a.sample < 0:
        p.error('Positive block/batch/step counts and nonnegative sample required')
    if mujoco.__version__ != '3.14.0':
        raise RuntimeError('Unexpected C reference')
    a.out.mkdir(parents=True, exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,
                       (128*1024*1024, resource.getrlimit(resource.RLIMIT_STACK)[1]))
    if a.cpu is not None:
        os.sched_setaffinity(0, {a.cpu})
    wheel = Path(mujoco.__file__).parent
    library = wheel/'libmujoco.so.3.14.0'
    helper = Path(__file__).with_name('benchmark.c')
    shutil.copyfile(helper, a.out/'benchmark.c')
    shutil.copyfile(__file__, a.out/'benchmark_constrained.py')
    command = ['gcc', '-O3', '-march=native', '-ffp-contract=off', '-shared',
               '-fPIC', str(a.out/'benchmark.c'), '-I'+str(wheel/'include'),
               str(library), '-Wl,-rpath,'+str(wheel), '-o', str(a.out/'benchmark.so')]
    subprocess.run(command, check=True)
    native = ctypes.CDLL(str(a.out/'benchmark.so')).flex_step_time
    native.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int]
    native.restype = ctypes.c_double
    manifests = {}
    for key, binary in [('ada', a.binary), ('baseline', a.baseline)]:
        manifest = binary.resolve().parents[3]/'manifest.json'
        if manifest.is_file():
            manifests[key] = dict(path=str(manifest), sha256=sha(manifest),
                                  data=json.loads(manifest.read_text()))
    report = dict(reference=mujoco.__version__, library_sha256=sha(library),
                  binaries={key: dict(path=str(binary.resolve()), sha256=sha(binary))
                            for key, binary in [('ada', a.binary), ('baseline', a.baseline)]},
                  driver_sha256=sha(Path(__file__)), helper_sha256=sha(helper),
                  source_manifests=manifests, native_compile_command=command,
                  gcc_version=subprocess.check_output(['gcc', '--version'], text=True).splitlines()[0],
                  hardware=platform.uname()._asdict(), affinity=sorted(os.sched_getaffinity(0)),
                  cpuinfo=Path('/proc/cpuinfo').read_text(),
                  quiet_window=a.quiet_window, complete=False,
                  blocks=a.blocks, batches=a.batches, steps=a.steps,
                  warmup_trajectories_per_block=1, results=[])
    def save():
        (a.out/'results.json').write_text(json.dumps(report, indent=2)+'\n')
    save()
    names = ['membrane_Newton_3', 'free', 'element_2_sphere',
             'element_mixed_pyramidal_3', 'element_elastic_cross_elliptic_6',
             'element_elastic_self_bvh_pyramidal_3']
    orders = list(itertools.permutations(('baseline', 'ada', 'c')))
    rng = np.random.default_rng(2026100309)
    for name in names:
        if a.only and a.only not in name:
            continue
        model = a.cases/(name+'.mjb')
        original_input = a.cases/(name+'.input')
        m = mujoco.MjModel.from_binary_path(str(model))
        d = mujoco.MjData(m)
        header, body = original_input.read_text().split('\n', 1)
        count, _ = map(int, header.split())
        stride = 1+m.nq+2*m.nv+m.nu+m.na
        values = np.fromstring(body, sep=' ')
        if a.sample >= count or values.size != count*stride:
            raise RuntimeError('Malformed corpus input: '+name)
        sample = values[a.sample*stride:(a.sample+1)*stride]
        if sample[0] != 0:
            raise RuntimeError('Benchmark reset requires zero initial time')
        local_model = a.out/(name+'.mjb')
        shutil.copyfile(model, local_model)
        input_path = a.out/(name+'.input')
        line = ' '.join(format(v, '.17g') for v in sample)+'\n'
        input_path.write_text(f'{a.batches+1} {a.steps}\n'+line*(a.batches+1))
        raw = {key: [] for key in orders[0]}
        row = dict(model=name, nv=m.nv, nflex=m.nflex, model_sha256=sha(model),
                   original_input_sha256=sha(original_input), sample=a.sample,
                   raw_us=raw, state_max_abs={'ada': 0., 'baseline': 0.}, passed=True)
        report['results'].append(row)
        for block in range(a.blocks):
            states = {}
            for language in orders[block % len(orders)]:
                if language == 'c':
                    times, frames = [], []
                    for _ in range(a.batches+1):
                        mujoco.mj_resetData(m, d)
                        first = 1
                        for array in (d.qpos, d.qvel, d.qfrc_applied, d.ctrl, d.act):
                            array[:] = sample[first:first+len(array)]
                            first += len(array)
                        times.append(native(m._address, d._address, a.steps))
                        frames.append(np.r_[d.qpos, d.qvel, d.time, d.act].copy())
                    states[language] = np.array(frames)
                else:
                    binary = a.binary if language == 'ada' else a.baseline
                    output = a.out/f'{name}-{language}-{block}.output'
                    with input_path.open() as source, output.open('w') as target:
                        subprocess.run([str(binary), str(local_model), 'benchmark'],
                                       stdin=source, stdout=target, stderr=subprocess.STDOUT,
                                       timeout=240, check=True)
                    lines = output.read_text().splitlines()
                    if len(lines) != 2*(a.batches+1) or not all(
                            x.startswith('seconds ') for x in lines[::2]):
                        raise RuntimeError('Invalid benchmark output: '+str(output))
                    times = [float(x.split()[1]) for x in lines[::2]]
                    states[language] = np.array([np.fromstring(x[6:], sep=' ')
                                                 for x in lines[1::2]])
                raw[language].append((np.array(times[1:])*1e6/a.steps).tolist())
            for language in ('baseline', 'ada'):
                same_shape = states[language].shape == states['c'].shape
                error = float(np.max(abs(states[language]-states['c']))) if same_shape else None
                row['state_max_abs'][language] = max(row['state_max_abs'][language], error or 0.)
                if not same_shape or not np.allclose(states[language], states['c'], atol=2e-9, rtol=2e-9):
                    row.update(passed=False, failed_language=language, failed_block=block,
                               state_shape_matches=same_shape)
                    save()
                    raise RuntimeError('Trajectory mismatch: '+name+' '+language)
            row['blocks_complete'] = block+1
            save()
        means = {key: np.mean(data, axis=1) for key, data in raw.items()}
        def ratio(denominator):
            paired = means['ada']/means[denominator]
            draws = np.median(rng.choice(paired, (5000, len(paired)), replace=True), axis=1)
            return dict(median=float(np.median(paired)), bootstrap_95=np.percentile(draws, [2.5, 97.5]).tolist())
        row.update(median_us={key: float(np.median(data)) for key, data in means.items()},
                   p95_trajectory_us={key: float(np.percentile(data, 95)*a.steps) for key, data in raw.items()},
                   ada_over_c=ratio('c'), ada_over_baseline=ratio('baseline'))
        save()
        print(json.dumps({key: value for key, value in row.items() if key != 'raw_us'}), flush=True)
    if not report['results']:
        raise RuntimeError('No selected benchmark models')
    report['complete'] = True
    save()


if __name__ == '__main__':
    main()
