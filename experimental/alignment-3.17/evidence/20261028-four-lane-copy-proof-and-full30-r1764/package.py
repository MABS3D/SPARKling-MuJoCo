from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp')
E=R/'experimental/alignment-3.17/evidence';D=E/'20261028-four-lane-copy-proof-and-full30-r1764'
read=lambda p:json.loads(p.read_text());sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
proofs={}
for n,name,count in [(1754,'sparkling-copy-four-unrolled-min',77),(1759,'sparkling-copy-four-bounds317',341),(1760,'sparkling-copy-four-bounds314',341)]:
    p=V/f'{name}-r{n}-20261028/results.json';d=read(p)
    assert d['exit']==0 and d['coverage'] and d['obligations_closed'] and not d['open'] and d['checks']==count
    proofs[str(n)]={'path':str(p),'sha256':sha(p),'checks':count,'warnings':d['warnings'],
                    'source_manifest_sha256':d['sources_sha256']}
for n,name in [(1752,'sparkling-copy-four-bits'),(1755,'sparkling-copy-four-unrolled-bits')]:
    d=read(V/f'{name}-r{n}-20261028/results.json');assert d['passed'] and len(d['records'])==4
for tag,n in [('317',1757),('314',1758)]:assert read(V/f'sparkling-copy-four-numerical{tag}-r{n}-20261028/results.json')['passed']
f=V/'sparkling-copy-four-full30-r1763-20261028/replicas/results.json';timing=read(f)
assert timing['passed'] and len(timing['records'])==30 and timing['replicas']==6 and timing['unchanged_binaries'] and timing['identical_shared_libraries']
assert read(V/'sparkling-copy-four-full30-r1763-20261028/completion.json')['exit']==0
q=read(V/'sparkling-copy-four-readiness-r1762-20261028/results.json')
assert q['ready_for_diagnostic_timing'] and not q['formal_qualification_passed'] and not q['whole_actual_solve_closed'] and not q['production_adopted']
roots=[]
for p in sorted(V.iterdir()):
    m=re.search(r'-r(\d+)-20261028$',p.name)
    if p.is_dir() and p.name.startswith('sparkling-') and m and 1748<=int(m[1])<=1763:roots.append(p)
source_roots=[]
for root in roots:
    for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
        tree=manifest.parent/'source'
        if manifest.is_file() and tree.is_dir():
            h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items());source_roots.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'four-lane-copy.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    def put(p,n):
        assert n not in members,n
        data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
    for root in roots:
        for folder,dirs,files in os.walk(root):
            dirs[:]=sorted(n for n in dirs if n not in {'obj','analysis','analysis314','__pycache__','.git'})
            for name in sorted(files):
                p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
    # These shared caches now contain the final1753 whole-unit VCs, not the
    # partial1748 watchdog. Their source scope is explicit in the archive name.
    for tag,analysis in [('317',V/'sparkling-common-copy-min-r1696-20261027/analysis'),('314',V/'sparkling-common-bounds314-r1700-20261028/analysis')]:
        for pattern in ['*row_bounds*.gnat-json','mj-solver_kernels-row_bounds.spark']:
            for p in sorted(analysis.rglob(pattern)):
                put(p,'final1753-proof-artifacts/'+tag+'/'+p.relative_to(analysis).as_posix())
with zipfile.ZipFile(Z) as z:
    assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in source_roots:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',{'files':members,'roots':[str(p) for p in roots],
     'zip_sha256':sha(Z),'zip_bytes':Z.stat().st_size,
     'scope':'Terminal exact frozen sources, scoped proof receipts, final whole-unit VCs, codegen, fresh bit/numerical tests and full30 raw replicated diagnostics. Compiler caches excluded. The initial1748 watchdog is a failure with no fresh complete report; its subsequent one-second diagnostic remains under that original source binding.'})
