#!/usr/bin/env python3
"""Compare the entire supported scalar contact step with MuJoCo 3.14.0."""
from pathlib import Path
import argparse,hashlib,json,math,random,subprocess,sys
import mujoco
import numpy as np
from evidence import HERE,snapshot,digest
DEFAULT=[2.,.1,0.,-9.81,.002,0.,0.,.02,1.,.9,.95,.001,.5,.3,0.,0.,0.,0]
def xml(c):
 m,r,p,g,h,margin,gap,tc,dr,d0,dw,width,mid,*_=c
 return f'''<mujoco><option timestep="{h:.17g}" gravity="0 0 {g:.17g}" integrator="Euler" solver="PGS" jacobian="dense" iterations="100" tolerance="1e-12"><flag warmstart="disable"/></option><worldbody><geom name="floor" type="plane" pos="0 0 {p:.17g}" size="1 1 .1"/><body><joint type="slide" axis="0 0 1" damping="0" armature="0"/><geom name="ball" type="sphere" size="{r:.17g}" mass="{m:.17g}"/></body></worldbody><contact><pair geom1="floor" geom2="ball" condim="1" margin="{margin:.17g}" gap="{gap:.17g}" solref="{tc:.17g} {dr:.17g}" solimp="{d0:.17g} {dw:.17g} {width:.17g} {mid:.17g} 2"/></contact></mujoco>'''
def cases():
 rows=[];names=[]
 def add(name,**kw):
  c=DEFAULT.copy()
  indices=dict(mass=0,radius=1,plane=2,gravity=3,h=4,margin=5,gap=6,tc=7,dr=8,d0=9,dw=10,width=11,mid=12,z=13,v=14,time=15,force=16,steps=17)
  for k,v in kw.items():c[indices[k]]=v
  rows.append(c);names.append(name)
 add('freefall-step',steps=1)
 add('settled-drop',steps=10000)
 add('penetrating-impact',z=.099,v=-.2)
 add('separating',z=.099,v=10)
 add('external-balanced',z=.3,force=19.62,steps=100)
 add('upward-load',z=.099,force=50,steps=100)
 for margin,gap in [(0.,0.),(.01,0.),(.01,.005),(.01,.02)]:
  for offset in [margin+gap,margin,margin-gap,0,-.001,-.0005,-.0001]:
   z=.1+offset
   for neighbor in [math.nextafter(z,-math.inf),z,math.nextafter(z,math.inf)]:
    add('threshold',z=neighbor,margin=margin,gap=gap)
 for d0,dw in [(.9,.95),(.9,.9),(.95,.9),(.0001,.9999),(.9999,.0001)]:
  for mid in [.0001,.5,.9999]:
   for width in [0.,1e-15,.001]:
    for delta in [0.,-.00025,-.0005,-.001,-.1]:
     add('impedance',d0=d0,dw=dw,mid=mid,width=width,z=.1+delta)
 rng=random.Random(20260929)
 for k in range(400):
  m=10**rng.uniform(-2,3);r=10**rng.uniform(-2,1);plane=rng.uniform(-2,2)
  add('random',mass=m,radius=r,plane=plane,z=plane+r+rng.uniform(-.002,.002),
      v=rng.uniform(-3,3),force=rng.uniform(-20,20),tc=10**rng.uniform(-3,-.3),
      dr=rng.uniform(.2,2),width=10**rng.uniform(-4,-1),mid=rng.uniform(.05,.95),
      d0=rng.uniform(.05,.8),dw=rng.uniform(.81,.99))
 for m in [.1,2.,100.]:
  for tc in [.001,.02,.1]:
   for z,v in [(.3,0),(.099,-1),(.099,2),(.11,-.1)]:
    add('trajectory',mass=m,tc=tc,z=z,v=v,steps=1000)
 return names,rows

