from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-certified-callers-and-diagnostic-controls-r1715';Z=D/'certified-callers-and-controls.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest();read=lambda p:json.loads(p.read_text())
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
proofs={}
for name,count in [('sparkling-certified-compose-min-r1661-20261027',7),('sparkling-certified-compose314-min-r1673-20261027',7),('sparkling-certified-size-min-r1676-20261027',2),('sparkling-certified-size314-min-r1679-20261027',2),('sparkling-common-copy-min-r1696-20261027',20),('sparkling-common-packed-min-r1697-20261028',79),('sparkling-common-bounds317-r1699-20261028',284),('sparkling-common-bounds314-r1700-20261028',284)]:
 f=V/name/'results.json';d=read(f);assert d['exit']==0 and d['obligations_closed'] and d['coverage'] and not d['open'] and d['checks']==count;proofs[name]=dict(path=str(f),sha256=sha(f),checks=count,warnings=d['warnings'])
callers={}
for tag,num in [('317',1678),('314',1681)]:
 f=V/f'sparkling-certified-sized-solve{tag}-r{num}-20261027/results.json';d=read(f);assert not d['obligations_closed'] and d['checks']==148 and len(d['open'])==3;callers[tag]=dict(path=str(f),sha256=sha(f),checks=d['checks'],open=d['open'])
measurements={}
for name in ['sparkling-certified-diagnostic-target-r1685-20261027','sparkling-certified-diagnostic-repeat-r1686-20261027','sparkling-certified-width-target-r1694-20261027','sparkling-common-copy-target-r1708-20261028']:
 f=V/name/'replicas/results.json';d=read(f);assert d['passed'] and d['unchanged_binaries'] and d['identical_shared_libraries'] and d['replicas']==6 and len(d['records'])==9;measurements[name]=dict(path=str(f),sha256=sha(f),records=[{k:r[k] for k in ['model','state','current_over_baseline','current_over_c']} for r in d['records']],scope='Diagnostic timing, not full formal qualification, adoption or C parity. Same original inputs/oracle and full supported forces. Separate experiment ratios do not identify causal percentage contributions.')
for n in ['sparkling-certified-compose-numerical317-r1664-20261027','sparkling-certified-compose-numerical314-r1665-20261027','sparkling-common-copy-numerical317-r1703-20261028','sparkling-common-copy-numerical314-r1704-20261028']:assert read(V/n/'results.json')['passed']
roots=[]
for root in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-2026102[78]$',root.name)
 if root.is_dir() and root.name.startswith('sparkling-') and m and 1652<=int(m[1])<=1708 and int(m[1]) not in {1659,1705,1706}:roots.append(root)
source_roots=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items());source_roots.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in {'obj','analysis','analysis314','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark','*.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis','analysis314'}&set(p.relative_to(root).parts):put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
for tree,h in source_roots:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All selected outputs terminal. Earlier1659 checkpoint and ongoing independent separated-solver1705/1706 and1709+ work are excluded. Frozen inputs may be read by successors; all selected source hashes checked before/after. Unique proof/session/input reports retained; compiler caches excluded.'))
dump(D/'summary.json',dict(proofs=proofs,actual_callers=callers,measurements=measurements,formal_qualification_passed=False,production_adopted=False,scope='Corrected actual-call path and source-bound numerical/diagnostic performance controls. Whole actual Solve still has three frame/state obligations on each reference. All controls remain private; no runtime adoption, complete port/latest migration or C performance parity.'))
(D/'README.md').write_text('''# Certified caller and integrated diagnostic controls

The actual-Solve variable-input array constraint is corrected by a local constant,
then scratch is moved into a small composition helper. That helper closes7 checks
on both references; its Bounds output is intentionally discarded after solving.
The INEFFECTIVE warning is retained explicitly as scratch-lifetime information,
not suppressed. A static size lemma closes2 on both references, exposing the
existing ancestor-size/DOF equality and256 bound while the broader ready predicate
stays opaque. Neither helper narrows admitted inputs or adds a runtime scan.

Both normal actual Solve scopes close148 checks, with three remaining obligations:
configuration preservation, Stable_Ready, and State_Values equality. All new solver
call preconditions, aliasing and runtime checks close. These are partial caller
proofs, not whole-caller, whole inertia, construction/state, global factorization
or complete dynamics Gold. One-second Z3 diagnostics identify missing facts;
watchdogs and a rejected stale shared-cache report are preserved as failures.
Source/ghost-only bridge audits retain prior receipts at their original bindings;
unchanged-scope reuse is explicit and is never labeled a fresh full-source run.

Fresh both-reference/profile activation and integration suites pass for1660;
1675 adds only a verified Static ghost lemma/call. Its fresh actual movement
binary matches all30 fixed100-step Ada endpoints exactly and native C at the
unchanged2e-10 tolerance. Formal qualification remains false. Diagnostic-readiness
receipts authorize only performance triage of the numerically checked prototype.
They record the open state proofs and do not authorize runtime adoption.

Six-replica target9 and independent repeat9 measurements use published1319 Ada,
private1675 Ada and normal native C3.17 SIMD/LTO, identical force/model/state
inputs, strict flags and nested uncertainty. Own build/proof/archive/hash/Git work
is absent during measurements. The repeat shows hinge about6.3percent slower,
free_ball about5.1-5.6percent slower and chain24 about6.9-7.1percent slower than
published Ada. First-run hinge intervals include1; both results are retained.
This is not sufficient integrated benefit to adopt; no faster-case count,
percentage-average or full30 acceptance timing is claimed. Native C ratios and
all raw replica/block data remain in the archive.

Independent POSIX CPU-timer profiles retain calibrated timer metadata, overruns,
all raw PCs and exact10000 uninstrumented endpoints for each role. They include
initialization/output and sampling overhead. Samples and disassembly identify a
checked copy/max loop and scalar certified updates for many short rows; sampled
fractions are not causal elapsed-cost decomposition. The source C factorI,
applyFT/xfrc and jacobian algorithms were inspected as diagnostic context.

The isolated256-bit preference applies only to the new certified child, with
exact same source and all other flags. It lowers generated SIMD cutoff from16 to8
and passes7374 exact-bit rows per profile plus30 fresh integrated endpoints.
Its chain control still takes about4.8-5.2percent longer than published Ada.
Independent-control percentage differences are not a paired causal width result.

The independent common-index copy successor1695 leaves generic Copy_Row and all
public domains/contracts intact. Its helper20, packed caller79 and whole bounds
units284 on both references close with documented inherited/initialization
warnings. It removes checked per-entry index translation for matching packed row
slices, with an ordinary Inline hint and a checked body guard implied by Pre.
Both-reference/profile numerical integration and all30 endpoints pass. The same
six-replica target9 diagnostic still shows chain about4.6-5.1percent slower than
published Ada. This control is not adopted and does not include the width change.

All complete kernel/row-bound proof scopes retain the existing verified vendor
mathematical boundary; there is no fresh Coq replay or new trusted port body.
Full port/latest migration, state/dynamics proof and parity with C remain open.
Production runtime remains389ecb827; latest pushed c0e21a38a changes earlier
evidence only. This checkpoint is local. Exact ZIP bytes are reconstructable
with tools/evidence_store.py. No Linux-image compaction or cache cleanup occurs.
''')
dump(D/'verification.json',dict(passed=True,zip_sha256=sha(Z),members_verified=len(members),selected_outputs_terminal=True,frozen_sources_unchanged=True,actual_callers_complete=False,formal_qualification_passed=False,diagnostic_timing_valid=True,production_adopted=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
