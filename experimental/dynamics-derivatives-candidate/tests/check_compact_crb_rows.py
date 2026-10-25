"""Direct compact CRB rows against C 3.17 mj_crb; not integrated timing.

C supplies composite inertias, spatial motions and the independent full mass.
Exercise all rows, nonzero origins, the fixed-diagonal shortcut, partial numeric
failure, maximum forest depth and preservation of every other compact row.
"""
import argparse,hashlib,importlib.util,json,shutil,subprocess
from pathlib import Path
import mujoco
import numpy as np
from build import ROOT,FOLDERS,environment,compiler_flags,linker_flags,solver_kernel_switches

def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def load(name,p):
 s=importlib.util.spec_from_file_location(name,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
 assert mujoco.__version__=='3.17.0' and mujoco.mj_version()==3_017_000
 a.out.mkdir(parents=True,exist_ok=False);source=a.build/'source';hashes=json.loads((a.build/'sources.json').read_text())
 def unchanged():return all(digest(source/n)==v for n,v in hashes.items())
 assert unchanged();shutil.copy2(Path(__file__),a.out/'runner.py')
 tests=source/'experimental/dynamics-derivatives-candidate/tests';fixture=load('compact_row_fixtures',tests/'compare.py');bench=load('compact_row_chain',tests/'benchmark_movement.py')
 selected={'slide','hinge_motor','affine_chain','branched','ball','free','free_ball','fixed_tendon','spatial_ball'}
 fixtures=[(name,xml) for name,xml,_ in fixture.fixtures(source/'experimental/adhesion-contact-integration/tests/compare_adhesion.py','3.17.0') if name in selected]
 fixtures += [('chain_24',bench.chain(24)),('branches_24',bench.chain(24,True)),('chain_256',bench.chain(256))]
 rng=np.random.default_rng(20261025366);cases=[];simple_rows=0
 for name,xml in fixtures:
  model=mujoco.MjModel.from_xml_string(xml);assert model.nv in range(1,257)
  (a.out/(name+'.xml')).write_text(xml)
  for state in range(3):
   data=mujoco.MjData(model);q=model.qpos0.copy();mujoco.mj_integratePos(model,q,rng.uniform(-.3,.3,model.nv),.1);data.qpos[:]=q
   mujoco.mj_forward(model,data);mujoco.mj_crb(model,data)
   dense=np.empty((model.nv,model.nv));mujoco.mj_fullM(model,data,dense)
   for row in range(model.nv):
    ancestors=[];j=row
    while j>=0:ancestors.append(j);j=int(model.dof_parentid[j])
    ancestors.reverse();simple=bool(model.dof_simplenum[row]);simple_rows+=simple
    cases.append(dict(key=f'{name}-{state}-{row}',n=model.nv,row=row,origin=(0,7,100000)[state],simple=simple,parents=model.dof_parentid.tolist(),motions=data.cdof.ravel().tolist(),composite=data.crb[model.dof_bodyid[row]].tolist(),arm=float(model.dof_armature[row]),fixed=float(model.dof_M0[row]),accepted=True,expected=dense[row,ancestors].tolist()))
 # Analytic controls: rejection at the diagonal or a later ancestor leaves a
 # bounded partial row, while a simple row ignores huge projection inputs.
 for origin in [0,7,2**31-3]:
  for row,reject_at in [(0,0),(2,2),(2,1),(2,0)]:
   motion=np.zeros((3,6));motion[reject_at,3]=1e12;motion[row,3]=1e12 if row==reject_at else 1e9
   composite=np.zeros(10);composite[9]=1e40
   cases.append(dict(key=f'limit-{origin}-{row}-{reject_at}',n=3,row=row,origin=origin,simple=False,parents=[-1,0,1],motions=motion.ravel().tolist(),composite=composite.tolist(),arm=0.,fixed=2e10,accepted=False,expected=None))
  cases.append(dict(key=f'fixed-{origin}',n=3,row=2,origin=origin,simple=True,parents=[-1,0,1],motions=np.full(18,1e12).tolist(),composite=np.full(10,1e40).tolist(),arm=1e10,fixed=2e10,accepted=True,expected=[0.,0.,2e10]))
 lines=[str(len(cases))]
 for c in cases:lines.append(' '.join(str(x) for x in [c['n'],c['row'],c['origin'],int(c['simple']),*c['parents']])+ ' '+ ' '.join(format(float(x),'.17g') for x in [*c['motions'],*c['composite'],c['arm'],c['fixed']]))
 inputs='\n'.join(lines)+'\n';(a.out/'cases.input').write_text(inputs);(a.out/'cases.json').write_text(json.dumps(cases,indent=2)+'\n');records=[]
 for mode in ['validation','release']:
  flags=compiler_flags(mode)
  work=a.out/mode;work.mkdir();project=work/'rows.gpr';project.write_text('project Rows is\n for Source_Dirs use ('+', '.join('"'+str(source/f)+'"' for f in FOLDERS)+');\n for Object_Dir use "obj";\n for Exec_Dir use "bin";\n for Create_Missing_Dirs use "True";\n for Main use ("compact_crb_rows_probe.adb");\n package Compiler is\n'+solver_kernel_switches(mode,flags)+' for Default_Switches ("Ada") use ('+', '.join('"'+f+'"' for f in flags)+');\n end Compiler;\n package Linker is\n for Default_Switches ("Ada") use ('+', '.join('"'+f+'"' for f in linker_flags(mode))+');\n end Linker;\nend Rows;\n')
  command=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','600','--','gprbuild','-P',str(project),'-j1']
  with (work/'build.log').open('w') as log:run=subprocess.run(command,env=environment(),stdout=log,stderr=subprocess.STDOUT)
  assert run.returncode==0,(work/'build.log').read_text()[-5000:]
  binary=work/'bin/compact_crb_rows_probe';run=subprocess.run([str(binary)],input=inputs,capture_output=True,text=True,timeout=180);(work/'output.txt').write_text(run.stdout+run.stderr);assert run.returncode==0,run.stderr
  rows=[x.split() for x in run.stdout.splitlines()];assert len(rows)==len(cases);maximum=0.;checks=0
  for c,r in zip(cases,rows):
   assert r[:2]==['row',str(c['accepted']).upper()],(c['key'],r[:2]);values=np.asarray(r[2:],float);assert np.all(np.isfinite(values)) and np.all(np.abs(values)<=1e60),c['key']
   if c['expected'] is not None:
    expected=np.asarray(c['expected']);assert values.shape==expected.shape and np.allclose(values,expected,atol=1e-13,rtol=1e-13),(c['key'],values,expected);maximum=max(maximum,float(np.max(np.abs(values-expected))));checks+=len(values)
  records.append(dict(mode=mode,flags=flags,cases=len(cases),checked_values=checks,max_abs_c=maximum,passed=True,binary_sha256=digest(binary),command=command));print(mode,len(cases),'passed',maximum,flush=True)
 assert unchanged();lib=Path(mujoco.__file__).parent/'libmujoco.so.3.17.0'
 (a.out/'results.json').write_text(json.dumps(dict(passed=True,reference='3.17.0',library_sha256=digest(lib),runner_sha256=digest(Path(__file__)),source_hashes_unchanged=True,sources_sha256=digest(a.build/'sources.json'),c_rows=sum(c['key'].split('-')[0] not in ['limit','fixed'] for c in cases),simple_reference_rows=int(simple_rows),records=records,scope='Direct compact row numeric oracle and frame, not composite accumulation, simulation cache publication, integration or performance.'),indent=2)+'\n')
if __name__=='__main__':main()
