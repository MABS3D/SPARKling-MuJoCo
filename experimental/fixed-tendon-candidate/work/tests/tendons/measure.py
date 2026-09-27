#!/usr/bin/env python3
"""Frozen release builds and paired full Euler trajectories against pinned C.

New tendon workloads have no pre-change Ada implementation. The baseline is
therefore measured only on workloads without tendons, never as a fictitious
zero-cost or reduced-physics tendon comparator.
"""
import argparse, hashlib, importlib.util, json, os, platform, shutil, subprocess, sys
from pathlib import Path
import mujoco
import numpy as np
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'experimental/smooth/tools'))
from prove_fragments import isolated_project
from compare_numerics import fixtures, reference
spec=importlib.util.spec_from_file_location('movement',ROOT/'tests/movement_performance/run.py')
movement=importlib.util.module_from_spec(spec);spec.loader.exec_module(movement)
FLAGS=['-gnat2022','-gnatn','-gnatp','-O3','-march=native','-flto','-ffat-lto-objects',
       '-ffp-contract=off','-ffinite-math-only','-fno-trapping-math','-fno-math-errno',
       '-ffunction-sections','-fdata-sections']
def digest(p): return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save(p,x): Path(p).write_text(json.dumps(x,indent=2)+'\n')
def build(a):
    out=a.build.resolve();out.mkdir(parents=True,exist_ok=False)
    env=os.environ.copy();env['PATH']=':'.join(str(next((a.toolchain/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
    ref=json.loads((a.reference/'build.json').read_text())['builds']['c']
    cb=a.reference/'movement_c'
    assert digest(cb)==ref['binary_sha256'] and digest(ref['library'])==ref['library_sha256']
    meta=dict(c=ref,flags=FLAGS,platform=platform.platform(),cpu=Path('/proc/cpuinfo').read_text(),
              baseline_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
              compiler=subprocess.check_output(['gcc','--version'],env=env,text=True), builds={})
    snap=out/'snapshot';snap.mkdir()
    files=[p for d in ('src','experimental/smooth/src') for p in (ROOT/d).rglob('*.ad?')]
    files += [ROOT/'tests/movement_performance/movement_bench.adb']
    for p in files:
        target=snap/p.relative_to(ROOT);target.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,target)
    for variant in ['baseline','current']:
        work=out/variant;src=work/'source';shutil.copytree(snap,src)
        if variant=='baseline':
            for p in src.rglob('*.ad?'):
                rel=str(p.relative_to(src))
                old=subprocess.run(['git','show','HEAD:'+rel],cwd=ROOT,capture_output=True)
                if old.returncode==0: p.write_bytes(old.stdout)
        project=isolated_project(src,work,'movement_bench')
        txt=project.read_text().replace('project Fragment is','project Fragment is\n   for Main use ("movement_bench.adb");\n   for Exec_Dir use "bin";')
        start=txt.index('        ("-gnat2022"');stop=txt.index(';',start)
        txt=txt[:start]+'('+','.join('"'+f+'"' for f in FLAGS)+')'+txt[stop:]
        txt=txt.replace('end Fragment;', '   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
        project.write_text(txt)
        cmd=['gprbuild','-P',str(project),'-j2']
        with (work/'build.log').open('w') as log: subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
        binary=work/'bin/movement_bench'
        meta['builds'][variant]=dict(binary=str(binary),sha256=digest(binary),command=cmd,
             sources={str(p.relative_to(src)):digest(p) for p in src.rglob('*.ad?')})
        print('built',variant,flush=True)
    (out/'movement_c').symlink_to(cb.resolve())
    save(out/'build.json',meta)
def measure(a):
    assert mujoco.__version__=='3.14.0'
    load_start=os.getloadavg()
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    meta=json.loads((a.build/'build.json').read_text())
    bins={k:Path(v['binary']) for k,v in meta['builds'].items()}
    for k,p in bins.items(): assert digest(p)==meta['builds'][k]['sha256']
    bins['c']=a.build/'movement_c';assert digest(bins['c'])==meta['c']['binary_sha256']
    assert digest(meta['c']['library'])==meta['c']['library_sha256']
    os.sched_setaffinity(0,{a.cpu});rng=np.random.default_rng(20260927)
    cases=fixtures();cases.update({p.stem:p.read_text() for p in (ROOT/'tests/tendons/fixtures').glob('*.xml')})
    cases.update({p.stem:p.read_text() for p in (ROOT/'tests/tendons/performance-fixtures').glob('*.xml')})
    names=a.model or ['tendon_scalar','tendon_chain_6','tendon_branches_6','tendon_nonlinear','tendon_chain_24','hinge_motor','branched_multijoint','chain_24_without_tendons']
    rows=[];summary=[]
    for name in names:
        xml=cases[name];(out/(name+'.xml')).write_text(xml)
        m=mujoco.MjModel.from_xml_string(xml);path=out/(name+'.mjb');mujoco.mj_saveModel(m,str(path))
        variants=['current','c'] if m.ntendon else ['baseline','current','c']
        for state in range(a.states):
            q=m.qpos0+rng.uniform(-.25,.25,m.nq);v=rng.uniform(-.5,.5,m.nv)
            u=rng.uniform(-.4,.4,m.nu);f=rng.uniform(-.1,.1,m.nv)
            data=' '.join(format(float(x),'.17g') for x in np.concatenate((q,v,u,f)))+'\n'
            key=f'{name}-{state}';(out/(key+'.input')).write_text(data)
            expected=reference(m,q,v,u,f,.125,a.steps)
            times={k:[] for k in variants};all_times={k:[] for k in variants}
            for block in range(a.blocks):
                order=variants if block%2==0 else list(reversed(variants))
                for variant in order:
                    cmd=[str(bins[variant]),str(path),str(a.steps),str(a.samples),'2']
                    run=subprocess.run(cmd,input=data,text=True,capture_output=True,timeout=60)
                    (out/f'{key}-{block}-{variant}.txt').write_text(run.stdout+run.stderr);run.check_returncode()
                    samples=movement.parse(run.stdout);assert len(samples)==a.samples
                    for sample in samples:
                        assert np.isfinite(sample['seconds']) and sample['seconds']>0
                        for field in ['qpos','qvel','time']:
                            got=np.asarray(sample[field]);want=expected[field]
                            assert got.shape==want.shape and np.all(np.isfinite(got)) and np.all(abs(got-want)<=2e-10+2e-10*abs(want)),(key,variant,field,got,want)
                    ns=[s['seconds']*1e9/a.steps for s in samples]
                    times[variant].append(float(np.median(ns)));all_times[variant].extend(ns)
                    rows.append(dict(case=key,block=block,variant=variant,order=order,samples=samples,
                                     loadavg=os.getloadavg()))
            result=dict(case=key,nv=m.nv,ntendon=m.ntendon,ns_per_step={k:movement.stats(v) for k,v in all_times.items()},
                        current_over_c=movement.ratio(times['current'],times['c'],rng))
            if 'baseline' in variants: result['current_over_baseline']=movement.ratio(times['current'],times['baseline'],rng)
            summary.append(result);print(key,result['current_over_c'],flush=True)
            save(out/'measurements.json',dict(complete=False,summary=summary,records=rows))
    save(out/'measurements.json',dict(complete=True,summary=summary,records=rows,command=sys.argv,
         build=str(a.build.resolve()),build_sha256=digest(a.build/'build.json'),cpu=a.cpu,
         steps=a.steps,blocks=a.blocks,samples=a.samples,states=a.states,
         loadavg_start=load_start,loadavg_end=os.getloadavg(),runner_sha256=digest(__file__),
         uncertainty='paired block medians, bootstrap 95%; within-session only',
         tails='p95 of trajectory-average step time, not individual-step latency',
         acceptance='requires repeat in a quiet session; measurements alone do not establish Gold'))
if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--build',type=Path,required=True)
    p.add_argument('--toolchain',type=Path);p.add_argument('--reference',type=Path);p.add_argument('--build-only',action='store_true')
    p.add_argument('--out',type=Path);p.add_argument('--cpu',type=int,default=12);p.add_argument('--blocks',type=int,default=12)
    p.add_argument('--samples',type=int,default=4);p.add_argument('--steps',type=int,default=200);p.add_argument('--states',type=int,default=3)
    p.add_argument('--model',action='append');a=p.parse_args()
    if a.blocks<2 or a.blocks%2 or min(a.steps,a.samples,a.states)<1: p.error('positive sizes and even block count required')
    if a.build_only:
        if not a.toolchain or not a.reference:p.error('build requires toolchain and reference')
        build(a)
    else:
        if not a.out:p.error('measurement requires out')
        measure(a)
