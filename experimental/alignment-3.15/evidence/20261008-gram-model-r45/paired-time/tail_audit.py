from pathlib import Path
import json,hashlib
import numpy as np
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/alignment-3.15/evidence');dest=root/'20261008-gram-model-r45'
time=json.loads((dest/'paired-time/results.json').read_text());rng=np.random.default_rng(2026100803);rows=[]
for row in time['results']:
 raw={k:np.array(v) for k,v in row['raw_us'].items()};n=raw['ada'].shape[0];indices=rng.integers(0,n,size=(5000,n));metrics={}
 for denominator in ['baseline','c']:
  a=np.percentile(raw['ada'][indices].reshape(5000,-1),95,axis=1);b=np.percentile(raw[denominator][indices].reshape(5000,-1),95,axis=1)
  metrics['ada_over_'+denominator]=dict(ratio=float(np.percentile(raw['ada'],95)/np.percentile(raw[denominator],95)),bootstrap_95=np.percentile(a/b,[2.5,97.5]).tolist())
 rows.append(dict(model=row['model'],p95=metrics))
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
out=dest/'paired-time/tail-audit.json';assert not out.exists();out.write_text(json.dumps(dict(method='Paired resampling of complete alternating blocks; 5000 bootstrap draws; 95th percentile trajectory times',seed=2026100803,rows=rows),indent=2)+'\n')
script=dest/'paired-time/tail_audit.py';assert not script.exists();script.write_bytes(Path(__file__).read_bytes())
p=root/'inventory.json';inv=json.loads(p.read_text());prior=dict(inv['files']);assert len(prior)==2707
for k,v in prior.items():assert sha(root/k)==v,k
for f in [out,script]:inv['files'][str(f.relative_to(root))]=sha(f)
inv['count']=inv['current_entries']=len(inv['files']);p.write_text(json.dumps(inv,indent=2)+'\n')
print(json.dumps(dict(inventory_count=inv['count'],rows=rows),indent=2))
