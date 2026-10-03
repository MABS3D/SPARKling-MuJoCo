"""Exercise failure after successful force evaluation and compare a clean retry to C."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare import model, parse

p=argparse.ArgumentParser()
p.add_argument('--bin-dir',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
results=[]
for constrained in [False,True]:
    label='constrained' if constrained else 'smooth'
    xml=model('<pid joint="j" kp="0" kv="0" ki=".1" imax="0" input="pos" forcelimited="true" forcerange="-.2 .2"/>')
    if constrained:
        xml=xml.replace('constraint="disable"','constraint="enable" warmstart="disable" island="disable"')
        xml=xml.replace('name="j" damping=".01"','name="j" damping=".01" limited="true" range="-1 1" frictionloss=".002"')
        xml=xml.replace('<worldbody>','<worldbody><geom type="plane" size="3 3 .1" pos="0 0 -.095" friction=".6 .01 .001"/>')
    m=mujoco.MjModel.from_xml_string(xml);m.actuator_actearly[:]=0
    path=a.out/(label+'.mjb');mujoco.mj_saveModel(m,str(path));(a.out/(label+'.xml')).write_text(xml)
    binary=a.bin_dir/('constrained_advanced_edges' if constrained else 'advanced_edges')
    r=subprocess.run([str(binary),str(path)],capture_output=True,text=True,timeout=40)
    (a.out/(label+'-edges.log')).write_text(r.stdout+r.stderr)
    record=dict(model=label,command=[str(binary),str(path)],exit=r.returncode,output=r.stdout+r.stderr,
                binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest())
    results.append(record)
    # Native edge test compares retry with fresh step exactly. Independently
    # compare that fresh step through the same production adapter with MuJoCo.
    probe=a.bin_dir/('constrained_advanced_probe' if constrained else 'advanced_probe')
    for sign in [1,-1]:
        d=mujoco.MjData(m);d.ctrl[0]=sign
        data='1\n'+' '.join(format(float(x),'.17g')for x in [1,0,*d.qpos,*d.qvel,*d.ctrl,*d.act,*d.qfrc_applied])+'\n'
        mujoco.mj_step(m,d);expected=np.r_[d.qpos,d.qvel,d.time,d.act]
        q=subprocess.run([str(probe),str(path)],input=data,capture_output=True,text=True,timeout=40)
        try:
            got=parse(q.stdout)[0];passed=q.returncode==0 and got['step']=='SUCCESS' and np.allclose(got['state'],expected,atol=2e-10,rtol=2e-10)
        except Exception:passed=False
        results.append(dict(model=label,sign=sign,fresh_reference_passed=bool(passed),exit=q.returncode,output=q.stdout+q.stderr,
            binary_sha256=hashlib.sha256(probe.read_bytes()).hexdigest()))
    print(label,'edge exit',r.returncode,flush=True)
(a.out/'results.json').write_text(json.dumps(dict(reference=mujoco.__version__,records=results),indent=2)+'\n')
raise SystemExit(not all(x['exit']==0 and x.get('fresh_reference_passed',True)for x in results))
