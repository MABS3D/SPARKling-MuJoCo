"""Pinned adversarial inputs against the unmodified native C oracle."""
import argparse,json,subprocess
from pathlib import Path
import numpy as np
from common import build
from check import pair_model
from check_contacts import library,match

def run(out):
    lib=library(out);fixtures=json.loads(Path(__file__).with_name('contact_regressions.json').read_text());reports={}
    for profile in ['validation','release']:
        failures=[]
        for x in fixtures:
            fields=x['input'].split();j=3;sizes=[];positions=[];mats=[]
            for g in range(2):
                sizes.append(np.asarray(fields[j+1:j+4],float));positions.append(np.asarray(fields[j+4:j+7],float));mats.append(np.asarray(fields[j+7:j+16],float));j+=20
            m,d=pair_model(*x['pair']);m.geom_size[:]=sizes;d.geom_xpos[:]=positions;d.geom_xmat[:]=mats
            for g,kind in enumerate(x['pair']):
                m.geom_rbound[g]=(sizes[g][0]+sizes[g][1] if kind=='capsule' else np.hypot(*sizes[g][:2]) if kind=='cylinder' else np.linalg.norm(sizes[g]) if kind=='box' else max(sizes[g]) if kind=='ellipsoid' else sizes[g][0])
            want=np.zeros(500);n=lib.rigid_contacts(m._address,d._address,0,1,float(fields[2]),want)
            r=subprocess.run([str(out/'build'/profile/'bin/contact_probe')],input=x['input'],text=True,capture_output=True,timeout=30)
            words=r.stdout.split();error=None
            if r.returncode or not words or words[0]!='SUCCESS':error=dict(reason='status',returncode=r.returncode,stdout=r.stdout,stderr=r.stderr)
            else:
                actual=np.asarray(words[2:],float).reshape(-1,10);error=match(actual,want[:10*n].reshape(-1,10),x['tolerance'])
                if len(actual)!=int(words[1]):error=dict(reason='protocol')
            if error:failures.append(dict(name=x['name'],error=error))
        reports[profile]=dict(cases=len(fixtures),failures=failures)
        print(profile,'pinned regressions',len(fixtures),'failures',len(failures),flush=True)
    (out/'contact-regression-numerics.json').write_text(json.dumps(reports,indent=2)+'\n')
    return not any(r['failures'] for r in reports.values())

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--reuse',action='store_true');a=p.parse_args();out=a.out.resolve()
    if not a.reuse:build(out)
    raise SystemExit(0 if run(out) else 1)
