#!/usr/bin/env python3
"""Whole-step experiment: original smooth math, bridged Gold kernels, native C.

Requires mujoco==3.14.0, numpy, native GNAT and a matching native C library.
No result constitutes a full-engine performance or formal assurance claim.
"""
from __future__ import annotations
import argparse
import hashlib
import itertools
import json
import os
from pathlib import Path
import platform
import shutil
import subprocess
import sys

import mujoco
import numpy as np

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[1]
sys.path.insert(0, str(REPO / 'experimental/smooth/tools'))
from prove_fragments import isolated_project
from compare_numerics import fixtures, reference

FLAGS = ['-O3', '-march=native', '-flto', '-ffat-lto-objects',
         '-ffp-contract=off', '-ffinite-math-only', '-fno-trapping-math',
         '-fno-math-errno', '-ffunction-sections', '-fdata-sections']


def digest(p):
    return hashlib.sha256(Path(p).read_bytes()).hexdigest()


def save(p, value):
    p.write_text(json.dumps(value, indent=2) + '\n')


def command(args, log, env):
    with log.open('w') as f:
        subprocess.run(args, stdout=f, stderr=subprocess.STDOUT, env=env,
                       check=True, timeout=600)


def build(out, env, library):
    snapshot = out / 'source'
    snapshot.mkdir()
    paths = list((REPO / 'src').rglob('*.ad?'))
    paths += list((REPO / 'experimental/smooth/src').glob('*.ad?'))
    paths += [REPO / 'experimental/smooth/tests/smooth_probe.adb',
              HERE / 'movement_bench.adb']
    hashes = {}
    for p in paths:
        dest = snapshot / p.relative_to(REPO)
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(p, dest)
        hashes[str(p.relative_to(REPO))] = digest(dest)
    if any(digest(p) != hashes[str(p.relative_to(REPO))] for p in paths):
        raise RuntimeError('sources changed during snapshot')
    shutil.copytree(HERE, out / 'harness', ignore=shutil.ignore_patterns('evidence', '__pycache__'))
    binaries, builds = {}, {}
    for variant in ('baseline', 'current', 'checked'):
        work = out / variant
        work.mkdir()
        sources = work / 'source'
        shutil.copytree(snapshot, sources)
        # Keep the measured bridge available as an experiment after rejection.
        math_variant = 'baseline' if variant == 'baseline' else 'candidate'
        shutil.copy2(HERE / math_variant / 'mj-smooth_math.adb',
                     sources / 'experimental/smooth/src/mj-smooth_math.adb')
        main = 'smooth_probe' if variant == 'checked' else 'movement_bench'
        project = isolated_project(sources, work, main)
        text = project.read_text().replace('project Fragment is',
            f'project Fragment is\n   for Main use ("{main}.adb");\n'
            '   for Exec_Dir use "bin";')
        flags = ['-gnat2022', '-O0', '-g', '-gnata', '-gnato', '-gnatVa', '-ffp-contract=off']
        if variant != 'checked':
            flags = ['-gnat2022', '-gnatn', '-gnatp', *FLAGS]
            a = text.index('        ("-gnat2022"')
            b = text.index(';', a)
            text = text[:a] + '(' + ', '.join('"'+f+'"' for f in flags) + ')' + text[b:]
            text = text.replace('end Fragment;', '   package Linker is\n'
                '      for Default_Switches ("Ada") use ("-flto", "-Wl,--gc-sections");\n'
                '   end Linker;\nend Fragment;')
        project.write_text(text)
        cmd = ['gprbuild', '-P', str(project), '-j2']
        command(cmd, work / 'build.log', env)
        binary = work / 'bin' / main
        binaries[variant] = binary
        builds[variant] = dict(command=cmd, flags=flags, binary_sha256=digest(binary),
            math_sha256=digest(sources / 'experimental/smooth/src/mj-smooth_math.adb'))
    binary = out / 'movement_c'
    cpp_runtime = Path(subprocess.check_output(['g++', '-print-file-name=libstdc++.so'], env=env, text=True).strip()).resolve()
    cmd = ['gcc', '-std=c11', *FLAGS, '-I'+str(Path(mujoco.__file__).parent / 'include'),
           str(HERE / 'movement_c.c'), str(library), str(cpp_runtime),
           '-Wl,-rpath,'+str(library.parent)+':'+str(cpp_runtime.parent),
           '-o', str(binary)]
    command(cmd, out / 'c-build.log', env)
    binaries['c'] = binary
    builds['c'] = dict(command=cmd, binary_sha256=digest(binary),
                       library=str(library), library_sha256=digest(library),
                       cpp_runtime=str(cpp_runtime), cpp_runtime_sha256=digest(cpp_runtime))
    save(out / 'build.json', dict(sources=hashes, builds=builds,
         tools={t: subprocess.check_output([t, '--version'], env=env, text=True).splitlines()[0]
                for t in ('gcc', 'gprbuild', 'gnatprove')},
         oracle=mujoco.__version__, numpy=np.__version__,
         platform=platform.platform(), cpu=Path('/proc/cpuinfo').read_text(),
         harness={str(p.relative_to(HERE)): digest(p) for p in HERE.rglob('*')
                  if p.is_file() and 'evidence' not in p.parts and '__pycache__' not in p.parts}))
    return binaries


