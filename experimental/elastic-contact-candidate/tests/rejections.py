#!/usr/bin/env python3
"""Failure semantics and degeneracies; not compared to undefined C capsule division."""
import argparse
import copy
import json
from pathlib import Path
import subprocess
import numpy as np
from compare import case, cases, body, shape, payload, parse

ap=argparse.ArgumentParser(); ap.add_argument('--probe',type=Path,required=True)
ap.add_argument('--out',type=Path,required=True); a=ap.parse_args(); a.out.mkdir(parents=True,exist_ok=True)
samples=[]
base=dict(cases())
c=copy.deepcopy(base['shared_body']); c['iterations']=1
samples.append(('nonconvergence',c,'ITERATION_LIMIT'))
c=copy.deepcopy(base['sphere']); c['bodies'][0]['quat']=[2.,0,0,0]
samples.append(('invalid_quaternion',c,'INVALID_INPUT'))
c=copy.deepcopy(base['crossing']); c['links'][0]=1
samples.append(('invalid_attachment',c,'INVALID_INPUT'))
c=copy.deepcopy(base['sphere']); c['shapes'][0]['owner']=2
samples.append(('invalid_shape_owner',c,'INVALID_INPUT'))
c=copy.deepcopy(base['plane']); c['shapes'][0]['direction']=[0,0,0]
samples.append(('invalid_plane_normal',c,'INVALID_INPUT'))
c=case([[0,0,1],[1,0,1]],[(0,1)],mass=np.array([1e10,1e-15]),stiffness=1e10,
       bodies=[body()],applied=np.array([[0,0,0],[1e10,0,0]]),dt=1.)
c['rest'][:]=1e9
samples.append(('numeric_rollback',c,'NUMERIC_LIMIT'))
c=case([[0,0,1],[1,0,1]],[(0,1)],bodies=[body(mass=1e-15,force=np.array([1e10,0,0]))],dt=1.)
samples.append(('body_rollback_after_particle_update',c,'NUMERIC_LIMIT'))
pos=[]; edges=[]
for i in range(40):
    pos.extend([[-.3,0,.00001*i],[.3,0,.00001*i]])
    edges.append((2*i,2*i+1))
samples.append(('contact_capacity',case(pos,edges),'CONTACT_CAPACITY'))
c=case([[0,0,0],[0,0,0],[-.1,0,.01],[.1,0,.01]],[(0,1),(2,3)])
samples.append(('collapsed_edge_defined',c,'SUCCESS'))
c=copy.deepcopy(base['sphere']); c['bodies'][0]['fixed']=1
c['bodies'][0]['vel']=[3.,2.,1.]; c['bodies'][0]['omega']=[.2,.3,.4]
samples.append(('fixed_body_preserved',c,'SUCCESS'))
results=[]
for name,c,status in samples:
    inp=payload(c); (a.out/(name+'.input')).write_text(inp)
    r=subprocess.run([str(a.probe)],input=inp,text=True,capture_output=True)
    (a.out/(name+'.output')).write_text(r.stdout+r.stderr); r.check_returncode()
    result=parse(r.stdout); assert result['status']==status,(name,result['status'],status)
    if status!='SUCCESS':
        for key,expected in [('position',c['pos']),('velocity',c['vel'])]:
            np.testing.assert_array_equal(result[key],expected,err_msg=name+' '+key)
        for key,field in [('body_position','pos'),('body_velocity','vel'),('body_omega','omega'),('body_quaternion','quat')]:
            if c['bodies']: np.testing.assert_array_equal(result[key],[b[field] for b in c['bodies']])
        for key in ('particle_contact','body_force','body_torque'):
            if key in result: np.testing.assert_array_equal(result[key],np.zeros_like(result[key]))
    if name=='fixed_body_preserved':
        for key,field in [('body_position','pos'),('body_velocity','vel'),('body_omega','omega'),('body_quaternion','quat')]:
            np.testing.assert_array_equal(result[key],[c['bodies'][0][field]])
        # Fixed obstacle still receives the opposite load in the report.
        np.testing.assert_allclose(np.sum(result['particle_contact'],axis=0)+result['body_force'][0],0,atol=1e-10)
    if name=='collapsed_edge_defined': assert result['count'][0][0]>0
    results.append(dict(name=name,status=status)); print(name,'PASS',flush=True)
(a.out/'rejections.json').write_text(json.dumps(results,indent=2)+'\n')
