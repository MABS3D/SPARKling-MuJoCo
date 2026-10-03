"""Native complete signed response versus Ada kinematics and owned flex sides."""
import argparse,hashlib,json,resource,subprocess
from pathlib import Path
import mujoco
import numpy as np
from reference_contact_side import load as load_side
from reference_response import load as load_response


def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    for name in ('binary','model','side-reference','response-reference','out'):p.add_argument('--'+name,type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(128*1024**2,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    model=a.out/a.model.name;model.write_bytes(a.model.read_bytes())
    if a.model.with_suffix('.xml').exists():(a.out/a.model.with_suffix('.xml').name).write_bytes(a.model.with_suffix('.xml').read_bytes())
    (a.out/'model.json').write_text(json.dumps(dict(original=str(a.model),sha256=digest(model)))+'\n')
    m=mujoco.MjModel.from_binary_path(str(model));d=mujoco.MjData(m);mujoco.mj_forward(m,d)
    if m.nv>256 or m.neq:raise RuntimeError('outside first response probe scope')
    native_side=load_side(a.side_reference);native_response=load_response(a.response_reference)
    cases=[]
    for c in d.contact[:d.ncon]:
        sides=[]
        for k in range(2):
            if c.flex[k]>=0:
                opp=int(c.vert[1-k]) if c.flex[1-k]==c.flex[k] else -1
                sides.append([int(c.flex[k]),int(c.elem[k]),int(c.vert[k]),opp,-1])
            else:sides.append([-1,-1,-1,-1,int(m.geom_bodyid[c.geom[k]])])
        for sparse in (0,1):
            for dim in (1,3,4,6):
                cases.append(dict(label='contact',sparse=sparse,dim=dim,point=c.pos.tolist(),frame=c.frame.tolist(),sides=sides))
    # Two interpolated endpoints, plus duplicate shared supports through a
    # body ancestor. This remains a component response, not an invented contact.
    for f in range(m.nflex):
        nv=int(m.flex_vertnum[f]);start=int(m.flex_vertadr[f]);point=d.flexvert_xpos[start+nv//2].tolist()
        for sparse in (0,1):
            cases.append(dict(label='two-flex-vertices',sparse=sparse,dim=6,point=point,
                frame=np.eye(3).reshape(-1).tolist(),sides=[[f,-1,0,-1,-1],[f,-1,nv-1,-1,-1]]))
    lines=[' '.join(map(str,d.qpos)),' '.join(map(str,d.qvel)),str(len(cases))]
    lines+=[' '.join(map(str,[c['sparse'],c['dim'],*c['point'],*c['frame'],*c['sides'][0],*c['sides'][1]])) for c in cases]
    payload='\n'.join(lines)+'\n';(a.out/'cases.input').write_text(payload);(a.out/'requests.json').write_text(json.dumps(cases,indent=2)+'\n')
    expected=[]
    for c in cases:
        m.opt.jacobian=mujoco.mjtJacobian.mjJAC_SPARSE if c['sparse'] else mujoco.mjtJacobian.mjJAC_DENSE
        bids=[];weights=[];diagonal=np.zeros(2)
        for k,s in enumerate(c['sides']):
            f,e,v,opp,bodyid=s
            body=np.zeros(729,dtype=np.int32);weight=np.zeros(729)
            if f<0:nb=1;body[0]=bodyid;weight[0]=-1 if k==0 else 1
            else:nb=native_side.side(m._address,d._address,f,e,v,opp,int(k==0),np.ascontiguousarray(c['point']),body,weight)
            bids+=body[:nb].tolist();weights+=weight[:nb].tolist()
            if f<0:nb=1;weight[0]=1
            else:nb=native_side.side(m._address,d._address,f,e,v,opp,0,np.ascontiguousarray(c['point']),body,weight)
            for b,w in zip(body[:nb],weight[:nb]):
                for r in range(2):diagonal[r]=diagonal[r]+m.body_invweight0[b,r]*w
        n=len(bids);parts=np.zeros((n,6,m.nv));present=np.zeros((n,m.nv),dtype=np.int32)
        raw=np.zeros(6*m.nv);chain=np.zeros(m.nv,dtype=np.int32)
        nn=native_response.response(m._address,d._address,n,np.array(bids,dtype=np.int32),np.array(weights),
            np.ascontiguousarray(c['point']),parts,present,raw,chain)
        if not c['sparse']:chain[:nn]=np.arange(nn)
        sums=np.vstack((raw[:3*nn].reshape(3,nn),raw[3*m.nv:3*m.nv+3*nn].reshape(3,nn)))
        projected=np.zeros((6,nn));frame=np.array(c['frame'])
        native_response.project(projected[:3],frame,np.ascontiguousarray(sums[:3]),nn)
        native_response.project(projected[3:],frame,np.ascontiguousarray(sums[3:]),nn)
        expected.append(dict(columns=chain[:nn].tolist(),diagonal=diagonal.view(np.uint64).tolist(),
            rows=projected[:c['dim']].view(np.uint64).tolist()))
    (a.out/'expected.json').write_text(json.dumps(expected)+'\n')
    r=subprocess.run([str(a.binary),str(model)],input=payload,text=True,capture_output=True,timeout=240)
    (a.out/'cases.output').write_text(r.stdout+r.stderr);actual=[]
    for line in r.stdout.splitlines():
        x=line.split()
        if not x:continue
        if x[0]=='case':actual.append(dict(status=x[1],width=int(x[2]),rows=[]))
        elif actual and x[0]=='row':actual[-1]['rows'].append(list(map(int,x[1:])))
        elif actual and x[0] in ('columns','diagonal'):actual[-1][x[0]]=list(map(int,x[1:]))
    checks=[]
    for i,(c,w,g) in enumerate(zip(cases,expected,actual)):
        support=g.get('columns')==w['columns'];diag=g.get('diagonal')==w['diagonal']
        wj=np.array(w['rows'],dtype=np.uint64);gj=np.array(g['rows'],dtype=np.uint64)
        shape=wj.shape==gj.shape;exact=shape and np.array_equal(wj,gj)
        err=float(np.max(np.abs(wj.view(np.float64)-gj.view(np.float64)))) if shape and wj.size else 0 if shape else None
        numeric=shape and np.allclose(wj.view(np.float64),gj.view(np.float64),atol=2e-12,rtol=2e-12)
        checks.append(dict(index=i,label=c['label'],sparse=c['sparse'],dim=c['dim'],support=support,diagonal_bitwise=diag,
            jacobian_bitwise=bool(exact),jacobian_max_error=err,passed=bool(g['status']=='SUCCESS' and support and diag and numeric)))
    result=dict(cases=len(cases),actual=len(actual),passed=r.returncode==0 and len(actual)==len(cases) and all(x['passed'] for x in checks),
        checks=checks,passing=sum(x['passed'] for x in checks),jacobian_bitwise=sum(x['jacobian_bitwise'] for x in checks),
        diagonal_bitwise=sum(x['diagonal_bitwise'] for x in checks),jacobian_max_error=max((x['jacobian_max_error'] or 0 for x in checks),default=0),
        exit=r.returncode,model_sha256=digest(model),binary_sha256=digest(a.binary),scope='Native signed response versus owned Ada poses/Jacobians/endpoint production; no full dynamics.')
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(a.model.stem,result['passing'],len(cases),r.returncode,flush=True)
    raise SystemExit(not result['passed'])


if __name__=='__main__':main()
