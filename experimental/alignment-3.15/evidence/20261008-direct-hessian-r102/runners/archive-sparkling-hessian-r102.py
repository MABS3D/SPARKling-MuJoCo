from pathlib import Path
import json, hashlib, shutil, gzip, zipfile, re
root = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base = Path('/var/tmp')
ev = root/'experimental/alignment-3.15/evidence'
dest = ev/'20261008-direct-hessian-r102'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p,q):
 q.parent.mkdir(parents=True,exist_ok=True); assert not q.exists(),q; shutil.copyfile(p,q)
def write(p,d):
 p.parent.mkdir(parents=True,exist_ok=True); assert not p.exists(),p; p.write_text(json.dumps(d,indent=2)+'\n')
def compress(p,q):
 q.parent.mkdir(parents=True,exist_ok=True); assert not q.exists(); q.write_bytes(gzip.compress(p.read_bytes(),mtime=0)); assert gzip.decompress(q.read_bytes())==p.read_bytes()

inv=json.loads((ev/'inventory.json').read_text()); old=dict(inv['files'])
for n,h in old.items(): assert sha(ev/n)==h,n
assert not dest.exists()
engines={}
for stage in range(97,103):
 p=base/f'sparkling-alignment-315-hessian-engine-r{stage}-20261008'
 m=json.loads((p/'manifest.json').read_text()); assert all(sha(p/'source'/n)==h for n,h in m['sources'].items())
 mh=sha(p/'manifest.json'); engines[mh]=stage
 copy(p/'manifest.json',dest/f'inputs/r{stage}/manifest.json')
 for name in ('mj-constraint_solvers.adb','mj-constraint_solvers-packed_cholesky.ads','mj-constraint_solvers-packed_cholesky.adb','mj-constraint_solvers-cone_kernels.ads','mj-constraint_solvers-cone_kernels.adb'):
  copy(p/'source/experimental/constraint-solvers-candidate/src'/name,dest/f'inputs/r{stage}'/name)
 if stage==102:
  sources=m['sources']; final=m
  with zipfile.ZipFile(dest/'inputs/r102/core-sources.zip','w',compression=zipfile.ZIP_DEFLATED,compresslevel=9) as z:
   for n in sources: z.write(p/'source'/n,n)
  with zipfile.ZipFile(dest/'inputs/r102/core-sources.zip') as z:
   assert set(z.namelist())==set(sources)
   assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in sources.items())

runner=(root/'experimental/alignment-3.15/tests/prove_flex.py').read_text()
versions={}
for stage in range(97,103):
 lines=runner.splitlines(keepends=True)
 if stage<102: lines=[s for s in lines if '"Packed_Mass_Values_Progress":' not in s]
 if stage<100: lines=[s for s in lines if '"Packed_Mass_Value_Sum":' not in s and '"Packed_Flat_Following_Rows":' not in s]
 text=''.join(lines); data=text.encode(); versions[stage]=hashlib.sha256(data).hexdigest()
 path=dest/f'runners/prove_flex-r{stage}.py'; path.parent.mkdir(parents=True,exist_ok=True);path.write_bytes(data)
attempts=[]
for p in sorted(base.glob('sparkling-alignment-315-hessian-*-scope-r*-20261008')):
 if not (p/'results.json').exists(): continue
 d=json.loads((p/'results.json').read_text()); stage=engines[d['manifest_sha256']]
 assert sha(p/'proof.log')==d['log_sha256']
 assert d['runner_sha256']==versions[stage],(stage,p.name)
 for n in ('results.json','proof.log','unit.spark.json'):
  if (p/n).exists():copy(p/n,dest/'attempts'/p.name/n)
 attempts.append(dict(stage=stage,scope=d['subprogram'],receipt=str((dest/'attempts'/p.name/'results.json').relative_to(dest)),checks=d.get('checks'),passed=d.get('passed',False),compiler_or_report_rejected=d.get('report_rejected'),open=[dict(file=e['file'],line=e['line'],message=e['message']['text']) for e in d.get('open',[])]))
write(dest/'attempts.json',attempts)
selected=[r for r in attempts if r['stage']==102 and r['passed']]
assert len(selected)==11 and sum(r['checks'] for r in selected)==414
write(dest/'minimum-closure.json',dict(engine_manifest_sha256=sha(base/'sparkling-alignment-315-hessian-engine-r102-20261008/manifest.json'),scopes=selected,checks=414,mass_gold_checks=394,element_gold_checks=13,gram_scaled_checks=7,dependencies={'Load_Mass_Values':['Load_Mass_Row','Mass_Values_Progress','Flat_Prior_Rows'],'Add_Mass_Values':['Add_Mass_Values_Row','Mass_Values_Progress','Flat_Prior_Rows','Flat_Following_Rows'],'Add_Mass_Values_Row':['Mass_Value_Sum'],'Flat_Prior_Rows':['Flat_Rows_Ordered'],'Flat_Following_Rows':['Flat_Rows_Ordered'],'Gram_Element_Flat':['Gram_Scaled']},scope='Exact mass loads/addition and ordered single Gram update with frame and numeric-limit result. Does not close global Gram/factor/solver proofs. Gram_Scaled is freshly closed on the same inputs.'))
for n in ('build_flex','build_hessian','prove_flex'):copy(root/f'experimental/alignment-3.15/tests/{n}.py',dest/(n+'.py'))
for name in ('flat_gram_probe.adb','mass_values_probe.adb','factor_values_probe.adb','test_gram.py','test_mass_addition.py','test_sparse_cholesky.py'):
 copy(root/'experimental/constraint-solvers-candidate/tests'/name,dest/'tests'/name)
