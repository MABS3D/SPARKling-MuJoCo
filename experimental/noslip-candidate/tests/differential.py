"""NoSlip vs literal C post-pass AND complete native C forward constraints."""
import argparse, ctypes, hashlib, importlib.util, json, pathlib, subprocess
import mujoco
import numpy as np
HERE=pathlib.Path(__file__).resolve().parents[1]
def module(path):
    spec=importlib.util.spec_from_file_location('fixtures',path);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m);return m
def row(kind=5,dim=1,r=.1,bound=0,mu=None):return [kind,dim,r,bound,*(mu if mu is not None else [1]*5)]
def encode(p):
    head=[len(p['B']),p['iterations'],p['tolerance'],p['scale']]
    for k in ['AR','B','force','rows']:head.extend(np.asarray(p[k]).ravel())
    return ' '.join(format(float(v),'.17g') for v in head)+'\n'
def run(binary,problems):
    p=subprocess.run([str(binary)],input=''.join(encode(x) for x in problems),text=True,capture_output=True,timeout=180)
    if p.returncode:raise RuntimeError(p.stdout[-1500:]+p.stderr)
    lines=p.stdout.splitlines();assert len(lines)==len(problems),(len(lines),len(problems),p.stdout[-1000:])
    result=[]
    for line in lines:
        v=line.split();result.append(dict(status=v[0],iterations=int(v[1]),restored=int(v[2]),improvement=float(v[3]),force=np.array(v[4:],float)))
    return result
def make_oracle(out):
    wheel=pathlib.Path(mujoco.__file__).parent;so=out/'reference.so'
    command=['gcc','-shared','-fPIC','-O2','-ffp-contract=off','-I'+str(wheel/'include'),str(HERE/'tests/reference.c'),
             str(wheel/'libmujoco.so.3.14.0'),'-Wl,-rpath,'+str(wheel),'-lm','-o',str(so)]
    r=subprocess.run(command,text=True,capture_output=True);(out/'reference-build.log').write_text(r.stdout+r.stderr)
    if r.returncode:raise RuntimeError(r.stdout+r.stderr)
    fn=ctypes.CDLL(str(so)).oracle_noslip
    dp=np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS');ip=np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
    fn.argtypes=[ctypes.c_int,dp,dp,dp,dp,ip,ip,dp,dp,ctypes.c_int,ctypes.c_double,ctypes.c_double,ctypes.POINTER(ctypes.c_int),ctypes.POINTER(ctypes.c_double)]
    fn.restype=None
    def oracle(p):
        rows=np.asarray(p['rows'],float);f=np.asarray(p['force'],float).copy();it=ctypes.c_int();imp=ctypes.c_double()
        fn(len(f),np.ascontiguousarray(p['AR'],float),np.ascontiguousarray(rows[:,2]),np.ascontiguousarray(p['B'],float),f,
           np.ascontiguousarray(rows[:,0],dtype=np.int32),np.ascontiguousarray(rows[:,1],dtype=np.int32),
           np.ascontiguousarray(rows[:,3]),np.ascontiguousarray(rows[:,4:]),p['iterations'],p['tolerance'],p['scale'],ctypes.byref(it),ctypes.byref(imp))
        return f,it.value,imp.value
    return oracle,command
