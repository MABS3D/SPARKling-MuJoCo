from pathlib import Path
import json,hashlib,shutil,gzip,zipfile,re
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');base=Path('/var/tmp');ev=root/'experimental/alignment-3.15/evidence';dest=ev/'20261008-mass-addition-r90'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p,q):
 q.parent.mkdir(parents=True,exist_ok=True);assert not q.exists(),q;shutil.copyfile(p,q)
def write(p,d):
 p.parent.mkdir(parents=True,exist_ok=True);assert not p.exists();p.write_text(json.dumps(d,indent=2)+'\n')
def compress(p,q):
 q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(gzip.compress(p.read_bytes(),mtime=0));assert gzip.decompress(q.read_bytes())==p.read_bytes()
inv=json.loads((ev/'inventory.json').read_text());old=dict(inv['files'])
for n,h in old.items():assert sha(ev/n)==h,n
assert not dest.exists()
engines={}
for stage in range(84,92):
 p=base/f'sparkling-alignment-315-mass-engine-r{stage}-20261008';m=json.loads((p/'manifest.json').read_text());assert all(sha(p/'source'/n)==h for n,h in m['sources'].items())
 engines[sha(p/'manifest.json')]=p;copy(p/'manifest.json',dest/'source'/p.name/'manifest.json')
 for suffix in ('.ads','.adb'):copy(p/'source'/('experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky'+suffix),dest/'source'/p.name/('mj-constraint_solvers-packed_cholesky'+suffix))
p=base/'sparkling-alignment-315-mass-engine-r90-20261008';m=json.loads((p/'manifest.json').read_text());sources=m['sources']
assert all(sha(root/n)==h for n,h in m['original_sources'].items())
with zipfile.ZipFile(dest/'source/final-engine.zip','w',zipfile.ZIP_DEFLATED) as z:
 for n in sorted(sources):z.write(p/'source'/n,n)
with zipfile.ZipFile(dest/'source/final-engine.zip') as z:assert all(hashlib.sha256(z.read(n)).hexdigest()==h for n,h in sources.items())
runner_paths=[root/'experimental/alignment-3.15/tests/prove_flex.py',base/'sparkling-mass-runner-r84.py',base/'sparkling-mass-runner-r86.py',base/'sparkling-mass-runner-r89.py'];runners={sha(p):p for p in runner_paths}
attempts=[]
for p in sorted(base.glob('sparkling-alignment-315-mass-*-scope-r*-20261008/results.json')):
 d=json.loads(p.read_text());assert d['manifest_sha256'] in engines;assert d['runner_source_unchanged'] and d['guard_source_unchanged'] and d['source_hashes_unchanged'];assert d['runner_sha256'] in runners
 t=dest/'attempts'/p.parent.name
 for n in ('results.json','proof.log','unit.spark.json'):
  if (p.parent/n).exists():copy(p.parent/n,t/n)
 copy(runners[d['runner_sha256']],t/'prove_flex.py')
 attempts.append(dict(scope=d['subprogram'],attempt=p.parent.name,stage=int(re.search(r'-r(\d+)-',p.parent.name)[1]),checks=d.get('checks'),closed=d.get('obligations_closed',False),passed=d['passed'],open=len(d.get('open',[])),warnings=d.get('warnings',[])))
write(dest/'attempts.json',attempts)
def fragment(source,name):
 text=source.read_text();match=re.search(r'^   (?:procedure|function) '+re.escape(name)+r'\b',text,re.M)
 assert match,name
 next_match=re.search(r'^   (?:procedure|function) \w+\b|^end MJ\.',text[match.end():],re.M)
 return text[match.start():match.end()+next_match.start()] if next_match else text[match.start():]
final_body=base/'sparkling-alignment-315-mass-engine-r90-20261008/source/experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky.adb'
latest={}
for item in attempts:
 if not(item['closed'] and item['passed']):continue
 receipt=json.loads((base/item['attempt']/'results.json').read_text());source=engines[receipt['manifest_sha256']]/'source/experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky.adb'
 name=item['scope'].removeprefix('Packed_')
 if fragment(source,name)!=fragment(final_body,name):continue
 prior=latest.get(name)
 if prior is None or item['stage']>prior['stage']:latest[name]=item
