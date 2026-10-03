"""Freeze identical-C-state diagnostics and independent prefix trajectories."""
import argparse,hashlib,json,subprocess
from pathlib import Path
import mujoco,numpy as np
from compare import base

def dense_jac(m,d):
 j=np.zeros((d.nefc,m.nv))
 if mujoco.mj_isSparse(m):
  for i in range(d.nefc):
   adr=d.efc_J_rowadr[i];n=d.efc_J_rownnz[i]
   j[i,d.efc_J_colind[adr:adr+n]]=d.efc_J[adr:adr+n]
 else:j[:]=d.efc_J.reshape(d.nefc,m.nv)
 return j

def main():
 p=argparse.ArgumentParser();p.add_argument('--case',type=Path,required=True)
 p.add_argument('--binary',type=Path,action='append',required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--frames',type=int,default=100);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 model=next(a.case.glob('*.mjb'));original=next(a.case.glob('*.input')).read_text()
 m=mujoco.MjModel.from_binary_path(str(model));values=np.fromstring(original.split('\n',1)[1],sep=' ')
 size=1+m.nq+2*m.nv+m.nu+m.na+6*m.nbody;initial=values[:size].copy()
 d=mujoco.MjData(m);offset=1;d.time=initial[0]
 for target in (d.qpos,d.qvel,d.qfrc_applied,d.ctrl,d.act,d.xfrc_applied):
  count=target.size;target[:]=initial[offset:offset+count].reshape(target.shape);offset+=count
 expected=[];states=[];inputs=[]
 for frame in range(a.frames+1):
  mujoco.mj_forward(m,d)
  expected.append({k:np.asarray(v).copy() for k,v in dict(counts=[d.ncon,d.nefc],free=d.qacc_smooth,
    acc=d.qacc,qfrc=d.qfrc_constraint,jac=dense_jac(m,d),aref=d.efc_aref,reg=d.efc_R,force=d.efc_force).items()})
  states.append(np.r_[d.qpos,d.qvel,d.time]);inputs.extend([d.time,*d.qpos,*d.qvel,*d.qfrc_applied,*d.ctrl,*d.act,*d.xfrc_applied.ravel()])
  if frame<a.frames:mujoco.mj_step(m,d)
 data=f'{a.frames+1} 0\n'+' '.join(format(x,'.17g') for x in inputs)+'\n'
 (a.out/'states.input').write_text(data)
 (a.out/'expected.json').write_text(json.dumps([{k:v.tolist() for k,v in e.items()} for e in expected])+'\n')
 results=dict(reference=mujoco.__version__,model_sha256=hashlib.sha256(model.read_bytes()).hexdigest(),
   script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
   library_sha256=hashlib.sha256((Path(mujoco.__file__).parent/'libmujoco.so.3.14.0').read_bytes()).hexdigest(),binaries=[])
 for index,binary in enumerate(a.binary):
  folder=a.out/str(index);folder.mkdir()
  run=subprocess.run([str(binary),str(model),'loads'],input=data,text=True,capture_output=True,timeout=180)
  (folder/'states.output').write_text(run.stdout+run.stderr)
  row=dict(path=str(binary),sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),exit=run.returncode,frames=[],prefixes=[])
  if run.returncode==0:
   actual=base.parse(run.stdout,m.nv,m.na)
   for frame,(x,y) in enumerate(zip(actual,expected)):
    errors={k:float(np.max(np.abs(x[k]-v))) if x[k].shape==v.shape and v.size else
      (0.0 if x[k].shape==v.shape else None) for k,v in y.items()}
    row['frames'].append(dict(frame=frame,errors=errors))
  for frame in sorted({0,1,2,5,10,20,30,50,75,a.frames}):
   if frame>a.frames:continue
   prefix=f'1 {frame}\n'+' '.join(format(x,'.17g') for x in initial)+'\n'
   (folder/f'prefix-{frame}.input').write_text(prefix)
   run=subprocess.run([str(binary),str(model),'loads'],input=prefix,text=True,capture_output=True,timeout=180)
   (folder/f'prefix-{frame}.output').write_text(run.stdout+run.stderr)
   actual=base.parse(run.stdout,m.nv,m.na)[0] if run.returncode==0 else None
   row['prefixes'].append(dict(frame=frame,exit=run.returncode,
     state_error=float(np.max(np.abs(actual['state']-states[frame]))) if actual else None))
  results['binaries'].append(row);(a.out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
  print(binary, 'same-state max', {k:max((f['errors'][k] or 0) for f in row['frames']) for k in expected[0]},'prefixes',row['prefixes'],flush=True)
if __name__=='__main__':main()
