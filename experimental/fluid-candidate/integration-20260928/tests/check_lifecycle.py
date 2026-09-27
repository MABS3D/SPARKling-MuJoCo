import os,sys,json,subprocess
from pathlib import Path
repo=Path(__file__).resolve().parents[1] / 'work'
sys.path.insert(0,str(repo/'experimental/smooth/tools'))
from prove_fragments import isolated_project
out=repo.parent/'lifecycle-tests';out.mkdir(exist_ok=True)
project=isolated_project(repo,out,'fluid_lifecycle_probe')
project.write_text(project.read_text().replace('project Fragment is','project Fragment is\n   for Main use ("fluid_lifecycle_probe.adb");\n   for Exec_Dir use "bin";'))
env=os.environ.copy();toolchain=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
env['PATH']=os.pathsep.join(str(p) for name in ('gnat','gprbuild','gnatprove') for p in (toolchain/name).glob('*/bin'))+os.pathsep+env['PATH']
with (out/'build.log').open('w') as log: subprocess.run(['gprbuild','-P',str(project),'-j2'],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
rows=[]
for fixture in ['fluid_box_chain24','fluid_ellipsoid_multiple']:
 r=subprocess.run([str(out/'bin/fluid_lifecycle_probe'),str(repo.parent/'tests/verified-strict'/f'{fixture}.mjb')],env=env,capture_output=True,text=True)
 rows.append(dict(fixture=fixture,exit=r.returncode,stdout=r.stdout,stderr=r.stderr));print(rows[-1])
(out/'results.json').write_text(json.dumps(rows,indent=2))
assert all(x['exit']==0 for x in rows)
