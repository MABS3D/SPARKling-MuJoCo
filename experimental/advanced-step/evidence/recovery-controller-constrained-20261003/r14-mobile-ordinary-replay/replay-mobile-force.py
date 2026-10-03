from pathlib import Path
import json,hashlib,subprocess,xml.etree.ElementTree as ET
import numpy as np,mujoco
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');src=Path('/var/tmp/sparkling-services-advanced-constrained-r14-mobile-20261003');out=Path('/var/tmp/sparkling-services-advanced-mobile-ordinary-replay-20261003');out.mkdir(exist_ok=False);name='so3_sites_expmap';sample=4
orig=mujoco.MjModel.from_binary_path(str(src/(name+'.mjb')));vals=list(map(float,(src/(name+'.input')).read_text().splitlines()[sample+1].split()));d=mujoco.MjData(orig);d.time=vals[1];i=2
for target in (d.qpos,d.qvel,d.ctrl,d.act,d.qfrc_applied,d.xfrc_applied.ravel()):target[:]=vals[i:i+target.size];i+=target.size
mujoco.mj_forward(orig,d);controller={k:getattr(d,k).copy()for k in ['actuator_length','actuator_velocity','actuator_force','qfrc_actuator','qacc','qacc_smooth','efc_J','efc_aref','efc_R','efc_force','qfrc_constraint']}
xml=ET.fromstring((src/(name+'.xml')).read_text());xml.remove(xml.find('actuator'));(out/'model.xml').write_text(ET.tostring(xml,encoding='unicode'));m=mujoco.MjModel.from_xml_path(str(out/'model.xml'));mujoco.mj_saveModel(m,str(out/'model.mjb'));v=mujoco.MjData(m);v.time=d.time
for k in ['qpos','qvel','xfrc_applied']:getattr(v,k)[:]=getattr(d,k)
v.qfrc_applied[:]=d.qfrc_applied+controller['qfrc_actuator']
input_values=[v.time,*v.qpos,*v.qvel,*v.qfrc_applied,*v.xfrc_applied.ravel()];data='1 0\n'+' '.join(format(float(x),'.17g')for x in input_values)+'\n';(out/'input.txt').write_text(data)
binary=Path('/var/tmp/sparkling-services-advanced-constrained-r14-r2-20261003/build/validation/bin/constrained_probe');p=subprocess.run([str(binary),str(out/'model.mjb'),'loads','problem'],input=data,text=True,capture_output=True,timeout=30);(out/'output.txt').write_text(p.stdout);(out/'problem.txt').write_text(p.stderr);assert p.returncode==0
mujoco.mj_forward(m,v);actual={};jac=[]
for row in p.stdout.splitlines():
 tag,*values=row.split()
 if tag=='jac':jac.append(list(map(float,values)))
 else:
  try:actual[tag]=np.array(values,float)
  except ValueError:pass
actual['jac']=np.array(jac);expected={'acc':v.qacc.copy(),'free':v.qacc_smooth.copy(),'jac':v.efc_J.reshape(v.nefc,m.nv).copy(),'aref':v.efc_aref.copy(),'reg':v.efc_R.copy(),'force':v.efc_force.copy(),'qfrc':v.qfrc_constraint.copy()}
full_m=np.zeros((m.nv,m.nv));mujoco.mj_fullM(m,v,full_m)
(out/'reference.json').write_text(json.dumps({**{k:x.tolist()for k,x in expected.items()},'mass':full_m.tolist()},indent=2)+'\n')
(out/'controller-reference.json').write_text(json.dumps({k:x.tolist()for k,x in controller.items()},indent=2)+'\n')
(out/'original-controller.input').write_text('1\n'+(src/(name+'.input')).read_text().splitlines()[sample+1]+'\n')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest();report=dict(reference=mujoco.__version__,model=name,sample=sample,binary_sha256=sha(binary),driver_sha256=sha(__file__),source_mjb_sha256=sha(src/(name+'.mjb')),input_sha256=sha(out/'input.txt'),ordinary_mjb_sha256=sha(out/'model.mjb'),scope='instantaneous ordinary replay; original C controller force added once to applied input; not a constant-force trajectory equivalence claim',errors={k:float(np.max(np.abs(actual[k]-x)))if x.size else 0 for k,x in expected.items()},ordinary_vs_original_C={k:float(np.max(np.abs(getattr(v,k)-controller[k])))if controller[k].size else 0 for k in ['qacc','qacc_smooth','efc_J','efc_aref','efc_R','efc_force','qfrc_constraint']})
(out/'results.json').write_text(json.dumps(report,indent=2)+'\n');print(json.dumps(report,indent=2))
