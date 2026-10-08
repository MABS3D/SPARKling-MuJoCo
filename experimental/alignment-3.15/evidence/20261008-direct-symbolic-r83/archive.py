from pathlib import Path
import json,hashlib,shutil,gzip,re,zipfile
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base=Path('/var/tmp'); evidence=root/'experimental/alignment-3.15/evidence'
dest=evidence/'20261008-direct-symbolic-r83'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p,q):
 q.parent.mkdir(parents=True,exist_ok=True);assert not q.exists(),q;shutil.copyfile(p,q)
def write(p,d):
 p.parent.mkdir(parents=True,exist_ok=True);assert not p.exists();p.write_text(json.dumps(d,indent=2)+'\n')
def compress(p,q):
 q.parent.mkdir(parents=True,exist_ok=True);assert not q.exists();q.write_bytes(gzip.compress(p.read_bytes(),mtime=0));assert gzip.decompress(q.read_bytes())==p.read_bytes()
inventory=json.loads((evidence/'inventory.json').read_text());old=dict(inventory['files'])
for n,h in old.items():assert sha(evidence/n)==h,n
assert not dest.exists()
engine=base/'sparkling-alignment-315-direct-engine-r83-20261008'
sources=json.loads((engine/'manifest.json').read_text())['sources']
assert all(sha(engine/'source'/n)==h for n,h in sources.items())
for n,h in json.loads((engine/'manifest.json').read_text())['original_sources'].items():assert sha(root/n)==h,n
engines={}
for stage in (77,78,79,80,81,82,83):
 p=base/f'sparkling-alignment-315-direct-engine-r{stage}-20261008'; m=json.loads((p/'manifest.json').read_text())
 assert all(sha(p/'source'/n)==h for n,h in m['sources'].items())
 engines[sha(p/'manifest.json')]=p
 copy(p/'manifest.json',dest/'source'/p.name/'manifest.json')
 for n in ('experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky.ads','experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky.adb','experimental/constraint-solvers-candidate/src/mj-constraint_solvers.adb'):
  copy(p/'source'/n,dest/'source'/p.name/Path(n).name)
with zipfile.ZipFile(dest/'source/final-engine.zip','w',zipfile.ZIP_DEFLATED) as z:
 for n in sorted(sources):z.write(engine/'source'/n,n)
with zipfile.ZipFile(dest/'source/final-engine.zip') as z:
 assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in sources.items())
runners=[root/'experimental/alignment-3.15/tests/prove_flex.py',base/'sparkling-direct-runner-r80.py',base/'sparkling-direct-runner-r81.py']
runners.append(base/'sparkling-direct-runner-r77-reconstructed.py')
runner_map={sha(p):p for p in runners}
attempts=[]
for p in sorted(base.glob('sparkling-alignment-315-direct-*-scope-r*-20261008/results.json')):
 d=json.loads(p.read_text());assert d['manifest_sha256'] in engines
 assert d['runner_source_unchanged'] and d['guard_source_unchanged'] and d['source_hashes_unchanged']
 target=dest/'attempts'/p.parent.name
 for n in ('results.json','proof.log','unit.spark.json'):
  if (p.parent/n).exists():copy(p.parent/n,target/n)
 runner=runner_map.get(d['runner_sha256'])
 if runner is not None:copy(runner,target/'prove_flex.py')
 attempts.append(dict(scope=d['subprogram'],attempt=p.parent.name,checks=d.get('checks'),closed=d.get('obligations_closed',False),passed=d['passed'],open=len(d.get('open',[])),warnings=d.get('warnings',[]),runner_recovered=runner is not None,stage=int(re.search(r'-r(\d+)-',p.parent.name)[1])))
