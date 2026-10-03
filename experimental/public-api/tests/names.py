"""Loaded native name hash tables against mj_name2id/mj_id2name."""
import argparse, hashlib, json, subprocess
from pathlib import Path
import mujoco
p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
assert mujoco.__version__=='3.14.0'
xml='''<mujoco model="names"><asset><material name="material"/><mesh name="tetra" vertex="0 0 0  1 0 0  0 1 0  0 0 1"/></asset><worldbody><light name="sun"/><camera name="camera"/><body name="corpo_à" pos="0 0 1"><joint name="hinge"/><geom name="sphere" size=".1"/><site name="site"/></body><body name="body2" pos="1 0 1"><joint name="j2"/><geom name="g2" size=".1"/></body></worldbody><contact><pair name="pair" geom1="sphere" geom2="g2"/><exclude name="exclude" body1="corpo_à" body2="body2"/></contact><equality><joint name="equal" joint1="hinge" joint2="j2"/></equality><tendon><fixed name="tendon"><joint joint="hinge" coef="1"/></fixed></tendon><actuator><motor name="motor" joint="hinge"/></actuator><sensor><jointpos name="sensor" joint="hinge"/></sensor><custom><numeric name="numbers" data="1 2"/><text name="text" data="abc"/><tuple name="tuple"><element objtype="body" objname="corpo_à"/></tuple></custom><keyframe><key name="key"/></keyframe></mujoco>'''
m=mujoco.MjModel.from_xml_string(xml);file=a.out/'names.mjb';mujoco.mj_saveModel(m,str(file));(a.out/'names.xml').write_text(xml)
counts={1:m.nbody,2:m.nbody,3:m.njnt,4:m.nv,5:m.ngeom,6:m.nsite,7:m.ncam,8:m.nlight,9:m.nflex,10:m.nmesh,11:m.nskin,12:m.nhfield,13:m.ntex,14:m.nmat,15:m.npair,16:m.nexclude,17:m.neq,18:m.ntendon,19:m.nu,20:m.nsensor,21:m.nnumeric,22:m.ntext,23:m.ntuple,24:m.nkey,25:m.nplugin}
requests=[];expected=[]
for kind in list(range(26))+[100,101,102]:
 count=counts.get(kind,0)
 names=[]
 for i in range(-1,count+1):
  name=mujoco.mj_id2name(m,kind,i)
  requests.append(f'2 {kind} {i}');expected.append(name.encode().hex() if name else '-')
  if name:names.extend([name,name+'x',name.upper(),name+'\0ignored'])
 for name in names+['','missing','world','corpo_à','corpo_ä']:
  requests.append(f'1 {kind} {name.encode().hex()}');expected.append(str(mujoco.mj_name2id(m,kind,name)))
data='\n'.join(requests)+'\n';(a.out/'input.txt').write_text(data)
r=subprocess.run([str(a.binary),str(file)],input=data,text=True,capture_output=True,check=True)
actual=r.stdout.splitlines();failures=[]
assert len(actual)==len(expected),(len(actual),len(expected))
for req,x,y in zip(requests,actual,expected):
 if x.strip()!=y:failures.append(dict(request=req,ada=x.strip(),c=y))
report=dict(reference=mujoco.__version__,cases=len(expected),passed=len(expected)-len(failures),failures=failures,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),test_source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
(a.out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report));assert not failures
