from pathlib import Path
import sys,subprocess,json,numpy as np,mujoco
root=Path(__file__).resolve().parent;sys.path.insert(0,str(root.parents[2]/'experimental/smooth/tools'));import compare_numerics as h
probe=Path(sys.argv[1]);out=Path(sys.argv[2]);out.mkdir(exist_ok=False);reports=[]
body='<body><joint name="j" type="slide"/><inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/></body>'
for kind in ['integrator','filter']:
 for early in ['false','true']:
  name=kind+'-'+early;act=f'<general joint="j" dyntype="{kind}" dynprm="1e-15" actearly="{early}" gainprm="1e-10"/>'
  xml=h.model_xml(body,act,gravity='0 0 0');m=mujoco.MjModel.from_xml_string(xml);path=out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));initial=1e10 if kind=='integrator' else 1.;ctrl=1. if kind=='integrator' else 1e10;data=f'1\n0 0 {ctrl} 0 {initial} .125 1\n';(out/(name+'.input')).write_text(data)
  r=subprocess.run([str(probe),str(path)],input=data,text=True,capture_output=True,timeout=60);(out/(name+'.output')).write_text(r.stdout+r.stderr);assert r.returncode==0,(name,r.stderr);row,=h.parse_output(r.stdout)
  assert row['forward']==('SUCCESS' if early=='false' else 'NUMERIC_LIMIT') and row['step']=='NUMERIC_LIMIT',(name,row)
  assert row['qpos'][0]==0 and row['qvel'][0]==0 and row['time'][0]==.125 and row['act'][0]==initial
  reports.append(dict(name=name,forward=row['forward'],step=row['step'],complete_state_unchanged=True))
(out/'summary.json').write_text(json.dumps(reports,indent=2));print(reports)
