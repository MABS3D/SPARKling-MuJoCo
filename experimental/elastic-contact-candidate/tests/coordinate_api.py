#!/usr/bin/env python3
"""Check coordinate-state ownership and atomic failures through the public API."""
import argparse
import json
from pathlib import Path
import subprocess
from build import HERE, environment, sources

ap=argparse.ArgumentParser(); ap.add_argument('--out',type=Path,required=True)
a=ap.parse_args(); a.out=a.out.resolve(); a.out.mkdir(parents=True,exist_ok=True)
before=sources(); env=environment(); env['ELASTIC_CONTACT_BUILD']=str(a.out)
results=[]
for mode in ('validation','release'):
    cmd=['gprbuild','-P',str(HERE/'coordinate_checks.gpr'),'-p','-j2','-XELASTIC_CONTACT_MODE='+mode]
    p=subprocess.run(cmd,env=env,text=True,capture_output=True)
    (a.out/(mode+'-build.log')).write_text(p.stdout+p.stderr); p.check_returncode()
    p=subprocess.run([str(a.out/mode/'bin/coordinate_checks')],text=True,capture_output=True)
    (a.out/(mode+'-checks.log')).write_text(p.stdout+p.stderr); p.check_returncode()
    results.append(dict(mode=mode,command=cmd,results=p.stdout.splitlines()))
    print(mode,p.stdout,flush=True)
assert before==sources(),'source changed during API checks'
(a.out/'coordinate-api.json').write_text(json.dumps(dict(sources=before,results=results),indent=2)+'\n')
