"""Shared-state elasticity/contact movement comparison with unmodified C 3.14.0."""
import argparse,hashlib,json,subprocess,resource,importlib.util
from pathlib import Path
import xml.etree.ElementTree as ET
import numpy as np
import mujoco
from compare import fixture,numbers

def fixtures():
 for solver in ('PGS','CG','Newton'):
  for dim in (1,3,4,6):
   tree=ET.fromstring(fixture(curved=True,mode='both'))
   option=tree.find('option');option.set('solver',solver);option.set('iterations','200')
   option.set('tolerance','1e-12');option.set('jacobian','sparse');option.set('cone','pyramidal')
   option.find('flag').attrib.clear();option.find('flag').set('warmstart','disable');option.find('flag').set('island','disable')
   ET.SubElement(tree.find('worldbody'),'geom',dict(type='plane',size='3 3 .1',pos='0 0 -.01',condim=str(dim),friction='.6 .015 .004'))
   contact=tree.find('deformable/flex/contact');contact.set('contype','1');contact.set('conaffinity','1');contact.set('internal','false');contact.set('condim',str(dim))
   tree.find('deformable/flex').set('radius','.015')
   yield f'membrane_{solver}_{dim}',ET.tostring(tree,encoding='unicode')
   if solver=='Newton' and dim>1:
    option.set('cone','elliptic')
    yield f'elliptic_{dim}',ET.tostring(tree,encoding='unicode')
 # Distinct movement paths, preserving the same compiled input adapter.
 for name,kw in [('pinned',dict(pinned=True)),('free',dict(free=True,mode='stretch')),('shared',dict(shared=True,pinned=True)),('tetra',dict(dim=3,mode='none')),('edge',dict(dim=1,edge=True))]:
  tree=ET.fromstring(fixture(curved=True,**kw));option=tree.find('option')
  option.set('solver','Newton');option.set('iterations','200');option.set('tolerance','1e-12');option.set('jacobian','sparse')
  option.find('flag').attrib.clear();option.find('flag').set('warmstart','disable');option.find('flag').set('island','disable')
  ET.SubElement(tree.find('worldbody'),'geom',dict(type='plane',size='3 3 .1',pos=('0 0 .29' if name=='shared' else '0 0 -.01'),condim='3'))
  contact=tree.find('deformable/flex/contact');contact.set('contype','1');contact.set('conaffinity','1');contact.set('internal','false');contact.set('condim','3')
  tree.find('deformable/flex').set('radius','.015')
  yield name,ET.tostring(tree,encoding='unicode')
 tree=ET.fromstring(fixture(curved=True,muscle=True));option=tree.find('option')
 option.set('solver','Newton');option.set('iterations','200');option.set('tolerance','1e-12');option.set('jacobian','sparse')
 option.find('flag').attrib.clear();option.find('flag').set('warmstart','disable');option.find('flag').set('island','disable')
 plane=ET.SubElement(tree.find('worldbody'),'geom',dict(type='plane',size='3 3 .1',pos='0 0 -.01',condim='3'))
 contact=tree.find('deformable/flex/contact');contact.set('contype','1');contact.set('conaffinity','1');contact.set('internal','false');contact.set('condim','3')
 tree.find('deformable/flex').set('radius','.015')
 yield 'muscle',ET.tostring(tree,encoding='unicode')
 for name,flag in [('contact_disabled','contact'),('constraint_disabled','constraint')]:
  option.find('flag').set(flag,'disable');yield name,ET.tostring(tree,encoding='unicode');del option.find('flag').attrib[flag]
 plane.set('quat','.9950041652780258 0 .09983341664682815 0')
 yield 'tilted_plane',ET.tostring(tree,encoding='unicode')
 plane.set('margin','.002');plane.set('gap','.006')
 yield 'margin_gap',ET.tostring(tree,encoding='unicode')
 ET.SubElement(tree.find('worldbody'),'geom',dict(type='plane',size='3 3 .1',pos='0 0 -.008',quat='.9950041652780258 .09983341664682815 0 0',condim='3'))
 yield 'two_planes',ET.tostring(tree,encoding='unicode')
 joint=tree.find("worldbody/body/joint[@name='j0_0_2']")
 joint.set('range','-.002 .002');joint.set('limited','true');joint.set('margin','.004');joint.set('frictionloss','.03')
 yield 'joint_rows',ET.tostring(tree,encoding='unicode')
 # Element endpoints exercise inverse-distance weights and the union of body
 # chains. Keep the original vertex corpus ahead of these cases unchanged.
 for dim in (1,2,3):
  for kind,size in [('sphere','.1'),('capsule','.08 .07'),('ellipsoid','.1 .12 .1'),
                    ('cylinder','.1 .09'),('box','.1 .11 .1')]:
   tree=ET.fromstring(fixture(dim=dim,mode='none' if dim==3 else 'stretch',edge=dim==1))
   option=tree.find('option');option.set('solver','Newton');option.set('iterations','200')
   option.set('tolerance','1e-12');option.set('jacobian','sparse')
   option.find('flag').attrib.clear();option.find('flag').set('warmstart','disable');option.find('flag').set('island','disable')
   contact=tree.find('deformable/flex/contact');contact.set('contype','1');contact.set('conaffinity','1');contact.set('internal','false');contact.set('condim','3')
   tree.find('deformable/flex').set('radius','.015')
   pos=' .3 .05 .09' if dim==1 else ('.3 .3 .09' if dim==2 else '.3 .3 -.09')
   geom=ET.SubElement(tree.find('worldbody'),'geom',dict(type=kind,size=size,pos=pos,condim='3',friction='.6 .015 .004'))
   yield f'element_{dim}_{kind}',ET.tostring(tree,encoding='unicode')
   if kind=='sphere':
    for cone,cdim,solver in [('pyramidal',1,'PGS'),('pyramidal',4,'CG'),('pyramidal',6,'Newton'),('elliptic',3,'Newton'),('elliptic',6,'Newton')]:
     option.set('cone',cone);option.set('solver',solver);geom.set('condim',str(cdim));contact.set('condim',str(cdim))
     yield f'element_{dim}_{cone}_{cdim}_{solver}',ET.tostring(tree,encoding='unicode')
 for variant in ('pinned','free','shared','shared_geom','repeated_body','mixed'):
  for cone,cdim in [('pyramidal',3),('elliptic',6)]:
   tree=ET.fromstring(fixture(mode='stretch',pinned=variant=='pinned',
     free=variant in ('free','repeated_body'),shared=variant in ('shared','shared_geom')))
   option=tree.find('option');option.set('solver','Newton');option.set('iterations','200')
   option.set('tolerance','1e-12');option.set('jacobian','sparse');option.set('cone',cone)
   option.find('flag').attrib.clear();option.find('flag').set('warmstart','disable');option.find('flag').set('island','disable')
   flex=tree.find('deformable/flex');flex.set('radius','.015');contact=flex.find('contact')
   contact.set('contype','1');contact.set('conaffinity','1');contact.set('internal','false');contact.set('condim',str(cdim))
   world=tree.find('worldbody');target=world
   pos='.5 .2 .39' if variant=='shared' else '.3 .3 .09'
   if variant=='shared_geom':target=world.find('body')
   if variant=='repeated_body':
    names=flex.get('body').split();names[2]=names[1];flex.set('body',' '.join(names))
    flex.set('vertex','0 0 0 0 0 0 -1 1 0 0 0 0')
   if variant=='mixed':
    ET.SubElement(world,'geom',dict(type='plane',size='3 3 .1',condim=str(cdim)))
    ET.SubElement(world.find('body'),'geom',dict(type='sphere',size='.08',pos='.22 .3 .09',condim=str(cdim)))
    target=ET.SubElement(world,'body',dict(pos=pos));ET.SubElement(target,'freejoint');pos='0 0 0'
   ET.SubElement(target,'geom',dict(type='sphere',size='.1',pos=pos,mass='1',condim=str(cdim),friction='.6 .015 .004'))
   yield f'element_{variant}_{cone}_{cdim}',ET.tostring(tree,encoding='unicode')
 spec=importlib.util.spec_from_file_location('flex_state_fixtures',Path(__file__).resolve().parents[2]/'flex-state-integration/tests/compare.py')
 state_fixtures=importlib.util.module_from_spec(spec);spec.loader.exec_module(state_fixtures)
 for name,kw in [('cross',dict(two=True)),('internal',dict(dim=3,internal=True))]+[
     ('self_'+mode,dict(selfmode=mode)) for mode in ('narrow','bvh','sap','auto')]:
  for cone,cdim in [('pyramidal',3),('elliptic',6)]:
   tree=ET.fromstring(state_fixtures.fixture(**kw))
   option=tree.find('option');option.set('solver','Newton');option.set('iterations','200')
   option.set('tolerance','1e-12');option.set('jacobian','sparse');option.set('cone',cone)
   option.set('timestep','.0002');option.set('gravity','0 0 -.3')
   if name=='internal':tree.find("worldbody/body[@name='b0_3']").set('pos','0 0 .065')
   for contact in tree.findall('deformable/flex/contact'):contact.set('condim',str(cdim))
   for geom in tree.findall('.//geom'):geom.set('condim',str(cdim))
   yield f'element_{name}_{cone}_{cdim}',ET.tostring(tree,encoding='unicode')
 # Keep the preceding contact-only fixtures and their RNG sequence stable.
 # Add continuum forces to the same self/cross/internal contact paths.
 for name,kw in [('cross',dict(two=True)),('internal',dict(dim=3,internal=True))]+[
     ('self_'+mode,dict(selfmode=mode)) for mode in ('narrow','bvh','sap','auto')]:
  for cone,cdim in [('pyramidal',3),('elliptic',6)]:
   tree=ET.fromstring(state_fixtures.fixture(**kw))
   option=tree.find('option');option.set('solver','Newton');option.set('iterations','200')
   option.set('tolerance','1e-12');option.set('jacobian','sparse');option.set('cone',cone)
   option.set('timestep','.0002');option.set('gravity','0 0 -.3')
   if name=='internal':tree.find("worldbody/body[@name='b0_3']").set('pos','0 0 .065')
   for flex in tree.findall('deformable/flex'):
    flex.find('contact').set('condim',str(cdim))
    ET.SubElement(flex,'elasticity',dict(young='120',poisson='.23',thickness='.045',
      damping='.012',elastic2d='none' if name=='internal' else 'stretch'))
   for geom in tree.findall('.//geom'):geom.set('condim',str(cdim))
   yield f'element_elastic_{name}_{cone}_{cdim}',ET.tostring(tree,encoding='unicode')

