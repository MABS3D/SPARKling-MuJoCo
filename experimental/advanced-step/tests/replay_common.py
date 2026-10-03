"""Replay advanced stress inputs with every actuator removed in the ordinary engine."""
from pathlib import Path
import argparse,hashlib,json,subprocess,xml.etree.ElementTree as ET
import mujoco,numpy as np
parser=argparse.ArgumentParser();parser.add_argument('--reference',type=Path,required=True);parser.add_argument('--binary',type=Path,required=True);parser.add_argument('--out',type=Path,required=True);args=parser.parse_args()
src=args.reference;out=args.out;out.mkdir(exist_ok=False)
binary=str(args.binary.resolve())
root=ET.fromstring((src/'global_disabled.xml').read_text());root.remove(root.find('actuator'));xml=ET.tostring(root,encoding='unicode');(out/'model.xml').write_text(xml)
m=mujoco.MjModel.from_xml_string(xml);orig=mujoco.MjModel.from_binary_path(str(src/'global_disabled.mjb'));mujoco.mj_saveModel(m,str(out/'model.mjb'));res=[]
for sample,line in enumerate((src/'global_disabled.input').read_text().splitlines()[1:]):
 vals=list(map(float,line.split()));steps=int(vals[0]);d=mujoco.MjData(orig);d.time=vals[1];i=2
 for arr in [d.qpos,d.qvel,d.ctrl,d.act,d.qfrc_applied,d.xfrc_applied.ravel()]:arr[:]=vals[i:i+arr.size];i+=arr.size
 ref=mujoco.MjData(m);ref.time=d.time
 for attr in ['qpos','qvel','qfrc_applied','xfrc_applied']:getattr(ref,attr)[:]=getattr(d,attr)
 data=f'1 {steps}\n'+' '.join(format(float(x),'.17g')for x in [ref.time,*ref.qpos,*ref.qvel,*ref.qfrc_applied,*ref.xfrc_applied.ravel()])+'\n'
 (out/f'sample{sample}.input').write_text(data)
 q=subprocess.run([binary,str(out/'model.mjb'),'loads','problem'],input=data,text=True,capture_output=True,timeout=30)
 assert q.returncode==0,(sample,q.returncode,q.stderr)
 (out/f'sample{sample}.output').write_text(q.stdout);(out/f'sample{sample}.problem').write_text(q.stderr)
 actual={};jac=[]
 for row in q.stdout.splitlines():
  tag,*v=row.split()
  if tag=='jac':jac.append(list(map(float,v)))
  else:
   try:actual[tag]=np.array(v,float)
   except ValueError:pass
 mujoco.mj_forward(m,ref);J=ref.efc_J.reshape(ref.nefc,m.nv);expected={'acc':ref.qacc.copy(),'free':ref.qacc_smooth.copy(),'jac':J.copy(),'aref':ref.efc_aref.copy(),'reg':ref.efc_R.copy(),'force':ref.efc_force.copy(),'qfrc':ref.qfrc_constraint.copy()};actual['jac']=np.array(jac)
 maxforce=float(np.max(np.abs(ref.efc_force)))if ref.nefc else 0
 for _ in range(steps):mujoco.mj_step(m,ref)
 expected['state']=np.r_[ref.qpos,ref.qvel,ref.time]
 errors={k:float(np.max(np.abs(actual[k]-v)))if v.size else 0 for k,v in expected.items()};entry={'sample':sample,'maxforce':maxforce,'errors':errors,'passed':all(np.allclose(actual[k],v,rtol=2e-10,atol=2e-10) for k,v in expected.items())};res.append(entry)
 if sample==6:(out/'sample6-reference.json').write_text(json.dumps({k:v.tolist()for k,v in expected.items()},indent=2))
 print(entry,flush=True)
digest=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
report=dict(reference=mujoco.mj_versionString(),binary_sha256=digest(binary),driver_sha256=digest(__file__),input_sha256=digest(src/'global_disabled.input'),source_mjb_sha256=digest(src/'global_disabled.mjb'),reduced_mjb_sha256=digest(out/'model.mjb'),cases=len(res),passed=sum(x['passed']for x in res),records=res)
(out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
raise SystemExit(report['passed']!=report['cases'])
