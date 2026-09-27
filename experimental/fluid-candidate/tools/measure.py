from pathlib import Path
import sys,os,subprocess,json,hashlib
import numpy as np
import mujoco
assert mujoco.__version__ == '3.14.0', 'Pinned MuJoCo oracle required'
root=Path(__file__).resolve().parents[1];repo=root/'work'
sys.path.insert(0,str(repo/'tests/movement_performance'))
from run import parse,stats,ratio,reference
build=root/sys.argv[1];out=root/sys.argv[2];out.mkdir()
binada=build/'bin/movement_bench';binc=root/'movement_c'
if not binc.exists():
 tool=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env=os.environ.copy()
 env['PATH']=':'.join(str(next((tool/t).glob('*/bin'))) for t in ('gnat','gprbuild'))+':'+env['PATH']
 lib=Path('/var/tmp/sparkling-movement-c/build/lib/libmujoco.so.3.14.0')
 cpp=Path(subprocess.check_output(['g++','-print-file-name=libstdc++.so'],env=env,text=True).strip()).resolve()
 cmd=['gcc','-std=c11','-O3','-march=native','-flto','-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno','-I'+str(Path(mujoco.__file__).parent/'include'),str(repo/'tests/movement_performance/movement_c.c'),str(lib),str(cpp),'-Wl,-rpath,'+str(lib.parent)+':'+str(cpp.parent),'-o',str(binc)]
 subprocess.run(cmd,env=env,check=True)
 (root/'c-build.json').write_text(json.dumps({'command':cmd,'library_sha256':hashlib.sha256(lib.read_bytes()).hexdigest(),'binary_sha256':hashlib.sha256(binc.read_bytes()).hexdigest()},indent=2))
os.sched_setaffinity(0,{12});rng=np.random.default_rng(20260927)
steps=100;samples=4;blocks=int(sys.argv[3]);cases=[];records=[]
paths=[root/'fixtures'/f'{name}.xml' for name in ['fluid_box_hinge_motor_wind','fluid_box_branched_multijoint_wind','fluid_box_chain_12_wind','fluid_ellipsoid_ellipsoid_all','fluid_ellipsoid_multiple','fluid_ellipsoid_sphere_all','fluid_flags_both_off','fluid_box_chain24','fluid_box_star24','fluid_box_branches24','fluid_ellipsoid_chain24','fluid_ellipsoid_star24','fluid_ellipsoid_branches24']]
for path in paths:
 m=mujoco.MjModel.from_xml_path(str(path));mp=out/(path.stem+'.mjb');mujoco.mj_saveModel(m,str(mp))
 for state in range(3):
  q=m.qpos0+rng.uniform(-.25,.25,m.nq);v=rng.uniform(-.5,.5,m.nv);ctrl=rng.uniform(-.4,.4,m.nu);applied=rng.uniform(-.1,.1,m.nv)
  data=' '.join(format(x,'.17g') for x in np.concatenate((q,v,ctrl,applied)))+'\n'
  key=path.stem+'-'+str(state);(out/(key+'.input')).write_text(data)
  expected=reference(m,q,v,ctrl,applied,.125,steps);timings={'ada':[],'c':[]};alltimings={'ada':[],'c':[]};error=0
  for block in range(blocks):
   order=['ada','c'] if block%2==0 else ['c','ada']
   for variant in order:
    binary=binada if variant=='ada' else binc
    run=subprocess.run([str(binary),str(mp),str(steps),str(samples),'2'],input=data,text=True,capture_output=True,check=True,timeout=30)
    rows=parse(run.stdout)
    for row in rows:
     for field in ('qpos','qvel','time'):
      actual=np.asarray(row[field]);ref=expected[field];delta=abs(actual-ref)
      assert actual.shape==ref.shape and np.all(delta<=2e-10+2e-10*abs(ref)),(key,variant,field,delta)
      error=max(error,float(max(delta,default=0)))
    ns=[row['seconds']*1e9/steps for row in rows];timings[variant].append(float(np.median(ns)));alltimings[variant].extend(ns)
    records.append({'case':key,'block':block,'variant':variant,'order':order,'rows':rows})
  item={'case':key,'nv':m.nv,'nbody':m.nbody,'max_absolute_error':error,'ns':{k:stats(x) for k,x in alltimings.items()},'ada_over_c':ratio(timings['ada'],timings['c'],rng)};cases.append(item)
  (out/'results.json').write_text(json.dumps({'complete':False,'summary':cases,'records':records},indent=2));print(key,item['ada_over_c'],flush=True)
(out/'results.json').write_text(json.dumps({'complete':True,'blocks':blocks,'samples':samples,'steps':steps,'cpu':12,'seed':20260927,'binary_sha256':hashlib.sha256(binada.read_bytes()).hexdigest(),'c_binary_sha256':hashlib.sha256(binc.read_bytes()).hexdigest(),'summary':cases,'records':records},indent=2))
