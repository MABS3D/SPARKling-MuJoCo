#!/usr/bin/env python3
"""Validate equality activation and rollback after capacity exhaustion."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
from compare_scalar import models as scalar_models


def fixtures():
 for name,kind,count,active in [('connect','connect',1,True),('weld','weld',1,True),('inactive','weld',1,False),('capacity','weld',43,True)]:
  attrs=' anchor="0 0 1"' if kind=='connect' else ''
  eq=f'<{kind} body1="a" active="{str(active).lower()}"{attrs}/>'*count
  xml=f'''<mujoco><option iterations="200" tolerance="1e-12"><flag warmstart="disable" island="disable" contact="disable"/></option>
  <worldbody><body name="a" pos="0 0 1"><freejoint/><geom size=".1" mass="1"/></body></worldbody><equality>{eq}</equality></mujoco>'''
  yield name, xml, name=='capacity'
 for name,kind,second,xml in scalar_models():
  xml=xml.replace('<option ', '<option iterations="200" tolerance="1e-12" ')
  xml=xml.replace('island="disable"', 'island="disable" warmstart="disable"')
  yield name+'-active', xml, False
  yield name+'-inactive', xml.replace('polycoef=', 'active="false" polycoef='), False
  yield name+'-disabled-passive', xml.replace('warmstart="disable"', 'warmstart="disable" spring="disable" damper="disable"'), False
  if second:
   # 42 welds plus five scalar equalities produce 257 rows from 47 objects.
   # Creation fits the object capacity; assembly must reject atomically.
   eq=xml.split('<equality>',1)[1].split('</equality>',1)[0]
   many=eq*5+'<weld body1="a"/>'*42
   yield name+'-mixed-capacity', xml.replace(eq,many), True

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--binary',type=Path,required=True)
p.add_argument('--out',type=Path,required=True)
a=p.parse_args(); a.out.mkdir(parents=True,exist_ok=False)
assert mujoco.__version__=='3.14.0'
records=[]
for name,xml,capacity in fixtures():
 m=mujoco.MjModel.from_xml_string(xml)
 path=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(path));(a.out/(name+'.xml')).write_text(xml)
 run=subprocess.run([str(a.binary),str(path)]+(['capacity'] if capacity else []),text=True,capture_output=True,timeout=60)
 (a.out/(name+'.log')).write_text(run.stdout+run.stderr)
 records.append(dict(name=name,passed=run.returncode==0 and 'atomicity PASS' in run.stdout,code=run.returncode))
result=dict(reference=mujoco.__version__,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
 script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
 scalar_fixtures_sha256=hashlib.sha256(Path(__file__).with_name('compare_scalar.py').read_bytes()).hexdigest(),
 records=records,cases=len(records),passed=sum(r['passed'] for r in records))
(a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result));raise SystemExit(0 if all(r['passed'] for r in records) else 1)
