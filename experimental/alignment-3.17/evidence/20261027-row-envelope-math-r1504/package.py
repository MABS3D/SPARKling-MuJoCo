from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-row-envelope-math-r1504';Z=D/'row-envelope-math.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
math=json.loads((V/'sparkling-row-envelope-composed-r1491-20261027/math-closure.json').read_text());assert math['passed'];roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1482<=int(m[1])<=1501:roots.append(p)
for p in Path('/proc').iterdir():
 if not p.name.isdigit() or int(p.name)==os.getpid():continue
 try:
  comm=(p/'comm').read_text().strip();cmd=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
  assert not (any(str(r) in cmd for r in roots) and (comm in {'gnatprove','gprbuild','gcc','gnat1','gnatwhy3','lto1','cvc5','z3','alt-ergo'} or comm.startswith('python'))),(p.name,comm)
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
  for pattern in ['why3session.xml','*.spark','*certified*.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All named1482-1501 jobs terminal. Later1502+ array-range prototype and its running minimum are outside this bundle. Frozen sources, vendor evidence, all complete/partial proof controls retained; generated caches excluded except selected unique proof/diagnostic inputs.'))
dump(D/'summary.json',dict(math_closure=math,prototype_1497=dict(proved=45,open=1,scope='Call precondition abs Previous <= Target_Bound is open; a post proved under that unresolved call is not completion.'),prototype_1499_1501=dict(exit=99,scope='Wall240 watchdog; no complete report or successful minimum claimed. Frozen source, console and available certified procedure GNAT-json retained.'),scope='Proof engineering progress toward eliminating repeated row checks; no runtime adoption, speedup, whole dynamics/factorization or full port claim.'))
(D/'README.md').write_text('''# Rounded row envelope: complete math unit, runtime prototype open

The original1412 envelope post was open.1482 separates actual FP product and
sum envelopes. The sum minimum closes15; product sign identities close but one
monotonic inequality remains open (18 other checks).1485/1487 retain the missing
spark.ads/library-directory setup failures.1489 uses the installed source paths
for the existing Long_Float library; its product minimum closes24. Final1491
composes the product and sum to prove the original rounded Add_Product envelope;
its minimum closes9 on both references. Counts are not additive.

The exact final1491 complete Solver_Kernels unit closes279 checks on each
reference:255 proof and24 flow, no open/skip/assume. The four inherited warning
rules/messages/columns/source statements match the actual published1319 source.
All original runtime row bodies are byte-identical. Higher caller, global
factorization equations and whole dynamics/state proofs remain separate/open.

Product monotonicity uses the existing SPARK.Lemmas.Long_Float_Arithmetic
instance, not a new generic instance or unproved port lemma. Real is a subtype
of the same Long_Float; input bounds fit its2**511 contract. Exact vendor source,
matching valid Why3 proof session and complete supplied Coq proof are preserved
with hashes. The vendor generic body is SPARK_Mode Off: current GNATprove proves
call preconditions/composition under this previously verified library contract,
not a fresh local proof/replay of that body. No fresh Coq replay is claimed;
coqc is unavailable. This mathematical dependency remains explicit.

The separate1496 certified packed-row prototype specifies ordered arithmetic
and the full frame under two input certificates and a safe rounded envelope.
Its1497 minimum leaves a call-bound precondition open, despite45 proved checks.
1498 tail invariants and1500 ghost-before controls each reach the240-second
watchdog without a complete report. None is trusted or adopted. The later1502+
range-form successor is outside this bundle and is not covered by279 closures.

Producing and maintaining per-row certificates in actual mass-copy, damping,
pivot and factor updates; proving certified-loop invariants and all consuming
callers; numerical qualification and replicated integrated timings remain work.
Original rejection paths and full public domains stay in place. Actual runtime
is still389 code (894063268 publishes prior evidence). No runtime speedup,
C parity, whole Gold dynamics, full port or latest-reference migration claim.
No new commit/push or cache/Linux-image cleanup. Restore exact ZIP bytes with
tools/evidence_store.py. Unsuccessful controls are retained with the results.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),both_reference_math_unit279_closed=True,all4_warnings_match_published_source=True,original_runtime_row_bodies_unchanged=True,certified_runtime_prototype_closed=False,all_included_jobs_terminal=True,vendor_dependency_explicit=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
