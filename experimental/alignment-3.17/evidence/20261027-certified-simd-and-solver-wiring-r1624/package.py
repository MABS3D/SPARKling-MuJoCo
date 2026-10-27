from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-certified-simd-and-solver-wiring-r1624';Z=D/'certified-simd-and-solver-wiring.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
proofs={}
for n,c in [('sparkling-certified-window317-unit-r1543-20261027',162),('sparkling-certified-window314-unit-r1544-20261027',162),('sparkling-certified-base317-unit-r1567-20261027',169),('sparkling-certified-base314-unit-r1569-20261027',169),('sparkling-certified-all-bounds-unit-r1608-20261027',264),('sparkling-certified-solver-initialized-min-r1603-20261027',98)]:
 p=V/n/'results.json';d=json.loads(p.read_text());assert d['exit']==0 and d['obligations_closed'] and d['coverage'] and not d['open'] and d['checks']==c;proofs[n]=dict(sha256=sha(p),checks=c,warnings=d['warnings'],scope='Exact recorded source and original command scope, not a broader dynamics proof.')
nums={}
for n in ['sparkling-certified-numerical317-r1615-20261027','sparkling-certified-numerical314-r1616-20261027']:
 p=V/n/'results.json';d=json.loads(p.read_text());assert d['passed'];nums[n]=dict(sha256=sha(p),profiles={k:{s:rec['summary']['scenarios'] for s,rec in v['suites'].items()} for k,v in d['records'].items() if k.startswith('candidate-')})
assert json.loads((V/'sparkling-certified-movement-endpoints-r1604-20261027/results.json').read_text())['passed']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1535<=int(m[1])<=1616 and int(m[1])!=1614:roots.append(p)
# All selected output jobs have terminated. Gate1619 and prefix1620 are outside
# this bundle; a gate may still read immutable1610 source inputs into1619 outputs.
source_roots=[]
for root in roots:
 for manifest in root.glob('*/sources.json'):
  tree=manifest.parent/'source'
  if tree.is_dir():
   h=json.loads(manifest.read_text());assert all(sha(tree/n)==v for n,v in h.items());source_roots.append((manifest,tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(x for x in dirs if x not in {'obj','analysis','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark','*load_certified_compact_buffers*.gnat-json','*prove_damped_rows_join*.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
 for p in sorted(V.glob('sparkling-certified-numerical*-r161[56].driver.log')):put(p,'logs/'+p.name)
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
for manifest,tree,h in source_roots:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Selected1535-1616 outputs terminal; active1614 gate controller,1619 outputs and1617+ prefix-frame work excluded. Frozen source1610 may be read by later consumers into excluded output directories; its full source hashes checked before/after packaging. Generated caches excluded except available unique proof reports/diagnostic inputs.'))
dump(D/'summary.json',dict(proofs=proofs,numerics=nums,integrated_endpoints=json.loads((V/'sparkling-certified-movement-endpoints-r1604-20261027/results.json').read_text()),codegen=json.loads((V/'sparkling-certified-window-codegen-r1541-20261027/results.json').read_text()),scope='Private integrated certificate prototype, not production adoption. SIMD kernel and row adapter/caller/bound module scopes close as recorded; loader functional prefix remains open. All inherited warnings and additional initialization warning remain explicit. Full AR unit600 watchdog retained, no whole-constructor claim. No movement timing or speedup claim.'))
(D/'README.md').write_text('''# Certified SIMD row and private solver wiring

A zero-origin ordinary checked window preserves full public domains and the
original ordered FP expression without pointer casts, assumptions, suppression
or new forced-inline directives. Both-reference complete child162 closures and
fresh both-profile native7374 exact-bit corpora pass. Strict release/LTO codegen
has2 packed add/multiply sites in the certified kernel. A later base-Real formal
interface moves the same numeric limits into proved Pre, avoiding new scalar
conversion checks at internal callers. Both-reference complete units close169
without warnings; fresh7374/profile native bits pass. Counts are not additive.

The ghost packed-layout minimum closes25 on both references. The full AR
unit control reaches its600-second watchdog without a complete report; this
is unfinished proof engineering, not a mathematical exception or completion of
constructors. Original AR runtime bodies are unchanged. All partial controls stay.

One-pass packed copy/max, exact row bounds, covers-through model, row separation,
frame transfer, certified single-entry store and exclusion of a completed row are
implemented. The complete bound child closes264 on the recorded C17 closure;
three inherited AR grouping warnings and the explicit FOR-loop initialization
precision warning remain. Bounds is initialized as a complete zero aggregate
before element assignments, and all initialization/functional checks close;
the warning is retained, not suppressed or relabeled absent.

Damping keeps Value+(Step*Damping). A failed static-constant assertion is retained;
a separate nonstatic FP-rounding lemma closes4, and Damped_Value closes23 under
the existing verified Long_Float addition-monotonicity contract. Exact vendor
source and valid matching shipped session are retained; no fresh Coq replay or
new trusted port body is claimed. No original input/rejection policy is narrowed.

The one-row factor update adapter closes38 under the original fallback and full
buffer frame. It reuses caller-computed starts/length like C. Private compact
compatible solver wiring uses certificates only where existing long-row cutoff8
can be reached (Nv>8); smaller/dense/strict paths retain original loaders. The
reverse LDL, pivot diagnostics, source scale and both substitutions stay. The
solver caller minimum closes98 after correcting a ghost snapshot initialization;
its12 inherited warnings remain. This does not prove the whole inertia phase,
global factorization equations, construction/state or complete dynamics.

The loader functional diagonal/prefix relation is still open. Original600-second
diagnosis and split-tail/model-join controls remain, including posts proved under
unproved obligations. A pure model-join minimum closes5 but does not resolve
preservation across a mutation; later1617+ frame work is outside this archive.
No unproved assertion/helper or narrow caller report establishes global closure.

The actual integrated release binary passes all30 fixed100-step endpoint cases:
Ada candidate endpoints exactly equal the published baseline, each role matches
the pinned native C oracle at unchanged2e-10 tolerances. One sample/one warmup
only executes the numeric protocol; elapsed fields are ignored during concurrent
proof work. Both-reference/profile activation432 and integration1152 pass, with
only vendor GPR source lookup configured and original inputs/tolerances retained.
The later12-group gate and prefix-frame work are outside this bundle.

All work is private/local; production remains389 source, last pushed894063268
changes earlier evidence only. No integrated performance comparison, speedup,
runtime adoption, overall C parity, complete port/latest migration or whole Gold
dynamics is claimed. Exact ZIP restoration uses tools/evidence_store.py.
No new commit/push, cache cleanup or Linux-image compaction is performed.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),selected_outputs_terminal=True,frozen_sources_unchanged=True,proof_scopes_recorded=True,all30_integrated_endpoints_pass=True,both_reference_profile_activation_integration_pass=True,loader_functional_closure=False,performance_qualified=False,production_adopted=False))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
