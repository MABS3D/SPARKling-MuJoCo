#!/usr/bin/env python3
"""Frozen build and paired whole-step xfrc experiment against pinned MuJoCo C.

The previous Ada build is compared only on the absent-load profile: it does not
implement body loads. Requires the project's pinned GNAT tools and Python env.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys

import mujoco
import numpy as np

REPO = Path(__file__).resolve().parents[3]
sys.path.insert(0, str(REPO / 'experimental/smooth/tools'))
from prove_fragments import isolated_project
from compare_numerics import reference
spec = importlib.util.spec_from_file_location('movement', REPO/'tests/movement_performance/run.py')
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def save(path, obj):
    path.write_text(json.dumps(obj, indent=2) + '\n')


def build(a):
    out = a.out.resolve()
    out.mkdir(parents=True, exist_ok=False)
    previous = json.loads((a.previous/'build.json').read_text())
    baseline = previous['builds']['current'].copy()
    assert digest(baseline['binary']) == baseline['binary_sha256']
    src = out/'source'
    paths = [p for d in ['src', 'experimental/smooth/src'] for p in (REPO/d).rglob('*.ad?')]
    paths += [REPO/'tests/movement_performance/movement_bench.adb', REPO/'tests/movement_performance/movement_c.c']
    for p in paths:
        dest = src/p.relative_to(REPO)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest)
    hashes = {str(p.relative_to(src)): digest(p) for p in src.rglob('*') if p.is_file()}
    assert all(digest(p) == hashes[str(p.relative_to(REPO))] for p in paths)
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((a.toolchain_root/t).glob('*/bin'))) for t in ('gnat','gprbuild','gnatprove'))+':'+env['PATH']
    project = isolated_project(src, out, 'movement_bench')
    text = project.read_text().replace('project Fragment is', 'project Fragment is\n   for Main use ("movement_bench.adb");\n   for Exec_Dir use "bin";')
    start = text.index('        ("-gnat2022"'); stop = text.index(';', start)
    flags = ['-gnat2022','-gnatn','-gnatp',*h.FLAGS]
    text = text[:start]+'('+', '.join('"'+f+'"' for f in flags)+')'+text[stop:]
    text = text.replace('end Fragment;', '   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n   end Linker;\nend Fragment;')
    project.write_text(text)
    cmd = ['gprbuild','-P',str(project),'-j2']
    with (out/'ada-build.log').open('w') as log:
        subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    binary = out/'bin/movement_bench'
    current = dict(binary=str(binary), binary_sha256=digest(binary), command=cmd, flags=flags)
    c = previous['builds']['c'].copy()
    assert digest(c['library']) == c['library_sha256']
    assert digest(c['cpp_runtime']) == c['cpp_runtime_sha256']
    cmd = c['command'].copy()
    cmd[cmd.index('-o')+1] = str(out/'movement_c')
    cmd = [str(src/'tests/movement_performance/movement_c.c') if x.endswith('/movement_c.c') else x for x in cmd]
    with (out/'c-build.log').open('w') as log:
        subprocess.run(cmd, env=env, stdout=log, stderr=subprocess.STDOUT, check=True)
    c.update(command=cmd, binary=str(out/'movement_c'), binary_sha256=digest(out/'movement_c'))
    save(out/'build.json', dict(builds=dict(baseline=baseline, current=current, c=c), sources=hashes,
        tools=previous['tools'], oracle=mujoco.__version__, cpu=Path('/proc/cpuinfo').read_text(),
        baseline_build=str(a.previous.resolve()), harness_sha256=digest(__file__)))
    print('Built frozen current Ada and C; verified previous Ada.', flush=True)


def measure(a):
    assert mujoco.__version__ == '3.14.0'
    assert a.blocks >= 6 and a.blocks % 6 == 0
    os.sched_setaffinity(0, {a.cpu})
    metadata = json.loads((a.out/'build.json').read_text())
    manifest = metadata['builds']
    for m in manifest.values():
        assert digest(m['binary']) == m['binary_sha256']
    assert digest(manifest['c']['library']) == manifest['c']['library_sha256']
    out = a.out/f'session{a.session}'
    out.mkdir(exist_ok=False)
    inputs = out/'inputs'; inputs.mkdir()
    save(out/'environment-start.json', dict(loadavg=os.getloadavg(),
         processes=subprocess.check_output(['ps','-eo','pid,comm,args'],text=True)))
    rng = np.random.default_rng(2026092700+a.session)
    loads_rng = np.random.default_rng(20260927)
    records, summaries = [], []
    models = ['hinge_motor','branched_multijoint','chain_12','crb_no_damping','crb_chain_24',
              'ancestor_star_24','ancestor_forest_24','ancestor_branches_24',
              'simple_hinges_6','simple_sliders_6','simple_mixed_8']
    cases = []
    for model in models:
        path = inputs/(model+'.mjb'); shutil.copy2(a.inputs/path.name, path)
        m = mujoco.MjModel.from_binary_path(str(path))
        for state in range(3):
            key = f'{model}-{state}'
            values = np.fromstring((a.inputs/(key+'.input')).read_text(), sep=' ')
            assert len(values) == 3*m.nv+m.nu
            q, v, ctrl, applied = np.split(values, [m.nq, 2*m.nv, 2*m.nv+m.nu])
            for profile in ['absent','zero','sparse','dense']:
                loads = None if profile == 'absent' else np.zeros((m.nbody,6))
                if profile == 'sparse': loads[-1] = loads_rng.uniform(-.3,.3,6)
                if profile == 'dense': loads[1:] = loads_rng.uniform(-.3,.3,(m.nbody-1,6))
                data = np.concatenate((values, loads.ravel())) if loads is not None else values
                data = ' '.join(format(float(x),'.17g') for x in data)+'\n'
                case = key+'-'+profile
                (inputs/(case+'.input')).write_text(data)
                want = reference(m,q,v,ctrl,applied,.125,100,loads)
                expected = {k: want[k].tolist() for k in ('qpos','qvel','time')}
                save(inputs/(case+'.expected.json'),expected)
                cases.append((case,model,profile,path,data,expected))
    # All reference calculations and fixture preparation precede timing.
    for idx in rng.permutation(len(cases)):
        case,model,profile,path,data,expected = cases[idx]
        variants = ['baseline','current','c'] if profile == 'absent' else ['current','c']
        timings = {v:[] for v in variants}; errors = {v:0. for v in variants}
        for block in range(a.blocks):
            if block % len(variants) == 0:
                permutation = list(rng.permutation(variants))
                rotations = list(rng.permutation(len(variants)))
            shift = rotations[block % len(variants)]
            order = permutation[shift:]+permutation[:shift]; outputs = {}
            for v in order:
                cmd = [manifest[v]['binary'],str(path),'100','4','2']
                if profile != 'absent': cmd.append('external')
                run = subprocess.run(cmd,input=data,text=True,capture_output=True,timeout=60)
                run.check_returncode(); rows = h.parse(run.stdout); assert len(rows) == 4
                for row in rows:
                    assert row['seconds'] > 0 and np.isfinite(row['seconds'])
                    for field,want in expected.items():
                        got,ref = np.asarray(row[field]),np.asarray(want)
                        err = abs(got-ref)
                        assert got.shape == ref.shape and np.all(err <= 2e-10+2e-10*abs(ref)), (case,v,field,err)
                        errors[v] = max(errors[v],float(np.max(err,initial=0)))
                outputs[v] = rows
                timings[v].append(float(np.median([r['seconds']*1e7 for r in rows])))
                records.append(dict(case=case,block=block,variant=v,order=order,rows=rows,loadavg=os.getloadavg()))
            if profile == 'absent':
                for r,b in zip(outputs['current'],outputs['baseline']):
                    for field in expected: assert r[field] == b[field], (case,'Ada changed',field)
        summary = dict(case=case,model=model,profile=profile,timings_ns=timings,
                       stats_ns={v:h.stats(timings[v]) for v in variants},
                       ratio_to_c=h.ratio(timings['current'],timings['c'],rng), max_c_error=errors)
        if profile == 'absent': summary['ratio_to_baseline'] = h.ratio(timings['current'],timings['baseline'],rng)
        summaries.append(summary)
        save(out/'measurements.json',dict(complete=False,summary=summaries))
        print(case,round(summary['ratio_to_c']['median'],3),flush=True)
    save(out/'environment-end.json', dict(loadavg=os.getloadavg(),
         processes=subprocess.check_output(['ps','-eo','pid,comm,args'],text=True)))
    save(out/'measurements.json',dict(complete=True,session=a.session,blocks=a.blocks,cpu=a.cpu,steps=100,
         samples=4,warmups=2,seed=2026092700+a.session,manifest=manifest,summary=summaries,records=records,
         input_sha256={p.name:digest(p) for p in inputs.iterdir()}))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--build',action='store_true')
    p.add_argument('--previous',type=Path)
    p.add_argument('--toolchain-root',type=Path)
    p.add_argument('--inputs',type=Path)
    p.add_argument('--session',type=int,default=1)
    p.add_argument('--blocks',type=int,default=24)
    p.add_argument('--cpu',type=int,default=12)
    a = p.parse_args()
    if a.build:
        if not a.previous or not a.toolchain_root: p.error('build requires --previous and --toolchain-root')
        build(a)
    else:
        if not a.inputs: p.error('measurement requires --inputs')
        measure(a)

if __name__ == '__main__': main()
