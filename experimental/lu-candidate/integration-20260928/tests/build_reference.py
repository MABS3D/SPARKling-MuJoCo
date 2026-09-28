from pathlib import Path
import subprocess,json,hashlib
root=Path(__file__).resolve().parents[1];upstream=Path('/var/tmp/sparkling-movement-c/source')
s=upstream/'src/engine/engine_util_solve.c';text=s.read_text()
parts=[]
for name in ['mju_factorLU','mju_solveLU','mju_factorLUSparse','mju_solveLUSparse']:
 start=text.index(('int ' if name.startswith('mju_factor') else 'void ')+name+'(');brace=text.index('{',start);end=brace+1;depth=1
 while depth:
  depth+=(text[end]=='{')-(text[end]=='}');end+=1
 parts.append(text[start:end])
head=text[:text.index('#include')]
head+='''#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "engine/engine_util_sparse.h"
#define mju_abs fabs
#define mjERROR(...) abort()
static void mju_copy(mjtNum* d, const mjtNum* s, int n) { if(n) memcpy(d,s,n*sizeof(mjtNum)); }
static void mju_copyInt(int* d, const int* s, int n) { if(n) memcpy(d,s,n*sizeof(int)); }
'''
p=root/'tests/reference.c';p.write_text(head+'\n\n'.join(parts)+'\n')
compiler=str(next(Path('/var/tmp/sparkling-matrix-recovery/toolchains/gnat').glob('*/bin/gcc')))
cmd=[compiler,'-shared','-fPIC','-O3','-march=native','-ffp-contract=off','-DmjUSEPLATFORMSIMD','-I'+str(upstream/'include'),'-I'+str(upstream/'src'),str(p),'-o',str(root/'bin/reference.so')]
subprocess.run(cmd,check=True)
(root/'evidence/reference.json').write_text(json.dumps(dict(version='3.14.0',source_sha256=hashlib.sha256(s.read_bytes()).hexdigest(),extracted_sha256=hashlib.sha256(p.read_bytes()).hexdigest(),command=cmd),indent=2))
