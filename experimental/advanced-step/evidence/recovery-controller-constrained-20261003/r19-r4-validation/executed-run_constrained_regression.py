"""Run the integrated controller corpus serially against one frozen build."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import mujoco
from build import ROOT


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['validation', 'release'], default='validation')
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    source = a.build/'source'
    manifest = json.loads((a.build/'manifest.json').read_text())
    assert all(digest(source/n) == h for n,h in manifest['sources'].items())
    binary = a.build/'build'/a.mode/'bin'
    tests = source/'experimental/advanced-step/tests'
    jobs = [
        ('edges', tests/'controller_edges.py', ['--bin-dir', str(binary)]),
        ('minimum', tests/'compare_constrained.py', ['--binary', str(binary/'constrained_advanced_probe'), '--only', 'combo_', '--samples', '2', '--steps', '10']),
        ('smooth', tests/'compare.py', ['--binary', str(binary/'advanced_probe')]),
        ('fixed', tests/'compare_constrained.py', ['--binary', str(binary/'constrained_advanced_probe')]),
        ('mobile', tests/'compare_constrained.py', ['--binary', str(binary/'constrained_advanced_probe'), '--contact-mobility', 'free-carrier']),
        ('parent', source/'experimental/constrained-step/tests/compare.py', ['--binary', str(binary/'constrained_probe'), '--samples', '2']),
    ]
    record = dict(mode=a.mode, reference=mujoco.__version__, source_manifest=manifest,
                  reference_libraries={str(f): digest(f) for f in Path(mujoco.__file__).parent.glob('libmujoco.so.*')},
                  runner_sha256=digest(Path(__file__)),
                  binaries={f.name: digest(f) for f in binary.iterdir() if f.is_file()}, jobs=[])
    for label, script, args in jobs:
        command = [sys.executable, str(script), *args, '--out', str(a.out/label)]
        with (a.out/(label+'.log')).open('w') as log:
            result = subprocess.run([sys.executable, str(ROOT/'tools/guarded.py'),
                '--cap-mb', '2800', '--min-free-mb', '700', '--timeout', '240', '--', *command],
                stdout=log, stderr=subprocess.STDOUT)
        record['jobs'].append(dict(name=label, exit=result.returncode, command=command,
                                   driver_sha256=digest(script)))
        (a.out/'results.json').write_text(json.dumps(record, indent=2)+'\n')
        print(label, result.returncode, (a.out/(label+'.log')).read_text()[-250:], flush=True)
    assert all(digest(source/n) == h for n,h in manifest['sources'].items())
    record['sources_unchanged'] = True
    record['passed'] = all(r['exit'] == 0 for r in record['jobs'])
    (a.out/'results.json').write_text(json.dumps(record, indent=2)+'\n')
    raise SystemExit(not record['passed'])


if __name__ == '__main__':
    main()
