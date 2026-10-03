"""Full-step SDF fixtures: Ada receives only MJB/state/controls/body loads."""
import argparse, hashlib, importlib.util, json, subprocess, sys
from pathlib import Path
import mujoco
import numpy as np
ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('constrained_compare', ROOT/'experimental/constrained-step/tests/compare.py')
base = importlib.util.module_from_spec(spec); spec.loader.exec_module(base)
VERTICES = '-.2 -.2 -.2 .2 -.2 -.2 .2 .2 -.2 -.2 .2 -.2 -.2 -.2 .2 .2 -.2 .2 .2 .2 .2 -.2 .2 .2'
def fixtures():
    # An inactive distant SDF selects the SDF scene wrapper, while the contact
    # itself is ordinary rigid/rigid. Exercise both endpoint ID/type orders and
    # asymmetric material mixing, including the row order used by PGS.
    for solver in ['PGS', 'Newton']:
        for first, size0, second, size1 in [
                ('box', '.2 .2 .2', 'sphere', '.08'),
                ('box', '.2 .2 .2', 'capsule', '.06 .08'),
                ('mesh', '', 'cylinder', '.06 .08'),
                ('cylinder', '.2 .2', 'sphere', '.08')]:
            for reverse in [False, True]:
                a, sa, b, sb = ((second, size1, first, size0) if reverse else
                                (first, size0, second, size1))
                ga = f'type="{a}" ' + ('mesh="field"' if a == 'mesh' else f'size="{sa}"')
                gb = f'type="{b}" ' + ('mesh="field"' if b == 'mesh' else f'size="{sb}"')
                yield f'mixedrigid_{first}_{second}_{solver}_{reverse}', f'''<mujoco>
                  <option gravity="0 0 0" jacobian="sparse" timestep=".001" solver="{solver}"
                    iterations="200" tolerance="1e-12"><flag warmstart="disable" island="disable"/></option>
                  <default><geom condim="3" solimp=".8 .95 .01 .5 2"/></default>
                  <asset><mesh name="field" vertex="{VERTICES}"/></asset><worldbody>
                  <geom {ga} solmix=".173" solref=".017 1.4" friction=".4 .01 .002"/>
                  <geom type="sdf" mesh="field" pos="5 0 0" contype="0" conaffinity="0"/>
                  <body pos=".24 .019 .013" quat=".99 .01 .02 .03"><freejoint/>
                    <geom {gb} mass="1" solmix=".871" solref=".039 .6" friction=".8 .03 .004"/>
                  </body></worldbody></mujoco>'''
    for solver in ['PGS', 'CG', 'Newton']:
        for dim in [1, 3, 4, 6]:
            xml = f'''<mujoco><option timestep=".001" jacobian="sparse" gravity="0 0 0"
              solver="{solver}" iterations="200" tolerance="1e-12" sdf_initpoints="4" sdf_iterations="10">
              <flag warmstart="disable" island="disable"/></option>
              <default><geom condim="{dim}" friction=".7 .01 .002" solimp=".8 .95 .01 .5 2"/></default>
              <asset><mesh name="field" vertex="{VERTICES}"/></asset>
              <worldbody><geom type="sdf" mesh="field"/>
              <body pos=".24 .01 .02"><freejoint/><geom type="sphere" size=".08" mass="1"/></body>
              </worldbody></mujoco>'''
            yield f'sphere_{solver}_{dim}', xml
    for kind, size in [('capsule', '.06 .08'), ('ellipsoid', '.08 .06 .07'),
                       ('cylinder', '.06 .08'), ('box', '.07 .06 .08')]:
        yield kind, f'''<mujoco><option gravity="0 0 0" jacobian="sparse" timestep=".001"
          sdf_initpoints="4" sdf_iterations="10" iterations="200" tolerance="1e-12">
          <flag warmstart="disable" island="disable"/></option>
          <default><geom condim="1" solimp=".8 .95 .01 .5 2"/></default>
          <asset><mesh name="field" vertex="{VERTICES}"/></asset><worldbody>
          <geom type="sdf" mesh="field"/><body pos=".24 .011 .023" quat=".99 .01 .02 .03">
          <freejoint/><geom type="{kind}" size="{size}" mass="1"/></body></worldbody></mujoco>'''
    yield 'sdf_sdf', f'''<mujoco><option gravity="0 0 0" jacobian="sparse" timestep=".001"
      sdf_initpoints="4" sdf_iterations="10" iterations="200" tolerance="1e-12">
      <flag warmstart="disable" island="disable"/></option><default><geom condim="1"/></default>
      <asset><mesh name="field" vertex="{VERTICES}"/></asset><worldbody>
      <geom type="sdf" mesh="field"/><body pos=".38 .027 .031" quat=".99 .01 .02 .03">
      <freejoint/><geom type="sdf" mesh="field" mass="1"/></body></worldbody></mujoco>'''
    yield 'plane_sdf', f'''<mujoco><option jacobian="sparse" timestep=".001" iterations="200" tolerance="1e-12">
      <flag warmstart="disable" island="disable"/></option><default><geom condim="1"/></default>
      <asset><mesh name="field" vertex="{VERTICES}"/></asset><worldbody>
      <geom type="plane" size="2 2 .1"/><body pos="0 0 .195"><freejoint/>
      <geom type="sdf" mesh="field" mass="1"/></body></worldbody></mujoco>'''
    yield 'reverse_ids', f'''<mujoco><option gravity="0 0 0" jacobian="sparse" timestep=".001"
      sdf_initpoints="4" sdf_iterations="10" iterations="200" tolerance="1e-12">
      <flag warmstart="disable" island="disable"/></option><default><geom condim="1"/></default>
      <asset><mesh name="field" vertex="{VERTICES}"/></asset><worldbody><geom type="sphere" size=".08"/>
      <body pos=".24 .013 .021"><freejoint/><geom type="sdf" mesh="field" mass="1"/></body>
      </worldbody></mujoco>'''
    yield 'mesh_sdf', f'''<mujoco><option gravity="0 0 0" jacobian="sparse" timestep=".001"
      sdf_initpoints="4" sdf_iterations="10" iterations="200" tolerance="1e-12">
      <flag warmstart="disable" island="disable"/></option><default><geom condim="1"/></default>
      <asset><mesh name="field" vertex="{VERTICES}"/>
      <mesh name="moving" scale=".35 .4 .45" vertex="{VERTICES}"/></asset><worldbody>
      <geom type="sdf" mesh="field"/><body pos=".24 .019 .013"><freejoint/>
      <geom type="mesh" mesh="moving" mass="1"/></body></worldbody></mujoco>'''
    for starts in [0, 1, 40]:
        yield f'starts_{starts}', f'''<mujoco><option gravity="0 0 0" jacobian="sparse" timestep=".001"
          sdf_initpoints="{starts}" sdf_iterations="10" iterations="200" tolerance="1e-12">
          <flag warmstart="disable" island="disable"/></option><default><geom condim="1"/></default>
          <asset><mesh name="field" vertex="{VERTICES}"/></asset><worldbody>
          <geom type="sdf" mesh="field"/><body pos=".24 .011 .023"><freejoint/>
          <geom type="sphere" size=".08" mass="1"/></body></worldbody></mujoco>'''
