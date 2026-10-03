import argparse, pathlib, subprocess, json, random, hashlib, itertools
HERE=pathlib.Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
import mujoco
assert mujoco.__version__=='3.14.0'
lib=pathlib.Path(mujoco.__file__).parent
cmd=['gcc','-O2',str(HERE/'tests/oracle.c'),'-I'+str(lib/'include'),str(lib/'libmujoco.so.3.14.0'),'-Wl,-rpath,'+str(lib),'-o',str(a.out/'oracle')]
subprocess.run(cmd,check=True)
rng=random.Random(3014000);requests=[];invalid=[]
def size(w,s):return sum(n for i,n in enumerate(w) if s&(1<<i))
def fields():
 nq,nv,na,nh,nu,nb,ne,nm,ud,pl=[rng.randrange(0,8) for _ in range(10)]
 return [1,nq,nv,na,nh,nv,nu,nv,6*nb,ne,3*nm,4*nm,ud,pl]
def packed(w,s):
 vals=[]
 for i,n in enumerate(w):
  if s&(1<<i):vals.extend([float(rng.randrange(2)) if i==9 else rng.uniform(-100,100) for _ in range(n)])
 return vals
def request(op,ss,ds,w,src,dst):
 return ' '.join(map(str,[op,ss,ds,*w,len(src),len(dst),*src,*dst]))
for case in range(512):
 w=fields();ss=rng.randrange(16384);ds=ss&rng.randrange(16384)
 for op in [1,2,3,4]:
  src=packed(w,ss if op in [1,2] else 16383)
  dst=[-123.5]*size(w,ds) if op in [1,4] else packed(w,16383)
  if op==4:ss=16383
  requests.append(request(op,ss,ds,w,src,dst))
 # Include non-binary input values to check C's mjtBool conversion in setters.
 if w[9]:
  requests.append(request(2,512,0,w,[rng.choice([-2.,0.,.1,9.]) for _ in range(w[9])],packed(w,16383)))
for code in list(range(26))+[100,101,102]:requests.append('8 '+str(code))
for nv,j,c,s,n in itertools.product([0,1,59,60,61,256],[0,1,2],[-1,0,1],[0,1,2],[-1,0,1]):
 requests.append('9 '+' '.join(map(str,[nv,j,c,s,n])))
data='\n'.join(requests)+'\n'
(a.out/'input.txt').write_text(data)
ada=subprocess.run([str(a.binary)],input=data,text=True,capture_output=True,check=True).stdout.splitlines()
c=subprocess.run([str(a.out/'oracle')],input=data,text=True,capture_output=True,check=True).stdout.splitlines()
assert len(ada)==len(c)==len(requests),(len(ada),len(c),len(requests))
failures=[]
for i,(x,y) in enumerate(zip(ada,c)):
 xx=x.split();yy=y.split()
 if xx and xx[0]=='SUCCESS':same=len(xx)==len(yy) and yy[0]=='SUCCESS' and all(float(a)==float(b) for a,b in zip(xx[1:],yy[1:]))
 else:same=xx==yy
 if not same:failures.append({'case':i,'ada':x,'c':y})
# Atomic invalid mask, non-subset and source/destination size failures.
w=[1,2,2,1,0,2,1,2,6,1,0,0,1,0]
for op,ss,ds,src,dst,expected in [
 (1,16384,1,[1.],[-99.],'INVALID_SIGNATURE'),
 (1,1,2,[1.],[-99.,-99.],'INVALID_SIGNATURE'),
 (1,1,1,[],[-99.],'INVALID_SIZE'),
 (2,1,0,[],packed(w,16383),'INVALID_SIZE'),
 (3,16384,0,packed(w,16383),packed(w,16383),'INVALID_SIGNATURE'),
 (4,16383,16384,packed(w,16383),[-99.],'INVALID_SIGNATURE')]:
 text=request(op,ss,ds,w,src,dst)+'\n'
 result=subprocess.run([str(a.binary)],input=text,text=True,capture_output=True,check=True).stdout.split()
 assert result[0]==expected and list(map(float,result[1:]))==dst,result
 invalid.append({'operation':op,'status':expected,'atomic':True})
report={'reference':mujoco.__version__,'cases':len(requests),'passed':len(requests)-len(failures),'failures':failures,'invalid_cases':invalid,'binary_sha256':hashlib.sha256(a.binary.read_bytes()).hexdigest(),'oracle_command':cmd,'library_sha256':hashlib.sha256((lib/'libmujoco.so.3.14.0').read_bytes()).hexdigest()}
(a.out/'ada.output').write_text('\n'.join(ada)+'\n');(a.out/'c.output').write_text('\n'.join(c)+'\n');(a.out/'results.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:v for k,v in report.items() if k not in ['oracle_command','invalid_cases']}));assert not failures
