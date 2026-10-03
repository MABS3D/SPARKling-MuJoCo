"""Explicit unsupported/domain cases and atomic capacity/numeric failures."""
import argparse, json, subprocess
from pathlib import Path
import mujoco
from test_tendon_constraints import BODY, TERMS, xml

def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    repeated='<fixed limited="true" range=".1 .4" frictionloss=".06"><joint joint="x" coef="1"/><joint joint="x" coef="2"/><joint joint="z" coef=".5"/></fixed>'
    fixtures=[
      ('duplicate_columns',xml(BODY,repeated),'create'),
      ('limit_power',xml(BODY,f'<fixed limited="true" range=".1 .4" solimplimit=".8 .95 .03 .5 3">{TERMS}</fixed>'),'create'),
      ('friction_power',xml(BODY,f'<fixed frictionloss=".1" solimpfriction=".8 .95 .03 .5 3">{TERMS}</fixed>'),'create'),
      ('negative_margin_loader',xml(BODY,f'<fixed limited="true" range=".1 .4" margin="-.01">{TERMS}</fixed>'),'load'),
      ('capacity',xml(BODY,''.join(f'<fixed name="t{i}" limited="true" range=".1 .4" frictionloss=".05"><joint joint="x" coef="1"/></fixed>' for i in range(260))),'capacity'),
      ('zero_weight_domain',xml(BODY,'<fixed frictionloss=".1"><joint joint="x" coef="0"/></fixed>'),'numeric'),
    ]
    records=[]
    for name,source,mode in fixtures:
        m=mujoco.MjModel.from_xml_string(source);f=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(f));(a.out/(name+'.xml')).write_text(source)
        r=subprocess.run([str(a.binary),str(f),mode],capture_output=True,text=True,timeout=120)
        record=dict(case=name,mode=mode,passed=r.returncode==0,output=r.stdout+r.stderr);records.append(record);print(record,flush=True)
    (a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
    if not all(r['passed'] for r in records):raise SystemExit(1)
if __name__=='__main__':main()
