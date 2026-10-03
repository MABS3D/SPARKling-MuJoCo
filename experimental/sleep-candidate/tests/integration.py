#!/usr/bin/env python3
"""Native MJB/owned-state trajectories, sleep and wake compared with MuJoCo C."""
import argparse,hashlib,json,re,subprocess
from pathlib import Path
import mujoco
import numpy as np
def xml(kind,n,policy='allowed',gravity=False,damping=0.):
    bodies=[]
    for i in range(n):
        j='<freejoint/>' if kind=='free' else f'<joint type="{kind}" damping="{damping}"/>'
        bodies.append(f'<body pos="{i*2} 0 1" sleep="{policy}">{j}<geom type="box" size=".1 .1 .1" mass="1"/></body>')
    return '<mujoco><option timestep=".002" sleep_tolerance=".001" gravity="'+('0 0 -9.81' if gravity else '0 0 0')+'"><flag sleep="enable" constraint="disable"/></option><worldbody>'+''.join(bodies)+'</worldbody></mujoco>'
def fixtures():
    for kind in ['slide','hinge','ball','free']:
        for n in [1,4,16]:
            for policy in ['allowed','never','init']:
                yield f'{kind}-{n}-{policy}',xml(kind,n,policy),kind,False
    for kind in ['slide','free']:
        yield f'{kind}-gravity',xml(kind,4,gravity=True),kind,True
    yield 'damping',xml('slide',4,damping=2.),'slide',False
def suite(model,kind,gravity):
    d=mujoco.MjData(model);ops=[]
    for _ in range(16):ops.append([0])
    q=model.qpos0.copy();v=np.zeros(model.nv)
    if kind in ['hinge','slide']:q[0]+=.1
    elif kind=='free':q[0]+=.1
    else:q[:4]=[np.cos(.05),np.sin(.05),0,0]
    ops.extend([[1,float(d.time),*q,*v],[0]])
    ops.extend([[2,0,1.],[0],[0],[2,0,0.]])
    ops.extend([[0]]*16)
    ops.extend([[4,1,1.,0.,0.,0.,0.,0.],[0],[0],[4,1,0.,0.,0.,0.,0.,0.]])
    ops.extend([[0]]*16)
    # Exact byte-zero perturbations should wake even at tiny magnitude.
    ops.extend([[2,0,-0.],[0],[2,0,0.],[0],[5,0],[0],[5,1],[0],[6],[0]])
    return ops
def oracle(m,ops):
    d=mujoco.MjData(m);records=[]
    for op in ops:
        kind=op[0]
        if kind==0:mujoco.mj_step(m,d)
        elif kind==1:d.time=op[1];d.qpos[:]=op[2:2+m.nq];d.qvel[:]=op[2+m.nq:]
        elif kind==2:d.qfrc_applied[op[1]]=op[2]
        elif kind==3:d.ctrl[op[1]]=op[2]
        elif kind==4:d.xfrc_applied[op[1]]=op[2:]
        elif kind==5:
            if op[1]:m.opt.enableflags|=int(mujoco.mjtEnableBit.mjENBL_SLEEP)
            else:m.opt.enableflags&=~int(mujoco.mjtEnableBit.mjENBL_SLEEP)
        elif kind==6:mujoco.mj_resetData(m,d)
        records.append(np.concatenate([[0,d.nv_awake],d.qpos,d.qvel,[d.time],d.tree_asleep]))
    return records
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--binary',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);a=ap.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__=='3.14.0';records=[];failures=[]
    for name,source,kind,gravity in fixtures():
        m=mujoco.MjModel.from_xml_string(source);f=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(f));(a.out/(name+'.xml')).write_text(source)
        ops=suite(m,kind,gravity);data=str(len(ops))+'\n'+'\n'.join(' '.join(str(x) for x in op) for op in ops)+'\n';(a.out/(name+'.input')).write_text(data)
        p=subprocess.run([str(a.binary),str(f)],input=data,text=True,capture_output=True,timeout=120)
        (a.out/(name+'.output')).write_text(p.stdout+p.stderr)
        if p.returncode or p.stdout.startswith(('create','load')):
            failures.append(dict(name=name,error=p.stdout[-1000:]+p.stderr[-1000:]));records.append(dict(name=name,operations=len(ops),passed=False));print('FAIL',name,failures[-1]);continue
        actual=[np.array([float(x) for x in re.findall(r'[+-]?(?:\d+\.\d+(?:[Ee][+-]?\d+)?|\d+)',line)]) for line in p.stdout.splitlines()]
        expected=oracle(m,ops)
        if len(actual)!=len(expected):failures.append(dict(name=name,error='row count'));continue
        bad=[];maximum=0.
        for i,(x,y) in enumerate(zip(actual,expected)):
            if x.shape!=y.shape:bad.append(dict(step=i,error='shape',ada=x.tolist(),c=y.tolist()));continue
            numerical=np.allclose(x[2:2+m.nq+m.nv+1],y[2:2+m.nq+m.nv+1],atol=2e-10,rtol=2e-10)
            metadata=np.array_equal(x[:2],y[:2]) and np.array_equal(x[3+m.nq+m.nv:],y[3+m.nq+m.nv:])
            maximum=max(maximum,float(np.max(np.abs(x-y))))
            if not (numerical and metadata):bad.append(dict(step=i,operation=ops[i],ada=x.tolist(),c=y.tolist()))
        records.append(dict(name=name,operations=len(ops),passed=not bad,max_abs_error=maximum))
        if bad:failures.append(dict(name=name,errors=bad[:5]));print('FAIL',name,'count',len(bad),'first',bad[0],flush=True)
        else:print(name,'PASS',flush=True)
        if len(failures)>=5:break
    result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),cases=len(records),passed=sum(r['passed'] for r in records),operations=sum(r['operations'] for r in records),records=records,failures=failures)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'operations',result['operations']);raise SystemExit(bool(failures))
if __name__=='__main__':main()
