"""Owned MJB flex state -> nodal endpoint, including mixed ordinary flex refusal."""
import argparse,hashlib,json,os,resource,subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare_node_weights import reference

def main():
 p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--root',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
 lib=reference(a.root,a.out);rng=np.random.default_rng(2026100331);records=[]
 for degree,dof in [(1,'trilinear'),(2,'quadratic')]:
  for cells in ['1 1 1','2 1 1','2 2 2']:
   for pin in (False,True):
    xml='<mujoco><worldbody><flexcomp name="ordinary" type="grid" count="2 2 1" dim="2" spacing=".05 .05 .05" pos="2 0 0"><contact selfcollide="none" internal="false"/></flexcomp><flexcomp name="nodes" type="grid" count="6 6 6" dim="3" spacing=".036 .036 .036" dof="'+dof+'" cellcount="'+cells+'" mass="1"><elasticity elastic2d="none"/><contact selfcollide="none" internal="false"/>'+('<pin range="0 7"/>' if pin else '')+'</flexcomp><geom type="plane" size="1 1 .1"/></worldbody></mujoco>'
    name=f'order{degree}_{cells.replace(" ","x")}_pin{pin}';(a.out/(name+'.xml')).write_text(xml);m=mujoco.MjModel.from_xml_string(xml);mjb=a.out/(name+'.mjb');mujoco.mj_saveModel(m,str(mjb))
    f=1;nv=int(m.flex_vertnum[f]);vstart=int(m.flex_vertadr[f]);nstart=int(m.flex_nodeadr[f]);nn=int(m.flex_nodenum[f]);nodebodies=np.ascontiguousarray(m.flex_nodebodyid[nstart:nstart+nn],dtype=np.int32);grid=np.ascontiguousarray(m.flex_cellnum[f],dtype=np.int32)
    cases=[];lines=[]
    def add(label,flex,count,ids,vw,status='SUCCESS'):
     expected=dict(status=status,bodies=[],weights=[])
     if status=='SUCCESS' and count:
      points=np.zeros((4,3));points[:count]=m.flex_vert0[vstart+np.array(ids[:count])];bodies=np.zeros(27,dtype=np.int32);weights=np.zeros(27);coord=np.zeros(3)
      nb=lib.weights(degree,grid,points,np.ascontiguousarray(vw),count,nodebodies,bodies,weights,coord)
      expected.update(bodies=bodies[:nb].tolist(),weights=weights[:nb].tolist())
     cases.append(dict(label=label,expected=expected));lines.append(' '.join(map(str,[flex,count,*ids,*vw])))
    add('empty-inactive-invalid-ids',f,0,[nv+5]*4,[0.]*4)
    add('invalid-flex',int(m.nflex),0,[0]*4,[0.]*4,'INVALID_INPUT')
    add('invalid-vertex',f,1,[nv,0,0,0],[1.,0,0,0],'INVALID_INPUT')
    add('ordinary-explicit-refusal',0,1,[0]*4,[1.,0,0,0],'UNSUPPORTED_FEATURE')
    for sample in range(64):
     count=sample%4+1;ids=rng.integers(0,nv,4).tolist();vw=np.zeros(4);vw[:count]=rng.dirichlet(np.ones(count))
     if sample%2:vw=-vw
     if sample%7==0:ids=[ids[0]]*4
     add('sample-'+str(sample),f,count,ids,vw)
    text=str(len(cases))+'\n'+'\n'.join(lines)+'\n';(a.out/(name+'.input')).write_text(text);(a.out/(name+'.expected.json')).write_text(json.dumps(cases,indent=2)+'\n')
    def limits():resource.setrlimit(resource.RLIMIT_STACK,(128*1024**2,128*1024**2))
    r=subprocess.run([str(a.binary),str(mjb)],input=text,text=True,capture_output=True,timeout=120,preexec_fn=limits);(a.out/(name+'.output')).write_text(r.stdout+r.stderr);actual=[]
    for line in r.stdout.splitlines():
     if line.startswith('case '):actual.append(dict(status=line.split()[1]))
     elif actual:
      k,_,v=line.partition(' ');actual[-1][k]=np.fromstring(v,sep=' ',dtype=np.int32 if k=='bodies' else np.float64)
    checks=[]
    for c,o in zip(cases,actual):
     e=c['expected'];ok=e['status']==o['status']
     for k in ('bodies','weights'):
      x=np.asarray(e[k],dtype=np.int32 if k=='bodies' else np.float64);y=o.get(k,np.array([]));ok=ok and x.shape==y.shape and np.array_equal(x if k=='bodies' else x.view(np.uint64),y if k=='bodies' else y.view(np.uint64))
     checks.append(dict(label=c['label'],passed=bool(ok)))
    records.append(dict(name=name,expected=len(cases),actual=len(actual),exit=r.returncode,exact=sum(c['passed'] for c in checks),checks=checks,passed=r.returncode==0 and len(actual)==len(cases) and all(c['passed'] for c in checks)))
    print(name,records[-1]['exact'],len(cases),r.returncode,flush=True)
 out=dict(passed=all(r['passed'] for r in records),records=records,exact=sum(r['exact'] for r in records),expected=sum(r['expected'] for r in records),binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),artifacts={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in a.out.iterdir() if p.is_file()},limits='Endpoint only. Ordinary flex remains explicitly rejected by this nodal API; full mixed dynamics admission is outside its scope.')
 (a.out/'results.json').write_text(json.dumps(out,indent=2)+'\n');raise SystemExit(not out['passed'])
if __name__=='__main__':main()
