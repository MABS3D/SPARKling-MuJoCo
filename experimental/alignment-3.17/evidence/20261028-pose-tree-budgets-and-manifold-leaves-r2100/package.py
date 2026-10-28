from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-pose-tree-budgets-and-manifold-leaves-r2100'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
proofs={}
for n in [2045,2048,2055,2059,2063,2065,2068,2070,2071,2074,2075,2077,2081,2083,2084,2085,2086,2087,2091,2092,2096]:
 p=next(V.glob(f'sparkling-*-r{n}-20261028/results.json'));d=read(p);assert d['exit']==0 and d['coverage'] and d['obligations_closed'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged'],str(p)
 proofs[str(n)]={'path':str(p),'sha256':sha(p),'checks':d['checks'],'warnings':d['warnings'],'sources_sha256':d['sources_sha256']}
numerical={}
for n in [2093,2094,2099]:
 p=next(V.glob(f'sparkling-*-r{n}-20261028/results.json'));d=read(p);assert d['passed'];numerical[str(n)]={'path':str(p),'sha256':sha(p),'scope':d['scope']}
adopted={}
for n in [1855,1890]:
 p=next(V.glob(f'sparkling-*-adoption-r{n}-20261028/adoption.json'));d=read(p);assert sha(R/d['file'])==d['new_sha256'];adopted[d['file']]=d['new_sha256']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261028$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 2043<=int(m[1])<=2099:roots.append(p)
sources=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'pose-tree-budgets-and-manifold-leaves.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for root in roots:
  is_analysis='analysis' in root.name
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if is_analysis else {'obj','analysis','analysis314','__pycache__','.git'}))
   for name in sorted(files):
    if is_analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out'}):continue
    p=Path(folder)/name;n=root.name+'/'+p.relative_to(root).as_posix();assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Terminal frozen private pose/tree prototypes, scoped and whole small-unit proof results, unsuccessful controls, exact source/C/vendor provenance, both-reference/profile numerical suites and full30 numerical endpoints. Generated build caches excluded; standalone analysis roots retain SPARK/VC/SMT/Why3 reports. No timing or production adoption.'))
dump(D/'summary.json',dict(proofs=proofs,numerical=numerical,unchanged_production=adopted,production_adopted=False,scalar_body_tree_closed_under_explicit_preconditions=True,manifold_body_tree_closed=False,mocap_lifecycle_closed=False,whole_dynamics_closed=False,new_performance_measured=False))
(D/'README.md').write_text('''# Pose tree budgets and manifold leaves: private checkpoint

Build_Bodies closes all110 obligations on both reference closures. The scalar
body tree now carries absolute position/center/anchor bounds from the already
proved local Build_One_Body growth relation. Parent indices precede children;
the per-body budget is2*Max_Dofs+2, and every accumulated cap stays below1e22.
Store_Body_Pose closes32 checks on each reference, including explicit Static
preservation of each earlier body's geometric bound. Its runtime assignment is
unchanged. Bound_Anchor_Geometry34 also closes on each reference; its loop is
Ghost Static, so it adds no runtime scan. Public contracts/domains are unchanged.

The private scalar builder exposes mocap layout and typed-input bounds as new
Static preconditions. These are obligations for the caller/lifecycle proof,
not an assertion that the existing Is_Ready predicate already establishes them.
No extra runtime mocap scan is added. The complete manifold/free/ball traversal,
its group-layout/axis properties, mocap lifecycle, cache publication and actual
external-force caller obligations remain open. The scalar proof must not be
presented as closure of those paths or of full simulation dynamics.

Pose_Bounds closes a fresh complete203 checks on both references, including
Apply_Cover12, First_Cap5 and Start_Cover10. Pose_Rounding closes a fresh complete
48 on both references, including Subtract_Work4 and Subtract_Vector10. The
reviewed vendor floating-point arithmetic contract boundary is copied with
hashes/licenses; no new Coq replay or trusted port body is claimed.
Pose_Frames closes complete67 on both references after Relocate_Position14.
The later Free_Position addition closes13 on each reference and is used by the
private manifold branch; there is no fresh whole80 claim. All exact floating
point relations and original failure paths of the addressed scopes remain
explicit. Existing9/14/Sqrt warnings and the Pose_Bounds integer reassociation
warning stay visible; counts describe separate scopes and are not added up.

The final private2090 source passes existing activation432 and integration1152
scenarios in every one of the four reference/profile builds. Models, inputs,
forces and tolerances are unchanged. The exact unchanged adopted1860 baseline
receipts are reused only after complete source/provider hashes match; every
new candidate binary is freshly built/tested. All30 integrated100-step movement
endpoints equal actual adopted1860 Ada exactly and satisfy the existing pinned
native C3.17 oracle at unchanged2e-10 tolerances. Internal elapsed outputs are
ignored because these were numerical checks with other proof work active.

An initial anchor lemma omitted a span bound and leaves two overflow obligations;
the corrected34-check scope closes. Initial scalar-tree attempts retain their
actual121/109 closed checks and remaining obligations. The final storage frame
contract closes the missing prefix-preservation obligation. These failures and
all source-bound receipts are preserved, rather than relabeled as successes.
The movement build's inherited snapshot labels are corrected in build.json,
with its initial metadata digest retained, before endpoint diagnosis. Binary,
commands, actual source and C reference remain unchanged by that metadata fix.

Read-only pinned C excerpts record the free qpos copy, mocap composition,
ball/hinge anchor correction and external-wrench zero shortcuts. C intermediate
quaternion-vector rotation and the current Ada matrix/intermediate-normalization
path differ; the audit is not a universal bit-equivalence claim. Original C
license and reviewed SPARK vendor boundary provenance are retained.

No newly prototyped body/force path is adopted into production. Production math
and dynamics still match r1855/r1890; bounded external-force leaves remain
unwired. Whole state/dynamics/factorization Gold, full features, coordinated
latest ABI migration and C parity remain open. Work is local, with no further
commit or push. Restore the exact ZIP with tools/evidence_store.py.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_adopted=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
