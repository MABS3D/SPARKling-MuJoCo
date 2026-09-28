#!/usr/bin/env python3
"""Alternating paired measurements; input reset and checksums outside timing."""
import argparse, hashlib, json, os, pathlib, platform, random, statistics, subprocess

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--binary', default='/tmp/sparkling-cholesky/bin/benchmark/cholesky_bench')
    p.add_argument('--output', type=pathlib.Path, required=True)
    p.add_argument('--samples', type=int, default=9)
    p.add_argument('--target-seconds', type=float, default=0.08)
    p.add_argument('--sizes', type=int, nargs='+', default=[1, 3, 6, 12, 24, 48, 96])
    a = p.parse_args()
    affinity = sorted(os.sched_getaffinity(0))
    cpu = affinity[0]
    os.sched_setaffinity(0, {cpu})

    def run(n, op, lang, batches):
        r = subprocess.run([a.binary, str(n), str(op), lang, str(batches)], capture_output=True, text=True, check=True)
        seconds, count, checksum = r.stdout.split()
        return (float(seconds) / int(count), float(checksum), float(seconds))
    rows = []
    rng = random.Random(20260928)
    for n in a.sizes:
        for op, name in enumerate(['factor', 'solve', 'update', 'downdate', 'factor_solve_update_solve']):
            _, _, t = run(n, op, 'c', 30)
            batches = max(10, min(30000, round(30 * a.target_seconds / max(t, 1e-09))))
            pairs = []
            for trial in range(a.samples):
                values = {}
                for lang in ['ada', 'c'] if trial % 2 == 0 else ['c', 'ada']:
                    values[lang] = run(n, op, lang, batches)
                if abs(values['ada'][1] - values['c'][1]) > 1e-11 * max(1, abs(values['c'][1])):
                    raise RuntimeError('Checksum mismatch')
                pairs.append({k: v[0] * 1000000000.0 for k, v in values.items()})
            ratios = [x['ada'] / x['c'] for x in pairs]
            boots = sorted((statistics.median(rng.choices(ratios, k=len(ratios))) for _ in range(2000)))
            row = {'n': n, 'operation': name, 'batches': batches, 'ada_ns': statistics.median((x['ada'] for x in pairs)), 'c_ns': statistics.median((x['c'] for x in pairs)), 'paired_ratio': statistics.median(ratios), 'paired_ratio_bootstrap_95': [boots[49], boots[1949]], 'samples': pairs}
            rows.append(row)
            print(f'{n:3d} {name:28s} {row['paired_ratio']:.3f} [{boots[49]:.3f}, {boots[1949]:.3f}]', flush=True)
    root = pathlib.Path(__file__).resolve().parents[1]
    repo = root.parents[1]
    paths = [*root.glob('src/*.ad?'), root / 'benchmark.gpr', root / 'tests/cholesky_bench.adb', repo / 'mujoco/src/engine/engine_util_solve.c', repo / 'mujoco/src/engine/engine_util_blas.c']
    report = {'metric': 'kernel/batch time excluding reset and checksums; not integrated dynamics', 'cpu': cpu, 'platform': platform.platform(), 'cpu_model': next((x.split(':', 1)[1].strip() for x in pathlib.Path('/proc/cpuinfo').read_text().splitlines() if x.startswith('model name'))), 'compiler': subprocess.check_output(['gcc', '--version'], text=True).splitlines()[0], 'binary_sha256': hashlib.sha256(pathlib.Path(a.binary).read_bytes()).hexdigest(), 'source_sha256': {str(x.relative_to(repo)): hashlib.sha256(x.read_bytes()).hexdigest() for x in paths}, 'rows': rows}
    a.output.parent.mkdir(parents=True, exist_ok=True)
    a.output.write_text(json.dumps(report, indent=2) + '\n')
if __name__ == '__main__':
    main()
