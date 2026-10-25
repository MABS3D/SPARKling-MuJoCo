"""Paired full Euler trajectories: strict Ada baseline/current and native C 3.17.

Wheel C build flags are unknown. Ratios are diagnostic, not final matched-build
C parity evidence. Run only when proofs/builds and other heavy jobs are idle.
"""
import argparse,hashlib,importlib.util,itertools,json,os,platform,shutil,subprocess
from pathlib import Path
import mujoco
import numpy as np

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p,v):p.write_text(json.dumps(v,indent=2)+'\n')
def chain(count,branches=False):
 option='<option timestep=".002"><flag constraint="disable" warmstart="disable" island="disable"/></option>'
 def body(i):
  axis=['1 0 0','0 1 0','0 0 1'][i%3]
  return f'<body pos=".07 .03 .04"><joint name="j{i}" axis="{axis}" damping=".02" armature=".003"/><geom type="sphere" size=".03" mass=".3"/>'
 if branches:
  arms=[]
  for arm in range(3):
   width=count//3;arms.append(''.join(body(arm*width+i) for i in range(width))+'</body>'*width)
  content=''.join(arms)
 else:content=''.join(body(i) for i in range(count))+'</body>'*count
 return '<mujoco>'+option+'<worldbody>'+content+'</worldbody><actuator><motor joint="j0"/></actuator></mujoco>'
def parse(text,nq,nv,samples):
 lines=[line.split() for line in text.splitlines()]
 assert len(lines)==4*samples,(len(lines),samples)
 result=[]
 for i in range(samples):
  rows=lines[4*i:4*i+4];assert [r[0] for r in rows]==['sample','qpos','qvel','time']
  values=[np.asarray(r[1:],float) for r in rows]
  assert [len(x) for x in values]==[1,nq,nv,1] and all(np.all(np.isfinite(x)) for x in values)
  assert values[0][0]>0
  result.append((float(values[0][0]),np.r_[values[1],values[2],values[3]]))
 return result
def stats(values):
 a=np.asarray(values);m=np.median(a)
 return dict(median_us=float(m*1e6),mad_us=float(np.median(np.abs(a-m))*1e6),p95_trajectory_mean_us=float(np.quantile(a,.95)*1e6))
def ratio(a,b,rng):
 a=np.median(a,axis=1);b=np.median(b,axis=1)
 take=rng.integers(0,len(a),size=(4000,len(a)))
 boot=np.median(a[take],axis=1)/np.median(b[take],axis=1)
 return dict(median=float(np.median(a)/np.median(b)),ci95=[float(x) for x in np.quantile(boot,[.025,.975])])
