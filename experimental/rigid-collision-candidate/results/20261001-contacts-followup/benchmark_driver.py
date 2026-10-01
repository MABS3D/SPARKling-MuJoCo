"""Same-session, balanced baseline/current/native-C full-precontact benchmark."""
import argparse,ctypes,itertools,json,os,platform,subprocess,sys
from pathlib import Path
import numpy as np
sys.path.insert(0,str(Path.cwd()/'tests'))
from check_contacts import library,serialize_objects,match
from check_advanced import model,mesh_asset,mesh_graph,CUBE
from benchmark_contacts import OFFSETS

def run(out,baseline,rounds):
 os.sched_setaffinity(0,{15});lib=library(out);f=lib.rigid_contact_time
 f.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_double,ctypes.c_int,ctypes.POINTER(ctypes.c_double)];f.restype=ctypes.c_double
 cases=[(a+'-'+b,a,b,0) for a,b in itertools.combinations_with_replacement(['sphere','capsule','ellipsoid','cylinder','box'],2)]
 cases += [('plane-'+b,'plane',b,0) for b in ['sphere','capsule','cylinder','box','mesh']]
 cases += [('box-mesh','box','mesh',0),('cylinder-mesh','cylinder','mesh',0),('mesh-mesh','mesh','mesh',0),('capsule-cylinder-margin','capsule','cylinder',.005)]
 rng=np.random.default_rng(3141202);records=[]
 for name,a,b,margin in cases:
  m,d=model(a,b,CUBE);positions=np.array([[0.,0.,0.],[.35,.17,.25]]);mats=np.stack([np.eye(3).reshape(9)]*2)
  d.geom_xpos[:]=positions;d.geom_xmat[:]=mats
  vertices=[[],[]];facets=[[],[]];graphs=[[],[]];seeds=[[],[]]
  for g,k in enumerate([a,b]):
   if k=='mesh':vertices[g],facets[g]=mesh_asset(m,g);graphs[g],seeds[g]=mesh_graph(m,g)
  def text(mode=0,repeats=1,pos=positions):return serialize_objects([a,b],m.geom_size,pos,mats,vertices=vertices,facets=facets,graphs=graphs,seeds=seeds,margin=margin,mode=mode,repeats=repeats)
  inputs=[];expected=[]
  for off in OFFSETS:
   p=positions.copy();p[1,0]+=off;d.geom_xpos[:]=p;v=np.zeros(500);n=lib.rigid_contacts(m._address,d._address,0,1,margin,v);expected.append(v[:10*n].reshape(-1,10));inputs.append(text(pos=p))
  d.geom_xpos[:]=positions;errors=[]
  for label,source in [('baseline',baseline),('current',out)]:
   check=subprocess.run([str(source/'build/release/bin/contact_probe')],input=''.join(inputs),text=True,capture_output=True,check=True)
   for frame,(line,want) in enumerate(zip(check.stdout.splitlines(),expected)):
    words=line.split();actual=np.asarray(list(map(float,words[2:]))).reshape(-1,10);err=match(actual,want)
    if words[0]!='SUCCESS' or err:errors.append(dict(build=label,frame=frame,error=err,status=words[0]))
   if len(check.stdout.splitlines())!=16:errors.append(dict(build=label,reason='missing frames'))
  if errors:raise RuntimeError((name,errors))
  checksum=ctypes.c_double();pilot=f(m._address,d._address,0,1,margin,128,ctypes.byref(checksum));reps=max(256,min(100000,int(.012*1e9/max(1,pilot))));reps=(reps//16)*16
  def ada(source):
   words=subprocess.run([str(source/'build/release/bin/contact_probe')],input=text(1,reps),text=True,capture_output=True,check=True).stdout.split()
   if words[0]!='SUCCESS':raise RuntimeError(words)
   return float(words[2]),float(words[3])
  functions=[lambda:ada(baseline),lambda:ada(out),lambda:(f(m._address,d._address,0,1,margin,reps,ctypes.byref(checksum)),checksum.value)]
  perms=list(itertools.permutations(range(3)));timings=[];sums=[]
  for r in range(rounds):
   vals=[None]*3
   for index in perms[r%6]:vals[index]=functions[index]()
   if any(abs(v[1]-vals[2][1])>2e-7*(1+abs(vals[2][1])) for v in vals[:2]):raise RuntimeError((name,'checksum mismatch',vals))
   timings.append([v[0] for v in vals]);sums.append([v[1] for v in vals])
  p=np.array(timings);ratios=p[:,1]/p[:,2];change=p[:,1]/p[:,0]
  def interval(r):return np.quantile(np.median(rng.choice(r,size=(10000,len(r)),replace=True),axis=1),[.025,.975]).tolist()
  record=dict(case=name,frames=16,repetitions=reps,contacts=[len(e) for e in expected],baseline_ns=float(np.median(p[:,0])),ada_ns=float(np.median(p[:,1])),c_ns=float(np.median(p[:,2])),ratio=float(np.median(ratios)),ratio95=interval(ratios),current_over_baseline=float(np.median(change)),change95=interval(change),triples_ns=timings,checksums=sums)
  records.append(record);print(name,'current/C',round(record['ratio'],3),'current/baseline',round(record['current_over_baseline'],3),flush=True)
  report=dict(scope='full geometric precontacts only; 16 changing poses; excludes scene filtering/broadphase, materials/frame finalization, constraints, dynamics and integration',rounds=rounds,order='all six permutations of baseline,current,C repeated',cpu_affinity=[15],platform=platform.platform(),baseline_path=str(baseline),current_path=str(out),baseline_manifest=json.loads((baseline/'manifest.json').read_text()),current_manifest=json.loads((out/'manifest.json').read_text()),results=records)
  (out/'contact-baseline-comparison.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--baseline',type=Path,required=True);p.add_argument('--rounds',type=int,default=30);a=p.parse_args();run(a.out,a.baseline,a.rounds)
