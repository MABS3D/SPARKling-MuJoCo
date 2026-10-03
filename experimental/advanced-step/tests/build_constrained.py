"""Freeze shared sources and apply reviewed controller hooks only in the copy."""
import argparse
import hashlib
import json
import shutil
import subprocess
from pathlib import Path
from build import environment, ROOT, HERE

FOLDERS = ['src', 'src/gen', 'experimental/smooth/src',
    'experimental/spatial-tendon-candidate/src', 'experimental/muscle-candidate/src',
    'experimental/advanced-actuation-candidate/src',
    'experimental/constrained-step/src', 'experimental/constrained-step/tests',
    'experimental/rigid-collision-candidate/src',
    'experimental/constraint-assembly-candidate/src', 'experimental/constraint-solvers-candidate/src',
    'experimental/joint-limit-candidate/src', 'experimental/frictionless-contact-candidate/src',
    'experimental/advanced-step/src', 'experimental/advanced-step/tests']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser()
    p.add_argument('--out', type=Path, required=True)
    p.add_argument('--mode', choices=['validation', 'release'], default='validation')
    p.add_argument('--resume', action='store_true')
    p.add_argument('--frozen', action='store_true')
    p.add_argument('--factory-hooks', choices=['apply','present'], default='apply',
                   help='apply the scoped patch, or require hooks already present in the immutable parent')
    p.add_argument('--base-snapshot', type=Path,
                   help='existing immutable common source root; owned controller inputs remain local')
    a = p.parse_args()
    if a.resume and a.frozen: p.error('--resume and --frozen are exclusive')
    a.out = a.out.resolve(); a.out.mkdir(parents=True, exist_ok=a.resume or a.frozen)
    snap = a.out/'source'
    manifest = json.loads((a.out/'manifest.json').read_text()) if a.resume or a.frozen else {}
    hashes = manifest.get('sources', {})
    origins = {}
    common_manifest = None
    if a.base_snapshot:
        a.base_snapshot = a.base_snapshot.resolve()
        common_path = a.base_snapshot.parent/'manifest.json'
        common_manifest = json.loads(common_path.read_text())
        assert all(digest(a.base_snapshot/f)==h for f,h in common_manifest['sources'].items()), 'common snapshot changed'
        manifest['common_snapshot'] = dict(source=str(a.base_snapshot), manifest_sha256=digest(common_path))
    for folder in ([] if a.frozen else FOLDERS[-2:] if a.resume else FOLDERS):
        owned = folder.startswith('experimental/advanced-step/') or folder == 'experimental/advanced-actuation-candidate/src'
        origin = ROOT if owned or not a.base_snapshot else a.base_snapshot
        for src in (origin/folder).iterdir():
            if src.is_file() and src.suffix in ['.ads','.adb','.py','.c']:
                rel = src.relative_to(origin); dst = snap/rel
                dst.parent.mkdir(parents=True, exist_ok=True)
                data = src.read_bytes()
                if not dst.exists() or dst.read_bytes() != data: dst.write_bytes(data)
                hashes[str(rel)] = digest(dst)
                origins[str(rel)] = src
    rel = Path('experimental/advanced-step/constrained_advanced.gpr')
    if not a.frozen:
        for name in ['constrained_advanced.gpr', 'controller_proof.gpr', 'controller_arrays_proof.gpr', 'controller_state_proof.gpr']:
            project_rel = Path('experimental/advanced-step')/name
            shutil.copyfile(ROOT/project_rel, snap/project_rel)
            hashes[str(project_rel)] = digest(snap/project_rel)
    if not (a.resume or a.frozen):
        assert all(digest(src)==hashes[f] for f,src in origins.items()), 'concurrent source edits'
        parent_paths = [str(Path('experimental/constrained-step/src')/('mj-data-constrained.'+suffix)) for suffix in ('ads','adb')]
        if a.factory_hooks == 'present':
            ads, adb = [(snap/f).read_text() for f in parent_paths]
            assert ads.count('procedure Create_Core') == 1 and ads.count('procedure Generate_Contacts') == 1, 'private hooks missing'
            assert adb.count('procedure Create_Core') == 1 and 'Create_Core (M, E, Result, Dynamics_Only => False);' in adb, 'ordinary factory wrapper missing'
            assert 'MJ.Data.Create_Dynamics (M, E.D, Result);' in adb and 'if Dynamics_Only then' in adb, 'dynamics factory branch missing'
            manifest['hooks'] = dict(already_present=True, files={f:hashes[f] for f in parent_paths})
        else:
            hook = HERE/'integration/advanced-factory-hooks.patch'
            metadata = json.loads((HERE/'integration/advanced-factory-hooks.json').read_text())
            assert all(hashes[f]==v['before'] for f,v in metadata.items()), 'hook baseline changed'
            shutil.copyfile(hook, a.out/'advanced-factory-hooks.patch')
            subprocess.run(['git','apply','--check',str(a.out/'advanced-factory-hooks.patch')], cwd=snap, check=True)
            subprocess.run(['git','apply',str(a.out/'advanced-factory-hooks.patch')], cwd=snap, check=True)
            for f,v in metadata.items():
                hashes[f] = digest(snap/f)
                assert hashes[f] == v['after'], 'unexpected hook result'
            manifest['hooks'] = dict(sha256=digest(hook), files=metadata)
    assert all(digest(snap/f)==h for f,h in hashes.items()), 'frozen source changed'
    env = environment(); env['ADVANCED_BUILD_ROOT'] = str(a.out/'build'); env['ADVANCED_MODE'] = a.mode
    cmd = ['gprbuild','-P',str(snap/rel),'-j1']
    manifest.update(sources=hashes, mode=a.mode, frozen=a.frozen, command=cmd)
    (a.out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    with (a.out/('build-'+a.mode+'.log')).open('w') as log:
        result = subprocess.run(['python3', str(ROOT/'tools/guarded.py'), '--cap-mb','3000',
            '--min-free-mb','700','--timeout','600','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
    print(a.out/('build-'+a.mode+'.log'));raise SystemExit(result.returncode)

if __name__ == '__main__':main()
