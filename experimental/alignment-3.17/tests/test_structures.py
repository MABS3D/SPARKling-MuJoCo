"""Compare isolated 3.17 CSR admission with the exact upstream C helper.

Owned-array shape checks and the documented duplicate-tendon correction have
separate expectations. This does not test the full model validator or engine.
"""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import random
import shutil
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
PIN = '800a109a4bdd02cb60404d565db4ae16fb04a53b'

def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    import mujoco
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--foundation', type=Path, required=True)
    parser.add_argument('--reference-root', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    assert mujoco.__version__ == '3.17.0'
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False)
    foundation = args.foundation.resolve(); prior_path = foundation/'manifest.json'
    prior = json.loads(prior_path.read_text()); assert prior['reference'] == '3.17.0' and prior['commit'] == PIN
    ref = args.reference_root.resolve()
    assert subprocess.check_output(['git','-C',str(ref),'rev-parse','HEAD'],text=True).strip() == PIN
    origin = ref/'src/engine/engine_io.c'; original = origin.read_bytes()
    assert original == subprocess.check_output(['git','-C',str(ref),'show','HEAD:src/engine/engine_io.c'])
    source_text = original.decode(); start = source_text.index('static int validateSparse(')
    opening = source_text.index('{', start); depth = 1; end = opening+1
    while depth:
        depth += (source_text[end] == '{')-(source_text[end] == '}'); end += 1
    helper = source_text[start:end]
    c_source = '#include <stdint.h>\n#include <mujoco/mjtype.h>\n'+helper+'''
int probe_validate(int nr, int nc, int64_t nnz, const int* w, const int* a, const int* c, int strict) {
  return validateSparse(nr, nc, (mjtSize)nnz, w, a, c, strict);
}
'''
    (out/'reference.c').write_text(c_source)
    inputs = {}
    for n in ['mj.ads','mj-types.ads']:
        p=foundation/'source/src'/n; assert sha(p) == prior['candidate_sources']['src/'+n]
        inputs['source/src/'+n]=p
    for n in ['mj-model_structures.ads','mj-model_structures.adb']:
        inputs['source/experimental/alignment-3.17/src/'+n]=ROOT/'experimental/alignment-3.17/src'/n
    for n in ['structures.gpr','structures_runtime.gpr','structures_probe.adb']:
        inputs['source/experimental/alignment-3.17/tests/'+n]=Path(__file__).with_name(n)
    hashes={n:sha(p) for n,p in inputs.items()}
    for n,p in inputs.items():
        target=out/n; target.parent.mkdir(parents=True,exist_ok=True); shutil.copyfile(p,target)
    assert all(sha(p)==hashes[n] for n,p in inputs.items())
    include=Path(mujoco.__file__).parent/'include'
    headers={str(p.relative_to(include)):sha(p) for p in include.rglob('*.h')}
    manifest=dict(reference='3.17.0',commit=PIN,foundation_manifest_sha256=sha(prior_path),
                  sources=hashes,upstream_engine_io_sha256=sha(origin),
                  extracted_helper_sha256=hashlib.sha256(helper.encode()).hexdigest(),
                  reference_driver_sha256=sha(out/'reference.c'),headers=headers,
                  runner_sha256=sha(Path(__file__)),guard_sha256=sha(ROOT/'tools/guarded.py'))
    (out/'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env=os.environ.copy()
    env['PATH']=':'.join(str(p) for tool in ['gnat','gprbuild','gnatprove'] for p in (tc/tool).glob('*/bin'))+':'+env['PATH']
    env['STRUCTURES_BUILD_ROOT']=str(out/'build');commands=[]
    def run(cmd,label,stdin=None):
        wrapped=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','600','--',*cmd]
        began=time.monotonic();r=subprocess.run(wrapped,env=env,input=stdin,text=True,capture_output=True)
        (out/(label+'.log')).write_text(r.stdout+r.stderr)
        commands.append(dict(label=label,command=wrapped,exit=r.returncode,seconds=time.monotonic()-began,log_sha256=sha(out/(label+'.log'))))
        (out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
        if r.returncode: raise RuntimeError(label+' failed: '+(r.stdout+r.stderr)[-3000:])
        return r.stdout
    run(['gcc','-std=c11','-O2','-shared','-fPIC','-I'+str(include),str(out/'reference.c'),'-o',str(out/'reference.so')],'build-c')
    lib=ctypes.CDLL(str(out/'reference.so'));c_validate=lib.probe_validate
    ints=ctypes.POINTER(ctypes.c_int); c_validate.argtypes=[ctypes.c_int,ctypes.c_int,ctypes.c_int64,ints,ints,ints,ctypes.c_int];c_validate.restype=ctypes.c_int
    cases=[]
    def add(name,nc,w,a,c,strict=True,**extra):
        d=dict(name=name,nrows=len(w),ncols=nc,nnz=len(c),w=w,a=a,c=c,strict=strict,fw=0,fa=0,fc=0);d.update(extra);cases.append(d)
    add('gaps-and-shared-spans',5,[2,1,2],[1,4,1],[99,0,3,99,4])
    add('empty-zero-columns',0,[0,0],[0,0],[])
    add('empty-unused-storage',0,[],[],[99])
    add('strict-duplicate',3,[2],[0],[1,1])
    add('nonstrict-duplicate',3,[2],[0],[1,1],False)
    for n in [-2147483648,-1,0,1,2147483647]:
        add('address-'+str(n),2,[1],[n],[0])
        add('width-'+str(n),2,[n],[0],[0])
        add('column-'+str(n),2,[1],[0],[n])
    add('largest-ncols',2147483647,[1],[0],[2147483646])
    add('past-largest-column',2147483647,[1],[0],[2147483647])
    rng=random.Random(2026102403)
    for k in range(1200):
        nr=rng.randrange(7);nc=rng.randrange(7);nnz=rng.randrange(22);strict=k%2==0
        widths=[rng.randrange(-1,nc+2 if strict else nc+1) for _ in range(nr)]
        addresses=[rng.choice([-2147483648,-1,*range(nnz+2),2147483647]) for _ in range(nr)]
        columns=[rng.randrange(-1,nc+1) for _ in range(nnz)]
        add('random-'+str(k),nc,widths,addresses,columns,strict)
    for field in ['fw','fa','fc']:
        add('lower-bound-'+field,2,[1],[0],[1],**{field:1})
    add('missing-width',2,[],[0],[1],nrows=1)
    add('missing-address',2,[1],[],[1])
    add('missing-column',2,[1],[0],[1],nnz=2)
    add('extra-width',2,[1,1],[0],[1],nrows=1)
    add('fixed-tendon-width-correction',1,[2],[0],[0,0],False,correction=True)
    def c_call(nr,nc,nnz,w,a,c,strict):
        wa=(ctypes.c_int*len(w))(*w);aa=(ctypes.c_int*len(a))(*a);ca=(ctypes.c_int*len(c))(*c)
        return c_validate(nr,nc,nnz,wa,aa,ca,int(strict))
    expectations=[]
    for d in cases:
        shape=all(d[k]==0 for k in ['fw','fa','fc']) and len(d['w'])==d['nrows'] and len(d['a'])==d['nrows'] and len(d['c'])==d['nnz']
        if not shape: expected=(1,-1);c_code=None
        else:
            c_code=c_call(d['nrows'],d['ncols'],d['nnz'],d['w'],d['a'],d['c'],d['strict'])
            row=-1
            if c_code:
                row=next(r for r in range(d['nrows']) if c_call(1,d['ncols'],d['nnz'],[d['w'][r]],[d['a'][r]],d['c'],d['strict']))
            expected=({0:0,1:2,2:3,3:4}[c_code],row)
        if d.get('correction'):
            assert c_code==1;expected=(0,-1)
        expectations.append(dict(name=d['name'],expected=list(expected),c_code=c_code,documented_correction=bool(d.get('correction'))))
    lines=[str(len(cases))]
    for d in cases:
        values=[d['nrows'],d['ncols'],d['nnz'],int(d['strict']),len(d['w']),len(d['a']),len(d['c']),d['fw'],d['fa'],d['fc'],*d['w'],*d['a'],*d['c']]
        lines.append(' '.join(map(str,values)))
    encoded='\n'.join(lines)+'\n';(out/'cases.input').write_text(encoded)
    (out/'expectations.json').write_text(json.dumps(expectations,indent=2)+'\n')
    (out/'cases.json').write_text(json.dumps(cases,indent=2)+'\n')
    profiles=[];project=out/'source/experimental/alignment-3.17/tests/structures_runtime.gpr'
    for mode in ['validation','release']:
        env['STRUCTURES_MODE']=mode;run(['gprbuild','-p','-P',str(project),'-j1'],'build-'+mode)
        binary=out/'build/runtime'/mode/'bin/structures_probe'
        output=run([str(binary)],'run-'+mode,encoded)
        # Guard diagnostics are after numeric output; reject any unexpected probe line.
        rows=[tuple(map(int,line.split())) for line in output.splitlines() if not line.startswith('guarded:')]
        assert len(rows)==len(cases),(mode,len(rows),len(cases))
        failures=[dict(case=e,actual=list(actual)) for e,actual in zip(expectations,rows) if actual!=tuple(e['expected'])]
        profiles.append(dict(mode=mode,binary_sha256=sha(binary),cases=len(rows),passed=len(rows)-len(failures),failures=failures))
        if failures:raise AssertionError(failures[:5])
        print(mode,len(rows),'passed',flush=True)
    result=dict(reference='3.17.0',scope='Exact extracted validateSparse C helper versus isolated integer kernels; full validator/engine admission is not exercised.',
                manifest_sha256=sha(out/'manifest.json'),source_hashes_unchanged=all(sha(out/n)==h for n,h in hashes.items()),
                driver_hashes_unchanged=(sha(Path(__file__))==manifest['runner_sha256'] and sha(ROOT/'tools/guarded.py')==manifest['guard_sha256']),
                reference_inputs_unchanged=(sha(origin)==manifest['upstream_engine_io_sha256'] and sha(out/'reference.c')==manifest['reference_driver_sha256']
                    and all(sha(include/n)==h for n,h in headers.items())),
                comparison_cases=sum(e['c_code'] is not None and not e['documented_correction'] for e in expectations),
                owned_shape_cases=sum(e['c_code'] is None for e in expectations),documented_correction_cases=1,profiles=profiles)
    result['complete']=all(result[k] for k in ['source_hashes_unchanged','driver_hashes_unchanged','reference_inputs_unchanged']) and all(not p['failures'] for p in profiles)
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    assert result['complete'];print('complete',flush=True)

if __name__=='__main__':main()
