"""Alternating complete trajectories, native C normal SIMD, I/O outside clocks."""
import argparse
import hashlib
import json
import os
import subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare import fixtures, poses


def run(command, data):
    r = subprocess.run(command, input=data, text=True, capture_output=True, timeout=180)
    if r.returncode:
        raise RuntimeError(r.stdout[-1200:] + r.stderr[-1200:])
    timings, states = [], []
    for line in r.stdout.splitlines():
        key, *values = line.split()
        if key == 'seconds': timings.append(float(values[0]))
        if key == 'state': states.append(np.array([float(v) for v in values]))
    return np.array(timings), states


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--reference', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=11)
    p.add_argument('--trajectories', type=int, default=32)
    p.add_argument('--steps', type=int, default=64)
    a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=False)
    available = os.sched_getaffinity(0); cpu = min(available)
    os.sched_setaffinity(0, {cpu})
    rng = np.random.default_rng(20261002); results = []
    for name, xml in fixtures():
        if name not in ['scalar_child', 'ball_child', 'moving_plane', 'spatial_tendon', 'fluid_child', 'no_mocap']:
            continue
        for mode in ['smooth', 'constrained']:
            m = mujoco.MjModel.from_xml_string(xml)
            if mode == 'smooth': m.opt.disableflags |= int(mujoco.mjtDisableBit.mjDSBL_CONSTRAINT)
            f = a.out / (name + '-' + mode + '.mjb'); mujoco.mj_saveModel(m, str(f))
            q = m.qpos0.copy(); v = np.full(m.nv, .01)
            pos, quat = poses(m, 0, rng)
            sample = [*q, *v]
            for i in range(m.nmocap): sample.extend([*pos[i], *quat[i]])
            data = f'{a.trajectories} {a.steps}\n' + ' '.join(format(x, '.17g') for x in sample * a.trajectories) + '\n'
            commands = dict(ada=[str(a.binary), str(f), mode, 'benchmark'], c=[str(a.reference), str(f), mode])
            series = dict(ada=[], c=[])
            for round in range(a.rounds + 1):
                state = {}
                for language in (['ada', 'c'] if round % 2 == 0 else ['c', 'ada']):
                    times, states = run(commands[language], data)
                    if round: series[language].append(times.tolist())
                    state[language] = states
                assert len(state['ada']) == len(state['c']) == a.trajectories
                for x, y in zip(state['ada'], state['c']):
                    assert np.allclose(x, y, atol=2e-10, rtol=2e-10), (name, mode, float(np.max(np.abs(x-y))))
            paired = np.array(series['ada']).sum(axis=1) / np.array(series['c']).sum(axis=1)
            boot = np.median(rng.choice(paired, size=(3000, len(paired)), replace=True), axis=1)
            item = dict(model=name, mode=mode, nv=m.nv, nmocap=m.nmocap, paired_ratio=float(np.median(paired)),
                        ratio_ci95=np.quantile(boot, [.025,.975]).tolist(),
                        ada_us_step=float(np.median(series['ada']) / a.steps * 1e6),
                        c_us_step=float(np.median(series['c']) / a.steps * 1e6),
                        raw_seconds=series)
            results.append(item); print(name, mode, item['paired_ratio'], flush=True)
    report = dict(reference=mujoco.__version__, cpu=cpu, shared_host=True, rounds=a.rounds, trajectories=a.trajectories, steps=a.steps,
                  ada_binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                  c_binary_sha256=hashlib.sha256(a.reference.read_bytes()).hexdigest(), workloads=results)
    (a.out / 'results.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__': main()
