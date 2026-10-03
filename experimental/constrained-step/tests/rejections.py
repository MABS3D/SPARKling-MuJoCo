"""Unsupported physics is rejected, never silently omitted from a step."""
import argparse,json,subprocess
from pathlib import Path
import mujoco
from compare import model_xml
p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
a.out.mkdir(parents=True,exist_ok=False)
base=model_xml('<body pos="0 0 .09"><joint name="z" type="slide" axis="0 0 1"/><geom name="ball" type="sphere" size=".1" mass="1"/></body>')
variants={
 'warmstart':base.replace('warmstart="disable"','warmstart="enable"'),
 'islands':base.replace('island="disable"','island="enable"'),
 'rk4':base.replace('timestep="0.001"','timestep="0.001" integrator="RK4"'),
 'noslip':base.replace('iterations="200"','iterations="200" noslip_iterations="1"'),
 'equality':base.replace('</mujoco>','<equality><joint joint1="z"/></equality></mujoco>'),
}
results=[]
for name,xml in variants.items():
 m=mujoco.MjModel.from_xml_string(xml);path=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path))
 run=subprocess.run([str(a.binary),str(path)],capture_output=True,text=True,timeout=60)
 passed=run.returncode==0 and run.stdout.strip()=='create UNSUPPORTED_FEATURE'
 results.append(dict(model=name,passed=passed,output=run.stdout+run.stderr));print(name,passed,flush=True)
(a.out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
assert all(r['passed'] for r in results)
