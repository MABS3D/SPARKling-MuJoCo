from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-reset-mocap-loop-and-state-frame-r2470'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adoption=read(V/'sparkling-clear-frame-adoption-r2420-20261030/adoption.json');assert adoption['production_adopted'] and all(sha(R/n)==h for n,h in adoption['files'].items())
audit=read(V/'sparkling-reset-clear-audit-r2437-20261030/results.json');assert audit['passed'] and audit['output_files']==184
required=[2383,2385,2387,2389,2393,2397,2403,2405,2407,2409,2410,2412,2413,2416,2417,2421,2424,2427,2428,2431,2435,2439,2442,2446,2450,2451,2455,2460,2462,2463,2465]
for n in required:assert len(list(V.glob(f'sparkling-*-r{n}-20261030/results.json')))==1,str(n)
for n in [2383,2385,2387,2389,2403,2405,2409,2410,2416,2417,2450,2451,2462,2463]:assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['obligations_closed'],str(n)
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261030$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 2381<=int(m[1])<=2466:roots.append(p)
outcomes={};sources=[]
for root in roots:
 p=root/'results.json'
 if p.is_file():
  d=read(p)
  if d.get('obligations_closed'):assert d['exit']==0 and d['coverage'] and d['representation_complete'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged']
  outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:d.get(k) for k in ['exit','checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven','flow_mode_only','flow_checks_closed']}}
 for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'reset-mocap-loop-and-state-frame.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  analysis='analysis' in root.name
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if analysis else {'obj','analysis','analysis314','__pycache__','.git'}))
   for name in sorted(files):
    if analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
 for n in adoption['files']:put(R/n,'adopted-production/'+n)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(outcomes=outcomes,adoption=adoption,numerical_audit=audit,source_snapshots=len(sources),source_hashes_checked=sum(len(h) for t,h in sources),whole_reset_closed=False,whole_initialize_closed=False,mocap_type_invariant_adopted=False,new_performance_measured=False))
(D/'README.md').write_text('''# Mocap reset loop and state-buffer preservation

The independent private Reset_Mocap_Poses scope closes52 checks on each
reference closure. Under explicit mapping/layout/bounded-input assumptions it
copies every mapped body's original position and raw quaternion, preserving
typed bounds. Its indexed traversal has the same body order and two copies as
C mj_resetData. This helper is not wired into production: its public caller and
constructor/state-invariant integration remain open.

The actual Clear_State body remains the same four buffer assignments with the
same existing Pre/Post. Additional Static contracts prove mocap nullity, values
and index ranges are preserved, using two Ghost queries. Fresh scopes close50
on both references. These contracts are adopted locally; no type invariant,
runtime field or scan is introduced. The3.14 body projection6, model loop26,
validity projection4 and wrapper10 also close their recorded private scopes.

Both actual-frame and private-lifecycle candidates pass1472 new C cases each:
368 per reference/profile,16 samples,100 steps and unchanged2e-10 tolerances.
All184 output files equal the previously verified baseline. Validation objects
emit neither Ghost state-image query; prototype invariant predicates also have
no emitted symbols. Clear_State is1782 bytes in each validation closure. Code
size and numerical checks are not a performance measurement.

The new private state invariant carries typed mocap inputs, raw-reference bounds
and mapping facts. Free5 closes on3.17. The helper's call inside Reset closes7
checks in an explicitly line-limited diagnostic; this does not prove Reset.
Full Reset attempts hit600-second watchdogs. New internal Initialize MC/clamp
postconditions support caller reasoning but remain unproved as a whole. Create
reports close26 with one compound postcondition open; no factory completion is
claimed. Failed quote qualification and incompatible scope-switch attempts are
preserved with their actual status.

Constructor-wide flow diagnosis finds an actuator-reference borrow across D
cleanup and an unrecognized Arms initialization. Canonical array range alone
does not close that flow warning. A Relaxed_Initialization prototype explicitly
tracks and requires Initialized without a zero-fill pass. The selected-line
Initialized assertion is proved; the complete builder attempt reaches its
watchdog. Both reports retain their actual scopes and outcomes.
Relaxed initialization is not accepted here as a whole-builder proof.

A concrete C3.17 fixture has one ball joint and three DOFs on the same body.
Copy_Manifold_Joints changes owned joint counts/addresses to DOF metadata, so
full Matches_Body is too strong for the later raw-reference projection. The
weakened precondition requires only the copied raw quaternion equality. This
broader projection closes28 per reference and its wrapper12 per reference,
with no change to the desired raw-bound postcondition or runtime behavior.

Next work is to remove the constructor borrow without copying actuator records,
carry the precise immutable component frames, and close whole Reset/constructor
proofs before adopting the private invariant or removing more guards. Whole
state/dynamics Gold, full features, latest ABI migration and integrated C
performance parity remain open. No new commit or push is performed.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,actual_clear_frame_adopted=True,private_invariant_not_adopted=True))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
