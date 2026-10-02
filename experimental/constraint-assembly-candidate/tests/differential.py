#!/usr/bin/env python3
"""CSR assembly against the pinned literal C helper and the official engine.

Input preparation is outside Ada. Geometry tests generate Jacobians with mj_jac,
independently of the engine's efc_J, then rotate them into the contact frame.
This tests assembly; it does not implement/validate an Ada contact Jacobian.
"""
import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import subprocess

import mujoco
import numpy as np

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
SEED = 20261001


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def generic(kind, ident, chain, jac, pos, margin, loss=0):
    jac = np.asarray(jac, dtype=float).reshape(len(pos), len(chain))
    return dict(mode=0, kind=kind, id=ident, chain=list(map(int,chain)), jac=jac.tolist(),
                pos=list(map(float,pos)), margin=list(map(float,margin)), loss=float(loss))


def prepared(op):
    """Algorithmic input -> C append arguments, preserving evaluation order."""
    mode = op['mode']
    if mode == 0:
        return op
    if mode == 2:
        if op['loss'] == 0:
            return None
        return generic(1, op['dof'], [op['dof']], [[1]], [0], [0], op['loss'])
    if mode == 3:
        side = -1.0 if op['side'] == 0 else 1.0
        dist = side * (op['bound'] - op['value'])
        if dist >= op['margin']:
            return None
        return generic(3, op['id'], [op['dof']], [[-side]], [dist], [op['margin']])
    if mode == 4:
        return None
    dim, cone = op['dim'], op['cone']
    if not op['chain']:
        return None  # mj_instantiateContact skips zero-DOF contacts
    jac = np.asarray(op['jac'])
    if dim == 1:
        return generic(5, op['id'], op['chain'], jac, [op['dist']], [op['margin']])
    if cone == 0:
        edges = []
        for k in range(1, dim):
            edges.append(jac[0] + op['mu'][k-1] * jac[k])
            edges.append(jac[0] + (-op['mu'][k-1]) * jac[k])
        return generic(6, op['id'], op['chain'], edges,
                       [op['dist']] * len(edges), [op['margin']] * len(edges))
    return generic(7, op['id'], op['chain'], jac,
                   [op['dist']] + [0]*(dim-1), [op['margin']] + [0]*(dim-1))


def native_oracle(out):
    """Compile an unchanged copy of the private mj_addConstraint C body."""
    source = ROOT/'mujoco/src/engine/engine_core_constraint.c'
    text = source.read_text()
    start = text.index('static void mj_addConstraint(')
    end = text.index('\n}\n', start) + 3
    body = text[start:end]
    assert hashlib.sha256(body.encode()).hexdigest() == '39fb9bd75469312aec8de833f2842d78d085e7b80a9a1524302713810fb6fde9'
    includes = text[:text.index('#include')]
    includes += '#include <mujoco/mujoco.h>\n#define mjMAX(a,b) ((a)>(b)?(a):(b))\n#define mjERROR(...) mju_error(__VA_ARGS__)\n'
    wrapper = r'''
void reference_append(int nv, int size, int type, int id, int width,
  double loss, const int* chain, const double* jac, const double* pos,
  const double* margin, int* counts, int* nnz, int* adr, int* cols,
  double* vals, double* positions, double* margins, double* losses,
  int* types, int* ids) {
  mjModel m = {0}; mjData d = {0};
  m.nv = nv; m.opt.jacobian = mjJAC_SPARSE;
  d.nefc=counts[0]; d.ne=counts[1]; d.nf=counts[2]; d.nl=counts[3];
  d.efc_J_rownnz=nnz; d.efc_J_rowadr=adr; d.efc_J_colind=cols; d.efc_J=vals;
  d.efc_pos=positions; d.efc_margin=margins; d.efc_frictionloss=losses;
  d.efc_type=types; d.efc_id=ids;
  mj_addConstraint(&m,&d,jac,pos,margin,loss,size,type,id,width,chain);
  counts[0]=d.nefc; counts[1]=d.ne; counts[2]=d.nf; counts[3]=d.nl;
}
'''
    package = Path(mujoco.__file__).parent
    library = package/'libmujoco.so.3.14.0'
    assert library.exists(), library
    (out/'reference.c').write_text(includes + body + wrapper)
    cmd = ['gcc', '-std=c11', '-O2', '-ffp-contract=off', '-fPIC', '-shared',
           '-I'+str(package/'include'), str(out/'reference.c'), str(library),
           '-Wl,-rpath,'+str(package), '-o', str(out/'reference.so')]
    subprocess.run(cmd, check=True, capture_output=True, text=True)
    lib = ct.CDLL(str(out/'reference.so'))
    ip = ct.POINTER(ct.c_int)
    dp = ct.POINTER(ct.c_double)
    lib.reference_append.argtypes = [ct.c_int]*5 + [ct.c_double] + [ip,dp,dp,dp,ip,ip,ip,ip,dp,dp,dp,dp,ip,ip]
    lib.reference_append.restype = None
    return lib, dict(source_sha256=sha(source), helper_sha256=hashlib.sha256(body.encode()).hexdigest(),
                     library_sha256=sha(library), command=cmd,
                     compiler=subprocess.check_output(['gcc','--version'],text=True).splitlines()[0])


