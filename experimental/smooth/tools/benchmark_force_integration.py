#!/usr/bin/env python3
"""Complete 64-step trajectories, owned Ada state versus official MuJoCo C/SIMD."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess
import sys
import tempfile
import numpy as np
import mujoco as mj
from prove_fragments import isolated_project, source_files
from test_actuation_integration import fixtures


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--toolchain-root', type=Path, required=True)
    ap.add_argument('--batches', type=int, default=128)
    ap.add_argument('--blocks', type=int, default=8)
    args = ap.parse_args()
    if args.batches < 1 or args.blocks < 3: ap.error('positive batches and at least 3 blocks required')
    assert mj.__version__ == '3.14.0', mj.__version__
    repo = Path(__file__).resolve().parents[3]
    args.out.mkdir(parents=True, exist_ok=False)
    work = Path(tempfile.mkdtemp(prefix='sparkling-force-benchmark-'))
    snap = work/'source'
    hashes = {}
    driver = repo/'experimental/smooth/tests/force-integration'
    for path in [*source_files(repo), *driver.glob('force_step_benchmark.*')]:
        rel = path.relative_to(repo)
        dst = snap/rel
        dst.parent.mkdir(parents=True, exist_ok=True)
        dst.write_bytes(path.read_bytes())
        hashes[str(rel)] = digest(dst)
    assert all(digest(repo/p) == v for p, v in hashes.items()), 'concurrent source edit'
    project = isolated_project(snap, work, 'force_step_benchmark')
    text = project.read_text().replace('project Fragment is', 'project Fragment is\n   for Main use ("force_step_benchmark.adb");\n   for Exec_Dir use "bin";\n   package Linker is\n      for Default_Switches ("Ada") use ("-flto", "-ffp-contract=off");\n   end Linker;')
    text = text.replace('"-O0", "-g", "-gnata", "-gnato", "-gnatVa"', '"-O3", "-gnatp", "-gnatn", "-march=native", "-flto"')
    project.write_text(text)
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(p) for t in ('gnat','gprbuild','gnatprove') for p in (args.toolchain_root/t).glob('*/bin'))+':'+env['PATH']
    with (args.out/'build.log').open('w') as log:
        subprocess.run(['python3', str(repo/'tools/guarded.py'), '--cap-mb','3000', '--min-free-mb','12000','--timeout','360','--', 'gprbuild', '-P',str(project),'-j2'], env=env, stdout=log, stderr=subprocess.STDOUT,check=True)
    lib = next(Path(mj.__file__).parent.glob('libmujoco.so*'))
    ada = work/'bin/force_step_benchmark'
    c = work/'force_step_c'
    command = ['gcc','-O3','-march=native','-flto','-ffp-contract=off', str(snap/driver.relative_to(repo)/'force_step_benchmark.c'), '-I'+str(repo/'mujoco/include'), '-Wl,-rpath,'+str(lib.parent),str(lib),'-lm','-o',str(c)]
    subprocess.run(command,env=env,check=True)
    cpu = max(os.sched_getaffinity(0))
    # Constrain this benchmark and its children only; leave other tasks untouched.
    os.sched_setaffinity(0,{cpu})
    models = {}
    for fluid, fixed, names in [
        ('none', False, ['slide-integrator-False-normal-False', 'ball-filterexact-True-normal-True', 'free-muscle-True-normal-True']),
        ('ellipsoid', True, ['slide-muscle-True-normal-True', 'ball-muscle-True-normal-True', 'free-filterexact-True-normal-True'])]:
        for name, xml in fixtures(fluid, fixed):
            if name in names: models[f'{fluid}-{fixed}-{name}'] = xml
    rows = []
    rng = np.random.default_rng(20261002)
    for name, xml in models.items():
        m = mj.MjModel.from_xml_string(xml)
        path = args.out/(name+'.mjb')
        mj.mj_saveModel(m,str(path))
        (args.out/(name+'.xml')).write_text(xml)
        samples = {side:[] for side in ('ada','c')}
        raw = []
        checksums = {}
        for block in range(args.blocks+1):
            for side in (('ada','c') if block % 2 == 0 else ('c','ada')):
                run = subprocess.run([str(ada if side=='ada' else c),str(path),str(args.batches)],capture_output=True,text=True,check=True,timeout=90)
                (args.out/f'{name}-{block}-{side}.txt').write_text(run.stdout)
                values = np.fromstring(run.stdout,sep=' ')
                assert len(values)==1+2*args.batches
                checksums[side] = values[0]
                wall = values[1:1+args.batches]*1e6/64
                cpu_times = values[1+args.batches:]*1e6/64
                if block:
                    samples[side].append(float(wall.mean()))
                    raw.append(dict(block=block,side=side,wall_us=wall.tolist(),cpu_us=cpu_times.tolist(),p95_us=float(np.percentile(wall,95))))
            np.testing.assert_allclose(checksums['ada'],checksums['c'],atol=2e-9,rtol=2e-9)
        ratios = np.array(samples['ada'])/samples['c']
        boot = np.median(rng.choice(ratios,(10000,len(ratios)),replace=True),axis=1)
        row = dict(model=name,nq=m.nq,nv=m.nv,tendons=m.ntendon,activation=m.na,
            median_ada_us=statistics.median(samples['ada']),median_c_us=statistics.median(samples['c']),
            median_paired_ratio=float(np.median(ratios)),ratio_ci95=np.quantile(boot,[.025,.975]).tolist(),
            wall_block_means=samples,raw=raw,checksums=checksums)
        rows.append(row)
        print(name,row['median_ada_us'],row['median_c_us'],row['median_paired_ratio'],row['ratio_ci95'],flush=True)
    data = dict(oracle=mj.__version__,steps=64,batches=args.batches,blocks=args.blocks,warmup_blocks=1,
        source_sha256=hashes,ada=str(ada),ada_sha256=digest(ada),c=str(c),c_sha256=digest(c),project=text,
        c_library=str(lib),c_library_sha256=digest(lib),c_driver_command=command,
        compiler=subprocess.check_output(['gcc','--version'],env=env,text=True).splitlines()[0],
        platform=platform.uname()._asdict(),logical_cpu=cpu,
        cpu_info=Path('/proc/cpuinfo').read_text().split('\n\n')[0],
        scope='Complete Euler trajectories; reset, inputs and readback outside timing. Shared host. Official wheel SIMD enabled. No pre-integration baseline for formerly unsupported models.',
        results=rows)
    (args.out/'results.json').write_text(json.dumps(data,indent=2)+'\n')

if __name__=='__main__': main()
