"""Compose a draft signed FS hook with individually frozen dependencies."""
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
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', required=True, type=Path)
    a = parser.parse_args()
    a.out.mkdir(parents=True, exist_ok=False)
    source = a.out / 'source'
    hashes, origins, dependencies = {}, {}, {}
    layers = [
        ('/var/tmp/sparkling-recovery-sdf-geom-order2-20261003', 'nested', None),
        ('/var/tmp/sparkling-recovery-flex-interpolated-state3-20261003', 'nested',
         'experimental/flex-state-integration/'),
        ('/var/tmp/sparkling-recovery-bvh-cache14-20261003', 'nested',
         'experimental/advanced-collision-candidate/src/mj-bvh.'),
        ('/var/tmp/sparkling-recovery-shell-weights5-20261003', 'flat',
         'experimental/flex-state-integration/src/mj-flex_shell_weights.'),
        ('/var/tmp/sparkling-recovery-shell-geometry2-20261003', 'flat',
         'experimental/flex-state-integration/src/mj-flex_shell_geometry.')]
    for folder, layout, prefix in layers:
        base = Path(folder)
        manifest = json.loads((base / 'manifest.json').read_text())
        dependencies[folder] = digest(base / 'manifest.json')
        for name, expected in manifest['sources'].items():
            if prefix is not None and not name.startswith(prefix):
                continue
            original = base / 'source' / (Path(name).name if layout == 'flat' else name)
            if digest(original) != expected:
                raise RuntimeError('changed frozen dependency ' + str(original))
            destination = source / name
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(original, destination)
            hashes[name], origins[name] = expected, str(original)
    # All common sources used by both standalone shell proofs must coincide.
    for folder in (layers[3][0], layers[4][0]):
        m = json.loads((Path(folder) / 'manifest.json').read_text())
        for name, value in m['sources'].items():
            if '/tests/' not in name and hashes.get(name) != value:
                raise RuntimeError('shell proof dependency differs: ' + name)
    here = 'experimental/flex-state-integration/'
    for name in ('mj-flex_state.ads', 'mj-flex_state.adb'):
        original = ROOT / here / 'integration/shell-state' / name
        dest = source / here / 'src' / name
        shutil.copyfile(original, dest)
        rel = str(dest.relative_to(source))
        hashes[rel], origins[rel] = digest(dest), str(original)
    tests = ('flex_shell_state_probe.adb', 'compare_shell_state.py', 'compare.py',
             'compare_interpolated_state.py', 'policy_interpolation.py')
    for name in tests:
        original = ROOT / here / 'tests' / name
        dest = source / here / 'tests' / name
        shutil.copyfile(original, dest)
        rel = str(dest.relative_to(source))
        hashes[rel], origins[rel] = digest(dest), str(original)
    project = source / here / 'flex_state.gpr'
    project.write_text(project.read_text().replace('flex_state_probe.adb', 'flex_shell_state_probe.adb'))
    hashes[str(project.relative_to(source))] = digest(project)
    shutil.copyfile(ROOT / 'tools/guarded.py', a.out / 'guarded.py')
    shutil.copyfile(Path(__file__), a.out / Path(__file__).name)
    env = environment()
    env.update(OPENBLAS_NUM_THREADS='1', OMP_NUM_THREADS='1',
               FLEX_STATE_BUILD_ROOT=str(a.out / 'build'))
    rows = []
    manifest = dict(sources=hashes, origins=origins, dependencies=dependencies, steps=rows,
                    runner_sha256=digest(Path(__file__)), guarded_sha256=digest(a.out / 'guarded.py'),
                    complete=False, live_FS_changed=False, performance='not measured')

    def save():
        (a.out / 'manifest.json').write_text(json.dumps(manifest, indent=2) + '\n')

    def run(name, command, wall=360):
        cmd = ['/var/tmp/sparkling-movement-env/bin/python', str(a.out / 'guarded.py'),
               '--cap-mb', '2500', '--timeout', str(wall), '--', *command]
        start = time.monotonic()
        with (a.out / (name + '.log')).open('w') as log:
            r = subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT)
        rows.append(dict(name=name, command=cmd, exit=r.returncode, seconds=time.monotonic() - start))
        save()
        print(json.dumps(rows[-1]), flush=True)
        return r.returncode

    save()
    py = '/var/tmp/sparkling-movement-env/bin/python'
    for mode in ('validation', 'release'):
        env['FLEX_STATE_MODE'] = mode
        if run('build-' + mode, ['gprbuild', '-P', str(project), '-j1']):
            raise SystemExit(1)
        binary = a.out / 'build' / mode / 'bin/flex_shell_state_probe'
        # Every native shell model runs in an independent process; preserve an
        # abort or missing result as a failure while allowing other models to run.
        for degree, cells in ((1, '1x1x1'), (1, '2x2x2'), (2, '1x1x1'), (2, '2x1x2')):
            for shape in ('plane', 'sphere', 'box'):
                for variant in ('plain', 'pinned', 'rotated', 'mixed'):
                    name = f'shell{degree}_{cells}_{shape}_{variant}'
                    run(mode + '-' + name, [py, str(source / here / 'tests/compare_shell_state.py'),
                        '--binary', str(binary), '--out', str(a.out / mode / name), '--samples', '4',
                        '--only', name], wall=180)
        for scope, script in (('positive', 'compare_interpolated_state.py'), ('ordinary', 'compare.py')):
            run(mode + '-' + scope, [py, str(source / here / 'tests' / script),
                '--binary', str(binary), '--out', str(a.out / mode / scope)], wall=600)
        run(mode + '-admission', [py, str(source / here / 'tests/policy_interpolation.py'),
            '--binary', str(binary), '--fixtures', str(a.out / mode / 'positive'),
            '--out', str(a.out / mode / 'admission')], wall=180)
    for name, expected in hashes.items():
        if digest(source / name) != expected:
            raise RuntimeError('frozen source changed: ' + name)
    manifest['complete'] = True
    save()
    raise SystemExit(any(row['exit'] for row in rows))


if __name__ == '__main__':
    main()
