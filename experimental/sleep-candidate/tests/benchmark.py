#!/usr/bin/env python3
"""Equivalent full Euler-step batches, alternating Ada and native C nstep calls."""
import argparse,hashlib,json,os,platform,re,subprocess,time
from pathlib import Path
import mujoco,numpy as np
from integration import xml
def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--steps',type=int,default=10000);p.add_argument('--rounds',type=int,default=9);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    cpu=min(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu});results=[]
    for n in [1,4,16,64]:
        for policy in ['allowed','never']:
            m=mujoco.MjModel.from_xml_string(xml('slide',n,policy));f=a.out/f'{n}-{policy}.mjb';mujoco.mj_saveModel(m,str(f))
            samples=[];checks=[]
            for r in range(a.rounds+1):
                def ada():
                    data='17\n'+'0\n'*16+f'7 {a.steps}\n'
                    q=subprocess.run([str(a.binary),str(f)],input=data,text=True,capture_output=True,timeout=120)
                    if q.returncode:raise RuntimeError(q.stderr+q.stdout[-1500:])
                    seconds=float(re.search(r'PERF\s+([\d.]+)',q.stdout)[1]);last=q.stdout.splitlines()[-1]
                    state=np.array([float(x) for x in last.split()]);return seconds,state
                def c():
                    d=mujoco.MjData(m);mujoco.mj_step(m,d,nstep=16);start=time.perf_counter_ns();mujoco.mj_step(m,d,nstep=a.steps);elapsed=(time.perf_counter_ns()-start)*1e-9
                    return elapsed,np.concatenate([[0,d.nv_awake],d.qpos,d.qvel,[d.time],d.tree_asleep])
                if r%2:cc,cs=c();aa,ss=ada()
                else:aa,ss=ada();cc,cs=c()
                if not np.allclose(ss,cs,atol=2e-10,rtol=2e-10):raise AssertionError((n,policy,ss.tolist(),cs.tolist()))
                if r:samples.append(dict(ada=aa,c=cc,ratio=aa/cc));checks.append(hashlib.sha256(ss.tobytes()).hexdigest())
            ratios=[s['ratio'] for s in samples];record=dict(trees=n,policy=policy,steps=a.steps,samples=samples,paired_ratio_median=float(np.median(ratios)),ada_us_per_step=float(np.median([s['ada'] for s in samples])/a.steps*1e6),c_us_per_step=float(np.median([s['c'] for s in samples])/a.steps*1e6),ratio_p10_p90=np.percentile(ratios,[10,90]).tolist(),final_state_hashes=checks)
            results.append(record);print(n,policy,'Ada/C',record['paired_ratio_median'],flush=True)
    report=dict(scope='Full independent smooth Euler step; all allowed trees settle asleep, never policy stays awake. No constraints/activation/tendons. Input/model allocation and I/O outside timing; native C nstep loop.',reference=mujoco.__version__,rounds=a.rounds,cpu_affinity=cpu,platform=platform.platform(),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),results=results)
    (a.out/'performance.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':main()
