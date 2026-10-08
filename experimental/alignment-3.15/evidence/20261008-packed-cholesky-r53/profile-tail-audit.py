from pathlib import Path
import hashlib,json,shutil,gzip
import numpy as np
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');ev=root/'experimental/alignment-3.15/evidence';dest=ev/'20261008-packed-cholesky-r53';p=Path('/var/tmp/sparkling-alignment-315-packed-profile-r53-20261008')
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p,q):q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p,q)
inv=json.loads((ev/'inventory.json').read_text());old=dict(inv['files']);assert len(old)==3157
for k,v in old.items():assert sha(ev/k)==v,k
assert json.loads((p/'results.json').read_text())['complete']
for f in p.iterdir():
 if f.is_file():
  if f.name.startswith('trajectory.'):
   q=dest/'profile'/(f.name+'.gz');q.parent.mkdir(parents=True,exist_ok=True);q.write_bytes(gzip.compress(f.read_bytes(),mtime=0));assert gzip.decompress(q.read_bytes())==f.read_bytes()
  else:copy(f,dest/'profile'/f.name)
for n in ['profile_flex.py','profile_samples.py']:copy(root/'experimental/alignment-3.15/tests'/n,dest/'profile'/n)
time=json.loads((dest/'paired-time/results.json').read_text());rng=np.random.default_rng(2026100804);rows=[]
for row in time['results']:
 raw={k:np.array(v) for k,v in row['raw_us'].items()};sample=rng.integers(0,len(raw['ada']),size=(5000,len(raw['ada'])));metrics={}
 for key in ['baseline','c']:
  a=np.percentile(raw['ada'][sample].reshape(5000,-1),95,axis=1);b=np.percentile(raw[key][sample].reshape(5000,-1),95,axis=1)
  metrics['ada_over_'+key]=dict(ratio=float(np.percentile(raw['ada'],95)/np.percentile(raw[key],95)),bootstrap_95=np.percentile(a/b,[2.5,97.5]).tolist())
 rows.append(dict(model=row['model'],p95=metrics))
q=dest/'paired-time/tail-audit.json';assert not q.exists();q.write_text(json.dumps(dict(method='Paired resampling of complete blocks; 5000 bootstrap draws; 95th percentile trajectory times',seed=2026100804,rows=rows),indent=2)+'\n')
copy(Path(__file__),dest/'profile-tail-audit.py')
for k,v in old.items():assert sha(ev/k)==v,k
for f in dest.rglob('*'):
 if f.is_file():
  k=str(f.relative_to(ev))
  if k not in old:inv['files'][k]=sha(f)
inv['count']=inv['current_entries']=len(inv['files']);(ev/'inventory.json').write_text(json.dumps(inv,indent=2)+'\n')
print(json.dumps(dict(inventory_count=inv['count'],tail=rows)))
