from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-external-force-bounds-and-pose-producers-r2037'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
proofs={}
for n in [2041,2042]:
 p=next(V.glob(f'sparkling-*-r{n}-20261028/results.json'));d=read(p)
 assert d['exit']==0 and d['obligations_closed'] and d['coverage'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged']
 proofs[str(n)]={'path':str(p),'sha256':sha(p),'checks':d['checks'],'warnings':d['warnings']}
bits=V/'sparkling-external-leaf-bits-r1974-20261028/results.json';assert read(bits)['passed']
adopted={}
for n in [1855,1890]:
 p=next(V.glob(f'sparkling-*-adoption-r{n}-20261028/adoption.json'));d=read(p);assert sha(R/d['file'])==d['new_sha256'];adopted[d['file']]=d['new_sha256']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261028$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1897<=int(m[1])<=2042 and int(m[1])!=2037:roots.append(p)
sources=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'external-force-bounds-and-pose-producers.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in {'obj','analysis','analysis314','__pycache__','.git'})
   for name in sorted(files):
    if 'analysis' in root.name and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out'}):continue
    p=Path(folder)/name;n=root.name+'/'+p.relative_to(root).as_posix();assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Terminal private prototypes, exact source snapshots, scoped proof results, failed variants, partial reports, generated SMT diagnostics, and actual-leaf bit tests. Generated caches excluded. No production adoption.'))
dump(D/'summary.json',dict(build_one_body=proofs,leaf_bits=read(bits),unchanged_production=adopted,production_adopted=False,global_pose_tree_closed=False,whole_dynamics_closed=False,new_performance_measured=False))
(D/'README.md').write_text('''# External-force bounds and pose producers: private proof checkpoint

These private prototypes establish the local arithmetic needed to remove
redundant numerical checks from external-force projection. Production sources
still match the previously adopted r1855/r1890 math and dynamics receipts.
No new runtime change is adopted, no global scan is removed, and no new
integrated performance measurement is claimed.

Work_Rounding closes 34 checks on each reference. External_Force_Bounds closes
25 on each reference, proving column and wrench-contribution bounds while
preserving the exact floating-point evaluation order. The monotonic-addition
lemma is the existing reviewed SPARK Long_Float_Arithmetic boundary; this work
introduces no new trusted port body, assumption or suppression and does not
claim a new Coq replay. Matching math subtraction27 and Cross98 scopes close.

New unwired bounded leaves close Column_Bounded15 and
Accumulate_Bounded_Column14 on each reference, with exact output/frame
properties. An actual-leaf comparison passes 20,768 exact-input-bit cases in
each of four profile/reference builds, including signed zeros, subnormals,
extreme admitted geometry/wrenches and high nonzero array lower bounds.
These are unit composition tests, not a complete simulation comparison.

The private pose chain closes Pose_Frames53, Pose_Growth31, Fixed_Position15,
Fixed_Frame31, Finalize_Body_Frame14 and Apply_One_Joint45 on both references.
Build_One_Body closes all113 obligations on both references in the final r2038
source, including position/center growth, joint anchors and previous default
contracts. Its nine existing warnings remain visible. Pose_Bounds172 closes
on both references before the final Transfer_Cover4 addition; that addition is
proved separately. Do not interpret these scopes as a fresh whole176 report.
Pose_Rounding34 has fresh whole results on both references. Existing inherited
math warnings and the integer reassociation warning in Pose_Bounds are retained.
Separate scoped counts must not be summed into whole-program assurance.

The archive retains initial compile errors, unsupported-loop variants, watchdog
outcomes and the partial r2034 body report (105 closed/five open) that led to
the final successful repair. Source manifests and every archive member are
hashed before/after packaging. Cache exclusions retain relevant copied proof
receipts and standalone generated SMT diagnostics.

Remaining work includes propagation through the complete body tree, the
free/ball manifold paths, mocap and state lifecycle contracts, storage/cache
publication and all external-force caller preconditions. The bounded leaves
remain unwired until those obligations close. Full state/dynamics/factorization
Gold, complete feature coverage, coordinated latest ABI migration and parity
with native C remain open. This checkpoint is local; no extra commit or push.
Restore the exact ZIP with tools/evidence_store.py.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_adopted=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
