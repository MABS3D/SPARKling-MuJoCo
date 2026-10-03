"""FLEX CSR admission and recovery using native compiled models."""
import argparse
import hashlib
import json
import resource
import subprocess
import xml.etree.ElementTree as ET
from pathlib import Path
import mujoco
from compare import fixture

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(128*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    assert mujoco.__version__=='3.14.0'
    rigid=ET.fromstring(fixture(dim=1,edge=True))
    for body in rigid.findall('.//body'):
        for joint in list(body.findall('joint')):body.remove(joint)
    fixtures=[('slides',fixture(dim=1,edge=True)),
              ('shared',fixture(dim=2,shared=True,pinned=True)),
              ('free',fixture(dim=3,mode='none',free=True)),
              ('zero_dofs',ET.tostring(rigid,encoding='unicode'))]
    records=[]
    for name,xml in fixtures:
        model=mujoco.MjModel.from_xml_string(xml)
        path=a.out/(name+'.mjb');mujoco.mj_saveModel(model,str(path))
        (a.out/(name+'.xml')).write_text(xml)
        run=subprocess.run([str(a.binary),str(path),'flex-load-checks'],capture_output=True,text=True,timeout=90)
        (a.out/(name+'.output')).write_text(run.stdout+run.stderr)
        lines=[line for line in run.stdout.splitlines() if line.startswith('flex-load-checks ')]
        checks=int(lines[0].split()[1]) if len(lines)==1 else 0
        record=dict(name=name,nv=model.nv,slots=len(model.flexedge_J_colind),checks=checks,
                    exit=run.returncode,passed=run.returncode==0 and checks>0,
                    mjb_sha256=hashlib.sha256(path.read_bytes()).hexdigest())
        records.append(record);print(json.dumps(record),flush=True)
    result=dict(reference=mujoco.__version__,scope='admission, exact owned CSR and rejection recovery',
                records=records,checks=sum(r['checks'] for r in records),
                passed=all(r['passed'] for r in records),
                binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    raise SystemExit(not result['passed'])

if __name__=='__main__':main()
