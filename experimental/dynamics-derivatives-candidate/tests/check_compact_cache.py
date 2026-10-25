"""Observe the real canonical path, dense boundary, lifetime and both policies.

A test-only Ada child reads the actual mode flag and checks that the legacy dense
slab stays untouched on the normal compact route. The C oracle is independent.
"""
import argparse,hashlib,importlib.util,json,shutil,subprocess
from pathlib import Path
import mujoco
import numpy as np
from build import ROOT,FOLDERS,environment,compiler_flags,linker_flags,solver_kernel_switches

def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();assert mujoco.__version__=='3.17.0';a.out.mkdir(exist_ok=False,parents=True);source=a.build/'source';h=json.loads((a.build/'sources.json').read_text());assert all(sha(source/n)==v for n,v in h.items());shutil.copy2(Path(__file__),a.out/'runner.py')
 tests=source/'experimental/dynamics-derivatives-candidate/tests';sp=importlib.util.spec_from_file_location('compact_cache_fixtures',tests/'compare.py');fixture=importlib.util.module_from_spec(sp);sp.loader.exec_module(fixture)
 selected={'slide','hinge_motor','affine_chain','branched','ball','free','free_ball','fixed_tendon','spatial_ball'}
 fixtures=[(n,x) for n,x,_ in fixture.fixtures(source/'experimental/adhesion-contact-integration/tests/compare_adhesion.py','3.17.0') if n in selected]
 sp=importlib.util.spec_from_file_location('compact_cache_chains',tests/'benchmark_movement.py');bench=importlib.util.module_from_spec(sp);sp.loader.exec_module(bench)
 fixtures += [('chain_24',bench.chain(24)),('branches_24',bench.chain(24,True))]
 fixtures.append(('independent_tendon','''<mujoco><option timestep=".002"><flag constraint="disable" warmstart="disable" island="disable"/></option><worldbody><body><joint name="a" type="slide" axis="1 0 0"/><geom size=".1" mass="1"/></body><body pos="1 0 0"><joint name="b" type="slide" axis="1 0 0"/><geom size=".1" mass="2"/></body><body pos="2 0 0"><joint type="slide"/><geom size=".1" mass=".3"/></body></worldbody><tendon><fixed armature=".5"><joint joint="a" coef="1"/><joint joint="b" coef="1"/></fixed></tendon></mujoco>'''))
 rng=np.random.default_rng(20261025397);cases=[]
 for name,xml in fixtures:
  m=mujoco.MjModel.from_xml_string(xml);path=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(a.out/(name+'.xml')).write_text(xml);batch=[];expected=[];expected_velocity=[]
  for _ in range(3):
   q=m.qpos0.copy();mujoco.mj_integratePos(m,q,rng.uniform(-.3,.3,m.nv),.1);v=rng.uniform(-.2,.2,m.nv);batch.append(np.r_[q,v]);d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;d.time=.125;mujoco.mj_forward(m,d);dense=np.empty((m.nv,m.nv));mujoco.mj_fullM(m,d,dense);expected.append(dense.ravel().tolist());mujoco.mj_Euler(m,d);expected_velocity.append(d.qvel.copy())
  inputs='3\n'+'\n'.join(' '.join(format(float(x),'.17g') for x in row) for row in batch)+'\n';(a.out/(name+'.input')).write_text(inputs);cases.append((name,path,inputs,np.asarray(expected),m.nv,np.asarray(expected_velocity)))
 records=[]
 for mode in ['validation','release']:
  flags=compiler_flags(mode)
  work=a.out/mode;work.mkdir();project=work/'cache.gpr';project.write_text('project Cache is\n for Source_Dirs use ('+', '.join('"'+str(source/f)+'"' for f in FOLDERS)+');\n for Object_Dir use "obj";\n for Exec_Dir use "bin";\n for Create_Missing_Dirs use "True";\n for Main use ("mj-data-compact_cache_probe.adb");\n package Compiler is\n'+solver_kernel_switches(mode,flags)+' for Default_Switches ("Ada") use ('+', '.join('"'+f+'"' for f in flags)+');\n end Compiler;\n package Linker is\n for Default_Switches ("Ada") use ('+', '.join('"'+f+'"' for f in linker_flags(mode))+');\n end Linker;\nend Cache;\n')
  cmd=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','600','--','gprbuild','-P',str(project),'-j1']
  with (work/'build.log').open('w') as log:r=subprocess.run(cmd,env=environment(),stdout=log,stderr=subprocess.STDOUT)
  assert r.returncode==0,(work/'build.log').read_text()[-5000:];binary=work/'bin/mj-data-compact_cache_probe'
  for policy in ['compatible','strict']:
   for name,path,inputs,expected,nv,expected_velocity in cases:
    run=subprocess.run([str(binary),str(path),policy],input=inputs,capture_output=True,text=True,timeout=120);(work/(name+'-'+policy+'.output')).write_text(run.stdout+run.stderr);assert run.returncode==0,(name,mode,policy,run.stdout[-1000:],run.stderr[-3000:]);rows=[r.split() for r in run.stdout.splitlines()];assert len(rows)==6 and all(r[0]=='mass' for r in rows[::2]) and all(r[0]=='euler_velocity' for r in rows[1::2]);actual=np.asarray([[float(x) for x in r[1:]] for r in rows[::2]]);actual_velocity=np.asarray([[float(x) for x in r[1:]] for r in rows[1::2]]);assert np.allclose(actual,expected,atol=1e-13,rtol=1e-13),(name,policy,np.max(np.abs(actual-expected)));assert np.allclose(actual_velocity,expected_velocity,atol=1e-13,rtol=1e-13),(name,policy,'Euler velocity',np.max(np.abs(actual_velocity-expected_velocity)))
    records.append(dict(mode=mode,policy=policy,model=name,nv=nv,samples=3,passed=True,max_abs_c=float(np.max(np.abs(actual-expected))),max_abs_euler_velocity_c=float(np.max(np.abs(actual_velocity-expected_velocity))),binary_sha256=sha(binary)));print(mode,policy,name,'passed',flush=True)
 assert all(sha(source/n)==v for n,v in h.items());(a.out/'results.json').write_text(json.dumps(dict(passed=True,source_hashes_unchanged=True,sources_sha256=sha(a.build/'sources.json'),reference='3.17.0',records=records,flags='Validation and strict movement-release flags; no suppressions.',scope='Actual cache selection, no dense writes on normal nv>=3 route, public dense expansion, unchanged stored mass across both factor policies, stale rejection and owned-model lifetime; both-policy damped Euler velocity against actual C mj_Euler, including chain/branch 24 DOF.'),indent=2)+'\n')
if __name__=='__main__':main()
