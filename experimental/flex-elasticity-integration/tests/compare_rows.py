"""Isolated FLEX row producer against rows assembled by the native C engine.

The Ada probe uses the smooth factory only for kinematics. It does not integrate
the generated equality forces, so this corpus cannot establish full flex-step
support, solver compatibility, or performance.
"""
import argparse, hashlib, json, subprocess
from pathlib import Path
import xml.etree.ElementTree as ET
import mujoco
import numpy as np
from compare import fixture, numbers

def fixtures():
    def constrain(tree):
        equalities=ET.SubElement(tree,'equality')
        for flex in tree.findall('./deformable/flex'):
            flex.find('edge').set('stiffness','0')
            if flex.find('elasticity') is not None:flex.find('elasticity').set('young','0')
            ET.SubElement(equalities,'flex',{'flex':flex.attrib['name']})
    for dim in (1,2,3):
        for name,kw in [('slides',{}),('shared',dict(shared=True,pinned=True)),
                        ('rotated',dict(rotated=True)),('free',dict(free=True))]:
            tree=ET.fromstring(fixture(dim=dim,edge=True,mode='stretch' if dim==2 else 'none',**kw))
            constrain(tree)
            yield f'dim{dim}_{name}',ET.tostring(tree,encoding='unicode')
    tree=ET.fromstring(fixture(dim=1,edge=True,count=2,shared=True,pinned=True))
    constrain(tree)
    xml=ET.tostring(tree,encoding='unicode')
    yield 'multiple',xml
    yield 'inactive_first',xml
    tree.find('option/flag').set('equality','disable')
    yield 'equality_disabled',ET.tostring(tree,encoding='unicode')

def parse(output):
    result=[]
    for line in output.splitlines():
        if line.startswith('case'): result.append({})
        elif result:
            key,_,data=line.partition(' ')
            if key in ('ids','pos','weight','rowadr','rownnz','columns','values','atomic_capacity'):
                result[-1][key]=np.fromstring(data,sep=' ')
    return result

def native_edge_weights(m,d,mode):
    # MuJoCo 3.14 keeps diagApprox as scratch, not a public MjData field.
    # Verify ownership/mapping against the compiled weight copied by the C
    # mjEQ_FLEX branch; the remaining fields below come from assembled efc.
    if int(m.opt.disableflags)&int(mujoco.mjtDisableBit.mjDSBL_EQUALITY):return np.array([])
    weights=[]
    for eq in range(m.neq):
        if not d.eq_active[eq]:continue
        f=int(m.eq_obj1id[eq]);first=int(m.flex_edgeadr[f])
        for e in range(first,first+int(m.flex_edgenum[f])):
            if m.flexedge_rigid[e] or not m.flexedge_J_rownnz[e]:continue
            adr=int(m.flexedge_J_rowadr[e]);nnz=int(m.flexedge_J_rownnz[e])
            if mode=='dense' and not np.any(d.flexedge_J[adr:adr+nnz]):continue
            weights.append(m.flexedge_invweight0[e])
    assert len(weights)==d.nefc
    return np.asarray(weights)

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=8)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__=='3.14.0'
    rng=np.random.default_rng(2026100317);records=[];failures=[]
    for name,xml in fixtures():
        for mode in ('sparse','dense'):
            m=mujoco.MjModel.from_xml_string(xml)
            m.opt.jacobian=getattr(mujoco.mjtJacobian,'mjJAC_'+mode.upper())
            if name=='inactive_first':m.eq_active0[0]=0
            label=f'{name}_{mode}';file=a.out/(label+'.mjb')
            mujoco.mj_saveModel(m,str(file));(a.out/(label+'.xml')).write_text(xml)
            inputs=[];expected=[]
            m.opt.disableflags &= ~int(mujoco.mjtDisableBit.mjDSBL_CONSTRAINT)
            for i in range(a.samples):
                q=m.qpos0.copy();mujoco.mj_integratePos(m,q,rng.uniform(-.05,.05,m.nv),.3 if i else 0.)
                v=rng.uniform(-.04,.04,m.nv) if i else np.zeros(m.nv)
                inputs.extend([0.,*q,*v]);d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v
                mujoco.mj_forward(m,d)
                assert np.all(d.efc_type==int(mujoco.mjtConstraint.mjCNSTR_EQUALITY))
                item=dict(ids=d.efc_id.copy(),pos=d.efc_pos.copy(),weight=native_edge_weights(m,d,mode))
                item['atomic_capacity']=np.array([sum(np.count_nonzero(d.efc_id==eq)>1 for eq in range(m.neq))])
                if mode=='sparse':
                    item.update(rowadr=d.efc_J_rowadr.copy(),rownnz=d.efc_J_rownnz.copy(),
                                columns=d.efc_J_colind.copy(),values=d.efc_J.copy())
                else:item['dense_values']=d.efc_J.reshape(d.nefc,m.nv).copy()
                expected.append(item)
            data=f'{a.samples}\n'+numbers(inputs)+'\n';(a.out/(label+'.input')).write_text(data)
            run=subprocess.run([str(a.binary),str(file),mode],input=data,text=True,capture_output=True,timeout=120)
            (a.out/(label+'.output')).write_text(run.stdout+run.stderr);actual=parse(run.stdout)
            if run.returncode or len(actual)!=len(expected):
                failure=dict(model=label,error=(run.stdout+run.stderr)[-1800:]);failures.append(failure)
                print('FAIL',label,failure['error'],flush=True);continue
            for sample,(x,y) in enumerate(zip(actual,expected)):
                if mode=='dense':
                    n=len(x['ids']);dense=np.zeros((n,m.nv))
                    for r in range(n):
                        start=int(x['rowadr'][r]);end=start+int(x['rownnz'][r])
                        for k in range(start,end):dense[r,int(x['columns'][k])]=x['values'][k]
                    x['dense_values']=dense
                errors={}
                for key,target in y.items():
                    shape=x.get(key,np.array([])).shape==target.shape
                    exact=key in ('ids','rowadr','rownnz','columns','atomic_capacity')
                    ok=shape and (np.array_equal(x[key],target) if exact else
                                  np.allclose(x[key],target,atol=2e-10,rtol=2e-10))
                    delta=float(np.max(np.abs(x[key]-target))) if shape and target.size else 0.
                    errors[key]=dict(passed=bool(ok),max_abs=delta)
                record=dict(model=label,sample=sample,passed=all(e['passed'] for e in errors.values()),errors=errors)
                records.append(record)
                if not record['passed']:failures.append(record);print('FAIL',label,sample,errors,flush=True)
            print(label,'checked',flush=True)
    result=dict(reference=mujoco.__version__,scope='isolated FLEX row assembly, not full constrained flex step',
                binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                records=records,failures=failures,cases=len(records),passed=sum(r['passed'] for r in records))
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))
if __name__=='__main__':main()