def parse(text):
 records=[]
 for line in text.splitlines():
  if line.startswith('case'):records.append({})
  elif records:
   key,_,data=line.partition(' ')
   if key in ('counts','passive','free','acc','constraint','state','aref','reg'):records[-1][key]=np.fromstring(data,sep=' ')
   elif key=='jac':records[-1][key]=np.r_[records[-1].get(key,np.array([])),np.fromstring(data,sep=' ')]
 return records

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
 p.add_argument('--samples',type=int,default=2);p.add_argument('--steps',type=int,default=30);p.add_argument('--only')
 a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 resource.setrlimit(resource.RLIMIT_STACK,(128*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
 if mujoco.__version__!='3.14.0':raise RuntimeError('wrong C baseline')
 rng=np.random.default_rng(2026100307);records=[];failures=[];warnings=[]
 mujoco.set_mju_user_warning(warnings.append)
 for name,xml in fixtures():
  if a.only and a.only not in name:continue
  (a.out/(name+'.xml')).write_text(xml)
  m=mujoco.MjModel.from_xml_string(xml);model=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(model))
  inputs=[];expected=[]
  for sample in range(a.samples):
   d=mujoco.MjData(m);mujoco.mj_integratePos(m,d.qpos,rng.uniform(-.03,.03,m.nv),.1 if sample else 0)
   d.qvel[:]=rng.uniform(-.015,.015,m.nv) if sample else 0;d.qfrc_applied[:]=rng.uniform(-.02,.02,m.nv)
   d.ctrl[:]=.1;d.act[:]=.08
   inputs.extend([0,*d.qpos,*d.qvel,*d.qfrc_applied,*d.ctrl,*d.act])
   mujoco.mj_forward(m,d)
   row=dict(counts=np.array([d.ncon,d.nefc]),passive=d.qfrc_passive.copy(),free=d.qacc_smooth.copy(),acc=d.qacc.copy(),constraint=d.qfrc_constraint.copy())
   if name.startswith('element_'):
    matrix=np.zeros((d.nefc,m.nv))
    for r in range(d.nefc):
     start=d.efc_J_rowadr[r];length=d.efc_J_rownnz[r]
     matrix[r,d.efc_J_colind[start:start+length]]=d.efc_J[start:start+length]
    row.update(jac=matrix.ravel(),aref=d.efc_aref.copy(),reg=d.efc_R.copy())
    if sample==0 and not any(any(c.elem[side]>=0 and c.vert[side]<0 for side in (0,1)) for c in d.contact):
     failures.append(dict(model=name,error='Fixture did not exercise an element endpoint'))
   for _ in range(a.steps):mujoco.mj_step(m,d)
   row['state']=np.r_[d.qpos,d.qvel,d.time,d.act];expected.append(row)
  if name.startswith('element_elastic_') and a.samples>1 and not any(np.any(row['passive']!=0) for row in expected):
   failures.append(dict(model=name,error='Fixture did not exercise elastic passive force'))
  (a.out/(name+'.expected.json')).write_text(json.dumps([{k:v.tolist() for k,v in row.items()} for row in expected],indent=2)+'\n')
  data=f'{a.samples} {a.steps}\n'+numbers(inputs)+'\n';(a.out/(name+'.input')).write_text(data)
  run=subprocess.run([str(a.binary),str(model),*(['diagnostic'] if name.startswith('element_') else [])],input=data,text=True,capture_output=True,timeout=180)
  (a.out/(name+'.output')).write_text(run.stdout+run.stderr);actual=parse(run.stdout)
  if run.returncode or len(actual)!=len(expected):
   failures.append(dict(model=name,exit=run.returncode,error=(run.stdout+run.stderr)[-2200:]));print('FAIL',name,failures[-1]['error'],flush=True)
  else:
   for i,(x,y) in enumerate(zip(actual,expected)):
    errors={}
    for key,value in y.items():
     valid=key in x and x[key].shape==value.shape
     delta=float(np.max(np.abs(x[key]-value))) if valid and value.size else 0.
     ok=valid and np.allclose(x[key],value,atol=2e-9,rtol=2e-9)
     errors[key]=dict(max_abs=delta,passed=bool(ok))
    row=dict(model=name,sample=i,errors=errors,passed=all(v['passed'] for v in errors.values()));records.append(row)
    if not row['passed']:failures.append(row);print('FAIL',name,i,{k:v for k,v in errors.items() if not v['passed']},flush=True)
  result=dict(reference=mujoco.__version__,steps=a.steps,cases=len(records),passed=sum(r['passed'] for r in records),failures=failures,records=records,warnings=warnings,binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),library_sha256=hashlib.sha256((Path(mujoco.__file__).parent/'libmujoco.so.3.14.0').read_bytes()).hexdigest(),fixture_source_sha256={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [Path(__file__).with_name('compare.py'),Path(__file__).resolve().parents[2]/'flex-state-integration/tests/compare.py']})
  (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(name,'checked',flush=True)
 print('RESULT',result['passed'],result['cases'],'failures',len(failures));raise SystemExit(bool(failures))
if __name__=='__main__':main()
