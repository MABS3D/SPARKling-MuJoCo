from pathlib import Path
import json,hashlib,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-body-physical-frame-and-joint-builder-r2842';read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-body-value-adoption-r2841-20261030/adoption.json');audit=read(V/'sparkling-joint-builder-completeness-r2839-20261030/results.json');assert adopt['production_adopted'] and audit['passed'] and sha(R/adopt['source_file'])==adopt['source_sha256']
for n in [2817,2818]:assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['obligations_closed']
for n in [2820,2836]:assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['passed']
for n in [2821,2822]:assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['passed']
for n in [2824,2825]:assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['flow_checks_closed']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261030$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 2778<=int(m[1])<=2841:roots.append(p)
analysis=set();outcomes={};sources=[]
for root in roots:
 p=root/'results.json'
 if p.is_file():
  x=read(p)
  if x.get('analysis_root'):analysis.add(Path(x['analysis_root']))
  outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:x.get(k) for k in ['subprogram','exit','checks','proof_checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven','flow_checks_closed']}}
 for p in [root/'sources.json',*root.glob('*/sources.json')]:
  if p.is_file():
   tree=p.parent/'source';h=read(p);assert all(sha(tree/n)==v for n,v in h.items());sources.append((tree,h))
for p in sorted(analysis):
 if p not in roots:roots.append(p)
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'body-physical-frame-and-joint-builder.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  is_analysis=root in analysis;label=root.relative_to(V).as_posix()
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if is_analysis else {'obj','analysis','__pycache__','.git'}))
   for name in sorted(files):
    if is_analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
    p=Path(folder)/name;put(p,label+'/'+p.relative_to(root).as_posix())
 put(R/adopt['source_file'],'adopted-production/'+adopt['source_file'])
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(adoption=adopt,builder_completeness=audit,outcomes=outcomes,source_snapshots=len(sources),whole_constructor_reset_state_dynamics_closed=False,new_timing_claim=False))
(D/'README.md').write_text('''# Body physical-field frame and separated joint builder

Adopted source SHA-256:
`f30888c404d20069be91d1c3b037c3c7b28b11dc2cb6e70d224c0b5c116bd10d`.

The manifold constructor now calls a joint-array builder that cannot mutate
Simulation or its body configuration through its interface. It then passes
only the two body DOF source arrays and the owned body array to the span-copy
helper. Runtime check/copy order remains joints, body spans, final position
layout. Mechanical comparison preserves the original statements after argument
renaming; helper success statuses propagate the original early returns. No
new validation pass or public input restriction is introduced.

The Ghost record model changes exactly First_Joint/Joint_Count and preserves
all nine remaining physical/mocap fields. The record-field audit enumerates all
11 components, including paired declarations. The model and update lemma close
3/2 reported checks per reference. The complete array helper closes33 checks
on both references, proving unchanged physical fields on every normal return
and exact source span values on success. The35-check coordinator closes its
strengthened postcondition on both references. Exact helper/supporting-source
identity permits reuse of those unchanged model/array-helper proofs after
extracting the joint builder; that audit is not presented as a fresh run.

The joint builder's full600-second attempts time out. Its fresh complete VC
inventories contain62 unique source-location/kind tuples per reference. Five
successful same-source regions partition all62 exactly: setup/contract7,
position validation10, joint reads11, quaternion reads8, component writes26.
The audit checks source/options, freshness, representation, complete scoped
reports and absence of missing/foreign/duplicate/skipped/assumed VCs. It credits
none of the deliberately low-resource inventory successes. Existing reviewed
warnings make wrapper passed flags false while obligations_closed is true.

Earlier direct-loop frame invariants, snapshot/cut assertions and an extracted
single-record setter do not close the array/caller obligations. Their actual
failure reports and all frozen variants remain. Separating both mutable arrays
through interfaces closes the functional frame without assumptions or a new
trusted body. This covers current contracts under explicit callee contracts;
full constructors, Reset/state/dynamics and complete physical simulation remain
open. No production ABI/version pin is changed.

Fresh native validation/release builds pass528 cases per pinned3.17/3.14
reference/profile. All132 outputs equal adopted2741 at unchanged16 samples,
100 steps and2e-10 tolerances. Ghost models are absent from native symbols.
Whole MJ.Data flow closes, retaining the same five modeled deallocators.
The body helper is inlined in release; the larger joint builder remains one
separate call in the cold constructor. That call boundary is reported rather
than called zero overhead. There are no new memory-copy/allocation calls in the
inspected wrapper; no timing or integrated C performance parity is claimed.

The runtime audit preserves the earlier release disassembly for the body-only
variant: its metadata loop advances192 bytes per body and writes the adjacent
32-bit fields together, without a new whole-record-copy call. Counts/assembly
are diagnostics, not measurements of speed. The final separated-builder
variant has its own symbol/call audit and numerical matrix. Full feature/ABI
alignment and integrated performance parity remain part of the active goal.

The included cleanup receipt removes only verified raw ZIP duplicates and
obsolete untracked generated indices. Current recipes/payloads/index, tracked
history, source, unique evidence and active caches are preserved; no VHDX
compaction or physical-image shrink is claimed.

Adopted locally. No commit or push is implied.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_adopted=True,builder_vcs_per_reference=62,body_helper_reported_checks_per_reference=33,coordinator_reported_checks_per_reference=35,whole_simulation_closed=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
