#!/usr/bin/env python3
"""Stateful muscle workload; diagnostic, not a full dynamics performance claim."""
import argparse,json,statistics,subprocess
from pathlib import Path
from evidence import HERE,ROOT,snapshot,tool_env,provenance
from reference import build_reference
ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True);ap.add_argument('--rounds',type=int,default=30000);ap.add_argument('--repeats',type=int,default=9);args=ap.parse_args()
out=args.out.resolve();out.mkdir(parents=True,exist_ok=True);hashes=snapshot();env=tool_env();build_reference(out/'reference')
env['MUSCLE_BUILD_ROOT']=str(out/'build');env['MUSCLE_REFERENCE_ROOT']=str(out/'reference')
cmd=['gprbuild','-P',str(HERE/'benchmark.gpr'),'-j2']
p=subprocess.run(cmd,cwd=ROOT,env=env,capture_output=True,text=True);(out/'build.log').write_text(p.stdout+p.stderr);assert p.returncode==0,p.stdout+p.stderr
exe=out/'build/benchmark/bin/muscle_bench';rows=[]
for pattern in range(3):
    samples=[]
    for i in range(args.repeats+1):
        order='A' if i%2==0 else 'C'
        run=subprocess.run([str(exe),str(args.rounds),str(pattern),order],capture_output=True,text=True,env=env,check=True)
        a,c,sa,sc=map(float,run.stdout.split());assert abs(sa-sc)<=2e-13*max(1,abs(sc)),(sa,sc)
        if i:samples.append({'first':order,'ada_seconds':a,'c_seconds':c,'ada_checksum':sa,'c_checksum':sc})
    ar=[s['ada_seconds']/(args.rounds*128)*1e9 for s in samples];cr=[s['c_seconds']/(args.rounds*128)*1e9 for s in samples]
    ratios=[s['ada_seconds']/s['c_seconds'] for s in samples]
    def stats(vals):return {'median':statistics.median(vals),'min':min(vals),'max':max(vals),'population_stddev':statistics.pstdev(vals)}
    rows.append({'pattern':['hard-switch','smooth-actearly','smooth-actearly-force-limit'][pattern],'steps_per_sample':args.rounds*128,'ada_ns_per_actuator_step':stats(ar),'c_ns_per_actuator_step':stats(cr),'paired_ratio':stats(ratios),'samples':samples})
assert snapshot()==hashes,'source changed during benchmark'
result={'scope':'scalar muscle actuation plus Euler activation; caller-provided varying lengths and velocities; excludes transmissions, dynamics and solver','full_movement_parity':'pending','environment':provenance(env),'sources':hashes,'build_command':cmd,'results':rows}
(out/'benchmark.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(rows,indent=2))