def native_fixtures(snapshot):
    ref=module(snapshot/'experimental/constraint-solvers-candidate/tests/differential.py')
    for name,xml in ref.fixtures():
        for method in range(3):
            for budget in [1,20]:
                for seed in [0,1]:
                    m=mujoco.MjModel.from_xml_string(xml);m.opt.solver=method;m.opt.noslip_iterations=0;m.opt.noslip_tolerance=0 if budget==1 else 1e-10
                    rng=np.random.default_rng(seed+1948);d0=mujoco.MjData(m)
                    d0.qvel[:]=rng.uniform(-2,2,m.nv);d0.qfrc_applied[:]=rng.uniform(-4,4,m.nv)
                    if name=='joint_limit':d0.qpos[0]=.08
                    if 'equality' in name:d0.qpos[:]=[.3,-.1]
                    mujoco.mj_forward(m,d0)
                    d=mujoco.MjData(m);d.qpos[:]=d0.qpos;d.qvel[:]=d0.qvel;d.qfrc_applied[:]=d0.qfrc_applied
                    m.opt.noslip_iterations=budget;mujoco.mj_forward(m,d);rows=[];i=0
                    while i<d.nefc:
                        kind=int(d.efc_type[i]);dim=d.contact[d.efc_id[i]].dim if kind in [6,7] else 1
                        width=2*(dim-1) if kind==6 else dim
                        mu=d.contact[d.efc_id[i]].friction if kind in [6,7] else np.ones(5)
                        for k in range(width):rows.append(row(kind,dim if k==0 else 0,d.efc_R[i+k],d.efc_frictionloss[i+k],mu))
                        i+=width
                    if not d.nefc:continue
                    p=dict(name=f'{name}-solver{method}-n{budget}-seed{seed}',AR=d.efc_AR.reshape(d.nefc,d.nefc).copy(),
                           B=d.efc_b.copy(),force=d0.efc_force.copy(),rows=rows,iterations=budget,
                           tolerance=m.opt.noslip_tolerance,scale=1/(m.stat.meaninertia*max(1,m.nv)),family='native')
                    yield p,d.efc_force.copy()
