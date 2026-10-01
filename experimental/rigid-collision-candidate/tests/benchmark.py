"""Pair decisions timed against contact-generating native mj_collision.

This measures only the collision phase, excluding model construction and poses.
It cannot establish contact-manifold or complete simulation performance parity.
"""
import argparse
import ctypes
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess

import numpy as np
import mujoco

from common import serialize, oracle, digest
from check import scene_model


def models():
    cases=[]
    kinds=['sphere','capsule','ellipsoid','cylinder','box']
    for n in [8,32,128,512]:
        for family in ['sparse','dense','mixed','masks','plane']:
            p=np.array([[i%8,(i//8)%8,i//64] for i in range(n)],float)
            p*=2.0 if family=='sparse' else 0.6
            ks=['sphere']*n if family in ['sparse','dense','plane'] else [kinds[i%5] for i in range(n)]
            if family=='plane':ks=['plane',*ks];p=np.vstack([[0,0,0],p])
            cases.append((f'{family}-{n}',scene_model(ks,p,masks=family=='masks')))
    return cases


def ada_call(probe,rows,repeats):
    run=subprocess.run([str(probe)],input=serialize(rows,mode=1,repeats=repeats),text=True,capture_output=True,check=True,timeout=90)
    values=run.stdout.split()
    if len(values)!=3 or values[0]!='SUCCESS':raise RuntimeError(run.stdout+run.stderr)
    return float(values[1]),int(values[2])


def main(out,rounds,case=None,repetitions=None):
    cores=os.sched_getaffinity(0);cpu=min(cores);os.sched_setaffinity(0,{cpu})
    lib=oracle(out);probe=out/'build/release/bin/rigid_probe';results=[]
    cases=[entry for entry in models() if case is None or entry[0]==case]
    suffix='' if case is None else '-confirmation'
    raw=out/('timing'+suffix+'-raw.jsonl')
    with raw.open('w') as log:
        for name,(m,d,rows,pairs,xml) in cases:
            repeats=repetitions if repetitions is not None else (300 if len(rows)>256 else 2000)
            expected=sum(1+a*4096+b for a,b in pairs)*repeats
            for _ in range(3):mujoco.mj_collision(m,d)
            ctime=[];atime=[]
            for i in range(rounds):
                check=ctypes.c_uint64()
                def run_c():
                    ns=lib.rigid_time(m._address,d._address,repeats,ctypes.byref(check))
                    if check.value!=expected:raise RuntimeError(f'C checksum mismatch {name}: {check.value} != {expected}')
                    return ns
                def run_a():
                    ns,checksum=ada_call(probe,rows,repeats)
                    if checksum!=expected:raise RuntimeError(f'Ada checksum mismatch {name}: {checksum} != {expected}')
                    return ns
                if i%2==0:cns=run_c();ans=run_a()
                else:ans=run_a();cns=run_c()
                ctime.append(cns);atime.append(ans)
                log.write(json.dumps(dict(case=name,round=i,c_ns=cns,ada_ns=ans,repeats=repeats))+'\n');log.flush()
            ratios=np.array(atime)/np.array(ctime)
            boot=np.random.default_rng(314).choice(ratios,size=(10000,len(ratios)),replace=True)
            interval=np.quantile(np.median(boot,axis=1),[.025,.975])
            record=dict(case=name,geoms=m.ngeom,contacts=d.ncon,pairs=len(pairs),repeats=repeats,
                c_median_ns=statistics.median(ctime),ada_median_ns=statistics.median(atime),
                paired_ratio_median=float(np.median(ratios)),paired_ratio_ci95=interval.tolist(),
                c_min_max_ns=[min(ctime),max(ctime)],ada_min_max_ns=[min(atime),max(atime)],
                xml_sha256=__import__('hashlib').sha256(xml.encode()).hexdigest())
            results.append(record)
            print(name,'Ada/C',round(record['paired_ratio_median'],3),flush=True)
            (out/('performance'+suffix+'.json')).write_text(json.dumps(dict(scope='pair detection vs C contact-generating collision phase; no complete-step parity claim',
                cpu_affinity=cpu,platform=platform.platform(),cpuinfo=Path('/proc/cpuinfo').read_text().split('model name')[1].splitlines()[0],
                compiler=subprocess.check_output(['gcc','--version'],text=True).splitlines()[0],
                rounds=rounds,results=results),indent=2)+'\n')
    (out/('benchmark-models'+suffix+'.json')).write_text(json.dumps({name:item[4] for name,item in cases},indent=2)+'\n')

if __name__=='__main__':
    a=argparse.ArgumentParser();a.add_argument('--out',type=Path,required=True);a.add_argument('--rounds',type=int,default=9);a.add_argument('--case');a.add_argument('--repetitions',type=int);args=a.parse_args();main(args.out.resolve(),args.rounds,args.case,args.repetitions)
