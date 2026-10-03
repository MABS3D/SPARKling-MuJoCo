"""Differential numerical tests against pinned native MuJoCo, seed 20261002.
Run with /var/tmp/sparkling-movement-env/bin/python; writes only --out.
"""
import argparse, ctypes as ct, json, subprocess, collections
from pathlib import Path
import numpy as np
import mujoco

P=ct.POINTER(ct.c_double); I=ct.POINTER(ct.c_int)
KINDS=[0,2,3,4,5,6]
NAMES=['plane','sphere','capsule','ellipsoid','cylinder','box']
IDENT=np.eye(3).ravel(); ZERO=np.zeros(3)
def p(x): return np.asarray(x,dtype=np.float64).ctypes.data_as(P)
def ip(x): return np.asarray(x,dtype=np.int32).ctypes.data_as(I)
def flat(xs):
    for x in xs:
        if isinstance(x,(list,tuple,np.ndarray)): yield from flat(x)
        else: yield x
def line(xs): return ' '.join(str(x) for x in flat(xs))
def pose(pos=ZERO,rot=IDENT): return [pos,rot]
def rotation(rng):
    q=rng.normal(size=4);q/=np.linalg.norm(q); mat=np.empty(9);mujoco.mju_quat2Mat(mat,q);return mat

def configure(lib):
    lib.ref_query.argtypes=[ct.c_int,P,P,ct.c_int,ct.c_int,P,I,P,P]
    lib.ref_objective.argtypes=[ct.c_int,P,ct.c_int,P,P,P,ct.c_int,P,ct.c_int,P]
    lib.ref_aabb.argtypes=[P,P,ct.c_double];lib.ref_aabb.restype=ct.c_int
    lib.ref_obb.argtypes=[P,P,P,P,P,P,ct.c_double];lib.ref_obb.restype=ct.c_int
    lib.ref_triangle.argtypes=[ct.c_int,P,P,P,P,ct.c_double,ct.c_double,P];lib.ref_triangle.restype=ct.c_int
    for name,args in [('ref_geom',[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,ct.c_int,ct.c_double,P]),
                      ('ref_elems',[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,ct.c_int,ct.c_int,ct.c_double,P]),
                      ('ref_ev',[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,ct.c_int,P]),
                      ('ref_generate',[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,ct.c_double,P]),
                      ('ref_mesh_sdf',[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,P]),
                      ('ref_flex_sdf',[ct.c_void_p,ct.c_void_p,ct.c_int,ct.c_int,P,I,ct.c_int])]:
        getattr(lib,name).argtypes=args;getattr(lib,name).restype=ct.c_int
    lib.ref_register_sphere()

def model_for(dim,points,radius,kind=1,size=(.2,.2,.2),selfmode='none',internal=False,elementcount=1,sdf=False):
    points=np.asarray(points); groups=len(points)//(dim+1)
    names=[f'v{i}' for i in range(len(points))]
    bodies=''.join(f'<body name="{n}" pos="{line(pos)}"><freejoint/><geom size=".001" mass="1" contype="0" conaffinity="0"/></body>' for n,pos in zip(names,points))
    sz=list(size)
    if kind==1:sz=sz[:1]
    if kind in (2,4):sz=sz[:2]
    if sdf:
        extension='<extension><plugin plugin="sparkling.test.sphere"><instance name="s"/></plugin></extension>'
        asset='<asset><mesh name="s"><plugin instance="s"/></mesh></asset>'
        geom='<geom name="target" type="sdf" mesh="s"><plugin instance="s"/></geom>'
    else:extension=asset='';geom=f'<geom name="target" type="{NAMES[kind]}" size="{line(sz)}"/>'
    elems=line(list(range(groups*(dim+1))))
    flex=f'<deformable><flex name="f" dim="{dim}" radius="{radius}" body="{" ".join(names)}" vertex="{line(np.zeros((len(points),3)))}" element="{elems}"><contact selfcollide="{selfmode}" internal="{str(internal).lower()}"/></flex></deformable>'
    m=mujoco.MjModel.from_xml_string(f'<mujoco>{extension}{asset}<option sdf_initpoints="8" sdf_iterations="10"/>'
                                    f'<worldbody>{geom}{bodies}</worldbody>{flex}</mujoco>')
    d=mujoco.MjData(m);mujoco.mj_forward(m,d);return m,d

