from pathlib import Path
import hashlib,json,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');E=R/'experimental/alignment-3.17/evidence';V=Path('/var/tmp');D=E/'20261026-row-domain-r894';Z=D/'row-domain.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def main():
 adoption=json.loads((V/'sparkling-adopt-row-domain-r893-20261026/complete.json').read_text());assert adoption['passed'] and adoption['locally_adopted'];binding=json.loads((V/'sparkling-adopt-row-domain-r893-20261026/source-binding.json').read_text());assert all(sha(R/n)==v for n,v in binding['owners'].items())
 gates=json.loads((V/'sparkling-row-domain-gates-r890-20261026/complete.json').read_text());assert gates['passed'] and len(gates['gates'])==14
 timing=json.loads((V/'sparkling-adopt-row-domain-r893-20261026/timing-summary.json').read_text());scopes={}
 for name in ['sparkling-data-dimensions-min-r861-20261026','sparkling-data-dof-predicate-min-r864-20261026','sparkling-data-dof-facts-min-r865-20261026','sparkling-data-body-range-frame-min-r883-20261026','sparkling-data-creation-dynamics-min-r884-20261026','sparkling-data-span-assignment-min-r900-20261026','sparkling-data-span-transitive-min-r901-20261026','sparkling-data-span-identity-min-r904-20261026']:
  p=V/name
  assert (p/'results.json').exists(),p
  d=json.loads((p/'results.json').read_text());assert d['obligations_closed'] and not d['open'];s=json.loads((p/'unit.spark.json').read_text());semantic=sum(x.get('severity')=='info' for kind in ['proof','flow'] for x in s.get(kind,[]));scopes[name]=dict(semantic_checks=semantic,inherited_warnings=len(d['warnings']),source_manifest_sha256=d['sources_sha256'],result_sha256=sha(p/'results.json'))
 constructor=V/'sparkling-data-manifold-components-min-r892-20261026';assert (constructor/'results.json').exists();constructor_result=json.loads((constructor/'results.json').read_text()); followup=V/'sparkling-data-span-components-min-r902-20261026/results.json'; assert followup.exists(); constructor_followup=json.loads(followup.read_text())
 D.mkdir();shutil.copy2(__file__,D/'package.py');roots=[]
 for p in sorted(V.iterdir()):
  m=re.search(r'-r(\d+)-20261026$',p.name)
  if p.is_dir() and p.name.startswith('sparkling-') and m and 859<=int(m[1])<=904:roots.append(p)
 members={};excluded={'obj','analysis','__pycache__','.git'}
 with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
  def put(p,n):
   assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
  for root in roots:
   for p in sorted(root.rglob('*')):
    if p.is_file() and not set(p.relative_to(root).parts)&excluded:put(p,root.name+'/'+p.relative_to(root).as_posix())
  for p in sorted(Path('/tmp').glob('sparkling-*.py')):
   m=re.search(r'-r(\d+)\.py$',p.name)
   if m and 859<=int(m[1])<=904:put(p,'recipes/'+p.name)
  put(Path(__file__),'recipes/package.py')
 with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==v for n,v in members.items())
 dump(D/'archive-manifest.json',dict(files=members,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,roots=[str(p) for p in roots],excluded='Generated compiler/prover/Python caches only. Frozen sources, complete copied SPARK reports, logs, binaries, failed attempts, full numerical and timing inputs/outputs retained. All included execution handles terminal before packaging.'))
 dump(D/'summary.json',dict(adoption=adoption,source_binding=binding,gates=gates,timings=timing,constructor_component_proofs=scopes,constructor_manifold_attempt=constructor_result,constructor_followup=constructor_followup,scope='Only equivalent solver row-membership predicate adopted. Private parent-Data constructor prototypes remain unadopted. Semantic proof/flow counts are distinct from compiler informational unrolling. No whole inertia-phase/global factorization theorem, whole dynamics Gold, complete port, production migration or overall C parity. No new commit or push.'))
 dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),adopted_sources_match=True,all14_numerical_groups=True,both_reference_proofs=True))
 (D/'README.md').write_text('''# Equivalent row-domain predicate: local adoption and exact evidence

The adopted solver uses abs(Value) <= Work_Real'Last at its four existing
rejection reductions. A helper proves exact equivalence to interval membership;
ordered floating arithmetic, all original domains, rejection results and frames
are unchanged. Existing integer reductions, the long-row threshold and compiler
policies remain. The final candidate uses ordinary optimization without a new
forced-inline directive. Earlier forced-inline prototypes are retained separately.

Fresh exact C3.14/C3.17 closures each close 225 complete-kernel obligations and 86
of the direct Solve_Compatible_Buffers minimum. Four kernel and twelve caller
inherited diagnostics match the baseline. This is not a proof of the whole
inertia-phase unit or global factorization theorem. All 14 numerical groups pass,
including 6,140 exact native-C scalar bit cases and 59,621 row cases per profile.
The final row corpus uses standard validation/release flags and the existing
per-file solver256 preference; an earlier globally256 diagnostic is separate.
Fresh actual source closures match all verified proof/build inputs exactly.

Targeted nine-scenario, independent nine-scenario repeat and full 30-scenario supported movement scenarios use six
identical ELF replicas per role, balanced order and normal native C3.17 SIMD/LTO.
All chain24 state/run intervals support about 4.3-5.0% less time than the published
row-window baseline. Full-run free_ball takes about 5.0-5.5% less, and branches24
about 2.3-2.9% less; retain each interval in the summary. No scenario confirms a
slowdown; two full-run intervals include no change. These counts are descriptive,
not an aggregate speedup metric. Full-run chain24 remains about 1.93 times C,
free_ball 1.64-1.66 and branches24 1.54. Applied body loads are present. No separate
body-load-free or overall parity claim is made.

Static diagnostic assembly retains YMM arithmetic; FP comparison sites halve
in Add_Long_Row22->11 and Scale_Row4->2. Static counts alone do not measure the
cause or magnitude of integrated savings. All binaries, matching native-C build
metadata, fixtures, raw timings, intervals and exact source bindings are archived.
No own compiler/prover/archive/hash/Git cleanup work overlapped those timings.

Private constructor work exports already admitted DOF coefficient facts and
preserves the exact body-configuration frame except remapped joint ranges.
The component prototype passes only body/joint storage to manifold expansion,
so unrelated Simulation fields follow ownership/mode framing. The two-field setter and frame transitivity each close two checks; the
array reflexivity lemma closes four. All retain the inherited diagnostics. The
Qpos validation loop gains a static prefix invariant, without a new runtime
scan or model restriction. Minimum results,
region-only diagnostics and timed-out attempts are kept in full. The later
caller905 run is outside this checkpoint and has no completion claim here. Region-only
reports must not be represented as complete Initialize proofs. Constructor
changes are unadopted; whole Initialize/Data and current-source, both-profile,
both-reference numerical qualification remain pending. No Silver mathematical
exception is inferred from an unfinished proof or timeout.

Restore row-domain.zip with tools/evidence_store.py restore using its relative
path. This is local progress after publication c10895298. Full port, whole
dynamics Gold, coordinated migration and overall C parity remain unfinished.
''')
 inv=json.loads((E/'inventory.json').read_text());prior=dict(inv['files'])
 for p in D.iterdir():
  if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
 assert all(inv['files'][k]==v for k,v in prior.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
 print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
if __name__=='__main__':main()
