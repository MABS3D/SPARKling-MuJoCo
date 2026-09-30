#!/usr/bin/env python3
"""Integrated trajectories. One native bulk mj_step call, not a Python per-step loop.

Input, reset, process startup and output are outside both timed regions. The Ada
probe reports its internal monotonic clock. Alternate order across repetitions.
"""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import time
import numpy as np
import mujoco
from build import build, sources, environment
from compare import cases, case, shape, xml, payload, parse, reference, run

ap=argparse.ArgumentParser(); ap.add_argument('--out',type=Path,required=True)
ap.add_argument('--baseline-probe',type=Path)
ap.add_argument('--repetitions',type=int,default=11); a=ap.parse_args()
a.out=a.out.resolve(); a.out.mkdir(parents=True,exist_ok=True); before=sources()
load_before=Path('/proc/loadavg').read_text().strip()
os.chdir(a.out)
exe=build(a.out/'build','release'); suite=[]
base=dict(cases())
for name in ('sphere','shared_body','crossing','attachment_spring'):
    c=copy.deepcopy(base[name]); c['steps']=200; suite.append((name,c))
for n in (32,128):
    rng=np.random.default_rng(3009+n)
    pos=np.array([[i*.1,0,.019] for i in range(n)])
    pos+=rng.uniform(-1,1,(n,3))*np.array([.003,.002,.0002])
    c=case(pos,[(i,i+1) for i in range(n-1)],shapes=[shape(2)],gravity=np.array([0,0,-9.81]),steps=200,stiffness=10.)
    suite.append((f'plane_network_{n}',c))
results=[]
for name,c in suite:
    # Every timing workload also gets a checked numerical final-state comparison.
    run(exe,a.out,name,c)
    if a.baseline_probe: run(a.baseline_probe,a.out,name+'-baseline',c,coordinates=False)
    init=copy.deepcopy(c); init['steps']=0
    _,m,d=reference(init,xml(c)); state_spec=mujoco.mjtState.mjSTATE_INTEGRATION
    state=np.zeros(mujoco.mj_stateSize(m,state_spec)); mujoco.mj_getState(m,d,state,state_spec)
    contact_start=d.nefc
    inp=payload(c); ada=[]; native=[]; previous=[]
    def run_c():
        mujoco.mj_setState(m,d,state,state_spec); mujoco.mj_forward(m,d)
        t=time.perf_counter_ns(); mujoco.mj_step(m,d,nstep=c['steps']); elapsed=time.perf_counter_ns()-t
        native.append(elapsed/c['steps'])
    def measure_ada(binary,samples):
        p=subprocess.run([str(binary),'1'],input=inp,text=True,capture_output=True,check=True)
        r=parse(p.stdout); assert r['status']=='SUCCESS',r['status']
        samples.append(r['timing'][0][0]*1e9/c['steps'])
    def run_ada(): measure_ada(exe,ada)
    def run_baseline(): measure_ada(a.baseline_probe,previous)
    runners=[run_c,run_ada]+([run_baseline] if a.baseline_probe else [])
    for f in runners: f()
    ada.clear(); native.clear(); previous.clear()
    for rep in range(a.repetitions):
        # Rotate first position, then reverse each cycle, balancing all engines.
        order=runners[rep%len(runners):]+runners[:rep%len(runners)]
        if (rep//len(runners))%2: order=list(reversed(order))
        for f in order: f()
    def stats(x):
        return dict(median_ns=float(np.median(x)),p10_ns=float(np.quantile(x,.1)),
                    p90_ns=float(np.quantile(x,.9)),min_ns=float(min(x)),max_ns=float(max(x)),samples_ns=x)
    ratio=float(np.median(ada)/np.median(native))
    result=dict(name=name,steps=c['steps'],initial_constraints=int(contact_start),final_constraints=int(d.nefc),
                ada=stats(ada),c=stats(native),ada_over_c=ratio)
    if previous:
        result.update(baseline=stats(previous),ada_over_baseline=float(np.median(ada)/np.median(previous)),
                      paired_ada_over_baseline=(np.array(ada)/previous).tolist())
    results.append(result); print(name,'Ada/C',round(ratio,3),flush=True)
assert before==sources(),'source changed during timings'
manifest=dict(reference=mujoco.__version__,host=platform.platform(),machine=platform.machine(),
    baseline_binary_sha256=hashlib.sha256(a.baseline_probe.read_bytes()).hexdigest() if a.baseline_probe else None,
    current_binary_sha256=hashlib.sha256(exe.read_bytes()).hexdigest(),
    c_settings=dict(solver='PGS',jacobian='auto',iterations=10000,tolerance=1e-14,warmstart=False),
    load_before=load_before,load_after=Path('/proc/loadavg').read_text().strip(),
    timing_scope='200-step trajectories; input, reset, initialization, process startup and I/O excluded',
    compiler_versions=json.loads((a.out/'build/build-release.json').read_text())['toolchains'],
    harness_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in Path(__file__).parent.glob('*.py')},
    cpu=Path('/proc/cpuinfo').read_text().split('model name')[1].splitlines()[0].strip(':\t '),
    native_library_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in Path(mujoco.__file__).parent.glob('libmujoco.so*')},
    sources=before,results=results)
(a.out/'benchmark.json').write_text(json.dumps(manifest,indent=2)+'\n')
