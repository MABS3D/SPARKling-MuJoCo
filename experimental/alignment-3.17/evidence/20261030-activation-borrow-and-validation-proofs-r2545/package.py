from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-activation-borrow-and-validation-proofs-r2545'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-activation-adoption-r2544-20261030/adoption.json');assert adopt['production_adopted'];assert sha(R/adopt['source_file'])==adopt['source_sha256']
required=[2482,2485,2489,2492,2493,2494,2496,2498,2499,2500,2501,2502,2503,2504,2505,2507,2510,2513,2515,2517,2518,2520,2522,2524,2525,2526,2529,2531,2532,2534,2535,2536,2538,2539,2540,2541,2542,2543]
for n in required:assert len(list(V.glob(f'sparkling-*-r{n}-20261030/results.json')))==1,str(n)
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261030$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-activation-') and m and 2480<=int(m[1])<=2544:roots.append(p)
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
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'activation-borrow-and-validation-proofs.zip';members={}
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
 for n in [adopt['source_file'],'experimental/mocap/tests/compare.py']:
  put(R/n,'adopted-production/'+n)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(outcomes=outcomes,adoption=adopt,source_snapshots=len(sources),source_hashes_checked=sum(len(h) for t,h in sources),whole_initialize_closed=False,whole_reset_closed=False,mocap_type_invariant_adopted=False,new_performance_measured=False))
(D/'README.md').write_text('''# Activation borrow removal and validation proofs

The actual constructor now configures its owned actuator element through an
in-place helper. The helper receives no Simulation and never frees it. Error
cleanup runs after its element borrow ends, with no whole-record copy. A
mechanical comparison confirms the original check/copy statements and order,
allowing only the explicit result/flag handoff and erased proof invariants.
The earlier borrow error is absent from fresh whole-unit flow analysis.

Fresh final-source scopes close on both pinned 3.17/3.14 closures:

| Scope | Checks per reference | Claim |
| --- | ---: | --- |
| Configure_Activation | 153 | Safety and successful output/frame relations |
| Prove_Actuator_Dynamics | 10 | Accepted actuator implies supported dynamics code |
| Prove_Model_Geom_Layout | 3 | Valid layout implies the geometry layout component |
| Model_Status | 13 | Complete current validator contracts under its callees |

Counts include reported informational flow checks; proof_checks is separately
recorded in each receipt. Existing reviewed floating-point warnings remain;
runner passed=false from those warnings does not mean obligations_closed=false.
No assumption, suppression or new trusted body is added. New proof contracts,
projections and invariants are Static and absent from fresh native objects.

The raw helper initially lacked the independent Nout index bound required by
actuator_lengthrange. Its added internal Static bound follows from the existing
constructor's Nout=Nactuator validation; supported public inputs are unchanged.
Moving the validator's original contracts to a forward declaration caused GNAT
Storage_Error failures on both references. A64MiB stack retry did not resolve
it. Body-local Static conditions with the original contract placement avoid
that failure. An incorrectly ordered Hide_Info variant is retained as failed.

The previous baseline itself leaves Dynamics_Inputs unproved in Model_Status.
A small proved geometry-layout projection supplies the missing Boolean fact,
closing both the original validator postcondition and added Static facts.
The supported-dynamics projection also closes independently. A selected call
inside Initialize closes8 checks under its intermediate facts; that diagnostic
is not the complete caller proof. The broader activation region hits its
240-second watchdog without a fresh report and remains unfinished.

Final candidate2528 passes432 cases per reference/profile:14 models,27 valid
model/mode combinations,16 samples,100 steps,unchanged2e-10 C tolerances.
The added muscle and mixed none/integrator/filter/filterexact/muscle fixtures
exercise parameter copies and activation addresses. All108 final output files
equal the earlier binary baseline byte-for-byte. Baseline and candidate binaries
for the expanded comparison are hash-checked against their build receipts.
Earlier400-case and intermediate Static-only variants retain their exact scope.

Actual whole-unit flow still has exactly two known Arms initialization messages.
The private relaxed-initialization prototype closes flow checks, but its complete
builder safety/functional proof is not established and is not adopted. The
mocap type invariant, complete Initialize/Reset/state proof, feature completion,
latest ABI migration and integrated C performance parity remain open. No new
timing claim, commit or push follows from this checkpoint.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,actual_activation_refactor_adopted=True,private_invariant_not_adopted=True))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
