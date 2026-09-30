from pathlib import Path
import hashlib,json,re,subprocess
here=Path(__file__).resolve().parents[1];root=here.parents[1];out=Path('/var/tmp/sparkling-actuators-20260930/oracle');out.mkdir(parents=True,exist_ok=True)
def extract(file,name):
 text=file.read_text();m=re.search(r'^mjtNum '+name+r'\(|^mjDCMotorSlots '+name+r'\(',text,re.M)
 if not m:raise ValueError(name)
 first=text.index('{',m.start());level=1;j=first+1
 while level:
  level+=(text[j]=='{')-(text[j]=='}');j+=1
 block=text[m.start():j]
 return block,{'file':str(file.relative_to(root)),'line':text.count('\n',0,m.start())+1,'sha256_lf':hashlib.sha256(block.encode()).hexdigest(),'source_sha256_raw':hashlib.sha256(file.read_bytes()).hexdigest()}
parts=[];manifest=[]
for file,name in [('engine_util_misc.c','mj_lugreStribeck'),('engine_util_misc.c','mj_dcmotorSlots'),('engine_core_util.c','mj_dcmotorResistance'),('engine_support.c','mj_nextActivation')]:
 block,meta=extract(root/'mujoco/src/engine'/file,name);parts.append(block);manifest.append(meta)
headers='''// Copyright 2021 DeepMind Technologies Limited.
// Licensed under the Apache License, Version 2.0; see candidate LICENSE.
// Assembled by the test harness from verbatim MuJoCo 3.14.0 excerpts.
#include <mujoco/mujoco.h>
#include "engine_support.h"
#include "engine_util_misc.h"
#include "engine_util_blas.h"
#include "engine_core_util.h"
'''
source=out/'oracle.c';source.write_text(headers+'\n\n'.join(parts)+'\n')
import mujoco
lib=next(Path(mujoco.__file__).parent.glob('libmujoco.so*'))
cmd=['gcc','-shared','-fPIC','-O2','-ffp-contract=off','-Werror=implicit-function-declaration','-I'+str(root/'mujoco/include'),'-I'+str(root/'mujoco/src/engine'),str(source),str(lib),'-Wl,-rpath,'+str(lib.parent),'-lm','-o',str(out/'oracle.so')]
subprocess.run(cmd,check=True)
manifest={'version':mujoco.__version__,'reference_commit':'9ecbb9d7b5ee623f54745638d36799ff90e6f7cd','wheel_library':str(lib),'library_sha256':hashlib.sha256(lib.read_bytes()).hexdigest(),'excerpts':manifest,'headers':{str(f.relative_to(root)):hashlib.sha256(f.read_bytes()).hexdigest() for folder in ['mujoco/include/mujoco','mujoco/src/engine'] for f in (root/folder).glob('*.h')},'command':cmd,'compiler_version':subprocess.check_output(['gcc','--version'],text=True),'oracle_sha256':hashlib.sha256((out/'oracle.so').read_bytes()).hexdigest()}
(here/'evidence/oracle.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(out/'oracle.so')
