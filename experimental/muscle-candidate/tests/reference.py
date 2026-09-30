"""Build an oracle from verbatim function bodies in the pinned upstream C file."""
from pathlib import Path
import re,subprocess,hashlib,json
from evidence import HERE,ROOT,tool_env
NAMES=['mju_min','mju_max','mju_clip','mju_sigmoid','mju_muscleGainLength','mju_muscleGain','mju_muscleBias','mju_muscleDynamicsTimescale','mju_muscleDynamics']
FLAGS=['-std=c11','-D_POSIX_C_SOURCE=200809L','-O3','-march=native','-ffp-contract=off','-flto']
def build_reference(out):
    out=Path(out);out.mkdir(parents=True,exist_ok=True)
    src=(ROOT/'mujoco/src/engine/engine_util_misc.c').read_text()
    chunks=[]
    for name in NAMES:
        start=re.search(r'^mjtNum '+name+r'\(',src,re.M).start()
        brace=src.index('{',start);depth=1;end=brace+1
        while depth:
            depth+=(src[end]=='{')-(src[end]=='}');end+=1
        chunks.append(src[start:end])
    prefix='#include <mujoco/mjtype.h>\n#include <mujoco/mjmacro.h>\n'
    prefix+='mjtNum mju_sigmoid(mjtNum);\n'
    # Helpers are literal upstream definitions, including clip comparison order.
    text=prefix+'\n\n'.join(chunks)+'\n'
    text+=(HERE/'tests/reference_bench.c').read_text()
    (out/'muscle_reference.c').write_text(text)
    cmd=['gcc',*FLAGS,'-fPIC','-shared','-I'+str(ROOT/'mujoco/include'),str(out/'muscle_reference.c'),'-o',str(out/'muscle_reference.so')]
    subprocess.run(cmd,env=tool_env(),check=True,capture_output=True,text=True)
    (out/'reference-build.json').write_text(json.dumps({'command':cmd,'generated_sha256':hashlib.sha256(text.encode()).hexdigest(),'functions':NAMES},indent=2)+'\n')
    return out/'muscle_reference.so'
