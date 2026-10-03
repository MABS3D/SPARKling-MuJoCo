"""One isolated native model: owned geometry and contact-side production."""
import argparse
import hashlib
import json
from pathlib import Path
import resource
import subprocess
import mujoco
import numpy as np
from reference_contact_side import load


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--reference',type=Path,required=True)
    p.add_argument('--model',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a = p.parse_args(); a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(128*1024**2,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    model = a.out / a.model.name; model.write_bytes(a.model.read_bytes())
    xml = a.model.with_suffix('.xml')
    if xml.exists(): (a.out / xml.name).write_bytes(xml.read_bytes())
    (a.out / 'model.json').write_text(json.dumps(dict(original=str(a.model),sha256=digest(model)))+'\n')
    m = mujoco.MjModel.from_binary_path(str(model)); d = mujoco.MjData(m)
    mujoco.mj_forward(m,d)
    np.savez(a.out / 'state.npz',qpos=d.qpos,qvel=d.qvel,xpos=d.xpos,xmat=d.xmat,
             vertices=d.flexvert_xpos)
    lib = load(a.reference); cases = []
    def add(label,f,e,v,opp,point,status='SUCCESS'):
        for neg in (0,1):
            cases.append(dict(label=label+'-'+str(neg),f=int(f),e=int(e),v=int(v),opp=int(opp),
                negative=neg,point=list(map(float,point)),status=status))
    for f in range(m.nflex):
        start,nv,dim = int(m.flex_vertadr[f]),int(m.flex_vertnum[f]),int(m.flex_dim[f])
        elems = m.flex_elem[int(m.flex_elemdataadr[f]):int(m.flex_elemdataadr[f])+int(m.flex_elemnum[f])*(dim+1)]
        elems = elems.reshape(-1,dim+1)
        for v in sorted(set([0,nv//2,nv-1])):
            add('vertex',f,-1,v,-1,d.flexvert_xpos[start+v])
        for e in np.linspace(0,len(elems)-1,min(16,len(elems)),dtype=int):
            ids = elems[e]; points = d.flexvert_xpos[start+ids]
            for point in (points.mean(axis=0),points[0],points.mean(axis=0)+[.011,-.013,.017]):
                for opposite in [-1,*map(int,ids)]:
                    add('element',f,e,-1,opposite,point)
        add('invalid-vertex',f,-1,nv,-1,[0,0,0],'INVALID_INPUT')
        add('invalid-element',f,len(elems),-1,-1,[0,0,0],'INVALID_INPUT')
        add('invalid-vertex-sentinel',f,0,-2,-1,[0,0,0],'INVALID_INPUT')
        add('invalid-point',f,0,-1,-1,[1e101,0,0],'INVALID_INPUT')
    for c in d.contact[:d.ncon]:
        for side in range(2):
            f = int(c.flex[side])
            if f >= 0:
                opposite = int(c.vert[1-side]) if int(c.flex[1-side]) == f else -1
                add('native-contact',f,int(c.elem[side]),int(c.vert[side]),opposite,c.pos)
    add('invalid-flex',m.nflex,0,-1,-1,[0,0,0],'INVALID_INPUT')
    payload = '\n'.join(' '.join(map(str,[*map(float,p),*map(float,r)])) for p,r in zip(d.xpos,d.xmat))+'\n'
    payload += str(len(cases))+'\n'+'\n'.join(' '.join(map(str,[c['f'],c['e'],c['v'],c['opp'],c['negative'],*c['point']])) for c in cases)+'\n'
    (a.out / 'cases.input').write_text(payload)
    (a.out / 'requests.json').write_text(json.dumps(cases,indent=2)+'\n')
    expected = []
    for c in cases:
        body = np.zeros(729,dtype=np.int32); weight = np.zeros(729); nb = 0
        if c['status'] == 'SUCCESS':
            nb = lib.side(m._address,d._address,c['f'],c['e'],c['v'],c['opp'],c['negative'],
                np.ascontiguousarray(c['point']),body,weight)
        if nb < 0 or nb > 729: raise RuntimeError('reference count')
        expected.append(dict(status=c['status'],bodies=body[:nb].tolist(),bits=weight[:nb].view(np.uint64).tolist()))
    (a.out / 'expected.json').write_text(json.dumps(expected)+'\n')
    r = subprocess.run([str(a.binary),str(model)],input=payload,text=True,capture_output=True,timeout=240)
    (a.out / 'cases.output').write_text(r.stdout+r.stderr)
    actual, vertices = [], []
    for line in r.stdout.splitlines():
        parts = line.split()
        if not parts: continue
        if parts[0] == 'vertex': vertices.append(list(map(int,parts[3:])))
        elif parts[0] == 'case': actual.append(dict(status=parts[1]))
        elif actual and parts[0] in ('bodies','bits'): actual[-1][parts[0]] = list(map(int,parts[1:]))
    checks = [dict(index=i,label=c['label'],passed=want == got) for i,(c,want,got) in enumerate(zip(cases,expected,actual))]
    failures = [dict(**x,expected=expected[x['index']],actual=actual[x['index']]) for x in checks if not x['passed']]
    v = np.array(vertices,dtype=np.uint64).view(np.float64)
    vertex_exact = v.shape == d.flexvert_xpos.shape and np.array_equal(v.view(np.uint64),d.flexvert_xpos.view(np.uint64))
    result = dict(cases=len(cases),actual=len(actual),exact=sum(x['passed'] for x in checks),exit=r.returncode,
        passed=r.returncode == 0 and len(actual) == len(cases) and not failures,
        failures=failures[:24],checks=checks,vertex_bits_exact=bool(vertex_exact),
        vertex_max_error=float(np.max(np.abs(v-d.flexvert_xpos))) if v.shape == d.flexvert_xpos.shape else None,
        nv=int(m.nv),interp=m.flex_interp.tolist(),contacts=int(d.ncon),max_bodies=max(len(x['bodies']) for x in expected),
        model_sha256=digest(model),binary_sha256=digest(a.binary),reference_manifest_sha256=digest(a.reference / 'manifest.json'),
        files={p.name:digest(p) for p in a.out.iterdir() if p.is_file()},
        scope='Owned contact-side producer versus stable element/vertex weights; C body poses, no integrated dynamics.')
    (a.out / 'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(a.model.stem,result['exact'],result['cases'],r.returncode,result['vertex_max_error'],flush=True)
    raise SystemExit(not result['passed'])


if __name__ == '__main__': main()
