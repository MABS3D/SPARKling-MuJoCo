"""Full owned-model NoSlip trajectories; no C contacts/J/forces enter Ada."""
import argparse, hashlib, importlib.util, json, pathlib, subprocess
import mujoco
import numpy as np
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--binary',type=pathlib.Path,required=True)
    ap.add_argument('--snapshot',type=pathlib.Path,required=True);ap.add_argument('--out',type=pathlib.Path,required=True)
    ap.add_argument('--samples',type=int,default=4);ap.add_argument('--steps',type=int,default=100)
    ap.add_argument('--only')
    ap.add_argument('--jacobian',choices=['dense','sparse'],help='Set the same model option in both engines')
    a=ap.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    path=a.snapshot/'experimental/constrained-step/tests/compare.py'
    spec=importlib.util.spec_from_file_location('parent_comparison',path);ref=importlib.util.module_from_spec(spec);spec.loader.exec_module(ref)
    records=[];failures=[];rng=np.random.default_rng(19481002)
    for base,raw in ref.fixtures():
        for cone in ['pyramidal','elliptic']:
            for budget in [0,1,12]:
                name=f'{base}-{cone}-noslip{budget}'
                if a.only and a.only not in name:continue
                xml=raw.replace('cone="pyramidal"',f'cone="{cone}"').replace('iterations="200"',f'iterations="200" noslip_iterations="{budget}" noslip_tolerance="1e-12"')
                if a.jacobian:xml=xml.replace('jacobian="sparse"',f'jacobian="{a.jacobian}"')
                (a.out/(name+'.xml')).write_text(xml)
                try:
                    m=mujoco.MjModel.from_xml_string(xml)
                except ValueError as error:
                    failures.append(dict(name=name,reference_error=str(error)))
                    print('REFERENCE ERROR',name,str(error),flush=True)
                    continue
                f=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(f));inputs=[];refs=[]
                failures_before=len(failures)
                for sample in range(a.samples):
                    q=m.qpos0.copy()
                    if sample:mujoco.mj_integratePos(m,q,rng.uniform(-1,1,m.nv),.008)
                    if base=='ball_limit':q[:]=[np.cos(.11),0,np.sin(.11),0]
                    if base=='hinge_contact':q[:]=.11
                    v=rng.uniform(-.2,.2,m.nv);applied=rng.uniform(-.2,.2,m.nv)
                    ctrl=rng.uniform(-.2,.2,m.nu);loads=rng.uniform(-.2,.2,(m.nbody,6))
                    inputs.extend([0.,*q,*v,*applied,*ctrl,*loads.ravel()])
                    refs.append(ref.oracle(m,q,v,applied,a.steps,ctrl,loads))
                text=f'{a.samples} {a.steps}\n'+' '.join(format(x,'.17g') for x in inputs)+'\n'
                r=subprocess.run([str(a.binary),str(f),'loads'],input=text,text=True,capture_output=True,timeout=180)
                (a.out/(name+'.output')).write_text(r.stdout+r.stderr)
                if r.returncode or r.stdout.startswith('create'):
                    failures.append(dict(name=name,error=r.stdout[-1200:]));continue
                outputs=ref.parse(r.stdout,m.nv)
                if len(outputs) != len(refs):
                    failures.append(dict(name=name,error='sample count differs',actual=len(outputs),expected=len(refs)))
                    continue
                for i,(actual,expected) in enumerate(zip(outputs,refs)):
                    errors={}
                    for key in expected:
                        atol=2e-10 if key in ['counts','free','jac','aref','reg'] else 3e-6
                        delta=float(np.max(np.abs(actual[key]-expected[key]),initial=0))
                        errors[key]=dict(max_abs=delta,passed=bool(np.allclose(actual[key],expected[key],atol=atol,rtol=2e-12 if atol<1e-8 else 1e-8)))
                    ok=all(x['passed'] for x in errors.values());rec=dict(name=name,sample=i,errors=errors,passed=ok)
                    records.append(rec)
                    if not ok:failures.append(rec)
                if len(failures)>failures_before:print('FAIL',failures[-1],flush=True)
                if len(records)%80==0:print('checked',len(records),flush=True)
    result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                cases=len(records),passed=sum(r['passed'] for r in records),steps=a.steps,jacobian_override=a.jacobian,failures=failures,records=records)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('RESULT',result['passed'],result['cases'],'failures',len(failures),flush=True)
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
