"""Complete collision phase: reconstructed two-pass Ada, unified Ada, native C.

No model loading, kinematic update, constraints, dynamics or integration timed.
The reconstructed baseline exists for primitives only, not hulls/heightfields.
"""
import argparse
import ctypes
import gc
import hashlib
import itertools
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess

import mujoco
import numpy as np

from common import HERE, ROOT, environment, digest, row
from check_scene import fmt, parse, match, native_contacts
from check_advanced import CUBE, mesh_asset, mesh_graph


def build(out):
    out.mkdir(parents=True,exist_ok=False)
    snap=out/'source';snap.mkdir()
    for folder in ['base','src','tests']:shutil.copytree(HERE/folder,snap/folder)
    shutil.copyfile(HERE/'rigid.gpr',snap/'rigid.gpr')
    library=Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'
    if mujoco.__version__!='3.14.0':raise RuntimeError('unexpected native version')
    env=environment()
    ccmd=['gcc','-O3','-march=native','-ffp-contract=off','-fPIC','-shared',
          '-I'+str(ROOT/'mujoco/include'),str(snap/'tests/scene_reference.c'),str(library),
          '-Wl,-rpath,'+str(library.parent),'-o',str(out/'scene_reference.so')]
    subprocess.run(ccmd,env=env,check=True)
    dcmd=['gcc','-O3','-march=native','-flto','-ffp-contract=off','-fPIC','-shared',
          '-I'+str(ROOT/'mujoco/include'),'-I'+str(ROOT/'mujoco/src'),
          '-I/var/tmp/sparkling-movement-c/build/_deps/ccd-src/src',
          '-I/var/tmp/sparkling-movement-c/build/_deps/ccd-build/src',
          str(snap/'tests/reference.c'),str(library),'-Wl,-rpath,'+str(library.parent),
          '-o',str(out/'diagnostic_reference.so')]
    subprocess.run(dcmd,env=env,check=True)
    baseline=out/'baseline-source';shutil.copytree(snap,baseline)
    p=baseline/'src/mj-rigid_detector.adb';s=p.read_text()
    old='Append_Pair (A, B, Margin, Explicit_Index, not With_Narrowphase, Hits, Details);'
    call='Traverse (S, Poses, Hits.Pairs, Hits.Metadata, False, Result);'
    assert s.count(old)==s.count(call)==1
    s=s.replace(old,'Append_Pair (A, B, Margin, Explicit_Index, True, Hits, Details);')
    s=s.replace(call,'Traverse (S, Poses, Hits.Pairs, Hits.Metadata, True, Result);')
    p.write_text(s)
    # This is a diagnostic reconstruction, not a proved production variant.
    # The release-only baseline does not assert Find_Candidates' no-Test post.
    ps=baseline/'src/mj-rigid_detector.ads';s=ps.read_text()
    s=s.replace('Post => Narrowphase_Count (S) = 0\n         and then (if Result /= Success then Hits.Pairs.Length = 0)',
                'Post => (if Result /= Success then Hits.Pairs.Length = 0)')
    ps.write_text(s)
    cmds={}
    for name,source in [('unified',snap),('two-pass',baseline)]:
        env.update(RIGID_MODE='release',RIGID_BUILD_ROOT=str(out/'build'/name))
        cmd=['gprbuild','-P',str(source/'rigid.gpr'),'-j2','scene_bench.adb',
             '-largs',str(out/'scene_reference.so'),'-Wl,-rpath,'+str(out)]
        cmds[name]=cmd
        with (out/(name+'-build.log')).open('w') as log:
            subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','180','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT,check=True)
    manifest=dict(reference_version=mujoco.__version__,reference_library=str(library),
                  reference_library_sha256=digest(library),c_command=ccmd,diagnostic_command=dcmd,ada_commands=cmds,
                  sources={name:{str(p.relative_to(source)):digest(p) for folder in ['base','src','tests'] for p in (source/folder).glob('*') if p.is_file()} for name,source in [('unified',snap),('two-pass',baseline)]},
                  gpr_sha256=digest(snap/'rigid.gpr'),
                  executables={name:digest(out/'build'/name/'release/bin/scene_bench') for name in ['unified','two-pass']},
                  reference_harness_sha256=digest(out/'scene_reference.so'),
                  baseline='reconstructed primitive two-stage pipeline: boolean Test selects hits, then the identical configured full-contact generators; only diagnostic snapshot changed')
    (out/'benchmark-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')


