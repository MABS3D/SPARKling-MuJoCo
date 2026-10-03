#!/usr/bin/env python3
"""Compare the bounded controller with unmodified MuJoCo engine_sleep.c."""
import argparse,hashlib,json,os,random,subprocess
from pathlib import Path
HERE=Path(__file__).resolve().parents[1]
REFERENCE=Path('/var/tmp/sparkling-advanced-bvh-accepted-validation-20261002-side/upstream')
LIB=Path('/var/tmp/sparkling-movement-env/lib/python3.12/site-packages/mujoco/libmujoco.so.3.14.0')
def case(n=3,values=None,policies=None,velocity=None,force=None,external=None,operations=None,mocap=False,weights=None):
    values=values or [-11]*n;policies=policies or [4]*n
    velocity=velocity if velocity is not None else [0.]*n;force=force if force is not None else [0.]*n
    external=external if external is not None else [0.]*(6*(n+1));weights=weights or [1.]*n
    data=[n,n+1,n,len(operations)]
    for i in range(n):data.extend([i+1,1,i,1,policies[i],values[i]])
    data.extend([-1,0,int(mocap)])
    for i in range(n):data.extend([i,0,0])
    for i in range(n):data.extend([i+1,weights[i]])
    for i in range(n):data.extend([velocity[i],.25+i,force[i]])
    data.extend(external)
    for op in operations:data.extend(op)
    return ' '.join(str(x) for x in data)+'\n'
def sleep(n,tol=.001,enabled=True,constraints=False,groups=None,permutation=None):
    groups=groups or [];op=[6,int(enabled),int(constraints),tol,len(groups)]
    for first,size in groups:op.extend([first,size])
    return op+(permutation or list(range(n)))
def fixtures():
    # Ten-step delay, reset on velocity/loads/policy, strict tolerance, signed zero.
    for n in [0,1,2,8,32,256,1024]:
        ops=[]
        for _ in range(12):ops.extend([sleep(n),[2,0]])
        yield f'countdown-{n}',case(n,operations=ops)
    for v in [-0.,0.,1e-300,-1e-300,.000999999,.001,.001000001,1e10]:
        for tol in [0.,.001,1.]:
            yield f'velocity-{v!r}-{tol}',case(velocity=[v,0.,0.],operations=[sleep(3,tol),[2,0],[3,1,0,0,0],[2,0]])
    for policy in range(6):
        yield f'policy-{policy}',case(policies=[policy]*3,operations=[sleep(3)]*12+[[2,0]])
    for f in [0.,-0.,1e-300,-1e-300,2.]:
        for which in ['qfrc','xfrc']:
            kw={'force':[f,0.,0.]} if which=='qfrc' else {'external':[0.]*6+[f]+[0.]*17}
            yield f'force-{which}-{f!r}',case(values=[0,1,2],operations=[[3,1,0,0,0],[2,0]],**kw)
    for state in [[0,1,2],[1,0,2],[1,2,0],[-1,2,1]]:
        for start in range(3):
            yield f'cycle-{state}-{start}',case(values=state,operations=[[0,start],[1,start,-5],[2,0]])
    for static in [0,1]:
        yield f'static-{static}',case(values=[0,1,2],mocap=bool(static),operations=[[2,0],[2,1],[2,0],[4,0,1,1,0,1],[2,0]])
    for eq in [0,1]:
        yield f'edge-{eq}',case(values=[-4,1,2],operations=[[4,eq,1,2,1,2,1,3],[2,0]])
    yield 'equality-different-cycles',case(values=[0,1,2],operations=[[4,1,1,1,1,2],[2,0]])
    yield 'equality-same-cycle',case(values=[1,0,2],operations=[[4,1,1,1,1,2],[2,0]])
    yield 'equality-missing',case(values=[0,1,2],operations=[[4,1,1,1,1,-1],[2,0]])
    yield 'disable',case(values=[1,0,2],operations=[[3,0,0,0,0],[2,0],sleep(3,enabled=False),[2,0]])
    yield 'pose-change',case(values=[1,0,2],operations=[[3,1,1,0,0],[2,0]])
    for flex in [0,1]:
        for active in [0,1]:
            yield f'group-{flex}-{active}',case(values=[-5,2,1],operations=[[5,flex,1,1,3,0,3,active,0,1,2],[2,0]])
    for constraint in [False,True]:
        yield f'no-islands-{constraint}',case(values=[-1]*3,operations=[sleep(3,constraints=constraint),[2,0]])
    yield 'coupled-island',case(values=[-1,-2,-1],operations=[sleep(3,constraints=True,groups=[(0,2)],permutation=[2,0,1]),[2,0]])
    rng=random.Random(20261002)
    for k in range(700):
        n=rng.choice([1,2,3,8,16,32]);p=[rng.randrange(6) for _ in range(n)]
        v=[rng.choice([0.,-0.,.0001,.001,.1,-.1]) for _ in range(n)]
        weights=[rng.choice([0.,.1,1.,10.,100.]) for _ in range(n)]
        force=[rng.choice([0.,0.,0.,-0.,1e-300]) for _ in range(n)]
        yield f'random-sleep-{k}',case(n,values=[rng.randint(-11,-1) for _ in range(n)],policies=p,velocity=v,force=force,weights=weights,operations=[sleep(n,rng.choice([0.,.001,.01,1.])) for _ in range(12)]+[[2,0]])
    for k in range(300):
        n=rng.choice([2,3,8,16,32]);perm=list(range(n));rng.shuffle(perm);t=[-11]*n
        for i,j in enumerate(perm):t[j]=perm[(i+1)%n]
        start=rng.randrange(n)
        yield f'random-cycle-{k}',case(n,values=t,operations=[[0,start],[1,start,rng.randint(-11,-1)],[2,0]])
