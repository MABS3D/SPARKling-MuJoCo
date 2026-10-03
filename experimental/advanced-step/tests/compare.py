"""Full owned-model/force/Euler comparison against official MuJoCo 3.14.0."""
import argparse, hashlib, itertools, json, subprocess, re
from pathlib import Path
import mujoco
import numpy as np

def model(act, body=None, flags='', timestep='.0005'):
    act=re.sub(r' actearly="(?:true|false)"', '', act)
    act=re.sub(r'<orientation ([^>]*)input="vel"([^>]*)/>',r'<general \1input="expmap"\2 dyntype="integrator" gaintype="so3" biastype="so3" actdim="3"/>',act)
    def servo(m):
        attrs=m.group(1);kp=re.search(r'kp="([^"]+)"',attrs);kv=re.search(r'kv="([^"]+)"',attrs)
        attrs=re.sub(r' (?:kp|kv)="[^"]+"','',attrs)
        return '<general '+attrs+' gainprm="'+(kp[1] if kp else '0')+'" biasprm="0 '+str(-float(kp[1]) if kp else 0.)+' '+str(-float(kv[1]) if kv else 0.)+'"/>'
    act=re.sub(r'<general ([^>]*gaintype="so3"[^>]*)/>',servo,act)
    body=body or '<body><joint name="j" damping=".01"/><geom size=".1" mass="1"/></body>'
    act=re.sub(r'<dcmotor ([^>]*)/>',lambda m: '<dcmotor '+re.sub(r' (?:forcelimited|forcerange)="[^"]+"','',m[1])+'/>',act)
    return f'<mujoco><option timestep="{timestep}" integrator="Euler" gravity="0 0 -9.81"><flag constraint="disable" {flags}/></option><worldbody>{body}</worldbody><actuator>{act}</actuator></mujoco>'

def fixtures():
    for joint,body in [('hinge',None),('slide','<body><joint name="j" type="slide"/><geom size=".1" mass="1"/></body>'),('ball','<body><joint name="j" type="ball"/><geom size=".1" mass="1"/></body>')]:
        gear='gear=".5 .2 -.3"' if joint=='ball' else 'gear=".7"'
        for integ,slew in [(False,False),(True,False),(False,True)]:
            for early in [False,True]:
                yield f'pid_{joint}_{int(integ)}{int(slew)}_{int(early)}',model(f'<pid joint="j" {gear} kp="3" kv=".4" ki="{.7 if integ else 0}" imax=".5" slewmax="{2 if slew else 0}" input="pos vel ff" actearly="{str(early).lower()}" forcelimited="true" forcerange="-.2 .2"/>',body)
    for electrical,integ,thermal,bristle,slew in itertools.product([False,True],repeat=5):
        extra=('inductance="0 .02" ' if electrical else '')+('thermal="2 10 0 .003 20 20" ' if thermal else '')+('lugre="30 .1 .2 .3 .1" ' if bristle else '')
        for early in [False,True]:
            act=f'<dcmotor joint="j" motorconst=".2" resistance="2" input="pos vel ff voltage" controller=".5 {.8 if integ else 0} .2 {2 if slew else 0} .5 12" cogging=".05 3 .2" {extra} actearly="{str(early).lower()}" forcelimited="true" forcerange="-.05 .05"/>'
            yield 'dc_'+''.join(str(int(x)) for x in [electrical,integ,thermal,bristle,slew,early]),model(act)
    yield 'dc_passive',model('<dcmotor joint="j" motorconst=".2" resistance="2" input="none"/>')
    ball='<body><joint name="j" type="ball"/><geom size=".1" mass="1"/></body>'
    for chart,early in itertools.product(['quat','expmap','vel'],[False,True]):
        yield f'so3_joint_{chart}_{int(early)}',model(f'<orientation joint="j" kp="4" kv=".3" input="{chart}" actearly="{str(early).lower()}" forcelimited="true" forcerange="0 .08"/>',ball)
    sites='<body><joint name="root" type="ball"/><geom size=".1"/><site name="ref" quat=".9238795325 .3826834324 0 0"/><body pos=".2 .1 0"><joint name="j" type="ball"/><geom size=".1"/><site name="s" quat=".9659258263 0 .2588190451 0"/></body></body>'
    for chart in ['quat','expmap','vel']:
        yield 'so3_sites_'+chart,model(f'<orientation site="s" refsite="ref" kp="4" kv=".3" input="{chart}" forcelimited="true" forcerange="0 .08"/>',sites)
    mixed=ball+'<body pos=".3 0 0"><joint name="s" type="slide"/><geom size=".1"/></body>'
    acts='<motor joint="s" gear=".2"/><general joint="s" dyntype="filterexact" dynprm=".02" gainprm=".4"/><pid joint="s" kp="3" kv=".4" ki=".7" imax=".5" input="pos vel ff"/><dcmotor joint="s" motorconst=".2" resistance="2" input="voltage" inductance="0 .02"/><orientation joint="j" kp="4" kv=".3" input="vel"/>'
    yield 'mixed_blocks',model(acts,mixed)
    yield 'global_disabled',model(acts,mixed,flags='actuation="disable"')
    yield 'clamp_disabled',model('<pid joint="j" kp="3" ki=".5" input="pos vel ff" ctrllimited="true" ctrlrange="-.03 .03"/>',flags='clampctrl="disable"')
    yield 'clamp_enabled',model('<pid joint="j" kp="3" ki=".5" input="pos vel ff" ctrllimited="true" ctrlrange="-.03 .03"/>')
    yield 'muscle_mixed',model('<muscle joint="j" lengthrange="-1 1"/><pid joint="j" kp=".3" ki=".1" input="pos"/>')
    for chart in ['expmap','vel']:
        yield 'so3_reanchor_'+chart,model(f'<orientation joint="j" kp=".4" input="{chart}"/>',ball)
    yield 'many_blocks',model(''.join('<pid joint="j" kp=".003" ki=".001" input="pos vel ff"/>' for _ in range(64)))
    yield 'group_disabled',model('<dcmotor joint="j" group="2" motorconst=".2" resistance="2" input="voltage" inductance="0 .02" lugre="30 .1 .2 .3 .1"/>')