def oracle(c):
 m=mujoco.MjModel.from_xml_string(xml(c));d=mujoco.MjData(m)
 d.qpos[0]=c[13];d.qvel[0]=c[14];d.time=c[15];d.qfrc_applied[0]=c[16]
 for _ in range(int(c[17])):mujoco.mj_step(m,d)
 if not c[17]:mujoco.mj_forward(m,d)
 assert m.nv==1 and m.body_simple[1]==2 and d.nefc in (0,1) and d.ncon in (0,1)
 assert not np.any(d.warning.number),d.warning.number
 active=bool(d.nefc);hit=bool(d.ncon)
 row=[0,int(hit),int(active),d.qpos[0],d.qvel[0],d.time,d.contact[0].dist if hit else 0.]
 if active:
  assert d.efc_J[0]==1.0
  row += [d.efc_KBIP[0,2],d.efc_KBIP[0,0],d.efc_KBIP[0,1],d.efc_R[0],d.efc_AR[0],d.efc_aref[0],d.efc_force[0]]
 else:row += [0,0,0,1e-15,1e-15,0,0]
 row += [d.qacc[0]]
 return row

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--binary',type=Path,required=True);ap.add_argument('--out',type=Path,required=True);args=ap.parse_args()
 assert mujoco.__version__=='3.14.0'
 source_hashes=snapshot()
 args.out.mkdir(parents=True,exist_ok=True);names,rows=cases()
 data=''.join(' '.join(format(x,'.17g') for x in c)+'\n' for c in rows)
 p=subprocess.run([str(args.binary)],input=data,capture_output=True,text=True)
 (args.out/'input.txt').write_text(data);(args.out/'output.txt').write_text(p.stdout);(args.out/'stderr.txt').write_text(p.stderr)
 if p.returncode:raise RuntimeError(p.stderr)
 actual=[list(map(float,x.split())) for x in p.stdout.splitlines()]
 assert len(actual)==len(rows),(len(actual),len(rows))
 errors=[0.]*15;scaled=[0.]*15;expected=[]
 for i,(c,a) in enumerate(zip(rows,actual)):
  b=oracle(c);expected.append(b);assert len(a)==len(b)==15
  assert a[:3]==b[:3],(i,names[i],a,b,c)
  for j,(v,w) in enumerate(zip(a[3:],b[3:]),3):
   errors[j]=max(errors[j],abs(v-w));scaled[j]=max(scaled[j],abs(v-w)/(1+abs(w)))
   assert math.isfinite(v) and math.isclose(v,w,rel_tol=2e-10,abs_tol=2e-10),(i,names[i],j,v,w,c)
  assert a[13]>=0
 # Independent physical/analytic checks.
 a=actual[0];assert abs(a[4]+.01962)<1e-15 and abs(a[3]-(.3-.002*.01962))<1e-15
 a=actual[1];assert .09<a[3]<.1 and abs(a[4])<1e-10 and abs(a[13]-19.62)<1e-8
 assert actual[3][2]==1 and actual[3][13]==0
 assert abs(actual[4][3]-.3)<1e-13 and abs(actual[4][4])<1e-13
 # Atomic numeric failure and time overflow.
 failures=[]
 for z,v,t,g,h in [(1e10,1e10,0.,1e10,1e10),(1.,0.,1e10,0.,1.)]:
  c=DEFAULT.copy();c[13:16]=[z,v,t];c[3]=g;c[4]=h;c[17]=1
  q=subprocess.run([str(args.binary)],input=' '.join(format(x,'.17g') for x in c)+'\n',text=True,capture_output=True)
  assert q.returncode==0,q.stderr
  a=list(map(float,q.stdout.split()));assert a[0]==1 and a[3:6]==[z,v,t],a
  failures.append(a)
 (args.out/'reference.json').write_text(json.dumps(expected)+'\n')
 summary={'source_sha256':source_hashes,'python_mujoco_library_sha256':digest(next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))),'cases':len(rows),'scalar_comparisons':len(rows)*12,'reference':'MuJoCo 3.14.0 PGS, no warmstart, 100 iterations, tolerance 1e-12','atol':2e-10,'rtol':2e-10,'max_abs_error_by_column':errors,'max_scaled_error_by_column':scaled,'settled_height':actual[1][3],'settled_velocity':actual[1][4],'settled_force':actual[1][13],'atomic_failure_cases':len(failures),'binary_sha256':hashlib.sha256(args.binary.read_bytes()).hexdigest()}
 assert source_hashes==snapshot()
 (args.out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps({k:v for k,v in summary.items() if k!='source_sha256'},indent=2))
if __name__=='__main__':main()
