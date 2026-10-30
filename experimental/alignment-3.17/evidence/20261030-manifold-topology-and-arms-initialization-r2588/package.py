from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-manifold-topology-and-arms-initialization-r2588'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-manifold-adoption-r2587-20261030/adoption.json');assert adopt['production_adopted'] and sha(R/adopt['source_file'])==adopt['source_sha256']
required=[2548,2551,2553,2555,2556,2558,2560,2561,2562,2563,2565,2567,2568,2570,2571,2572,2575,2577,2579,2580,2581,2582,2583,2584,2585,2586]
for n in required:assert len(list(V.glob(f'sparkling-*-r{n}-20261030/results.json')))==1,str(n)
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261030$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-manifold-') and m and 2546<=int(m[1])<=2587:roots.append(p)
outcomes={};sources=[]
for root in roots:
 p=root/'results.json'
 if p.is_file():
  d=read(p)
  if d.get('obligations_closed'):assert d['exit']==0 and d['coverage'] and d['representation_complete'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged']
  outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:d.get(k) for k in ['subprogram','exit','checks','proof_checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven','flow_checks_closed']}}
 for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'manifold-topology-and-arms-initialization.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  analysis='analysis' in root.name
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if analysis else {'obj','analysis','__pycache__','.git'}))
   for name in sorted(files):
    if analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
 for n in [adopt['source_file'],'experimental/mocap/tests/compare.py']:put(R/n,'adopted-production/'+n)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(outcomes=outcomes,adoption=adopt,source_snapshots=len(sources),source_hashes_checked=sum(len(h) for t,h in sources),whole_initialize_closed=False,whole_reset_closed=False,mocap_type_invariant_adopted=False,new_performance_measured=False))
(D/'README.md').write_text('''# Manifold topology and proved Arms initialization

The actual manifold topology path now has three small verified stages. The
fused DOF pass copies armatures and retains the compiled dof_M0 diagonal for
simple DOFs in the same order as C mj_crb. The raw-array cache builder preserves
the original body-mass traversal, reverse parent accumulation and cache-building
call order. Its thin wrapper supplies the owned/model arrays. Mechanical source
comparison verifies those runtime statements and traversal against baseline2528.
No zero-fill pass, record copy or runtime validation scan is added.

| Final scope | Reported checks per reference | Functional scope |
| --- | ---: | --- |
| Prepare_Manifold_Dofs | 56 | Exact success/rejection criterion, armature copies, simple/fixed/effective-parent values and frame |
| Build_Manifold_Cache | 67 | Safety, initialized Arms reads, cache dimensions and DOF metadata correspondence |
| Build_Manifold_Topology | 49 | Complete wrapper safety/contracts and supplied metadata correspondence |

All three scopes close on both pinned3.17/3.14 closures. Counts include their
informational flow checks; proof_checks and existing warnings remain separate
in each receipt. Gold here concerns the stated output properties under explicit
inputs/callee contracts. It is not a proof of full physical dynamics or every
cache field's mathematical meaning. No assumption, suppression or new trusted
body is introduced.

Relaxed_Initialization tracks the array while it is filled; it does not bypass
initialization safety. The56-check scope proves that Ok implies every armature
entry is initialized. The67-check scope separately proves initialization at
both consumers. Both actual whole-unit MJ.Data flow runs now have no open
messages, including the formerly reported Arms gap. Flow-only receipts contain
zero safety/functional proof VCs and are not whole-unit Gold proofs.

The first monolithic topology proofs hit240-second watchdogs. Hiding unrelated
predicates alone did not close them. Separating the cache algorithm from the
large Model/Simulation records closes its67-check scope. The initial wrapper
then has48 checks closed and one open last-index precondition. Length equality
with the same first index is the required relation; it also handles empty arrays.
Broadening those internal shapes closes all49 wrapper checks, without narrowing
supported public inputs. The earlier selected Initialize call reaches a
240-second watchdog without a fresh report. Its precondition propagation and
the complete factory/lifecycle proof remain open.

The added mixed_dof_tree has19 position coordinates and16 velocity DOFs: a free
parent with ball/hinge children, an independent simple free body and nonzero
armatures throughout. The C3.17 simple counts are0 for the first10 DOFs and
6,5,4,3,2,1 for the final6. Together with the earlier fixtures it gives15 models
and29 valid model/mode combinations. Final candidate2574 passes464 cases per
reference/profile at16 samples,100 steps and unchanged2e-10 C tolerances.
The old2528 binaries also pass the expanded suite; all116 final output files
match those baselines byte-for-byte. Fresh native objects contain none of the
listed Ghost projection/state-image symbols. Earlier candidate variants retain
their own frozen sources and results.

The initialization/cache refactor is adopted locally. Complete Initialize,
Create_Dynamics, Reset and state/dynamics Gold, the private mocap invariant,
feature completion, latest ABI migration and integrated performance parity
remain open. Existing reviewed warnings/deallocators are preserved. No timing,
complete-port, commit or push claim follows from this checkpoint.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,actual_manifold_refactor_adopted=True,private_invariant_not_adopted=True))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
