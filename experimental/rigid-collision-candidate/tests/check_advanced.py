"""Compiled convex assets and terrain against native MuJoCo precontacts."""
import argparse,itertools,json,subprocess,select,sys
from pathlib import Path
import mujoco,numpy as np
from common import build
from check import rotation
from check_contacts import library,serialize_objects,match

CUBE=np.array(list(itertools.product([-1.,1.],repeat=3)))
def model(a,b,cloud,other_cloud=None):
    vertex=' '.join(format(x,'.9g') for x in cloud.reshape(-1))
    assets=f'<mesh name="hull" vertex="{vertex}"/><hfield name="terrain" nrow="9" ncol="11" size="2 2 0.7 0.5"/>'
    if other_cloud is not None:
        second=' '.join(format(x,'.9g') for x in other_cloud.reshape(-1))
        assets+=f'<mesh name="other" vertex="{second}"/>'
    def geom(k,i):
        name='other' if other_cloud is not None and i==1 else 'hull'
        return f'<geom type="mesh" mesh="{name}"/>' if k=='mesh' else '<geom type="hfield" hfield="terrain"/>' if k=='hfield' else f'<geom type="{k}" size="0.4 0.6 0.5"/>'
    m=mujoco.MjModel.from_xml_string('<mujoco><option ccd_iterations="100"/><asset>'+assets+'</asset><worldbody>'+''.join('<body>'+('' if k in ['plane','hfield'] else '<freejoint/>')+geom(k,i)+'</body>' for i,k in enumerate([a,b]))+'</worldbody></mujoco>')
    d=mujoco.MjData(m);mujoco.mj_forward(m,d);return m,d

def mesh_asset(m,g):
    mesh=int(m.geom_dataid[g]);va=int(m.mesh_vertadr[mesh]);nv=int(m.mesh_vertnum[mesh]);fa=int(m.mesh_polyadr[mesh]);nf=int(m.mesh_polynum[mesh]);facets=[]
    for f in range(fa,fa+nf):
        adr=int(m.mesh_polyvertadr[f]);num=int(m.mesh_polyvertnum[f]);facets.append((m.mesh_polynormal[f].tolist(),m.mesh_polyvert[adr:adr+num].tolist()))
    return m.mesh_vert[va:va+nv].astype(float),facets

def mesh_graph(m,g):
    mesh=int(m.geom_dataid[g]);start=int(m.mesh_graphadr[mesh]);end=int(m.mesh_graphadr[mesh+1]) if mesh+1<len(m.mesh_graphadr) else len(m.mesh_graph)
    return ([],[]) if start<0 else (m.mesh_graph[start:end].tolist(),m.mesh_extrema[mesh].tolist())

