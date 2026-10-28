from pathlib import Path
import hashlib,json,os,re,shutil,zipfile

R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
V=Path('/var/tmp'); E=R/'experimental/alignment-3.17/evidence'
D=E/'20261028-baseline-rebuild-and-state-proof-controls-r1747'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
def locate(n):
    found=[p for p in V.glob(f'sparkling-*-r{n}-2026102[78]') if (p/'results.json').exists()]
    assert len(found)==1,found
    return found[0]

closed={}
for n,count in [(1706,95),(1717,95),(1714,86),(1718,86),(1716,7),(1720,7),(1742,5),(1744,5)]:
    p=locate(n)/'results.json'; d=read(p)
    assert d['exit']==0 and d['obligations_closed'] and d['coverage'] and not d['open'] and d['checks']==count
    closed[str(n)]={'path':str(p),'sha256':sha(p),'checks':count,'warnings':len(d['warnings']),
                    'source_manifest_sha256':d['sources_sha256']}
normal=locate(1740)/'results.json'; d=read(normal)
assert d['coverage'] and d['fresh_scoped_report'] and not d['obligations_closed'] and d['checks']==153 and len(d['open'])==3
actual={'path':str(normal),'sha256':sha(normal),'checks':153,
        'open':[{k:e.get(k) for k in ['file','line','rule','message']} for e in d['open']]}
audit=V/'sparkling-baseline-rebuild-control-r1731-20261028/binary-comparison.json'
d=read(audit); assert d['exact_source_manifest_equal'] and d['same_text'] and d['baseline']==d['current']
endpoints=V/'sparkling-baseline-rebuild-endpoints-r1733-20261028/results.json'
d=read(endpoints);assert d['passed'] and len(d['records'])==30
bridge=V/'sparkling-solve-frame-control-r1735-20261028/state-view-ghost-audit.json'
assert read(bridge)['passed']
measurements={}
for n in [1722,1730]:
    folders=list(V.glob(f'sparkling-*-r{n}-20261028'));assert len(folders)==1
    p=folders[0]/'replicas/results.json';d=read(p)
    assert d['passed'] and d['replicas']==6 and len(d['records'])==9 and d['unchanged_binaries'] and d['identical_shared_libraries']
    measurements[str(n)]={'path':str(p),'sha256':sha(p),'records':[
        {k:x[k] for k in ['model','state','current_over_baseline','current_over_c']} for x in d['records']]}

roots=[]
for p in sorted(V.iterdir()):
    m=re.search(r'-r(\d+)-2026102[78]$',p.name)
    if not (p.is_dir() and p.name.startswith('sparkling-') and m):continue
    n=int(m[1])
    if n in {1705,1706} or 1709<=n<=1746 and n!=1715:
        if not p.name.startswith('sparkling-solve-state-view-analysis314-'):roots.append(p)
frozen=[]
for root in roots:
    for manifest in [root/'sources.json',*root.glob('*/sources.json'),*root.glob('*/*/sources.json')]:
        tree=manifest.parent/'source'
        if manifest.is_file() and tree.is_dir():
            h=read(manifest);assert all(sha(tree/n)==x for n,x in h.items());frozen.append((tree,h))

D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'rebuild-and-frame-controls.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    def put(p,n):
        assert n not in members,n
        data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
    for root in roots:
        for folder,dirs,files in os.walk(root):
            dirs[:]=sorted(n for n in dirs if n not in {'obj','analysis','analysis314','__pycache__','.git'})
            for name in sorted(files):
                p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
        for pattern in ['why3session.xml','*.spark','*.gnat-json']:
            for p in sorted(root.rglob(pattern)):
                if {'obj','analysis','analysis314'}&set(p.relative_to(root).parts):
                    put(p,'generated-reports/'+root.name+'/'+p.relative_to(root).as_posix())
with zipfile.ZipFile(Z) as z:
    assert z.testzip() is None
    assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in frozen:assert all(sha(tree/n)==x for n,x in h.items())
