"""Actual FLEX equality movement: mixed source IDs, activity and C response.

All fields come from mj_forward/mj_step, with normal native SIMD. There is no
isolated row oracle or reference force supplied to the Ada engine.
"""
import argparse, hashlib, json, resource, subprocess
from pathlib import Path
import xml.etree.ElementTree as ET
import mujoco
import numpy as np
from compare import numbers
from compare_rows import fixtures as edge_fixtures
from compare_constrained import parse as contact_parse

def fixtures():
    for name,xml in edge_fixtures():
        tree=ET.fromstring(xml)
        flag=tree.find('option/flag')
        flag.attrib.pop('constraint',None)
        flag.set('warmstart','disable');flag.set('island','disable')
        yield name,ET.tostring(tree,encoding='unicode'),False
        if name=='multiple':
            yield 'runtime_toggle',ET.tostring(tree,encoding='unicode'),True
        if name=='dim1_slides':
            eq=tree.find('equality')
            eq.insert(0,ET.Element('joint',{'joint1':'j0_0_0'}))
            ET.SubElement(eq,'joint',{'joint1':'j0_2_1'})
            yield 'mixed_joint',ET.tostring(tree,encoding='unicode'),False
            tendons=ET.SubElement(tree,'tendon')
            fixed=ET.SubElement(tendons,'fixed',{'name':'t0'})
            ET.SubElement(fixed,'joint',{'joint':'j0_1_2','coef':'1'})
            eq.insert(1,ET.Element('tendon',{'tendon1':'t0'}))
            yield 'mixed_tendon',ET.tostring(tree,encoding='unicode'),False
            ET.SubElement(tree.find('worldbody'),'geom',
                {'type':'plane','size':'3 3 .1','pos':'0 0 -.008','condim':'3'})
            flex=tree.find('deformable/flex');flex.set('radius','.015')
            contact=flex.find('contact');contact.set('contype','1');contact.set('conaffinity','1')
            yield 'mixed_contact',ET.tostring(tree,encoding='unicode'),False

def parse(output):
    rows=contact_parse(output)
    index=-1
    for line in output.splitlines():
        if line.startswith('case'):index+=1
        elif index>=0:
            key,_,data=line.partition(' ')
            if key in ('eqids','force'):rows[index][key]=np.fromstring(data,sep=' ')
    return rows

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=3)
    p.add_argument('--steps',type=int,default=100);p.add_argument('--only')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(128*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    assert mujoco.__version__=='3.14.0'
    rng=np.random.default_rng(2026100318);records=[];failures=[];warnings=[]
    mujoco.set_mju_user_warning(warnings.append)
    for name,xml,toggle in fixtures():
        if a.only and a.only not in name:continue
        for solver in ('PGS','CG','Newton'):
            for mode in ('sparse','dense'):
                tree=ET.fromstring(xml);option=tree.find('option')
                option.set('solver',solver);option.set('jacobian',mode)
                option.set('iterations','200');option.set('tolerance','1e-12')
                label=f'{name}_{solver}_{mode}'
                text=ET.tostring(tree,encoding='unicode');m=mujoco.MjModel.from_xml_string(text)
                if name=='inactive_first':m.eq_active0[0]=0
                model=a.out/(label+'.mjb');mujoco.mj_saveModel(m,str(model))
                (a.out/(label+'.xml')).write_text(text)
                inputs=[];expected=[]
                for sample in range(a.samples):
                    d=mujoco.MjData(m)
                    mujoco.mj_integratePos(m,d.qpos,rng.uniform(-.03,.03,m.nv),.1 if sample else 0.)
                    d.qvel[:]=rng.uniform(-.015,.015,m.nv) if sample else 0.
                    d.qfrc_applied[:]=rng.uniform(-.02,.02,m.nv)
                    if toggle:d.eq_active[0]=(sample+1)%3!=2
                    inputs.extend([0.,*d.qpos,*d.qvel,*d.qfrc_applied,*d.ctrl,*d.act])
                    (a.out/(label+'.pending.input')).write_text(f'{sample+1} {a.steps}\n'+numbers(inputs)+'\n')
                    mujoco.mj_forward(m,d)
                    if mode=='sparse':
                        jac=np.zeros((d.nefc,m.nv))
                        for r in range(d.nefc):
                            start=int(d.efc_J_rowadr[r]);end=start+int(d.efc_J_rownnz[r])
                            jac[r,d.efc_J_colind[start:end]]=d.efc_J[start:end]
                    else:jac=d.efc_J.reshape(d.nefc,m.nv).copy()
                    eq=d.efc_type==int(mujoco.mjtConstraint.mjCNSTR_EQUALITY)
                    row=dict(counts=np.array([d.ncon,d.nefc]),eqids=d.efc_id[eq].copy(),
                        jac=jac.ravel(),aref=d.efc_aref.copy(),reg=d.efc_R.copy(),force=d.efc_force.copy(),
                        passive=d.qfrc_passive.copy(),free=d.qacc_smooth.copy(),acc=d.qacc.copy(),
                        constraint=d.qfrc_constraint.copy())
                    for _ in range(a.steps):mujoco.mj_step(m,d)
                    row['state']=np.r_[d.qpos,d.qvel,d.time,d.act];expected.append(row)
                data=f'{a.samples} {a.steps}\n'+numbers(inputs)+'\n'
                (a.out/(label+'.input')).write_text(data)
                (a.out/(label+'.expected.json')).write_text(json.dumps(
                    [{k:v.tolist() for k,v in row.items()} for row in expected],indent=2)+'\n')
                run=subprocess.run([str(a.binary),str(model),'diagnostic',*(['toggle'] if toggle else [])],
                    input=data,text=True,capture_output=True,timeout=180)
                (a.out/(label+'.output')).write_text(run.stdout+run.stderr);actual=parse(run.stdout)
                if run.returncode or len(actual)!=len(expected):
                    failure=dict(model=label,exit=run.returncode,error=(run.stdout+run.stderr)[-2200:])
                    failures.append(failure);print('FAIL',label,failure['error'],flush=True)
                else:
                    for sample,(x,y) in enumerate(zip(actual,expected)):
                        errors={}
                        for key,target in y.items():
                            shape=key in x and x[key].shape==target.shape
                            exact=key in ('counts','eqids')
                            ok=shape and (np.array_equal(x[key],target) if exact else
                                np.allclose(x[key],target,atol=2e-9,rtol=2e-9))
                            delta=float(np.max(np.abs(x[key]-target))) if shape and target.size else 0.
                            errors[key]=dict(passed=bool(ok),max_abs=delta)
                        record=dict(model=label,sample=sample,passed=all(e['passed'] for e in errors.values()),errors=errors)
                        records.append(record)
                        if not record['passed']:
                            failures.append(record);print('FAIL',label,sample,
                                {k:v for k,v in errors.items() if not v['passed']},flush=True)
                result=dict(reference=mujoco.__version__,steps=a.steps,cases=len(records),
                    passed=sum(r['passed'] for r in records),failures=failures,records=records,warnings=warnings,
                    binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                    runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                    fixture_source_sha256={str(Path(__file__).with_name(n)):hashlib.sha256(
                        Path(__file__).with_name(n).read_bytes()).hexdigest() for n in ('compare.py','compare_rows.py','compare_constrained.py')},
                    library_sha256=hashlib.sha256((Path(mujoco.__file__).parent/'libmujoco.so.3.14.0').read_bytes()).hexdigest())
                (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(label,'checked',flush=True)
    print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))
if __name__=='__main__':main()