def isolated(a):
    """A native-reference abort must not erase or prevent the other cases."""
    a.out.mkdir(parents=True, exist_ok=False)
    records=[]; failures=[]; models=[]
    result=dict(reference=mujoco.__version__, binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
        driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        steps=a.steps, samples=a.samples, complete=False, records=records, failures=failures, models=models)
    for name,_ in fixtures():
        if a.only and a.only not in name:continue
        folder=a.out/name
        command=[sys.executable,str(Path(__file__).resolve()),'--worker','--only-exact',name,
                 '--binary',str(a.binary.resolve()),'--out',str(folder.resolve()),
                 '--samples',str(a.samples),'--steps',str(a.steps)]
        with (a.out/(name+'.log')).open('w') as log:
            try:
                run=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=240)
                code=run.returncode
            except subprocess.TimeoutExpired:
                code=124
        receipt=folder/'results.json'
        row=dict(model=name,exit=code,command=command)
        if receipt.is_file():
            data=json.loads(receipt.read_text())
            records.extend(data['records']);failures.extend(data['failures'])
            row['complete']=data.get('complete',False)
            if not row['complete'] or (code and not data['failures']):
                failures.append(dict(model=name,error='worker incomplete',exit=code))
        else:
            row['complete']=False
            failures.append(dict(model=name,error='worker ended before reference/probe receipt',exit=code))
        models.append(row)
        result.update(cases=len(records),passed=sum(r['passed'] for r in records))
        pending=a.out/'results.pending.json';pending.write_text(json.dumps(result,indent=2)+'\n')
        pending.replace(a.out/'results.json')
        print(name,'exit',code,flush=True)
    result['complete']=True
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print('RESULT',result['passed'],result['cases'],'failures',len(failures))
    raise SystemExit(bool(failures))

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=4)
    p.add_argument('--steps',type=int,default=100);p.add_argument('--only')
    p.add_argument('--worker',action='store_true',help=argparse.SUPPRESS)
    p.add_argument('--only-exact',help=argparse.SUPPRESS);a=p.parse_args()
    if not a.worker:isolated(a)
    assert mujoco.__version__=='3.14.0';a.out.mkdir(parents=True,exist_ok=False)
    rng=np.random.default_rng(261002);records=[];failures=[]
    completed_models=[]
    def checkpoint(complete=False):
        result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
          driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
          complete=complete,completed_models=completed_models,steps=a.steps,cases=len(records),
          passed=sum(r['passed'] for r in records),failures=failures,records=records)
        temporary=a.out/'results.pending.json';temporary.write_text(json.dumps(result,indent=2)+'\n')
        temporary.replace(a.out/'results.json')
        return result
    for name,xml in fixtures():
        if a.only and a.only not in name:continue
        if a.only_exact and a.only_exact != name:continue
        m=mujoco.MjModel.from_xml_string(xml);file=a.out/(name+'.mjb')
        mujoco.mj_saveModel(m,str(file));(a.out/(name+'.xml')).write_text(xml)
        values=[];refs=[];states=[]
        for i in range(a.samples):
            q=m.qpos0.copy()
            if i:mujoco.mj_integratePos(m,q,rng.uniform(-.1,.1,m.nv),.001)
            v=rng.uniform(-.01,.01,m.nv);applied=rng.uniform(-.01,.01,m.nv)
            loads=rng.uniform(-.01,.01,(m.nbody,6));ctrl=np.zeros(m.nu);act=np.zeros(m.na)
            values.extend([0.,*q,*v,*applied,*ctrl,*act,*loads.ravel()])
            states.append((q,v,applied,ctrl,loads,act))
        data=f'{a.samples} {a.steps}\n'+' '.join(format(x,'.17g') for x in values)+'\n'
        (a.out/(name+'.input')).write_text(data)
        # Persist reproducible inputs before calling the native oracle, which
        # runs in this expendable worker just like the Ada subprocess.
        for q,v,applied,ctrl,loads,act in states:
            refs.append(base.oracle(m,q,v,applied,a.steps,ctrl,loads,act))
        try:
            run=subprocess.run([str(a.binary),str(file),'loads'],input=data,text=True,capture_output=True,timeout=180)
        except subprocess.TimeoutExpired:
            failures.append(dict(model=name,error='probe exceeded 180 seconds'))
            completed_models.append(name);checkpoint();print('TIMEOUT',name,flush=True);continue
        (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
        if run.returncode or run.stdout.startswith('create'):
            failures.append(dict(model=name,error=(run.stdout+run.stderr)[-1800:]))
            completed_models.append(name);checkpoint();print('FAIL',name,run.stdout[-600:],flush=True);continue
        actual=base.parse(run.stdout,m.nv,m.na)
        if len(actual)!=len(refs):raise RuntimeError('Incomplete probe output')
        for i,(x,y) in enumerate(zip(actual,refs)):
            # Check physical acceleration, force and the integrated state.
            # Detailed frame/row diagnostics are available via the probe's
            # optional "contacts" argument for a failing replay.
            errors={}
            fields = ['counts','free','acc','qfrc','state']
            if name.startswith('mixedrigid_'):
                fields += ['jac', 'aref', 'reg', 'force']
            for key in fields:
                delta=float(np.max(np.abs(x[key]-y[key]))) if y[key].size else 0.
                tol=2e-10 if key in ('counts','free','jac','aref','reg') else 3e-6
                errors[key]=dict(max_abs=delta,passed=bool(np.allclose(x[key],y[key],atol=tol,rtol=1e-8)))
            ok=all(e['passed'] for e in errors.values());record=dict(model=name,sample=i,passed=ok,errors=errors)
            records.append(record)
            if not ok:failures.append(record);print('FAIL',name,i,errors,flush=True)
        completed_models.append(name);checkpoint();print(name,'checked',flush=True)
    result=checkpoint(complete=True)
    print('RESULT',result['passed'],result['cases'],'failures',len(failures))
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
