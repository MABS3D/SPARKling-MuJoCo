"""Native MuJoCo 3.14.0 differential tests, including full-step derivatives."""
import argparse, ctypes, hashlib, importlib.util, json, subprocess
from pathlib import Path
import mujoco
import numpy as np

LIBRARY = Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'
LIB = ctypes.CDLL(str(LIBRARY))
for name in ['mjd_smooth_velFD', 'mjd_passive_velFD']:
    f = getattr(LIB,name); f.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_double]
    f.restype=None

ADHESION_PROVIDER = Path(__file__).resolve().parents[3]/'experimental/adhesion-contact-integration/tests/compare_adhesion.py'

def fixtures(adhesion_path=ADHESION_PROVIDER):
    common = '<option timestep=".002"><flag constraint="disable" warmstart="disable" island="disable"/></option>'
    prefix = '<mujoco>'+common
    yield 'slide', prefix+'<worldbody><body><joint name="j" type="slide" axis="1 0 0" damping=".2" stiffness=".3"/><geom type="sphere" size=".1" mass="1"/></body></worldbody></mujoco>', 'smooth'
    yield 'hinge_motor', prefix+'<worldbody><body pos="0 0 .2"><joint name="j" damping=".1" stiffness=".4"/><geom type="capsule" fromto="0 0 0 .2 .1 .3" size=".03" mass="1"/></body></worldbody><actuator><motor joint="j" ctrllimited="true" ctrlrange="-.2 .2"/></actuator></mujoco>', 'smooth'
    yield 'affine_chain', prefix+'''<worldbody><body><joint name="j1" damping=".15"/><geom type="box" size=".1 .2 .1" mass="1"/>
      <body pos=".2 0 .1"><joint name="j2" axis="0 1 0" damping=".2"/><geom type="box" size=".1 .1 .2" mass=".8"/>
      <body pos=".1 .1 .2"><joint name="j3" axis="1 0 0" damping=".3"/><geom type="sphere" size=".1" mass=".5"/></body></body></body></worldbody>
      <actuator><general joint="j1" biastype="affine" biasprm=".1 .2 -.3"/><motor joint="j2"/></actuator></mujoco>''', 'smooth'
    yield 'branched', prefix+'''<worldbody><body><joint name="j0"/><geom type="sphere" size=".1" mass="1"/>
      <body pos=".2 0 .1"><joint name="j1" axis="0 1 0"/><geom type="box" size=".1 .2 .1" mass=".7"/></body>
      <body pos="0 .2 .1"><joint name="j2" type="slide" axis="1 0 0" damping=".2"/><geom type="sphere" size=".1" mass=".4"/></body>
      </body></worldbody><actuator><motor joint="j0"/></actuator></mujoco>''', 'smooth'
    yield 'ball', prefix+'<worldbody><body><joint name="j" type="ball" damping=".12" stiffness=".3"/><geom type="box" size=".1 .2 .3" mass="1"/></body></worldbody><actuator><motor joint="j" gear="1 .2 -.3 0 0 0"/></actuator></mujoco>', 'smooth'
    yield 'free', prefix+'<worldbody><body pos="0 0 .3"><freejoint name="j"/><geom type="box" size=".1 .2 .3" mass="1"/></body></worldbody><actuator><motor joint="j" gear=".2 -.3 .4 .5 .6 -.7"/></actuator></mujoco>', 'smooth'
    yield 'free_ball', prefix+'''<worldbody><body pos="0 0 .4"><freejoint name="j0"/><geom type="box" size=".1 .2 .1" mass="1"/>
      <body pos=".2 .1 .3"><joint name="j1" type="ball" damping=".1"/><geom type="box" size=".1 .1 .2" mass=".4"/>
      <body pos=".2 0 .1"><joint name="j2" damping=".1"/><geom type="sphere" size=".1" mass=".3"/></body></body></body></worldbody>
      <actuator><motor joint="j1" gear=".3 .2 .1 0 0 0"/></actuator></mujoco>''', 'smooth'
    for kind in ['integrator','filter','filterexact']:
        yield 'activation_'+kind, prefix+f'''<worldbody><body><joint name="j" type="slide" axis="1 0 0" damping=".1"/><geom type="sphere" size=".1" mass="1"/></body></worldbody>
          <actuator><general joint="j" dyntype="{kind}" dynprm=".05" actlimited="true" actrange="-.5 .5" ctrllimited="true" ctrlrange="-.2 .2" gainprm="2"/></actuator></mujoco>''', 'smooth'
    yield 'muscle', prefix+'''<worldbody><body><joint name="j" type="slide" axis="1 0 0" damping=".1"/><geom type="sphere" size=".1" mass="1"/></body></worldbody>
      <actuator><muscle joint="j" lengthrange="-.5 .5" force="2" range=".5 1.5"/></actuator></mujoco>''', 'smooth'
    for kind in ['box','ellipsoid']:
        option = '<option timestep=".002" density=".5" viscosity=".015" wind=".1 -.2 .05"><flag constraint="disable" warmstart="disable" island="disable"/></option>'
        geom = '<geom type="box" size=".1 .2 .3" mass="1"/>' if kind=='box' else '<geom type="ellipsoid" size=".1 .2 .3" mass="1" fluidshape="ellipsoid" fluidcoef=".8 .4 .2 .3 .1"/>'
        yield 'fluid_'+kind, '<mujoco>'+option+'<worldbody><body pos="0 0 .2"><freejoint/>'+geom+'</body></worldbody></mujoco>', 'smooth'
    yield 'fixed_tendon', prefix+'''<worldbody><body><joint name="j0" type="slide" axis="1 0 0"/><geom type="sphere" size=".1" mass="1"/>
      <body pos=".2 .1 0"><joint name="j1" damping=".1"/><geom type="box" size=".1 .2 .1" mass=".5"/></body></body></worldbody>
      <tendon><fixed stiffness=".4" damping=".3" armature=".2"><joint joint="j0" coef=".7"/><joint joint="j1" coef="-.3"/><joint joint="j0" coef=".2"/></fixed></tendon></mujoco>''', 'smooth'
    yield 'spatial_ball', prefix+'''<worldbody><site name="a" pos=".5 .4 .3"/><body><joint name="j" type="ball" damping=".1"/>
      <geom type="box" size=".1 .2 .1" mass="1"/><site name="b" pos=".2 .1 0"/></body></worldbody>
      <tendon><spatial stiffness=".2" damping=".3"><site site="a"/><site site="b"/></spatial></tendon></mujoco>''', 'smooth'
    for solver in ['PGS','CG','Newton']:
        opt = f'<option timestep=".002" solver="{solver}" iterations="200" tolerance="1e-12"><flag warmstart="disable" island="disable"/></option>'
        yield 'contact_'+solver, '<mujoco>'+opt+'''<worldbody><geom type="plane" size="3 3 .1" condim="3"/>
          <body pos="0 0 .09"><freejoint/><geom type="sphere" size=".1" mass="1" condim="3"/></body></worldbody></mujoco>''', 'constrained'
    for solver in ['PGS','CG','Newton']:
        for jac in ['dense','sparse']:
            opt = f'<option timestep=".002" solver="{solver}" iterations="200" tolerance="1e-12" cone="elliptic" jacobian="{jac}"><flag warmstart="disable" island="disable"/></option>'
            yield 'elliptic6_'+solver+'_'+jac, '<mujoco>'+opt+'''<worldbody><geom type="plane" size="3 3 .1" condim="6"/>
              <body pos="0 0 .09"><freejoint/><geom type="sphere" size=".1" mass="1" condim="6"/></body></worldbody></mujoco>''', 'constrained'
    yield 'limit_friction', '<mujoco><option timestep=".002" tolerance="1e-12"><flag warmstart="disable" island="disable"/></option>'+'''<worldbody><body><joint name="j" type="slide" axis="1 0 0" limited="true" range="-.05 .05" frictionloss=".1"/><geom type="sphere" size=".1" mass="1"/></body></worldbody><actuator><motor joint="j"/></actuator></mujoco>''', 'constrained'
    spec=importlib.util.spec_from_file_location('derivative_adhesion_fixtures',adhesion_path)
    provider=importlib.util.module_from_spec(spec);spec.loader.exec_module(provider)
    for name,xml in provider.fixtures():
        yield 'adhesion_'+name,xml,'constrained'

