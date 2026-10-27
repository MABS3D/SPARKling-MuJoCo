from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-external-domain-control-r1480';Z=D/'external-domain-control.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
q=json.loads((V/'sparkling-external-domain-qualification-r1473-20261027/results.json').read_text());decision=json.loads((V/'sparkling-external-domain-decision-r1481-20261027/results.json').read_text());assert q['passed'] and decision['passed'] and not decision['adopted']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-external-domain-') and m and 1464<=int(m[1])<=1481:roots.append(p)
for p in Path('/proc').iterdir():
 if not p.name.isdigit() or int(p.name)==os.getpid():continue
 try:
  comm=(p/'comm').read_text().strip();cmd=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
  assert not (any(str(r) in cmd for r in roots) and (comm in {'gnatprove','gprbuild','gcc','gnat1','lto1','cvc5','z3','alt-ergo'} or comm.startswith('python'))),(p.name,comm)
  assert not ('benchmark_replicas.py' in cmd and comm.startswith('python'))
 except (OSError,PermissionError):pass
D.mkdir();shutil.copy2(__file__,D/'package.py');members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(x for x in dirs if x not in {'obj','analysis','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
 for p in sorted(V.glob('sparkling-external-domain-*.driver.log')):put(p,'logs/'+p.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All external-domain jobs terminal; frozen sources, binaries, complete proof reports, compiler diagnostics, numeric and all raw timing data retained. Generated caches excluded.'))
dump(D/'summary.json',dict(qualification=q,decision=decision,codegen=json.loads((V/'sparkling-external-domain-build-r1466-20261027/codegen-review.json').read_text())))
(D/'README.md').write_text('''# External-load domain predicate: proved, not adopted

The candidate replaces only the final Within_Work(Value) branch with the proved
equivalent abs Value <= Work_Limit comparison. It retains the genuine rejection,
ordered force expression, failure frame, complete input domains and every force
channel. No new assumptions, suppression, forced inline hints or thresholds.
Both references close the scalar minimum13 and whole External_Loads43, without
warnings; the latter includes Apply_Buffers caller preconditions. Higher whole
state/dynamics and global factorization functional proofs remain separate/open.
Both-reference/profile activation432 and integration1152 plus all12 numerical
groups pass. Unchanged standalone solver row corpora are not repeated or
presented as fresh evidence for an unrelated owner.

Build1466 has48 to46 ordered comparisons and0 to2 abs masks in Solve_Acceleration.
That static fact does not prove causal time savings. Six identical binary replicas
per role retain normal native C3.17 SIMD/LTO and the original strict release flags.
All endpoints and binary/shared-library bindings pass for target9, independent
repeat9, full30 and independent hinge/free regression-check6.

Chain target gains0.8-1.0percent, repeat0.8-1.2percent (one interval includes1),
and full1.0-1.3percent (all intervals below1). Full30 hinge slows0.9-1.0percent
and dedicated followup2.8-3.1percent, all corresponding intervals above1.
Free full30 medians slow2.0-2.7percent, one interval above1; dedicated followup
medians are near1 with all intervals including1, so not reproduced, not erased.
Other workload uncertainty is retained. No average of percentage changes or
sufficient compensating integrated gain is inferred: the candidate is not adopted.

Actual runtime remains the published389 source (894063268 changes only evidence).
The chain still takes about1.80 times C's time in this full run; complete port,
latest-reference migration and overall C parity are not established. These are
supported smooth-movement comparisons, not a full MuJoCo equivalence claim.
No new commit/push or Linux image/cache cleanup. Restore the exact ZIP using
tools/evidence_store.py; failed and successful results are retained together.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),both_reference_external_unit43_closed=True,all12_numerical_groups_pass=True,all54_replicated_timing_records_retained=True,actual_runtime_unchanged=True,all_included_jobs_terminal=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
