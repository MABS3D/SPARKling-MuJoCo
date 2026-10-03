"""Source-frozen full collision phase: old Ada, BVH Ada and official C.

Kinematics, dynamics, constraints and integration are outside this measurement.
"""
import argparse
import ctypes
import hashlib
import itertools
import json
import os
from pathlib import Path
import platform
import subprocess

import mujoco
import numpy as np

from common import ROOT, environment, digest
from benchmark_scene import prepare, stream
from check_scene import parse, match
from check_bvh_scene import compound_xml


def build(before,after,out):
    out.mkdir(parents=True,exist_ok=False);env=environment()
    lib=Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'
    ccmd=['gcc','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',
          '-I'+str(ROOT/'mujoco/include'),str(after/'source/tests/scene_reference.c'),str(lib),
          '-Wl,-rpath,'+str(lib.parent),'-o',str(out/'reference.so')]
    subprocess.run(ccmd,env=env,check=True)
    commands={}
    for label,source in [('before',before/'source'),('bvh',after/'source')]:
        env.update(RIGID_MODE='release',RIGID_BUILD_ROOT=str(out/'build'/label))
        cmd=['gprbuild','-P',str(source/'rigid.gpr'),'-j2','scene_bench.adb',
             '-largs',str(out/'reference.so'),'-Wl,-rpath,'+str(out)]
        commands[label]=cmd
        with (out/(label+'-build.log')).open('w') as f:
            subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','180','--',*cmd],env=env,stdout=f,stderr=subprocess.STDOUT,check=True)
    meta=dict(reference=mujoco.__version__,reference_library_sha256=digest(lib),c_command=ccmd,
              ada_commands=commands,driver_sha256=digest(__file__),
              before_sources=json.loads((before/'sources.json').read_text()),
              after_sources=json.loads((after/'manifest.json').read_text())['sources'],
              executables={s:digest(out/'build'/s/'release/bin/scene_bench') for s in commands})
    (out/'manifest.json').write_text(json.dumps(meta,indent=2)+'\n')


def fixtures():
    for n in [16,64,128,256,512]:yield f'compound-sparse-{n}',compound_xml(n)
    for n in [16,64]:yield f'compound-dense-{n}',compound_xml(n,True)
    for n in [32,128]:
        world=''.join(f'<body pos="{i%8*2} {i//8*2} 0"><freejoint/><geom type="sphere" size=".4"/></body>' for i in range(n))
        yield f'single-geom-{n}','<mujoco><worldbody>'+world+'</worldbody></mujoco>'


def native_match(contacts,wanted):
    if len(contacts)!=len(wanted):return dict(reason='count',ada=len(contacts),c=len(wanted))
    groups={}
    for c in wanted:groups.setdefault(c['pair'],[]).append(c)
    for c in contacts:
        error=match(np.asarray([c]),groups.pop(tuple(map(int,c[:2])),[]))
        if error:return error
    return None