def run(binary,data):
    p=subprocess.run([str(binary)],input=data,text=True,capture_output=True,timeout=20)
    if p.returncode:raise RuntimeError(f'{binary}: {p.returncode}: {p.stdout[-1000:]}{p.stderr[-1000:]}')
    return [[float(x) for x in line.split()] for line in p.stdout.splitlines()]
def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True);a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    oracle=a.out/'reference';cmd=['gcc','-O2','-DMJ_DISABLE_DEBUG_TRACING','-ffunction-sections','-fdata-sections','-I'+str(REFERENCE/'include'),'-I'+str(REFERENCE/'src'),str(HERE/'tests/reference.c'),str(REFERENCE/'src/engine/engine_sleep.c'),str(LIB),'-Wl,--gc-sections','-Wl,-rpath,'+str(LIB.parent),'-lm','-o',str(oracle)]
    q=subprocess.run(cmd,text=True,capture_output=True);(a.out/'reference-build.log').write_text(q.stdout+q.stderr)
    if q.returncode:print(q.stderr);raise SystemExit(q.returncode)
    records=[];fails=[];operations=0
    for name,data in fixtures():
        try:aa=run(a.binary,data);cc=run(oracle,data)
        except Exception as e:
            (a.out/(name+'.input')).write_text(data);print('CRASH',name,str(e),flush=True);raise
        operations+=len(cc);ok=aa==cc
        records.append(dict(name=name,passed=ok,operations=len(cc)))
        if not ok:
            fails.append(dict(name=name,ada=aa,c=cc));(a.out/(name+'.input')).write_text(data)
            print('FAIL',name,[(i,x,y) for i,(x,y) in enumerate(zip(aa,cc)) if x!=y][:1],flush=True)
        if len(fails)>=5:break
    result=dict(reference='3.14.0',expected_commit='9ecbb9d7b5ee623f54745638d36799ff90e6f7cd',cases=len(records),operations=operations,passed=sum(r['passed'] for r in records),failures=fails,records=records,command=cmd,
      hashes={str(x):hashlib.sha256(x.read_bytes()).hexdigest() for x in [a.binary,oracle,LIB,REFERENCE/'src/engine/engine_sleep.c',HERE/'tests/reference.c']},group_predicate_scope='Caller-supplied activity predicates; compiler/geometry producers are outside this test.')
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print('RESULT',result['passed'],result['cases'],'operations',operations);raise SystemExit(bool(fails))
if __name__=='__main__':main()