def main():
 p=argparse.ArgumentParser(description=__doc__)
 p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--blocks',type=int,default=24);p.add_argument('--samples',type=int,default=4)
 p.add_argument('--steps',type=int,default=100);p.add_argument('--cpu',type=int,default=12)
 p.add_argument('--loads',choices=['all','none','single'],default='all')
 p.add_argument('--warmups',type=int,default=2)
 p.add_argument('--models',nargs='+',help='Diagnostic subset; all fixture RNG draws are retained')
 a=p.parse_args();assert a.warmups>=0
 assert a.blocks>=6 and a.blocks%6==0 and min(a.samples,a.steps)>0
 assert mujoco.__version__=='3.17.0' and mujoco.mj_version()==3_017_000
 a.out.mkdir(parents=True,exist_ok=False);shutil.copy2(Path(__file__),a.out/'runner.py')
 meta=json.loads((a.build/'build.json').read_text());assert meta['reference']=='3.17.0'
 binaries={k:Path(v['binary']) for k,v in meta['builds'].items()}
 source_maps={}
 for name in ['baseline','current']:
  work=binaries[name].parent.parent;manifest=work/'sources.json'
  source_maps[name]=(work/'source',manifest,json.loads(manifest.read_text()))
 def unchanged():
  return all(digest(path)==meta['builds'][name]['binary_sha256'] for name,path in binaries.items()) and digest(Path(meta['builds']['c']['library']))==meta['builds']['c']['library_sha256'] and all(all(digest(root/n)==value for n,value in hashes.items()) for root,manifest,hashes in source_maps.values())
 assert unchanged();os.sched_setaffinity(0,{a.cpu})
 providers=a.out/'providers';providers.mkdir()
 variant_source=Path(meta['builds']['current']['binary']).parent.parent/'source'
 tests=variant_source/'experimental/dynamics-derivatives-candidate/tests'
 compare=providers/'compare.py';shutil.copy2(tests/'compare.py',compare)
 adhesion=providers/'compare_adhesion.py';shutil.copy2(variant_source/'experimental/adhesion-contact-integration/tests/compare_adhesion.py',adhesion)
 spec=importlib.util.spec_from_file_location('movement_fixtures',compare);fixture=importlib.util.module_from_spec(spec);spec.loader.exec_module(fixture)
 names=['hinge_motor','affine_chain','branched','ball','free','free_ball','fixed_tendon','spatial_ball']
 xmls={name:xml for name,xml,mode in fixture.fixtures(adhesion,'3.17.0') if name in names}
 assert len(xmls)==len(names)
 xmls.update(chain_24=chain(24),branches_24=chain(24,True))
 assert not a.models or set(a.models)<=set(xmls)
 rng=np.random.default_rng(20261025);bootstrap=np.random.default_rng(2026102502)
 orders=list(itertools.permutations(binaries));records=[];commands=[]
 try:
  for name,xml in xmls.items():
   model=mujoco.MjModel.from_xml_string(xml);assert model.na==0
   model_path=a.out/(name+'.mjb');mujoco.mj_saveModel(model,str(model_path));(a.out/(name+'.xml')).write_text(xml)
   for state in range(3):
    key=name+'-'+str(state);q=model.qpos0.copy();mujoco.mj_integratePos(model,q,rng.uniform(-.15,.15,model.nv),.1)
    v=rng.uniform(-.2,.2,model.nv);ctrl=rng.uniform(-.1,.1,model.nu);applied=rng.uniform(-.1,.1,model.nv)
    loads=rng.uniform(-.03,.03,(model.nbody,6));loads[0]=0
    if a.loads=='none':loads[:]=0
    elif a.loads=='single':loads[1:-1]=0
    text=' '.join(format(float(x),'.17g') for x in np.r_[q,v,ctrl,applied,loads.ravel()])+'\n'
    if a.models and name not in a.models:continue
    input_path=a.out/(key+'.input');input_path.write_text(text)
    d=mujoco.MjData(model);d.qpos[:]=q;d.qvel[:]=v;d.ctrl[:]=ctrl;d.qfrc_applied[:]=applied;d.xfrc_applied[:]=loads;d.time=.125
    for _ in range(a.steps):mujoco.mj_step(model,d)
    assert not any(int(x.number) for x in d.warning)
    oracle=np.r_[d.qpos,d.qvel,d.time];dump(a.out/(key+'-oracle.json'),oracle.tolist())
    timings={k:[] for k in binaries};maximum=0.;checks=0
    for block in range(a.blocks):
     outputs={}
     for variant in orders[(block+len(records))%len(orders)]:
      command=[str(binaries[variant]),str(model_path),str(a.steps),str(a.samples),str(a.warmups)]
      run=subprocess.run(command,input=text,text=True,capture_output=True,timeout=120)
      output=a.out/(key+f'-{block:02}-{variant}.output');output.write_text(run.stdout+run.stderr)
      commands.append(dict(argv=command,input=str(input_path),output=str(output),exit=run.returncode))
      assert run.returncode==0,(key,variant,run.returncode,run.stdout[-1500:],run.stderr[-1500:])
      rows=parse(run.stdout,model.nq,model.nv,a.samples);outputs[variant]=[row[1] for row in rows]
      timings[variant].append([row[0]/a.steps for row in rows])
      for _,values in rows:
       maximum=max(maximum,float(np.max(np.abs(values-oracle))));checks+=len(values)
       assert np.allclose(values,oracle,atol=2e-10,rtol=2e-10),(key,variant,maximum)
     assert all(np.array_equal(x,y) for x,y in zip(outputs['baseline'],outputs['current'])),(key,'Ada exact equality')
    item=dict(model=name,state=state,nq=model.nq,nv=model.nv,nbody=model.nbody,blocks=a.blocks,samples=a.samples,steps=a.steps,warmups=a.warmups,model_sha256=digest(model_path),checked_values=checks,max_abs_c=maximum,
      timings_seconds_per_step=timings,statistics={k:stats(np.ravel(v)) for k,v in timings.items()},current_over_baseline=ratio(timings['current'],timings['baseline'],bootstrap),current_over_c=ratio(timings['current'],timings['c'],bootstrap))
    records.append(item);dump(a.out/'partial.json',records);print(key,'current/base',item['current_over_baseline'],'current/C',item['current_over_c'],flush=True)
  assert unchanged()
  result=dict(passed=True,source_and_binary_unchanged=True,build_sha256=digest(a.build/'build.json'),source_manifests_sha256={name:digest(item[1]) for name,item in source_maps.items()},reference='3.17.0',loads=a.loads,cpu=a.cpu,platform=platform.uname()._asdict(),model_count=len({r['model'] for r in records}),scenario_count=len(records),warmups=a.warmups,selected_models=a.models,records=records,scope=meta['scope'],limitations=['Official C wheel compiler flags unknown; no final matched-build C parity acceptance.','Smooth Euler only: no contacts, constraints, sensors or rendering.','The raw shared mass reader is not on this stepping path.','Bootstrap is within-session without multiple-comparison correction; p95 is trajectory mean, not individual step latency.'])
  dump(a.out/'results.json',result)
 except BaseException as error:
  dump(a.out/'failure.json',dict(error=repr(error),completed_scenarios=len(records)));raise
 finally:dump(a.out/'commands.json',commands)
if __name__=='__main__':main()
