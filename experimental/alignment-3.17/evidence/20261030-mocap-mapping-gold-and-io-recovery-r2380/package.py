from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-mocap-mapping-gold-and-io-recovery-r2380'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adoption=read(V/'sparkling-mocap-mapping-adoption-r2374-20261030/adoption.json');assert adoption['production_adopted'];assert all(sha(R/n)==h for n,h in adoption['files'].items())
audit=read(V/'sparkling-mocap-final-audit-r2375-20261030/results.json');assert audit['passed'] and audit['output_files']==92 and audit['new_c_comparisons']==1472
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-(20261028|20261030)$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 2261<=int(m[1])<=2375:roots.append(p)
outcomes={};sources=[]
for root in roots:
 p=root/'results.json'
 if p.is_file():
  d=read(p)
  if d.get('obligations_closed'):
   assert d['exit']==0 and d['coverage'] and d['fresh_scoped_report'] and d['representation_complete'] and not d['open'] and d['source_hashes_unchanged'],str(p)
  outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:d.get(k) for k in ['exit','checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed']}}
 for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
for n in [2364,2365,2368,2369]:
 p=next(V.glob(f'sparkling-*-r{n}-20261030/results.json'));assert read(p)['obligations_closed']
for n in [2372,2373]:assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['passed']
# These supervisors were observed terminal with exit135; no result file is
# invented from their partial analysis or from absence of a live process.
interrupted=['sparkling-mocap-reference-opaque-all314-r2295-20261028','sparkling-mocap-mapping-final314-r2301-20261028']
for name in interrupted:assert not (V/name/'results.json').exists()
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'mocap-mapping-gold-and-io-recovery.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  analysis='analysis' in root.name
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if analysis else {'obj','analysis','analysis314','__pycache__','.git'}))
   for name in sorted(files):
    if analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
 for n in adoption['files']:put(R/n,'adopted-production/'+n)
 for n in ['io-interruption-20261028.txt','io-recovery-20261028.py']:put(E/n,'interruption-notes/'+n)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(outcomes=outcomes,interrupted_without_final_report=interrupted,adoption=adoption,final_numerical_audit=audit,source_snapshots=len(sources),source_hashes_checked=sum(len(h) for t,h in sources),whole_state_closed=False,mocap_invariant_adopted=False,new_performance_measured=False))
(D/'README.md').write_text('''# Gold mocap mapping and recovery from the Linux I/O interruption

The actual private Mocap_Mapping_Valid function now proves its exact Boolean
result: IDs are in range, every nonnegative ID is unique, and every mocap slot
is covered. Its full scope closes45 checks on each3.14/3.17 closure, including
termination; the separate coverage lemma closes12 on each. Counts are separate
scopes, not a whole Data-unit claim. Existing warnings are retained. The same
count precondition is preserved, with no assumptions or check suppressions.

The original one-pass seen-array algorithm is retained. Contracts, assertions,
invariants and the coverage lemma are Static. Fresh validation objects emit
neither the Ghost spec nor lemma; the mapping function is372 bytes on both
closures (the previous validation body was382). Code size is not timing.
The C source excerpts show sequential mocap ID allocation and raw pose copying
in mj_resetData; source hashes and the exact fragments are retained.

Final actual source2363 passes368 cases per reference/profile,1472 new C
comparisons, with16 samples,100 steps and unchanged2e-10 tolerances. All92
output files are byte-identical to the previously verified adopted baseline.
Intermediate syntax failures, quantifier timeouts and successful earlier
variants retain their own actual status and source hashes. New shared object
caches were copied for faster rebuilds; prior binaries/reports were preserved.

The Linux I/O failure stopped two supervisors with exit135 before final result
handling. Their partial files are preserved without invented success reports.
Recovered source manifests were rehashed before resuming. The prepared
projection annotation fix correctly qualifies three generated validity clauses.

Private raw-reference proof work closes7 for a copied quaternion on both
references,18 for the whole copied array on3.17,4 for projecting model validity
to body parameters,6 for one body's raw quaternion,26 for the composed owned
reference loop, and10 for its wrapper. The latter scopes are3.17-only and have
their separately recorded callee contracts. Their construction/reset lifecycle
integration remains open; no mocap type invariant is adopted. All unsuccessful
variants and complete setter watchdogs are retained with actual outcomes.

This checkpoint adopts only the proved mapping validator/spec/coverage helper.
Whole state/dynamics Gold, full features, coordinated latest ABI migration and
integrated C performance parity remain open. No new timing is claimed and no
additional commit or push is performed by this work.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,interrupted_attempts_explicit=True,actual_mapping_adopted=True))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