def expected(case, lib):
    rc, ec = case['rc'], case['ec']
    counts = np.zeros(4, np.int32)
    nnz, adr, types, ids = [np.zeros(rc, np.int32) for _ in range(4)]
    cols = np.zeros(ec, np.int32)
    vals = np.zeros(ec)
    pos, margins, losses = [np.zeros(rc) for _ in range(3)]
    statuses = []
    nv = case['nv']
    calls = 0
    def ip(a): return a.ctypes.data_as(ct.POINTER(ct.c_int))
    def dp(a): return a.ctypes.data_as(ct.POINTER(ct.c_double))
    for op in case['ops']:
        if op['mode'] == 4:
            counts[:] = 0
            nv = op['nv']
            statuses.append(1)
            continue
        a = prepared(op)
        if a is None or (not a['chain'] and a['kind'] < 5):
            statuses.append(1)
            continue
        width, n = len(a['chain']), len(a['pos'])
        nr = int(counts[0]); used = int(adr[nr-1] + nnz[nr-1]) if nr else 0
        if nr+n > rc or used+n*width > ec:
            statuses.append(2)
            continue
        chain = np.asarray(a['chain'], np.int32)
        jac = np.asarray(a['jac'], float).ravel()
        p, m = np.asarray(a['pos'], float), np.asarray(a['margin'], float)
        lib.reference_append(nv,n,a['kind'],a['id'],width,a['loss'],
            ip(chain),dp(jac),dp(p),dp(m),ip(counts),ip(nnz),ip(adr),ip(cols),
            dp(vals),dp(pos),dp(margins),dp(losses),ip(types),ip(ids))
        calls += 1
        statuses.append(0)
    nr = int(counts[0]); used = int(adr[nr-1]+nnz[nr-1]) if nr else 0
    return dict(status=statuses, head=[nv,nr,used,*map(int,counts[1:])],
                rows=[[int(adr[r]),int(nnz[r]),int(types[r]),int(ids[r]),
                       float(pos[r]),float(margins[r]),float(losses[r])] for r in range(nr)],
                cols=cols[:used].tolist(), vals=vals[:used].tolist(), calls=calls)


def encode(case):
    words = [case['nv'],case['rc'],case['ec'],len(case['ops'])]
    for op in case['ops']:
        mode = op['mode']; words.append(mode)
        if mode == 0:
            words += [op['kind'],op['id'],len(op['pos']),len(op['chain']),op['loss']]
            words += op['chain'] + [x for row in op['jac'] for x in row]
            words += [x for pair in zip(op['pos'],op['margin']) for x in pair]
        elif mode == 1:
            words += [op['dim'],op['cone'],op['id'],len(op['chain']),op['dist'],op['margin']]
            words += op['mu'] + op['chain'] + [x for row in op['jac'] for x in row]
        elif mode == 2:
            words += [op['dof'],op['loss']]
        elif mode == 3:
            words += [op['id'],op['dof'],op['side'],op['value'],op['bound'],op['margin']]
        else:
            words += [op['nv']]
    return ' '.join(str(x) for x in words)


def parse(output, cases):
    lines = iter(output.splitlines()); result=[]
    for _ in cases:
        status = list(map(int,next(lines).split()))
        head = list(map(int,next(lines).split()))
        rows=[]
        for _ in range(head[1]):
            w = next(lines).split()
            rows.append(list(map(int,w[:4])) + list(map(float,w[4:])))
        cols=[];vals=[]
        for _ in range(head[2]):
            c,v=next(lines).split();cols.append(int(c));vals.append(float(v))
        result.append(dict(status=status,head=head,rows=rows,cols=cols,vals=vals))
    assert next(lines,None) is None, 'Unexpected trailing output'
    return result