def run(out,samples,terrain=True,indexed=False):
    lib=library(out);rng=np.random.default_rng(3141101);texts=[];expected=[];desc=[]
    families=[('cube',CUBE),('polytope',rng.normal(size=(28,3))),('wide-face',np.array([[np.cos(t),np.sin(t),z] for z in [-.7,.7] for t in np.linspace(0,2*np.pi,24,endpoint=False)]))]
    pairs=[('plane','mesh'),('sphere','mesh'),('capsule','mesh'),('ellipsoid','mesh'),('cylinder','mesh'),('box','mesh'),('mesh','mesh')]
    for family,cloud in families:
        for a,b in pairs:
            m,d=model(a,b,cloud)
            verts=[[],[]];facets=[[],[]];graphs=[[],[]];seeds=[[],[]]
            for g,k in enumerate([a,b]):
                if k=='mesh':verts[g],facets[g]=mesh_asset(m,g);graphs[g],seeds[g]=mesh_graph(m,g)
            for i in range(samples):
                positions=rng.uniform(-1.8,1.8,(2,3));mats=np.stack([rotation(rng),rotation(rng)]);margin=float(rng.choice([0,0,.005,.1]))
                if i%7==0:mats[:]=np.eye(3).reshape(9);positions[:]=0;positions[1,2]=.03
                d.geom_xpos[:]=positions;d.geom_xmat[:]=mats
                result=np.zeros(500);n=lib.rigid_contacts(m._address,d._address,0,1,margin,result)
                texts.append(serialize_objects([a,b],m.geom_size,positions,mats,vertices=verts,facets=facets,graphs=graphs,seeds=seeds,margin=margin))
                expected.append(result[:10*n].reshape(-1,10).copy());desc.append(dict(family=family,pair=[a,b],sample=i))
                # Reverse the complete compiled assets and compare with C's
                # dispatch in that input order, including mesh-mesh ties.
                n=lib.rigid_contacts(m._address,d._address,1,0,margin,result)
                texts.append(serialize_objects([b,a],m.geom_size[::-1],positions[::-1],mats[::-1],vertices=verts[::-1],facets=facets[::-1],graphs=graphs[::-1],seeds=seeds[::-1],margin=margin))
                expected.append(result[:10*n].reshape(-1,10).copy());desc.append(dict(family=family,pair=[b,a],sample=i,reversed=True))
    worker=None;native_crashes=[]
    def terrain_oracle(case):
        nonlocal worker
        if worker is None or worker.poll() is not None:
            worker=subprocess.Popen([sys.executable,str(Path(__file__).with_name('terrain_oracle.py')),str(out)],stdin=subprocess.PIPE,stdout=subprocess.PIPE,stderr=subprocess.DEVNULL,text=True,bufsize=1)
        worker.stdin.write(json.dumps(case)+'\n');worker.stdin.flush()
        if not select.select([worker.stdout],[],[],10)[0]:
            worker.kill();worker.wait();native_crashes.append(dict(**case,exitcode=worker.returncode,reason='timeout'));return None
        line=worker.stdout.readline()
        if not line:
            worker.wait();native_crashes.append(dict(**case,exitcode=worker.returncode,reason='native_process_exit'));return None
        return np.asarray(json.loads(line)).reshape(-1,10)
    for b in (['sphere','capsule','ellipsoid','cylinder','box','mesh'] if terrain else []):
        m,d=model('hfield',b,CUBE);m.hfield_data[:]=rng.uniform(0,1,m.hfield_data.shape)
        verts=[[],[]];facets=[[],[]];graphs=[[],[]];seeds=[[],[]]
        if b=='mesh':verts[1],facets[1]=mesh_asset(m,1);graphs[1],seeds[1]=mesh_graph(m,1)
        for i in range(samples):
            poses=rng.uniform(-1.8,1.8,(2,3));mats=np.stack([rotation(rng),rotation(rng)]);margin=float(rng.choice([0,0,.005,.1]))
            if i%7==0:poses[:]=0;poses[1,2]=.3;mats[:]=np.eye(3).reshape(9)
            d.geom_xpos[:]=poses;d.geom_xmat[:]=mats
            want=terrain_oracle(dict(indexed=indexed,kind=b,sample=i,positions=poses.tolist(),matrices=mats.tolist(),margin=margin,heights=m.hfield_data.tolist()))
            hf=[int(m.hfield_nrow[0]),int(m.hfield_ncol[0]),*m.hfield_size[0].tolist(),*m.hfield_data.astype(float).tolist()]
            texts.append(serialize_objects(['hfield',b],m.geom_size,poses,mats,vertices=verts,facets=facets,graphs=graphs,seeds=seeds,heightfield=hf,margin=margin,mode=3))
            expected.append(want);desc.append(dict(family='terrain',pair=['hfield',b],sample=i))
    if worker is not None:
        worker.stdin.close();worker.wait(timeout=10)
    (out/('terrain-indexed-crashes.json' if indexed else 'terrain-native-crashes.json')).write_text(json.dumps(native_crashes,indent=2)+'\n')
    reports={}
    for profile in ['validation','release']:
        r=subprocess.run([str(out/'build'/profile/'bin/contact_probe')],input=''.join(texts),text=True,capture_output=True,timeout=240)
        lines=r.stdout.splitlines();failures=[]
        for i,want in enumerate(expected):
            f=lines[i].split() if i<len(lines) else ['MISSING']
            if f[0]!='SUCCESS':error=dict(reason='status',output=f)
            else:
                actual=np.array(list(map(float,f[2:]))).reshape(-1,10)
                error=(None if np.isfinite(actual).all() else dict(reason='nonfinite')) if want is None else match(actual,want)
            if error:failures.append(dict(index=i,**desc[i],**error,input=texts[i]))
        reports[profile]=dict(cases=len(expected),native_crashes=len(native_crashes),compared=sum(w is not None for w in expected),returncode=r.returncode,stderr=r.stderr,failures=failures)
        print(profile,'advanced',len(expected),'failures',len(failures),flush=True)
    (out/('advanced-indexed-numerics.json' if indexed else 'advanced-numerics.json')).write_text(json.dumps(reports,indent=2)+'\n');(out/'advanced-input.txt').write_text(''.join(texts))
    return not any(x['returncode'] or x['failures'] for x in reports.values())
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--mesh-only',action='store_true');p.add_argument('--indexed-terrain',action='store_true');p.add_argument('--out',type=Path,required=True);p.add_argument('--samples',type=int,default=100);p.add_argument('--reuse',action='store_true');a=p.parse_args();out=a.out.resolve()
    if not a.reuse:build(out)
    raise SystemExit(0 if run(out,a.samples,not a.mesh_only,a.indexed_terrain) else 1)