dump(D/'archive-manifest.json',{'roots':[str(p) for p in roots],'files':members,
     'zip_sha256':sha(Z),'zip_bytes':Z.stat().st_size,
     'scope':'Terminal private controls only. Frozen sources, scoped proof receipts, numerical outputs, raw replicated diagnostics and unsuccessful attempts retained. Generated compiler caches excluded; selected existing proof/session reports retained separately. The partial1737 preparation and cancelled1738 attempt are explicitly not evidence for the intended corrected source.'})
dump(D/'summary.json',{'closed_minima':closed,'normal_actual_solve':actual,
     'same_source_rebuild_audit':{'path':str(audit),'sha256':sha(audit)},
     'fresh_baseline_endpoints':{'path':str(endpoints),'sha256':sha(endpoints)},
     'state_view_ghost_audit':{'path':str(bridge),'sha256':sha(bridge)},
     'diagnostic_measurements':measurements,'formal_qualification_passed':False,
     'production_adopted':False,'scope':'Counts describe distinct scopes and are not additive. State view lemma closes5 on both refs, but all three main state/configuration obligations remain in the normal1739 caller. One-second diagnostics are not normal-scope closure. Split/outlining controls remain slower and unadopted. The exact baseline rebuild rules out a binary difference for that same-source/current-recipe control only; it is not a general causal compiler analysis or C parity result.'})
(D/'README.md').write_text('''# Baseline reproducibility and state proof controls

Rebuilding the published1319 Ada source using the current strict build recipe
produces the exact same executable, SHA-256
`ddad4bf451f092e089bc336bb774216270373cb72aef00f3c8c6391036bbbc62`.
Both files contain2,973,320 bytes; their text sections match too. Source manifests
are identical. The added vendor search paths do not change this result. All30
fresh100-step endpoints equal baseline Ada exactly and satisfy the original
native C oracle at2e-10. No new timing is needed to compare identical binaries.
This rules out a baseline binary discrepancy for this particular rebuild; it
does not rule out code layout or compiler effects between different programs.

The preceding private split separates the legacy solver, restored byte for byte
to1319, from the certified solver. Certified95, legacy86 and composition7 scopes
close on both references with inherited warnings retained. A separate control
outlines only the new composition helper. Fresh numerical and raw six-replica
target9 diagnostics are preserved. Both controls remain slower than published
Ada and are not adopted. Neither combines the earlier common-copy or vector-width
controls, and separate experiment ratios do not measure causal cost fractions.

New state proof experiments add only static ghost facts to1675. The state-view
lemma closes5 checks on both references, with12 inherited warnings retained.
It relates State_Values to State_Image under explicit layout preconditions.
The1739 normal Solve scope closes153 checks but still has the same three open
properties: configuration preservation, Stable_Ready and state-value equality.
The additional image lemma does not establish whole-caller closure. Short Z3
diagnostics and a further opacity control retain their open checks as failures.
The preparation assertion/cancelled1738 run is retained with its actual source
and cancellation reason; it is not counted as verification of a corrected source.

Exact inverse-edit audits establish the static-only source scope of1741; they
are not substitutes for proving its caller obligations. No assumption, warning
suppression, forced inlining, domain restriction or new trusted body is added.
Production numerical code is unchanged. Full state/dynamics Gold, functional
factorization, coordinated latest-version migration, the full port and parity
with native C remain open. This checkpoint is local; no commit or push is made.
Exact archive bytes are reconstructable with tools/evidence_store.py.
''')
dump(D/'verification.json',{'passed':True,'members_verified':len(members),
     'zip_sha256':sha(Z),'frozen_sources_unchanged':True,'selected_outputs_terminal':True,
     'actual_caller_complete':False,'formal_qualification_passed':False,'production_adopted':False})
inventory=read(E/'inventory.json');old=dict(inventory['files'])
for p in D.iterdir():
    if p.is_file():inventory['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inventory['files'][k]==h for k,h in old.items())
inventory['count']=len(inventory['files']);dump(E/'inventory.json',inventory)
print(json.dumps({'roots':len(roots),'members':len(members),'zip_bytes':Z.stat().st_size,
                  'inventory_files':inventory['count']}),flush=True)
