"""Freeze all sources; leave shared builds and source files untouched."""
import argparse, hashlib, json, os, re, shutil, subprocess
from pathlib import Path
HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
FOLDERS = ['src', 'src/gen', 'experimental/smooth/src',
    'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
    'experimental/constrained-step/src', 'experimental/rigid-collision-candidate/src',
    'experimental/constraint-assembly-candidate/src', 'experimental/constraint-solvers-candidate/src',
    'experimental/joint-limit-candidate/src', 'experimental/frictionless-contact-candidate/src',
    'experimental/inverse-dynamics/src',
    'experimental/inverse-dynamics/tests',
    'experimental/dynamics-derivatives-candidate/src', 'experimental/dynamics-derivatives-candidate/tests']
def environment():
    env = os.environ.copy(); tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH'] = ':'.join(str(next((tc/n).glob('*/bin')))
        for n in ('gnat', 'gprbuild', 'gnatprove')) + ':' + env['PATH']
    return env
def compiler_flags(mode, *, lto=None):
    """Checked profiles; release LTO defaults on, with explicit diagnostic controls."""
    if mode not in ('validation', 'release'):
        raise ValueError(mode)
    use_lto = mode == 'release' if lto is None else lto
    flags = ['-gnat2022', '-ffp-contract=off']
    flags += (['-O3', '-gnatn', '-march=native'] if mode == 'release' else
              ['-O1', '-g', '-gnata', '-gnato', '-gnatVa'])
    return flags + (['-flto=1'] if use_lto else [])

def solver_kernel_switches(mode, flags):
    """GPR per-file release preference; preserve ordinary validation switches."""
    if mode not in ('validation', 'release'):
        raise ValueError(mode)
    if mode == 'validation':
        return ''
    selected = flags + ['-mprefer-vector-width=256']
    return (' for Switches ("mj-solver_kernels.adb") use (' +
            ', '.join('"' + flag + '"' for flag in selected) + ');\n')

def linker_flags(mode, *, lto=None):
    if mode not in ('validation', 'release'):
        raise ValueError(mode)
    use_lto = mode == 'release' if lto is None else lto
    if not use_lto:
        return ['-lm']
    return ['-lm', '-O3' if mode == 'release' else '-O1',
            *(['-march=native'] if mode == 'release' else []),
            '-ffp-contract=off', '-flto=1']