def data(m, sample):
    d=mujoco.MjData(m);d.time=sample['time'];d.qpos[:]=sample['q'];d.qvel[:]=sample['v']
    d.act[:]=sample['act'];d.ctrl[:]=sample['ctrl'];d.qfrc_applied[:]=sample['applied'];d.xfrc_applied[:]=sample['loads']
    return d

def oracle(m,sample,mode):
    d=data(m,sample);nv=m.nv;nx=2*nv+m.na;eps=sample['eps'];result={}
    A=np.empty((nx,nx));B=np.empty((nx,m.nu))
    mujoco.mjd_transitionFD(m,d,eps,sample['centered'],A,B,None,None)
    result.update(A=A,B=B)
    for name,fun in [('smooth','mjd_smooth_velFD'),('passive','mjd_passive_velFD')]:
        d=data(m,sample);mujoco.mj_forward(m,d)
        # passive FD writes the represented entries, not an additive oracle.
        d.qDeriv[:]=0
        getattr(LIB,fun)(m._address,d._address,eps)
        matrix=np.zeros((nv,nv))
        for r in range(nv):
            off=m.D_rowadr[r];n=m.D_rownnz[r]
            matrix[r,m.D_colind[off:off+n]]=d.qDeriv[off:off+n]
        result[name]=matrix
    if mode in ['smooth','constrained']:
        d=data(m,sample);d.qacc[:]=sample['acc']
        Fq=np.empty((nv,nv));Fv=Fq.copy();Fa=Fq.copy();Mq=np.empty((nv,m.nC))
        mujoco.mjd_inverseFD(m,d,eps,sample['subtract'],Fq,Fv,Fa,None,None,None,Mq)
        result.update(Fq=Fq,Fv=Fv,Fa=Fa,Mq=Mq)
    return result