def random_cases():
    rng=np.random.default_rng(SEED); cases=[]
    for kind in range(8):
        for width in [0,1,2,8,17,64]:
            for n in [1,3,6,10]:
                chain=sorted(rng.choice(64,width,replace=False).tolist())
                for zeros in [False,True]:
                    j = np.zeros((n,width)) if zeros else rng.normal(size=(n,width))*100
                    op=generic(kind,91,chain,j,rng.normal(size=n),rng.uniform(0,.1,n),.7)
                    cases.append(dict(nv=64,rc=32,ec=1024,ops=[op]))
    for dim in [1,3,4,6]:
        for cone in [0,1]:
            for width in [0,1,6,17,64]:
                for _ in range(8):
                    chain=sorted(rng.choice(64,width,replace=False).tolist())
                    j=rng.uniform(-1e20,1e20,(dim,width));j[:,::3]=0
                    mu=rng.uniform(0,1e10,5);mu[::2]=0
                    op=dict(mode=1,dim=dim,cone=cone,id=9,chain=chain,jac=j.tolist(),
                            mu=mu.tolist(),dist=-.021,margin=.013)
                    cases.append(dict(nv=64,rc=32,ec=1024,ops=[op]))
    for side in [0,1]:
        for margin in [0,.125]:
            for dist in [-1,0, np.nextafter(margin,-np.inf),margin,np.nextafter(margin,np.inf),1]:
                op=dict(mode=3,id=7,dof=3,side=side,value=0.,
                        bound=float(dist*(-1 if side==0 else 1)),margin=margin)
                cases.append(dict(nv=8,rc=8,ec=8,ops=[op]))
    for loss in [0.,np.nextafter(0,1),.25,1e10]:
        cases.append(dict(nv=8,rc=8,ec=8,ops=[dict(mode=2,dof=5,loss=float(loss))]))
    prefix=generic(0,11,[0,3],[[1,0],[0,2]],[.2,.4],[0,0])
    for rc,ec in [(2,4),(3,4),(3,5),(3,6),(10,8),(10,9),(10,10)]:
        ops=[prefix,dict(mode=2,dof=1,loss=.7),
             dict(mode=3,id=3,dof=2,side=0,value=-.2,bound=0.,margin=0.),
             dict(mode=1,dim=3,cone=0,id=2,chain=[0,1],jac=[[1,0],[0,1],[2,3]],
                  mu=[.7,.7,.1,.1,.1],dist=-.03,margin=.01)]
        cases.append(dict(nv=8,rc=rc,ec=ec,ops=ops))
        cases.append(dict(nv=8,rc=rc,ec=ec,ops=ops+[dict(mode=4,nv=8),*ops]))
    for _ in range(80):
        ops=[]
        for _ in range(12):
            width=int(rng.integers(0,9));n=int(rng.integers(1,11));kind=int(rng.integers(0,8))
            chain=sorted(rng.choice(8,width,replace=False).tolist())
            ops.append(generic(kind,23,chain,rng.normal(size=(n,width)),rng.normal(size=n),[0]*n))
        cases.append(dict(nv=8,rc=64,ec=512,ops=ops))
    cases.append(dict(nv=4096,rc=16,ec=16,ops=[
        generic(0,3,[0,4095],[[1e61,-1e61],[-0.,0.]],[1e30,-1e30],[0.,1e30])]))
    for kind in range(8):
        for rows in [1,3,10]:
            cases.append(dict(nv=0,rc=16,ec=1,ops=[
                generic(kind,4,[],np.zeros((rows,0)),[-.1]*rows,[.01]*rows)]))
    cases.append(dict(nv=8,rc=16,ec=16,ops=[prefix,dict(mode=4,nv=0),
        dict(mode=1,dim=6,cone=0,id=0,chain=[],jac=[[]]*6,mu=[0.]*5,dist=0.,margin=0.),
        generic(0,0,[],np.zeros((1,0)),[0.],[0.])]))
    for dim,cone in [(1,0),(6,0),(6,1)]:
        width=4096
        j=rng.uniform(-1e20,1e20,(dim,width))
        op=dict(mode=1,dim=dim,cone=cone,id=3,chain=list(range(width)),jac=j.tolist(),
                mu=[1e10,0.,1e-15,.8,.7],dist=-1e30,margin=1e30)
        cases.append(dict(nv=width,rc=16,ec=40960,ops=[op]))
    return cases


