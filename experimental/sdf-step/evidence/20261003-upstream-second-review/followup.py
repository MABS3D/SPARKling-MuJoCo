from pathlib import Path
import subprocess,json
w=Path(__file__).resolve().parent;old=Path('/var/tmp/sparkling-upstream-sdf-review-20261003');runs=[]
for profile in ['double','single']:
 cmd=[str(old/profile/'bin/engine_collision_driver_test'),'--gtest_color=no'];r=subprocess.run(cmd,cwd=old/'source/test',text=True,capture_output=True,timeout=60);runs.append({'kind':'gtest-correct-cwd','profile':profile,'command':cmd,'cwd':str(old/'source/test'),'exit':r.returncode,'output':r.stdout+r.stderr});print(profile,r.returncode,r.stdout[-170:])
 # multipair reuses minimal forward harness, no rebuilding
 for n in [1,4]:
  for t in [0,2]:
   cmd=[str(old/f'repro-main-{profile}'),str(old/f'multipair-33-p{n}.xml'),str(t)];r=subprocess.run(cmd,cwd=w,text=True,capture_output=True,timeout=30);runs.append({'kind':'multipair','profile':profile,'initpoints':n,'threads':t,'command':cmd,'exit':r.returncode,'output':r.stdout+r.stderr});print(profile,n,t,r.returncode,r.stdout.strip())
base=(w/'sdf-first-1.xml').read_text()
for name,text in [('slide',base.replace('<freejoint/>','<joint type="slide"/>')),('zero-yz',base.replace('.24 .019 .013','.24 0 0')),('slide-zero-yz',base.replace('<freejoint/>','<joint type="slide"/>').replace('.24 .019 .013','.24 0 0'))]:
 p=w/(name+'.xml');p.write_text(text);cmd=[str(w/'stable'),str(p),'0','0'];r=subprocess.run(cmd,cwd=w,text=True,capture_output=True,timeout=30);runs.append({'kind':'minimal-ablation','name':name,'command':cmd,'exit':r.returncode,'output':r.stdout+r.stderr});print(name,r.returncode,r.stdout.strip())
(w/'followup-results.json').write_text(json.dumps(runs,indent=2)+'\n')
