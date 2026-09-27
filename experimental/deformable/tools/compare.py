#!/usr/bin/env python3
"""Checked Cartesian flex-edge trajectories against the installed MuJoCo C library.
Run with the project test venv and --toolchain-root. No writes to shared build dirs.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import numpy as np
import mujoco

REPO = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(REPO / 'experimental/smooth/tools'))
from prove_fragments import isolated_project


def digest(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def build(out, toolchain, release=False):
    work = Path(tempfile.mkdtemp(prefix='sparkling-elastic-'))
    source = work / 'source'
    files = [REPO / 'src/mj.ads', REPO / 'src/mj-types.ads',
             *sorted((REPO / 'experimental/smooth/src').glob('mj-elastic_*.ad?')),
             REPO / 'experimental/deformable/tests/elastic_probe.adb']
    hashes = {}
    for p in files:
        rel = p.relative_to(REPO)
        dst = source / rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dst)
        hashes[str(rel)] = digest(dst)
    if any(digest(p) != hashes[str(p.relative_to(REPO))] for p in files):
        raise RuntimeError('sources changed during snapshot')
    env = os.environ.copy()
    env['PATH'] = os.pathsep.join(str(p) for name in ('gnat', 'gprbuild', 'gnatprove')
        for p in toolchain.glob(name + '/*/bin')) + os.pathsep + env['PATH']
    project = isolated_project(source, work, 'elastic_probe')
    project.write_text(project.read_text().replace('project Fragment is',
        'project Fragment is\n   for Main use ("elastic_probe.adb");\n   for Exec_Dir use "bin";'))
    if release:
        project.write_text(project.read_text().replace(
            '"-O0", "-g", "-gnata", "-gnato", "-gnatVa"',
            '"-O3", "-gnatp", "-gnatn", "-march=native", "-flto"'))
    cmd = ['gprbuild', '-P', str(project), '-j2']
    manifest = dict(snapshot=str(source), source_sha256=hashes,
        command=cmd, project=project.read_text(), mujoco=mujoco.__version__,
        harness_sha256=digest(__file__),
        libraries={str(p): digest(p) for p in Path(mujoco.__file__).parent.glob('libmujoco*')})
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2))
    with (out / 'build.log').open('w') as log:
        subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    exe = work / 'bin/elastic_probe'
    manifest['binary'] = str(exe)
    manifest['binary_sha256'] = digest(exe)
    (out / 'manifest.json').write_text(json.dumps(manifest, indent=2))
    return exe


def xml_model(base, mass, pinned, edges, stiffness, damping, gravity, dt):
    text = ['<mujoco><option integrator="Euler" timestep="%s" gravity="%s">'
            '<flag constraint="disable"/></option><worldbody>' %
            (dt, ' '.join(map(str, gravity)))]
    for v, pos in enumerate(base):
        text += ['<body name="v%d" pos="%s">' % (v, ' '.join(map(str, pos)))]
        if not pinned[v]:
            for axis in ('1 0 0', '0 1 0', '0 0 1'):
                text += ['<joint type="slide" axis="%s"/>' % axis]
        text += ['<inertial pos="0 0 0" mass="%s" diaginertia=".01 .01 .01"/></body>' % mass[v]]
    text += ['</worldbody><deformable>']
    for e, (a,b) in enumerate(edges):
        text += ['<flex name="e%d" dim="1" body="v%d v%d" vertex="0 0 0 0 0 0" '
                 'element="0 1" radius=".001"><edge stiffness="%s" damping="%s"/>'
                 '<contact contype="0" conaffinity="0" selfcollide="none"/></flex>' %
                 (e,a,b,stiffness[e],damping[e])]
    text += ['</deformable></mujoco>']
    return ''.join(text)


def payload(pos, vel, mass, pin, edges, rest, stiffness, damping, applied, gravity, dt, steps):
    rows = [[len(pos),len(edges),steps,dt,*gravity]]
    rows += [[mass[v],int(pin[v]),*pos[v],*vel[v],*applied[v]] for v in range(len(pos))]
    rows += [[a+1,b+1,rest[e],stiffness[e],damping[e]] for e,(a,b) in enumerate(edges)]
    return '\n'.join(' '.join(map(str,row)) for row in rows)+'\n'


def parse(text):
    result = {}
    for line in text.splitlines():
        key,*fields = line.split()
        if key in ('forces','step'):
            result[key]=fields[0]
        else:
            result.setdefault(key,[]).append(list(map(float,fields)))
    return result


def run_case(exe, out, rng, n, mode, sample):
    base = rng.uniform(-.3,.3,(n,3))
    mass = rng.uniform(.2,2,n)
    pin = np.zeros(n,dtype=bool)
    if mode != 'free': pin[0]=True
    if mode == 'pinned': pin[:]=True
    if mode == 'empty': edges=[]
    elif mode == 'ring': edges=[(i,(i+1)%n) for i in range(n)]
    elif mode == 'grid':
        width=max(2,int(np.sqrt(n)))
        edges=[(i,i+1) for i in range(n-1) if (i+1)%width]
        edges += [(i,i+width) for i in range(n-width)]
    elif mode == 'star': edges=[(0,i) for i in range(1,n)]
    elif mode == 'disconnected': edges=[(i,i+1) for i in range(0,n-1,2)]
    else: edges=[(i,i+1) for i in range(n-1)]
    k = rng.uniform(3,30,len(edges)); damp=rng.uniform(.03,.3,len(edges))
    if mode == 'spring': damp[:]=0
    if mode == 'damper': k[:]=0
    if mode == 'disabled': k[:]=0; damp[:]=0
    if mode == 'light': mass[:]=1e-15; k*=1e-15; damp*=1e-15
    gravity = np.array([.2,-.1,-9.81]); dt=.0005
    xml = xml_model(base,mass,pin,edges,k,damp,gravity,dt)
    model=mujoco.MjModel.from_xml_string(xml); data=mujoco.MjData(model)
    pos=base+rng.uniform(-.02,.02,(n,3)); pos[pin]=base[pin]
    vel=rng.uniform(-.2,.2,(n,3)); vel[pin]=0
    if mode == 'collapsed': pos[1]=pos[0]
    if mode == 'tiny': pos[1]=pos[0]+np.array([1e-16,0,0])
    applied=rng.uniform(-.3,.3,(n,3))
    if mode == 'light': applied*=1e-15
    for v in range(n):
        if pin[v]: continue
        adr=model.body_dofadr[v+1]
        data.qpos[adr:adr+3]=pos[v]-base[v]
        data.qvel[adr:adr+3]=vel[v]
        data.qfrc_applied[adr:adr+3]=applied[v]
    mujoco.mj_forward(model,data)
    # Use realized positions, including subtraction/addition rounding in C.
    pos=data.xpos[1:].copy()
    expected={key:np.zeros((n,3)) for key in ('spring','damper')}
    for v in range(n):
        if pin[v]: continue
        adr=model.body_dofadr[v+1]
        expected['spring'][v]=data.qfrc_spring[adr:adr+3]
        expected['damper'][v]=data.qfrc_damper[adr:adr+3]
    steps=100 if sample%3==0 else 1
    inp=payload(pos,vel,mass,pin,edges,model.flexedge_length0,k,damp,applied,gravity,dt,steps)
    name=f'{mode}-{n}-{sample}'
    (out/f'{name}.xml').write_text(xml); (out/f'{name}.input').write_text(inp)
    process=subprocess.run([str(exe)],input=inp,text=True,capture_output=True,check=True)
    (out/f'{name}.output').write_text(process.stdout)
    actual=parse(process.stdout)
    if actual['forces']!='SUCCESS' or actual['step']!='SUCCESS': raise AssertionError(actual)
    for _ in range(steps): mujoco.mj_step(model,data)
    mujoco.mj_kinematics(model,data)
    expected['position']=data.xpos[1:].copy(); expected['velocity']=np.zeros((n,3))
    for v in range(n):
        if not pin[v]:
            adr=model.body_dofadr[v+1]; expected['velocity'][v]=data.qvel[adr:adr+3]
    if np.any(data.warning.number):
        raise AssertionError(f'{name}: C reported a simulation warning')
    (out/f'{name}.expected.json').write_text(json.dumps(
        {key: value.tolist() for key, value in expected.items()}, indent=2))
    errors={}
    for key, value in expected.items():
        np.testing.assert_allclose(actual[key],value,rtol=2e-10,atol=2e-10,err_msg=f'{name} {key}')
        errors[key]=float(np.max(np.abs(np.array(actual[key])-value)))
    return dict(name=name,steps=steps,comparisons=n*12,max_abs_error=errors)


def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--toolchain-root',type=Path,required=True)
    ap.add_argument('--samples',type=int,default=3); ap.add_argument('--probe',type=Path)
    args=ap.parse_args()
    if mujoco.__version__ != '3.14.0':
        raise RuntimeError('The reference must be MuJoCo 3.14.0')
    args.out=args.out.resolve(); args.out.mkdir(parents=True,exist_ok=True)
    os.chdir(args.out)
    exe=args.probe or build(args.out,args.toolchain_root)
    rng=np.random.default_rng(27092026); results=[]
    for mode in ('free','pinned','empty','ring','grid','star','disconnected','spring','damper','disabled','light','collapsed','tiny'):
        for n in (2,4,8,32):
            for s in range(args.samples):
                row=run_case(exe,args.out,rng,n,mode,s); results.append(row)
                print(row['name'],'PASS',flush=True)
    # The first particle advances successfully; failure in the second must
    # roll back the entire candidate, including that first update.
    p=np.zeros((2,3)); p[1,0]=1; v=np.zeros_like(p)
    inp=payload(p,v,np.array([1e10,1e-15]),[False,False],[(0,1)],[1e9],[1e10],[0],
                np.zeros_like(p),np.zeros(3),1,1)
    result=subprocess.run([str(exe)],input=inp,text=True,capture_output=True,check=True)
    actual=parse(result.stdout); assert actual['step']=='NUMERIC_LIMIT'
    np.testing.assert_array_equal(actual['position'],p); np.testing.assert_array_equal(actual['velocity'],v)
    # The pinned record is preserved even if its stored velocity is nonzero.
    pin=[True,False]; v[0]=[2,-3,4]
    inp=payload(p,v,np.ones(2),pin,[],[],[],[],np.zeros_like(p),np.zeros(3),0,3)
    result=subprocess.run([str(exe)],input=inp,text=True,capture_output=True,check=True)
    actual=parse(result.stdout); assert actual['step']=='SUCCESS'
    np.testing.assert_array_equal(actual['position'],p); np.testing.assert_array_equal(actual['velocity'],v)
    # Maximum vertex capacity, empty topology: no hidden lower-size assumption.
    large=np.zeros((4096,3))
    inp=payload(large,large,np.ones(4096),np.zeros(4096,dtype=bool),[],[],[],[],
                large,np.zeros(3),0,1)
    result=subprocess.run([str(exe)],input=inp,text=True,capture_output=True,check=True)
    actual=parse(result.stdout); assert actual['step']=='SUCCESS'
    np.testing.assert_array_equal(actual['position'],large)
    # Maximum edge capacity, duplicate edges intentionally accumulate.
    p=np.array([[0.,0.,0.],[1.5,0.,0.]])
    inp=payload(p,np.zeros_like(p),np.ones(2),[False,False],[(0,1)]*4096,
      np.ones(4096),np.full(4096,2),np.zeros(4096),np.zeros_like(p),np.zeros(3),0,1)
    result=subprocess.run([str(exe)],input=inp,text=True,capture_output=True,check=True)
    actual=parse(result.stdout); assert actual['step']=='SUCCESS'
    np.testing.assert_array_equal(actual['spring'],[[4096,0,0],[-4096,0,0]])
    for invalid in ([(0,0)],[(0,2)]):
        inp=payload(p,np.zeros_like(p),np.ones(2),[False,False],invalid,[1],[2],[0],
                    np.zeros_like(p),np.zeros(3),0,1)
        result=subprocess.run([str(exe)],input=inp,text=True,capture_output=True,check=True)
        assert result.stdout.strip()=='invalid topology'
    summary=dict(boundary_cases=6,cases=len(results),comparisons=sum(r['comparisons'] for r in results),
                 atomic_failure='PASS',mujoco=mujoco.__version__,results=results)
    (args.out/'results.json').write_text(json.dumps(summary,indent=2));print(json.dumps({k:v for k,v in summary.items() if k!='results'}))
if __name__=='__main__': main()
