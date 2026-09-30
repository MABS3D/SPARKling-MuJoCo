#!/usr/bin/env python3
"""Alternating native full-step timings, same single flex in C and SPARK."""
from pathlib import Path
import argparse, json, os, platform, subprocess
import numpy as np
import mujoco
from check import ROOT, environment, digest
from compare import fixture, payload, parse, numbers

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--exe',type=Path,required=True)
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--baseline',type=Path,help='previous Ada binary, evaluated only at n<=50')
    ap.add_argument('--c-root',type=Path,default=Path('/var/tmp/sparkling-movement-c'))
    ap.add_argument('--blocks',type=int,default=8);ap.add_argument('--steps',type=int,default=1000)
    ap.add_argument('--cpu',type=int,default=min(os.sched_getaffinity(0)))
    a=ap.parse_args();out=a.out.resolve();out.mkdir(parents=True,exist_ok=True)
    assert a.blocks>=2 and a.steps>0 and mujoco.__version__=='3.14.0'
    exe=a.exe.resolve();baseline=a.baseline.resolve() if a.baseline else None;a.c_root=a.c_root.resolve();os.chdir(out)
    c=out/'flex_c';lib=a.c_root/'build/lib/libmujoco.so.3.14.0'
    source=ROOT/'experimental/deformable/tests/elastic_bench.c';env=environment()
    stdcpp=Path(subprocess.check_output(['gcc','-print-file-name=libstdc++.so'],env=env,text=True).strip()).resolve().parent
    cmd=['gcc','-O3','-march=native','-ffp-contract=off','-flto','-I'+str(a.c_root/'source/include'),
         str(source),'-L'+str(lib.parent),'-Wl,-rpath,'+str(lib.parent),'-Wl,-rpath,'+str(stdcpp),
         '-Wl,--disable-new-dtags','-lmujoco','-lstdc++','-lm','-o',str(c)]
    p=subprocess.run(cmd,env=env,capture_output=True,text=True)
    (out/'build.log').write_text(p.stdout+p.stderr)
    if p.returncode:print(p.stderr)
    p.check_returncode()
    cache=(a.c_root/'build/CMakeCache.txt').read_text()
    manifest=dict(command=cmd,ada_sha256=digest(exe),c_sha256=digest(c),library_sha256=digest(lib),
        baseline_sha256=digest(baseline) if baseline else None,baseline_path=str(baseline),
        c_harness_sha256=digest(source),compiler=subprocess.check_output(['gcc','--version'],env=env,text=True).splitlines()[0],
        cmake_flags=[line for line in cache.splitlines() if line.startswith(('CMAKE_C_FLAGS_RELEASE:','MUJOCO_ENABLE_AVX','MUJOCO_ENABLE_LTO'))],
        platform=platform.platform(),cpuinfo=Path('/proc/cpuinfo').read_text().split('\n\n')[0],cpu=a.cpu,
        steps=a.steps,blocks=a.blocks,load_start=os.getloadavg(),
        c_solver='Newton',c_warmstart=True,c_islands=True,c_iterations=100,c_tolerance=1e-12)
    (out/'build.json').write_text(json.dumps(manifest,indent=2))
    records=[];summaries=[];rng=np.random.default_rng(930)
    for mode in ['rest','tilt_impact']:
        for n in [4,16,32,50,64,128]:
            f=fixture(n,mode,930+n);m=f['m'];d=f['d']
            # These mobile-only fixtures can use the normal C optimizations.
            m.opt.solver=mujoco.mjtSolver.mjSOL_NEWTON
            m.opt.disableflags &= ~(int(mujoco.mjtDisableBit.mjDSBL_WARMSTART)|int(mujoco.mjtDisableBit.mjDSBL_ISLAND))
            f['xml']=f['xml'].replace('solver="PGS"','solver="Newton"').replace('<flag warmstart="disable" island="disable"/>','')
            name=f'{mode}-{n}';(out/(name+'.xml')).write_text(f['xml'])
            mjb=out/(name+'.mjb');mujoco.mj_saveModel(m,str(mjb))
            ada_input=payload(f['pos'],f['vel'],f['mass'],f['pin'],f['edges'],m.flexedge_length0,f['k'],f['damp'],f['applied'],f['gravity'],f['h'],a.steps,f['normal'],f['origin'],f['radius'],f['margin'],f['gap'],f['solver'])
            inputs={'ada':ada_input,'c':numbers(np.r_[d.qpos,d.qvel,d.qfrc_applied])+'\n'}
            kinds=['ada','c']
            if baseline and n<=50:inputs['baseline']=ada_input;kinds.append('baseline')
            baseline_ratios=[]
            for kind,inp in inputs.items():(out/(name+'.'+kind+'.input')).write_text(inp)
            ratios=[]
            for block in range(a.blocks):
                med={};outputs={}
                for kind in (kinds if block%2==0 else kinds[::-1]):
                    command=[str(exe if kind=='ada' else baseline),'3'] if kind!='c' else [str(c),str(mjb),str(a.steps),'3']
                    p=subprocess.run(['taskset','-c',str(a.cpu),*command],input=inputs[kind],text=True,capture_output=True,check=True)
                    (out/f'{name}-{block}-{kind}.output').write_text(p.stdout+p.stderr)
                    data=parse(p.stdout);outputs[kind]=data
                    us=np.array(data['timing']).ravel()*1e6/a.steps
                    med[kind]=float(np.median(us));records.append(dict(mode=mode,n=n,block=block,kind=kind,us=us.tolist()))
                for key in ['position','velocity']:
                    np.testing.assert_allclose(outputs['ada'][key],outputs['c'][key],atol=2e-9,rtol=2e-9)
                    if 'baseline' in outputs:np.testing.assert_allclose(outputs['ada'][key],outputs['baseline'][key],atol=2e-9,rtol=2e-9)
                ratios.append(med['ada']/med['c'])
                if 'baseline' in outputs:baseline_ratios.append(med['ada']/med['baseline'])
            summary=dict(mode=mode,n=n,ratio=float(np.median(ratios)))
            for kind in kinds:
                us=np.array([r['us'] for r in records if r['n']==n and r['mode']==mode and r['kind']==kind]).ravel()
                summary[kind]={k:float(np.quantile(us,q)) for k,q in [('p10',.1),('median',.5),('p90',.9),('p99',.99)]}
            boot=np.median(rng.choice(ratios,size=(5000,len(ratios)),replace=True),axis=1)
            summary['ratio_ci95']=np.quantile(boot,[.025,.975]).tolist()
            if baseline_ratios:
                summary['baseline_ratio']=float(np.median(baseline_ratios))
                boot=np.median(rng.choice(baseline_ratios,size=(5000,len(baseline_ratios)),replace=True),axis=1)
                summary['baseline_ratio_ci95']=np.quantile(boot,[.025,.975]).tolist()
            summaries.append(summary)
            print(json.dumps(summary),flush=True)
            (out/'timings.json').write_text(json.dumps(dict(records=records,summary=summaries,load_end=os.getloadavg()),indent=2))
if __name__=='__main__':main()
