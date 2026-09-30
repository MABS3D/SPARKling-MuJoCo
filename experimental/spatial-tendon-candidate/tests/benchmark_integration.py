"""Full Euler trajectories, release Ada versus the official optimized C wheel."""
import argparse,sys,json,subprocess,hashlib,shutil,os,tempfile,statistics
from pathlib import Path
from datetime import datetime,timezone
import numpy as np
import mujoco as mj
from common import ROOT,REPO,SCRATCH,environment
sys.path.insert(0,str(REPO/'experimental/smooth/tools'))
from prove_fragments import isolated_project,source_files

OUT=ROOT/'evidence/performance-integration'
MANIFEST=OUT/'build.json'

def model(arms):
    bodies=[];tendons=[]
    for i in range(arms):
        bodies.append(f'<body pos="1 .1 {i*.01}"><joint type="slide" axis="0 1 0" damping=".03" armature=".1"/><joint axis="0 0 1" armature=".1"/><inertial pos=".1 0 .05" mass="1.4" diaginertia=".2 .3 .4"/><site name="end{i}" pos=".1 .05 0"/></body>')
        tendons.append(f'<spatial stiffness=".2" damping=".01" springlength="1.4 1.6"><site site="start"/><geom geom="wrap" sidesite="side"/><site site="end{i}"/></spatial>')
    return '<mujoco><compiler angle="radian"/><option timestep=".001" gravity="0 0 0"><flag constraint="disable"/></option><worldbody><geom name="wrap" type="sphere" size=".4" contype="0" conaffinity="0"/><site name="start" pos="-1 .1 .1"/><site name="side" pos="0 .6 0"/>'+''.join(bodies)+'</worldbody><tendon>'+''.join(tendons)+'</tendon></mujoco>'

def build():
    OUT.mkdir(parents=True,exist_ok=True)
    work=Path(tempfile.mkdtemp(prefix='spatial-step-benchmark-',dir=SCRATCH));snap=work/'source';hashes={}
    for file in [*source_files(REPO),ROOT/'tests/step_benchmark.adb',ROOT/'tests/step_benchmark.c']:
        rel=file.relative_to(REPO);dst=snap/rel;dst.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(file,dst)
        hashes[str(rel)]=hashlib.sha256(dst.read_bytes()).hexdigest()
    assert all(hashlib.sha256((REPO/k).read_bytes()).hexdigest()==v for k,v in hashes.items())
    project=isolated_project(snap,work,'step_benchmark')
    text=project.read_text().replace('project Fragment is', 'project Fragment is\n   for Main use ("step_benchmark.adb");\n   for Exec_Dir use "bin";\n   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-ffp-contract=off");\n   end Linker;')
    text=text.replace('"-O0", "-g", "-gnata", "-gnato", "-gnatVa"','"-O3", "-gnatp", "-gnatn", "-march=native", "-flto"')
    project.write_text(text)
    env=environment()
    with (OUT/'build.log').open('w') as log:subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    lib=next(Path(mj.__file__).parent.glob('libmujoco.so*'));cexe=work/'step_c'
    command=['gcc','-O3','-march=native','-flto','-ffp-contract=off',str(snap/(ROOT/'tests/step_benchmark.c').relative_to(REPO)), '-I'+str(REPO/'mujoco/include'), '-Wl,-rpath,'+str(lib.parent),str(lib),'-lm','-o',str(cexe)]
    subprocess.run(command,env=env,check=True)
    data=dict(ada=str(work/'bin/step_benchmark'),c=str(cexe),work=str(work),source_sha256=hashes,project=text,c_driver_command=command,
              c_library=str(lib),c_library_sha256=hashlib.sha256(lib.read_bytes()).hexdigest(),c_library_build_flags='official MuJoCo wheel; internal flags not independently controlled',
              compiler=subprocess.check_output(['gcc','--version'],env=env,text=True).splitlines()[0])
    MANIFEST.write_text(json.dumps(data,indent=2)+'\n');return data

def refresh(data):
    current = {str(p.relative_to(REPO)): hashlib.sha256(p.read_bytes()).hexdigest()
               for p in [*source_files(REPO), ROOT/'tests/step_benchmark.adb', ROOT/'tests/step_benchmark.c']}
    # Rebuild both languages and dependency closure when any build input changes.
    return data if current == data['source_sha256'] else build()

def run(data, batches=4096):
    assert all(hashlib.sha256((REPO/k).read_bytes()).hexdigest()==v for k,v in data['source_sha256'].items()),'build stale'
    allowed=sorted(os.sched_getaffinity(0));os.sched_setaffinity(0,{allowed[-1]})
    results=[]
    for arms in (1,4,8):
        xml=model(arms);m=mj.MjModel.from_xml_string(xml);path=Path(data['work'])/f'arms{arms}.mjb';mj.mj_saveModel(m,str(path));(OUT/f'arms{arms}.xml').write_text(xml)
        cpu_samples={'ada':[],'c':[]};samples={'ada':[],'c':[]};tails={'ada':[],'c':[]};checksums={}
        for rep in range(6):
            for side in (('ada','c') if rep%2==0 else ('c','ada')):
                r=subprocess.run([data[side],str(path),str(batches)],text=True,capture_output=True,check=True,timeout=120)
                values=np.array([float(x) for x in r.stdout.split()]);assert len(values)==1+2*batches
                checksums[side]=float(values[0]);times=values[1:1+batches]*1e6/64; cpu_times=values[1+batches:]*1e6/64
                (OUT/f'{arms}-{rep}-{side}.txt').write_text(r.stdout)
                if rep:cpu_samples[side].append(float(np.mean(cpu_times)));samples[side].append(float(np.mean(times)));tails[side].append(float(np.percentile(times,95)))
            np.testing.assert_allclose(checksums['ada'],checksums['c'],rtol=2e-11,atol=2e-11)
        am,cm=statistics.median(samples['ada']),statistics.median(samples['c'])
        cpu_a,cpu_c=statistics.median(cpu_samples['ada']),statistics.median(cpu_samples['c'])
        result=dict(cpu_microseconds_per_step=cpu_samples,median_cpu_ada=cpu_a,median_cpu_c=cpu_c,cpu_ada_over_c=cpu_a/cpu_c,dofs=m.nv,tendons=m.ntendon,bodies=m.nbody,steps_per_trajectory=64,trajectories_per_sample=batches,microseconds_per_step=samples,p95_trajectory_microseconds_per_step=tails,median_ada=am,median_c=cm,ada_over_c=am/cm,checksums=checksums)
        print(json.dumps(result),flush=True);results.append(result)
    (OUT/'results.json').write_text(json.dumps(dict(timestamp=datetime.now(timezone.utc).isoformat(),reference=mj.__version__,logical_cpu=allowed[-1],source_sha256=data['source_sha256'], c_library_sha256=data['c_library_sha256'], compiler=data['compiler'], project=data['project'], timers='monotonic wall clock and thread CPU clock, per trajectory',scope='full 64-step Euler trajectories; reset/input preparation/readback outside timing; one warmup and five alternating samples; shared host',results=results),indent=2)+'\n')

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--batches',type=int,default=4096);p.add_argument('--build-only',action='store_true');p.add_argument('--reuse-build',action='store_true');p.add_argument('--refresh-build',action='store_true');a=p.parse_args()
    d=json.loads(MANIFEST.read_text()) if a.reuse_build or a.refresh_build else build()
    if a.refresh_build:d=refresh(d)
    if not a.build_only:run(d,a.batches)
