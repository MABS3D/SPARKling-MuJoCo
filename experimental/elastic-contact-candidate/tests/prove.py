#!/usr/bin/env python3
"""Prove minimum math subprograms first, followed by a fresh complete-unit gate."""
import argparse
import json
from pathlib import Path
import re
import resource
import subprocess
from build import HERE, REPO, environment, sources

ap=argparse.ArgumentParser(); ap.add_argument('--out',type=Path,required=True)
ap.add_argument('--pipeline',action='store_true')
ap.add_argument('--flow',action='store_true',help='dependency/initialization only; not a proof gate')
ap.add_argument('--unit',choices=['math','coordinates'],default='math')
ap.add_argument('--whole-only',action='store_true'); a=ap.parse_args()
a.out=a.out.resolve(); a.out.mkdir(parents=True,exist_ok=True)
env=environment(); env['ELASTIC_CONTACT_BUILD']=str(a.out/'build')
soft,hard=resource.getrlimit(resource.RLIMIT_STACK)
resource.setrlimit(resource.RLIMIT_STACK,(min(64*1024*1024,hard) if hard!=-1 else 64*1024*1024,hard))
def proof_sources():
    selected=sources()
    if not a.pipeline:
        suffixes=('mj.ads','mj-types.ads',
                  'mj-elastic_kernels.ads','mj-elastic_kernels.adb',
                  'mj-elastic_contact_math.ads','mj-elastic_contact_math.adb','contact.gpr')
        if a.unit=='coordinates': suffixes+=('mj-elastic_coordinates.ads','mj-elastic_coordinates.adb',
                                            'mj-elastic_network.ads','mj-elastic_network.adb')
        selected={k:v for k,v in selected.items() if k.endswith(suffixes)}
    return selected
before=proof_sources(); results=[]
unit='mj-elastic_contacts.adb' if a.pipeline else ('mj-elastic_coordinates.adb' if a.unit=='coordinates' else 'mj-elastic_contact_math.adb')
limits=[]
if not a.pipeline and not a.whole_only and not a.flow:
    for line,text in enumerate((HERE/'src'/unit).read_text().splitlines(),1):
        match=re.match(r'   (?:function|procedure) (\w+)',text)
        if match: limits.append((match.group(1),f'{unit}:{line}'))
for name,limit in limits+[('whole-unit',None)]:
    proof=a.out/name; proof.mkdir(exist_ok=True)
    env['ELASTIC_CONTACT_BUILD']=str(proof/'build')
    cmd=['gnatprove','-P',str(HERE/'contact.gpr'),'-u',unit,'--mode='+('flow' if a.flow else 'prove'),
         '--prover=cvc5,z3,altergo','--timeout=15','--steps=0','--proof=per_check',
         '-j2','--checks-as-errors=on','--warnings=continue','--report=all',
         '--counterexamples=off']
    if limit: cmd+=['--limit-subp='+limit]
    wrapped=['python3',str(REPO/'tools/guarded.py'),'--cap-mb','2800','--min-free-mb','1500','--timeout','600','--',*cmd]
    with (proof/'run.log').open('w') as log:
        p=subprocess.run(wrapped,env=env,stdout=log,stderr=subprocess.STDOUT)
    results.append(dict(name=name,exit=p.returncode,command=cmd,log=str(proof/'run.log')))
    print(name,p.returncode,flush=True)
    if proof_sources()!=before: raise RuntimeError('source changed during proof')
(a.out/'proof.json').write_text(json.dumps(dict(sources=before,results=results),indent=2)+'\n')
raise SystemExit(any(r['exit'] for r in results))
