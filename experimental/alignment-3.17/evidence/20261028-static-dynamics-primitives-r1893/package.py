from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-static-dynamics-primitives-r1893'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-dynamics-base-adoption-r1890-20261028/adoption.json');assert adopt['production_adopted'] and sha(R/adopt['file'])==adopt['new_sha256']
ready=read(V/'sparkling-dynamics-base-readiness-r1889-20261028/results.json');assert ready['ready_for_diagnostic_timing'] and not ready['formal_qualification_passed'];proofs={}
for key,rec in ready['records'].items():
 if not key.startswith(('317-','314-')):continue
 p=Path(rec['path']);d=read(p);assert d['exit']==0 and d['coverage'] and d['obligations_closed'] and not d['open'] and not d['warnings'];assert sha(p)==rec['sha256'];proofs[key]=dict(rec)
assert len(proofs)==20
for n in ['sparkling-dynamics-base-numerical317-r1883-20261028','sparkling-dynamics-base-numerical314-r1884-20261028','sparkling-dynamics-base-bits-r1885-20261028','sparkling-dynamics-base-endpoints-r1886-20261028']:assert read(V/n/'results.json')['passed']
f=V/'sparkling-dynamics-base-full30-r1888-20261028/replicas/results.json';timing=read(f);assert timing['passed'] and len(timing['records'])==30 and timing['replicas']==6 and timing['unchanged_binaries'] and timing['identical_shared_libraries'];assert read(f.parent.parent/'completion.json')['exit']==0
assert read(V/'sparkling-dynamics-profile-r1894-20261028/results.json')['passed']
assert read(V/'sparkling-dynamics-profile-audit-r1896-20261028/results.json')['passed']
whole={}
for n in ['sparkling-dynamics-base-whole317-r1891-20261028','sparkling-dynamics-base-whole314-r1892-20261028']:
 p=V/n/'results.json';assert p.is_file();d=read(p);whole[n]={k:d.get(k) for k in ['exit','checks','coverage','obligations_closed','fresh_scoped_report','seconds']}
roots=[]
for p in sorted(V.iterdir()):
 m=re.search(r'-r(\d+)-20261028$',p.name)
 if p.is_dir() and p.name.startswith('sparkling-') and m and 1860<=int(m[1])<=1896 and int(m[1])!=1893:roots.append(p)
sources=[]
for root in roots:
 for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
  tree=manifest.parent/'source'
  if manifest.is_file() and tree.is_dir():
   h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items());sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'static-dynamics-primitives.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 def put(p,n):
  assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
 for root in roots:
  for folder,dirs,files in os.walk(root):
   dirs[:]=sorted(n for n in dirs if n not in {'obj','analysis','analysis314','__pycache__','.git'})
   for name in sorted(files):
    if 'analysis' in root.name and not (name.endswith(('.spark','.gnat-json')) or name in {'why3session.xml','gnatprove.out'}):continue
    p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
 put(R/adopt['file'],'adopted-production/'+adopt['file'])
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size,scope='Terminal frozen sources,20 scoped proof receipts,whole-unit attempt outcomes and partial Why3 XML/VCs,numerical and exact-bit tests,raw full30 six-replica diagnostics,source inverse audit and adoption. Failed initial audit1887 is preserved; its timing did not start. Generated caches excluded except final analysis proof artifacts with their actual scope; no stale report is claimed as a completed whole-unit result.'))
dump(D/'summary.json',dict(proofs=proofs,whole_smooth_dynamics=whole,measurements=dict(path=str(f),sha256=sha(f),records=[{k:x[k] for k in ['model','state','current_over_baseline','current_over_c']} for x in timing['records']]),adoption=adopt,formal_qualification_passed=False,full_port_performance_acceptance_passed=False))
(D/'README.md').write_text('''# Static bounds in dynamics primitives

The adopted incremental change replaces 29 temporary subtype constraints with
proved Static assertions in ten Smooth_Dynamics bodies. Two private scalar
helpers also replace their return subtypes with explicit proved range
postconditions and Static result checks. All public signatures, return subtypes,
contracts and required input domains remain unchanged. The exact inverse-edit
audit reconstructs the original file and proves that no other numerical body
or public specification changed. Expressions and floating-point evaluation
order are preserved. No assumption, suppressed check, new trusted port body or
forced inline directive is introduced.

Each of the ten scoped bodies closes on both reference source closures, with
zero warnings: Config_Dot18, Apply_Config17, Cross_Component12, Cross_Local17,
Cross_Transport17, Dot_Motion16, Center_Acceleration35, Mass_Contribution25,
Prepared_Mass_Contribution21 and Bias_Contribution17. Counts describe separate
scopes and are not added into a whole-unit claim. Complete Smooth_Dynamics
attempts retain their actual outcomes in summary.json; neither the scope proofs
nor the numerical tests establish complete state/dynamics/factorization Gold.

Both standard profiles/reference closures pass the existing activation and
supported integration suites. The exact-bit harness passes 34,304 cases per
build in eight profile/reference/role builds. It calls actual public operations
on full-domain extremes, signed zeros, subnormals and deterministic random data;
inputs travel as integer bits. Native C directly checks the four elementary
operations; composites compare actual baseline outputs rather than a mirrored
formula. Test-only unchecked conversions remain outside the port. All 30 actual
movement endpoints equal previous Ada and satisfy the unchanged native C oracle.

The baseline is the locally adopted1838 math optimization, not the older1319
checkpoint. Strict release flags and native C3.17 SIMD/LTO remain unchanged.
Six-replica full30 timing ran with this task's other heavy jobs idle. The new
incremental gain is0.91–1.26 percent on chain_24,1.74–2.09 percent on branches_24
and5.32–6.19 percent on free, with each per-state95-percent interval below
previous Ada. Ball and free_ball have lower medians but intervals include parity;
those apparent gains are inconclusive. No final case has an interval wholly
above previous Ada. Raw timings, same-code replicas and uncertainty are retained;
no percentage average or faster-case count is an acceptance metric. Direct
Ada/C medians remain1.75–1.76 on chain_24,1.37–1.38 on branches_24 and about1.21
on free. These results justify incremental local adoption, not C parity.

The first audit script failed because substring counting confused Y and XY;
the corrected exact-name audit passes. That failure and the source-bound proof
receipts are retained. Full-port features, coordinated latest ABI migration,
whole state/dynamics/factorization Gold and C parity remain open. The current
math gains remain adopted. A refreshed flat PC profile on chain_24 state0 is archived, and all10,000
profiled endpoints per role equal the uninstrumented result. Many timer overruns
limit precision: the received-sample fractions identify candidate functions,
not exact phase costs or causal slowdown fractions. Current Solve_Acceleration
(external-force projection) is about20 percent of received PCs, the compatible
solver15 percent and Add_Long_Row11 percent. Inspect those guards and compact-row
paths against C before selecting further inertia work. Profile CPU/elapsed
values include instrumentation and are not replicated performance evidence. This work remains local, without an
additional commit or push. Restore the exact ZIP with tools/evidence_store.py.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_dynamics_primitives_adopted=True,whole_dynamics_closed=False,full_port_performance_acceptance_passed=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
 if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