copy(root/'experimental/constraint-solvers-candidate/solvers.gpr',dest/'solvers.gpr')
copy(root/'tools/guarded.py',dest/'guarded.py')
copy(root/'experimental/alignment-3.15/overlays/remove-internal-flex.patch',dest/'remove-internal-flex.patch')
for p in [Path(__file__),base/'sparkling-hessian-minima-r100.py',base/'sparkling-hessian-minima-r101.py',base/'sparkling-hessian-minima-r102.py',base/'sparkling-hessian-pending-r102.py',base/'sparkling-hessian-verify-r102.py',base/'sparkling-hessian-tail-r102.py']:
 copy(p,dest/'runners'/p.name)
for folder,label in [('sparkling-alignment-315-hessian-native-r99-20261008','native-r99'),('sparkling-alignment-315-hessian-native-r102-20261008','native'),('sparkling-alignment-315-hessian-release-r102-20261008','release'),('sparkling-alignment-314-hessian-regression-r102-20261008','production')]:
 p=base/folder;d=json.loads((p/'results.json').read_text()); assert d['complete'];m=json.loads((p/'manifest.json').read_text()); assert all(sha(p/'source'/n)==h for n,h in m['sources'].items())
 if label in ('native','release'): assert all(m['sources'].get(n)==h for n,h in sources.items())
 for f in p.iterdir():
  if f.is_file():copy(f,dest/label/f.name)
 dirs=('flat_gram_probe','mass_values_probe','factor_values_probe') if label.startswith('native') else ('state','forces','constrained')
 for name in dirs:
  q=p/name;rd=json.loads((q/'results.json').read_text()); assert rd['cases']==rd['passed'] and not rd.get('failures')
  for f in q.rglob('*'):
   if not f.is_file() or f.suffix=='.so':continue
   out=dest/label/name/f.relative_to(q)
   if f.suffix in ('.txt','.output'):compress(f,out.with_name(out.name+'.gz'))
   else:copy(f,out)
 binaries={str(f.relative_to(p)):dict(sha256=sha(f),bytes=f.stat().st_size) for f in p.rglob('bin/*') if f.is_file()}
 write(dest/label/'binaries.json',binaries)
 if label=='native':
  for n in m['sources']:
   if n not in sources:copy(p/'source'/n,dest/'native-extra-inputs'/n)

p=base/'sparkling-alignment-315-hessian-time-r102-quiet-20261008';d=json.loads((p/'results.json').read_text());assert d['complete'] and all(r['passed'] for r in d['results'])
for f in p.rglob('*'):
 if f.is_file() and f.suffix!='.so':copy(f,dest/'paired-time'/f.relative_to(p))
for n in ('engine_util_sparse.c','engine_util_sparse.h','engine_util_solve.c','engine_solver.c'):
 copy(base/'sparkling-alignment-315-foundation-r6-20261007/source/mujoco/src/engine'/n,dest/'reference'/n)
write(dest/'results.json',dict(reference='3.15.0',source_count=len(sources),mass_gold_closed=True,mass_gold_checks=394,element_gold_checks=13,minimum_checks=414,minimum_scopes=11,gram_passed=700,gram_actual_c_bitwise=434,mass_passed=180,factor_passed=407,release_passed=390,production_passed=366,numerical_comparisons=2043,actual_c_comparisons=1777,whole_gram_gold_closed=False,whole_factor_gold_closed=False,whole_solver_gold_closed=False,whole_dynamics_gold_closed=False,production_315_migrated=False,goal_complete=False,pending=[r for r in attempts if r['stage']==102 and not r['passed']],scope='Direct flat numeric Hessian across scalar and folded elliptic paths; dense H allocation removed on sparse path. Fixed-support mass semantics, coalesced Jacobian support and legacy dense rank-update bridge remain explicit limitations.'))
for n,h in old.items():assert sha(ev/n)==h,n
for p in dest.rglob('*'):
 if p.is_file():inv['files'][str(p.relative_to(ev))]=sha(p)
inv['count']=inv['current_entries']=len(inv['files']);inv['direct_hessian_prior_entries_preserved']=len(old)
(ev/'inventory.json').write_text(json.dumps(inv,indent=2)+'\n')
for n,h in inv['files'].items():assert sha(ev/n)==h,n
print(json.dumps(dict(entries=len(inv['files']),prior_preserved=len(old),checks=414,scopes=11)))
