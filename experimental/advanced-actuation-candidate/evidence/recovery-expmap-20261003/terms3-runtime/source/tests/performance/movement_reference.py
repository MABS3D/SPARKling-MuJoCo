"""Reference-only whole C steps: contextualize the candidate's isolated phase cost.

This is not an integrated Ada/C movement comparison. Validate native C's final
trajectory against official Python MuJoCo, excluding setup and I/O from timings.
"""
from pathlib import Path
import hashlib,json,os,subprocess
import mujoco,numpy as np
here=Path(__file__).resolve().parents[2]
scratch=Path('/var/tmp/sparkling-actuators-performance-20260930')
tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains/gnat/gnat-x86_64-linux-16.1.0-1')
reference=Path('/var/tmp/sparkling-movement-c/build/lib/libmujoco.so.3.14.0')
source=here/'tests/performance/movement_reference.c';exe=scratch/'bin/movement_reference'
repo=here.parents[1];folder=scratch/'comparison-v2'
stage=json.loads((folder/'results.json').read_text());os.sched_setaffinity(0,{stage['cpu']})
env=os.environ.copy();env['LD_LIBRARY_PATH']=str(tc/'lib64')+':'+str(reference.parent)
cmd=[str(tc/'bin/gcc'),'-O3','-march=native','-flto','-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno',
     '-I'+str(repo/'mujoco/include'),str(source),str(reference),'-lm','-Wl,-rpath,'+str(reference.parent),'-Wl,-rpath,'+str(tc/'lib64'),'-o',str(exe)]
subprocess.run(cmd,env=env,check=True)
steps=2000;results=[]
for name in ['hinge_motor','dc_full','so3_quat','dc_chain_8','dc_chain_32','dc_chain_64']:
 f=folder/name;m=mujoco.MjModel.from_binary_path(str(f/'model.mjb'));d=mujoco.MjData(m)
 initial=np.fromstring((f/'c.input').read_text(),sep=' ')[1:]
 offset=0
 for field in ['qpos','qvel','ctrl','act']:
  data=getattr(d,field);data[:]=initial[offset:offset+len(data)];offset+=len(data)
 for _ in range(steps):mujoco.mj_step(m,d)
 assert all(w.number==0 for w in d.warning)
 expected=np.r_[d.time,d.qpos,d.qvel,d.act];times=[]
 for block in range(9):
  p=subprocess.run([str(exe),str(f/'model.mjb'),str(f/'c.input'),str(steps),'3','1'],env=env,text=True,capture_output=True,timeout=60);p.check_returncode()
  (f/f'movement-reference-{block}.output').write_text(p.stdout)
  for line in p.stdout.splitlines():
   kind,*values=line.split();values=np.array(list(map(float,values)))
   if kind=='sample':times.append(float(values[0])/steps)
   else:
    assert kind=='state';np.testing.assert_allclose(values,expected,atol=2e-8,rtol=2e-8,err_msg=name+' native/reference trajectory')
 row={'name':name,'steps':steps,'blocks':9,'samples_per_block':3,'c_whole_step_us':float(np.median(times)*1e6),
      'timings_us':dict(zip(['p10','p50','p90'],map(float,np.percentile(times,[10,50,90])*1e6))),
      'native_vs_official_trajectory_passed':True}
 results.append(row);print(name,'whole C step us',row['c_whole_step_us'],flush=True)
out={'scope':'C-only complete mj_step on evolving trajectories; independent context, not aggregate Ada equivalence',
     'results':results,'cpu':stage['cpu'],'compile_command':cmd,'reference_library_sha256':hashlib.sha256(reference.read_bytes()).hexdigest(),
     'binary_sha256':hashlib.sha256(exe.read_bytes()).hexdigest(),'sources':{str(p.relative_to(here)):hashlib.sha256(p.read_bytes()).hexdigest()
          for p in [source,Path(__file__).resolve()]}}
(folder/'movement-reference.json').write_text(json.dumps(out,indent=2)+'\n')
