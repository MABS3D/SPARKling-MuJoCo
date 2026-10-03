from pathlib import Path
import hashlib
import json
import os
import subprocess
import time

repo = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
snapshot = Path('/var/tmp/sparkling-services-geometry-normalize-terms3-20261003')
out = Path('/var/tmp/sparkling-services-normalize-runtime-20261003')
out.mkdir(exist_ok=False)
source = snapshot/'source'
manifest = json.loads((snapshot/'manifest.json').read_text())
sha = lambda path: hashlib.sha256(Path(path).read_bytes()).hexdigest()
unchanged = lambda: all(sha(source/name) == h for name, h in manifest['sources'].items())
assert unchanged()
(out/'sources.json').write_text(json.dumps(manifest, indent=2)+'\n')
tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env = os.environ.copy()
env['PATH'] = ':'.join(str(next((tc/name).glob('*/bin'))) for name in ['gnat', 'gprbuild'])+':/usr/bin:/bin'
env['ACTUATION_BUILD_ROOT'] = str(out/'build')
python = '/var/tmp/sparkling-movement-env/bin/python'
rows = []
for mode in ['validation', 'release']:
    env['ACTUATION_MODE'] = mode
    binary = out/'build'/mode/'bin/actuation_probe'
    steps = [
        ('build', ['gprbuild', '-p', '-j1', '-P', str(source/'actuation.gpr'), 'actuation_probe.adb']),
        ('normalize', [python, str(source/'tests/normalize_exact.py'), '--binary', str(binary), '--out', str(out/(mode+'-normalize'))]),
        ('kernel', [python, str(repo/'experimental/advanced-actuation-candidate/tests/compare.py'), '--binary', str(binary), '--source-manifest', str(snapshot/'manifest.json'), '--out', str(out/(mode+'-kernel.json'))]),
        ('expmap', [python, str(source/'tests/expmap_exact.py'), '--binary', str(binary), '--out', str(out/(mode+'-expmap'))]),
    ]
    for label, command in steps:
        started = time.monotonic()
        wrapped = [python, str(repo/'tools/guarded.py'), '--cap-mb', '2400', '--min-free-mb', '700', '--timeout', '180', '--', *command]
        result = subprocess.run(wrapped, env=env, text=True, capture_output=True)
        (out/(mode+'-'+label+'.log')).write_text(result.stdout+result.stderr)
        rows.append(dict(mode=mode, step=label, command=wrapped, exit=result.returncode,
                         elapsed_seconds=time.monotonic()-started, sources_unchanged_after=unchanged()))
        (out/'results.json').write_text(json.dumps(dict(driver_sha256=sha(__file__), steps=rows), indent=2)+'\n')
        print(mode, label, result.returncode, flush=True)
        if result.returncode or not rows[-1]['sources_unchanged_after']:
            raise SystemExit(1)
print('BOTH PROFILES COMPLETE', flush=True)