dump(D/'summary.json',{'proofs':proofs,'measurements':{'path':str(f),'sha256':sha(f),
     'records':[{k:x[k] for k in ['model','state','current_over_baseline','current_over_c']} for x in timing['records']]},
     'ready_for_diagnostic_timing':True,'formal_qualification_passed':False,
     'production_adopted':False,'performance_acceptance_passed':False,
     'scope':'Four-lane copy is functionally proved under unchanged contracts, but integrated regressions reject adoption. Counts are separate scopes and are not additive. Existing actual-Solve state/configuration obligations remain open. No whole-port/latest migration or C performance parity.'})
(D/'README.md').write_text('''# Four-lane packed-copy proof and integrated rejection

The private common-domain copy now accumulates four independent maxima, then
combines them and handles the final 1–3 elements. Generic Copy_Row, all public
contracts, rejection domains and other source files remain unchanged. The
initial attempt times out and exposes a Source'Length conversion issue for an
extreme array bound. The final 1753 version divides an Int64 length before
converting to Natural and explicitly unrolls each four-element group.

The final minimum closes 77 checks. Complete Row_Bounds units close 341 on
both reference closures, including exact copy, maximum/witness, packed-row
coverage and frame properties. Warnings remain visible: the minimum has eight
FOR-loop array-initialization precision warnings; each whole unit has 13 total
warnings. Actual initialization obligations close. There are no assumptions,
suppressed checks, new trusted port bodies or changed inline directives.
Counts describe separate scopes and must not be added together.

Fresh bit checks pass 12,336 scenarios in each of the four standard profiles:
0–256 DOFs, chains, independent roots and deterministic forests; signed zeros,
subnormals, work caps and their predecessors, maxima in every lane, random data,
all remainder classes, copied bits, source preservation and untouched guards.
The oracle is the unchanged proved sequential Copy_Row. Test-only bit conversion
is outside the SPARK port. Both-reference/profile activation/integration and
all 30 actual movement endpoints also pass; Ada endpoints match the original
baseline exactly and native C uses the unchanged 2e-10 oracle tolerance.

Disassembly confirms four independent scalar maximum accumulators. It also
retains checked index arithmetic; no vectorized maximum or speedup is inferred
from source structure alone. Six-replica full-30 diagnostics use unchanged
baseline1319, candidate1753 and native C3.17 SIMD/LTO, fixed inputs/forces and
balanced orders, with all own heavy jobs idle. Raw outputs and uncertainty are
preserved. The candidate is slower than published Ada by 8.15–8.77 percent on
free_ball, 6.24–6.90 percent on chain_24, and 5.48–5.65 percent on branches_24.
Their per-state 95-percent intervals are above parity. Lower medians on ball,
free and fixed_tendon have intervals including parity, so they do not establish
speedups. No aggregate percentage average or faster-case count is an acceptance
metric. Relative to native C, the candidate remains about 1.63x, 1.95x and 1.55x
on those three models respectively.

The candidate is not adopted. Formal qualification also remains false: three
existing configuration/state obligations in the actual caller remain open.
The unchanged caller's earlier partial receipts retain their original bindings;
fresh whole Row_Bounds reports establish the unchanged callee contracts only.
Production numerical code is unchanged. Full port, coordinated latest migration,
whole dynamics/factorization Gold and parity with C remain unfinished. A plan
for tighter pose-producer bounds is archived explicitly as unimplemented work.
This checkpoint is local. Exact ZIP bytes can be reconstructed using the store.
''')
dump(D/'verification.json',{'passed':True,'members_verified':len(members),'zip_sha256':sha(Z),
     'frozen_sources_unchanged':True,'selected_outputs_terminal':True,
     'whole_row_bounds_closed':True,'whole_actual_solve_closed':False,
     'formal_qualification_passed':False,'production_adopted':False,'performance_acceptance_passed':False})
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
    if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps({'roots':len(roots),'members':len(members),'zip_bytes':Z.stat().st_size,
                  'inventory_files':inv['count']}),flush=True)
