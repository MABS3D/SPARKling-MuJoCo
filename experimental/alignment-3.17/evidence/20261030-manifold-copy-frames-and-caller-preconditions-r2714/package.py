from pathlib import Path
import hashlib,json,os,re,shutil,zipfile
R=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');V=Path('/var/tmp');E=R/'experimental/alignment-3.17/evidence'
D=E/'20261030-manifold-copy-frames-and-caller-preconditions-r2714'
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
read=lambda p:json.loads(p.read_text())
def dump(p,x):p.write_text(json.dumps(x,indent=2)+'\n')
adopt=read(V/'sparkling-body-frame-adoption-r2713-20261030/adoption.json')
assert adopt['production_adopted'] and sha(R/adopt['source_file'])==adopt['source_sha256']
required=[2677,2679,2681,2683,2684,2685,2686,2688,2689,2690,2691,2692,2693,2694,2695,2696,2697,2698,2705,2707,2708,2709,2711,2712]
for n in required:
    ps=list(V.glob(f'sparkling-*-r{n}-20261030/results.json'));assert len(ps)==1,n
    x=read(ps[0]);assert x['obligations_closed'] and x['proof_checks']>0 and not x['open'],n
for n in [2699,2700,2701]:
    ps=list(V.glob(f'sparkling-*-r{n}-20261030/results.json'));assert len(ps)==1 and read(ps[0])['passed'],n
assert read(V/'sparkling-body-frame-runtime-audit-r2699-20261030/native-comparison.json')['passed']
assert read(V/'sparkling-body-frame-runtime-audit-r2699-20261030/flow-coverage-audit.json')['passed']
roots=[]
for p in sorted(V.iterdir()):
    m=re.search(r'-r(\d+)-20261030$',p.name)
    if p.is_dir() and p.name.startswith('sparkling-') and m and 2650<=int(m[1])<=2713:roots.append(p)
outcomes={};sources=[];analysis_roots=set()
for root in roots:
    p=root/'results.json'
    if p.is_file():
        d=read(p)
        if d.get('analysis_root'):analysis_roots.add(Path(d['analysis_root']))
        outcomes[root.name]={'path':str(p),'sha256':sha(p),**{k:d.get(k) for k in ['subprogram','exit','checks','proof_checks','obligations_closed','fresh_scoped_report','seconds','warnings','open','passed','scope','whole_subprogram_proven','flow_checks_closed']}}
    for manifest in [root/'sources.json',*root.glob('*/sources.json')]:
        tree=manifest.parent/'source'
        if manifest.is_file() and tree.is_dir():
            h=read(manifest);assert all(sha(tree/n)==v for n,v in h.items()),str(manifest);sources.append((tree,h))
D.mkdir();shutil.copy2(__file__,D/'package.py');Z=D/'manifold-copy-frames-and-caller-preconditions.zip';members={}
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
    put(R/adopt['source_file'],'adopted-production/'+adopt['source_file'])
with zipfile.ZipFile(Z) as z:
    assert z.testzip() is None and all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in members.items())
for tree,h in sources:assert all(sha(tree/n)==v for n,v in h.items())
dump(D/'archive-manifest.json',dict(files=members,roots=[str(p) for p in roots],zip_sha256=sha(Z),zip_bytes=Z.stat().st_size))
dump(D/'summary.json',dict(outcomes=outcomes,adoption=adopt,source_snapshots=len(sources),source_hashes_checked=sum(len(h) for _,h in sources),whole_copy_manifold_joints_closed=False,whole_initialize_closed=False,whole_reset_closed=False,mocap_type_invariant_adopted=False,new_performance_measured=False))
(D/'README.md').write_text('''# Manifold-copy frames and caller preconditions

The adopted source adds only Static contracts, loop invariants and Ghost
projections. Copy_Manifold_Joints preserves body allocation/bounds, dimensions,
selected option scalars and topology/ancestor-cache emptiness. Its activation
caller preserves body allocation across the actuator loop. Damping/armature
ranges are projected from the DOF validator already run by both public factories;
no new public input restriction or executable scan is added.

| Final scope | Reported checks per reference | Property |
| --- | ---: | --- |
| Prove_Dof_Values | 20 | All validated damping/armature values in range |
| Model_Status | 15 | Original postcondition plus existing DOF validation fact |
| Copy_Manifold_Joints combined postcondition | 11 | Original successful layout and new frame |
| Three copy-loop invariants | 12 each | Frame initialization and preservation |
| Activation-loop body allocation invariant | 9 | Initialization and preservation |
| Per-DOF assignment region | 21 | Damping/armature reads and owned write |
| Initialize topology call | 8 | Required manifold builder precondition |

Each selected postcondition, invariant or call scope is narrower than a complete
procedure proof. Counts include flow/unrolling information; actual proof_checks
and all reviewed warnings are retained. Whole constructors, Reset, full state
and dynamics Gold, private invariant adoption, full feature/ABI alignment and
integrated C performance parity remain unfinished. The body-metadata diagnostic
retains its actual outcome rather than claiming complete copy safety.

The strengthened internal preconditions have selected caller proofs at Create
to Initialize and at both Initialize/Create_Dynamics to Copy_Manifold_Joints.
No runtime validator is removed or added in this checkpoint. Exact removal of
the new Static/Ghost code recovers the previous source byte-for-byte. A native
GNAT validation-profile policy probe confirms that new contracts, Ghost calls,
Ghost snapshots and Static invariants are not executed; normal checks execute.

Fresh native validation/release builds each pass528 numerical cases against
both pinned3.17 and3.14 references, with16 samples,100 steps and unchanged2e-10
tolerances. All132 output files equal previous production2622 byte-for-byte.
The new Ghost projection is absent from native symbols. This is neither timing
nor a universal equivalence proof; no performance improvement is claimed.

Both whole MJ.Data flow reports contain333 informational checks and no open
messages, retaining the same five modeled deallocators. The initial audit
classifier incorrectly required proof-mode termination and every entity body
in SPARK; its false result is retained, with a separate audit accepting the
actual FLOW_MODE terminator and exactly the unchanged reviewed deallocators.
This is flow-only evidence, with zero runtime/functional proof VCs.

The earlier filters selecting a body-local Static postcondition generated zero
proof checks (r2652/r2656) and are explicitly mis-scoped, despite their old
wrapper flag. The corrected filter selects the combined postcondition at its
original aspect location and requires proof_checks>0. The plural-line attempt
and all earlier watchdog/failure reports remain archived. No proof follows
from timeout, added annotations alone or compiler success.

These changes are adopted locally. No commit or push is implied by this
checkpoint, and full-port completion/performance parity remain open.
''')
dump(D/'verification.json',dict(passed=True,members_verified=len(members),zip_sha256=sha(Z),frozen_sources_unchanged=True,selected_outputs_terminal=True,actual_static_frame_refactor_adopted=True,private_invariant_not_adopted=True))
inv=read(E/'inventory.json');old=dict(inv['files'])
for p in D.iterdir():
    if p.is_file():inv['files'][p.relative_to(E).as_posix()]=sha(p)
assert all(inv['files'][k]==h for k,h in old.items());inv['count']=len(inv['files']);dump(E/'inventory.json',inv)
print(json.dumps(dict(roots=len(roots),members=len(members),zip_bytes=Z.stat().st_size,inventory_files=inv['count'])),flush=True)
