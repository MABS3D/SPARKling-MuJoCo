from pathlib import Path
import hashlib,json,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence'
D=E/'20261026-row-window-profile-r792';P=Path('/var/tmp/sparkling-profile-row-window-r791-20261026')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 d=json.loads((P/'results.json').read_text());assert d['passed'];summaries={r:json.loads((P/(r+'.summary.json')).read_text()) for r in ['current','c']}
 assert all(v['collection_valid'] for v in summaries.values())
 D.mkdir();shutil.copy2(__file__,D/'package.py');members={};zpath=D/'profile.zip'
 with zipfile.ZipFile(zpath,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  for p in sorted(P.iterdir()):
   if p.is_file():members[p.name]=sha(p);z.write(p,p.name)
 with zipfile.ZipFile(zpath) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'summary.json',dict(passed=True,profile=d,functions={r:v['functions'][:12] for r,v in summaries.items()},files=members,zip_sha256=sha(zpath),scope='Actual adopted row-window binary,5000 numeric endpoints per role, qualified main-thread CPU-timer PC sampling on chain24 state0. Flat shares include initialization/printing and signal overhead. This is diagnostic location evidence, not causal savings or a substitute for the replicated acceptance measurements. Executables and full build/source closure are in the preceding r790 exact archive, identified by matching SHA256.'))
 (D/'README.md').write_text('''# Current row-window diagnostic profile

The actual final adopted row-window binary and pinned normal native C3.17 each
pass5000 numerical endpoints with qualified main-thread CPU-timer collection.
There is no overlapping own proof/build/archive/Git activity during collection.
Current Ada has1898 samples; C has911. Observed CPU time includes sampling,
initialization and printing and is not acceptance timing.

Ada's leading flat functions are packed factor/solve17.02%, acceleration
preparation16.70%, long row updates11.38%, compact mass10.54% and recursive
forces8.90%. C's leading functions include scaled addition18.33%, Jacobian7.46%,
solveLD7.24%, CRB6.81% and factorI6.48%. These are locations for investigation,
not independent causal contributions or obtainable savings. Inlining affects
function attribution. The samples do not establish full-port performance.

Full raw PCs/maps, complete timer metadata, sampler/source, frozen provider,
output endpoints, commands and hashes are preserved in profile.zip. Executables
and complete source/build closures are preserved in the preceding r790 archive.
Restore with tools/evidence_store.py restore using the repository-relative path.
No new code adoption, commit or push occurs in this diagnostic checkpoint.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(zip_bytes=zpath.stat().st_size,inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
