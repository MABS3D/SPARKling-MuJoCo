#!/usr/bin/env python3
"""Alternating full-step timings for the standalone Cartesian edge subset.
The C engine does extra generic model/BVH bookkeeping. Results are subset-only.
"""
import argparse
import json
import os
from pathlib import Path
import platform
import subprocess
import xml.etree.ElementTree as ET
import numpy as np
import mujoco
from compare import build, digest, payload, parse, xml_model, REPO


def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--toolchain-root',type=Path,required=True)
    ap.add_argument('--c-build',type=Path,required=True,help='Recorded native C build JSON')
    ap.add_argument('--blocks',type=int,default=12)
    ap.add_argument('--cpu',type=int,default=8)
    ap.add_argument('--steps',type=int,default=1000)
    ap.add_argument('--build-only',action='store_true')
    ap.add_argument('--reuse',action='store_true')
    args=ap.parse_args();args.out=args.out.resolve();args.out.mkdir(parents=True,exist_ok=True)
    if mujoco.__version__ != '3.14.0':
        raise RuntimeError('The reference must be MuJoCo 3.14.0')
    if args.blocks < 2 or args.steps < 1:
        raise ValueError('At least two blocks and one step are required')
    host_load_start = os.getloadavg()
    if args.reuse:
        manifest=json.loads((args.out/'benchmark-build.json').read_text())
        ada=Path(manifest['ada']); c=Path(manifest['c'])
        assert digest(ada)==manifest['ada_sha256'] and digest(c)==manifest['c_sha256']
    else:
        ada=build(args.out,args.toolchain_root,release=True)
        ref=json.loads(args.c_build.read_text())['builds']['c']
        c=args.out/'elastic_c'; command=ref['command'].copy()
        source=REPO/'experimental/deformable/tests/elastic_bench.c'
        command=[str(source) if x.endswith('/movement_c.c') else x for x in command]
        command[-1]=str(c)
        command.insert(command.index('-o'), '-Wl,--disable-new-dtags')
        subprocess.run(command,check=True,capture_output=True,text=True)
        manifest=dict(ada=str(ada),ada_sha256=digest(ada),c=str(c),c_sha256=digest(c),
          c_command=command,c_source_sha256=digest(source),reference=ref,
          platform=platform.platform(),cpu=Path('/proc/cpuinfo').read_text(),
          cpu_affinity=args.cpu,steps=args.steps,blocks=args.blocks,
          harness_sha256=digest(__file__))
        (args.out/'benchmark-build.json').write_text(json.dumps(manifest,indent=2))
    if args.build_only:return
    os.chdir(args.out)
    rng=np.random.default_rng(27102026); records=[]; summaries=[]
    for n in (4,16,64,128):
        base=np.array([[.04*i, .01*np.sin(i), .01*np.cos(i)] for i in range(n)])
        mass=np.ones(n);pin=np.zeros(n,dtype=bool);pin[0]=True
        edges=[(i,i+1) for i in range(n-1)]
        k=np.full(n-1,20.);damp=np.full(n-1,.2)
        gravity=np.array([0.,0.,-9.81]);dt=.0005
        # One flex with many edges: do not penalize C with one flex per edge.
        root=ET.fromstring(xml_model(base,mass,pin,edges,k,damp,gravity,dt))
        deform=root.find('deformable');deform.clear()
        flex=ET.SubElement(deform,'flex',name='net',dim='1',radius='.001',
          body=' '.join(f'v{i}' for i in range(n)),vertex=' '.join(['0']*(3*n)),
          element=' '.join(str(v) for e in edges for v in e))
        ET.SubElement(flex,'edge',stiffness='20',damping='.2')
        ET.SubElement(flex,'contact',contype='0',conaffinity='0',selfcollide='none')
        xml=ET.tostring(root,encoding='unicode');xml_path=args.out/f'chain-{n}.xml';xml_path.write_text(xml)
        m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m)
        mjb_path=args.out/f'chain-{n}.mjb'
        mujoco.mj_saveModel(m,str(mjb_path))
        pos=base+rng.uniform(-.005,.005,(n,3));pos[pin]=base[pin]
        vel=rng.uniform(-.03,.03,(n,3));vel[pin]=0
        applied=rng.uniform(-.1,.1,(n,3))
        for v in range(1,n):
            a=m.body_dofadr[v+1]
            d.qpos[a:a+3]=pos[v]-base[v];d.qvel[a:a+3]=vel[v];d.qfrc_applied[a:a+3]=applied[v]
        mujoco.mj_forward(m,d);pos=d.xpos[1:].copy()
        inputs={'ada':payload(pos,vel,mass,pin,edges,m.flexedge_length0,k,damp,applied,gravity,dt,args.steps),
                'c':' '.join(map(str,np.r_[d.qpos,d.qvel,d.qfrc_applied]))+'\n'}
        for variant,value in inputs.items():(args.out/f'chain-{n}.{variant}.input').write_text(value)
        paired=[]
        for b in range(args.blocks):
            outputs={};medians={}
            for variant in (('ada','c') if b%2==0 else ('c','ada')):
                cmd=[str(ada),'3'] if variant=='ada' else [str(c),str(mjb_path),str(args.steps),'3']
                proc=subprocess.run(['taskset','-c',str(args.cpu),*cmd],input=inputs[variant],
                                    text=True,capture_output=True)
                (args.out/f'chain-{n}-{b}-{variant}.stderr').write_text(proc.stderr)
                proc.check_returncode()
                (args.out/f'chain-{n}-{b}-{variant}.output').write_text(proc.stdout)
                result=parse(proc.stdout);outputs[variant]=result
                times=np.array(result['timing']).ravel()/args.steps*1e6
                medians[variant]=float(np.median(times))
                records.append(dict(n=n,block=b,variant=variant,microseconds=times.tolist()))
            for key in ('position','velocity'):
                np.testing.assert_allclose(outputs['ada'][key],outputs['c'][key],atol=2e-9,rtol=2e-9)
            paired.append(medians['ada']/medians['c'])
        stats={}
        for variant in ('ada','c'):
            a=np.array([r['microseconds'] for r in records if r['n']==n and r['variant']==variant]).ravel()
            stats[variant]={key:float(np.quantile(a,q)) for key,q in [('p10',.1),('median',.5),('p90',.9),('p99',.99)]}
        bootstrap=np.median(rng.choice(paired,size=(10000,len(paired)),replace=True),axis=1)
        stats.update(n=n,ratio=float(np.median(paired)),ratio_ci95=np.quantile(bootstrap,[.025,.975]).tolist())
        summaries.append(stats);print(json.dumps(stats),flush=True)
    result=dict(run=dict(blocks=args.blocks,steps=args.steps,cpu=args.cpu,
                host_load_start=host_load_start,host_load_end=os.getloadavg()),scope='Cartesian particles and flex edge springs/dampers; not whole MuJoCo parity',
                records=records,summary=summaries)
    (args.out/'timings.json').write_text(json.dumps(result,indent=2))
if __name__=='__main__':main()
