from pathlib import Path
import hashlib,json,shutil,subprocess
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');S=R/'experimental/alignment-3.17/evidence/storage';O=Path(__file__).parent
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();m=json.loads((S/'manifest.json').read_text())
referenced=set(m['packs'])|{x['recipe'] for x in m['archives'].values()}|{m['index']['file'],'manifest.json'}
G='/mnt/c/Program Files/Git/cmd/git.exe';raw=subprocess.check_output([G,'ls-files','--others','--exclude-standard','-z','--','experimental/alignment-3.17/evidence/storage'],cwd=R)
paths=[R/x.decode() for x in raw.split(b'\0') if x];assert len(paths)==6,paths
records=[]
for p in paths:
 assert p.parent==S and p.name not in referenced and p.name.startswith(('payloads-','archive-','objects-'))
 digest=sha(p);dest=O/p.name;assert not dest.exists();shutil.move(str(p),str(dest));assert sha(dest)==digest and not p.exists()
 records.append(dict(original=str(p),quarantined=str(dest),sha256=digest,bytes=dest.stat().st_size,referenced_by_manifest=False))
(O/'recovery.json').write_text(json.dumps(dict(passed=True,manifest_unchanged_sha256=sha(S/'manifest.json'),files=records,scope='First single-archive pack wrote unreferenced immutable outputs before rejecting the other newly inventoried ZIP. Only six newly untracked, unreferenced outputs were quarantined with byte hashes; no tracked store file, old recipe, source or raw proof ZIP moved. Repack both new archives together, then verify the complete store/inventory. This preserves the failed attempt rather than overwriting payloads.'),indent=2)+'\n')
print('QUARANTINED UNREFERENCED FAILED-PACK OUTPUTS',len(records),flush=True)