def parse(text):
    records=[];current=None
    for line in text.splitlines():
        fields=line.split()
        if not fields:continue
        if fields[0]=='evaluate':
            current={'evaluate':fields[1]};records.append(current)
        elif current is not None and fields[0]=='step':current['step']=fields[1]
        elif current is not None and fields[0] in ['length','velocity','force','qforce','acc','dot','state']:
            current[fields[0]]=np.array([float(x) for x in fields[1:]])
    assert text.rstrip().endswith('lifecycle PASS'),text[-2400:]
    return records

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',required=True,type=Path);p.add_argument('--out',required=True,type=Path);p.add_argument('--samples',default=8,type=int);p.add_argument('--steps',default=100,type=int);p.add_argument('--only');args=p.parse_args()
    assert mujoco.__version__=='3.14.0';args.out.mkdir(parents=True,exist_ok=False)
    rng=np.random.default_rng(261002);records=[];failures=[];models=0
    for name,xml in fixtures():
        if args.only and args.only not in name:continue
        m=mujoco.MjModel.from_xml_string(xml)
        if name.startswith(('pid_', 'dc_', 'so3_joint_')) and name[-1:] in ['0','1']:m.actuator_actearly[:]=int(name[-1])
        if name.startswith('dc_') and name!='dc_passive':m.actuator_forcelimited[:]=1;m.actuator_forcerange[:]=[-.05,.05]
        if name=='group_disabled':m.opt.disableactuator=4
        path=args.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(args.out/(name+'.xml')).write_text(xml);models+=1
        lines=[str(args.samples)];expected=[]
        for sample in range(args.samples):
            d=mujoco.MjData(m);q=m.qpos0.copy();mujoco.mj_integratePos(m,q,rng.uniform(-1,1,m.nv),.03)
            if sample==0:q=m.qpos0.copy()
            d.qpos[:]=q;d.qvel[:]=rng.uniform(-.2,.2,m.nv);d.ctrl[:]=rng.uniform(-.15,.15,m.nu);d.act[:]=rng.uniform(-.02,.02,m.na)
            if name.startswith('so3_reanchor'):
                if m.na:d.act[:]=[7.4,0,0]
                else:d.ctrl[:]=[7.4,0,0]
            if sample==0 and name.startswith('so3_joint_quat'):d.ctrl[:]=0
            d.qfrc_applied[:]=rng.uniform(-.002,.002,m.nv);d.xfrc_applied[:]=rng.uniform(-.001,.001,(m.nbody,6));d.time=.125
            steps=args.steps if sample%2==0 else 1
            lines.append(' '.join(format(float(x),'.17g') for x in [steps,d.time,*d.qpos,*d.qvel,*d.ctrl,*d.act,*d.qfrc_applied,*d.xfrc_applied.ravel()]))
            mujoco.mj_forward(m,d)
            ref={k:getattr(d,v).copy() for k,v in [('length','actuator_length'),('velocity','actuator_velocity'),('force','actuator_force'),('qforce','qfrc_actuator'),('acc','qacc'),('dot','act_dot')]}
            for _ in range(steps):mujoco.mj_step(m,d)
            ref['state']=np.r_[d.qpos,d.qvel,d.time,d.act];expected.append(ref)
            assert not np.any(d.warning.number),(name,d.warning)
        data='\n'.join(lines)+'\n';(args.out/(name+'.input')).write_text(data)
        run=subprocess.run([str(args.binary),str(path),'loads'],input=data,text=True,capture_output=True,timeout=180)
        (args.out/(name+'.output')).write_text(run.stdout+run.stderr)
        try:
            assert run.returncode==0,run.stdout[-3000:]+run.stderr
            actual=parse(run.stdout);assert len(actual)==len(expected)
            for i,(got,want) in enumerate(zip(actual,expected)):
                assert got['evaluate']==got['step']=='SUCCESS',(got.get('evaluate'),got.get('step'))
                errors={};passed=True
                for k,v in want.items():
                    shape=got[k].shape==v.shape
                    ok=shape and np.allclose(got[k],v,atol=2e-10,rtol=2e-10)
                    errors[k]=dict(passed=bool(ok),max_abs=float(np.max(np.abs(got[k]-v))) if shape and v.size else 0.)
                    passed=passed and ok
                record=dict(model=name,sample=i,passed=bool(passed),errors=errors);records.append(record)
                if not passed:failures.append(record)
        except Exception as e:failures.append(dict(model=name,error=str(e)))
        print(name,'FAIL' if any(x['model']==name for x in failures) else 'PASS',flush=True)
    result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),models=models,cases=len(records),passed=sum(x['passed'] for x in records),failures=failures,records=records)
    (args.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'failures',len(failures))
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
