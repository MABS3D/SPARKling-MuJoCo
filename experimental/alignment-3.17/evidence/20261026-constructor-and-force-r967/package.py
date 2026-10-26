from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-constructor-and-force-r967';Z=D/'constructor-and-force.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 base=json.loads((V/'sparkling-adopt-row-domain-r893-20261026/snapshot317/sources.json').read_text());assert all(sha(R/n)==base[n] for n in ['experimental/smooth/src/mj-data.adb','experimental/smooth/src/mj-data.ads','experimental/smooth/src/mj-smooth_dynamics.ads','experimental/smooth/src/mj-smooth_dynamics.adb','experimental/smooth/src/mj-solver_kernels.adb'])
 numbers={}
 for folder in ['sparkling-data-manifold-read-facts-min-r910-20261026','sparkling-total-force-min-r913-20261026','sparkling-total-force-caller-r915-20261026','sparkling-total-force-baseline-caller-r917-20261026','sparkling-data-dof-entry-min-r922-20261026','sparkling-data-array-frame-min-r923-20261026','sparkling-data-span-valid-min-r933-20261026','sparkling-data-body-span-min-r934-20261026','sparkling-data-body-span-current-min-r937-20261026','sparkling-data-body-span-current314-min-r941-20261026','sparkling-data-end-facts-min-r946-20261026','sparkling-data-zero-original-min-r953-20261026','sparkling-data-creation-bridge-min-r954-20261026','sparkling-data-model-status-bridge-min-r955-20261026','sparkling-data-creation-bridge314-min-r963-20261026','sparkling-data-model-status-bridge314-min-r964-20261026']:
  p=V/folder;d=json.loads((p/'results.json').read_text());assert d['obligations_closed'] and not d['open'] and d['source_hashes_unchanged'];s=json.loads((p/'unit.spark.json').read_text());numbers[folder]=dict(semantic_closed=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in s.get(k,[])),legacy_counter=d['checks'],warnings=len(d['warnings']),source_manifest_sha256=d['sources_sha256'],result_sha256=sha(p/'results.json'))
 numerics={}
 for ref,folder in [('317','sparkling-data-numerical-r936-20261026'),('314','sparkling-data-numerical314-r943-20261026')]:
  d=json.loads((V/folder/'results.json').read_text());assert d['passed'] and len(d['records'])==4
  for role,r in d['records'].items():assert r['build_exit']==0 and r['suites']['activation']['summary']['scenarios']==432 and r['suites']['integration']['summary']['scenarios']==1152 and all(s['passed'] for s in r['suites'].values())
  numerics[ref]=d
 timings={}
 for folder in ['sparkling-total-force-movement-r925-20261026','sparkling-total-force-repeat-r928-20261026']:
  d=json.loads((V/folder/'replicas/results.json').read_text());assert d['passed'] and len(d['records'])==9 and d['replicas']==6;timings[folder]=[dict(model=r['model'],state=r['state'],current_over_baseline=r['current_over_baseline'],current_over_c=r['current_over_c']) for r in d['records']]
 bits=json.loads((V/'sparkling-total-force-bits-r919-20261026/results.json').read_text());assert bits['passed'] and bits['complete'] and len(bits['records'])==4 and all(x['cases']==6540 for x in bits['records'])
 flow=json.loads((V/'sparkling-data-flow-review-r965-20261026/results.json').read_text());assert flow['reviewed_scope_flow_closed'] and flow['warning_multisets_equal']
 pending={}
 for folder in ['sparkling-data-span-lengths-min-r907-20261026','sparkling-data-manifold-read-caller-r911-20261026','sparkling-data-manifold-leaf-caller-r924-20261026','sparkling-data-manifold-span-caller-r938-20261026','sparkling-data-model-status-current-min-r939-20261026','sparkling-data-model-status-current314-min-r942-20261026','sparkling-data-model-status-opaque-min-r947-20261026','sparkling-data-manifold-end-caller-r950-20261026','sparkling-data-layout-opaque-caller-r957-20261026']:
  p=V/folder;d=json.loads((p/'results.json').read_text());s=json.loads((p/'unit.spark.json').read_text());pending[folder]=dict(semantic_closed=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in s.get(k,[])),open=[dict(line=x['line'],rule=x['rule']) for x in d['open']],source_manifest_sha256=d['sources_sha256'],result_sha256=sha(p/'results.json'))
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 907<=int(m[1])<=965:roots.append(p)
 members={};excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   m=re.search(r'-r(\d+)\.py$',p.name)
   if m and 907<=int(m[1])<=965:put(p,'recipes/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,excluded='Generated compiler/prover/Python caches only. Frozen source closures, complete copied reports, diagnostic failures, copied baseline flow traces, runtime binaries, full test inputs/outputs, raw timing and recipes retained. All named execution handles terminal before packaging. Previous893 baseline closures remain in the exact894 checkpoint.'))
 dump(D/'summary.json',dict(private=True,adopted=False,proof_scopes=numbers,pending_proofs=pending,numerical=numerics,total_force_bits=bits,total_force_timings=timings,flow_review=flow,scope='Private constructor proof engineering and a non-adopted Total_Force performance experiment. Each proof remains tied to its exact frozen source and minimum; counts are not additive. Constructor935/940 pass432+1152 scenarios for both roles and profiles on C17/C14; later static variants need exact-source requalification. Remap36 proves full ordered prefix behavior and frame; Model_Status21 closes on both references after Creation bridge2. Parent Copy_Manifold_Joints remains87 semantic closed plus2 open in957; whole Initialize/Data proof pending. Whole Data FLOW has no unresolved candidate diagnostics under the unchanged five spec-only deallocator boundary; this is not runtime safety or whole Gold. Total_Force11/caller28 and6540 exact bit cases pass, but independent six-replica target9/repeat9 do not establish reproducible integrated gain, so it is not adopted. Both full math600-second controls time out without a complete report.949/951 is a discarded duplicate-aspect compile error: original Zero_Array contract already exists in the private spec and its minimum953 closes9. No runtime adoption, migration, C parity, commit or push.'))
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),runtime_unchanged_from893=True,constructor_reference_profile_controls=True,total_force_not_adopted=True))
 (D/'README.md').write_text('''# Private constructor proof closure and force-sum experiment

The actual runtime remains adopted row-domain893 after publication c10895298.
Only the pre-existing local solver change is in the working source. Neither
constructor repairs nor the Total_Force candidate are adopted here.

The body-span remapper closes36 minimum checks on exact C3.17/C3.14 closures.
Its Ok flag equals validation of every span. The exact record-delta model states
which prefix is updated before the first invalid span and which entries stay
unchanged; every other field is preserved. All generic array bounds and Natural
Nv inputs are admitted, including empty arrays and arbitrary addresses when a
count is zero. No extra runtime scan or public model filter is introduced.
The per-entry coefficient lemma closes10, array-frame bridge4, shape projection
26/later28 and creation-input reverse bridge2. Model_Status closes21 on each
reference; their inherited warnings remain separate. The existing Zero_Array
private-spec contract closes9. The failed949/951 attempt incorrectly duplicated
body aspects; it is retained, discarded and never adopted. No allocator behavior
or original Max_Size precondition is changed.

The latest examined Copy_Manifold_Joints minimum in957 closes87 semantic checks
with TWO unresolved obligations: remapper precondition and parent postcondition.
Earlier summaries inferred counts from log tails; the full structured reports
and per-snapshot counts in summary.json are authoritative. Attempts that simplify
coefficient reasoning also expose array-frame/bounds obligations; they are not
represented as monotonically decreasing or complete constructor proofs. Complete
Initialize/Data, full physical/cached invariants and exact-source adoption remain
pending. This is proof engineering, not a Silver mathematical exception.

Both actual baseline and private constructor935/940 pass432 activation scenarios
and1152 manifold/muscle/tendon/body-load integration scenarios per validation and
release profile, against official C3.17/C3.14 respectively. Existing providers,
XML, scenarios and tolerances are retained; only the C17 version guard is adapted.
Later945/952/956/961 static proof variants are distinctly versioned and need fresh
exact-source qualification before adoption. These are numeric controls, not
performance evidence or universal C equivalence.

Fresh whole Data FLOW reproduces the baseline's two Arms initialization errors
and mutable-owner rename error. The private candidate has zero unresolved flow
diagnostics and tool exit0. Five unchanged reviewed unchecked-deallocation
instances remain spec-only in both controls, with the same33 warning multiset.
The raw runner flow_closed=false was an overstrict all-entities-all metadata gate;
its original verdicts are preserved. The review matches stable instance names
and byte-identical declarations, retaining generated GP names too. This is not
runtime-safety/functional Gold or proof of modeled deallocator bodies. Original
flow traces are copied outside generated analysis caches before packaging.

A separate Total_Force experiment uses base Real with the exact five original
input domains and result bound in Pre/Post. Its minimum closes11 and the direct
caller28, versus baseline12/40; this removes implicit checks without dropping
guarantees. Both roles/profiles match6540 exact native-C ordered-operation bit
controls. Assembly sites fall48->38 in Solve_Acceleration, but the independent
six-replica target9/repeat9 movement comparison does not confirm a reproducible
integrated benefit. The candidate stays private; no full30 or C14 numeric gate
is claimed. Both complete Smooth_Dynamics proof controls hit600 seconds without
a full report, so they establish no whole-unit closure or regression result.
Prepared broader gate recipes are retained as unexecuted plans.

All frozen sources, complete copied reports, failures, raw controls/timings and
binaries are preserved. Generated obj/analysis caches are excluded and may be
regenerated. Restore constructor-and-force.zip through tools/evidence_store.py.
Full port, whole dynamics Gold, coordinated migration and C parity remain open.
No new commit or push is performed.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,members=len(members),roots=len(roots),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