def synthetic():
    rng=np.random.default_rng(19481002)
    for n in [1,2,4,5,6,10,16,32,64,128,256]:
        for seed in range(12):
            rows=[];f=[]
            if seed%3==0 and n>=2:rows.append(row(0));f.append(-.2)
            if len(rows)<n:rows.append(row(1,bound=2));f.append(.3)
            while len(rows)<n:
                kind=6 if seed%2==0 else 7;dim=[3,4,6][(seed+len(rows))%3];width=2*(dim-1) if kind==6 else dim
                if width>n-len(rows):rows.append(row(3));f.append(1.2);continue
                mu=[.8,.4,.03,.005,.002]
                rows.extend(row(kind,dim if k==0 else 0,mu=mu) for k in range(width))
                if kind==6:f.extend(rng.uniform(0,2,width))
                else:
                    normal=float(rng.uniform(.1,2));v=rng.normal(size=dim-1);v*=normal*.6/np.linalg.norm(v)
                    f.extend([normal,*(v*np.array(mu[:dim-1]))])
            a=rng.normal(size=(n,min(n,32)));a=a@a.T
            rr=np.array(rows)[:,2];a+=np.diag(rr)
            yield dict(name=f'synthetic-{n}-{seed}',AR=a,B=rng.uniform(-3,3,n),force=f,rows=rows,
                       iterations=7 if seed%3 else 1,tolerance=0,scale=.7,family='synthetic')
    for name,a,b,f in [
        ('zero-curvature',np.ones((4,4)),[1,-1,0,0],[1,2,3,4]),
        ('zero-diagonal',np.zeros((4,4)),[1,-1,0,0],[1,2,0,0]),
        ('indefinite-restore',np.array([[1,3,0,0],[3,1,0,0],[0,0,1,0],[0,0,0,1]]),[0,0,0,0],[.2,1.,0,0])]:
        yield dict(name=name,AR=a,B=b,force=f,rows=[row(6,3 if i==0 else 0,r=0) for i in range(4)],iterations=3,tolerance=0,scale=1,family='edge')
    for dim in [3,4,6]:
        for force in [0,1e-16]:
            yield dict(name=f'zero-normal-{dim}-{force}',AR=np.eye(dim),B=np.ones(dim),force=[force]+[0]*(dim-1),
                       rows=[row(7,dim if i==0 else 0,r=0) for i in range(dim)],iterations=2,tolerance=0,scale=1,family='edge')
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--binary',type=pathlib.Path,required=True);ap.add_argument('--out',type=pathlib.Path,required=True)
    ap.add_argument('--snapshot',type=pathlib.Path,required=True);a=ap.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__=='3.14.0';oracle,cmd=make_oracle(a.out)
    native=list(native_fixtures(a.snapshot));problems=[p for p,_ in native]+list(synthetic())
    refs=[oracle(p) for p in problems];outputs=run(a.binary,problems);records=[];failures=[]
    for idx,(p,(cf,ci,imp),o) in enumerate(zip(problems,refs,outputs)):
        err=float(np.max(np.abs(cf-o['force']),initial=0));tol=3e-9+2e-10*np.max(np.abs(cf),initial=0)
        native_error=float(np.max(np.abs(cf-native[idx][1]),initial=0)) if idx<len(native) else None
        frozen=[i for i,r in enumerate(p['rows']) if int(r[0]) not in [1,2,6,7] or (int(r[0])==7 and int(r[1])>0)]
        preserved=bool(np.array_equal(o['force'][frozen],np.array(p['force'])[frozen]))
        # Dense/native arithmetic may stop at a nearby criterion iteration; fixed
        # iteration cases require exactly the same number of sweeps.
        passed=bool(err<=tol and preserved and o['status'] in ['CONVERGED','ITERATION_LIMIT']
                    and (p['tolerance']>0 or o['iterations']==ci) and (native_error is None or native_error<=tol))
        rec=dict(name=p['name'],family=p['family'],rows=len(p['B']),force_error=err,tolerance=float(tol),
                 native_oracle_error=native_error,iterations=o['iterations'],c_iterations=ci,preserved=preserved,
                 restored=o['restored'],status=o['status'],passed=passed)
        records.append(rec)
        if not passed:
            failures.append(rec)
            if len(failures)<=6:print('FAIL',rec,flush=True)
    # Atomic malformed-domain/layout rejection; disabled/empty paths.
    edges=[]
    p=dict(name='base',AR=[[1.1]],B=[1.],force=[.3],rows=[row(1,bound=2)],iterations=3,tolerance=0,scale=1)
    for label,changes,expected in [('negative-R',{'rows':[row(1,r=-1,bound=2)]},'INVALID_INPUT'),
      ('bad-header',{'rows':[row(6,3)]},'INVALID_INPUT'),('bad-scale',{'scale':0},'INVALID_INPUT'),
      ('nonfinite-domain',{'B':[1e30]},'INVALID_INPUT'),('dry-infeasible',{'force':[3.]},'INVALID_INPUT'),
      ('disabled',{'iterations':0},'DISABLED')]:
        q=p|changes;o=run(a.binary,[q])[0];ok=o['status']==expected and np.array_equal(o['force'],q['force'])
        edges.append(dict(name=label,passed=bool(ok)))
    q=dict(name='empty',AR=np.zeros((0,0)),B=[],force=[],rows=[],iterations=3,tolerance=1e-6,scale=1)
    o=run(a.binary,[q])[0];edges.append(dict(name='empty',passed=o['status']=='CONVERGED' and o['iterations']==0))
    q=dict(name='capacity',AR=np.eye(257),B=np.zeros(257),force=np.zeros(257),rows=[row() for _ in range(257)],iterations=3,tolerance=0,scale=1)
    o=run(a.binary,[q])[0];edges.append(dict(name='capacity-257',passed=o['status']=='INVALID_INPUT' and np.array_equal(o['force'],q['force'])))
    q=dict(name='numeric-growth',AR=np.eye(5)*1e20,B=np.ones(5)*1e20,force=[.5,1e10,0,0,0],
           rows=[row(1,r=0,bound=2)]+[row(7,4 if i==0 else 0,r=0,mu=[1e10]*5) for i in range(4)],iterations=3,tolerance=0,scale=1)
    o=run(a.binary,[q])[0];edges.append(dict(name='numeric-growth-after-dry-update',passed=o['status']=='NUMERIC_LIMIT' and np.array_equal(o['force'],q['force'])))
    summary=dict(reference='MuJoCo 3.14.0',binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
                 reference_command=cmd,cases=len(records),passed=sum(r['passed'] for r in records),
                 native_cases=len(native),edges=edges,failures=failures,records=records)
    (a.out/'results.json').write_text(json.dumps(summary,indent=2)+'\n')
    print('RESULT',summary['passed'],summary['cases'],'edges',sum(r['passed'] for r in edges),'/',len(edges),flush=True)
    if failures or not all(r['passed'] for r in edges):raise SystemExit(1)
if __name__=='__main__':main()
