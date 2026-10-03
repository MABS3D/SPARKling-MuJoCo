"""Alternating native C / Ada ray queries, cached poses, preparation and I/O excluded."""
import argparse,ctypes,hashlib,json,os,pathlib,platform,subprocess
import mujoco,numpy as np
from differential import vec,digest
HERE=pathlib.Path(__file__).resolve().parents[1];ROOT=HERE.parents[1]
def main():
    p=argparse.ArgumentParser();p.add_argument('--binary',type=pathlib.Path,required=True);p.add_argument('--out',type=pathlib.Path,required=True)
    p.add_argument('--rounds',type=int,default=11);p.add_argument('--repeats',type=int,default=3000);a=p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    cpu=min(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu})
    library=pathlib.Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'
    command=['gcc','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',
             '-I'+str(pathlib.Path(mujoco.__file__).parent/'include'),str(HERE/'tests/reference.c'),str(library),
             '-Wl,-rpath,'+str(library.parent),'-o',str(a.out/'reference.so')]
    subprocess.run(command,check=True);lib=ctypes.CDLL(str(a.out/'reference.so'))
    lib.ray_benchmark.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_void_p]
    lib.ray_benchmark.restype=ctypes.c_double
    rng=np.random.default_rng(241003);records=[]
    for count in [8,64,256]:
        geoms=''.join(f'<geom type="{["sphere","box","capsule","ellipsoid"][i%4]}" pos="{i%16*.7} {i//16*.7} .5" size=".2 .25 .3"/>' for i in range(count))
        xml='<mujoco><option><flag constraint="disable"/></option><worldbody>'+geoms+'</worldbody></mujoco>'
        m=mujoco.MjModel.from_xml_string(xml);d=mujoco.MjData(m);mujoco.mj_forward(m,d)
        model=a.out/f'model-{count}.mjb';mujoco.mj_saveModel(m,str(model))
        q=[]
        for i in range(64):
            target=d.geom_xpos[i%count];point=target+rng.uniform(-2,2,3);direction=target-point if i%2==0 else rng.normal(size=3)
            q.append([*point,*direction,1,-1,0,*([1]*6)])
        q=np.ascontiguousarray(q,dtype=np.float64);data=f'{len(q)} {a.repeats}\n'+'\n'.join(vec(v) for v in q)+'\n'
        (a.out/f'model-{count}.input').write_text(data)
        samples=[]
        def ada():
            r=subprocess.run([str(a.binary),str(model)],input=data,text=True,capture_output=True,check=True)
            values=r.stdout.split();return float(values[0]),float(values[1])
        def native():
            checksum=ctypes.c_double();t=lib.ray_benchmark(m._address,d._address,q.ctypes.data,len(q),a.repeats,ctypes.byref(checksum))
            return t,checksum.value
        for r in range(a.rounds+1):
            if r%2:ct,cc=native();at,ac=ada()
            else:at,ac=ada();ct,cc=native()
            if not np.isclose(ac,cc,rtol=2e-10,atol=2e-10):raise RuntimeError((ac,cc))
            if r:samples.append(dict(ada_seconds=at,c_seconds=ct,ratio=at/ct,ada_checksum=ac,c_checksum=cc))
        ratios=np.array([s['ratio'] for s in samples]);bootstrap=np.median(rng.choice(ratios,(10000,len(ratios))),axis=1)
        record=dict(geometries=count,queries=len(q),repeats=a.repeats,samples=samples,
                    ada_ns=float(np.median([s['ada_seconds'] for s in samples])*1e9/(len(q)*a.repeats)),
                    c_ns=float(np.median([s['c_seconds'] for s in samples])*1e9/(len(q)*a.repeats)),
                    paired_ratio=float(np.median(ratios)),interval95=np.quantile(bootstrap,[.025,.975]).tolist())
        records.append(record);print(count,record['paired_ratio'],record['interval95'],flush=True)
    result=dict(scope='cached-pose full scene ray queries; excludes kinematics/pose refresh, model loading, I/O and movement',
                reference=mujoco.__version__,reference_library_sha256=digest(library),binary_sha256=digest(a.binary),
                cpu=cpu,platform=platform.platform(),rounds=a.rounds,command=command,records=records)
    (a.out/'performance.json').write_text(json.dumps(result,indent=2)+'\n')
if __name__=='__main__':main()
