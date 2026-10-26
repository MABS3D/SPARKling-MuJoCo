from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-manifold-caller-recovery-r1062';Z=D/'manifold-caller-recovery.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 D.mkdir();shutil.copy2(__file__,D/'package.py');proofs={}
 for name,count in [('sparkling-data-span-memory-caller314-r1031-20261026',97),('sparkling-data-span-wrapper314-r1037-20261026',8),('sparkling-data-model-status314-r1038-20261026',21)]:
  p=V/name;d=json.loads((p/'results.json').read_text());s=json.loads((p/'unit.spark.json').read_text());assert d['obligations_closed'] and not d['open'] and d['source_hashes_unchanged'];n=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in s.get(k,[]));assert n==count;proofs[name]=dict(checks=n,warnings=len(d['warnings']),result_sha256=sha(p/'results.json'),source_manifest_sha256=d['sources_sha256'])
 parent=V/'sparkling-data-initialize-prefix-r1034-20261026';d=json.loads((parent/'results.json').read_text());assert d['source_hashes_unchanged'] and len(d['open'])==1 and d['open'][0]['line']==1673;s=json.loads((parent/'unit.spark.json').read_text());prefix=dict(scope=d['scope'],first_line=d['first_line'],last_line=d['last_line'],proof_infos=sum(x.get('severity')=='info' for x in s.get('proof',[])),flow_infos=sum(x.get('severity')=='info' for x in s.get('flow',[])),open=d['open'],result_sha256=sha(parent/'results.json'))
 controls={}
 for name in ['sparkling-minimal-flowfix-direct-numerical-r1028-20261026','sparkling-minimal-flowfix-direct-numerical314-r1029-20261026','sparkling-minimal-flowfix-initialized-numerical-r1055-20261026','sparkling-minimal-flowfix-initialized-numerical314-r1056-20261026']:
  p=V/name/'results.json';d=json.loads(p.read_text());assert d['passed'] and len(d['records'])==4;controls[name]=dict(result_sha256=sha(p),records={k:dict(source_manifest_sha256=v['source_manifest_sha256'],activation=v['suites']['activation']['summary']['scenarios'],integration=v['suites']['integration']['summary']['scenarios']) for k,v in d['records'].items()})
 timings={}
 for name,n in [('sparkling-minimal-flowfix-direct-full-r1036-20261026',30),('sparkling-minimal-flowfix-direct-repeat-r1041-20261026',3)]:
  p=V/name/'replicas/results.json';d=json.loads(p.read_text());assert d['passed'] and d['replicas']==6 and len(d['records'])==n;timings[name]=dict(result_sha256=sha(p),records=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in d['records']])
 roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 1023<=int(m[1])<=1060:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(V.glob('sparkling-*.log')):
   m=re.search(r'-r(\d+)\.log$',p.name)
   if m and 1023<=int(m[1])<=1060:put(p,'logs/'+p.name)
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. Interrupted Why3 sessions copied explicitly under1060/partial-reports before this archive. Complete sources/reports, raw numeric/movement outputs, binaries and surviving run-specific recipes retained. The new1061 proof is active and excluded.'))
 dump(D/'summary.json',dict(adopted=False,minimum_proofs=proofs,selected_prefix=prefix,numerical=controls,timings=timings,recovery=json.loads((V/'sparkling-proof-recovery-r1060-20261026/interrupted.json').read_text()),scope='C14 manifold97, wrapper8 and Model_Status21 close on the exact private1030 closure. Prefix1034 closes the previously open manifold-call precondition and null dereference, but retains one Fluid_Phase.Initialize precondition timeout. It is not the full Initialize proof. Direct1023 clears original FLOW diagnostics with unchanged reviewed boundaries, but the full30 finds hinge+1.1..1.3%; the independent repeat is inconclusive with wider intervals, not a demonstrated win. Range-only1040 fails the same two Arms flow diagnostics. Initialized1049 transfers those two diagnostics into proof with a partial-initialization aspect/invariant/assertion; both-reference numeric controls and reviewed FLOW pass, but the initialization properties and consuming-read checks are not proved: their runs were interrupted with no final reports. FLOW alone is insufficient for adoption. Their partial diagnostics are preserved, and a new actual-minimum1061 retry is outside this checkpoint. No runtime adoption, complete port, migration, whole-dynamics Gold or overall C parity claim.'))
 (D/'README.md').write_text('''# Manifold caller progress and interrupted initialization proofs

The C3.14 Copy_Manifold_Joints minimum closes97 semantic checks, repeating the
C3.17 closure in1035. Remap_Spans_For_Constructor closes8 and Model_Status21 on
the exact same private C3.14 source1030. Six inherited warnings remain. These
are minimum scopes under called contracts, not complete Data/Initialize proof.

Selected Initialize region1659..1680 in1034 now proves the manifold-call
precondition, its body-pointer dereference and subsequent call checks except
one Fluid_Phase.Initialize precondition, which reaches prover limits. Summary
separates proof checks from whole-unit flow information; counts are not additive.
A later split into nine explicit static precondition cuts1039 was interrupted;
partial Why3 reports are retained without a completion claim.

The direct-owned-element variant1023 passes reviewed whole Data FLOW and the
existing432 activation plus1152 integration scenarios per reference/profile.
Its full30 six-replica movement run finds roughly1.1-1.3% hinge slowdown; the
independent three-state repeat has wide intervals and is inconclusive. It stays
private. The range-only1040 variant still has two Arms initialization diagnostics
and is discarded before new build/numerical qualification.

Variant1049 uses Relaxed_Initialization, an explicit initialized-prefix invariant
and a whole-array initialization assertion instead of adding a runtime zeroing
pass. It passes reviewed FLOW under the same five spec-only deallocators and
unchanged warning multiset, plus all C3.14/C3.17 numeric controls. This does not
prove initialization: the invariant initialization/preservation, final assertion
and consuming-read checks still require completed proof reports on both references.
The original1052/1053/1058/1059 jobs and fluid-cut1048 have no final reports and
no live processes at recovery. They are interrupted, not successes or failures.
Their copied partial sessions and original runners remain. The cause of process
loss is not inferred. A fresh minimum retry1061 is outside this checkpoint.

The actual runtime remains893, published as e956729c3. No candidate in this
checkpoint is adopted or newly published. Restore manifold-caller-recovery.zip
with tools/evidence_store.py. Full port, coordinated migration, whole-dynamics
Gold and overall C parity remain unfinished.
''')
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),no_runtime_adoption=True,interrupted_runs_not_claimed_closed=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,members=len(members),roots=len(roots),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