def main():
    ap=argparse.ArgumentParser();ap.add_argument('--binary',required=True);ap.add_argument('--oracle',required=True);ap.add_argument('--out',required=True);a=ap.parse_args()
    assert mujoco.__version__=='3.14.0'
    out=Path(a.out);out.mkdir(parents=True,exist_ok=True)
    lib=ct.CDLL(a.oracle);configure(lib);rng=np.random.default_rng(20261002)
    cases=[]
    def add(group,inputs,expected,kind='query',tol=3e-9,metadata=False):
        cases.append((group,line(inputs),np.asarray(expected),kind,tol,metadata))
    for k in range(6):
        for j in range(90):
            size=rng.uniform(.05,.8,3);x=rng.uniform(-1,1,3);value=np.empty(4)
            lib.ref_query(KINDS[k],p(size),p(x),1,0,None,None,None,p(value))
            add('sdf_analytic',[1,k,size,x,1],value)
    # Singular gradients: native NaNs must become explicit rejection, never NaN contacts.
    add('singular_sdf',[1,1,[.2,.2,.2],[0,0,0],1],[1e10],kind='numeric_rejection')
    # A box face/edge/corner has a finite zero gradient in C. It must remain
    # admitted so midsurface normalization can select its documented fallback.
    for point in ([.2,0,0],[.2,.3,0],[.2,.3,.4],[-.2,-.3,-.4]):
        size=np.array([.2,.3,.4]);x=np.array(point);value=np.empty(4)
        lib.ref_query(6,p(size),p(x),1,0,None,None,None,p(value))
        add('box_surface_gradient',[1,5,size,x,1],value)
    for split in (False,True):
        boxes=[[0,0,0,1,1,1]];children=[[-1]*8];coeff=[rng.uniform(-1,1,8)]
        if split:
            children[0]=list(range(1,9))
            for j in range(8):
                c=np.array([.5 if j>>k&1 else -.5 for k in range(3)])
                boxes.append([*c,.5,.5,.5]);children.append([-1]*8);coeff.append(rng.uniform(-1,1,8))
        boxes=np.asarray(boxes);children=np.asarray(children,dtype=np.int32);coeff=np.asarray(coeff)
        for j in range(160):
            x=rng.uniform(-1.8,1.8,3);value=np.empty(4)
            lib.ref_query(8,p([0,0,0]),p(x),1,len(boxes),p(boxes),ip(children),p(coeff),p(value))
            payload=[v for triple in zip(boxes,children,coeff) for v in triple]
            add('sdf_octree',[2,len(boxes),x,1,payload],value,tol=2e-7)
    # Parent child cycle is rejected before search; C would abort or loop.
    add('invalid_octree',[2,1,[.1,.1,.1],1,[0,0,0,1,1,1],[0,-1,-1,-1,-1,-1,-1,-1],[0]*8],[],kind='invalid')
    for k in (1,2,5):
        for j in range(220):
            size=rng.uniform(.03,.4,3);pos=rng.uniform(-.4,.4,3);rot=rotation(rng)
            corners=rng.uniform(-.4,.4,(3,3));skin=float(rng.uniform(.001,.1));margin=.01
            contacts=np.empty((50,10));n=lib.ref_triangle(KINDS[k],p(size),p(pos),p(rot),p(corners),skin,margin,p(contacts))
            add('flex_triangle',[3,k,size,pose(pos,rot),skin,margin,corners],contacts[:n],kind='contacts')
    for j in range(120):
        n=int(rng.integers(0,24));n2=int(rng.integers(0,24));self=j%3==0;oriented=j%2==0;refit=j%5==0
        A=np.column_stack((rng.uniform(-1,1,(n,3)),rng.uniform(.01,.5,(n,3))))
        B=np.column_stack((rng.uniform(-1,1,(n2,3)),rng.uniform(.01,.5,(n2,3))))
        newA=A.copy();newB=B.copy();newA[:,:3]+=rng.uniform(-.2,.2,(n,3));newB[:,:3]+=rng.uniform(-.2,.2,(n2,3))
        posA=rng.uniform(-.2,.2,3) if oriented else ZERO;rotA=rotation(rng) if oriented else IDENT
        posB=rng.uniform(-.2,.2,3) if oriented else ZERO;rotB=rotation(rng) if oriented else IDENT
        X=newA if refit else A;Y=(newB if refit else B) if not self else X
        expected=[]
        for i,b1 in enumerate(X):
            for k,b2 in enumerate(Y):
                if self and i>=k:continue
                if oriented:hit=lib.ref_obb(p(b1),p(b2),p(posA),p(rotA),p(posA if self else posB),p(rotA if self else rotB),.01)
                else:hit=lib.ref_aabb(p(b1),p(b2),.01)
                if hit:expected.append((i,k))
        add('bvh_refit' if refit else 'bvh_pairs',[4,n,n2,int(self),int(oriented),int(refit),.01,pose(posA,rotA),pose(posB,rotB),A,B,*([newA,newB] if refit else [])],expected,kind='pairs')
    for mode in range(4):
        for j in range(130):
            k=int(rng.integers(0,6));k2=int(rng.integers(0,6));s1=rng.uniform(.1,.6,3);s2=rng.uniform(.1,.6,3)
            relpos=rng.uniform(-.3,.3,3);relmat=rotation(rng);x=rng.uniform(-.7,.7,3);iterations=-1 if j%2 else 6
            value=np.empty(4);lib.ref_objective(KINDS[k],p(s1),KINDS[k2],p(s2),p(relpos),p(relmat),mode,p(x),iterations,p(value))
            add('sdf_objective' if iterations<0 else 'sdf_descent',[5,k,s1,k2,s2,pose(relpos,relmat),mode,x,iterations],value,tol=2e-8)
    # Native compiled flex fixtures cover raw specialized and GJK/EPA routes.
    base={1:np.array([[-.1,0,0],[.1,0,0]]),2:np.array([[-.1,-.1,0],[.2,-.1,0],[0,.2,0]]),
          3:np.array([[-.1,-.1,-.1],[.2,-.1,-.1],[0,.2,-.1],[0,0,.2]])}
    for dim in (1,2,3):
        for k in (1,2,3,4,5):
            m,d=model_for(dim,base[dim],.03,k)
            g=0;vertices=m.flex_elem[:dim+1].copy();body=m.flex_vertbodyid[vertices].copy()
            for j in range(5):
                d.geom_xpos[g]=rng.uniform(-.2,.2,3);d.geom_xmat[g]=rotation(rng)
                expected=np.empty((50,10));n=lib.ref_geom(m._address,d._address,g,0,0,.01,p(expected))
                points=d.flexvert_xpos[vertices].copy()
                add('flex_geom_'+str(dim),[7,k,m.geom_size[g],pose(d.geom_xpos[g],d.geom_xmat[g].ravel()),m.geom_bodyid[g],dim,.03,.01,
                    [v for t in zip(points,body) for v in t]],expected[:n],kind='contacts',tol=2e-5)
    # Compiled spherical SDF plugin exercises the full native SDF generator.
    m,d=model_for(2,base[2],.03,1,sdf=True)
    mesh_bounds=m.geom_aabb[0].copy()
    for j in range(15):
        # Build a second analytic sphere and preserve actual SDF mesh bounding box.
        xml='<mujoco><extension><plugin plugin="sparkling.test.sphere"><instance name="s"/></plugin></extension>'\
          '<asset><mesh name="s"><plugin instance="s"/></mesh></asset><option sdf_initpoints="8" sdf_iterations="10"/>'\
          '<worldbody><geom name="sdf" type="sdf" mesh="s"><plugin instance="s"/></geom>'\
          '<body><freejoint/><geom size=".15" mass="1"/></body></worldbody></mujoco>'
        sm=mujoco.MjModel.from_xml_string(xml);sd=mujoco.MjData(sm);mujoco.mj_forward(sm,sd)
        sd.geom_xpos[1]=rng.uniform(.05,.3,3);sd.geom_xmat[1]=rotation(rng)
        expected=np.empty((50,10));n=lib.ref_generate(sm._address,sd._address,1,0,0,p(expected))
        add('sdf_generator',[6,1,sm.geom_size[1],1,[.25]*3,pose(sd.geom_xpos[1],sd.geom_xmat[1].ravel()),pose(sd.geom_xpos[0],sd.geom_xmat[0].ravel()),
            sm.geom_aabb[1],sm.geom_aabb[0],8,10],expected[:n],kind='contacts',tol=2e-8)
    for tree in (0,1):
        m,d=model_for(2,base[2],.03,sdf=True)
        expected=np.empty((50,10));ids=np.empty(50,dtype=np.int32);n=lib.ref_flex_sdf(m._address,d._address,0,0,p(expected),ip(ids),tree)
        add('flex_sdf',[13,1,tree,pose(),pose(d.geom_xpos[0],d.geom_xmat[0].ravel()),1,[.25]*3,8,10,d.flexvert_xpos[m.flex_elem[:3]]],expected[:n],kind='contacts',tol=2e-8)
    # Mesh/SDF uses compiled float vertices, local mesh pose and native face BVH.
    xml='<mujoco><extension><plugin plugin="sparkling.test.sphere"><instance name="s"/></plugin></extension>' \
        '<asset><mesh name="s"><plugin instance="s"/></mesh>' \
        f'<mesh name="t" vertex="{line(base[3])}" face="0 1 2 0 3 1 0 2 3 1 3 2"/></asset>' \
        '<option sdf_initpoints="8" sdf_iterations="10"/><worldbody>' \
        '<geom type="mesh" mesh="t"/><geom type="sdf" mesh="s"><plugin instance="s"/></geom></worldbody></mujoco>'
    m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);mujoco.mj_forward(m,d)
    mid=int(m.geom_dataid[0]); va=int(m.mesh_vertadr[mid]);fa=int(m.mesh_faceadr[mid])
    corners=m.mesh_vert[va:va+m.mesh_vertnum[mid]][m.mesh_face[fa:fa+m.mesh_facenum[mid]]].astype(float)
    for j in range(12):
        d.geom_xpos[0]=rng.uniform(-.1,.1,3);d.geom_xmat[0]=rotation(rng)
        expected=np.empty((50,10));n=lib.ref_mesh_sdf(m._address,d._address,0,1,p(expected))
        add('mesh_sdf',[13,len(corners),2,pose(d.geom_xpos[0],d.geom_xmat[0]),pose(d.geom_xpos[1],d.geom_xmat[1]),
             1,[.25]*3,8,10,corners],expected[:n],kind='contact_set',tol=2e-7)
    # Plane contacts can exceed the per-pair 50-contact manifold.
    vertices=rng.uniform(-.2,.2,(130,3));normal=IDENT
    expected=[]
    for i,v in enumerate(vertices):
        if v[2]<=.04:expected.append([v[2]-.03,*(v+np.array([0,0,-.5*(v[2]-.03)-.03])),0,0,1,0,0,0,-1,-1,-1,i])
    add('flex_plane',[10,pose(),.03,.01,len(vertices),len(vertices),vertices],expected,kind='contacts',metadata=True)
    add('capacity_atomic',[10,pose(),.03,.01,len(vertices),1,vertices],[],kind='capacity')
    # Whole self-collision + topology policies, tested as sets before FPS is needed.
    for dim in (1,2,3):
        for mode in ('narrow','bvh','sap','auto'):
            points=np.vstack([base[dim]+[0,0,.02*i] for i in range(3)])
            m,d=model_for(dim,points,.03,selfmode=mode)
            # mj_collision native runs the C driver with identical groups/layers.
            mujoco.mj_collision(m,d);expected=[]
            for c in d.contact:
                if c.flex[0]==0 and c.flex[1]==0:
                    expected.append([c.dist,*c.pos,*c.frame[:3],0,0,0,*c.elem,*c.vert])
            indices=m.flex_elem.reshape((-1,dim+1));points=d.flexvert_xpos[indices.ravel()].copy();bodies=m.flex_vertbodyid[indices.ravel()].copy()
            code={'narrow':1,'bvh':2,'sap':3,'auto':4}[mode]
            add('flex_self_'+mode,[11,dim,.03,3,1,code,0,1000,[v for t in zip(points,bodies) for v in t],m.flex_elemlayer],expected,kind='contact_set',metadata=True,tol=2e-5)

    # Internal tetrahedral contacts, not just external/self contacts.
    for z in (.015,.03,.06):
        points=base[3].copy();points[3,2]=points[0,2]+z
        m,d=model_for(3,points,.03,internal=True)
        mujoco.mj_collision(m,d);expected=[]
        for c in d.contact:
            if c.flex[0]==0 and c.flex[1]==0:
                vv=[int(np.where(m.flex_elem[:4]==v)[0][0]) if v>=0 else -1 for v in c.vert]
                expected.append([c.dist,*c.pos,*c.frame[:3],0,0,0,*c.elem,*vv])
        order=m.flex_elem.reshape((-1,4)).ravel();points=d.flexvert_xpos[order];bodies=m.flex_vertbodyid[order]
        add('flex_internal',[11,3,.03,1,1,0,1,1000,[v for t in zip(points,bodies) for v in t],m.flex_elemlayer],expected,kind='contacts',metadata=True)
    # Predefined element/vertex route, each dimensionality and arbitrary body IDs.
    for dim in (1,2,3):
        for j in range(8):
            points=np.vstack((base[dim],rng.uniform(-.15,.15,3)))
            m,d=model_for(dim,points,.03)
            expected=np.empty((50,10));n=lib.ref_ev(m._address,d._address,0,0,dim+1,p(expected))
            order=np.r_[m.flex_elem[:dim+1],dim+1]
            add('flex_element_vertex',[9,dim,.03,d.flexvert_xpos[order]],expected[:n],kind='contacts',tol=2e-5)
    # Heightfield/flex uses unskinned sub-grid bounds and the flex support callback.
    for dim in (1,2,3):
        for j in range(4):
            points=base[dim].copy()+[0,0,.17+.03*j]
            m,d=model_for(dim,points,.03)
            # Recompile fixture with terrain as geom zero.
            names=[f'v{i}' for i in range(len(points))]
            bodies=''.join(f'<body name="{name}" pos="{line(pt)}"><freejoint/><geom size=".001" mass="1" contype="0" conaffinity="0"/></body>' for name,pt in zip(names,points))
            xml=f'<mujoco><asset><hfield name="h" nrow="3" ncol="3" size="1 1 .5 .1" elevation="0 .1 .2 .3 .4 .5 .6 .7 .8"/></asset><worldbody><geom name="h" type="hfield" hfield="h"/>{bodies}</worldbody><deformable><flex dim="{dim}" radius=".03" body="{" ".join(names)}" vertex="{line(np.zeros_like(points))}" element="{line(list(range(len(points))))}"><contact selfcollide="none"/></flex></deformable></mujoco>'
            m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);mujoco.mj_forward(m,d)
            expected=np.empty((50,10));n=lib.ref_geom(m._address,d._address,0,0,0,.01,p(expected))
            order=m.flex_elem[:dim+1]
            add('flex_heightfield',[14,dim,.03,.01,pose(d.geom_xpos[0],d.geom_xmat[0]),3,3,m.hfield_size[0],m.hfield_data,d.flexvert_xpos[order]],expected[:n],kind='contacts',tol=2e-5)
    # Cross-flex dimensions 1/2/3, positive margins and unequal radii.
    for dim1 in (1,2,3):
        for dim2 in (1,2,3):
            pts1=base[dim1];pts2=base[dim2]+[.03,.015,.06]
            allpoints=np.vstack([pts1,pts2]);names=[f'v{i}' for i in range(len(allpoints))]
            bodies=''.join(f'<body name="{name}" pos="{line(pt)}"><freejoint/><geom size=".001" mass="1" contype="0" conaffinity="0"/></body>' for name,pt in zip(names,allpoints))
            flex=[]
            for fid,(dim,start,pts,radius) in enumerate(((dim1,0,pts1,.03),(dim2,len(pts1),pts2,.04))):
                ns=names[start:start+len(pts)]
                flex.append(f'<flex name="f{fid}" dim="{dim}" radius="{radius}" body="{" ".join(ns)}" vertex="{line(np.zeros_like(pts))}" element="{line(list(range(len(pts))))}"><contact selfcollide="none"/></flex>')
            m=mujoco.MjModel.from_xml_string(f'<mujoco><worldbody>{bodies}</worldbody><deformable>{"".join(flex)}</deformable></mujoco>');d=mujoco.MjData(m);mujoco.mj_forward(m,d)
            expected=np.empty((50,10));n=lib.ref_elems(m._address,d._address,0,0,1,0,.01,p(expected))
            payload=[]
            for fid,(dim,radius) in enumerate(((dim1,.03),(dim2,.04))):
                indices=m.flex_elem[m.flex_elemdataadr[fid]:m.flex_elemdataadr[fid]+dim+1]+m.flex_vertadr[fid]
                payload += [dim,radius,fid,[v for t in zip(d.flexvert_xpos[indices],m.flex_vertbodyid[indices]) for v in t]]
            add('flex_cross_dimensions',[8,.01,dim1,dim2,payload],expected[:n],kind='contacts',tol=2e-5)

    # Batched plane/flex: exercises >50 farthest-point filtering and provenance.
    triangles=rng.uniform(-.3,.3,(60,3,3));triangles[:,:,2]-=.3
    m,d=model_for(2,triangles.reshape((-1,3)),.03,kind=0,size=(1,1,.1),selfmode='none')
    mujoco.mj_collision(m,d);expected=[]
    for c in d.contact:
        if c.geom[0]==0 and c.flex[1]==0:expected.append([c.dist,*c.pos,*c.frame[:3],0,0,0,*c.elem,*c.vert])
    idx=m.flex_elem[:180];points=d.flexvert_xpos[idx];bodies=m.flex_vertbodyid[idx]
    add('flex_driver_plane_fps',[12,2,.03,60,1,0,0,1000,[v for t in zip(points,bodies) for v in t],m.flex_elemlayer,
       0,m.geom_size[0],pose(d.geom_xpos[0],d.geom_xmat[0]),0],expected,kind='contact_set',metadata=True,tol=2e-8)
    # Extreme-scale/degenerate leaves: BVH pruning must preserve the exhaustive
    # C leaf-pair result, including after refitting moving boxes.
    edge_rng=np.random.default_rng(2026100201)
    for j in range(96):
        scale=(1e-12,1e-5,1.,1e7)[j%4];offset=(-1e9,0.,1e9)[j%3]
        n=8+j%9;self=j%2==0;refit=j%3==0;oriented=j%4>=2
        A=np.column_stack((offset+edge_rng.uniform(-1,1,(n,3))*scale,
                           edge_rng.uniform(0,.5,(n,3))*scale))
        B=np.column_stack((offset+edge_rng.uniform(-1,1,(n,3))*scale,
                           edge_rng.uniform(0,.5,(n,3))*scale))
        A[0,3:]=0;B[0]=A[0];A[1]=A[0];B[1]=A[1]
        newA=A.copy();newB=B.copy()
        newA[:,:3]+=edge_rng.uniform(-.2,.2,(n,3))*scale
        newB[:,:3]+=edge_rng.uniform(-.2,.2,(n,3))*scale
        X=newA if refit else A;Y=X if self else (newB if refit else B)
        margin=0. if j%2 else scale*.01
        expected=[]
        for i,b1 in enumerate(X):
            for k,b2 in enumerate(Y):
                if self and i>=k:continue
                if oriented:hit=lib.ref_obb(p(b1),p(b2),p(ZERO),p(IDENT),p(ZERO),p(IDENT),margin)
                else:hit=lib.ref_aabb(p(b1),p(b2),margin)
                if hit:expected.append((i,k))
        add('bvh_boundary_refit' if refit else 'bvh_boundary_pairs',
            [4,n,n,int(self),int(oriented),int(refit),margin,pose(),pose(),A,B,
             *([newA,newB] if refit else [])],expected,kind='pairs')
    # Gather results in one process; input construction and I/O are untimed.
    payload='\n'.join(c[1] for c in cases)+'\n';(out/'inputs.txt').write_text(payload)
    proc=subprocess.run([a.binary],input=payload,text=True,capture_output=True)
    (out/'stdout.txt').write_text(proc.stdout);(out/'stderr.txt').write_text(proc.stderr)
    if proc.returncode:raise RuntimeError(f'probe exit {proc.returncode}: {proc.stderr}; lines {len(proc.stdout.splitlines())}/{len(cases)}')
    rows=proc.stdout.splitlines();assert len(rows)==len(cases)
    counts=collections.Counter();failures=[];maxerror=collections.defaultdict(float)
    for idx,(case,row) in enumerate(zip(cases,rows)):
        group,inputs,expected,kind,tol,metadata=case;values=np.fromstring(row,sep=' ');status=int(values[0]);n=int(values[1]);actual=values[2:]
        try:
            if kind=='invalid':assert status==1 and n==0
            elif kind=='capacity':assert status==2 and n==0
            elif kind=='numeric_rejection':assert status==3 and n==0
            elif kind=='pairs':
                assert status==0;actual=actual.reshape((n,2)).astype(int)
                if inputs.split()[3]=='1':actual=np.sort(actual,axis=1)
                assert sorted(map(tuple,actual))==sorted(map(tuple,expected.reshape((-1,2))))
            elif kind in ('contacts','contact_set'):
                assert status==0,(status,n,len(expected));cols=14 if metadata else 10
                actual=actual.reshape((n,cols));expected=expected.reshape((-1,cols));assert len(actual)==len(expected),(n,len(expected))
                if kind=='contact_set' and len(actual):
                    # Match an unordered multiset one-to-one; preserve pair orientation.
                    unmatched=list(range(len(expected)))
                    for aa in actual:
                        errors=np.max(np.abs(expected[unmatched]-aa),axis=1)
                        pick=int(np.argmin(errors));err=float(errors[pick]);assert err<=tol,err
                        matched=unmatched.pop(pick)
                        if metadata:assert np.array_equal(aa[10:],expected[matched,10:])
                        maxerror[group]=max(maxerror[group],err)
                elif len(actual):
                    if metadata:assert np.array_equal(actual[:,10:],expected[:,10:])
                    err=float(np.max(np.abs(actual-expected)));assert np.allclose(actual[:,:10],expected[:,:10],rtol=tol,atol=tol),err;maxerror[group]=max(maxerror[group],err)
            else:
                if status==3 and expected[0]==1e10:pass
                else:
                    assert status==0,status;assert np.all(np.isfinite(actual))
                    err=float(np.max(np.abs(actual-expected)));assert np.allclose(actual,expected,rtol=tol,atol=tol),err;maxerror[group]=max(maxerror[group],err)
            counts[group]+=1
        except (AssertionError,ValueError) as e:
            failures.append({'index':idx,'group':group,'reason':str(e),'status':status,'actual':values.tolist(),'expected':expected.tolist(),'input':inputs})
    report={'reference':mujoco.__version__,'seed':20261002,'cases':len(cases),'passed':sum(counts.values()),'groups':dict(counts),'max_absolute_error':dict(maxerror),'failures':failures}
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k!='failures'},indent=2));print('failures',len(failures))
    for f in failures[:12]:print(f['index'],f['group'],f['reason'])
    if failures:raise SystemExit(1)
if __name__=='__main__':main()
