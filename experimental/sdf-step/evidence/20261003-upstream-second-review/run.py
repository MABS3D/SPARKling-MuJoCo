from pathlib import Path
import subprocess,json,hashlib,shutil
w=Path(__file__).resolve().parent;old=Path('/var/tmp/sparkling-upstream-sdf-review-20261003');runs=[];files=[w/'independent_probe.c'];builds=[]
configs=[('stable',Path('/var/tmp/sparkling-movement-env/lib/python3.12/site-packages/mujoco'),False,'3.14.0'),('main-double',old/'double/lib',False,'3.14.1'),('main-single',old/'single/lib',True,'3.14.1')]
for profile,lib,single,ver in configs:
 inc=Path('/var/tmp/sparkling-movement-env/lib/python3.12/site-packages/mujoco/include') if profile=='stable' else old/'source/include'
 binary=w/profile;so=lib/('libmujoco.so.'+ver);files.extend([so,binary])
 cmd=['gcc','-O1','-Wall','-Wextra',*(['-DmjUSESINGLE'] if single else []),'-I'+str(inc),str(w/'independent_probe.c'),str(so),'-Wl,-rpath,'+str(lib),'-o',str(binary)]
 r=subprocess.run(cmd,text=True,capture_output=True,timeout=30);builds.append({'command':cmd,'exit':r.returncode,'output':r.stdout+r.stderr});r.check_returncode()
 for order in ['mesh-first','sdf-first']:
  for n in [1,2,4,40,50,80]:
   template=(old/f'cases/mesh-{order}-p1.xml').read_text();p=w/f'{order}-{n}.xml';p.write_text(template.replace('sdf_initpoints="1"',f'sdf_initpoints="{n}"'));files.append(p)
   for threads in [0,2]:
    cmd=[str(binary),str(p),str(threads),'0'];r=subprocess.run(cmd,cwd=w,text=True,capture_output=True,timeout=20)
    runs.append({'profile':profile,'order':order,'initpoints':n,'threads':threads,'command':cmd,'exit':r.returncode,'output':r.stdout+r.stderr})
 # fatal is deliberate, child process isolated
 if profile=='stable':
  cmd=[str(binary),str(w/'sdf-first-1.xml'),'0','1'];r=subprocess.run(cmd,cwd=w,text=True,capture_output=True,timeout=20);runs.append({'profile':profile,'forced_driver':True,'command':cmd,'exit':r.returncode,'output':r.stdout+r.stderr})
for profile in ['double','single']:
 cmd=[str(old/profile/'bin/engine_collision_driver_test'),'--gtest_color=no'];r=subprocess.run(cmd,cwd=w,text=True,capture_output=True,timeout=60);runs.append({'profile':profile,'gtest':True,'command':cmd,'exit':r.returncode,'output':r.stdout+r.stderr})
(w/'results.json').write_text(json.dumps(runs,indent=2)+'\n');(w/'builds.json').write_text(json.dumps(builds,indent=2)+'\n');(w/'manifest.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in set(files)},indent=2)+'\n')
for profile,_,_,_ in configs:
 rs=[r for r in runs if r['profile']==profile and 'order' in r];print(profile,len(rs),'valid capacity',sum(r['exit']==0 for r in rs),'unsafe',sum(r['exit']==10 for r in rs),'other',[(r['exit'],r['output']) for r in rs if r['exit']not in[0,10]])
for r in runs:
 if 'order' not in r: print(r['profile'],r['exit'],r['output'][-250:])