def engine_snapshot(m,d):
    nr=d.nefc
    used=int(d.efc_J_rowadr[nr-1]+d.efc_J_rownnz[nr-1]) if nr else 0
    return dict(head=[m.nv,nr,used,d.ne,d.nf,d.nl],
        rows=[[int(d.efc_J_rowadr[r]),int(d.efc_J_rownnz[r]),int(d.efc_type[r]),int(d.efc_id[r]),
               float(d.efc_pos[r]),float(d.efc_margin[r]),float(d.efc_frictionloss[r])] for r in range(nr)],
        cols=d.efc_J_colind[:used].tolist(),vals=d.efc_J[:used].tolist())


def physical_cases():
    cases=[]
    for dim in [1,3,4,6]:
        for cone in ['pyramidal','elliptic']:
            for rotation in [False,True]:
                # Two contacting descendants exercise cancellation of shared ancestor DOFs.
                for shared in [False,True]:
                    angle='0.27 -0.19 0.11' if rotation else '0 0 0'
                    ground=f'<geom name="floor" type="plane" size="2 2 .1" euler="{angle}" condim="{dim}"/>'
                    obj=f'<body name="object" pos="0 0 .10"><freejoint/>'\
                        f'<geom type="sphere" size=".12" condim="{dim}" friction=".7 .04 .02" margin=".02" gap=".005"/></body>'
                    if shared:
                        ground=f'<body name="first"><joint type="slide" axis="1 0 0"/>'\
                               f'<geom type="sphere" size=".12" pos="-.10 0 .2" condim="{dim}"/></body>'
                        obj=f'<body name="second"><joint type="slide" axis="0 0 1"/>'\
                            f'<geom type="sphere" size=".12" pos=".10 0 .2" condim="{dim}" friction=".7 .04 .02"/></body>'
                        ground='<body name="parent"><inertial pos="0 0 0" mass="1" diaginertia=".1 .1 .1"/><joint type="hinge" axis="0 1 0"/>'+ground+obj+'</body>'
                        obj=''
                    xml=f'<mujoco><compiler angle="radian"/><option jacobian="sparse" cone="{cone}"/>'\
                        f'<worldbody>{ground}{obj}</worldbody></mujoco>'
                    m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m)
                    if not shared:
                        d.qpos[3:7]=np.array([.9,.2,-.1,.25])/np.linalg.norm([.9,.2,-.1,.25])
                    else:
                        d.qpos[0]=.37
                    mujoco.mj_forward(m,d)
                    ops=[]
                    def ancestors(body):
                        chain=set()
                        while body:
                            a=int(m.body_dofadr[body]);n=int(m.body_dofnum[body])
                            chain.update(range(a,a+n));body=int(m.body_parentid[body])
                        return chain
                    for ci in range(d.ncon):
                        c=d.contact[ci]
                        if c.efc_address < 0:
                            continue
                        b1,b2=int(m.geom_bodyid[c.geom1]),int(m.geom_bodyid[c.geom2])
                        chain=sorted(ancestors(b1)^ancestors(b2))
                        p1,r1,p2,r2=[np.zeros((3,m.nv)) for _ in range(4)]
                        mujoco.mj_jac(m,d,p1,r1,c.pos,b1);mujoco.mj_jac(m,d,p2,r2,c.pos,b2)
                        frame=np.array(c.frame).reshape(3,3)
                        full=np.vstack((frame@(p2-p1),frame@(r2-r1)))[:c.dim,chain]
                        ops.append(dict(mode=1,dim=int(c.dim),cone=int(cone=='elliptic'),id=ci,
                                        chain=chain,jac=full.tolist(),mu=list(map(float,c.friction)),
                                        dist=float(c.dist),margin=float(c.includemargin)))
                    assert ops and d.nefc, (dim,cone,shared)
                    cases.append(dict(nv=m.nv,rc=128,ec=2048,ops=ops,engine=engine_snapshot(m,d),
                                      label=f'contact-{dim}-{cone}-rotate{rotation}-shared{shared}'))
    # Real engine scalar limits/friction and prepared equality/tendon rows.
    for x in [-.3,-.2,-.1,0.,.1,.2,.3]:
        xml='''<mujoco><compiler angle="radian"/><option jacobian="sparse"/>
        <worldbody><body><joint name="x" type="slide" axis="1 0 0" range="-.2 .2" margin=".03" frictionloss=".7"/>
        <geom size=".1" type="sphere" contype="0"/><body><joint name="y" type="hinge" range="-.5 .5" margin=".1"/>
        <geom size=".1" type="sphere" contype="0" pos="0 0 .3"/></body></body></worldbody>
        <tendon><fixed name="t" frictionloss=".2" limited="true" range="-.15 .15" margin=".02">
        <joint joint="x" coef="1"/><joint joint="y" coef=".1"/></fixed></tendon>
        <equality><joint joint1="y" polycoef="0 0 0 0 0"/></equality></mujoco>'''
        m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);d.qpos[:]=[x,.6]
        mujoco.mj_forward(m,d);ops=[]
        # Equality geometry and tendon Jacobians are prepared by their own modules.
        for r in range(d.nefc):
            kind=int(d.efc_type[r]);ident=int(d.efc_id[r])
            if kind in [0,2]:
                a=int(d.efc_J_rowadr[r]);n=int(d.efc_J_rownnz[r])
                ops.append(generic(kind,ident,d.efc_J_colind[a:a+n],
                    [d.efc_J[a:a+n]],[d.efc_pos[r]],[d.efc_margin[r]],d.efc_frictionloss[r]))
        for k,loss in enumerate(m.dof_frictionloss):
            # C orders DOF friction before tendon friction.
            if loss:
                at=int(d.ne)
                ops.insert(at,dict(mode=2,dof=k,loss=float(loss)))
        for jid in range(m.njnt):
            if not m.jnt_limited[jid]: continue
            for side in [0,1]:
                ops.append(dict(mode=3,id=jid,dof=int(m.jnt_dofadr[jid]),side=side,
                    value=float(d.qpos[m.jnt_qposadr[jid]]),bound=float(m.jnt_range[jid,side]),
                    margin=float(m.jnt_margin[jid])))
        for r in range(d.nefc):
            if d.efc_type[r]==4:
                a=int(d.efc_J_rowadr[r]);n=int(d.efc_J_rownnz[r])
                ops.append(generic(4,int(d.efc_id[r]),d.efc_J_colind[a:a+n],
                    [d.efc_J[a:a+n]],[d.efc_pos[r]],[d.efc_margin[r]]))
        cases.append(dict(nv=m.nv,rc=64,ec=512,ops=ops,engine=engine_snapshot(m,d),label=f'limits-{x}'))
    return cases