def parse(text):
    rows = []
    for line in text.splitlines():
        key, *values = line.split()
        if key == 'sample':
            rows.append(dict(seconds=float(values[0])))
        elif key in ('qpos', 'qvel', 'time'):
            rows[-1][key] = [float(x) for x in values]
        else:
            raise ValueError(line)
    return rows


def stats(values):
    x = np.asarray(values)
    median = np.median(x)
    return dict(median=float(median), mad=float(np.median(abs(x-median))),
                p95=float(np.quantile(x,.95)), minimum=float(min(x)), maximum=float(max(x)))


def ratio(a, b, rng):
    x = np.asarray(a)/np.asarray(b)
    boot = np.median(rng.choice(x, size=(10000, len(x))), axis=1)
    return dict(median=float(np.median(x)), ci95=[float(t) for t in np.quantile(boot,[.025,.975])])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--toolchain-root', type=Path, required=True)
    parser.add_argument('--c-library', type=Path, required=True)
    parser.add_argument('--blocks', type=int, default=24)
    parser.add_argument('--samples', type=int, default=4)
    parser.add_argument('--steps', type=int, default=100)
    parser.add_argument('--cpu', type=int, default=12)
    parser.add_argument('--build-only', action='store_true')
    parser.add_argument('--reuse-build', action='store_true')
    parser.add_argument('--ada-comparison', choices=('exact', 'tolerance'), default='exact',
                        help='Use tolerance only for an explicitly changed floating-point algorithm')
    parser.add_argument('--extra-fixtures', type=Path)
    parser.add_argument('--model', action='append', default=[], help='Select model names; repeat as needed')
    args = parser.parse_args()
    if args.blocks < 6 or args.blocks % 6 or args.samples < 1 or args.steps < 1:
        parser.error('blocks must be a positive multiple of six; samples/steps positive')
    if mujoco.__version__ != '3.14.0':
        parser.error('MuJoCo 3.14.0 required')
    out = args.out.resolve()
    env = os.environ.copy()
    env['PATH'] = ':'.join(str(next((args.toolchain_root / t).glob('*/bin')))
                          for t in ('gnat', 'gprbuild', 'gnatprove')) + ':' + env['PATH']
    if args.reuse_build:
        binaries = {v: out / v / 'bin/movement_bench' for v in ('baseline','current')}
        binaries['c'] = out / 'movement_c'
        recorded = json.loads((out / 'build.json').read_text())
        for v, p in binaries.items():
            if digest(p) != recorded['builds'][v]['binary_sha256']:
                raise RuntimeError('binary changed: '+v)
        if digest(args.c_library) != recorded['builds']['c']['library_sha256']:
            raise RuntimeError('C library changed')
    else:
        out.mkdir(parents=True, exist_ok=False)
        binaries = build(out, env, args.c_library.resolve())
    if args.build_only:
        return
    rawdir = out / 'timings'
    rawdir.mkdir(exist_ok=False)
    os.sched_setaffinity(0, {args.cpu})
    rng = np.random.default_rng(20260924)
    records, summary = [], []
    orders = list(itertools.permutations(('baseline','current','c')))
    # Balanced first-position/precedence over every six process-level blocks.
    model_names = args.model or ['hinge_motor', 'branched_multijoint', 'chain_12']
    model_xmls = fixtures()
    if args.extra_fixtures:
        for path in sorted(args.extra_fixtures.glob('*.xml')):
            if path.stem in model_xmls:
                parser.error('extra fixture shadows a built-in case: '+path.stem)
            model_xmls[path.stem] = path.read_text()
    if len(set(model_names)) != len(model_names) or any(name not in model_xmls for name in model_names):
        parser.error('model names must exist and be unique')
    for name in model_names:
        xml = model_xmls[name]
        (rawdir / (name+'.xml')).write_text(xml)
        m = mujoco.MjModel.from_xml_string(xml)
        path = rawdir / (name+'.mjb')
        mujoco.mj_saveModel(m,str(path))
        for state in range(3):
            key = f'{name}-{state}'
            q=m.qpos0+rng.uniform(-.25,.25,m.nq)
            v=rng.uniform(-.5,.5,m.nv)
            ctrl=rng.uniform(-.4,.4,m.nu)
            applied=rng.uniform(-.1,.1,m.nv)
            data=' '.join(format(x,'.17g') for x in np.concatenate((q,v,ctrl,applied)))+'\n'
            (rawdir / (key+'.input')).write_text(data)
            expected = reference(m,q,v,ctrl,applied,.125,args.steps)
            save(rawdir / (key+'.expected.json'),
                 {k: expected[k].tolist() for k in ('qpos','qvel','time')})
            timings={v: [] for v in ('baseline','current','c')}
            all_steps={v: [] for v in timings}
            max_error=0.
            max_ada_error=0.
            for block in range(args.blocks):
                if block % 6 == 0:
                    rng.shuffle(orders)
                order=orders[block%6]
                block_outputs={}
                for variant in order:
                    cmd=[str(binaries[variant]),str(path),str(args.steps),str(args.samples),'2']
                    run=subprocess.run(cmd,input=data,text=True,capture_output=True,timeout=60)
                    (rawdir / f'{key}-{block}-{variant}.txt').write_text(run.stdout+run.stderr)
                    run.check_returncode()
                    rows=parse(run.stdout)
                    if len(rows) != args.samples:
                        raise AssertionError('incomplete samples')
                    for row in rows:
                        if not np.isfinite(row['seconds']) or row['seconds'] <= 0:
                            raise AssertionError('invalid duration')
                        for field in ('qpos','qvel','time'):
                            actual=np.asarray(row[field]); ref=expected[field]
                            error=abs(actual-ref)
                            if actual.shape != ref.shape or not np.all(error <= 2e-10+2e-10*abs(ref)):
                                raise AssertionError((key,variant,field,actual,ref))
                            max_error=max(max_error,float(max(error,default=0)))
                    block_outputs[variant]=rows
                    ns=[row['seconds']*1e9/args.steps for row in rows]
                    timings[variant].append(float(np.median(ns)))
                    all_steps[variant].extend(ns)
                    records.append(dict(case=key,block=block,variant=variant,order=order,rows=rows))
                for a,b in zip(block_outputs['baseline'],block_outputs['current']):
                    for field in ('qpos','qvel','time'):
                        av, bv = np.asarray(a[field]), np.asarray(b[field])
                        error = abs(av-bv)
                        max_ada_error = max(max_ada_error, float(max(error, default=0)))
                        if args.ada_comparison == 'exact':
                            if a[field] != b[field]:
                                raise AssertionError(('Ada exact comparison failed',key,field))
                        elif av.shape != bv.shape or not np.all(error <= 2e-10+2e-10*abs(av)):
                            raise AssertionError(('Ada tolerance comparison failed',key,field))
            item=dict(case=key,nv=m.nv,nbody=m.nbody,nu=m.nu,steps=args.steps,
                nanoseconds_per_step={v:stats(x) for v,x in all_steps.items()},
                current_over_baseline=ratio(timings['current'],timings['baseline'],rng),
                current_over_c=ratio(timings['current'],timings['c'],rng),
                baseline_over_c=ratio(timings['baseline'],timings['c'],rng),
                max_absolute_error=max_error, max_ada_absolute_error=max_ada_error)
            summary.append(item)
            save(out / 'measurements.json',dict(complete=False,records=records,summary=summary))
            print(key, 'current/base', item['current_over_baseline'],
                  'current/C',item['current_over_c'],flush=True)
    save(out / 'measurements.json',dict(complete=True,seed=20260924,
        command=sys.argv,cpu=args.cpu,blocks=args.blocks,samples=args.samples,
        ada_comparison=args.ada_comparison,atol=2e-10,rtol=2e-10,
        measurement_harness_sha256={str(p.relative_to(REPO)):digest(p) for p in
            [Path(__file__), REPO/'experimental/smooth/tools/compare_numerics.py']},
        uncertainty='paired block-median ratios, bootstrap 95%; within session; no multiplicity correction',
        tail_scope='p95 of trajectory-average step cost, not individual-step latency',
        records=records,summary=summary))


if __name__ == '__main__':
    main()
