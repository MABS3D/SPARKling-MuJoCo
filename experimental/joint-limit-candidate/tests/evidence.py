"""Immutable source receipts and pinned C reference for this isolated candidate."""
from pathlib import Path
import hashlib, json, os, platform, subprocess

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
TOOLCHAIN = Path('/var/tmp/sparkling-matrix-recovery/toolchains')

def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def environment():
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((TOOLCHAIN / x).glob('*/bin')))
                          for x in ['gnat', 'gprbuild', 'gnatprove']) + ':' + env['PATH']
    return env

def snapshot():
    paths = [ROOT / 'src' / name for name in
             ['mj.ads', 'mj-types.ads', 'mj-blas.ads', 'mj-blas.adb',
              'mj-vector_models.ads', 'mj-vector_models.adb', 'mj-quaternion_math.ads']]
    paths += [ROOT / 'experimental/frictionless-contact-candidate/src' / name
              for name in ['mj-contact_rows.ads', 'mj-contact_rows.adb']]
    paths += [ROOT / 'tools/guarded.py', HERE / 'results/reference.json']
    paths += list(HERE.glob('*.gpr')) + list((HERE / 'src').glob('*.ad?'))
    paths += [p for p in (HERE / 'tests').glob('*') if p.is_file()]
    ref = json.loads((HERE / 'results/reference.json').read_text())
    for rel, wanted in ref['normalized_sha256'].items():
        p = ROOT / 'mujoco' / rel
        assert hashlib.sha256(p.read_bytes().replace(b'\r\n', b'\n')).hexdigest() == wanted, rel
        paths.append(p)
    return {str(p.relative_to(ROOT)): digest(p) for p in sorted(paths)}

def provenance(env):
    result = {'platform': platform.platform(),
              'cpu': Path('/proc/cpuinfo').read_text().split('\n\n')[0]}
    for tool in ['gcc', 'gprbuild', 'gnatprove']:
        p = subprocess.run([tool, '--version'], env=env, text=True,
                           capture_output=True, timeout=10)
        result[tool] = (p.stdout + p.stderr).splitlines()[0]
    # Record the actual system numerical runtime linked by both executables.
    result['runtime_libraries'] = {}
    for line in Path('/proc/self/maps').read_text().splitlines():
        words = line.split()
        if len(words) >= 6:
            p = Path(words[-1])
            if p.is_file() and (p.name.startswith('libm.so') or p.name.startswith('libc.so')):
                result['runtime_libraries'][str(p)] = digest(p)
    return result