selected=list(latest.values())
write(dest/'proof-continuity.json',dict(method='Exact individual declarations/bodies, including contracts, matched to the final body. Supporting predicate contracts and bodies unchanged. The unsuccessful proof-only inlining experiment was reverted; final declarations match the last closed minimum receipts.',scopes=selected,whole_solver_gold=False))
write(dest/'final-minima.json',dict(scopes=selected,checks=sum(r['checks'] for r in selected),claim='Individual exact floating-point/frame properties under explicit preconditions; no whole solver/dynamics Gold inferred.'))
for n in ('build_flex','build_mass','build_packed','prove_flex'):copy(root/f'experimental/alignment-3.15/tests/{n}.py',dest/(n+'.py'))
copy(root/'tools/guarded.py',dest/'guarded.py');copy(Path(__file__),dest/'archive.py');copy(base/'sparkling-mass-tail-r90.py',dest/'tail-audit.py')
for n in ('mass_addition_probe.adb','test_mass_addition.py'):copy(root/'experimental/constraint-solvers-candidate/tests'/n,dest/n)
copy(root/'experimental/constraint-solvers-candidate/solvers.gpr',dest/'solvers.gpr')
for folder, label in [('sparkling-alignment-315-mass-native-r90-20261008','mass-native'),('sparkling-alignment-315-mass-factor-r90-20261008','factor-native'),('sparkling-alignment-315-mass-release-r90-20261008','release'),('sparkling-alignment-314-mass-regression-r90-20261008','production')]:
 p=base/folder;assert json.loads((p/'results.json').read_text())['complete'];ms=json.loads((p/'manifest.json').read_text())['sources'];assert all(sha(p/'source'/n)==h for n,h in ms.items())
 if label!='production':assert all(ms.get(n)==h for n,h in sources.items())
 for f in p.iterdir():
  if f.is_file():copy(f,dest/label/f.name)
 for directory in ('cases','state','forces','constrained'):
  q=p/directory
  if not q.exists():continue
  d=json.loads((q/'results.json').read_text());assert d['cases']==d['passed'] and not d['failures']
  for f in q.rglob('*'):
   if not f.is_file() or f.suffix=='.so':continue
   target=dest/label/directory/f.relative_to(q)
   if f.suffix in ('.txt','.output'):compress(f,target.with_name(target.name+'.gz'))
   else:copy(f,target)
p=base/'sparkling-alignment-315-mass-native-r84-20261008'
for n in ('manifest.json','commands.json','results.json'):copy(p/n,dest/'mass-native-r84'/n)
copy(p/'cases/results.json',dest/'mass-native-r84/cases/results.json')
p=base/'sparkling-alignment-315-mass-time-r90-quiet-20261008';d=json.loads((p/'results.json').read_text());assert d['complete'] and all(r['passed'] for r in d['results'])
for f in p.rglob('*'):
 if f.is_file() and f.suffix!='.so':copy(f,dest/'paired-time'/f.relative_to(p))
reference=base/'sparkling-alignment-315-foundation-r6-20261007/source/mujoco'
for n in ('engine_util_sparse.c','engine_util_solve.c'):copy(reference/'src/engine'/n,dest/'reference'/n)
write(dest/'results.json',dict(reference='3.15.0',source_count=len(sources),whole_mass_gold_closed=False,mass_passed=180,factor_passed=407,release_passed=390,production_passed=366,goal_complete=False,whole_solver_gold_closed=False,whole_dynamics_gold_closed=False,final_minimum_checks=sum(r['checks'] for r in selected),final_minimum_scopes=len(selected),pending=[r for r in attempts if r['stage']==90 and not r['closed']],scope='Exact flat mass addition with fixed factor support, precondition propagation, C differential regression and paired movement timing.'))
for n,h in old.items():assert sha(ev/n)==h,n
for p in dest.rglob('*'):
 if p.is_file():inv['files'][str(p.relative_to(ev))]=sha(p)
inv['count']=inv['current_entries']=len(inv['files']);inv['mass_prior_entries_preserved']=len(old)
(ev/'inventory.json').write_text(json.dumps(inv,indent=2)+'\n')
for n,h in inv['files'].items():assert sha(ev/n)==h,n
print(json.dumps(dict(entries=len(inv['files']),prior_preserved=len(old),checks=sum(r['checks'] for r in selected),scopes=len(selected))))
