"""Renew shell fixtures against two immutable, already compiled FS binaries."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

from build import ROOT, environment


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    source = a.out / 'source'
    source.mkdir()
    m = json.loads((a.build / 'manifest.json').read_text())
    for name, value in m['sources'].items():
        if digest(a.build / 'source' / name) != value:
            raise RuntimeError('build source changed: ' + name)
    here = ROOT / 'experimental/flex-state-integration/tests'
    for name in ('compare.py', 'compare_shell_state.py'):
        shutil.copyfile(here / name, source / name)
    shutil.copyfile(ROOT / 'tools/guarded.py', a.out / 'guarded.py')
    env = environment()
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1')
    rows = []
    manifest = dict(build=str(a.build), build_manifest_sha256=digest(a.build / 'manifest.json'),
        build_sources=m['sources'], tests={p.name:digest(p) for p in source.iterdir()},
        runner_sha256=digest(Path(__file__)), guarded_sha256=digest(a.out / 'guarded.py'),
        steps=rows, complete=False, performance='not measured', binaries={})
    for mode in ('validation', 'release'):
        binary = a.build / 'build' / mode / 'bin/flex_shell_state_probe'
        manifest['binaries'][mode] = dict(path=str(binary), sha256=digest(binary))
        for degree, cells in ((1, '1x1x1'), (1, '2x2x2'), (2, '1x1x1'), (2, '2x1x2')):
            for shape in ('plane', 'sphere', 'box'):
                for variant in ('plain', 'pinned', 'rotated', 'mixed'):
                    name = f'shell{degree}_{cells}_{shape}_{variant}'
                    cmd = ['/var/tmp/sparkling-movement-env/bin/python', str(a.out / 'guarded.py'),
                        '--cap-mb','2500','--timeout','180','--',
                        '/var/tmp/sparkling-movement-env/bin/python', str(source / 'compare_shell_state.py'),
                        '--binary',str(binary),'--out',str(a.out / mode / name),
                        '--samples','4','--only',name]
                    start = time.monotonic()
                    with (a.out / (mode + '-' + name + '.log')).open('w') as log:
                        r = subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT)
                    rows.append(dict(profile=mode, model=name, command=cmd, exit=r.returncode,
                                      seconds=time.monotonic() - start))
                    (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
                    print(mode, name, r.returncode, flush=True)
    manifest['complete'] = True
    (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    raise SystemExit(any(row['exit'] for row in rows))


if __name__ == '__main__':
    main()
