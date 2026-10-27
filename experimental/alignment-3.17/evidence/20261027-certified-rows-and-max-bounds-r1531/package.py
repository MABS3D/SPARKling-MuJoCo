from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261027-certified-rows-and-max-bounds-r1531';Z=D/'certified-rows-and-max-bounds.zip';sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,d):p.write_text(json.dumps(d,indent=2)+'\n')
proofs={}
for name,count in [('sparkling-certified-final317-unit-r1529-20261027',124),('sparkling-certified-final314-unit-r1530-20261027',124),('sparkling-copy-final317-unit-r1527-20261027',26),('sparkling-copy-final314-unit-r1528-20261027',26)]:
 p=V/name/'results.json';d=json.loads(p.read_text());assert d['passed'] and d['obligations_closed'] and d['coverage'] and not d['open'] and not d['warnings'] and d['checks']==count and d['source_hashes_unchanged'];proofs[name]=dict(result_sha256=sha(p),checks=count)
C=V/'sparkling-certified-bounds-candidate-r1524-20261027'
for tag in ['317','314']:
 h=json.loads((C/tag/'sources.json').read_text());base=json.loads((V/'sparkling-adopt-row-input-r1319-20261027'/('snapshot'+tag)/'sources.json').read_text());assert all(sha(C/tag/'source'/n)==v for n,v in h.items());delta={n for n in h.keys()|base.keys() if h.get(n)!=base.get(n)};assert delta=={'experimental/dynamics-derivatives-candidate/derivatives.gpr',*[f'experimental/smooth/src/mj-solver_kernels-{stem}.{ext}' for stem in ['certified','row_bounds'] for ext in ['ads','adb']]},delta
bits=json.loads((V/'sparkling-certified-native-bits-stack-r1533-20261027/results.json').read_text());assert bits['passed'] and all(x['cases']==7374 and x['certified']==5448 and x['fallback']==1807 for x in bits['records']);assert json.loads((V/'sparkling-certified-native-bits-r1532-20261027/stack-retry.json').read_text())['passed']
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261027$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1502<=int(m[1])<=1534 and int(m[1])!=1504:roots.append(p)
for p in Path('/proc').iterdir():
 if not p.name.isdigit() or int(p.name)==os.getpid():continue
 try:
  comm=(p/'comm').read_text().strip();cmd=(p/'cmdline').read_bytes().replace(b'\0',b' ').decode(errors='replace')
  assert not (any(str(r) in cmd for r in roots) and (comm in {'gnatprove','gprbuild','gcc','gnat1','gnatwhy3','lto1','cvc5','z3','alt-ergo'} or comm.startswith('python'))),(p.name,comm)
  assert not ('benchmark_replicas.py' in cmd and comm.startswith('python'))
 except (OSError,PermissionError):pass
D.mkdir();shutil.copy2(__file__,D/'package.py');members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(x for x in dirs if x not in {'obj','analysis','__pycache__','.git'})
   for name in sorted(files):
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
  for pattern in ['why3session.xml','*.spark','*certified*.gnat-json']:
   for p in sorted(root.rglob(pattern)):
    if {'obj','analysis'}&set(p.relative_to(root).parts):put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(k)).hexdigest()==v for k,v in members.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(r) for r in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='All named1502-1534 jobs terminal; prior1504 archive is separate, and later zero-origin window1535+ is outside this bundle. Unique sources, numeric/bit outputs, codegen and complete/partial proof controls retained. Generated caches excluded except selected reports/diagnostic inputs.'))
dump(D/'summary.json',dict(proofs=proofs,bits=bits,codegen=json.loads((V/'sparkling-certified-codegen-r1534-20261027/results.json').read_text()),scope='Final1524 dedicated child certifies exact packed-row FP update, full frame, Work domain and propagated output bound. Copy_Row certifies exact copy and exact max-abs with one traversal, full array origins and null rows, no initial Target value restriction beyond existing initialized scratch. Both units close fully on both references without warnings; original production owners unchanged. Native C17 numeric corpus passes both profiles with original fallback and no case filtering. Not integrated into actual dynamics, no integrated performance claim.'))
(D/'README.md').write_text('''# Certified packed rows and fused copy bounds: private verified modules

The1524 candidate has two new child units; all existing runtime source owners
are byte-identical to actual1319/published389. Only the frozen proof project adds
explicit installed SPARK library source paths. Nothing is adopted in production.

Solver_Kernels.Certified proves the original ordered Add_Product for a disjoint
packed target/source pair, the full unchanged-cell frame, Work domain and the
rounded output envelope under two proven input certificates. Full units close124
on both references without warnings; the final minimum closes76. Earlier1503
retains one open preservation obligation,1505/1507 close67/76,1510 full units close124
with two integer grouping warnings, and1524 explicit grouping removes those.
The existing verified SPARK Long_Float monotonic mathematical dependency remains
explicit; source/session/Coq evidence is retained, not a fresh local Coq replay.

Solver_Kernels.Row_Bounds.Copy_Row proves exact component copying and exact
maximum absolute value (upper bound plus zero or source witness) in one pass.
Both-reference full units close26 without warnings. Source and target may have
different origins or be empty; initial Target values are unrestricted beyond its
existing initialized scratch mode. The initial1520 out-parameter/SourceFirst ghost
witness failure is retained;1522 uses inout like the actual loaders and a zero
initial witness, preserving null arrays with negative base-type bounds.

All7374 unchanged numeric inputs from the native row corpus are exercised on
packed source/target subranges, including sentinel/gap cells. Origin is adjusted
only where two packed rows need extra index space; no numeric case is removed.
Both validation/release match native C3.17 mju_addToScl output bits, complete-row
rejection via original fallback, source/gap/sentinel bits and exact copied max bits.
5448 cases use the certified kernel,1807 use fallback and119 are empty. An extra
negative-origin empty copy case passes. Numeric evidence is for C17 standalone
kernels, not fresh whole-C14 integration or universal C equivalence.

The original8MiB checked test stack fails at the first65535-entry packed row.
Exactly the same binary, input and oracle pass all7374 with64MiB test stack.
The rebuilt both-profile run also passes. This is a test-only stack limit;
original failure/partial output and retry bindings are preserved, no production
stack change or memory/performance result is claimed.

Strict native release/LTO disassembly shows the certified loop inlined in the
standalone harness is scalar (no packed add/multiply), while the original long-row
fallback has two packed add/multiply sites. Copy_Row has scalar max. These static
facts require further compiler work and do not establish elapsed-time savings.
The later zero-origin window1535+ is outside these proof/bit scopes.

Producing row certificates in mass copy/damping/pivot updates, maintaining them
through factorization, proving consuming callers and integrated numerical/timing
acceptance remain open. Full dynamics/state/global factorization Gold, full port,
latest migration and C parity remain open. Actual production is unchanged.
No new commit/push or cache/Linux-image cleanup. Restore exact ZIP bytes with
tools/evidence_store.py; all unsuccessful controls remain with the successes.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),both_reference_cert124_and_copy26_closed=True,zero_final_unit_warnings=True,all7374_native_cases_both_profiles=True,original_runtime_owners_unchanged=True,integrated_runtime_adoption=False,all_included_jobs_terminal=True))
inv=json.loads((E/'inventory.json').read_text());old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==v for k,v in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv);print(json.dumps(dict(zip_bytes=Z.stat().st_size,roots=len(roots),members=len(members),inventory_files=inv['count'])),flush=True)
