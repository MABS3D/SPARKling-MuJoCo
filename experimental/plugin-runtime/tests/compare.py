"""Real C plugin callbacks on full trajectories, not C-generated forces fed to Ada."""
import argparse, ctypes, hashlib, json, os, subprocess
from pathlib import Path
import mujoco
import numpy as np
HERE=Path(__file__).resolve().parent
def reference(out):
    package=Path(mujoco.__file__).parent
    library=next(package.glob('libmujoco.so.*'))
    command=['gcc','-O2','-fPIC','-shared','-ffp-contract=off','-I'+str(package/'include'),str(HERE/'reference.c'),str(library),'-Wl,-rpath,'+str(package),'-o',str(out/'reference.so')]
    subprocess.run(command,check=True,capture_output=True)
    plugin=ctypes.CDLL(str(out/'reference.so'));plugin.register_reference.restype=ctypes.c_int
    assert plugin.register_reference()>=0
    return plugin, dict(command=command,library=str(library),library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),source_sha256=hashlib.sha256((HERE/'reference.c').read_bytes()).hexdigest())
def model(stage, active=False, disabled='', limited=False, multi=False, joint='slide'):
    name='spark.test.multi' if multi else 'spark.test.sensor.'+['none','pos','vel','acc'][stage]
    extensions=('<plugin plugin="spark.test.passive"><instance name="p"><config key="k" value="1.7"/><config key="d" value=".3"/></instance></plugin>'
       '<plugin plugin="spark.test.actuator"><instance name="a"><config key="gain" value="2.3"/><config key="dot" value=".3"/></instance></plugin>') if not multi else ''
    extensions+=f'<plugin plugin="{name}"><instance name="s"><config key="k" value="1.7"/><config key="d" value=".3"/><config key="gain" value="2.3"/><config key="dot" value=".3"/></instance></plugin>'
    jointxml=f'<joint type="{joint}" axis="1 0 0" damping=".12" stiffness=".8"/>'
    instance='s' if multi else 'a'
    dynamic='dyntype="user" actdim="1"' if active else ''
    limit='forcelimited="true" forcerange="-.4 .4"' if limited else ''
    flag='<flag constraint="disable" '+disabled+'/>'
    return f'<mujoco><extension>{extensions}</extension><option timestep=".002" gravity="0 0 0">{flag}</option><worldbody><body>{jointxml}<geom type="box" size=".1 .2 .3" mass="2"/></body></worldbody><actuator><plugin instance="{instance}" joint="0" gear="1.4" {dynamic} {limit}/><motor joint="0" gear=".7"/></actuator><sensor><plugin instance="s" cutoff=".25"/></sensor></mujoco>'.replace('joint="0"','joint="j"').replace(f'type="{joint}" axis=',f'name="j" type="{joint}" axis=')
def configurations(m, stage, active, multi):
    masks=[7] if multi else [4,1,2]
    result=[]
    for i,mask in enumerate(masks):
        params=[0.0]*16;params[0]=1.7;params[1]=.3;params[2]=2.3;params[4]=0;params[5]=0
        params[8]=0 if active and mask&1 else -1;params[9]=.3
        result.append((mask,3 if multi else stage if mask==2 else 0,params))
    return result
def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=4);a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False);plugin,ref=reference(a.out);rng=np.random.default_rng(241002);records=[];failures=[]
    cases=[]
    for stage in range(4):
        for active in [False,True]:
            for joint in ['slide','hinge']:
                for steps in [0,1,100]:cases.append((stage,active,'',False,False,joint,steps))
    for disabled in ['sensor="disable"','actuation="disable"','spring="disable" damper="disable"']:
        cases.append((3,True,disabled,False,False,'slide',100))
    cases += [(3,True,'',True,False,'slide',100),(3,True,'',False,True,'slide',100)]
    for idx,(stage,active,disabled,limited,multi,joint,steps) in enumerate(cases):
        xml=model(stage,active,disabled,limited,multi,joint);m=mujoco.MjModel.from_xml_string(xml)
        modelpath=a.out/f'{idx:03d}.mjb';mujoco.mj_saveModel(m,str(modelpath));(a.out/f'{idx:03d}.xml').write_text(xml)
        configs=configurations(m,stage,active,multi)
        for sample in range(a.samples):
            q=rng.uniform(-.3,.3,m.nq);v=rng.uniform(-.2,.2,m.nv);u=rng.uniform(-.7,.7,m.nu);act=rng.uniform(-.2,.2,m.na);applied=rng.uniform(-.2,.2,m.nv)
            d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.ctrl[:]=u;d.act[:]=act;d.qfrc_applied[:]=applied
            mujoco.mj_forward(m,d);acc=d.qacc.copy()
            for _ in range(steps):mujoco.mj_step(m,d)
            expected=[acc,np.r_[d.qpos,d.qvel,d.time],d.act.copy(),d.sensordata.copy(),d.actuator_force.copy()]
            expected += [d.plugin_state[m.plugin_stateadr[i]:m.plugin_stateadr[i]+m.plugin_statenum[i]].copy() for i in range(m.nplugin)]
            values=[str(steps)]
            for mask,needed,params in configs:values += [str(mask),str(needed)]+[format(x,'.17g') for x in params]
            values += [format(x,'.17g') for x in np.r_[q,v,u,act,applied]]
            run=subprocess.run([str(a.binary),str(modelpath)],input=' '.join(values)+'\n',text=True,capture_output=True,timeout=30)
            if run.returncode:
                raise RuntimeError(f'case {idx} sample {sample}: '+run.stdout[-2000:]+run.stderr[-1500:])
            actual=[np.fromstring(line,sep=' ') for line in run.stdout.splitlines()]
            errors=[]
            if len(actual)!=len(expected):raise RuntimeError(run.stdout[:2000])
            for j,(x,y) in enumerate(zip(actual,expected)):
                x=x[:len(y)]
                errors.append(dict(field=j,maximum=float(np.max(abs(x-y))) if len(y) else 0.0,passed=bool(np.allclose(x,y,atol=2e-10,rtol=2e-10))))
            ok=all(e['passed'] for e in errors);record=dict(case=idx,sample=sample,steps=steps,stage=stage,active=active,disabled=disabled,multi=multi,joint=joint,passed=ok,errors=errors);records.append(record)
            if not ok:failures.append(record)
        print(idx,'PASS' if all(r['passed'] for r in records if r['case']==idx) else 'FAIL',flush=True)
    result=dict(reference=mujoco.__version__,oracle=ref,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),cases=len(records),passed=sum(r['passed'] for r in records),failures=failures,records=records)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'])
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
