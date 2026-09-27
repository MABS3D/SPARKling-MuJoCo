#!/usr/bin/env python3
"""Balanced, isolated process measurements; diagnostic variants have NO proof claim."""
import argparse, pathlib, json, subprocess, os, hashlib, importlib.util, numpy as np
P=pathlib.Path
ap=argparse.ArgumentParser();ap.add_argument('--build',type=P,required=True);ap.add_argument('--inputs',type=P,required=True);ap.add_argument('--out',type=P,required=True);ap.add_argument('--session',type=int,required=True);ap.add_argument('--blocks',type=int,default=20);a=ap.parse_args()
a.out.mkdir(parents=True,exist_ok=False);os.sched_setaffinity(0,{12})
spec=importlib.util.spec_from_file_location('harness',P(__file__).resolve().parents[1]/'run.py');h=importlib.util.module_from_spec(spec);spec.loader.exec_module(h)
manifest=json.loads((a.build/'manifest.json').read_text()); variants=list(manifest)
assert a.blocks%len(variants)==0
for k,m in manifest.items(): assert hashlib.sha256(P(m['binary']).read_bytes()).hexdigest()==m['binary_sha256']
if 'library' in manifest['c']:
 assert hashlib.sha256(P(manifest['c']['library']).read_bytes()).hexdigest()==manifest['c']['library_sha256']
rng=np.random.default_rng(2026092600+a.session);records=[];summaries=[]
for model in ('crb_chain_24','ancestor_star_24','ancestor_forest_24','simple_mixed_8'):
 for state in range(3):
  key=f'{model}-{state}'; data=(a.inputs/(key+'.input')).read_text();expected=json.loads((a.inputs/(key+'.expected.json')).read_text()); timings={v:[] for v in variants};errors={v:0. for v in variants};ada_errors={v:0. for v in variants}
  for block in range(a.blocks):
   if block%len(variants)==0:
    permutation=list(rng.permutation(variants)); rotations=list(rng.permutation(len(variants)))
   shift=rotations[block%len(variants)];order=permutation[shift:]+permutation[:shift];outputs={}
   for v in order:
    cmd=[manifest[v]['binary'],str(a.inputs/(model+'.mjb')),'100','4','2']
    run=subprocess.run(cmd,input=data,text=True,capture_output=True,timeout=60);run.check_returncode();rows=h.parse(run.stdout);assert len(rows)==4
    for row in rows:
     assert row['seconds']>0 and np.isfinite(row['seconds'])
     for field in ('qpos','qvel','time'):
      actual=np.asarray(row[field]);ref=np.asarray(expected[field]);err=abs(actual-ref)
      assert actual.shape==ref.shape and np.all(err<=2e-10+2e-10*abs(ref)),(key,v,field,err)
      errors[v]=max(errors[v],float(np.max(err,initial=0)))
    outputs[v]=rows;timings[v].append(float(np.median([r['seconds']*1e7 for r in rows])))
    records.append(dict(case=key,block=block,variant=v,order=order,rows=rows))
   for v in variants:
    for r,b in zip(outputs[v],outputs['baseline']):
     for field in ('qpos','qvel','time'):
      err=abs(np.asarray(r[field])-np.asarray(b[field]));ada_errors[v]=max(ada_errors[v],float(np.max(err,initial=0)))
      if v not in ('fused','combined','c'): assert r[field]==b[field],(key,v,'non-bitwise')
  summary=dict(case=key,timings_ns=timings,ratio_to_baseline={v:h.ratio(timings[v],timings['baseline'],rng) for v in variants},stats_ns={v:h.stats(timings[v]) for v in variants},max_c_reference_error=errors,max_ada_error=ada_errors)
  summaries.append(summary)
  (a.out/'measurements.json').write_text(json.dumps(dict(complete=False,records=records,summary=summaries)))
  print(key,{v:round(summary['ratio_to_baseline'][v]['median'],3) for v in variants},flush=True)
(a.out/'measurements.json').write_text(json.dumps(dict(complete=True,session=a.session,blocks=a.blocks,cpu=12,steps=100,samples=4,seed=2026092600+a.session,manifest=manifest,records=records,summary=summaries),indent=2))