def main():
    p = argparse.ArgumentParser(); p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['validation','release'], default='validation')
    p.add_argument('--resume', action='store_true')
    p.add_argument('--prepare-only', action='store_true', help='Freeze sources for minimal proof; do not compile or claim a build gate')
    p.add_argument('--foundation', type=Path,
        help='Use a verified 3.17 foundation source closure instead of production 3.14')
    p.add_argument('--working-dependencies', action='store_true',
        help='On resume, refresh the full current closure instead of only owned sources')
    a = p.parse_args()
    a.out = a.out.resolve()
    if a.resume:
        previous=json.loads((a.out/'reference.json').read_text())['reference']
        intended='3.17.0' if a.foundation else '3.14.0'
        if previous != intended:
            raise RuntimeError('Reference change on resume: use a fresh output tree (3.17 requires --foundation)')
    a.out.mkdir(parents=True, exist_ok=a.resume)
    snap = a.out/'source'; manifest = a.out/'sources.json'
    hashes = json.loads(manifest.read_text()) if a.resume else {}
    refreshed = []
    for folder in (FOLDERS[-2:] if a.resume and not a.working_dependencies else FOLDERS):
        for f in (ROOT/folder).iterdir():
            if f.is_file() and f.suffix in ('.ads','.adb','.py'):
                data = f.read_bytes(); rel = f.relative_to(ROOT)
                dest = snap/rel; dest.parent.mkdir(parents=True, exist_ok=True)
                if not dest.exists() or dest.read_bytes() != data: dest.write_bytes(data)
                hashes[str(rel)] = hashlib.sha256(data).hexdigest(); refreshed.append(str(rel))
    # Freeze the test providers and guard too: tests run from this complete
    # source snapshot without borrowing mutable files from the working tree.
    for name in ['experimental/adhesion-contact-integration/tests/compare_adhesion.py',
                 'experimental/alignment-3.17/tests/test_admission.py', 'tools/guarded.py']:
        data=(ROOT/name).read_bytes();dest=snap/name;dest.parent.mkdir(parents=True,exist_ok=True)
        if not dest.exists() or dest.read_bytes()!=data:dest.write_bytes(data)
        hashes[name]=hashlib.sha256(data).hexdigest();refreshed.append(name)
    rel = HERE.relative_to(ROOT)/'derivatives.gpr'; data = (ROOT/rel).read_bytes()
    if not (snap/rel).exists() or (snap/rel).read_bytes()!=data: (snap/rel).write_bytes(data)
    hashes[str(rel)] = hashlib.sha256(data).hexdigest(); refreshed.append(str(rel))
    foundation_receipt = None
    if a.foundation:
        foundation = a.foundation.resolve()
        prior_path = foundation/'manifest.json'
        prior = json.loads(prior_path.read_text())
        assert prior['reference'] == '3.17.0'
        assert prior['commit'] == '800a109a4bdd02cb60404d565db4ae16fb04a53b'
        prior_hash = hashlib.sha256(prior_path.read_bytes()).hexdigest()
        for mode in ['validation', 'release']:
            gate = json.loads((foundation/('verify-'+mode)/'results.json').read_text())
            assert gate['complete'] and gate['passed'] and gate['source_hashes_unchanged']
            assert gate['manifest_sha256'] == prior_hash
        copied = {}
        for name, expected in prior['candidate_sources'].items():
            if not name.startswith('src/'): continue
            origin = foundation/'source'/name
            data = origin.read_bytes()
            assert hashlib.sha256(data).hexdigest() == expected, name
            dest = snap/name; dest.parent.mkdir(parents=True, exist_ok=True)
            if not dest.exists() or dest.read_bytes() != data: dest.write_bytes(data)
            hashes[name] = expected; copied[name] = expected
            if name in refreshed: refreshed.remove(name)
        foundation_receipt = dict(reference=prior['reference'], commit=prior['commit'],
            manifest_sha256=prior_hash, library_sources=copied)
    # The structural kernels have no model-ABI dependency. The 3.17 foundation
    # already supplies them; legacy closures need the same proved ghost lemmas.
    for name in ['mj-model_structures.ads','mj-model_structures.adb']:
        helper_rel='src/'+name;dest=snap/helper_rel
        if not dest.exists():
            data=(ROOT/'experimental/alignment-3.17/src'/name).read_bytes()
            dest.write_bytes(data);hashes[helper_rel]=hashlib.sha256(data).hexdigest()
    version=re.search(r'Version_Header\s*:\s*constant\s*:=\s*(\d+)',
        (snap/'src/gen/mj-models.ads').read_text())
    expected_header=3_017_000 if a.foundation else 3_014_000
    if version is None or int(version[1]) != expected_header:
        raise RuntimeError('Frozen model ABI does not match the selected reference; provide a matching foundation')
    changed = [f for f,h in hashes.items()
        if hashlib.sha256(((ROOT if f in refreshed else snap)/f).read_bytes()).hexdigest()!=h]
    if changed: raise RuntimeError('Concurrent changes during snapshot: '+repr(changed))
    manifest.write_text(json.dumps(hashes, indent=2)+'\n')
    (a.out/'reference.json').write_text(json.dumps(foundation_receipt or dict(reference='3.14.0'), indent=2)+'\n')
    if a.prepare_only:
        print(json.dumps(dict(prepared=True,compiled=False,sources_sha256=hashlib.sha256(manifest.read_bytes()).hexdigest())))
        return
    env = environment(); env['DERIVATIVES_BUILD_ROOT'] = str(a.out/'build')
    env['DERIVATIVES_MODE'] = a.mode
    cmd = ['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','600','--',
           'gprbuild','-P',str(snap/rel),'-j1']
    with (a.out/('build-'+a.mode+'.log')).open('w') as log:
        r = subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT)
    unchanged=all(hashlib.sha256((snap/n).read_bytes()).hexdigest()==v for n,v in hashes.items())
    receipt=dict(mode=a.mode,exit=r.returncode,source_hashes_unchanged=unchanged,
        sources_sha256=hashlib.sha256(manifest.read_bytes()).hexdigest(),
        reference_sha256=hashlib.sha256((a.out/'reference.json').read_bytes()).hexdigest(),
        command=cmd,passed=r.returncode==0 and unchanged)
    (a.out/('build-'+a.mode+'-result.json')).write_text(json.dumps(receipt,indent=2)+'\n')
    if not unchanged:raise RuntimeError('Frozen source changed during build')
    if r.returncode:
        print((a.out/('build-'+a.mode+'.log')).read_text()[-5500:])
    else: print(a.out/'build'/a.mode/'bin/derivatives_probe')
    raise SystemExit(r.returncode)
if __name__ == '__main__': main()
