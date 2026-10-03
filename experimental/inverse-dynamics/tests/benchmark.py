"""Complete inverse evaluations versus native C, not forward movement timings."""
import argparse, hashlib, json, os, platform, subprocess
from pathlib import Path
import mujoco
import numpy as np

HERE = Path(__file__).resolve().parent

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--models', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--rounds', type=int, default=9)
    args = p.parse_args()
    args.out.mkdir(parents=True, exist_ok=False)
    libdir = Path(mujoco.__file__).resolve().parent
    c = args.out / 'reference_bench'
    library = libdir / 'libmujoco.so.3.14.0'
    command = ['cc', '-O3', '-ffp-contract=off', '-I', str(libdir / 'include'),
               str(HERE / 'reference_bench.c'), str(library), '-lm',
               '-Wl,-rpath,' + str(libdir), '-o', str(c)]
    subprocess.run(command, check=True, capture_output=True)
    cpu = min(os.sched_getaffinity(0))
    names = ['smooth-slide', 'smooth-branched_multijoint', 'smooth-chain12',
             'smooth-mixed-ellipsoid-free-muscle-False-normal-True',
             'smooth-mixed-box-ball-filterexact-False-normal-True']
    models = [args.models / (name + '.mjb') for name in names]
    models = [m for m in models if m.exists()]
    records = []
    for model in models:
        for mode in ['warm', 'cold']:
            repeats = 100_000 if mode == 'warm' else 10_000
            samples = {'ada': [], 'c': []}
            checksums = {'ada': [], 'c': []}
            for round in range(args.rounds + 1):
                order = ['ada', 'c'] if round % 2 == 0 else ['c', 'ada']
                for lang in order:
                    binary = args.binary if lang == 'ada' else c
                    result = subprocess.run([str(binary), str(model), str(repeats), mode],
                        text=True, capture_output=True, check=True, timeout=60,
                        preexec_fn=lambda: os.sched_setaffinity(0, {cpu}))
                    elapsed, checksum = map(float, result.stdout.split())
                    if round:
                        samples[lang].append(elapsed / repeats)
                        checksums[lang].append(checksum)
                if not np.isclose(checksum, checksums['ada'][-1] if round else checksum, atol=1e-6, rtol=2e-10):
                    raise AssertionError('inverse trajectory checksum')
            if not np.allclose(checksums['ada'], checksums['c'], atol=1e-6, rtol=2e-10):
                raise AssertionError((model, checksums))
            ratio = np.asarray(samples['ada']) / np.asarray(samples['c'])
            record = dict(model=model.stem, mode=mode, repeats=repeats, samples_seconds=samples,
                          checksums=checksums, ada_us=float(np.median(samples['ada'])*1e6),
                          c_us=float(np.median(samples['c'])*1e6), paired_ratio=float(np.median(ratio)),
                          ratio_p10_p90=np.quantile(ratio, [.1,.9]).tolist())
            records.append(record)
            print(model.stem, mode, record['paired_ratio'], flush=True)
    report = dict(scope='Continuous inverse evaluations; cold includes position/velocity preparation; warm reuses both stages. No complete forward movement/performance claim.',
                  cpu=cpu, platform=platform.platform(), reference=mujoco.__version__, command=command,
                  binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
                  library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(), records=records)
    (args.out / 'performance.json').write_text(json.dumps(report, indent=2) + '\n')

if __name__ == '__main__':
    main()
