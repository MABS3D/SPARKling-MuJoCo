"""Equivalent 128-step movement trajectories; official C SIMD versus release Ada."""
import argparse,hashlib,json,os,statistics,subprocess
from pathlib import Path
import mujoco,numpy as np
from compare import fixtures,model
from build import ROOT,environment

def main():
 p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--batches',type=int,default=256);a=p.parse_args()
 assert mujoco.__version__=='3.14.0';assert a.batches>0;a.out.mkdir(parents=True,exist_ok=False)
 env=environment();lib=next(Path(mujoco.__file__).parent.glob('libmujoco.so*'));c=a.out/'advanced_c'
 source=a.build/'source/experimental/advanced-step/tests/advanced_bench.c'
 cmd=['gcc','-O3','-march=native','-ffp-contract=off',str(source),'-I'+str(ROOT/'mujoco/include'),'-Wl,-rpath,'+str(lib.parent),str(lib),'-lm','-o',str(c)]
 subprocess.run(cmd,check=True,env=env)
 bins={'ada':a.build/'build/release/bin/advanced_bench','c':c}
 chosen=dict(fixtures());names=['pid_hinge_10_0','dc_111110','so3_joint_expmap_0','so3_sites_vel','mixed_blocks','many_blocks']
 body=''.join(f'<body pos="{i*.3} 0 0"><joint name="j{i}" damping=".03"/><geom size=".1" mass="1"/></body>' for i in range(16))
 chosen['pid_16dof']=model(''.join(f'<pid joint="j{i}" kp="3" ki=".7" kv=".4" input="pos vel ff"/>' for i in range(16)),body);names.append('pid_16dof')
 cpu=sorted(os.sched_getaffinity(0))[-1];os.sched_setaffinity(0,{cpu});results=[]
 for name in names:
  m=mujoco.MjModel.from_xml_string(chosen[name]);path=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(a.out/(name+'.xml')).write_text(chosen[name])
  samples={'ada':[],'c':[]};wall={'ada':[],'c':[]};tails={'ada':[],'c':[]};checksum={}
  for rep in range(7):
   for side in (('ada','c') if rep%2==0 else ('c','ada')):
    r=subprocess.run([str(bins[side]),str(path),str(a.batches)],text=True,capture_output=True,check=True,timeout=180)
    (a.out/f'{name}-{rep}-{side}.txt').write_text(r.stdout);v=np.array([float(x) for x in r.stdout.split()]);assert len(v)==1+2*a.batches
    checksum[side]=v[0];w=v[1:1+a.batches]*1e6/128;t=v[1+a.batches:]*1e6/128
    if rep:samples[side].append(float(t.mean()));wall[side].append(float(w.mean()));tails[side].append(float(np.percentile(t,95)))
   np.testing.assert_allclose(checksum['ada'],checksum['c'],atol=2e-9,rtol=2e-9)
  am,cm=statistics.median(samples['ada']),statistics.median(samples['c'])
  result=dict(model=name,dofs=m.nv,actuators=m.nactuator,controls=m.nu,outputs=m.nout,activations=m.na,cpu_us_per_step=samples,wall_us_per_step=wall,p95_cpu_us_per_step=tails,median_ada_us=am,median_c_us=cm,ada_over_c=am/cm,checksum={k:float(v) for k,v in checksum.items()})
  results.append(result);print(json.dumps(result),flush=True)
 manifest=json.loads((a.build/'manifest.json').read_text())
 data=dict(reference=mujoco.__version__,source_sha256=manifest['sources'],ada_flags=['-O3','-gnatn','-march=native','-ffp-contract=off','runtime checks retained'],c_library_sha256=hashlib.sha256(lib.read_bytes()).hexdigest(),c_library_flags='official optimized wheel, normal SIMD; internal flags not independently controlled',c_driver_command=cmd,compilers={x:subprocess.check_output([x,'--version'],env=env,text=True).splitlines()[0] for x in ['gcc','gnatls']},cpu=cpu,cpuinfo=Path('/proc/cpuinfo').read_text().split('model name',1)[1].splitlines()[0],steps=128,batches=a.batches,scope='reset and inputs/readback/I/O outside timing; one warm-up plus six alternating repetitions; shared host; no prior Ada feature baseline',results=results)
 (a.out/'results.json').write_text(json.dumps(data,indent=2)+'\n')
if __name__=='__main__':main()
