"""Full-step C/Ada timings for identical enabled tendon-constraint physics."""
import argparse, ctypes, hashlib, json, os, platform, subprocess
from pathlib import Path
import mujoco
import numpy as np
from test_tendon_constraints import fixtures

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--repeats',type=int,default=15);p.add_argument('--steps',type=int,default=100);a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    cpu=min(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu})
    wheel=Path(mujoco.__file__).parent;lib=wheel/'libmujoco.so.3.14.0';native=a.out/'benchmark.so'
    driver=Path(__file__).with_name('benchmark.c')
    cmd=['gcc','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',str(driver),'-I'+str(wheel/'include'),str(lib),'-Wl,-rpath,'+str(wheel),'-o',str(native)]
    subprocess.run(cmd,check=True)
    f=ctypes.CDLL(str(native)).constrained_time;f.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int];f.restype=ctypes.c_double
    selected={'fixed_PGS_lower','fixed_CG_lower','fixed_Newton_lower','spatial_Newton','spatial_free_Newton','mixed_fixed_spatial','fixed_spring_armature'}
    results=[];rng=np.random.default_rng(731)
    for name,source in fixtures():
        if name not in selected:continue
        m=mujoco.MjModel.from_xml_string(source);d=mujoco.MjData(m);file=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(file))
        q=m.qpos0.copy();v=np.linspace(-.03,.03,m.nv);force=np.linspace(-.05,.05,m.nv)
        payload=f'1 {a.steps}\n'+' '.join(format(x,'.17g') for x in [0,*q,*v,*force,*np.zeros(m.nu),*np.zeros(m.na)])+'\n'
        times={'ada':[],'c':[]};states={}
        for repeat in range(a.repeats+2):
            for language in (['ada','c'] if repeat%2==0 else ['c','ada']):
                if language=='ada':
                    r=subprocess.run([str(a.binary),str(file),'benchmark'],input=payload,text=True,capture_output=True,check=True,timeout=120)
                    lines=r.stdout.splitlines();assert lines[0].startswith('seconds '),r.stdout
                    elapsed=float(lines[0].split()[1]);states[language]=np.fromstring(lines[1][6:],sep=' ')
                else:
                    mujoco.mj_resetData(m,d);d.qpos[:]=q;d.qvel[:]=v;d.qfrc_applied[:]=force
                    elapsed=f(m._address,d._address,a.steps);states[language]=np.r_[d.qpos,d.qvel,d.time].copy()
                if repeat>=2:times[language].append(elapsed/a.steps*1e6)
            if not np.allclose(states['ada'],states['c'],atol=3e-6,rtol=1e-8):raise AssertionError((name,np.max(abs(states['ada']-states['c']))))
        ratio=np.array(times['ada'])/np.array(times['c'])
        interval=np.percentile(np.median(ratio[rng.integers(0,len(ratio),(3000,len(ratio)))],axis=1),[2.5,97.5])
        row=dict(model=name,nv=m.nv,rows=d.nefc,times_us=times,paired_ratio=float(np.median(ratio)),paired_bootstrap_95=interval.tolist(),
          trajectory_max_abs=float(np.max(abs(states['ada']-states['c']))),summary={k:dict(median_us=float(np.median(v)),p10_us=float(np.percentile(v,10)),p90_us=float(np.percentile(v,90)),p95_us=float(np.percentile(v,95))) for k,v in times.items()})
        results.append(row);print({k:v for k,v in row.items() if k!='times_us'},flush=True)
    report=dict(reference=mujoco.__version__,reference_sha256=hashlib.sha256(lib.read_bytes()).hexdigest(),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
      steps=a.steps,repeats=a.repeats,warmup=2,cpu=cpu,hardware=platform.uname()._asdict(),driver_sha256=hashlib.sha256(driver.read_bytes()).hexdigest(),command=cmd,results=results)
    (a.out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':main()
