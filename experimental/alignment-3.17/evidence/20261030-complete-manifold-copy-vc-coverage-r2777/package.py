from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-complete-manifold-copy-vc-coverage-r2777'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-copy-coverage-adoption-r2776-20261030/adoption.json');audit=read(V/'sparkling-copy-completeness-audit-r2775-20261030/results.json')
assert adopt['production_adopted'] and audit['passed'] and sha(R/adopt['source_file'])==adopt['source_sha256']
for x in audit['references'].values():assert x['proof_vcs']==95 and x['every_vc_proved_exactly_once'] and x['low_resource_inventory_successes_not_used_as_proof'] and len(x['regions'])==7
roots=[V/'sparkling-copy-qpos-prefix-r2741-20261030']
for p in sorted(V.iterdir()):
    m=re.search(r'-r(\d+)-20261030$',p.name)
    if p.is_dir() and p.name.startswith('sparkling-') and m and 2756<=int(m[1])<=2776:roots.append(p)
analysis_roots=set();outcomes={};sources=[]
for root in roots:
    p=root/'results.json'
    if p.is_file():
        x=read(p)
        if x.get('analysis_root'):analysis_roots.add(Path(x['analysis_root']))
        outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:x.get(k) for k in ['subprogram','exit','checks','proof_checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven']}}
    for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
        if manifest.is_file():
            tree=manifest.parent/'source';h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items());sources.append((tree,h))
# Keep the selected generation/solver inputs even when a reused cache predates
# this bundle's attempt range. Completed scoped .spark reports stay with runs.
for p in sorted(analysis_roots):
    if p not in roots:roots.append(p)
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'complete-manifold-copy-vc-coverage.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    def put(p,n):
        assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
    for root in roots:
        analysis=root in analysis_roots
        label=root.relative_to(V).as_posix()
        for folder,dirs,files in os.walk(root):
            dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if analysis else {'obj','analysis','__pycache__','.git'}))
            for name in sorted(files):
                if analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
                p=Path(folder)/name;put(p,label+'/'+p.relative_to(root).as_posix())
    put(R/adopt['source_file'],'adopted-production/'+adopt['source_file'])
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(adoption=adopt,completeness_audit=audit,outcomes=outcomes,source_snapshots=len(sources),exact_physical_field_copy_complete=False,whole_initialize_reset_state_dynamics_closed=False,full_port_or_performance_parity=False))
(D/'README.md').write_text('''# Complete current-contract manifold-copy VC coverage

Copy_Manifold_Joints is adopted with its internal Static body-shape relation,
proved Ghost body-layout projection and Static Qpos validation-prefix invariant.
The exact adopted source is candidate2741, SHA-256
`2b247768281c5b9884a4845124872b2f3b2319101fe136b10f856cfe5f33a977`.

| Disjoint region | Proof VCs per reference |
| --- | ---: |
| Contract and contract-expression safety | 11 |
| Projection calls and allocation | 4 |
| Qpos validation and prefix invariant | 10 |
| Joint reads, group bounds and outer invariant | 13 |
| Quaternion reads | 8 |
| Component updates and inner invariant | 28 |
| Body updates, body-loop invariant and final access | 21 |
| Total | 95 |

A fresh whole-routine inventory contains95 unique
(check_file,check_line,check_col,rule) tuples on each pinned3.17/3.14 closure.
Seven successful complete region runs per reference partition that inventory
exactly: no missing, duplicate or foreign VC. msg_id is filter-local and is not
used as identity. The independent audit checks exact source-manifest hashes,
identical semantic GNATprove options, selected entity, complete representation,
fresh reports, all proof entries informational and no skipped/assumed VCs.
The low-step inventory's successful entries are not needed as proof: all95
are covered by the seven ordinary-resource runs, including every invariant's
initialization/preservation, postcondition and allocation/leak check.

This is complete VC coverage for the routine's current contracts under callee
contracts. The monolithic600-second attempts still time out; this checkpoint
does not turn those runs green or infer progress from stale Why3 cache XML.
Existing reviewed warnings remain and make individual wrapper passed flags
false despite all scoped obligations closing. It does not prove exact copying
of every physical field, complete constructors/Reset/state/dynamics, full
features/ABI alignment or integrated C performance parity.

The production3.14 source closure matches after the already existing build
normalization: two ABI-independent structural helper files are supplied from
experimental/alignment-3.17/src, and the GPR adds the SPARK library directories.
The normalization is checked explicitly rather than silently treating those
three paths as identical. The3.17 closure remains a private reference; no
production ABI/version pin is changed.

The preceding checkpoint retains fresh validation/release native matrices:
528 cases per reference/profile,132 byte-identical outputs versus previous
production, unchanged16 samples/100 steps/2e-10 tolerances, both Ghost helpers
absent from native symbols, exact Static/Ghost erasure and clean whole MJ.Data
flow with the same five modeled deallocators. Those unchanged-source results
are reused; no redundant numerical run or new timing claim is made here.
See ../20261030-body-layout-and-qpos-prefix-proofs-r2755/README.md.

The strengthened internal precondition is established by both constructors on
both references. The prior modular interface audit verifies unchanged caller
text and pre/postconditions after the prefix-only body change. No runtime scan,
record copy, public input restriction, assumption or trusted body is added.
The next functional gap is preservation/mapping of the individual body fields;
the current postcondition covers layout and selected frame properties.

Adopted locally. No commit or push is implied by this checkpoint.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_adopted=True,proof_vcs_per_reference=95,successful_disjoint_regions_per_reference=7,monolithic_run_passed=False))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
    if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
