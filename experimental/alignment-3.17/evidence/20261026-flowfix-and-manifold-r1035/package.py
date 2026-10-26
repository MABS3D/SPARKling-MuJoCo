from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-flowfix-and-manifold-r1035';Z=D/'flowfix-and-manifold.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
def main():
 assert not D.exists();D.mkdir();shutil.copy2(__file__,D/'package.py')
 p=V/'sparkling-data-span-memory-caller-r1017-20261026';d=json.loads((p/'results.json').read_text());assert d['obligations_closed'] and not d['open'] and d['source_hashes_unchanged'];s=json.loads((p/'unit.spark.json').read_text());proof=dict(semantic_checks=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in s.get(k,[])),warnings=len(d['warnings']),result_sha256=sha(p/'results.json'),source_manifest_sha256=d['sources_sha256'],scope='Copy_Manifold_Joints minimum on exact private C3.17 source980, not its callers/whole Data or Initialize. Same source as failed982, only prover memory/timeout increased. All previously open precondition and postcondition obligations close without new assumptions or program changes.')
 assert proof['semantic_checks']==97
 timings={}
 for root in ['sparkling-minimal-flowfix-full-r979-20261026','sparkling-minimal-flowfix-repeat-r984-20261026','sparkling-minimal-flowfix-aligned-target-r992-20261026','sparkling-minimal-flowfix-cold-forward-target-r1021-20261026','sparkling-minimal-flowfix-cold-forward-full-r1022-20261026']:
  p=V/root/'replicas/results.json';d=json.loads(p.read_text());assert d['passed'] and d['replicas']==6
  timings[root]=dict(result_sha256=sha(p),records=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in d['records']])
 numeric={}
 for root in ['sparkling-minimal-flowfix-numerical-r975-20261026','sparkling-minimal-flowfix-numerical314-r976-20261026','sparkling-minimal-flowfix-aligned-numerical-r989-20261026','sparkling-minimal-flowfix-aligned-numerical314-r990-20261026','sparkling-minimal-flowfix-cold-forward-numerical-r1014-20261026','sparkling-minimal-flowfix-cold-forward-numerical314-r1015-20261026']:
  p=V/root/'results.json';d=json.loads(p.read_text());assert d['passed'] and len(d['records'])==4
  for role,r in d['records'].items():assert r['build_exit']==0 and r['suites']['activation']['summary']['scenarios']==432 and r['suites']['integration']['summary']['scenarios']==1152
  numeric[root]=dict(result_sha256=sha(p),manifest_hashes={role:r['source_manifest_sha256'] for role,r in d['records'].items()},scope='Both original baseline/candidate profiles; unchanged numerical suites and tolerances. Numerical controls, not proofs or runtime-parity evidence.')
 roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 969<=int(m[1])<=1022:roots.append(p)
 excluded={'obj','analysis','__pycache__','.git'};members={}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for folder,pattern in [(Path('/tmp'),'sparkling-*.py'),(V,'sparkling-*.log')]:
   for p in sorted(folder.glob(pattern)):
    m=re.search(r'-r(\d+)(?:-20261026)?\.(?:py|log)$',p.name)
    if m and 969<=int(m[1])<=1022:put(p,'recipes-and-logs/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. Frozen sources, copied complete reports, failed generations/builds/reviews, binaries, fixtures, numerical outputs and raw movement timings retained. Every included output root terminal; later running1031/1034 outputs excluded. Their source980 is immutable. No own heavy work overlaps the archived timings.'))
 dump(D/'summary.json',dict(adopted=False,closed_manifold_minimum=proof,numerical=numeric,timings=timings,scope='Three diagnostic Data variants remain unadopted: copied record971 has repeated hinge regression; private record64-byte alignment985 has no demonstrated gain; cold-placement1010 improves hinge triage but full30 confirms seven regressions. The unsupported code-generation-only Machine_Attribute GNATprove warning is explicitly retained/reviewed in1020, not suppressed. Failed late-pragma993, incomplete generation999 and failed strict review1018 retained. First-run proof minima969/980 expose two obligations; larger resource-only run1017 closes97. No whole Initialize/Data Gold, full port, migration or overall C parity. Current runtime remains adopted893, published as e956729c3. Later direct-element candidate1023 and C14 caller proofs are outside this checkpoint.'))
 (D/'README.md').write_text('''# Constructor minimum closed; Data performance controls retained

Copy_Manifold_Joints closes all 97 semantic proof/flow checks on private C3.17
source980, including the two previously open call-precondition and parent-postcondition
obligations. Eight inherited warnings remain. Source, contracts and input domain
are unchanged from failed982: prover memory/timeout alone were increased. This
minimum is not a proof of Initialize, its callers or the complete Data unit.
The C3.14 repeat is subsequent work outside this checkpoint.

Minimal Data fixes remove the three actual baseline flow diagnostics under the
same five reviewed spec-only deallocator instances. Each candidate's source is
separately bound. The copied-record971, aligned985 and cold-placement1010 variants
pass the existing C3.14/C3.17 activation432 and integration1152 scenarios for each
baseline/candidate validation/release profile, with unchanged suite tolerances.
Flow does not establish whole-unit safety or functional Gold; deallocator bodies
are not newly proved. The single additional ignored Machine_Attribute diagnostic
in the cold variant is recorded explicitly, never suppressed.

All variants remain unadopted. The copied record repeatedly slows hinge movement
by roughly3-4%. Record alignment gives no demonstrated benefit. Cold placement
moves/shrinks the initializer and has near-neutral hinge triage, but the completed
30-scenario six-replica run confirms regressions in branched, ball, fixed_tendon
and one chain24 state. Wider intervals are not treated as an improvement. The
source-built normal native C3.17 SIMD/LTO remains the performance reference.
Raw per-case distributions, original binaries, complete commands and fixtures
are retained; no aggregate percentage-speedup claim is made.

Failed proof budgets, failed late-pragmas/builds, incomplete source generation999
and the failed strict-warning review1018 are preserved with their original
outcomes. No source narrowing, assumptions, suppressions or new forced-inlining
are introduced by the accepted proof closure. Current runtime remains893,
published as e956729c3; the later direct-element candidate1023 is separate.
Restore flowfix-and-manifold.zip through tools/evidence_store.py. Full port,
whole dynamics Gold, coordinated migration and overall C parity remain open.
''')
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),semantic_manifold_checks=97,all_timing_controls_retained=True,no_runtime_adoption=True))
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,members=len(members),roots=len(roots),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
