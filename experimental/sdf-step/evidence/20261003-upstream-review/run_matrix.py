from pathlib import Path
import subprocess,json,sys,hashlib
base=Path(__file__).resolve().parent; build=base/sys.argv[1]; name=sys.argv[2]; source=base/'source'; out=base/name;out.mkdir(exist_ok=True)
flags=['-DmjUSESINGLE'] if 'single' in sys.argv[1] else []
cmd=['gcc','-O1','-g',*flags,'-I'+str(source/'include'),'-I'+str(source),str(base/'case_probe.c'),'-L'+str(build/'lib'),'-lmujoco','-Wl,-rpath,'+str(build/'lib'),'-o',str(out/'case_probe')]
r=subprocess.run(cmd,capture_output=True,text=True);(out/'build.log').write_text(r.stdout+r.stderr);r.check_returncode();runs=[]
files=[source/'src/engine/engine_collision_driver.c',source/'src/engine/engine_collision_sdf.c',source/'test/engine/engine_collision_driver_test.cc',build/'lib/libmujoco.so.3.14.1',base/'case_probe.c',out/'case_probe']
(out/'manifest.json').write_text(json.dumps({str(f):hashlib.sha256(f.read_bytes()).hexdigest() for f in files},indent=2))
for case in json.loads((base/'cases.json').read_text()):
 for threads in [0,2]:
  cmd=[str(out/'case_probe'),case['xml'],str(threads)];r=subprocess.run(cmd,capture_output=True,text=True,timeout=30,cwd=out);log=case['name']+f'-t{threads}.log';(out/log).write_text(r.stdout+r.stderr)
  lines=r.stdout.splitlines();runs.append(dict(**case,threads=threads,exit=r.returncode,log=log,header=lines[0] if lines else '',contacts=lines[1:] if r.returncode==0 else [],command=cmd))
(out/'results.json').write_text(json.dumps(runs,indent=2));print(name,'passed',sum(x['exit']==0 for x in runs),'/',len(runs));print('failed',[(x['name'],x['threads'],x['exit']) for x in runs if x['exit']])