def xml_cases():
    for n in [32,128,512]:
        for family in ['sparse','dense','mixed']:
            step=2 if family=='sparse' else .6
            kinds=['sphere','capsule','ellipsoid','cylinder','box'] if family=='mixed' else ['sphere']
            world=''.join(f'<body pos="{i%8*step} {(i//8)%8*step} {i//64*step}"><freejoint/><geom type="{kinds[i%len(kinds)]}" size=".35 .4 .45"/></body>' for i in range(n))
            yield f'{family}-{n}', '<mujoco><option ccd_iterations="100"/><worldbody>'+world+'</worldbody></mujoco>',True
    for n in [32,128]:
        kinds=['sphere','capsule','ellipsoid','cylinder','box']
        world='<geom type="plane" size="10 10 .1"/>'+''.join(f'<body pos="{i%16*1.5} {i//16*1.5} .25"><freejoint/><geom type="{kinds[i%5]}" size=".3 .35 .4"/></body>' for i in range(n))
        yield f'floor-mixed-{n}', '<mujoco><worldbody>'+world+'</worldbody></mujoco>',True
    verts=' '.join(map(str,CUBE.reshape(-1)))
    for n in [16,64]:
        world=''.join(f'<geom type="mesh" mesh="cube" pos="{i%8*3} {i//8*3} 0"/><body pos="{i%8*3+1.2} {i//8*3+.1} .07"><freejoint/><geom type="sphere" size=".35"/></body>' for i in range(n))
        yield f'hull-sphere-{n}',f'<mujoco><asset><mesh name="cube" vertex="{verts}"/></asset><worldbody>{world}</worldbody></mujoco>',False
    for n in [16,64]:
        world='<geom type="hfield" hfield="field"/>'+''.join(f'<body pos="{i%8*1.1-4} {i//8*1.1-4} .45"><freejoint/><geom type="sphere" size=".3"/></body>' for i in range(n))
        yield f'terrain-sphere-{n}',f'<mujoco><asset><hfield name="field" nrow="33" ncol="33" size="10 10 .7 .5"/></asset><worldbody>{world}</worldbody></mujoco>',False


