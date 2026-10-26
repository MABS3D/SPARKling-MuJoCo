from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp')
D=E/'20261026-constructor-proof-r860';Z=D/'constructor-proof.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 scopes={}
 for name in ['sparkling-data-topology-contract-min-r811-20261026','sparkling-data-topology-arrays-min-r817-20261026','sparkling-data-activation-frame-min-r830-20261026','sparkling-data-activation-match-min-r833-20261026','sparkling-data-activation-entry-effort-r839-20261026','sparkling-data-metadata-facts-min-r841-20261026','sparkling-data-activation-traversal-min-r842-20261026','sparkling-data-supported-kinds-min-r847-20261026','sparkling-data-topology-lengths-min-r849-20261026','sparkling-data-activation-atomic-min-r852-20261026','sparkling-data-geometry-facts-min-r855-20261026','sparkling-data-creation-facts-min-r857-20261026','sparkling-data-model-status-geometry-min-r858-20261026']:
  p=V/name;d=json.loads((p/'results.json').read_text());assert d['obligations_closed'] and not d['open'] and d['source_hashes_unchanged'];s=json.loads((p/'unit.spark.json').read_text());semantic=sum(x.get('severity')=='info' for kind in ['proof','flow'] for x in s.get(kind,[]));scopes[name]=dict(semantic_checks=semantic,legacy_info_count=d['checks'],warnings=len(d['warnings']),obligations_closed=True,source_manifest_sha256=d['sources_sha256'],result_sha256=sha(p/'results.json'))
 numerical=json.loads((V/'sparkling-data-numerical-r850-20261026/results.json').read_text());assert numerical['passed']
 for role in ['baseline','candidate']:
  assert numerical['records'][role]['suites']['activation']['summary']['scenarios']==432
  assert numerical['records'][role]['suites']['integration']['summary']['scenarios']==1152
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 809<=int(m[1])<=858:roots.append(p)
 assert len(roots)>30;members={};exclude={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&exclude:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   m=re.search(r'-r(\d+)\.py$',p.name)
   if m and 809<=int(m[1])<=858:put(p,'recipes/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,roots=[str(p) for p in roots],excluded='Generated compiler/prover/Python caches only. Frozen inputs, complete copied reports, failures, logs, binaries, full numerical inputs/outputs and recipes retained. Active Initialize r859 is outside this checkpoint; no conclusion about its proof.'))
 dump(D/'summary.json',dict(private=True,adopted=False,proof_scopes=scopes,numerical=numerical,scope='Private constructor proof engineering on the C17 closure. Functional topology maps86, activation entry93, traversal31, matching predicate49, metadata5, supported kinds18, geometry2, creation facts2 and Model_Status19 close at their recorded snapshots. The early topology75 scope was safety-only; later maps export exact behavior. Legacy check counters can include informational loop-unroll messages; semantic proof/flow counts are explicit. Baseline Model_Status reproduces an open postcondition; the geometry-layout ghost bridge closes it. Both baseline and candidate pass432+1152 validation scenarios against official C3.17. The exact numeric candidate is r846; later r854/r856 have additional proof facts and remove the redundant r844 capacity guard. A current-source requalification is still required. Full Initialize/whole Data/C14/release/performance/adoption remain pending.'))
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),proof_scopes_checked=True,numerical_scenarios_per_role=1584,source_adopted=False))
 (D/'README.md').write_text('''# Private constructor proof closure and numerical controls

The adopted runtime remains row-window r789. These constructor repairs remain
private: no whole Data, whole dynamics Gold, production migration or C-parity
claim. The original Initialize attempt reaches its900-second group limit without
a report. Its exact inputs/logs and earlier2.5GB failures remain preserved.

The initial topology wrapper closes75 semantic safety/flow checks after layout
preconditions and mass invariants. Functional strengthening first exposes an
illegal old value of an owning pointer, then quantified mutable-owner frame
timeouts. Those failed attempts are preserved. Passing source/configuration
arrays read-only and two owned mutable caches separately closes86 checks with
exact armature, simple/fixed inertia, parent/body/joint/effective-parent maps and
counts. The raw array preconditions use lengths rather than canonical upper
bounds to preserve empty-array cases. The read-only configuration frame follows
SPARK ownership/modes; full ordered subtree-mass equivalence is not claimed.

Activation construction is split into one parameter record and its array loop.
The entry closes93 checks: exact activation/muscle fields, unchanged base fields,
address progression, muscle flag and, in the later scope, unchanged entry on
rejection. The traversal closes31 checks and the matching predicate49. A frame
predicate closes2 and the layout-metadata lemma5. Supported-kind propagation
closes18. Inherited diagnostics remain explicit; strict warning-free passed is
false. No assumption, suppression, unchecked pointer or modeled deallocator
change is introduced.

An original Model_Status postcondition also remains open in a fresh adopted
baseline control. Its Creation_Inputs requirement includes geometry layout,
which was hidden along with the checked full-layout expression. A proved pure
ghost bridge exports this existing conjunct without a runtime scan. That bridge
closes2 checks; decomposition of creation inputs closes2. Model_Status then
closes19 checks, including existing Na/mocap capacities and supported dynamics.
The intermediate defensive Na guard is removed: the original public admission
already rejects excess activation storage. No new model filter is required.
The private constructor and Set_Dimensions must still discharge all propagated
facts in the full caller chain; those obligations are not assumed completed.

Existing differential suites run unchanged XML/scenarios/tolerances with only
the expected version guard adapted to official3.17. Both the actual baseline
and private r846 candidate pass432 activation scenarios and1152 combined
slide/hinge/ball/free, integrator/filter/filterexact/muscle, early/limit/disable,
spatial-tendon and body-load scenarios, validation profile. Full inputs/outputs
and provider SHA bindings are preserved. Later proof-only changes and removal
of a redundant guard are distinguished from the exact tested source; fresh
current-source/release/C14 qualification remains required. These are numerical
tests, not performance evidence or universal C equivalence.

Semantic check counts here exclude compiler informational unrolling messages:
some older result counters reported76 for75 or96 for93. Complete original
reports and counters remain unmodified. Restore constructor-proof.zip with
tools/evidence_store.py restore using the repository-relative path.
No new commit or push is performed. Full port, whole dynamics Gold, coordinated
migration and overall C performance parity remain unfinished.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
