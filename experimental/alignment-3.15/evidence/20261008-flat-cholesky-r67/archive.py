from pathlib import Path
import gzip, hashlib, json, re, shutil

root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base=Path('/var/tmp')
evidence=root/'experimental/alignment-3.15/evidence'
dest=evidence/'20261008-flat-cholesky-r67'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p,q):
 q.parent.mkdir(parents=True,exist_ok=True)
 assert not q.exists(),q
 shutil.copyfile(p,q)
def write(p,value):
 p.parent.mkdir(parents=True,exist_ok=True)
 assert not p.exists(),p
 p.write_text(json.dumps(value,indent=2)+'\n')
inv=json.loads((evidence/'inventory.json').read_text());old=dict(inv['files']);assert len(old)==3580
for n,v in old.items():assert sha(evidence/n)==v,n
assert not dest.exists()
engines={}
for stage in range(61,68):
 engine=base/f'sparkling-alignment-315-flat-engine-proof-r{stage}-20261008'
 m=json.loads((engine/'manifest.json').read_text());assert all(sha(engine/'source'/k)==v for k,v in m['sources'].items())
 engines[sha(engine/'manifest.json')]=engine
 out=dest/'proof-source'/engine.name;copy(engine/'manifest.json',out/'manifest.json')
 for n in ['mj-constraint_solvers-packed_cholesky.ads','mj-constraint_solvers-packed_cholesky.adb','mj-constraint_solvers.adb']:
  copy(engine/'source/experimental/constraint-solvers-candidate/src'/n,out/n)
runner=(root/'experimental/alignment-3.15/tests/prove_flex.py').read_text();attempts=[]
added63=['Transpose_Envelope','Copy_Flat_Columns','Transpose_Offsets_Ordered','Transpose_Prior_Rows','Copy_Flat_Transpose']
for receipt in sorted(base.glob('sparkling-alignment-315-flat-*-scope-r*-20261008/results.json')):
 stage=int(re.search(r'-r(\d+)',receipt.parent.name)[1]);data=json.loads(receipt.read_text())
 assert data['manifest_sha256'] in engines
 historical='\n'.join(line for line in runner.splitlines()
  if not (stage<63 and any('"Packed_'+n+'":' in line for n in added63))
  and not (stage<64 and '"Packed_Set_Transpose_Offset":' in line))+'\n'
 assert hashlib.sha256(historical.encode()).hexdigest()==data['runner_sha256'],receipt
 out=dest/'attempts'/receipt.parent.name
 for n in ['results.json','proof.log','unit.spark.json']:
  if (receipt.parent/n).exists():copy(receipt.parent/n,out/n)
 (out/'prove_flex.py').write_text(historical)
 attempts.append(dict(stage=stage,scope=data['subprogram'],receipt=receipt.parent.name,
  checks=data.get('checks'),closed=data.get('obligations_closed',False),passed=data['passed'],
  open=len(data.get('open',[])),warnings=data.get('warnings',[])))
write(dest/'attempts.json',attempts)
current=base/'sparkling-alignment-315-flat-engine-proof-r67-20261008';sources=json.loads((current/'manifest.json').read_text())['sources'];unit=Path('experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky')
def canon(s):return re.sub(r'\s+','',re.sub(r'--[^\n]*','',s))
def fragment(s,n):
 m=re.search(r'^   (?:procedure|function) '+n+r'\b',s,re.M)
 if not m:return None
 end=re.search(r'^   (?:procedure|function) \w+\b|^end MJ\.',s[m.end():],re.M)
 return s[m.start():m.end()+end.start()] if end else s[m.start():]
selected={'Transpose_Envelope':63,'Set_Transpose_Offset':66,'Build_Transpose_Offsets':66,'Copy_Flat_Columns':63,'Transpose_Offsets_Ordered':63,'Transpose_Prior_Rows':63,'Copy_Flat_Transpose':63,'Flat_Ordered':63,'Flat_Separate':63,'Flat_Prefix_Progress':63,'Flat_Update_Row':65};closure=[]
for name,stage in selected.items():
 engine=base/f'sparkling-alignment-315-flat-engine-proof-r{stage}-20261008';m=json.loads((engine/'manifest.json').read_text())['sources'];changed=[k for k,v in m.items() if sources.get(k)!=v]
 assert all(k in [str(unit.with_suffix('.ads')),str(unit.with_suffix('.adb')),'experimental/constraint-solvers-candidate/src/mj-constraint_solvers.adb','experimental/constraint-solvers-candidate/tests/packed_cholesky_probe.adb'] for k in changed),changed
 for suffix in ['.ads','.adb']:
  a=fragment((engine/'source'/unit.with_suffix(suffix)).read_text(),name);b=fragment((current/'source'/unit.with_suffix(suffix)).read_text(),name)
  assert (a is None and b is None) or (a and b and canon(a)==canon(b)),(name,suffix)
 for dep in ['Valid_Offsets','Slot','Bounded','Ordered_Flat','Valid_Transpose_Offsets']:
  suffix='.adb' if dep in ['Ordered_Flat','Valid_Transpose_Offsets'] else '.ads'
  assert canon(fragment((engine/'source'/unit.with_suffix(suffix)).read_text(),dep))==canon(fragment((current/'source'/unit.with_suffix(suffix)).read_text(),dep)),(name,dep)
 p=base/f'sparkling-alignment-315-flat-{name.lower().replace("_","-")}-scope-r{stage}-20261008/results.json';d=json.loads(p.read_text());assert d['passed'] and d['obligations_closed'] and not d['open'] and not d['warnings']
 closure.append(dict(scope=name,stage=stage,checks=d['checks'],receipt=p.parent.name,owned_contract_body_identical=True,shared_models_identical=True,external_dependencies_identical=True,changed_context=changed))
