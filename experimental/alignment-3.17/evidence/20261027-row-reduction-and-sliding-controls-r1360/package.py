from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-row-reduction-and-sliding-controls-r1360';Z=D/'row-reduction-and-sliding-controls.zip'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
decision=json.loads((V/'sparkling-row-rejection-decision-r1340-20261027/results.json').read_text());assert decision['passed'] and not decision['adopted']
q=json.loads((V/'sparkling-row-rejection-qualification-r1335-20261027/results.json').read_text());assert q['passed']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1323<=int(m[1])<=1356:roots.append(p)
for p in Path('/proc').iterdir():
 if not p.name.isdigit() or int(p.name)==os.getpid():continue
 try:
  comm=(p/'comm').read_text().strip();cmd=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
  assert not (any(str(r) in cmd for r in roots) and comm in {'gnatprove','gnatwhy3','gprbuild','gcc','cc1','lto1','cvc5','z3','alt-ergo'}),(p.name,comm)
  assert not ('benchmark_replicas.py' in cmd and comm.startswith('python')),(p.name,cmd)
 except (OSError,PermissionError):pass
D.mkdir();shutil.copy2(__file__,D/'package.py');members={};reports=[]
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(x for x in dirs if x not in {'obj','analysis','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark','*add_slid_row.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):
     n='generated-reports/'+root.name+'/'+p.relative_to(root).as_posix();put(p,n);reports.append(n)
 for p in sorted(V.glob('sparkling-*.log')):
  m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
  if m and 1323<=int(m[1])<=1356:put(p,'logs/'+p.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],generated_reports=reports,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All included jobs terminal. Unique sources, runners, binaries, numerical data and raw timing retained; generated obj/analysis caches excluded except available SPARK/Why3 reports and Add_Slid_Row proof ASTs.'))
sliding={}
for label,name in [('initial_flow','sparkling-row-zero-min317-r1343-20261027'),('nested_minimum','sparkling-row-zero-update317-r1345-20261027'),('initial_origin_post','sparkling-row-zero-outer317-r1347-20261027'),('external_helper_minimum','sparkling-row-zero-helper-min-r1350-20261027'),('split_bridge','sparkling-row-zero-bridge-min-r1353-20261027'),('full_slice_bridge','sparkling-row-zero-slices-min-r1355-20261027')]:
 p=V/name/'results.json';d=json.loads(p.read_text());sliding[label]=dict(result=str(p),sha256=sha(p),exit=d['exit'],semantic_closed=d.get('obligations_closed',False),checks=d.get('checks'),open=d.get('open',[]))
assert sliding['external_helper_minimum']['semantic_closed'] and not sliding['full_slice_bridge']['semantic_closed']
bits=V/'sparkling-row-zero-native-bits-r1356-20261027/results.json';bd=json.loads(bits.read_text());assert bd['passed'] and all(x['cases']==7374 for x in bd['records'])
dump(D/'summary.json',dict(decision=decision,qualification=q,sliding_proofs=sliding,sliding_native_bits=dict(result=str(bits),sha256=sha(bits),cases_per_profile=7374,unchanged_baseline_receipts_reused=True),codegen=json.loads((V/'sparkling-row-zero-helper-build-r1349-20261027/codegen-review.json').read_text()),next_work=json.loads((V/'sparkling-row-zero-slices-r1354-20261027/next-work.json').read_text()),scope='No runtime adoption. Rejected checked-count-to-modular-OR control is fully qualified but slower in representative integrated movement. Separate checked zero-origin sliding shows SIMD in predecessor1348 and exact-bit comparisons for1354; original-origin functional post remains open. No complete successor Gold, speedup, migration, full port or C parity claim.'))
(D/'README.md').write_text('''# Row reduction and checked-sliding controls: no runtime adoption

Runtime remains commit389ecb827. The single-owner1323 control changes Add_Row's
checked Int64 rejection count to the existing modular integer OR helper, retaining
all public contracts, FP order, full arbitrary/null-origin domains and rejected-row
contents. Both references close minimum37, whole kernel231 and solver caller
MINIMUM86. Three inherited kernel warnings remain; exactly one old reassociation
warning belongs to the removed count invariant. Twelve caller warnings retain
their rules, messages, columns and source statements. All14 numerical groups,
activation/integration profiles,66306 row cases/profile and7374 exact native-bit
cases/role/profile pass. Counts are not additive; caller proof is not a global
factorization equation or whole dynamics proof.

The target9 comparison uses six identical replicas per executable, unchanged
strict FP/release flags and normal native C3.17 SIMD/LTO. All numeric endpoints
pass. Hinge is about3% slower and free_ball3.0-3.5% slower, each state's interval
above1. Chain medians are0.6-1.1% slower: two intervals include1 and one lower bound
is1.00047. No compensating gain is established, so1323 is rejected; no repeat/full30
acceptance or speedup is claimed. Static removal of one overflow branch did not
establish a benefit; no causal cost attribution follows from instruction counts.

The separate sliding successor gives two arrays equal zero-origin bounds through
ordinary checked constrained parameters, preserving empty/arbitrary-origin arrays
and the theoretical2**31-element Natural span. The public forced-inline wrapper
and its full contract remain; no new forced-inline directive, unsafe view,
assumption, suppression or input restriction is introduced. Initial1343 flow
failure required declaring captured Last;1346 build failure required moving the
sliding helper outside the existing forced-inline public wrapper. Both are kept.

The nested scalar Update minimum closes30 on1348. Its movement executable shows
2 vaddpd instructions in the solver/sliding call path, versus0 at baseline; this
is a static diagnostic for that predecessor, not a measured benefit.1354 full-slice
successor passes7374 native exact-bit cases in each standard profile, reusing only
unchanged baseline receipts after exact source/harness/input/oracle/binary checks.
The complete origin bridge remains open:1347 original post,1353 two independent
acceptance/component assertions, and1355 full-slice post do not close.1353's final
post proved under unproved assertions is not completion. No whole-unit Gold,
movement qualification, speedup or adoption is claimed for the vector successor.

Available complete and incomplete SPARK/Why3 reports and origin-bridge proof ASTs
are retained outside excluded build caches in the ZIP. All named jobs are terminal.
Complete port/latest-reference migration, global dynamics/state proofs and C parity
remain unfinished. No commit/push or Linux image cleanup is performed. Restore the
exact ZIP with tools/evidence_store.py; next-work.json records the proof steps.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),all_named_jobs_terminal=True,actual_runtime_unchanged=True,measured_regressions_and_open_proof_boundaries_explicit=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