def measure(out,rounds,target_ms):
    cpu=min(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu})
    lib=ctypes.CDLL(str(out/'reference.so'));fn=lib.scene_time_frames
    fn.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_void_p),ctypes.c_int,ctypes.c_int,
                 ctypes.POINTER(ctypes.c_uint64),ctypes.POINTER(ctypes.c_double)];fn.restype=ctypes.c_double
    metadata=dict(scope='Full collision phase, 16 moving poses; no kinematics/constraint/dynamics/integration timings',
                  cpu=cpu,platform=platform.platform(),rounds=rounds,
                  flags='Same -O3 -gnatp -gnatn -march=native -flto -ffp-contract=off Ada profiles; C official normal SIMD',
                  shared_host=True,compiler_versions={s:subprocess.run([s,'--version'],env=environment(),capture_output=True,text=True).stdout.splitlines()[0] for s in ['gcc','gprbuild','gnatprove']})
    records=[];rng=np.random.default_rng(31402102)
    def save():
        (out/'performance.json').write_text(json.dumps(dict(metadata=metadata,records=records),indent=2)+'\n')
    with (out/'raw.jsonl').open('w') as log:
        for name,xml in fixtures():
            m,frames,rows,wanted,assets=prepare(xml);check=stream(rows,assets,0,1)
            outputs={};errors=[]
            for label in ['before','bvh']:
                p=subprocess.run([str(out/'build'/label/'release/bin/scene_bench')],input=check,text=True,capture_output=True,check=True,timeout=90)
                (out/(name+'-'+label+'.log')).write_text(p.stdout+p.stderr);outputs[label]=p.stdout
                lines=p.stdout.splitlines()
                if len(lines)!=16:errors.append(dict(method=label,reason='incomplete output'));continue
                for f,line in enumerate(lines):
                    status,contacts,_,_=parse(line);error=native_match(contacts,wanted[f])
                    if status!='SUCCESS' or error:errors.append(dict(method=label,frame=f,error=error,status=status))
            if outputs['before']!=outputs['bvh']:errors.append(dict(reason='ordered before/after output differs'))
            if errors:
                records.append(dict(case=name,timed=False,errors=errors));save();print(name,'NOT TIMED',flush=True);continue
            ptr=(ctypes.c_void_p*16)(*(d._address for d in frames));count=ctypes.c_uint64();checksum=ctypes.c_double()
            pilot=fn(m._address,ptr,16,2,ctypes.byref(count),ctypes.byref(checksum));expected_digest=checksum.value
            reps=max(2,min(10000,int(target_ms*1e6/(16*max(pilot,1)))))
            expected=sum(map(len,wanted))*reps;text=stream(rows,assets,1,reps)
            def measure_one(method):
                if method=='c':
                    ns=fn(m._address,ptr,16,reps,ctypes.byref(count),ctypes.byref(checksum))
                    if count.value!=expected:raise RuntimeError((name,'C count'))
                    return ns
                p=subprocess.run([str(out/'build'/method/'release/bin/scene_bench')],input=text,text=True,capture_output=True,check=True,timeout=120)
                v=p.stdout.split()
                if len(v)!=4 or v[0]!='SUCCESS' or int(v[2])!=expected:raise RuntimeError((name,method,p.stdout))
                if abs(float(v[3])-expected_digest)>2e-6*(1+abs(expected_digest)):raise RuntimeError((name,method,'checksum'))
                return float(v[1])
            times={s:[] for s in ['before','bvh','c']};orders=list(itertools.permutations(times))
            for r in range(rounds+2):
                order=orders[r%len(orders)];sample={s:measure_one(s) for s in order}
                if r>=2:
                    for s,v in sample.items():times[s].append(v)
                    log.write(json.dumps(dict(case=name,round=r-2,order=order,repetitions=reps,ns_per_frame=sample))+'\n');log.flush()
            def ratio(a,b):
                x=np.asarray(times[a])/times[b];boot=np.median(rng.choice(x,size=(10000,len(x)),replace=True),axis=1)
                return dict(paired_median=float(np.median(x)),ci95=np.quantile(boot,[.025,.975]).tolist())
            rec=dict(case=name,geoms=m.ngeom,frames=16,timed=True,repetitions=reps,
                     correctness='Every frame matched native contact fields; complete before/after output, including order, was byte-identical',
                     timings={s:dict(median_ns=float(np.median(v)),p10_ns=float(np.quantile(v,.1)),p90_ns=float(np.quantile(v,.9)),p95_ns=float(np.quantile(v,.95))) for s,v in times.items()},
                     bvh_vs_before=ratio('bvh','before'),bvh_vs_c=ratio('bvh','c'),samples_ns=times,
                     xml_sha256=hashlib.sha256(xml.encode()).hexdigest())
            records.append(rec);save();print(name,json.dumps({k:rec[k] for k in ['bvh_vs_before','bvh_vs_c']}),flush=True)
    save()


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--before',type=Path,required=True);p.add_argument('--after',type=Path,required=True);p.add_argument('--out',type=Path,required=True);p.add_argument('--rounds',type=int,default=15);p.add_argument('--target-ms',type=float,default=4);p.add_argument('--repo',type=Path,default=ROOT);a=p.parse_args();ROOT=a.repo.resolve()
    build(a.before,a.after,a.out);measure(a.out,a.rounds,a.target_ms)
