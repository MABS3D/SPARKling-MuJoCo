"""Flat ancestry vs unchanged pinned mj_mergeChain, plus malformed admission."""
import argparse,ctypes,hashlib,json,shlex,subprocess
from pathlib import Path
import mujoco
import numpy as np
from compare import fixtures

PIN='9ecbb9d7b5ee623f54745638d36799ff90e6f7cd'

def function(text,marker):
    start=text.index(marker);brace=text.index('{',start);depth=0
    for i in range(brace,len(text)):
        if text[i]=='{':depth+=1
        elif text[i]=='}':depth-=1
        if depth==0:return text[start:i+1]
    raise ValueError(marker)

def reference(root,out):
    ref=root/'mujoco';path='src/engine/engine_core_util.c'
    if mujoco.__version__!='3.14.0':raise RuntimeError('Wrong C reference version')
    pinned=subprocess.check_output(['git','-C',str(ref),'show',PIN+':'+path]).decode().replace('\r\n','\n')
    if (ref/path).read_text()!=pinned:raise RuntimeError('Changed C reference body')
    body=function(pinned,'int mj_mergeChain(')
    src=out/'reference.c'
    src.write_text('// Unchanged extract: Copyright 2021 DeepMind Technologies Limited.\n'
        '// Apache-2.0: https://www.apache.org/licenses/LICENSE-2.0\n'
        '#include <mujoco/mujoco.h>\n#include <mujoco/mjmacro.h>\n'+body+'''
int merge_native(const mjModel* m, int* chain, int b0, int b1) {
  return mj_mergeChain(m, chain, b0, b1, 0);
}
int merge_flat(int nb, int nv, int* weld, int* address, int* width,
               int* parents, int* chain, int b0, int b1) {
  mjModel m = {0}; m.nbody=nb; m.nv=nv;
  m.body_weldid=weld; m.body_dofadr=address; m.body_dofnum=width;
  m.dof_parentid=parents;
  return mj_mergeChain(&m, chain, b0, b1, 0);
}
''')
    command=['gcc','-std=c11','-O3','-march=native','-ffp-contract=off','-Wall','-Wextra',
        '-fPIC','-shared','-MMD','-MF',str(out/'reference.d'),'-I'+str(ref/'include'),
        str(src),'-o',str(out/'reference.so')]
    run=subprocess.run(command,capture_output=True,text=True)
    (out/'reference-build.log').write_text(run.stdout+run.stderr)
    if run.returncode:raise RuntimeError(run.stderr)
    hashes={path:hashlib.sha256((ref/path).read_bytes()).hexdigest()}
    for dep in shlex.split((out/'reference.d').read_text().replace('\\\n',' ').split(':',1)[1]):
        p=Path(dep)
        if p.is_relative_to(ref):
            rel=str(p.relative_to(ref))
            original=subprocess.check_output(['git','-C',str(ref),'show',PIN+':'+rel]).decode().replace('\r\n','\n')
            if p.read_text()!=original:raise RuntimeError('Changed C header: '+rel)
            hashes[rel]=hashlib.sha256(p.read_bytes()).hexdigest()
    wheel=Path(mujoco.__file__).parent
    receipt=dict(commit=PIN,version=mujoco.__version__,sources=hashes,command=command,
        compiler=subprocess.check_output(['gcc','--version'],text=True),
        body_sha256=hashlib.sha256(body.encode()).hexdigest(),
        wrapper_sha256=hashlib.sha256(src.read_bytes()).hexdigest(),
        reference_sha256=hashlib.sha256((out/'reference.so').read_bytes()).hexdigest(),
        native_library_sha256=hashlib.sha256((wheel/'libmujoco.so.3.14.0').read_bytes()).hexdigest())
    (out/'reference.json').write_text(json.dumps(receipt,indent=2)+'\n')
    lib=ctypes.CDLL(str(out/'reference.so'))
    ints=np.ctypeslib.ndpointer(dtype=np.int32,flags='C_CONTIGUOUS')
    lib.merge_native.argtypes=[ctypes.c_void_p,ints,ctypes.c_int,ctypes.c_int]
    lib.merge_native.restype=ctypes.c_int
    lib.merge_flat.argtypes=[ctypes.c_int,ctypes.c_int,ints,ints,ints,ints,ints,ctypes.c_int,ctypes.c_int]
    lib.merge_flat.restype=ctypes.c_int
    return lib

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--binary',type=Path,required=True)
    p.add_argument('--root',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    lib=reference(a.root,a.out);rng=np.random.default_rng(2026100314)
    cases=[];inputs=[]
    def add(name,arrays,b0,b1,expected,status='SUCCESS',kind='native'):
        weld,address,width,parents=map(lambda x:np.asarray(x,dtype=np.int32),arrays)
        values=[len(weld),len(parents),b0,b1,*weld,*address,*width,*parents]
        inputs.append(' '.join(map(str,values)))
        cases.append(dict(name=name,kind=kind,nv=len(parents),b0=b0,b1=b1,
            status=status,columns=list(map(int,expected))))
    extra='<mujoco><worldbody><body name="moving"><joint type="slide"/>'\
        '<geom size=".1"/><body name="weld"><geom size=".1"/>'\
        '<body name="ball"><joint type="ball"/><geom size=".1"/>'\
        '<body name="weld_ball"><geom size=".1"/></body></body></body></body>'\
        '<body name="free"><freejoint/><geom size=".1"/>'\
        '<body name="weld_free"><geom size=".1"/></body></body></worldbody></mujoco>'
    for name,xml in [*fixtures(),('welded_ball_free',extra)]:
        model=mujoco.MjModel.from_xml_string(xml)
        if model.nv>256:raise RuntimeError('Native fixture exceeds current leaf capacity')
        (a.out/(name+'.xml')).write_text(xml)
        arrays=[model.body_weldid,model.body_dofadr,model.body_dofnum,model.dof_parentid]
        for b0 in range(model.nbody):
            for b1 in range(model.nbody):
                chain=np.zeros(256,dtype=np.int32)
                count=lib.merge_native(model._address,chain,b0,b1)
                add(name,arrays,b0,b1,chain[:count])
    # Random monotone forests exercise exact order, duplicate removal and both
    # ends of the 256-DOF supported capacity, independently of body compilation.
    for nv in [0,1,2,3,6,7,32,96,255,256]:
        for variant in range(12):
            parents=np.array([rng.integers(-1,i) for i in range(nv)],dtype=np.int32)
            weld=np.arange(nv+1,dtype=np.int32)
            address=np.arange(-1,nv,dtype=np.int32)
            width=np.r_[0,np.ones(nv,dtype=np.int32)].astype(np.int32)
            arrays=[weld,address,width,parents]
            for _ in range(12):
                b0,b1=map(int,rng.integers(0,nv+1,2));chain=np.zeros(256,dtype=np.int32)
                count=lib.merge_flat(nv+1,nv,*arrays,chain,b0,b1)
                add('forest-'+str(variant),arrays,b0,b1,chain[:count],kind='flat-C')
    base=[np.array(x,dtype=np.int32) for x in [[0,1],[-1,0],[0,4],[-1,0,1,2]]]
    for name,field,index,value in [
        ('weld-negative',0,1,-1),('weld-large',0,1,2),('width-negative',2,1,-1),
        ('address-negative',1,1,-1),('address-large',1,1,5),('span-large',2,1,5),
        ('parent-self',3,3,3),('parent-forward',3,2,3),
        ('parent-large',3,3,4),('parent-negative',3,3,-2)]:
        arrays=[x.copy() for x in base];arrays[field][index]=value
        add(name,arrays,1,0,[],status='INVALID_TOPOLOGY',kind='malformed-Ada-only')
    # Restore the valid topology after each rejection within the same process.
        add(name+'-recovered',base,1,0,[0,1,2,3],kind='recovery')
    text=str(len(inputs))+'\n'+'\n'.join(inputs)+'\n'
    (a.out/'input.txt').write_text(text)
    (a.out/'expected.json').write_text(json.dumps(cases,indent=2)+'\n')
    run=subprocess.run([str(a.binary.resolve())],input=text,text=True,capture_output=True,timeout=90)
    (a.out/'output.txt').write_text(run.stdout+run.stderr)
    lines=[line.split() for line in run.stdout.splitlines() if line.startswith('case ')]
    records=[]
    for case,line in zip(cases,lines):
        count=int(line[2]);columns=list(map(int,line[3:]))
        records.append(case|dict(passed=line[1]==case['status'] and count==len(columns)
            and columns==case['columns']))
    passed=run.returncode==0 and len(lines)==len(cases) and all(r['passed'] for r in records)
    result=dict(passed=passed,exit=run.returncode,expected=len(cases),
        exact=sum(r['passed'] for r in records),records=records,
        input_sha256=hashlib.sha256(text.encode()).hexdigest(),
        binary_sha256=hashlib.sha256(a.binary.read_bytes()).hexdigest(),
        driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        scope='Finite exact integer comparison of ancestry only. Malformed cases never execute C. No movement or whole-loader proof claim.')
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ['passed','exit','exact','expected']}))
    raise SystemExit(not passed)
if __name__=='__main__':main()
