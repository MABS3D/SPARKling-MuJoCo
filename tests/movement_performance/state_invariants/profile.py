#!/usr/bin/env python3
"""Measure instrumented phases separately from the uninstrumented A/B trial.

Nested readiness and condition costs are INCLUDED in their enclosing phases.
Clock overhead is not subtracted: these are diagnostic shares, not speed claims.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import numpy as np

HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE.parent))
from run import parse, stats


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--fixtures',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--cpu',type=int,default=12)
    p.add_argument('--repeats',type=int,default=8)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    os.sched_setaffinity(0,{a.cpu})
    result=dict(complete=False,cpu=a.cpu,repeats=a.repeats,steps=100,samples=4,
                instrumentation='nested timings include clock overhead',cases=[])
    b=a.build/'baseline/bin/movement_bench';profile=a.build/'profile/bin/movement_bench'
    result['binaries']={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [b,profile]}
    for name in ['hinge_motor','branched_multijoint','chain_12']:
        for state in range(3):
            key=f'{name}-{state}';model=a.fixtures/(name+'.mjb');data=(a.fixtures/(key+'.input')).read_text()
            ref=subprocess.run([str(b),str(model),'100','1','2'],input=data,text=True,capture_output=True,check=True,timeout=60)
            reference=parse(ref.stdout)[0]
            records=[]
            for index in range(a.repeats):
                run=subprocess.run([str(profile),str(model),'100','4','2'],input=data,text=True,capture_output=True,check=True,timeout=60)
                (a.out/f'{key}-{index}.txt').write_text(run.stdout+run.stderr)
                values=parse('\n'.join(s for s in run.stdout.splitlines() if not s.startswith('profile ')))
                assert len(values)==4
                for row in values:
                    for field in ['qpos','qvel','time']:assert row[field]==reference[field],(key,index,field)
                phases={}
                for line in run.stdout.splitlines():
                    if line.startswith('profile '):
                        _,phase,seconds,count=line.split()
                        assert int(count)==(800 if phase in ['CONDITION','PREPARE_FACTOR'] else 400),(key,phase,count)
                        phases[phase]=float(seconds)*1e9/400
                assert len(phases)==16
                records.append(dict(total_ns_per_step=sum(r['seconds'] for r in values)*1e9/400,phases=phases))
            phase_stats={phase:stats([r['phases'][phase] for r in records]) for phase in records[0]['phases']}
            ready=[sum(v for k,v in r['phases'].items() if k.startswith('READY_')) for r in records]
            case=dict(case=key,records=records,phases=phase_stats,
                      total=stats([r['total_ns_per_step'] for r in records]),
                      ready=stats(ready),ready_fraction=stats([v/r['total_ns_per_step'] for v,r in zip(ready,records)]))
            result['cases'].append(case)
            (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
            print(key,'readiness share',case['ready_fraction']['median'],flush=True)
    result['complete']=True
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')


if __name__=='__main__':main()