def samples(m,name,count):
    rng=np.random.default_rng(2602102)
    for i in range(count):
        q=m.qpos0.copy();mujoco.mj_integratePos(m,q,rng.uniform(-.3,.3,m.nv),.08)
        if name=='limit_friction':q[0]=.065
        ctrl=rng.uniform(-.15,.15,m.nu)
        for u in range(m.nu):
            if m.actuator_ctrllimited[u]:
                low,high=m.actuator_ctrlrange[u]
                ctrl[u]=[0.5*(low+high),low,high,high+.01,low-.01][i%5]
        act=rng.uniform(.05,.35,m.na)
        if name.startswith('activation_') and i%4==3:act[:]=.5
        yield dict(time=.1,q=q,v=rng.uniform(-.2,.2,m.nv),act=act,ctrl=ctrl,
          applied=rng.uniform(-.15,.15,m.nv),acc=rng.uniform(-.3,.3,m.nv),
          loads=rng.uniform(-.03,.03,(m.nbody,6)),eps=[1e-5,1e-6,1e-7][i%3],
          centered=i%2,subtract=(i//2)%2)

def serialized(batch):
    rows=[str(len(batch))]
    for s in batch:
        values=[s['time'],s['eps'],s['centered'],s['subtract'],*s['q'],*s['v'],*s['act'],*s['ctrl'],*s['applied'],*s['acc'],*s['loads'].ravel()]
        rows.append(' '.join(format(x,'.17g') for x in values))
    return '\n'.join(rows)+'\n'

def parse(text,m,mode):
    nx=2*m.nv+m.na
    dims={'A':(nx,nx),'B':(nx,m.nu),'smooth':(m.nv,m.nv),'passive':(m.nv,m.nv)}
    dims.update(Fq=(m.nv,m.nv),Fv=(m.nv,m.nv),Fa=(m.nv,m.nv),Mq=(m.nv,m.nC))
    records=[]
    for line in text.splitlines():
        tokens=line.split()
        if not tokens:continue
        name=tokens[0]
        if name=='seconds':continue
        if name not in dims:raise ValueError('Unexpected probe output: '+line[:500])
        if name=='A':records.append({})
        records[-1][name]=np.array(tokens[1:],dtype=float).reshape(dims[name])
    return records

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=12)
    p.add_argument('--only');a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__=='3.14.0'
    provider=a.out/'adhesion-fixtures.py';provider.write_bytes(ADHESION_PROVIDER.read_bytes())
    records=[];failures=[];comparisons=0;maxima={}
    for name,xml,mode in fixtures(provider):
        if a.only and a.only not in name:continue
        m=mujoco.MjModel.from_xml_string(xml);f=a.out/(name+'.mjb')
        mujoco.mj_saveModel(m,str(f));(a.out/(name+'.xml')).write_text(xml)
        batch=list(samples(m,name,a.samples));inputs=serialized(batch)
        (a.out/(name+'.input')).write_text(inputs)
        run=subprocess.run([str(a.binary),str(f),mode],input=inputs,text=True,capture_output=True,timeout=180)
        (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
        if run.returncode:
            failures.append(dict(model=name,error=run.stdout[-1800:]+run.stderr[-500:]));print('FAIL',name,failures[-1],flush=True);continue
        actual=parse(run.stdout,m,mode);assert len(actual)==len(batch)
        for i,(s,x) in enumerate(zip(batch,actual)):
            ref=oracle(m,s,mode);errors={}
            for key,y in ref.items():
                delta=float(np.max(np.abs(x[key]-y))) if y.size else 0.
                # FD magnifies rounding by 1/eps. This tolerance is fixed before
                # running the corpus; record every absolute/scaled discrepancy.
                atol=2e-6 if s['eps']==1e-7 else 2e-7
                ok=bool(np.allclose(x[key],y,atol=atol,rtol=2e-6))
                errors[key]=dict(passed=ok,max_abs=delta,atol=atol,rtol=2e-6)
                comparisons+=y.size;maxima[key]=max(maxima.get(key,0.),delta)
            passed=all(v['passed'] for v in errors.values())
            record=dict(model=name,sample=i,eps=s['eps'],centered=s['centered'],passed=passed,errors=errors)
            records.append(record)
            if not passed:failures.append(record);print('FAIL',name,i,{k:v for k,v in errors.items() if not v['passed']},flush=True)
        print(name,'checked',flush=True)
    result=dict(reference=mujoco.__version__,library_sha256=hashlib.sha256(LIBRARY.read_bytes()).hexdigest(),
      driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
      adhesion_provider_sha256=hashlib.sha256(provider.read_bytes()).hexdigest(),
      binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),cases=len(records),
      passed=sum(r['passed'] for r in records),comparisons=int(comparisons),
      max_abs_error=maxima,failures=failures,records=records)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('RESULT',result['passed'],result['cases'],'failures',len(failures))
    raise SystemExit(1 if failures else 0)
if __name__=='__main__':main()
