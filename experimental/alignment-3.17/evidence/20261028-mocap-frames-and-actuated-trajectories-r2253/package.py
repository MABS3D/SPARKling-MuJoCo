from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-mocap-frames-and-actuated-trajectories-r2253'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261028$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 2199<=int(m[1])<=2260 and int(m[1])!=2253:roots.append(p)
required=[2201,2203,2205,2209,2211,2212,2213,2217,2219,2223,2225,2228,2230,2232,2233,2236,2238,2239,2241,2244,2247,2248,2251,2254,2256,2259]
results={}
for n in required:
 p=next(V.glob(f'sparkling-*-r{n}-20261028/results.json'));d=read(p)
 results[str(n)]={'path':str(p),'sha256':sha(p),'result':d}
 if d.get('obligations_closed'):
  assert d['exit']==0 and d['coverage'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged']
  assert 'generation of data representation information failed' not in (p.parent/'proof.log').read_text()
for n in [2232,2233,2241,2247,2248,2254]:assert results[str(n)]['result']['passed'],str(n)
sources=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'mocap-frames-and-actuated-trajectories.zip';members={}
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
 for n in ['compare.py','mocap_probe.adb']:put(R/'experimental/mocap/tests'/n,'working-tests/'+n)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(results=results,mocap_invariant_adopted=False,whole_state_closed=False,new_performance_measured=False))
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True))
(D/'README.md').write_text('''# Mocap frames and trajectories with nonzero actuation

Exact source snapshots, proof reports, build flags, numerical providers and
failed/watchdog attempts are preserved in the reconstructable ZIP. Summary
records retain actual statuses, warnings, assumptions and source hashes.

The original mocap corpus passed 272 cases per run on both references, in
validation/release for baseline and private candidate. Its 68 output files are
byte-identical between baseline and candidate. Those original models have no
actuators, so activation preservation there only exercises an empty vector.

The expanded suite adds integrator, filter and filterexact actuator fixtures
with nonzero activation, control and generalized applied force. It explicitly
checks successful mocap setters preserve state/inputs/activation, rejected
updates remain atomic, and compares poses, accelerations, reset and 100-step
trajectories against the corresponding C reference. Existing fixtures, 16
samples and 2e-10 tolerances are retained. All 368 cases pass in each of the
eight reference/profile/role runs (2944 total), and 92 baseline/candidate output
files are byte-identical. Each reference/profile/role report
has its own source and binary hashes; these are numerical checks, not universal
equivalence proofs or performance measurements.

The first private state-frame prototype closes 80 obligations, with activation
preservation still open. Free closes 5 on each reference. Existing Zero_Array9,
Equal_State_Images4, Equal_Input_Images8, Equal_Activation_Images14 and
Equal_Transitive2 close their recorded scopes. Query helper precondition order
is corrected and both state/input helpers close13, activation helper5. Whole
setter variants retain their actual outcomes; watchdogs are not complete proofs.
The activation-postcondition-only diagnostic closes its three checks under the
current cut assertions; the input-postcondition diagnostic also closes three.
Both activation/input diagnostic reports are explicitly
limited to their selected source lines and cannot establish the complete setter
or its intermediate checks. The complete attempts hit their 600-second limits.
The duplicate allocator-contract experiment fails compilation and is retained.

The Static mocap invariant remains private: constructor/reset/all public state
operations still need lifecycle closure. Whole simulation/dynamics Gold,
latest ABI migration, full functionality and C performance parity remain open.
No runtime numerical optimization is adopted by this checkpoint.
''')
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
