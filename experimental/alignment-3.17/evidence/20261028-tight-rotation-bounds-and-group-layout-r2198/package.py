from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-tight-rotation-bounds-and-group-layout-r2198'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
proofs={}
for n in [2103,2105,2106,2110,2114,2116,2124,2128,2129,2137,2141,2143,2149,2151,2154,2157,2159,2163,2165,2169,2170,2171,2172,2177,2178,2195]:
 p=next(V.glob(f'sparkling-*-r{n}-20261028/results.json'));d=read(p);assert d['exit']==0 and d['coverage'] and d['obligations_closed'] and d['fresh_scoped_report'] and not d['open'] and d['source_hashes_unchanged'],str(p)
 assert 'generation of data representation information failed' not in (p.parent/'proof.log').read_text(),str(p)
 proofs[str(n)]={'path':str(p),'sha256':sha(p),'checks':d['checks'],'warnings':d['warnings'],'sources_sha256':d['sources_sha256']}
# These attempts must be terminal but are retained with their actual status.
attempts={}
for n in [2117,2120,2126,2133,2145,2146,2152,2167,2174,2181,2185,2188,2193]:
 p=next(V.glob(f'sparkling-*-r{n}-20261028/results.json'));d=read(p);attempts[str(n)]={k:d.get(k) for k in ['exit','checks','coverage','obligations_closed','fresh_scoped_report','seconds','open']}
controls=read(V/'sparkling-static-invariant-probe-r2175-20261028/results.json');assert controls['passed']
cleanup=read(V/'sparkling-zip-duplicate-cleanup-r2190-20261028/results.json');assert cleanup['passed'] and len(cleanup['removed'])==35
adopt=read(V/'sparkling-group-layout-adoption-r2183-20261028/adoption.json');assert adopt['production_adopted'] and all(sha(R/n)==h for n,h in adopt['files'].items());assert read(V/'sparkling-group-layout-actual-build-r2184-20261028/results.json')['passed']
base={}
for n in [1855,1890]:
 p=next(V.glob(f'sparkling-*-adoption-r{n}-20261028/adoption.json'));d=read(p);assert sha(R/d['file'])==d['new_sha256'];base[d['file']]=d['new_sha256']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261028$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 2101<=int(m[1])<=2197:roots.append(p)
sources=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'tight-rotation-bounds-and-group-layout.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  is_analysis='analysis' in root.name
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if is_analysis else {'obj','analysis','analysis314','__pycache__','.git'}))
   for name in sorted(files):
    if is_analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
 for n in adopt['files']:put(R/n,'adopted-production/'+n)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Terminal exact source snapshots; whole/scoped rotation and group proofs; failed/watchdog variants; cache-resume audit/partial reports; explicit standard-library boundary provenance; Static invariant positive/negative control; mocap prototype actual outcomes; adopted Ghost-only module/current-project compile; verified exact raw ZIP cleanup receipts. No numerical/performance timing this checkpoint.'))
dump(D/'summary.json',dict(proofs=proofs,attempts=attempts,ghost_group_layout_adoption=adopt,unchanged_numerical_sources=base,static_invariant_controls=controls,cleanup={k:cleanup[k] for k in ['removed_bytes','windows_free_before','windows_free_after']},mocap_invariant_adopted=False,rotation_prototype_adopted=False,whole_dynamics_closed=False,new_performance_measured=False))
(D/'README.md').write_text('''# Tight rotation bounds and expanded joint-group structure

The independent Ghost Rotation_Bounds unit closes all166 obligations on each
reference, under the existing Unit_Quaternion precondition and reviewed standard
library boundaries. All matrix entries of the original ordered Rotation formula
are within1.00001. The proof bounds the exact-real squared norm from the actual
ordered floating norm, accounts for product/add/subtract roundoff, applies a
proved Young inequality, and proves diagonal/off-diagonal entries before the
matrix. Product_Error7, Sum_Error5, Difference_Error5, Norm_Bound26,
Young_Bound7, Diagonal_Bound34, corrected Off_Diagonal_Bound31,
Entry_Bound14 and the matrix loop17 are separate scoped diagnostics, not counts
to sum into a whole-unit claim.

Initial whole166 attempts hit900-second watchdogs. All partial Why3 sessions
are preserved. The final full reports resume exactly the same source/model
cache, after a recorded manifest audit; they are fresh complete reports, not
partial reports relabeled as completion. A separate norm-splitting variant is
retained with its actual attempt outcomes and is not needed for the complete
166-check claim. The standard rounding lemma boundary is unchanged; no new Coq
replay is claimed. All19 warnings remain visible: inherited operator
reassociation and standard Big_Real/Big_Integer Is_Valid assumed-True models.
No new port Assume, suppressed check, unchecked conversion or trusted body.
The original Rotation contract stays unchanged; a separate private wrapper
consumes the theorem, avoiding a circular strengthening of Rotation itself.

The private Make_Rotation9 and Free_Position14 scopes expose the tight matrix
bound. The two store helpers prove exact fields and preservation of unaffected
entries: free48 and ball30 on both references. Initial aggregate/parenthesis and
representation-generation failures, an upper-index overflow in a superseded
contract, and an unclosed combined-index postcondition are preserved. The final
contracts specify the same six entries as two triples, and representation
information completes. The new Ball_Orientation helper reaches its watchdogs;
its exact composition proof remains open and it is not adopted. Callee contracts
(such as normalization) retain their separate existing proof scope; this work
is not a full normalized-pose or simulation proof.

MJ.Data.Group_Layout closes a fresh whole69 on both references, with two visible
integer reassociation warnings; Next_Start33 separately closes without warnings.
It specifies the native widths free6/ball3/scalar1, uniform expanded metadata,
and the next group start. This Ghost Static unit is adopted locally after exact
parent Data spec/body and cross-reference source audits. It compiles in the
actual project's ordinary validation profile. It changes no runtime field,
scan or execution path. Factory/lifecycle preservation and the complete
manifold traversal remain open; the new schema is not yet an extra Is_Ready
runtime condition.

An isolated Static type-invariant experiment includes a successful positive
proof and a deliberately failing negative proof. Its validation binary omits
only these proof-only checks as specified by the existing Static level. This
is a language feasibility control, not a bypass in production. A private mocap
prototype then carries typed mocap bounds in a Static type invariant. The
initial setter report closes the invariant checks but leaves the Configuration
snapshot frame obligation open. The final entry/equality variant closes that
frame and63 checks overall, leaving only State_Values preservation open. The
unchanged equality lemma separately closes29 checks; all attempts retain their
actual statuses in summary.json. No mocap invariant is adopted: constructor, reset and
all public state operations still need their complete lifecycle proof.

The exact store was fully verified (65 archives/436 inventory files) before
removing35 ignored, untracked raw ZIP duplicates, totaling4,588,267,819 bytes.
Each duplicate's size/hash/recipe was checked again immediately before removal.
Sources, recipes/payloads, unique proofs, active caches, other tasks and
installed toolchains are preserved. All original ZIP bytes remain exactly
reconstructable. Windows free-space samples are recorded; this was not WSL
shutdown, trim or VHDX compaction.

Production numerical math/dynamics still match r1855/r1890. External-force
bounded leaves remain unwired and production guards remain. No new numerical
suite, integrated timing or C-parity result is claimed in this checkpoint.
The previous numerical evidence retains its original source scope. Whole
state/dynamics/factorization Gold, complete features and coordinated latest ABI
migration remain open. Local work only, without another commit or push.
Restore the exact ZIP with tools/evidence_store.py.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,ghost_group_layout_adopted=True,numerical_runtime_changed=False,whole_dynamics_closed=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