def prepare(xml):
    m=mujoco.MjModel.from_xml_string(xml)
    if len(m.hfield_data):m.hfield_data[:]=.25
    initial=mujoco.MjData(m).qpos.copy();frames=[];rows=[];want=[];assets={}
    kinds={0:'plane',2:'sphere',3:'capsule',4:'ellipsoid',5:'cylinder',6:'box',7:'mesh',1:'hfield'}
    for f in range(16):
        d=mujoco.MjData(m);d.qpos[:]=initial
        for j in range(m.njnt):
            adr=int(m.jnt_qposadr[j]);d.qpos[adr:adr+3]+=.025*np.sin((f*.13+j)*np.array([1.,1.2,1.7]))
            q=np.array([1.,.015*np.sin(f*.11+j),.012*np.cos(f*.09+j),.009*np.sin(f*.06-j)]);q/=np.linalg.norm(q)
            d.qpos[adr+3:adr+7]=q
        mujoco.mj_fwdPosition(m,d);mujoco.mj_collision(m,d)
        frames.append(d);want.append(native_contacts(d));rs=[]
        for g in range(m.ngeom):
            body=int(m.geom_bodyid[g]);weld=int(m.body_weldid[body]);par=int(m.body_weldid[m.body_parentid[weld]])
            kind=kinds[int(m.geom_type[g])]
            r=row((kind if kind not in ['mesh','hfield'] else 'box',m.geom_size[g]),d.geom_xpos[g],d.geom_xmat[g],body,weld,par,
                  bool(m.body_dofnum[weld]),int(m.geom_contype[g])&0xffffffff,int(m.geom_conaffinity[g])&0xffffffff,float(m.geom_margin[g]),float(m.geom_gap[g]))
            if kind=='mesh':
                r[0]=6
                if f==0:
                    v,faces=mesh_asset(m,g);graph,seeds=mesh_graph(m,g)
                    a=[len(v),*v.reshape(-1),len(faces)]
                    for normal,indices in faces:a.extend([*normal,len(indices),*indices])
                    a.append(len(graph))
                    if graph:a.extend([*seeds,*graph])
                    assets[g]=a
            elif kind=='hfield':
                r[0]=7
                if f==0:
                    h=int(m.geom_dataid[g]);adr=int(m.hfield_adr[h]);nr=int(m.hfield_nrow[h]);nc=int(m.hfield_ncol[h])
                    assets[g]=[nr,nc,*m.hfield_size[h],*m.hfield_data[adr:adr+nr*nc]]
            rs.append(r)
        rows.append(rs)
    return m,frames,rows,want,assets


def stream(rows,assets,mode,reps):
    text=fmt([mode,len(rows),reps,len(rows[0])])
    for i,r in enumerate(rows[0]):
        text+=fmt(r)
        if i in assets:text+=fmt(assets[i])
    for frame in rows[1:]:text+=fmt([x for r in frame for x in r[12:25]])
    return text


def matched(a,b):
    """Same outputs up to tangent-basis choice; independent native tolerances."""
    native=[dict(pair=tuple(map(int,r[:2])),distance=r[2],position=r[3:6],normal=r[6:9],include=r[15],excluded=int(r[16]),dim=int(r[17]),fri=r[18:23]) for r in b]
    return match(a,native)


def diagnose_normals(actual,want,m,d,raw_fn):
    """Only recognize the already documented native empty-clip normal flip.

    No exemption for arbitrary differences: every mismatching contact must
    match raw native CCD in distance, position and canonical normal.
    """
    if len(actual)!=len(want):return None
    left=list(range(len(want)));diagnosed=[]
    for r in actual:
        pair=tuple(map(int,r[:2]));found=None
        for j in left:
            c=want[j]
            if pair!=c['pair']:continue
            if abs(r[2]-c['distance'])>2e-6 or np.max(np.abs(r[3:6]-c['position']))>2e-6:continue
            if int(r[17])!=c['dim'] or np.max(np.abs(r[18:23]-c['fri']))>1e-10:continue
            if abs(r[15]-c['include'])>1e-12 or int(r[16])!=c['excluded']:continue
            if np.max(np.abs(r[6:9]-c['normal']))<=2e-6:found=j;break
            if np.max(np.abs(r[6:9]+c['normal']))>2e-6:continue
            a,b=pair;reverse=m.geom_type[a]>m.geom_type[b]
            if reverse:a,b=b,a
            v=np.zeros(500);n=raw_fn(m._address,d._address,a,b,0,v)
            if reverse:v[4:7]*=-1
            if n==1 and np.max(np.abs(r[2:9]-v[:7]))<1e-9:
                diagnosed.append(dict(pair=pair,distance=float(r[2]),position=r[3:6].tolist(),ada_and_raw_ccd_normal=r[6:9].tolist(),native_driver_normal=c['normal'].tolist()))
                found=j;break
        if found is None:return None
        left.remove(found)
    return diagnosed


