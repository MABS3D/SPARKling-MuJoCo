from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-actuator-remapping-and-caller-frame-r2649'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-remap-adoption-r2648-20261030/adoption.json');assert adopt['production_adopted'] and sha(R/adopt['source_file'])==adopt['source_sha256']
required=[2591,2594,2597,2599,2602,2604,2606,2608,2609,2610,2611,2613,2615,2623,2625,2627,2629,2630,2631,2632,2633,2634,2635,2636,2637,2639,2641,2642,2643,2644,2645,2647]
for n in required:assert len(list(V.glob(f'sparkling-*-r{n}-20261030/results.json')))==1,str(n)
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261030$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-remap-') and m and 2589<=int(m[1])<=2648:roots.append(p)
outcomes={};sources=[];analysis_roots=set()
for root in roots:
 p=root/'results.json'
 if p.is_file():
  d=read(p)
  if d.get('analysis_root'):analysis_roots.add(Path(d['analysis_root']))
  if d.get('obligations_closed'):assert d['exit']==0 and d['coverage'] and d['representation_complete'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged']
  outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:d.get(k) for k in ['subprogram','exit','checks','proof_checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven','flow_checks_closed']}}
 for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'actuator-remapping-and-caller-frame.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  analysis=root in analysis_roots or 'analysis' in root.name
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
(D/'README.md').write_text('''# Actuator remapping and constructor-frame diagnosis

The actual Remap_Actuators now receives the actuator array and dimension values,
not the entire Simulation. The constructor retains direct ownership of its body,
joint and other state fields across that call. A single-element helper preserves
the original ID/address/gear checks and five field updates, and the array helper
preserves the actuator order. Mechanical comparison covers those statements.
Validated immutable transmission metadata is loaded as an argument even on body
or rejected branches; the layout/index proofs make that extra read defined and
side-effect free. The array uses the owned Config range, equal to the original
D.Na after construction. Dead initial Ok:=False is removed from its coordinator;
element calls establish every error result and empty/success cases set True.
No additional record copy, runtime validation pass, assumption or trusted body
is introduced.

| Final scope | Reported checks per reference | Property |
| --- | ---: | --- |
| Remap_Input_Valid | 9 | Well-defined acceptance predicate |
| Remapped_Parameter | 14 | Well-defined exact record model |
| Remap_One_Actuator | 35 | Exact success/rejection, mapped fields and frame |
| Remap_Parameter_Array | 77 | Ordered composition, complete successful array and body-flag preservation |
| Prove_Joint_Kinds | 14 | Already validated joint types lie in0..3 |
| Model_Status | 14 | Original validator postcondition plus validated joint/actuator facts |
| Remap_Actuators | 37 | Complete model-to-array adapter contracts and safety |

All scopes close on both pinned3.17/3.14 closures under their explicit inputs
and callee contracts. Counts include informational flow checks; proof_checks and
existing reviewed warnings are separately recorded. Warnings make runner
passed=false while obligations_closed=true; successful closure checks the full
fresh report, representation, coverage and absence of open/skipped/assumed VCs.
This is not whole simulation safety or functional correctness.

The first attempt exposed an implicit Integer conversion of unconstrained array
Length and missing validated gear-prefix information. Int64 shape arithmetic
and proved prefix/rejection assertions close the single-element scope. The
initial array has52 checks closed with one invariant open. Subsequent240-second
attempts time out. The final Boolean-only acceptance predicate states its actual
dependency, separate prefix facts and model abstraction support composition,
and600-second guarded budgets allow complete reports: the final array takes
about273-287 seconds and adapters about379-490 seconds. No proof is claimed
from a watchdog or merely from a longer observation wait. A preparation-count
assertion failure and a corrected audit-loop parser are retained explicitly.

The already performed joint validation now has a proved Static projection and
validator postcondition; no new public input restriction or runtime joint scan
is added. Both whole MJ.Data flow checks have no open messages and zero proof
VCs; these are flow-only results. The selected Build_Manifold_Topology call in
Initialize closes7 checks with one precondition open: Body_Config nonnull cannot
yet be established. This locates remaining caller-frame work; it does not prove
the full constructor. Copy_Manifold_Joints currently requires a nonnull body
configuration but does not state its preservation in the postcondition. Its
frame and the activation loop's continuation invariants need their own proofs.

The suite adds parent-frame ball transmission and body transmission models,
giving17 fixtures and33 valid model/mode pairs. The body case has no active
contact and checks remapping/zero-moment behavior, not body-contact coupling.
Final candidate2622 passes528 cases per reference/profile,16 samples,100 steps,
unchanged2e-10 C tolerances. Unchanged2574 baseline binaries also pass this
expanded suite; all132 final output files equal those baselines byte-for-byte.
Fresh native objects emit none of the listed Ghost model/projection functions.

The remapping change is adopted locally. Complete Initialize/Create_Dynamics,
Reset and state/dynamics Gold, private mocap-invariant integration, full feature
and ABI alignment, and integrated C performance parity remain open. Existing
warnings/deallocators are retained. No timing, complete-port, commit or push
claim follows from this checkpoint.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,actual_remap_refactor_adopted=True,private_invariant_not_adopted=True))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
