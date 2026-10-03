"""Bitwise C3.14 manifold corpus, including normalization branch boundaries."""
import argparse, hashlib, json, math, subprocess
from pathlib import Path
import mujoco
import numpy as np


def cases():
    rng = np.random.default_rng(290310)
    quats = [[0.]*4, [1., -0., 0., -0.], [-1., 0., -0., 0.]]
    for scale in (1e-60, 1e-16, .4999999999999999e-15, .5e-15, .8e-15, 1e-15,
                  1e-10, 1., 1e10, 1e60):
        quats += [[scale]*4, [scale, -scale/3, scale/7, -scale/11]]
    for n in range(-80, 81):
        quats.append([1.+n*np.finfo(float).eps, 0., -0., 0.])
    quats += [rng.uniform(-1, 1, 4)*10.**rng.uniform(-60,60) for _ in range(200)]
    for q in quats: yield 'normalize', 0, list(q), [0.]*3, 0.
    vectors = [[0., -0., 0.], [1e-16, -2e-16, 3e-16], [1e-15, 0., 0.],
               [1., 2., 3.], [-1., -2., -3.], [1e10, -1e10, 1e10]]
    vectors += [rng.uniform(-1,1,3)*10.**rng.uniform(-20,10) for _ in range(200)]
    for v in vectors:
        for h in (0., .002, 1., 1e10):
            yield 'increment', 1, [1.,0.,0.,0.], list(v), h
            q = rng.normal(size=4); q /= np.linalg.norm(q)
            q *= 1. + rng.integers(-40, 41)*np.finfo(float).eps
            yield 'integrate', 2, list(q), list(v), h
    # Probe both sides of the first cosine rounding transition and GNAT's
    # small-argument shortcut. Inputs still exercise the real rotation path.
    for center in (math.sqrt(2.**-53), 2.**-26):
        for toward in (0., math.inf):
            x=center
            for _ in range(4096):
                yield 'increment', 1, [1.,0.,0.,0.], [1.,0.,0.], 2*x
                x=math.nextafter(x,toward)


def reference(mode, q, v, h):
    q = np.array(q, dtype=float); v = np.array(v, dtype=float)
    if mode == 0: mujoco.mju_normalize4(q)
    elif mode == 1:
        angle = h*mujoco.mju_normalize3(v)
        mujoco.mju_axisAngle2Quat(q, v, angle)
    else: mujoco.mju_quatIntegrate(q, v, h)
    return q


def main():
    p=argparse.ArgumentParser();p.add_argument('--probe',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True);a=p.parse_args()
    assert mujoco.__version__ == '3.14.0'
    a.out.mkdir(parents=True,exist_ok=False)
    rows=list(cases())
    data=str(len(rows))+'\n'+'\n'.join(str(mode)+' '+' '.join(format(x,'.17g') for x in q+v+[h])
        for _,mode,q,v,h in rows)+'\n'
    (a.out/'input.txt').write_text(data)
    run=subprocess.run([str(a.probe)],input=data,text=True,capture_output=True,timeout=120)
    (a.out/'output.txt').write_text(run.stdout);(a.out/'stderr.txt').write_text(run.stderr)
    run.check_returncode();lines=run.stdout.splitlines();assert len(lines)==len(rows)
    records=[]
    for row,line in zip(rows,lines):
        name,mode,q,v,h=row;want=reference(mode,q,v,h);got=np.array([float(x) for x in line.split()])
        exact=bool(np.array_equal(got.view(np.uint64),want.view(np.uint64)))
        records.append(dict(operation=name,passed=exact,q=q,v=v,h=h,want=want.tolist(),got=got.tolist(),
                            max_error=float(np.max(np.abs(got-want)))))
    summary={name:dict(passed=sum(r['passed'] for r in records if r['operation']==name),
                      cases=sum(r['operation']==name for r in records)) for name in ('normalize','increment','integrate')}
    result=dict(mujoco=mujoco.__version__,binary_sha256=hashlib.sha256(a.probe.read_bytes()).hexdigest(),
                library_sha256=hashlib.sha256(next(Path(mujoco.__file__).parent.glob('libmujoco.so*')).read_bytes()).hexdigest(),
                driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                input_sha256=hashlib.sha256(data.encode()).hexdigest(),summary=summary,records=records)
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print(summary)
    return 0 if all(r['passed'] for r in records) else 1


if __name__=='__main__':raise SystemExit(main())
