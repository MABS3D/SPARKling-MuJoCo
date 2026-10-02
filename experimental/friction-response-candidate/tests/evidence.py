"""Immutable candidate snapshots; no writes outside this candidate and /var/tmp."""
import hashlib
import os
from pathlib import Path
import shutil
import subprocess

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
TC = Path('/var/tmp/sparkling-matrix-recovery/toolchains')

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def environment(out):
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((TC / x).glob('*/bin')))
                          for x in ('gnat', 'gprbuild', 'gnatprove')) + ':' + env['PATH']
    env['FRICTION_BUILD_ROOT'] = str(out / 'build')
    return env

def freeze(out):
    out.mkdir(parents=True, exist_ok=False)
    target = out / 'snapshot'
    files = [HERE / 'friction.gpr', *sorted((HERE / 'src').glob('*')),
             *sorted((HERE / 'tests').glob('*.adb')),
             *sorted((HERE / 'tests').glob('*.py')),
             ROOT / 'src/mj.ads', ROOT / 'src/mj-types.ads']
    manifest = {}
    for source in files:
        relative = (Path('root-src') / source.name if source.parent == ROOT / 'src'
                    else source.relative_to(HERE))
        dest = target / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        content = source.read_bytes()
        dest.write_bytes(content)
        manifest[str(source.relative_to(ROOT))] = hashlib.sha256(content).hexdigest()
    project = target / 'friction.gpr'
    project.write_text(project.read_text().replace('"../../src"', '"root-src"'))
    return target, manifest

def unchanged(manifest):
    return all(digest(ROOT / name) == sha for name, sha in manifest.items())

def versions(env):
    return {tool: subprocess.run([tool, '--version'], env=env, text=True,
                                capture_output=True, check=True).stdout.splitlines()[0]
            for tool in ('gprbuild', 'gnatprove')}
