"""Source-frozen checked/release builds; actual native MuJoCo C oracle."""
from pathlib import Path
import ctypes
import hashlib
import json
import os
import shutil
import subprocess

import mujoco

HERE=Path(__file__).resolve().parents[1]
ROOT=HERE.parents[1]
TOOLCHAINS=Path('/var/tmp/sparkling-matrix-recovery/toolchains')

def digest(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def environment():
    env=os.environ.copy()
    env['PATH']=':'.join(str(p) for name in ['gnat','gprbuild','gnatprove']
                         for p in (TOOLCHAINS/name).glob('*/bin'))+':'+env['PATH']
    return env

def build(out):
    out=Path(out);out.mkdir(parents=True,exist_ok=False)
    snapshot=out/'source';snapshot.mkdir()
    for folder in ['base','src','tests']:
        shutil.copytree(HERE/folder,snapshot/folder)
    shutil.copyfile(HERE/'rigid.gpr',snapshot/'rigid.gpr')
    sources={str(p.relative_to(HERE)):digest(p) for folder in ['base','src','tests']
             for p in (HERE/folder).glob('*') if p.is_file()}
    sources['rigid.gpr']=digest(HERE/'rigid.gpr')
    env=environment();env['RIGID_BUILD_ROOT']=str(out/'build')
    for mode in ['validation','release']:
        env['RIGID_MODE']=mode
        cmd=['gprbuild','-P',str(snapshot/'rigid.gpr'),'-j1']
        with (out/(mode+'-build.log')).open('w') as f:
            subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000',
                            '--timeout','180','--',*cmd],env=env,stdout=f,
                           stderr=subprocess.STDOUT,check=True)
    library=Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'
    if mujoco.__version__!='3.14.0':raise RuntimeError('Unexpected C reference')
    cmd=['gcc','-O3','-march=native','-flto','-ffp-contract=off','-fPIC','-shared',
         '-I'+str(ROOT/'mujoco/include'),'-I/var/tmp/sparkling-movement-c/build/_deps/ccd-src/src',
         '-I/var/tmp/sparkling-movement-c/build/_deps/ccd-build/src','-I'+str(ROOT/'mujoco/src'),
         str(snapshot/'tests/reference.c'),str(library),
         '-Wl,-rpath,'+str(library.parent),'-o',str(out/'reference.so')]
    subprocess.run(cmd,check=True)
    record={'sources':sources,'reference_library':str(library),
            'reference_library_sha256':digest(library),'oracle_command':cmd,
            'binaries':{m:digest(out/'build'/m/'bin/rigid_probe') for m in ['validation','release']},
            'contact_binaries':{m:digest(out/'build'/m/'bin/contact_probe') for m in ['validation','release']},
            'full_contact_binaries':{m:digest(out/'build'/m/'bin/full_contact_probe') for m in ['validation','release']},
            'scene_binaries':{m:digest(out/'build'/m/'bin/scene_probe') for m in ['validation','release']}}
    (out/'manifest.json').write_text(json.dumps(record,indent=2)+'\n')
    return out

def oracle(out):
    lib=ctypes.CDLL(str(Path(out)/'reference.so'))
    lib.rigid_pair.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.c_int,ctypes.c_double]
    lib.rigid_pair.restype=ctypes.c_int
    lib.rigid_time.argtypes=[ctypes.c_void_p,ctypes.c_void_p,ctypes.c_int,ctypes.POINTER(ctypes.c_uint64)]
    lib.rigid_time.restype=ctypes.c_double
    lib.rigid_time_frames.argtypes=[ctypes.c_void_p,ctypes.POINTER(ctypes.c_void_p),ctypes.c_int,ctypes.c_int,ctypes.POINTER(ctypes.c_uint64)]
    lib.rigid_time_frames.restype=ctypes.c_double
    return lib

KINDS={'plane':0,'sphere':1,'capsule':2,'ellipsoid':3,'cylinder':4,'box':5}

def row(shape,position,rotation,body,weld,parent,dynamic,contype=1,affinity=1,margin=0,gap=0,asleep=False):
    kind,size=shape
    return [KINDS[kind],body,weld,parent,int(dynamic),contype,affinity,margin,gap,
            *size,*position,*rotation,int(asleep)]

def serialize(rows,mode=0,repeats=1,explicit=(),exclusions=(),filter_parent=True,sleep=False,margin=None):
    values=[mode,len(rows),len(explicit),len(exclusions),repeats,int(filter_parent),int(sleep)]
    for r in rows:values.extend(r)
    for p in explicit:values.extend(p)
    for p in exclusions:values.extend(p)
    if margin is not None:values.append(margin)
    return ' '.join(format(x,'.17g') if isinstance(x,float) else str(x) for x in values)+'\n'