def compare(actual, ref, label, tolerance=0):
    for key in ['status','head','cols']:
        if key in ref:
            assert actual[key]==ref[key], (label,key,actual[key],ref[key])
    assert len(actual['rows'])==len(ref['rows']),label
    maxerr=0.
    for a,b in zip(actual['rows'],ref['rows']):
        assert a[:4]==b[:4], (label,'descriptor',a,b)
        for x,y in zip(a[4:],b[4:]):
            assert x==y, (label,'metadata',x,y)
    for x,y in zip(actual['vals'],ref['vals']):
        err=abs(x-y);maxerr=max(maxerr,err)
        assert err<=tolerance*max(1.,abs(x),abs(y)),(label,'value',x,y,err)
        if tolerance==0 and x==0:
            assert np.signbit(x)==np.signbit(y),(label,'signed zero',x,y)
    return maxerr


def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--binary',type=Path,action='append',required=True)
    ap.add_argument('--out',type=Path,required=True)
    args=ap.parse_args();out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
    assert mujoco.__version__=='3.14.0',mujoco.__version__
    lib,native=native_oracle(out)
    cases=random_cases()+physical_cases()
    (out/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
    expected_cases=[expected(case,lib) for case in cases]
    payload=str(len(cases))+'\n'+'\n'.join(encode(c) for c in cases)+'\n'
    (out/'input.txt').write_text(payload)
    records=[]
    for binary in args.binary:
        p=subprocess.run([str(binary.resolve())],input=payload,text=True,capture_output=True,timeout=120)
        (out/(binary.parent.parent.name+'-output.txt')).write_text(p.stdout)
        assert p.returncode==0,(p.returncode,p.stderr[-2000:])
        actual=parse(p.stdout,cases);worst=0
        for k,(c,a,e) in enumerate(zip(cases,actual,expected_cases)):
            compare(a,e,str(k))
            if 'engine' in c:
                worst=max(worst,compare(a,c['engine'],c['label'],tolerance=2e-13))
        records.append(dict(binary=str(binary.resolve()),binary_sha256=sha(binary),
                            cases=len(cases),passed=True,engine_max_absolute_error=worst))
        print(binary, 'PASS',len(cases),'cases; engine max error',worst,flush=True)
    report=dict(seed=SEED,reference_version=mujoco.__version__,native_reference=native,
        cases=len(cases),operations=sum(len(c['ops']) for c in cases),
        literal_c_calls=sum(e['calls'] for e in expected_cases),
        engine_scenes=sum('engine' in c for c in cases),results=records)
    (out/'results.json').write_text(json.dumps(report,indent=2)+'\n')


if __name__=='__main__':
    main()
