import ctypes as c,json,subprocess,hashlib
from pathlib import Path
import numpy as np
root=Path(__file__).resolve().parents[1];rng=np.random.default_rng(20260928)
libpath=root/'bin/reference.so';lib=c.CDLL(str(libpath));dp=c.POINTER(c.c_double);ip=c.POINTER(c.c_int)
lib.mju_factorLU.argtypes=[dp,c.c_int,ip];lib.mju_solveLU.argtypes=[dp,dp,dp,ip,c.c_int]
lib.mju_factorLUSparse.argtypes=[dp,c.c_int,ip,ip,ip,ip,ip]
lib.mju_solveLUSparse.argtypes=[dp,dp,dp,c.c_int,ip,ip,ip,ip,ip]
def d(x):return x.ctypes.data_as(dp)
def i(x):return x.ctypes.data_as(ip)
def words(a):return ' '.join(format(float(x),'.17e') for x in np.ravel(a))
def ints(a):return ' '.join(str(int(x)) for x in a)
cases=[]
for n in [0,1,2,3,4,6,8,16,31,64]:
 for k in range(20):
  a=rng.normal(size=(n,n));b=rng.normal(size=n)
  if k%2==0:a+=np.eye(n)*(n+1)
  cases.append(dict(mode='D',a=a,b=b,expect='SUCCESS',name=f'dense_{n}_{k}'))
for a in [np.zeros((1,1)),np.array([[1.,2.],[2.,4.]]),np.diag([1.,1e-16])]:
 cases.append(dict(mode='D',a=a,b=np.ones(len(a)),expect='SINGULAR',name='singular'))
for pivot in [1e-15,-1e-15,1e-14,-1e-14]:
 cases.append(dict(mode='D',a=np.array([[pivot]]),b=np.array([pivot]),expect='SUCCESS',name='pivot_boundary'))
for n in [0,1,2,4,8,16,32,64]:
 for topology in ['diagonal','chain','star','tree','full']:
  mask=np.eye(n,dtype=bool)
  if topology=='full':mask[:]=True
  elif topology!='diagonal':
   for j in range(1,n):
    parent=j-1 if topology=='chain' else 0 if topology=='star' else int(rng.integers(j))
    mask[j,parent]=mask[parent,j]=True
    if topology=='tree':
     for k in np.where(mask[parent,:parent])[0]:mask[j,k]=mask[k,j]=True
  for k in range(5):
   a=rng.normal(size=(n,n))*mask+np.eye(n)*(n+2);b=rng.normal(size=n)
   cases.append(dict(mode='S',a=a,b=b,mask=mask,expect='SUCCESS',name=f'{topology}_{n}_{k}'))
for pivot in [0.,1e-16,-1e-16,-0.]:
 cases.append(dict(mode='S',a=np.diag([1.,pivot]),mask=np.eye(2,dtype=bool),b=np.array([1.,1e-15]),expect='SUCCESS',name='clamp'))
# Four-cycle requires an additional (0,2)/(2,0) entry on eliminating row 3.
a=np.array([[4.,1.,0.,1.],[1.,4.,1.,0.],[0.,1.,4.,1.],[1.,0.,1.,4.]])
cases.append(dict(mode='S',a=a,mask=a!=0,b=np.ones(4),expect='FILL_REQUIRED',name='fill_required'))
a=1e99*np.array([[1.,1.,0.],[-1.,1.,1.],[0.,-1.,1.]])
cases.append(dict(mode='D',a=a,b=np.ones(3),expect='SUCCESS',name='dense_large_fallback_growth'))
# Exercise stage-bound refresh and both factor/solve numeric-domain failures.
a=rng.normal(size=(192,192))+np.eye(192)*193
cases.append(dict(mode='D',a=a,b=rng.normal(size=192),expect='SUCCESS',name='dense_refresh_192'))
cases.append(dict(mode='D',a=np.array([[1e100,1e100],[-1e100,1e100]]),b=np.ones(2),expect='NUMERIC_LIMIT',name='dense_numeric_limit'))
a=np.array([[1e100,1e100],[1e100,1e-15]])
cases.append(dict(mode='S',a=a,mask=np.ones((2,2),dtype=bool),b=np.ones(2),expect='NUMERIC_LIMIT',name='sparse_numeric_limit'))
cases.append(dict(mode='D',a=np.array([[1e-15]]),b=np.array([1e100]),expect='SUCCESS',solve_expect='NUMERIC_LIMIT',name='solve_numeric_limit'))
lines=[]
for v in cases:
 a=v['a'];n=len(a)
 if v['mode']=='D':lines.append(f'D {n} {words(a)} {words(v["b"])}')
 else:
  mask=v['mask'];col=np.where(mask)[1].astype(np.int32);row=np.concatenate(([0],np.cumsum(mask.sum(axis=1)))).astype(np.int32)
  v.update(col=col,row=row,values=a[mask].copy())
  lines.append(f'S {n} {len(col)} {ints(row)} {ints(col)} {words(a[mask])} {words(v["b"])}')
