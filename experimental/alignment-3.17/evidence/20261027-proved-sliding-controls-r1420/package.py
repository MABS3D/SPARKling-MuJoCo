from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-proved-sliding-controls-r1420';Z=D/'proved-sliding-controls.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
qpath=V/'sparkling-sliding-qualification-r1400-20261027/results.json';q=json.loads(qpath.read_text());assert q['passed'];decision=json.loads((V/'sparkling-sliding-decision-r1410-20261027/results.json').read_text());assert decision['passed'] and not decision['adopted']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1361<=int(m[1])<=1414:roots.append(p)
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
  for pattern in ['why3session.xml','*.spark','*add_slid_row.gnat-json','*prove_update_envelope.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):
     n='generated-reports/'+root.name+'/'+p.relative_to(root).as_posix();put(p,n);reports.append(n)
 for p in sorted(V.glob('sparkling-*.log')):
  m=re.search(r'-r(\d+)\.(?:driver\.)?log$',p.name)
  if m and 1361<=int(m[1])<=1414:put(p,'logs/'+p.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],generated_reports=reports,zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All included jobs terminal. Frozen sources, runners, logs, binaries, numerical cases and raw timing retained. Generated caches excluded except available SPARK/Why3 reports and focused proof ASTs; partial/failed reports are not proof completion.'))
extras={}
for label,name in [('ghost_policy_failure','sparkling-sliding-expected-update-r1363-20261027'),('initial_expected_caller_open','sparkling-sliding-static-caller-r1366-20261027'),('future_envelope_post_open','sparkling-row-envelope-min-r1413-20261027'),('checked_view_not_writable','sparkling-checked-view-legality-r1414-20261027')]:
 p=V/name/'results.json';extras[label]=dict(result=str(p),sha256=sha(p),receipt=json.loads(p.read_text()))
dump(D/'summary.json',dict(qualification=q,decision=decision,controls=extras,codegen=json.loads((V/'sparkling-sliding-final-build-r1392-20261027/codegen-review.json').read_text()),scope='Original-origin functional/rejection bridge is now proved, using a Static expected row and a separately proved array-domain congruence lemma. Final1384 closes complete kernels282 on both refs, with only three inherited warnings and source-bound scalar/caller minima. Fourteen numerical groups and both-reference/profile integration pass. Six-replica target9 has small mixed gains and a material hinge regression, so no adoption or full30/repeat acceptance follows. A prospective rounded-envelope theorem remains open; local checked conversion-renaming is not writable Ada. No runtime owner or public contract changes in the actual repo; complete dynamics Gold, port/migration and C parity remain open.'))
(D/'README.md').write_text('''# Checked sliding: full unit proof closed, performance adoption deferred

Actual runtime remains commit389ecb827. This private1384 kernel retains the full
original public Add_Row contract, null/arbitrary origins, theoretical2**31-element
Natural span, exact FP tree, complete-row rejection and source/frame behavior.
Ordinary checked constrained parameters give both arrays zero origins. No pointer
cast, new forced-inline directive, assumption, suppression or size restriction is
introduced. The normal body-private sliding helper stays outside the original
forced-inline public wrapper.

The previous origin-bridge gap is closed. A Static ghost aggregate models the
result at its original origin. The nested Update proves exact array equality and
acceptance against that model. Its private model Pre/Post use the matching Static
assertion level, and the caller proves every stronger private precondition. The
separate ghost Prove_Work_Equality proves that equal-element arrays, even at
different origins, have identical Work_Array results. No runtime ghost array or
proof loop is added. All original public/outer contracts remain checked in their
original profiles. The initial1363 ghost-policy failure and1366 unproved caller
post are preserved, rather than used as completion evidence.

Both references close public wrapper11, private sliding caller28, work-equality
lemma16 and the complete solver kernel282. Earlier nested minima33 close before
the final lemma delta; final complete-unit reports re-prove that body in1384.
Counts are not additive. Exact-source minimum caches are merged only after their
jobs finish; normal GNATprove incremental task validation and fresh complete unit
reports, full coverage and no open checks are required. Three inherited kernel
warnings match prior source statements; exactly one old reassociation warning
belongs to the deleted checked-count invariant. The real inertia solver caller
MINIMUM86 also closes for each reference, retaining twelve inherited warnings.
This caller scope does not prove the global factorization equations or the whole
inertia phase/state/dynamics.

All14 numerical groups pass, including both-reference/profile raw mass and
derivatives, C17 reverse layouts, cache and direct-CRB controls. Activation432 and
integration1152 cases pass per reference/profile. Standard checked/release row
corpora pass66306 cases/profile.7374 exact native C row-bit cases pass per candidate
profile; only unchanged baseline receipts are reused after exact source, harness,
case, oracle and preserved-binary bindings. Cases are not universal C equivalence.

The final movement executable contains2 vaddpd instructions in the solver/sliding
call path, versus0 at the published baseline. Native C3.17 SIMD/LTO and original
strict flags, solver-file256 preference, inputs and tolerances are retained. An
identical baseline binary is reused without recompilation. All six replicas and
nine target trajectory endpoints pass. Hinge nevertheless takes4.3-4.6% longer,
all intervals above1. Free_ball medians improve0.9-1.3% but every interval includes1.
Chain medians improve0.2-0.6%, with two intervals below1 and one including1. No
percentage average or sufficient integrated benefit is inferred; the control is
not adopted and has no repeat/full30 acceptance. SIMD code generation alone does
not establish an integrated speedup. Existing zero/diagonal backward-row skipping
was checked and is already present; it is not a demonstrated regression cause.

Two future controls remain explicitly incomplete:1413's rounded update-envelope
lemma has one open functional post despite proved arithmetic safety; this is
unfinished proof engineering, not a Silver mathematical exception or permission to
remove runtime guards.1414's checked array type-conversion renaming fails Ada's
writable-object legality rule. Neither is adopted or trusted. Why3 task-formatting
failures and the successful focused task dump are diagnostic, not proofs.

All named jobs are terminal. Available complete/incomplete SPARK and Why3 reports
and focused proof ASTs are preserved outside excluded build caches. Full dynamics
Gold, complete port/latest-reference migration and C parity remain unfinished.
No commit, push or Linux image cleanup is performed. Restore the exact ZIP with
tools/evidence_store.py.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),both_reference_whole_kernel282_closed=True,all14_numerical_groups_pass=True,measured_hinge_regression_retained=True,actual_runtime_unchanged=True,all_named_jobs_terminal=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
