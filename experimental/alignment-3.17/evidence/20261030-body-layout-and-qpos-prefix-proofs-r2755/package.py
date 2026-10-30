from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence';D=E/'20261030-body-layout-and-qpos-prefix-proofs-r2755'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
for n in [2720,2727,2729,2731,2732,2735,2736,2738,2742,2743,2744,2745]:
    p=next(V.glob(f'sparkling-*-r{n}-20261030/results.json'));x=read(p);assert x['obligations_closed'] and x['proof_checks']>0 and not x['open'],n
for n in [2746,2747,2748,2751]:
    p=next(V.glob(f'sparkling-*-r{n}-20261030/results.json'));assert read(p)['passed'],n
assert read(V/'sparkling-copy-body-and-qpos-runtime-audit-r2748-20261030/native-comparison.json')['passed']
for n in [2752,2753]:
    assert read(next(V.glob(f'sparkling-*-r{n}-20261030/results.json')))['flow_checks_closed'],n
full={tag:read(V/f'sparkling-copy-full-prefix{tag}-r{n}-20261030/results.json') for tag,n in [('317',2749),('314',2750)]}
adopt=read(V/'sparkling-copy-body-adoption-r2754-20261030/adoption.json')
assert sha(R/adopt['source_file'])==adopt['production_source_sha256']
roots=[V/'sparkling-body-frame-control-r2650-20261030']
for p in sorted(V.iterdir()):
    m=re.search(r'-r(\d+)-20261030$',p.name)
    if p.is_dir() and p.name.startswith('sparkling-') and m and 2715<=int(m[1])<=2754:roots.append(p)
outcomes={};sources=[];analysis_roots=set()
for root in roots:
    p=root/'results.json'
    if p.is_file():
        x=read(p)
        if x.get('analysis_root'):analysis_roots.add(Path(x['analysis_root']))
        outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:x.get(k) for k in ['subprogram','exit','checks','proof_checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven','flow_checks_closed']}}
    for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
        tree=manifest.parent/'source'
        if manifest.is_file() and tree.is_dir():
            h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'body-layout-and-qpos-prefix-proofs.zip';members={}
with zipfile.ZipFile(Z,'w',zipfile.ZIP_DEFLATED,compresslevel=6) as z:
    def put(p,n):
        assert n not in members,n;data=p.read_bytes();members[n]=hashlib.sha256(data).hexdigest();z.writestr(n,data)
    for root in roots:
        analysis=root in analysis_roots or 'analysis' in root.name
        for folder,dirs,files in os.walk(root):
            dirs[:]=sorted(n for n in dirs if n not in ({'__pycache__','.git'} if analysis else {'obj','analysis','__pycache__','.git'}))
            for name in sorted(files):
                if analysis and not (name.endswith(('.spark','.gnat-json','.smt2')) or name in {'why3session.xml','gnatprove.out','data_representation_generation.log'}):continue
                p=Path(folder)/name;put(p,root.name+'/'+p.relative_to(root).as_posix())
    put(R/adopt['source_file'],'production/'+adopt['source_file'])
with zipfile.ZipFile(Z) as z:assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
closed=all(x.get('obligations_closed') for x in full.values())
dump(D/'summary.json',dict(outcomes=outcomes,adoption=adopt,source_snapshots=len(sources),whole_copy_under_current_contracts_closed=closed,whole_initialize_closed=False,whole_reset_closed=False,new_performance_measured=False))
status='adopted locally' if adopt['production_adopted'] else 'retained as a private candidate'
(D/'README.md').write_text('''# Body metadata layout and Qpos prefix proofs

The candidate adds only an internal Static body-count/array-shape precondition,
a proved Ghost projection of body DOF source-array allocation/bounds and a
Static Qpos validation-prefix invariant. Removing those additions exactly
recovers the previously adopted source. No runtime check, traversal, record
copy, public input restriction, assumption or trusted body is added.

The original single body assignment leaves three pointer/index obligations
open. Shape facts close both index checks; a separate layout projection closes
the remaining source-pointer gap. Its complete minimum closes8 checks on each
reference. The body-update region then closes28 reported checks per reference.
The reference/spring-reference region initially leaves two range checks open.
The new Qpos prefix invariant closes11 checks and the assignments15 on both
references, including initialization/preservation and both value bounds.

Selected Initialize/Create_Dynamics calls meet the stronger shape contract on
both references. The final prefix addition changes only the callee body; exact
caller text, callee pre/postconditions and all other files are checked identical
to those already proved call scopes. This audit reuses unchanged modular call
interfaces; it is not a fresh proof run or a whole constructor proof.

Both fresh validation/release matrices pass528 cases per reference/profile,
with unchanged16 samples,100 steps and2e-10 tolerances. All132 output files equal
previous production byte-for-byte; both Ghost projections are absent from
native symbols. Whole MJ.Data flow closes with the same five modeled
deallocators. Existing reviewed warnings remain. No timing claim follows.

Earlier600-second region/whole-procedure watchdogs and the null-procedure
syntax error are preserved as failed attempts. Copied Why3 sessions can predate the failed attempt; their freshness audit
distinguishes historical cache from current-run evidence. No current-run
progress or complete proof is inferred from stale cached sessions. Final whole-procedure outcomes are recorded
in summary.json; selected scopes must not be mistaken for the entire routine.
Even a complete current-contract proof does not establish exact copying of
every physical field or complete simulation correctness. Full constructor,
Reset/state/dynamics, feature/ABI alignment and integrated C parity remain open.

This checkpoint also retains the exact duplicate-cleanup plan and receipt:
four ignored reconstructable ZIPs and thirteen obsolete untracked indices,
totaling1,040,097,328 bytes. The current manifest/recipes/payloads, tracked
indices, sources, unique evidence and active caches were preserved. The prior
full verification covered73 archives/494 inventory files. No VHDX compaction,
shutdown or physical-image shrink is claimed.

Candidate status: '''+status+'''. No commit or push is implied.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,production_adopted=adopt['production_adopted'],whole_copy_under_current_contracts_closed=closed))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
    if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'],whole_copy_under_current_contracts_closed=closed)),flush=True)
