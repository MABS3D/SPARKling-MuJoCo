"""Freeze the complete foundation source library plus 3.17 admission overlay.

This preparation does not inherit a full-validator proof or any runtime gate.
Only the verified 3.17 foundation source closure is used; production is untouched.
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[3]
PIN = '800a109a4bdd02cb60404d565db4ae16fb04a53b'

def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--foundation',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    args=parser.parse_args();foundation=args.foundation.resolve();out=args.out.resolve()
    assert not out.is_relative_to(ROOT)
    prior_path=foundation/'manifest.json';prior=json.loads(prior_path.read_text())
    assert prior['reference']=='3.17.0' and prior['commit']==PIN
    for mode in ['validation','release']:
        result=json.loads((foundation/('verify-'+mode)/'results.json').read_text())
        assert result['complete'] and result['passed'] and result['source_hashes_unchanged']
        assert result['manifest_sha256']==digest(prior_path)
    out.mkdir(parents=True,exist_ok=False);source=out/'source';source.mkdir()
    original={}
    for name,value in prior['candidate_sources'].items():
        if not (name.startswith('src/') or name=='sparkling_mujoco.gpr'):continue
        p=foundation/'source'/name;assert digest(p)==value,name
        target=source/name;target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,target)
        original[name]=value
    overlay=ROOT/'experimental/alignment-3.17/overlays/validation-structures.patch'
    target=source/'experimental/alignment-3.17/overlays'/overlay.name
    target.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(overlay,target)
    already_applied = bool(prior.get('structural_overlay'))
    with (out/'apply-overlay.log').open('w') as log:
        if already_applied:
            assert prior['structural_overlay']['sha256'] == digest(overlay), 'Different overlay already applied; regenerate the foundation or use an unoverlaid baseline'
            log.write('Verified identical structural overlay already applied by the foundation builder; patch not applied twice.\n')
        else:
            subprocess.run(['patch','--batch','--fuzz=0','-p1','-i',str(target)],cwd=source,stdout=log,stderr=subprocess.STDOUT,check=True)
    for p in (ROOT/'experimental/alignment-3.17/src').glob('*.ad?'):
        assert (source/'src'/p.name).read_bytes()==p.read_bytes(),p.name
    assert all(digest(foundation/'source'/n)==v for n,v in original.items())
    hashes={str(p.relative_to(source)):digest(p) for p in sorted(source.rglob('*')) if p.is_file()}
    manifest=dict(reference='3.17.0',commit=PIN,phase='admission-prepared',
        foundation_manifest_sha256=digest(prior_path),base_library_sources=original,candidate_sources=hashes,
        overlay_sha256=digest(overlay),overlay_already_applied=already_applied,runner_sha256=digest(Path(__file__)),production_applied=False,
        scope='Complete foundation source library with structural admission overlay; compilation, proofs and runtime/model validation pending. Corpus and engine consumers are not copied or claimed.')
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    print(json.dumps(dict(reference='3.17.0',frozen=True,files=len(hashes),manifest_sha256=digest(out/'manifest.json'))))

if __name__=='__main__':main()
