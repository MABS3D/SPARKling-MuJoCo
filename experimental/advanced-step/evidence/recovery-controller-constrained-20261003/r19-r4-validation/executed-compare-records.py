"""Compare full probe output files, inputs and C differential records."""
import argparse,hashlib,json
from pathlib import Path
p=argparse.ArgumentParser();p.add_argument('--current',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
r={'driver_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'current':str(a.current),'baseline':str(a.baseline),'corpora':{}}
for name in ['minimum','smooth','fixed','mobile','parent']:
 x=json.loads((a.current/name/'results.json').read_text());y=json.loads((a.baseline/name/'results.json').read_text())
 c={'records_identical':x['records']==y['records'],'cases':x['cases'],'passed':x['passed'],'failures_identical':x['failures']==y['failures'],'files':{}}
 for suffix in ['.input','.mjb','.output']:
  left={f.name:f for f in (a.current/name).glob('*'+suffix)};right={f.name:f for f in (a.baseline/name).glob('*'+suffix)}
  mismatch=[n for n in sorted(left.keys()|right.keys()) if n not in left or n not in right or left[n].read_bytes()!=right[n].read_bytes()]
  c['files'][suffix]={'current_count':len(left),'baseline_count':len(right),'mismatches':mismatch,'identical':not mismatch}
 r['corpora'][name]=c
x=json.loads((a.current/'edges/results.json').read_text());y=json.loads((a.baseline/'edges/results.json').read_text())
def edge(v):return [{k:z[k] for k in ['model','exit','output'] if k in z} for z in v['records']]
r['edges_identical']=edge(x)==edge(y)
r['same_numerical_records_and_files']=all(x['records_identical'] and x['failures_identical'] and all(c['identical'] for c in x['files'].values()) for x in r['corpora'].values()) and r['edges_identical']
a.out.write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r,indent=2));raise SystemExit(not r['same_numerical_records_and_files'])