write(dest/'closure.json',dict(scopes=closure,checks=sum(r['checks'] for r in closure),build_flat_open=4,whole_factor_functional_closed=False,whole_backsolve_functional_closed=False,caller_gold_closed=False))
for stage in [61,62,64,65,66,67]:
 folder=base/f'sparkling-alignment-315-flat-native-r{stage}-20261008';out=dest/'native-attempts'/folder.name
 for p in folder.iterdir():
  if p.is_file():copy(p,out/p.name)
 if (folder/'cases/results.json').exists():copy(folder/'cases/results.json',out/'cases/results.json')
 if stage==67:
  assert json.loads((folder/'results.json').read_text())['complete']
  cases=json.loads((folder/'cases/results.json').read_text());assert cases['passed']==cases['cases']==395
  manifest=json.loads((folder/'manifest.json').read_text())['sources'];assert all(manifest.get(k)==v for k,v in sources.items())
  for n in ['input.txt','output.txt']:
   p=folder/'cases'/n;q=out/'cases'/(n+'.gz');q.write_bytes(gzip.compress(p.read_bytes(),mtime=0));assert gzip.decompress(q.read_bytes())==p.read_bytes()
  copy(folder/'cases/reference.c',out/'cases/reference.c')
  for n in ['packed_cholesky_probe.adb','test_sparse_cholesky.py']:copy(folder/'source/experimental/constraint-solvers-candidate/tests'/n,out/n)
  copy(folder/'source/experimental/constraint-solvers-candidate/solvers.gpr',out/'solvers.gpr')
for reference,kind,stage in [('315','release',65),('315','release',66),('315','release',67),('314','regression',66),('314','regression',67)]:
 folder=base/f'sparkling-alignment-{reference}-flat-{kind}-r{stage}-20261008';out=dest/'integration'/folder.name
 d=json.loads((folder/'results.json').read_text());assert d['complete'] and d['source_hashes_unchanged']
 for p in folder.iterdir():
  if p.is_file():copy(p,out/p.name)
 for p in folder.glob('*/results.json'):copy(p,out/p.parent.name/p.name)
 if reference=='315' and stage==67:
  manifest=json.loads((folder/'manifest.json').read_text())['sources'];assert all(manifest.get(k)==v for k,v in sources.items())
for stage in [66,67]:
 folder=base/f'sparkling-alignment-315-flat-time-r{stage}-quiet-20261008';d=json.loads((folder/'results.json').read_text());assert d['complete'] and d['quiet_window'] and all(r['passed'] for r in d['results'])
 for p in folder.iterdir():
  if p.is_file() and p.suffix!='.so':copy(p,dest/f'paired-time-r{stage}'/p.name)
for n in ['prove_flex.py','build_flex.py','build_packed.py']:copy(root/'experimental/alignment-3.15/tests'/n,dest/n)
copy(root/'tools/guarded.py',dest/'guarded.py');copy(Path(__file__),dest/'archive.py')
write(dest/'results.json',dict(reference='3.15.0',source_count=len(sources),native_cases_passed=395,integrated_315_checks_passed=390,production_314_checks_passed=366,minima_checks=sum(r['checks'] for r in closure),minima_scopes=len(closure),build_flat_open=4,goal_complete=False,scope='Flat CSR columns and CSC numeric-slot map on the factor/backsolve call path; constant Max_Dofs scratch; duplicate offset construction removed. Triangular capacity, dense H and dense rank-update bridge remain.'))
for n,v in old.items():assert sha(evidence/n)==v,n
for p in dest.rglob('*'):
 if p.is_file():inv['files'][str(p.relative_to(evidence))]=sha(p)
inv['count']=inv['current_entries']=len(inv['files']);inv['flat_prior_entries_preserved']=len(old)
(evidence/'inventory.json').write_text(json.dumps(inv,indent=2)+'\n')
for n,v in inv['files'].items():assert sha(evidence/n)==v,n
print(json.dumps(dict(entries=inv['count'],prior_preserved=len(old),checks=sum(r['checks'] for r in closure),scopes=len(closure))))
