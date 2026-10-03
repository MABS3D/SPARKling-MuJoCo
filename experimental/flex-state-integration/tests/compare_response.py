"""Native stable mj_jacSum operands and result versus signed Ada scalar folds."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np
from reference_response import load


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def bits(x):
    return int(np.float64(x).view(np.uint64))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--reference',type=Path,required=True)
    p.add_argument('--fixtures',type=Path,required=True)
    p.add_argument('--model',required=True)
    p.add_argument('--out',type=Path,required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    receipt = json.loads((a.fixtures / 'results.json').read_text())
    case = next(r for r in receipt['records'] if r['model'] == a.model)
    model = Path(case['model_path'])
    if not case['passed'] or digest(model) != case['model_sha256']:
        raise RuntimeError('shell fixture receipt mismatch')
    ep = json.loads((a.fixtures / (a.model+'.expected.json')).read_text())
    usable = [e for e in ep if e['status'] == 'SUCCESS' and len(e['bodies']) > 1]
    if len(usable) < 2: raise RuntimeError('missing signed shell support')
    bodies0 = usable[0]['bodies']; weights0 = np.array(usable[0]['bits'],dtype=np.uint64).view(np.float64)
    bodies1 = usable[1]['bodies']; weights1 = np.array(usable[1]['bits'],dtype=np.uint64).view(np.float64)
    patterns = [('world-then-shell',[0]+bodies0,[-1.0]+weights0.tolist()),
        ('two-shell-sides',bodies1+bodies0,weights1.tolist()+weights0.tolist()),
        ('duplicates-cancellation',[0,bodies0[0],bodies0[0],bodies0[-1],bodies0[0]],[-0.0,4.0,-3.0,0.0,-1.0])]
    (a.out / 'requests.json').write_text(json.dumps(dict(model=str(model),model_sha256=digest(model),
        patterns=patterns,previous_receipt_sha256=digest(a.fixtures / 'results.json')),indent=2)+'\n')
    lib = load(a.reference)
    lines, expected, labels, batches = [], [], [], []
    for sparse in (False,True):
        m = mujoco.MjModel.from_binary_path(str(model)); d = mujoco.MjData(m)
        m.opt.jacobian = mujoco.mjtJacobian.mjJAC_SPARSE if sparse else mujoco.mjtJacobian.mjJAC_DENSE
        mujoco.mj_forward(m,d)
        nv = m.nv
        if nv == 0 or nv > 256 or d.ncon == 0: raise RuntimeError('fixture domain')
        point = np.ascontiguousarray(d.contact[0].pos)
        frame = np.ascontiguousarray(d.contact[0].frame)
        np.savez(a.out / ('state-'+str(int(sparse))+'.npz'),qpos=d.qpos,qvel=d.qvel,point=point,frame=frame)
        for name,bid,w in patterns:
            n = len(bid); body = np.ascontiguousarray(bid,dtype=np.int32); weight = np.ascontiguousarray(w)
            parts = np.zeros((n,6,nv)); present = np.zeros((n,nv),dtype=np.int32)
            raw = np.zeros(6*nv); chain = np.zeros(nv,dtype=np.int32)
            nn = lib.response(m._address,d._address,n,body,weight,point,parts,present,raw,chain)
            if nn < 0 or nn > nv: raise RuntimeError('C support outside range')
            sums = np.vstack((raw[:3*nn].reshape(3,nn),raw[3*nv:3*nv+3*nn].reshape(3,nn)))
            projected = np.zeros((6,nn))
            lib.project(projected[:3],frame,np.ascontiguousarray(sums[:3]),nn)
            lib.project(projected[3:],frame,np.ascontiguousarray(sums[3:]),nn)
            batch = f'{int(sparse)}-{name}'
            np.savez(a.out / (batch+'.npz'),parts=parts,present=present,weights=weight,
                     chain=chain[:nn],sum=sums,projected=projected)
            support = list(map(int,chain[:nn])); mapping = {v:i for i,v in enumerate(support)}
            for v in range(nv):
                for r in range(6):
                    lines.append(' '.join(map(str,[0,n,0,*[x for k in range(n) for x in
                        (int(present[k,v]),float(parts[k,r,v]),float(weight[k]))]])))
                    has = v in mapping
                    expected.append((int(has),bits(sums[r,mapping[v]]) if has else bits(0.0)))
                    labels.append(f'{batch}-fold-{r}-{v}')
            for c in range(nn):
                for r in range(6):
                    base = 0 if r < 3 else 3
                    xyz = sums[base:base+3,c]
                    abc = frame[3*(r%3):3*(r%3)+3]
                    lines.append(' '.join(map(str,[1,*map(float,xyz),*map(float,abc)])))
                    expected.append((1,bits(projected[r,c])))
                    labels.append(f'{batch}-frame-{r}-{c}')
            batches.append(dict(name=batch,nv=nv,terms=n,support=support))
    # Explicit zero and cancellation projections use the native matrix routine.
    for xyz in ([0.0,-0.0,0.0],[-0.0,-0.0,-0.0],[1e30,-1e30,1.0],[5e-324,-5e-324,0.0]):
        for abc in ([0.0,-0.0,0.0],[-1.0,-1.0,-1.0],[0.0,1.0,0.0],[1.0,1.0,1.0]):
            inp = np.ascontiguousarray(xyz).reshape(3,1); frame = np.zeros(9); frame[:3] = abc
            out = np.zeros((3,1)); lib.project(out,frame,inp,1)
            lines.append(' '.join(map(str,[1,*xyz,*abc])))
            expected.append((1,bits(out[0,0]))); labels.append('special-frame')
    payload = str(len(lines))+'\n'+'\n'.join(lines)+'\n'
    (a.out / 'cases.input').write_text(payload)
    (a.out / 'expected.json').write_text(json.dumps(dict(expected=expected,labels=labels,batches=batches))+'\n')
    r = subprocess.run([str(a.binary)],input=payload,text=True,capture_output=True,timeout=240)
    (a.out / 'cases.output').write_text(r.stdout+r.stderr)
    actual = []
    for line in r.stdout.splitlines():
        fields = line.split()
        if len(fields) != 2: break
        try: actual.append(tuple(map(int,fields)))
        except ValueError: break
    failures = [dict(index=i,label=labels[i],expected=want,actual=got)
                for i,(want,got) in enumerate(zip(expected,actual)) if want != got]
    result = dict(cases=len(expected),actual=len(actual),exact=sum(want == got for want,got in zip(expected,actual)),
        passed=r.returncode == 0 and len(actual) == len(expected) and not failures,
        exit=r.returncode,failures=failures[:32],batches=batches,model_sha256=digest(model),
        binary_sha256=digest(a.binary),reference_manifest_sha256=digest(a.reference / 'manifest.json'),
        files={p.name:digest(p) for p in a.out.iterdir() if p.is_file()},
        scope='Native weighted Jacobian accumulation/support and frame projection; prepared shell operands, not full dynamics.')
    (a.out / 'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(a.model,result['exact'],result['cases'],r.returncode,flush=True)
    raise SystemExit(not result['passed'])


if __name__ == '__main__':
    main()
