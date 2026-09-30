#!/usr/bin/env python3
"""Regression for geometric ties over long trajectories, at unchanged tolerances.
An optional pre-fix binary records the former divergence, separately from passes.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import subprocess
import numpy as np
from compare import case, shape, payload, parse, xml, reference
from build import sources

ap=argparse.ArgumentParser(); ap.add_argument('--probe',type=Path,required=True)
ap.add_argument('--baseline-probe',type=Path)
ap.add_argument('--out',type=Path,required=True); a=ap.parse_args()
a.out=a.out.resolve(); a.out.mkdir(parents=True,exist_ok=True); os.chdir(a.out)
before=sources(); rows=[]; baseline=[]
for steps in (1,2,3,5,10,200,1000,2000):
    c=case([[i*.1,0,.019] for i in range(128)],[(i,i+1) for i in range(127)],
           shapes=[shape(2)],gravity=np.array([0,0,-9.81]),steps=steps,stiffness=10.)
    want,_,_=reference(c,xml(c))
    for label,exe,results in [('current',a.probe,rows),('baseline',a.baseline_probe,baseline)]:
        if exe is None: continue
        r=subprocess.run([str(exe)],input=payload(c),text=True,capture_output=True,check=True)
        (a.out/f'{label}-{steps}.output').write_text(r.stdout+r.stderr)
        got=parse(r.stdout); assert got['status']=='SUCCESS'
        f1=np.array(got['particle_contact']);f2=want['particle_contact']
        same=np.array_equal(np.nonzero(f1[:,2])[0],np.nonzero(f2[:,2])[0])
        errors={k:float(np.max(np.abs(np.array(got[k])-want[k])))
                for k in ('particle_contact','position','velocity','coordinate') if k in got}
        row=dict(steps=steps,same_selected_vertices=bool(same),max_abs_error=errors)
        results.append(row); print(label,row,flush=True)
        if label=='current':
            assert same,(steps,'different selected contacts')
            for key in errors:
                np.testing.assert_allclose(got[key],want[key],atol=2e-8,rtol=2e-8,err_msg=f'{steps}: {key}')
assert before==sources(),'source changed during regression'
(a.out/'selection-sensitivity.json').write_text(json.dumps(dict(
    status='PASS',absolute_tolerance=2e-8,relative_tolerance=2e-8,sources=before,
    current_binary_sha256=hashlib.sha256(a.probe.read_bytes()).hexdigest(),
    baseline_binary_sha256=hashlib.sha256(a.baseline_probe.read_bytes()).hexdigest() if a.baseline_probe else None,
    results=rows,baseline_diagnostic=baseline),indent=2)+'\n')
