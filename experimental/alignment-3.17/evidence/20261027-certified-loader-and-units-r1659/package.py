from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-certified-loader-and-units-r1659';Z=D/'certified-loader-and-units.zip';P=V/'sparkling-certified-current-validation-r1641-20261027';C=V/'sparkling-certified-current-r1639-20261027';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
p= P/'proofs/results.json';proofs=json.loads(p.read_text());assert proofs['passed'] and len(proofs['records'])==20
for label,r in proofs['records'].items():
 f=Path(r['path']);d=json.loads(f.read_text());assert sha(f)==r['sha256'] and d['exit']==0 and d['coverage'] and d['obligations_closed'] and not d['open'];assert d['sources_sha256']==sha(C/label[:3]/'sources.json')
num=json.loads((P/'numerics-results.json').read_text());assert num['passed']
for tag,k in [('317',1642),('314',1643)]:assert json.loads((V/f'sparkling-certified-current-numerical{tag}-r{k}-20261027/results.json').read_text())['passed']
failed=V/'sparkling-certified-actual-solve317-r1650-20261027/results.json';flow=json.loads(failed.read_text());assert not flow['obligations_closed'] and flow['exit']!=0
assert 'E0007' in (failed.parent/'proof.log').read_text()
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1617<=int(m[1])<=1650 and int(m[1])!=1624:roots.append(p)
# Every selected output producer is terminal. The newer1652/1653/1654/1655/1656/
#1657/1658 input and proof work is deliberately outside this checkpoint.
source_roots=[]
for root in roots:
 for manifest in root.glob('*/sources.json'):
  tree=manifest.parent/'source'
  if tree.is_dir():
   h=json.loads(manifest.read_text());assert all(sha(tree/n)==v for n,v in h.items());source_roots.append((manifest,tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(x for x in dirs if x not in {'obj','analysis','analysis314','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark','*load_certified_compact_buffers*.gnat-json','*prove_damped*.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis','analysis314'}&set(p.relative_to(root).parts):put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
for manifest,tree,h in source_roots:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Selected1617-1650 output producers terminal;1624 prior checkpoint omitted.1652+ corrected actual-Solve and framing attempts are outside the archive. Frozen source hashes checked before and after; original reports and failed controls retained.'))
dump(D/'summary.json',dict(proofs=proofs,numerics=num,actual_solve_flow_control=flow,source_bindings={t:sha(C/t/'sources.json') for t in ['317','314']},qualification_passed=False,production_adopted=False,performance_qualified=False,scope='Private loader and whole new child units now close under recorded source scopes on both references. Actual Solve rejects the variable-input array constraint with E0007; corrected successors and their unresolved whole-caller proofs are outside this bundle. No adoption, full inertia/dynamics/state proof, full port/latest migration or C parity claim.'))
(D/'README.md').write_text('''# Certified loader and whole child-unit checkpoint

The exact ordered-FP loader now closes66 checks on both reference closures.
Its positive-step contract names the transparent Damped_Row_Matches expression:
each diagonal equals Mass+(Step*Damping), all other row entries equal Mass;
zero step requires Factor=Mass. Per-row model17, row frame11, prefix frame15
and prefix join5 close too. The failed all-row raw-expansion controls remain;
no failed assertion or unproved helper is used in the final1639 loader.
A redundant ghost initialization is removed and its flow checks close. The
loader retains only12 inherited recursive-contract/numeric-variant warnings.

Both-reference complete certified child units close169 without warnings;
complete row-bounds children close264 with the documented three inherited AR
operator-grouping warnings and FOR-loop initialization-precision warning. Actual
initialization and functional checks close; no warning is suppressed. The
previously verified vendor Long_Float mathematical dependency remains explicit,
with supplied session/source evidence; no fresh local Coq replay is claimed.
The factor-row adapter38, compatible-buffer solver98 and packed-layout minimum25
close on both current source closures. Counts are separate scopes, not additive.
Incremental ALI compilation avoids forced rebuilds; each scoped report must be
fresh, bind the exact source manifest, and match the expected semantic count.
The initial controller import failure and its explicit correction are retained.

Both-reference/profile activation432 and integration1152 scenarios pass. All12
native mass/derivative/reverse-layout/cache/direct-CRB groups pass. Each standard
profile passes7374 native exact-bit rows (5448 certified,1807 fallback,119 empty)
and the complete66306 original arithmetic/rejection/frame corpus. The actual
integrated release binary passes all30 fixed100-step endpoints: exact Ada
baseline values and unchanged2e-10 native C oracle tolerance. No force, model,
input or tolerance is removed. Source1639 is the bound private control.

Qualification intentionally has not passed. The added actual Data.Inertia_Phase
Solve scope exposes SPARK E0007: the local Bounds subtype depends directly on
modifiable D.Nv. The runtime numeric tests do not close that proof gap. A later
successor captures the same value in a local constant; that1652+ source and its
whole-caller/framing attempts are outside this archive. The new helper/unit
proofs do not establish the whole caller, whole inertia phase, construction/state,
complete dynamics or global factorization equations. A closed postcondition under
unclosed checks is never completion.

No replicated movement timing, speedup, runtime adoption, overall C parity,
complete port or latest-version migration is claimed. Production runtime stays
389ecb827; latest pushed c0e21a38a contains earlier evidence only. This checkpoint
is local, exact ZIP bytes can be restored with tools/evidence_store.py. Original
watchdogs and short-timeout diagnostic failures are retained as failures.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),selected_outputs_terminal=True,frozen_sources_unchanged=True,both_reference_loader_closed=True,both_reference_new_children_closed=True,both_reference_numeric_pass=True,actual_solve_closed=False,qualification_passed=False,performance_qualified=False,production_adopted=False))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
