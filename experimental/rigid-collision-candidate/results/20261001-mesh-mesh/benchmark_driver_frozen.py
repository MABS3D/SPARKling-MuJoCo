"""Balanced mesh-mesh precontact timings, with actual native C and frozen builds."""
import argparse
import ctypes
import itertools
import json
import os
import platform
import subprocess
from pathlib import Path

import numpy as np

from check import rotation
from check_advanced import CUBE, model, mesh_asset, mesh_graph
from check_contacts import library, match, serialize_objects
from benchmark_contacts import OFFSETS


def clouds():
    rng = np.random.default_rng(3141101)
    yield "cube", CUBE
    yield "polytope", rng.normal(size=(28, 3))
    yield "wide-face", np.array([[np.cos(t), np.sin(t), z] for z in [-.7, .7]
                                for t in np.linspace(0, 2*np.pi, 24, endpoint=False)])
    for n in [128, 512]:
        z = 1 - 2*(np.arange(n) + .5)/n
        angle = np.arange(n)*np.pi*(3-np.sqrt(5))
        radius = np.sqrt(1-z*z)
        yield f"round-{n}", np.stack([radius*np.cos(angle), radius*np.sin(angle), z], axis=1)


def run(out, baseline, rounds=30, target=.012, families=None, distinct=False, shared_current=True):
    if rounds < 6:
        raise ValueError("Use at least one cycle of all six timing orders")
    os.sched_setaffinity(0, {15})
    lib = library(out)
    timer = lib.rigid_contact_time
    timer.argtypes = [ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_int,
                      ctypes.c_double, ctypes.c_int, ctypes.POINTER(ctypes.c_double)]
    timer.restype = ctypes.c_double
    rng = np.random.default_rng(3141203)
    permutations = list(itertools.permutations(range(3)))
    records = []
    report = dict(scope="mesh-mesh geometric precontacts; excludes broadphase, material/frame, constraints and movement",
                  rounds=rounds, target_seconds=target, cpu_affinity=[15], platform=platform.platform(),
                  order="all six permutations of baseline,current,native C repeated",
                  baseline_path=str(baseline), current_path=str(out),
                  asset_layout=dict(baseline='two serialized assets',current=('two different assets' if distinct else 'one shared asset' if shared_current else 'two copies of the same asset'),native_c=('two different assets' if distinct else 'one shared compiled mesh')),
                  baseline_manifest=json.loads((baseline/'manifest.json').read_text()),
                  current_manifest=json.loads((out/'manifest.json').read_text()), results=records)

    for family, cloud in clouds():
        if families and family not in families:
            continue
        m, d = model('mesh', 'mesh', cloud, cloud*np.array([1.13,.84,1.06]) if distinct else None)
        vertices, facets, graphs, seeds = [], [], [], []
        for geom in [0, 1]:
            v, f = mesh_asset(m, geom)
            g, s = mesh_graph(m, geom)
            vertices.append(v); facets.append(f); graphs.append(g); seeds.append(s)
        turned = np.stack([rotation(rng), rotation(rng)])
        identity = np.stack([np.eye(3).reshape(9)]*2)
        separation = 2*max(np.linalg.norm(v, axis=1).max() for v in vertices)+.1
        configurations = [('aligned', identity, [.35, .17, .25], 0.),
                          ('rotated', turned, [.35, .17, .25], 0.),
                          ('margin', turned, [.35, .17, .25], .005),
                          ('separated', turned, [separation, 0., 0.], 0.)]
        share = shared_current and not distinct
        for label, mats, translation, margin in configurations:
            positions = np.array([[0., 0., 0.], translation])

            def encode(pos=positions, mode=0, repeats=1, shared=False):
                return serialize_objects(['mesh', 'mesh'], m.geom_size, pos, mats,
                                         vertices=vertices, facets=facets, graphs=graphs,
                                         seeds=seeds, margin=margin, mode=mode, repeats=repeats,shared_mesh=shared)

            expected, inputs, current_inputs = [], [], []
            for off in OFFSETS:
                p = positions.copy(); p[1, 0] += off
                d.geom_xpos[:] = p; d.geom_xmat[:] = mats
                buffer = np.zeros(500)
                count = lib.rigid_contacts(m._address, d._address, 0, 1, margin, buffer)
                expected.append(buffer[:10*count].reshape(-1, 10).copy())
                inputs.append(encode(p))
                current_inputs.append(encode(p,shared=share))
            for name, source in [('baseline', baseline), ('current', out)]:
                checked = subprocess.run([str(source/'build/release/bin/contact_probe')],
                                         input=''.join(inputs if name=='baseline' else current_inputs), text=True, capture_output=True, check=True)
                lines = checked.stdout.splitlines()
                if len(lines) != len(expected):
                    raise RuntimeError((family, label, name, "missing frames", checked.stderr))
                for frame, (line, want) in enumerate(zip(lines, expected)):
                    words = line.split()
                    if words[0] != 'SUCCESS':
                        raise RuntimeError((family, label, name, frame, words))
                    actual = np.asarray(list(map(float, words[2:]))).reshape(-1, 10)
                    error = match(actual, want)
                    if error:
                        raise RuntimeError((family, label, name, frame, error))
            d.geom_xpos[:] = positions; d.geom_xmat[:] = mats
            checksum = ctypes.c_double()
            pilot = timer(m._address, d._address, 0, 1, margin, 128, ctypes.byref(checksum))
            repeats = max(256, min(1000000, int(target*1e9/max(pilot, 1))))
            repeats = repeats//16*16

            def ada(source):
                words = subprocess.run([str(source/'build/release/bin/contact_probe')],
                                       input=encode(mode=1, repeats=repeats,shared=(source==out and share)), text=True,
                                       capture_output=True, check=True).stdout.split()
                if words[0] != 'SUCCESS':
                    raise RuntimeError(words)
                return float(words[2]), float(words[3])

            calls = [lambda: ada(baseline), lambda: ada(out),
                     lambda: (timer(m._address, d._address, 0, 1, margin, repeats,
                                    ctypes.byref(checksum)), checksum.value)]
            timings, checksums = [], []
            for iteration in range(rounds):
                values = [None]*3
                for index in permutations[iteration % 6]:
                    values[index] = calls[index]()
                if any(abs(v[1]-values[2][1]) > 2e-7*(1+abs(values[2][1])) for v in values[:2]):
                    raise RuntimeError((family, label, "checksum mismatch", values))
                timings.append([v[0] for v in values]); checksums.append([v[1] for v in values])
            times = np.asarray(timings)
            ratios = times[:, 1]/times[:, 2]
            changes = times[:, 1]/times[:, 0]

            def interval(values):
                return np.quantile(np.median(rng.choice(values, size=(10000, len(values)),
                                                        replace=True), axis=1), [.025, .975]).tolist()

            row = dict(case=family+'-'+label, vertices=[len(v) for v in vertices],
                       facets=[len(f) for f in facets], frames=16, contacts=[len(w) for w in expected],
                       margin=margin, positions=positions.tolist(), matrices=mats.tolist(),
                       repetitions=repeats, baseline_ns=float(np.median(times[:, 0])),
                       ada_ns=float(np.median(times[:, 1])), c_ns=float(np.median(times[:, 2])),
                       ratio=float(np.median(ratios)), ratio95=interval(ratios),
                       current_over_baseline=float(np.median(changes)), change95=interval(changes),
                       triples_ns=timings, checksums=checksums)
            records.append(row)
            (out/('mesh-mesh-distinct-benchmark.json' if distinct else 'mesh-mesh-unshared-benchmark.json' if not shared_current else 'mesh-mesh-benchmark.json')).write_text(json.dumps(report, indent=2)+'\n')
            print(row['case'], 'Ada/C', round(row['ratio'], 3), 'current/baseline',
                  round(row['current_over_baseline'], 3), flush=True)
    return report


if __name__ == '__main__':
    p = argparse.ArgumentParser()
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=30)
    p.add_argument('--target', type=float, default=.012)
    p.add_argument('--families', nargs='+')
    p.add_argument('--distinct', action='store_true')
    p.add_argument('--unshared-current', action='store_true')
    args = p.parse_args()
    run(args.out.resolve(), args.baseline.resolve(), args.rounds, args.target, args.families, args.distinct, not args.unshared_current)
