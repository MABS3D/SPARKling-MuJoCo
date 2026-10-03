#!/usr/bin/env python3
"""Compare compiler address passes, including native-engine resolved layouts."""
import argparse
import hashlib
import json
from pathlib import Path
import random
import subprocess

HERE = Path(__file__).resolve().parent

def execute(binary, records):
    run = subprocess.run([str(binary)], input='\n'.join(records)+'\n',
        text=True, capture_output=True, timeout=90)
    if run.returncode: raise RuntimeError(run.stdout[-2000:]+run.stderr[-2000:])
    return [line.split() for line in run.stdout.splitlines()]

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    args=p.parse_args();args.out.mkdir(parents=True,exist_ok=False)
    rng=random.Random(20261002);records=[];expected_engine=[]
    for n in [0,1,2,3,7,8,31,32,127,128,511,512,4096,131072]:
        for kind in range(4): records.append(f'J {n} '+' '.join([str(kind)]*n))
    for _ in range(600):
        n=rng.randrange(513);records.append(f'J {n} '+' '.join(str(rng.randrange(4)) for _ in range(n)))
    for n in [0,1,2,3,7,8,31,32,127,128,511,512,4096]:
        for widths in [(0,0,0),(1,1,0),(1,1,1),(3,2,7),(0,2,3),(2,0,0)]:
            records.append(f'A {n} '+' '.join(' '.join(map(str,widths)) for _ in range(n)))
    for _ in range(600):
        n=rng.randrange(513);records.append(f'A {n} '+' '.join(str(rng.randrange(17)) for _ in range(3*n)))
    maximum=(1<<27)-1
    for component in range(3):
        for over in [0,1,2]:
            widths=[0]*6;widths[component]=maximum;widths[component+3]=over
            records.append('A 2 '+' '.join(map(str,widths)))
    for n in [0,1,2,31,128,4096,131072]:
        for mode in ['none','all','mixed']:
            flags=[0 if mode=='none' else 1 if mode=='all' else rng.randrange(2) for _ in range(n)]
            records.append(f'M {n} '+' '.join(map(str,flags)))
        records.append(f'O {n}')
    for _ in range(160):
        n=rng.randrange(257);records.append(f'M {n} '+' '.join(str(rng.randrange(2)) for _ in range(n)))
    for computed in [-1,0,1,7,maximum]:
        for declared in [-1,0,1,7,maximum]:
            for dyn in [0,1]: records.append(f'R 1 {computed} {declared} {dyn}')
    import mujoco
    assert mujoco.__version__=='3.14.0'
    for seed in range(48):
        r=random.Random(seed);joints=[];bodies=[];actuators=[]
        for i in range(1+r.randrange(12)):
            kind=r.choice(['hinge','slide','ball','free'])
            j=f'<freejoint name="j{i}"/>' if kind=='free' else f'<joint name="j{i}" type="{kind}"/>'
            bodies.append(f'<body pos="{i} 0 0">{j}<geom type="sphere" size=".1" mass="1"/></body>')
            # Explicit gain/bias and activation dimensions are resolved upstream.
            if kind in ['hinge','slide']:
                dyn=r.choice(['none','integrator','filter','filterexact'])
                actuators.append(f'<general joint="j{i}" dyntype="{dyn}" dynprm=".1"/>')
        xml='<mujoco><worldbody>'+''.join(bodies)+'</worldbody><actuator>'+''.join(actuators)+'</actuator></mujoco>'
        m=mujoco.MjModel.from_xml_string(xml)
        idx=len(records);records.append('J '+str(m.njnt)+' '+' '.join(map(str,m.jnt_type)))
        expected_engine.append((idx,['SUCCESS',str(m.nq),str(m.nv)]+[str(int(x)) for q,v in zip(m.jnt_qposadr,m.jnt_dofadr) for x in (q,v)]))
        idx=len(records);records.append('A '+str(m.nactuator)+' '+' '.join(str(int(x)) for row in zip(m.actuator_ctrlnum,m.actuator_outnum,m.actuator_actnum) for x in row))
        expected_engine.append((idx,['SUCCESS',str(m.nu),str(m.nout),str(m.na)]+[str(int(x)) for row in zip(m.actuator_ctrladr,m.actuator_outadr,m.actuator_actadr) for x in row]))
    for n in range(16):
        bodies=''.join(f'<body name="b{i}" pos="{i} 0 0" mocap="true"><geom type="sphere" size=".1"/></body>' for i in range(n))
        m=mujoco.MjModel.from_xml_string('<mujoco><worldbody>'+bodies+'</worldbody></mujoco>')
        idx=len(records);records.append('M '+str(m.nbody)+' '+' '.join(str(int(x>=0)) for x in m.body_mocapid))
        expected_engine.append((idx,['SUCCESS',str(m.nmocap)]+[str(int(x)) for x in m.body_mocapid]))
    cc=Path('/var/tmp/sparkling-matrix-recovery/toolchains/gnat')
    compiler=next(cc.glob('*/bin/gcc'));oracle=args.out/'oracle'
    subprocess.run([str(compiler),'-O2','-std=c99',str(HERE/'reference.c'),'-o',str(oracle)],check=True)
    expected=execute(oracle,records);actual=execute(args.binary,records)
    assert len(expected)==len(actual)==len(records)
    failures=[i for i,(a,b) in enumerate(zip(actual,expected)) if a!=b]
    engine_failures=[i for i,b in expected_engine if actual[i]!=b]
    report=dict(reference='MuJoCo 3.14.0 SaveDofOffsets',cases=len(records),
        passed=len(records)-len(failures),engine_layouts=len(expected_engine),
        failures=failures,engine_failures=engine_failures,
        binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
        reference_sha256=hashlib.sha256((HERE/'reference.c').read_bytes()).hexdigest())
    (args.out/'inputs.txt').write_text('\n'.join(records)+'\n')
    (args.out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({**report,'failures':failures[:10],'engine_failures':engine_failures[:10]}))
    if failures or engine_failures: raise SystemExit(1)

if __name__=='__main__':main()