# Rejected structural layouts must not be passed to C's fatal error handler.
invalid=['S 2 2 0 1 2 0 0 1 1 1 1', 'S 2 3 0 2 3 0 0 1 1 1 1 1 1',
         'S 2 3 0 2 3 1 0 1 1 1 1 1 1','S 1 1 0 2 0 1 1']
lines+=invalid
p=subprocess.run([str(root/'bin/lu_probe')],input='\n'.join(lines)+'\n',text=True,capture_output=True)
(root/'evidence/numerical-input.txt').write_text('\n'.join(lines)+'\n');(root/'evidence/numerical-output.txt').write_text(p.stdout);(root/'evidence/numerical-stderr.txt').write_text(p.stderr)
assert p.returncode==0,p.stderr
out=p.stdout.splitlines();assert len(out)==5*len(lines),(len(out),len(lines))
worst=0.;counts={'dense':0,'sparse':0,'rejections':0};fail=[];clamps=[]
for index,v in enumerate(cases):
 status,factors,pivots,sol_status,x=out[5*index:5*index+5];factors=np.fromstring(factors,sep=' ');x=np.fromstring(x,sep=' ')
 try:
  assert status==v['expect'],(status,v['expect'])
  if status!='SUCCESS':counts['rejections']+=1;continue
  if v.get('solve_expect')=='NUMERIC_LIMIT':
   assert sol_status=='NUMERIC_LIMIT';counts['rejections']+=1;continue
  n=len(v['a']);b=v['b'];cx=np.zeros(n)
  if v['mode']=='D':
   cf=v['a'].copy();cp=np.zeros(n,dtype=np.int32);assert lib.mju_factorLU(d(cf),n,i(cp))==1
   lib.mju_solveLU(d(cx),d(cf),d(b),i(cp),n);assert np.array_equal(cp,np.fromstring(pivots,sep=' ',dtype=int))
   counts['dense']+=1
  else:
   cf=v['values'].copy();row=v['row'];col=v['col'];nnz=np.diff(row).astype(np.int32);scratch=np.zeros(n,dtype=np.int32)
   diag=np.array([np.where(col[row[k]:row[k+1]]==k)[0][0] for k in range(n)],dtype=np.int32)
   first=lib.mju_factorLUSparse(d(cf),n,i(scratch),i(nnz),i(row),i(col),None)
   assert int(pivots)==first,(pivots,first)
   lib.mju_solveLUSparse(d(cx),d(cf),d(b),n,i(nnz),i(row),i(diag),i(col),None)
   if first!=-1:clamps.append(v['name'])
   counts['sparse']+=1
  assert sol_status=='SUCCESS'
  np.testing.assert_allclose(factors,cf.ravel(),rtol=2e-12,atol=2e-12)
  np.testing.assert_allclose(x,cx,rtol=2e-10,atol=2e-10)
  if n and v['name']!='clamp':
   residual=np.linalg.norm(v['a']@x-b,np.inf)/(np.linalg.norm(v['a'],np.inf)*np.linalg.norm(x,np.inf)+np.linalg.norm(b,np.inf))
   worst=max(worst,float(residual));assert residual<2e-12,residual
 except Exception as e:fail.append(dict(name=v['name'],error=str(e)))
for j in range(len(invalid)):
 assert out[5*(len(cases)+j)]=='INVALID_STRUCTURE';counts['rejections']+=1
result=dict(status='passed' if not fail else 'failed',cases=len(lines),counts=counts,clamped=len(clamps),worst_scaled_residual=worst,failures=fail,oracle='MuJoCo 3.14.0 extracted C',library=str(libpath),library_sha256=hashlib.sha256(libpath.read_bytes()).hexdigest(),binary_sha256=hashlib.sha256((root/'bin/lu_probe').read_bytes()).hexdigest())
(root/'evidence/numerical.json').write_text(json.dumps(result,indent=2));print(json.dumps(result,indent=2));assert not fail
