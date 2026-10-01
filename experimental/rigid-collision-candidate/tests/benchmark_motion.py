"""Collision-phase trajectories, with kinematics and input preparation untimed."""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import statistics
import subprocess

import mujoco
import numpy as np
from common import oracle,serialize,digest
from driver_cases import extract,pairs


def cases():
    result=[]
    for n in [8,32,128,512]:
        for family in ['sparse-moving','dense-moving','mixed-moving']:
            bodies=[];step=2.0 if family.startswith('sparse') else .6
            kinds=['sphere']*n if not family.startswith('mixed') else ['sphere','capsule','ellipsoid','cylinder','box']*(n//5+1)
            for i in range(n):
                p=np.array([i%8,(i//8)%8,i//64])*step
                bodies.append('<body pos="'+' '.join(map(str,p))+'"><freejoint/><geom type="'+kinds[i]+'" size=".35 .4 .45"/></body>')
            xml='<mujoco><option ccd_iterations="100"/><worldbody>'+''.join(bodies)+'</worldbody></mujoco>'
            m=mujoco.MjModel.from_xml_string(xml);initial=mujoco.MjData(m).qpos.copy();frames=[];rows=[];expected=[]
            for f in range(16):
                d=mujoco.MjData(m);d.qpos[:]=initial
                for j in range(m.njnt):
                    a=int(m.jnt_qposadr[j]);d.qpos[a:a+3]+=.025*np.sin((f*.13+j)*np.array([1.,1.2,1.7]))
                    q=np.array([1.,.015*np.sin(f*.11+j),.012*np.cos(f*.09+j),.009*np.sin(f*.06-j)]);q/=np.linalg.norm(q)
                    d.qpos[a+3:a+7]=q
                mujoco.mj_fwdPosition(m,d);frames.append(d);rows.append(extract(m,d)[0]);expected.append(pairs(d))
            result.append((family+'-'+str(n),m,frames,rows,expected,xml))
    return result


def stream(rows,mode,repeats):
    text=serialize(rows[0],mode=mode,repeats=len(rows) if mode==4 else repeats)
    if mode==5:text+=str(len(rows))+'\n'
    for frame in rows[1:]:
        text+=' '.join(format(v,'.17g') for r in frame for v in r[12:25])+'\n'
    return text


def parse_pairs(text):
    lines=[]
    for line in text.splitlines():
        v=line.split()
        if len(v)<2 or v[0]!='SUCCESS':return None
        p=sorted(tuple(map(int,q)) for q in zip(v[2::2],v[3::2]))
        if len(p)!=int(v[1]) or len(p)!=len(set(p)):return None
        lines.append(p)
    return lines


def main(out,rounds):
    cpu=min(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu})
    lib=oracle(out);probe=out/'build/release/bin/rigid_probe';results=[];failures=[]
    with (out/'motion-timing-raw.jsonl').open('w') as log:
        for name,m,frames,rows,expected,xml in cases():
            validation=subprocess.run([str(probe)],input=stream(rows,4,1),text=True,capture_output=True,check=True,timeout=120)
            actual=parse_pairs(validation.stdout)
            if actual!=expected:
                differences=[]
                if actual is not None:
                    for f,(a,c) in enumerate(zip(actual,expected)):
                        extra=sorted(set(a)-set(c));missing=sorted(set(c)-set(a))
                        if extra or missing:differences.append(dict(frame=f,extra=extra,missing=missing))
                failures.append(dict(case=name,differences=differences,output=validation.stdout if actual is None else None))
                print(name,'NOT TIMED: pair decisions differ',flush=True)
                continue
            repeats=80 if m.ngeom>=512 else 250
            checksum_expected=sum(1+a*4096+b for frame in expected for a,b in frame)*repeats
            ptr=(ctypes.c_void_p*len(frames))(*(d._address for d in frames))
            text=stream(rows,5,repeats);ctimes=[];atimes=[]
            def run_c():
                check=ctypes.c_uint64();ns=lib.rigid_time_frames(m._address,ptr,len(frames),repeats,ctypes.byref(check))
                if check.value!=checksum_expected:raise RuntimeError('C checksum '+name)
                return ns
            def run_a():
                run=subprocess.run([str(probe)],input=text,text=True,capture_output=True,check=True,timeout=120)
                v=run.stdout.split()
                if len(v)!=3 or v[0]!='SUCCESS' or int(v[2])!=checksum_expected:raise RuntimeError('Ada checksum '+name+run.stdout)
                return float(v[1])
            for i in range(rounds):
                if i%2==0:c=run_c();a=run_a()
                else:a=run_a();c=run_c()
                ctimes.append(c);atimes.append(a)
                log.write(json.dumps(dict(case=name,round=i,c_ns=c,ada_ns=a,repetitions=repeats,frames=len(frames)))+'\n');log.flush()
            ratios=np.array(atimes)/np.array(ctimes)
            rng=np.random.default_rng(314);boot=np.median(rng.choice(ratios,size=(10000,len(ratios)),replace=True),axis=1)
            record=dict(case=name,geoms=m.ngeom,frames=len(frames),repetitions=repeats,
                pairs_min_max=[min(map(len,expected)),max(map(len,expected))],
                c_median_ns=statistics.median(ctimes),ada_median_ns=statistics.median(atimes),
                paired_ratio_median=float(np.median(ratios)),paired_ratio_ci95=np.quantile(boot,[.025,.975]).tolist(),
                c_min_max_ns=[min(ctimes),max(ctimes)],ada_min_max_ns=[min(atimes),max(atimes)],
                xml_sha256=hashlib.sha256(xml.encode()).hexdigest())
            results.append(record);print(name,'Ada/C',round(record['paired_ratio_median'],3),flush=True)
            (out/'motion-performance.json').write_text(json.dumps(dict(scope='collision phase over 16 precomputed moving frames; pair detection versus C contact manifolds; not a complete simulation',
                cpu_affinity=cpu,rounds=rounds,harness_sha256=digest(__file__),results=results,untimed_mismatches=failures),indent=2)+'\n')
    return not failures

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=11);a=p.parse_args();raise SystemExit(0 if main(a.out.resolve(),a.rounds) else 1)
