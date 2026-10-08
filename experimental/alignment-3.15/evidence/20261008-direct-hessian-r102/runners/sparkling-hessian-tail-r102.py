from pathlib import Path
import hashlib,json
import numpy as np
p=Path('/var/tmp/sparkling-alignment-315-hessian-time-r102-quiet-20261008/results.json')
d=json.loads(p.read_text());assert d['complete'] and all(r['passed'] for r in d['results'])
rng=np.random.default_rng(2026100805);records=[]
for row in d['results']:
 cur=np.array(row['raw_us']['ada']);base=np.array(row['raw_us']['baseline'])
 assert cur.shape==base.shape==(24,16)
 draws=rng.integers(0,24,size=(5000,24))
 ratios=np.quantile(cur[draws].reshape(5000,-1),.95,axis=1)/np.quantile(base[draws].reshape(5000,-1),.95,axis=1)
 ratio=float(np.quantile(cur,.95)/np.quantile(base,.95));lo,hi=np.quantile(ratios,[.025,.975])
 records.append(dict(model=row['model'],ratio=ratio,bootstrap_95=[float(lo),float(hi)],central_percent=100*(ratio-1),percent_95=[100*(float(lo)-1),100*(float(hi)-1)],resolved='slower' if lo>1 else 'faster' if hi<1 else 'unresolved'))
receipt=dict(results_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),method='Paired complete-block percentile bootstrap: 5000 draws of 24 alternating blocks, each retaining 16 trajectories, seed 2026100805; p95 current/baseline. No aggregate acceptance.',results=records)
(p.parent/'tail-audit.json').write_text(json.dumps(receipt,indent=2)+'\n')
print(json.dumps(records))
