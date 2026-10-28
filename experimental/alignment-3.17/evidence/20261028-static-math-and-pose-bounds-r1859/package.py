from pathlib import Path
import hashlib,json,os,re,shutil,zipfile,subprocess
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-static-math-and-pose-bounds-r1859'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-math-base-adoption-r1855-20261028/adoption.json');assert adopt['production_adopted'] and sha(R/adopt['file'])==adopt['new_sha256']
proofs={}
for tag,first in [('317',1840),('314',1843)]:
 for i,fn,count in [(0,'apply',68),(1,'apply_transpose',68),(2,'multiply',116)]:
  p=V/f'sparkling-math-base-{tag}-{fn}-r{first+i}-20261028/results.json';d=read(p);assert d['exit']==0 and d['coverage'] and d['obligations_closed'] and not d['open'] and d['checks']==count;proofs[tag+'-'+fn]=dict(path=str(p),sha256=sha(p),checks=count,warnings=d['warnings'],sources_sha256=d['sources_sha256'])
for n in ['sparkling-rotation-base-min-r1824-20261028','sparkling-rotation-base314-min-r1826-20261028','sparkling-pose-bounds-whole317-r1812-20261028','sparkling-pose-bounds-whole314-r1813-20261028','sparkling-pose-round-whole-unit-r1819-20261028']:
 p=V/n/'results.json';d=read(p);assert d['obligations_closed'];proofs[n]=dict(path=str(p),sha256=sha(p),checks=d['checks'],warnings=d['warnings'],sources_sha256=d['sources_sha256'])
for n in ['sparkling-math-base-numerical317-r1847-20261028','sparkling-math-base-numerical314-r1848-20261028','sparkling-math-base-bits-r1852-20261028','sparkling-math-base-endpoints-r1851-20261028']:
 assert read(V/n/'results.json')['passed']
timings={}
for n in ['sparkling-rotation-full30-r1837-20261028','sparkling-math-base-full30-r1854-20261028']:
 p=V/n/'replicas/results.json';d=read(p);assert d['passed'] and d['unchanged_binaries'] and d['identical_shared_libraries'] and len(d['records'])==30 and d['replicas']==6 and read(V/n/'completion.json')['exit']==0
 timings[n]=dict(path=str(p),sha256=sha(p),records=[{k:x[k] for k in ['model','state','current_over_baseline','current_over_c']} for x in d['records']])
whole={}
for n in ['sparkling-math-base-whole317-r1856-20261028','sparkling-math-base-whole314-r1857-20261028']:
 p=V/n/'results.json';assert p.is_file();d=read(p);whole[n]={k:d.get(k) for k in ['exit','checks','coverage','obligations_closed','fresh_scoped_report','seconds']}
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261028$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1765<=int(m[1])<=1858:roots.append(p)
source_roots=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);source_roots.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'math-and-pose-bounds.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  analysis_root='analysis' in root.name
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in {'obj','analysis','analysis314','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name
    if analysis_root and not (name.endswith(('.spark','.gnat-json')) or name in {'why3session.xml','gnatprove.out'}):continue
    put(p,root.name+'/'+p.relative_to(root).as_posix())
 put(R/adopt['file'],'adopted-production/'+adopt['file'])
with zipfile.ZipFile(Z) as z:
 assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in source_roots:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Terminal frozen sources, exact scoped proof reports, partial watchdog/failed diagnostics, numerical/bit tests and both full30 raw timing runs. Generated build/proof caches excluded except final analysis proof artifacts and partial Why3 session XML, whose filenames/source bindings do not replace original scoped receipts. Includes failed decimal transport and absent-old-C-symbol harness attempts.'))
dump(D/'summary.json',dict(proofs=proofs,whole_smooth_math=whole,measurements=timings,adoption=adopt,formal_qualification_passed=False,full_port_performance_acceptance_passed=False,scope='63 redundant local subtype checks replaced with equivalent proved Static assertions in four math bodies, preserving exact FP order/full domains/contracts. Full30 measurements justify local incremental adoption, not C parity or whole-port Gold. PoseBounds146 bothrefs and PoseRounding34(317) are proof-only prototypes; global pose producer and force-projection scan removal remain unimplemented/unproved.'))
(D/'README.md').write_text('''# Proved static math bounds and pose-bound prototypes

The adopted local change removes 63 redundant subtype checks from temporary
values in Apply, Apply_Transpose, Multiply and Rotation. Every original bound
remains an explicit proved Static assertion. Public preconditions/postconditions,
input domains, expressions and floating-point evaluation order are unchanged.
An exact inverse-edit audit recovers the previous file; no assumptions, suppressed
checks, new trusted port bodies or forced inline directives are introduced.

Apply and Apply_Transpose each close 68 checks; Multiply closes 116 on each
reference closure. Rotation closes 157 in the isolated1821 source; that proof is
reused only after checking its exact body, types and public dependent contracts.
The ten existing unrelated elementary-math warnings remain visible. Counts are
separate scopes, not additive. Complete-unit attempts retain their actual
results in summary.json; they do not establish whole Smooth_Math completion.

Both standard profiles and both reference closures pass the existing activation
and supported integration suites. All 30 movement endpoints equal published Ada
exactly and match native C with unchanged2e-10 tolerance. The new three-operation
bit corpus passes 31,776 admitted extreme/random cases per each of eight
profile/reference/role builds, including signed zeros and subnormals. The test
transports input bits as integers after exposing decimal-parser rounding on
subnormal values; original failed harness attempts are retained. Test-only
unchecked conversions are outside the port. The separate Rotation corpus passes
14,927 cases in eight profiles; native C numerical comparisons use2e-15.

The first Rotation-only full30 six-replica run improves ball, leaves other gains
uncertain and has a hinge-state regression interval; it was not adopted alone.
The final combined change improves chain_24 by3.65–3.88 percent and branches_24
by5.29–5.65 percent, with all three per-state95-percent intervals below parity
against previous Ada. Free_ball improves2.38–2.91 percent beyond its uncertainty.
Other lower medians with intervals crossing parity are not established speedups.
No final case has an interval wholly above previous Ada. C remains faster:
chain_24 takes about1.77x native C time and branches_24 about1.40x. All raw
measurements, same-code replicas, uncertainty and exact source/binary bindings
are preserved. Timing ran with this task's other heavy jobs idle. No unweighted
percentage average or faster-case count is used as an acceptance metric.

Separately, the private Pose_Bounds unit proves146 checks on both references.
It bounds the exact rounded position increments using power-of-two budgets.
Pose_Rounding proves34 checks on3.17 using the existing reviewed SPARK
Long_Float_Arithmetic lemma boundary; no fresh Coq replay is claimed. Its small
lemmas show that adding a bounded pose offset to a Work-bounded coordinate cannot
escape Work under the actual rounded expression. The complete pose-frame kernel
still times out; its short diagnostic retains open obligations. Capture/expose
position lemmas close8 checks each, but do not close the kernel. The global pose
producer budget and removal of the Jacobian/external-force scans are unfinished.
None of these pose prototypes is adopted into production.

Whole state/dynamics/factorization Gold, coordinated latest ABI migration, full
feature coverage and C performance parity remain open. This checkpoint and the
math implementation are local; no additional commit/push is performed. Restore
the exact ZIP through tools/evidence_store.py when needed.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_math_adopted=True,production_pose_adopted=False,whole_smooth_math_closed=False,whole_dynamics_closed=False,full_port_performance_acceptance_passed=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
