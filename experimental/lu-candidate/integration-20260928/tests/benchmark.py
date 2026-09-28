import json,subprocess,statistics,os,platform,hashlib
from pathlib import Path
r=Path(__file__).resolve().parents[1]
rows=[];cpu=max(os.sched_getaffinity(0))
for mode in ['D','S']:
 for n in [8,32,128]:
  values={'ada':[],'c':[]};loops=max(10,50000//n)
  for rep in range(7):
   checks={}
   for lang in (['ada','c'] if rep%2==0 else ['c','ada']):
    exe=r/'bin'/('lu_bench' if lang=='ada' else 'c_bench')
    out=subprocess.check_output(['taskset','-c',str(cpu),str(exe),mode,str(n),str(loops)],text=True).split()
    values[lang].append(float(out[0])/loops)
    checks[lang]=float(out[1])
   assert abs(checks['ada']-checks['c'])<=1e-9*max(1,abs(checks['ada']))
  row=dict(mode=mode,n=n,loops=loops,seconds_per_factor_solve=values,ratio=statistics.median(values['ada'])/statistics.median(values['c']))
  rows.append(row);print(mode,n,row['ratio'],flush=True)
result=dict(cpu=cpu,platform=platform.platform(),note='Standalone factor+solve including factor buffer copy; not integrated movement. Concurrent host workloads uncontrolled.',rows=rows,binaries={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in (r/'bin').iterdir() if p.is_file()})
(r/'evidence/performance.json').write_text(json.dumps(result,indent=2))
