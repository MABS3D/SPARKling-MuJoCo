#!/usr/bin/env python3
"""Paired whole-Euler-step timings, validating every trajectory against native C.

Binaries must be built with the same recorded release flags and pinned C library.
This local sample is not a claim of performance parity or quiet-host regression.
"""
import argparse
import hashlib
import itertools
import json
import os
from pathlib import Path
import subprocess
import mujoco
import numpy as np
from compare_numerics import fixtures


def parse(text):
    rows=[]
    for line in text.splitlines():
        key,*values=line.split()
        if key=='sample': rows.append({'seconds':float(values[0])})
        else: rows[-1][key]=np.array(values,dtype=float)
    return rows


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--ada',type=Path,required=True);p.add_argument('--c',type=Path,required=True)
    p.add_argument('--baseline',type=Path,help='Frozen pre-change Ada executable')
    p.add_argument('--out',type=Path,required=True);p.add_argument('--cpu',type=int)
    p.add_argument('--steps',type=int,default=12000);p.add_argument('--samples',type=int,default=7)
    p.add_argument('--blocks',type=int,default=12)
    p.add_argument('--model',action='append',default=[],help='Fixture name; repeat to select workloads')
    p.add_argument('--external',action='store_true',help='Include world-frame body forces and torques')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    if min(a.steps,a.samples,a.blocks)<1:p.error('steps, samples and blocks must be positive')
    if a.cpu is not None: os.sched_setaffinity(0,{a.cpu})
    src=Path(__file__).resolve().parents[1]/'tests/manifold-fixtures'
    cases={x:(src/(x+'.xml')).read_text() for x in ('free','ball','free_ball_hinge','ball_chain')}
    cases['scalar_hinge']=fixtures()['hinge_motor'];cases['scalar_chain_12']=fixtures()['chain_12']
    if a.model:
        cases={name:(cases[name] if name in cases else (src/(name+'.xml')).read_text()) for name in a.model}
    kinds=('baseline','ada','c') if a.baseline else ('ada','c')
    orders=list(itertools.permutations(kinds))
    rng=np.random.default_rng(20260930)
    def paired_summary(values):
        values=np.asarray(values,dtype=float)
        bootstrap=np.median(rng.choice(values,size=(10000,len(values)),replace=True),axis=1)
        return dict(median=float(np.median(values)),ci95=list(map(float,np.percentile(bootstrap,[2.5,97.5]))),
                    minimum=float(values.min()),maximum=float(values.max()))
    results=[]
    for name,xml in cases.items():
        m=mujoco.MjModel.from_xml_string(xml);path=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path))
        values=[m.qpos0,np.linspace(-.2,.3,m.nv),np.zeros(m.nu),np.linspace(-.03,.04,m.nv)]
        if a.external:values.append(np.linspace(-.02,.03,6*m.nbody))
        data=' '.join(format(x,'.17g') for x in np.concatenate(values))+'\n'
        times={kind:[] for kind in kinds};ratios=[];baseline_ratios=[];improvement_ratios=[]
        for block in range(a.blocks):
            runs={}
            for kind in orders[block%len(orders)]:
                run=subprocess.run([str(getattr(a,kind)),str(path),str(a.steps),str(a.samples),'2']+(['external'] if a.external else []),input=data,text=True,capture_output=True,timeout=60)
                (a.out/(name+'-'+str(block)+'-'+kind+'.output')).write_text(run.stdout+run.stderr)
                run.check_returncode();runs[kind]=parse(run.stdout)
                times[kind].extend(x['seconds']/a.steps for x in runs[kind])
            for kind in kinds:
                if kind=='c':continue
                for ar,cr in zip(runs[kind],runs['c']):
                    for field in ('qpos','qvel','time'):
                        np.testing.assert_allclose(ar[field],cr[field],atol=2e-8,rtol=2e-8,err_msg=name+' '+kind+' '+field)
            medians={kind:float(np.median([r['seconds'] for r in runs[kind]])) for kind in kinds}
            ratios.append(medians['ada']/medians['c'])
            if a.baseline:
                baseline_ratios.append(medians['baseline']/medians['c'])
                improvement_ratios.append(medians['ada']/medians['baseline'])
        result=dict(model=name,nq=m.nq,nv=m.nv,ada_us=float(np.median(times['ada'])*1e6),c_us=float(np.median(times['c'])*1e6),paired_ratio=float(np.median(ratios)),block_ratios=ratios)
        result['ada_over_c']=paired_summary(ratios)
        result['timings_us']={kind:dict(zip(('p10','p50','p90'),map(float,np.percentile(times[kind],[10,50,90])*1e6))) for kind in kinds}
        if a.baseline:
            result['baseline_over_c']=paired_summary(baseline_ratios)
            result['ada_over_baseline']=paired_summary(improvement_ratios)
            result['baseline_block_ratios']=baseline_ratios
            result['improvement_block_ratios']=improvement_ratios
        results.append(result);print(name,result['ada_us'],result['c_us'],result['ada_over_c'],result.get('ada_over_baseline'),flush=True)
    digest=lambda x:hashlib.sha256(x.read_bytes()).hexdigest()
    (a.out/'results.json').write_text(json.dumps(dict(mujoco=mujoco.__version__,args={k:str(v) for k,v in vars(a).items()},loadavg=os.getloadavg(),affinity=sorted(os.sched_getaffinity(0)),orders=orders,bootstrap_seed=20260930,bootstrap_resamples=10000,binaries={k:dict(path=str(getattr(a,k)),sha256=digest(getattr(a,k))) for k in kinds},results=results),indent=2)+'\n')

if __name__=='__main__':main()
