from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-flat-row-compiler-controls-r1478';Z=D/'flat-row-compiler-controls.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
q=json.loads((V/'sparkling-flat-qualification-r1458-20261027/results.json').read_text());decision=json.loads((V/'sparkling-flat-decision-r1462-20261027/results.json').read_text());assert q['passed'] and decision['passed'] and not decision['adopted'];roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1422<=int(m[1])<=1463:roots.append(p)
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
  if m and 1422<=int(m[1])<=1463:put(p,'logs/'+p.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],generated_reports=reports,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All included row-control jobs terminal. Later independent external-load owner work is outside this archive. Frozen source, binaries, compiler logs, numeric data and raw timing retained; available proof reports/ASTs copied outside excluded generated caches.'))
dump(D/'summary.json',dict(qualification=q,decision=decision,codegen=json.loads((V/'sparkling-flat-final-build-r1445-20261027/codegen-review.json').read_text()),scope='Optional parent/nested hints alone retain the call; compiler logging reports function not inlinable, without isolating a specific cause. Standard checked conversions in inout actuals plus a non-nested equal-bound helper and body guard remove the call and retain SIMD. Final1441 current-source whole284 and solver caller-minimum86 close for both refs; all14 numerical groups pass. Six-replica target9 remains insufficient to adopt a material simple-model regression. No runtime adoption, full port/latest migration/global dynamics Gold or C parity claim.'))
(D/'README.md').write_text('''# Non-nested checked row conversions: proved, not adopted

Actual runtime remains389ecb827. All1422-1463 row-control jobs are terminal;
the later independent external-load predicate experiment is outside this bundle.

An optional Inline hint on the proved sliding parent, then one on its nested
helper, both compile and close their minima but retain the call. GCC's missed-inline
log says the parent function is not inlinable; it does not isolate a cost or prove
a target-option mismatch. Scalar Scale_Row comparison shows changed padding with
unchanged useful instructions. These are diagnostics, not a cause of slowdown.

The separate1431 language probe confirms checked subtype conversion in an inout
actual supports zero origins and original target write-back; it is not a standalone
SPARK or zero-copy proof.1432 moves the flat loop to a non-nested procedure. Its
private zero/equal-bound Pre implies a retained native shape guard, letting the
optimizer see equal bounds. Existing forced-inline directives remain; only two
ordinary optional hints are added. No pointer cast, assumption, suppression,
threshold or public domain restriction is introduced.

The flat minimum32 closes for both references; checked/release row66306 and native
exact-bit7374 corpora pass. Initial1435/1440 caller posts and component assertions
remain open and are retained.1441 separates the acceptance facts on converted and
original arrays and invokes the independently proved work-domain congruence lemma.
All final caller31 obligations close under per_check, including every assertion;
no post under an unproved assertion is claimed as completion. Final public wrapper11,
complete kernel284 and actual inertia solver CALLER MINIMUM86 close on both refs.
Counts are not additive. Three inherited kernel and twelve caller warnings retain
prior source statements/rules/messages/columns; the removed count invariant retires
exactly one old warning. Exact-source caches are validated by GNATprove incremental
task checks; final complete reports and no open obligations remain required.

All14 numerical groups, both-reference/profile activation432/integration1152,
66306 standard row cases/profile and7374 exact native cases/candidate/profile pass.
Only exact unchanged baseline receipts are reused, with full source/provider/input/
oracle/binary bindings. Standard strict flags, solver-file256 preference and normal
native C3.17 SIMD/LTO remain. The final inlined loop uses native caller vector width;
it has SIMD and no row helper call, with no extra copy call versus baseline. Those
static facts do not establish a speedup or absence of inlined memory work.

Six identical replicas per executable retain all nine target trajectories. Hinge
medians are2.6-2.9% slower, every interval above1; free_ball medians1.0-2.3% slower
have intervals including1. Chain medians improve0.6-1.0%, two intervals below1 and
one including1. No percentage average or sufficient integrated benefit is inferred.
The control is not adopted and has no repeat/full30 acceptance. Cross-run comparison
with the earlier nested implementation does not isolate call, width or layout cost.
Existing zero/diagonal skipping and bounded Dof_Count Size are already present;
neither is newly identified missing work.

Full factorization equations, whole dynamics/state Gold, full port/latest-reference
migration and C parity remain open. No commit or push. Restore the exact ZIP through
tools/evidence_store.py. No generated cache or Linux image cleanup is performed.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),both_reference_whole_kernel284_closed=True,all14_numerical_groups_pass=True,no_call_simd_codegen_and_actual_mixed_timings_retained=True,actual_runtime_unchanged=True,all_included_jobs_terminal=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
