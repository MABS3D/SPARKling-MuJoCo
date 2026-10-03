"""Compare owned flex state and detected contacts from real MJB/Model/Data to C."""
import argparse,hashlib,json,pathlib,subprocess,xml.etree.ElementTree as ET
import mujoco,numpy as np

def fixture(dim=2,shape='plane',pin=False,offset=False,selfmode='none',two=False,large=False,internal=False,mask=False,gap=False):
 points={1:[[-.14,0,.03],[.14,0,.03]],2:[[-.14,-.1,.03],[.14,-.1,.03],[0,.14,.03]],
         3:[[-.14,-.1,.03],[.14,-.1,.03],[0,.14,.03],[0,0,.2]]}[dim]
 if selfmode!='none':points=points+[[p[0],p[1],p[2]+.025] for p in points]
 if large:points=[[.04*(i%9),.04*(i//9),.02+.00001*i] for i in range(72)]
 n=len(points);bodies=[];names=[];vertices=[]
 for f in range(2 if two else 1):
  for i,p in enumerate(points):
   if pin and i==0:
    names.append('world');vertices.extend(p);continue
   name=f'b{f}_{i}';names.append(name)
   local=[.007,-.003,.004] if offset else [0,0,0];vertices.extend(local)
   p=np.asarray(p)-local+np.array([0,0,.075*f])
   joint='<joint type="slide" axis="0 0 1"/>' if large else '<freejoint/>'
   bodies.append(f'<body name="{name}" pos="'+ ' '.join(map(str,p))+f'">{joint}<inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/></body>')
 sizes={'plane':'5 5 .1','sphere':'.13','capsule':'.08 .13','ellipsoid':'.12 .09 .15','cylinder':'.1 .12','box':'.1 .1 .12'}
 center='0 0 -.09' if shape!='plane' else '0 0 0'
 geom=f'<geom type="{shape}" size="{sizes[shape]}" pos="{center}" priority="0" solmix=".3" friction=".6 .01 .02" margin="{.01 if gap else 0}" gap="{.015 if gap else 0}"'+(' contype="0" conaffinity="0"' if mask else '')+'/>'
 elements=list(range(n)) if not large else [v for i in range(0,n,3) for v in [i,i+1,i+2]]
 flexes=[]
 for f in range(2 if two else 1):
  nn=names[n*f:n*(f+1)];vv=vertices[3*n*f:3*n*(f+1)]
  flexes.append(f'<flex name="f{f}" dim="{dim}" radius=".05" body="'+ ' '.join(nn)+'" vertex="'+ ' '.join(map(str,vv))+'" element="'+ ' '.join(map(str,elements))+'">'+
   f'<contact selfcollide="{selfmode}" internal="{str(internal).lower()}" condim="3" solmix=".7" friction=".7 .02 .03" margin="{.005 if gap else 0}" gap="{.01 if gap else 0}"/></flex>')
 return '<mujoco><option><flag island="disable" warmstart="disable"/></option><worldbody>'+geom+''.join(bodies)+'</worldbody><deformable>'+''.join(flexes)+'</deformable></mujoco>'

def fixtures():
 for dim in [1,2,3]:
  for shape in ['plane','sphere','capsule','ellipsoid','cylinder','box']:
   yield f'dim{dim}_{shape}',fixture(dim,shape)
 for name,kw in [('offset',dict(offset=True)),('pinned',dict(pin=True,offset=True)),
   ('gap',dict(gap=True)),('masked',dict(mask=True)),('cross',dict(two=True)),
   ('filter72',dict(large=True)),('tetra_internal',dict(dim=3,internal=True))]:yield name,fixture(**kw)
 for mode in ['narrow','bvh','sap','auto']:yield 'self_'+mode,fixture(selfmode=mode)
 for dim in [1,4,6]:
  r=ET.fromstring(fixture());r.find('deformable/flex/contact').set('condim',str(dim))
  r.find('worldbody/geom').set('condim',str(dim));yield 'condim'+str(dim),ET.tostring(r,encoding='unicode')
 for mode in ['midphase','contact']:
  r=ET.fromstring(fixture(shape='box'));r.find('option/flag').set(mode,'disable')
  yield 'disabled_'+mode,ET.tostring(r,encoding='unicode')
 r=ET.fromstring(fixture(selfmode='auto'));contact=r.find('deformable/flex/contact')
 contact.set('contype','0');contact.set('conaffinity','0');yield 'masked_self',ET.tostring(r,encoding='unicode')
 for mode in ['rigid_world','rigid_body','shared_body']:
  r=ET.fromstring(fixture(offset=True));f=r.find('deformable/flex')
  if mode=='rigid_world':f.set('body','world world world');f.set('vertex','-.14 -.1 .03 .14 -.1 .03 0 .14 .03')
  else:f.set('body','b0_0 b0_0 b0_0');f.set('vertex','0 0 0 .28 0 0 .14 .24 0')
  if mode=='shared_body':
   g=r.find('worldbody/geom');r.find('worldbody').remove(g);r.find('worldbody/body').append(g)
   g.set('type','sphere');g.set('size','.1');g.set('pos','0 0 0')
  yield mode,ET.tostring(r,encoding='unicode')
 r=ET.fromstring(fixture(two=True,offset=True))
 for i,f in enumerate(r.findall('deformable/flex')):
  f.set('body',f'b{i}_0 b{i}_0 b{i}_0');f.set('vertex','0 0 0 .28 0 0 .14 .24 0')
 yield 'cross_rigid',ET.tostring(r,encoding='unicode')

def parse(text):
 samples=[];s=None
 for line in text.splitlines():
  p=line.split()
  if p[0]=='sample':s={'vertices':{},'contacts':[]};samples.append(s)
  elif p[0]=='v':s['vertices'][tuple(map(int,p[1:3]))]=np.array(list(map(float,p[3:])))
  elif p[0]=='detect':s['status']=p[1];s['count']=int(p[2])
  elif p[0]=='c':s['contacts'].append((tuple(map(int,p[1:8])),np.array(list(map(float,p[8:])))))
  elif p[0]!='end':raise RuntimeError(line)
 return samples

def oracle(m,q,v):
 d=mujoco.MjData(m);d.qpos[:]=q;d.qvel[:]=v;mujoco.mj_forward(m,d)
 verts={(f,i):d.flexvert_xpos[int(m.flex_vertadr[f])+i].copy() for f in range(m.nflex) for i in range(int(m.flex_vertnum[f]))}
 contacts=[]
 for c in d.contact:
  if max(c.flex)<0:continue
  geom=max(c.geom);f1=int(c.flex[0]);f2=int(c.flex[1]);gap=0.
  for f in [f1,f2]:
   if f>=0:gap+=float(m.flex_gap[f])
  if geom>=0:gap+=float(m.geom_gap[geom])
  if f1==f2 and f1>=0:gap=0.
  key=(geom,f1,f2,*map(int,c.elem),*map(int,c.vert))
  values=np.r_[c.dist,c.pos,c.frame[:3],c.dim,c.solref,c.solimp,c.friction,c.includemargin,c.includemargin+gap]
  contacts.append((key,values.copy()))
 return dict(vertices=verts,contacts=contacts)

def compare(a,b):
 errors=[];vertex_error=0.;contact_error=0.
 if a.get('status')!='SUCCESS':return ['status '+str(a.get('status'))],0,0
 if a['vertices'].keys()!=b['vertices'].keys():errors.append('vertex indices')
 for k,v in b['vertices'].items():
  av=a['vertices'].get(k,np.array([np.nan]*3));vertex_error=max(vertex_error,float(np.max(np.abs(av-v))))
  if not np.allclose(av,v,atol=2e-10,rtol=2e-12):errors.append('vertex '+str(k))
 pool=list(b['contacts'])
 for k,v in a['contacts']:
  matches=[(i,w) for i,(kk,w) in enumerate(pool) if kk==k]
  chosen=next(((i,w) for i,w in matches if np.allclose(v[:7],w[:7],atol=2e-5,rtol=1e-8)
    and np.allclose(v[7:],w[7:],atol=2e-10,rtol=2e-12)),None)
  if chosen is None:errors.append('contact '+str(k)+' actual='+str(v.tolist())+' expected='+str([w.tolist() for _,w in matches]));continue
  i,w=chosen;contact_error=max(contact_error,float(np.max(np.abs(v-w))));pool.pop(i)
 if pool:errors.append('missing contacts '+str([k for k,v in pool]))
 return errors,vertex_error,contact_error

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',required=True,type=pathlib.Path);p.add_argument('--out',required=True,type=pathlib.Path);p.add_argument('--samples',type=int,default=8);p.add_argument('--only');a=p.parse_args()
 assert mujoco.__version__=='3.14.0';a.out.mkdir(parents=True,exist_ok=False)
 warnings=[];mujoco.set_mju_user_warning(warnings.append);rng=np.random.default_rng(20261002);records=[];failures=[]
 for name,xml in fixtures():
  if a.only and a.only not in name:continue
  (a.out/(name+'.xml')).write_text(xml);m=mujoco.MjModel.from_xml_string(xml)
  root=ET.fromstring(xml);root.remove(root.find('deformable'));core=mujoco.MjModel.from_xml_string(ET.tostring(root,encoding='unicode'))
  core.opt.disableflags|=int(mujoco.mjtDisableBit.mjDSBL_CONSTRAINT)
  assert (m.nq,m.nv,m.nbody)==(core.nq,core.nv,core.nbody)
  mf=a.out/(name+'.mjb');cf=a.out/(name+'-core.mjb');mujoco.mj_saveModel(m,str(mf));mujoco.mj_saveModel(core,str(cf))
  inputs=[];expected=[]
  for sample in range(a.samples):
   q=m.qpos0.copy()
   if sample:mujoco.mj_integratePos(m,q,rng.uniform(-1,1,m.nv),.015)
   v=rng.uniform(-.1,.1,m.nv);inputs.extend(q);inputs.extend(v);expected.append(oracle(m,q,v))
  data=str(a.samples)+'\n'+' '.join(format(x,'.17g') for x in inputs)+'\n'
  r=subprocess.run([str(a.binary),str(mf),str(cf)],input=data,text=True,capture_output=True,timeout=180,cwd=a.out)
  (a.out/(name+'.output')).write_text(r.stdout+r.stderr)
  try:
   if r.returncode:raise RuntimeError(r.stdout[-1500:])
   actual=parse(r.stdout)
   if len(actual)!=a.samples:raise RuntimeError(r.stdout[-1500:])
   for i,(x,y) in enumerate(zip(actual,expected)):
    errors,ve,ce=compare(x,y);record=dict(model=name,sample=i,passed=not errors,errors=errors,vertex_abs_error=ve,contact_abs_error=ce)
    records.append(record)
    if errors:failures.append(record)
  except Exception as e:failures.append(dict(model=name,error=str(e)))
  print(name,'PASS' if not any(x.get('model')==name for x in failures) else 'FAIL',flush=True)
 result=dict(reference=mujoco.__version__,cases=len(records),passed=sum(x['passed'] for x in records),failures=failures,
  warnings=warnings,records=records,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
  scope='actual MJB metadata, owned Model/Data body kinematics, updated flex vertices/BVH and geometric/material contacts; no flex dynamics/solver')
 (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))
if __name__=='__main__':main()