write(dest/'attempts.json',attempts)
selected=[d for d in attempts if d['stage']==83 and d['passed'] and d['closed']]
write(dest/'final-minima.json',dict(scopes=selected,checks=sum(d['checks'] for d in selected),claim='Only these individually scoped obligations are closed; no global symbolic, solver or dynamics Gold claim.'))
for name in ('build_flex','build_packed','prove_flex'):copy(root/f'experimental/alignment-3.15/tests/{name}.py',dest/(name+'.py'))
copy(root/'tools/guarded.py',dest/'guarded.py');copy(Path(__file__),dest/'archive.py')
reference=base/'sparkling-alignment-315-foundation-r6-20261007/source/mujoco'
for name in ('engine_util_solve.c','engine_util_sparse.h','engine_util_sparse_avx.h','engine_util_blas.h'):
 copy(reference/'src/engine'/name,dest/'reference'/name)

for name,label in [('sparkling-alignment-315-direct-native-r83-20261008','native'),('sparkling-alignment-315-direct-release-r83-20261008','release'),('sparkling-alignment-314-direct-regression-r83-20261008','production')]:
 p=base/name;d=json.loads((p/'results.json').read_text());assert d['complete']
 m=json.loads((p/'manifest.json').read_text())
 assert all(sha(p/'source'/n)==h for n,h in m['sources'].items())
 if label!='production':assert all(m['sources'].get(n)==h for n,h in sources.items())
 for f in p.iterdir():
  if f.is_file():copy(f,dest/label/f.name)
 for folder in ('cases','state','forces','constrained'):
  q=p/folder
  if not q.exists():continue
  d=json.loads((q/'results.json').read_text());assert d['cases']==d['passed'] and not d['failures']
  for f in q.rglob('*'):
   if not f.is_file() or f.suffix=='.so':continue
   out=dest/label/folder/f.relative_to(q)
   if f.suffix in ('.txt','.output'):compress(f,out.with_name(out.name+'.gz'))
   else:copy(f,out)
 if label=='native':
  for n in ('packed_cholesky_probe.adb','test_sparse_cholesky.py'):copy(p/'source/experimental/constraint-solvers-candidate/tests'/n,dest/label/n)
  copy(p/'source/experimental/constraint-solvers-candidate/solvers.gpr',dest/label/'solvers.gpr')
# Preserve r77 complete runtime results, with their distinct earlier source.
p=base/'sparkling-alignment-315-direct-release-r77-20261008'
for n in ('manifest.json','commands.json','results.json'):copy(p/n,dest/'runtime-r77'/n)
for folder in ('state','forces','constrained'):copy(p/folder/'results.json',dest/'runtime-r77'/folder/'results.json')
timing=base/'sparkling-alignment-315-direct-time-r83-quiet-20261008';d=json.loads((timing/'results.json').read_text());assert d['complete'] and all(r['passed'] for r in d['results'])
for f in timing.rglob('*'):
 if f.is_file() and f.suffix!='.so':copy(f,dest/'paired-time'/f.relative_to(timing))
write(dest/'results.json',dict(reference='3.15.0',source_count=len(sources),native_passed=407,release_passed=390,production_passed=366,goal_complete=False,symbolic_global_gold_closed=False,whole_factor_functional_closed=False,whole_backsolve_functional_closed=False,final_minimum_checks=sum(d['checks'] for d in selected),final_minimum_scopes=len(selected),pending=[d for d in attempts if d['stage']==83 and not d['closed']],scope='Direct C-order symbolic counting/filling, actual-NNZ allocation and flat adapters. Experimental solver, not complete MuJoCo.'))
for n,h in old.items():assert sha(evidence/n)==h,n
for p in dest.rglob('*'):
 if p.is_file():inventory['files'][str(p.relative_to(evidence))]=sha(p)
inventory['count']=inventory['current_entries']=len(inventory['files']);inventory['direct_symbolic_prior_entries_preserved']=len(old)
(evidence/'inventory.json').write_text(json.dumps(inventory,indent=2)+'\n')
for n,h in inventory['files'].items():assert sha(evidence/n)==h,n
print(json.dumps(dict(entries=len(inventory['files']),prior_preserved=len(old),final_scope_checks=sum(d['checks'] for d in selected))))
