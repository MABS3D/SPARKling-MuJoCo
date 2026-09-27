#!/usr/bin/env python3
"""Report ranges across states/sessions, without averaging model percentages."""
import argparse,json,pathlib,numpy as np
ap=argparse.ArgumentParser();ap.add_argument('sessions',nargs='+',type=pathlib.Path);ap.add_argument('--out',type=pathlib.Path,required=True);a=ap.parse_args()
runs=[json.loads((p/'measurements.json').read_text()) for p in a.sessions]
assert all(r['complete'] for r in runs)
models={}
for model in ('crb_chain_24','ancestor_star_24','ancestor_forest_24','simple_mixed_8'):
 rows=[s for r in runs for s in r['summary'] if s['case'].rsplit('-',1)[0]==model];variants={}
 for v in rows[0]['timings_ns']:
  savings=[100*(1-s['ratio_to_baseline'][v]['median']) for s in rows]
  closure=[float(np.median((np.asarray(s['timings_ns']['baseline'])-s['timings_ns'][v])/(np.asarray(s['timings_ns']['baseline'])-s['timings_ns']['c'])))*100 for s in rows]
  relative_c=[float(np.median(np.asarray(s['timings_ns'][v])/s['timings_ns']['c'])) for s in rows]
  variants[v]=dict(saving_percent_range=[min(savings),max(savings)],gap_closed_percent_range=[min(closure),max(closure)],time_over_c_range=[min(relative_c),max(relative_c)],ci_below_one=sum(s['ratio_to_baseline'][v]['ci95'][1]<1 for s in rows),comparisons=len(rows))
 models[model]=variants
result=dict(models=models,final_processes=sum(r['blocks']*len(r['summary'])*len(r['manifest']) for r in runs),timed_steps=sum(r['blocks']*len(r['summary'])*len(r['manifest'])*r['steps']*r['samples'] for r in runs),max_reference_error=max(max(s['max_c_reference_error'].values()) for r in runs for s in r['summary']),max_ada_error=max(v for r in runs for s in r['summary'] for k,v in s['max_ada_error'].items() if k!='c'))
a.out.write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2))
