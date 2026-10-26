from pathlib import Path
from collections import Counter
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence'
D=E/'20261026-predicate-and-data-audit-r808';V=Path('/var/tmp')
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def read(folder):return json.loads((V/folder/'results.json').read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 predicate=read('sparkling-work-predicate-min-r794-20261026');oldpred=read('sparkling-work-predicate-baseline-min-r796-20261026')
 key=lambda w:(w['file'],w['rule'],json.dumps(w['message'],sort_keys=True))
 assert predicate['obligations_closed'] and predicate['checks']==3 and Counter(map(key,predicate['warnings']))==Counter(map(key,oldpred['warnings']))
 callers={}
 for folder,count in [('sparkling-work-predicate-external-min-r798-20261026',12),('sparkling-work-predicate-solver-min-r799-20261026',86),('sparkling-work-predicate-apply-min-r802-20261026',30),('sparkling-work-predicate-external-unit-r807-20261026',42)]:
  d=read(folder);assert d['obligations_closed'] and d['checks']==count and not d['open'];callers[folder]=dict(checks=count,warnings=len(d['warnings']),obligations_closed=True)
 data=read('sparkling-work-predicate-data-unit-r800-20261026');base=read('sparkling-work-predicate-baseline-data-unit-r803-20261026');k=lambda x:(x['file'],x['line'],x['rule'],json.dumps(x['message'],sort_keys=True))
 assert len(data['open'])==len(base['open'])==3 and sorted(map(k,data['open']))==sorted(map(k,base['open']))
 timing=json.loads((V/'sparkling-work-predicate-movement-r797-20261026/replicas/results.json').read_text());assert timing['passed'] and timing['replicas']==6 and len(timing['records'])==9
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 793<=int(m[1])<=807 and int(m[1])!=805:roots.append(p)
 assert len(roots)==14
 members={};zpath=D/'predicate-data-audit.zip';excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(zpath,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   m=re.search(r'-r(\d+)\.py$',p.name)
   if m and 793<=int(m[1])<=807:put(p,'recipes/'+p.name)
  p=V/'sparkling-work-predicate-build-r795.log'
  if p.exists():put(p,'loose-logs/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(zpath) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,zip_sha256=sha(zpath),zip_bytes=zpath.stat().st_size,roots=[str(p) for p in roots],scope='Completed/frozen private inputs only. Active topology r805 and initialization r809 results are excluded. Generated caches excluded; copied complete reports, failures, source, binaries and raw nine-case timing retained.'))
 dump(D/'summary.json',dict(private=True,adopted=False,predicate_checks=3,predicate_inherited_warnings=8,callers=callers,parent_data_baseline_flow_errors=base['open'],parent_data_candidate_flow_errors=data['open'],parent_whole_unit_closed=False,initialization_attempt=read('sparkling-data-initialize-min-r806-20261026'),movement=dict(passed=True,scenarios=9,replicas=6,records=timing['records']),scope='Abs predicate is exactly equivalent to old interval membership for its admitted Real domain. Fresh C17 minima and full external-load unit close; full parent data remains blocked by three reproducible baseline flow errors. Initial per-check3s full external-unit run leaves one timeout; per-path minimum30 and full unit42 at the historical10s budget close it. Nine-case performance is promising but independent/full30/two-reference/boundary qualification remains pending. Separate constructor flow-repair prototype is not adopted or timing-qualified; first Initialize minimum hits2.5GB group cap, not a completed proof. Original adopted row-window runtime remains unchanged.'))
 (D/'README.md').write_text('''# Private predicate experiment and parent-data proof audit

The adopted runtime is still row-window r789. The private predicate experiment
changes only Within_Work in mj-data.ads to abs(X)<=Work_Limit, retaining the
exact original interval-membership relation as a proved postcondition. Its three
minimum checks close, with eight diagnostics identical to the baseline. The
scalar accumulation minimum12, packed solver minimum86 and application minimum30
close; the complete external-load unit closes42 checks without warnings.
The initial whole external-unit attempt uses per-check3s and leaves one timeout;
the historical successful strategy was per-path10s. Both attempts are retained.

The full parent Data unit stops during flow analysis on three errors: two
uninitialized Arms reports and a renamed dereference dependent on mutable D
in Initialize. A fresh actual adopted-baseline run reproduces exactly those
three errors. This is unfinished proof engineering, not a mathematical Silver
exception, not complete parent-unit Gold and not a new predicate regression.

The private nine-scenario comparison uses six copies per role and normal native
C3.17 SIMD/LTO. All endpoints pass and no slowdown is confirmed. Branches24
has about1.4-1.8% lower median time with all three intervals below one; chain24
is about1.1-1.6% lower with only two intervals below one. All free-ball intervals
include no change. No adoption or aggregate/parity claim: an independent repeat,
all30 scenarios, boundary corpus and two-reference qualification remain pending.
Static acceleration comparison sites change48 to45, a diagnostic only.

A separate private prototype starts from the actual adopted baseline, initializes
armature scratch and validates a copied actuator record before committing it.
Rejecting branches keep the same Free and status behavior. It does not include
the abs predicate. The first Initialize minimum exceeds its2.5GB group memory
cap before producing a report and is not a proof. Topology and a larger-memory
initialization attempt are active when packaged and are explicitly excluded.
Neither prototype changes the adopted source or its previously proved scopes.

Frozen source, binaries, copied reports, failures and raw samples are preserved.
Restore predicate-data-audit.zip with tools/evidence_store.py restore using its
repository-relative path. Full port, whole dynamics Gold, coordinated migration
and overall C parity remain unfinished. No new commit or push is performed.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(zip_bytes=zpath.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