def measure(out,rounds,target_ms,only=None):
    cpu=max(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu})
    lib=ctypes.CDLL(str(out/'scene_reference.so'));fn=lib.scene_time_frames
    fn.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_void_p),ctypes.c_int,ctypes.c_int,ctypes.POINTER(ctypes.c_uint64),ctypes.POINTER(ctypes.c_double)];fn.restype=ctypes.c_double
    diag_lib=ctypes.CDLL(str(out/'diagnostic_reference.so'));raw_fn=diag_lib.rigid_convex_contacts
    raw_fn.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_double,np.ctypeslib.ndpointer(dtype=np.float64,flags='C_CONTIGUOUS')];raw_fn.restype=ctypes.c_int
    rng=np.random.default_rng(31402021);records=[];raw=out/'scene-timing-raw.jsonl'
    env=environment()
    versions={n:subprocess.run([n,'--version'],env=env,text=True,capture_output=True).stdout for n in ['gnat','gprbuild','gcc']}
    metadata=dict(scope='complete collision phase over 16 precomputed moving frames, full contacts/materials/frames included; excludes kinematics, constraints, dynamics and integration',
                  baseline='reconstructed two-stage primitive path, not an earlier integrated scene implementation',
                  cpu_affinity=[cpu],platform=platform.platform(),cpuinfo=Path('/proc/cpuinfo').read_text(),compiler_versions=versions,
                  rounds=rounds,target_ms_per_sample=target_ms,warmup_cycles=4,anti_dce='same opaque output-buffer escape per frame; checksum outside timer',results=records)
    def save(): (out/'scene-performance.json').write_text(json.dumps(metadata,indent=2)+'\n')
    with raw.open('w') as log:
        for name,xml,has_baseline in xml_cases():
            if only and not any(s in name for s in only):continue
            gc.collect();m,frames,rows,want,assets=prepare(xml)
            (out/(name+'-model.xml')).write_text(xml)
            check_input=stream(rows,assets,0,1);(out/(name+'-input.txt')).write_text(check_input)
            methods=['unified','two-pass'] if has_baseline else ['unified']
            outputs={};errors={};known_normal_flips={}
            for method in methods:
                exe=out/'build'/method/'release/bin/scene_bench'
                p=subprocess.run([str(exe)],input=check_input,text=True,capture_output=True,timeout=90)
                (out/(name+'-'+method+'-correctness.log')).write_text(p.stdout+p.stderr)
                parsed=[];faults=[];known=[]
                for f,line in enumerate(p.stdout.splitlines()):
                    try:
                        status,contacts,selected,calls=parse(line)
                        if status!='SUCCESS':faults.append(dict(frame=f,status=status));continue
                        parsed.append(contacts)
                        error=match(contacts,want[f])
                        if error:
                            diagnosed=diagnose_normals(contacts,want[f],m,frames[f],raw_fn)
                            if diagnosed:known.extend(dict(frame=f,**v) for v in diagnosed)
                            else:faults.append(dict(frame=f,**error))
                        if len(contacts):
                            matrices=contacts[:,6:15].reshape(-1,3,3)
                            if not np.isfinite(contacts).all() or np.max(np.abs(matrices@matrices.transpose(0,2,1)-np.eye(3)))>1e-8:
                                faults.append(dict(frame=f,reason='nonfinite output or invalid frame'))
                    except (ValueError,IndexError) as e:faults.append(dict(frame=f,reason=str(e)))
                if p.returncode or len(parsed)!=16:faults.append(dict(reason='probe completion',exitcode=p.returncode,frames=len(parsed)))
                outputs[method]=parsed;errors[method]=faults;known_normal_flips[method]=known
            if has_baseline and len(outputs['unified'])==len(outputs['two-pass'])==16:
                equivalence=[dict(frame=f,**e) for f,(a,b) in enumerate(zip(outputs['unified'],outputs['two-pass'])) if (e:=matched(a,b))]
            else:equivalence=[]
            if any(errors.values()) or equivalence:
                record=dict(case=name,geoms=m.ngeom,timed=False,correctness_errors=errors,baseline_differences=equivalence)
                records.append(record);print(name,'NOT TIMED: outputs differ',flush=True);save();continue
            comparable=not any(known_normal_flips.values())
            ptr=(ctypes.c_void_p*16)(*(d._address for d in frames))
            count=ctypes.c_uint64();checksum=ctypes.c_double()
            pilot=fn(m._address,ptr,16,2,ctypes.byref(count),ctypes.byref(checksum))
            reps=max(2,min(100000,int(target_ms*1e6/(16*max(1,pilot)))))
            expected=sum(map(len,want))*reps
            expected_digest=checksum.value
            def c():
                ns=fn(m._address,ptr,16,reps,ctypes.byref(count),ctypes.byref(checksum))
                if count.value!=expected:raise RuntimeError((name,'C count',count.value,expected))
                return ns
            text=stream(rows,assets,1,reps)
            def ada(method):
                exe=out/'build'/method/'release/bin/scene_bench'
                p=subprocess.run([str(exe)],input=text,text=True,capture_output=True,check=True,timeout=120);v=p.stdout.split()
                if len(v)!=4 or v[0]!='SUCCESS' or int(v[2])!=expected:raise RuntimeError((name,method,p.stdout,p.stderr,expected))
                if comparable and abs(float(v[3])-expected_digest)>2e-6*(1+abs(expected_digest)):raise RuntimeError((name,method,'checksum',v[3],expected_digest))
                return float(v[1])
            times={n:[] for n in [*methods,'c']};orders=list(itertools.permutations(times))
            for r in range(rounds):
                order=orders[r%len(orders)];sample={}
                for method in order:sample[method]=c() if method=='c' else ada(method)
                for method,value in sample.items():times[method].append(value)
                log.write(json.dumps(dict(case=name,round=r,order=order,ns_per_frame=sample,repetitions=reps,frames=16))+'\n');log.flush()
            def stats(values):
                a=np.asarray(values)
                return dict(median_ns=float(np.median(a)),p05_ns=float(np.quantile(a,.05)),p95_ns=float(np.quantile(a,.95)),min_ns=float(a.min()),max_ns=float(a.max()))
            def ratio(a,b):
                ratios=np.asarray(times[a])/times[b]
                boot=np.median(rng.choice(ratios,size=(20000,len(ratios)),replace=True),axis=1)
                return dict(paired_median=float(np.median(ratios)),ci95=np.quantile(boot,[.025,.975]).tolist())
            record=dict(case=name,geoms=m.ngeom,frames=16,repetitions=reps,timed=True,contacts_min_max=[min(map(len,want)),max(map(len,want))],
                        timings={n:stats(v) for n,v in times.items()},paired_ns=times,
                        comparable_to_c=comparable,unified_vs_c=ratio('unified','c') if comparable else None,
                        known_native_normal_flips=known_normal_flips,
                        correctness='all 16 frames matched native fields or the precisely diagnosed native empty-clip normal flip; baseline matched unified where available. C timing ratio withheld if normals differ.',
                        xml_sha256=hashlib.sha256(xml.encode()).hexdigest())
            if has_baseline:record['unified_vs_two_pass']=ratio('unified','two-pass')
            records.append(record);save()
            change=100*(record['unified_vs_two_pass']['paired_median']-1) if has_baseline else None
            print(name,'new ns',round(record['timings']['unified']['median_ns'],1),'change %',None if change is None else round(change,2),'Ada/C',None if not comparable else round(record['unified_vs_c']['paired_median'],3),flush=True)
    save()
    return records


if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--out',type=Path,required=True);p.add_argument('--reuse',action='store_true');p.add_argument('--rounds',type=int,default=15);p.add_argument('--target-ms',type=float,default=20);p.add_argument('--only',nargs='+');a=p.parse_args();out=a.out.resolve()
    if not a.reuse:build(out)
    measure(out,a.rounds,a.target_ms,a.only)
