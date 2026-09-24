#!/usr/bin/env python3
"""Alternating C/Ada kernel samples with preparation outside both clocks."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import math
import os
from pathlib import Path
import platform
import random
import statistics
import subprocess
from reference import validate

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent
NAMES = {
    1: 'quaternion', 2: 'quaternion_in_place',
    3: 'conjugate', 4: 'conjugate_in_place',
    5: 'matrix', 6: 'matrix_in_place',
    7: 'transpose', 8: 'transpose_in_place',
}

def source_hashes():
    paths = [*sorted((ROOT/'src').glob('*.ad?')),
             *(HERE/name for name in ('adapter.ads','adapter.adb','driver.c',
                                      'main.adb','checks.gpr','measure.py','reference.json')),
             ROOT/'mujoco/src/engine/engine_util_spatial.c',
             ROOT/'mujoco/src/engine/engine_util_blas.c']
    return {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest()
            for p in paths}

def write_report(path, report):
    temporary = path.with_suffix(path.suffix+'.tmp')
    temporary.write_text(json.dumps(report,indent=2)+'\n')
    temporary.replace(path)

def main():
    reference = validate()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--pairs',type=int,default=31)
    parser.add_argument('--ms',type=float,default=25)
    parser.add_argument('--cpu',type=int)
    parser.add_argument('--ops',default='1,2,3,4,5,6,7,8')
    parser.add_argument('--patterns',default='0,1,2,3,4,5,6,7')
    parser.add_argument('--output',type=Path,default=HERE/'measurements.json')
    args = parser.parse_args()
    operations = list(map(int,args.ops.split(',')))
    patterns = list(map(int,args.patterns.split(',')))
    assert args.pairs>=5 and args.ms>0
    assert len(set(operations))==len(operations) and set(operations)<=NAMES.keys()
    assert len(set(patterns))==len(patterns) and set(patterns)<=set(range(8))
    cpu = args.cpu if args.cpu is not None else min(os.sched_getaffinity(0))
    os.sched_setaffinity(0,{cpu})
    binary = HERE/'build/release/bin/main'
    results = []
    report = {
        'complete':False, 'recorded_at_utc':datetime.now(timezone.utc).isoformat(),
        'requested_operations':operations, 'requested_patterns':patterns,
        'fixture':{
            'batch_vectors':32768,
            'preparation':'identical C initialization outside both clocks; each output slot visited once',
            'checksum':'all outputs outside both clocks',
            'context_switch_scope':'whole sample including preparation and checksum',
        },
        'platform':platform.platform(), 'cpu':cpu,
        'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0],
        'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),
        'source_sha256':source_hashes(),
        'build_flags':{
            'common':['-O3','-march=native','-flto','-ffat-lto-objects','-ffp-contract=off',
                      '-ffinite-math-only','-fno-trapping-math','-fno-math-errno',
                      '-ffunction-sections','-fdata-sections'],
            'ada':['-gnat2022','-gnatn','-gnatp'],
            'c':['-std=gnu11','-DmjUSEPLATFORMSIMD'],
        },
        'compiler':subprocess.check_output(['readelf','-p','.comment',str(binary)],text=True),
        'gprbuild':subprocess.check_output(['gprbuild','--version'],text=True).splitlines()[0],
        'reference':'MuJoCo 3.14.0 '+reference,
        'pairs':args.pairs, 'target_ms':args.ms, 'results':results,
    }
    rng = random.Random(20260923)

    def sample(backend,op,reps,pattern):
        row = json.loads(subprocess.check_output(
            [str(binary),str(backend),str(op),str(reps),str(pattern)],text=True))
        assert row['cpu_ns']>0 and row['wall_ns']>0 and math.isfinite(row['sink'])
        return row

    try:
        for op in operations:
            for pattern in patterns:
                probes = [sample(b,op,200000,pattern) for b in (0,1)]
                reps = max(1000,min(50000000,int(
                    200000*args.ms*1e6/min(p['cpu_ns'] for p in probes))))
                pairs = []
                report['current_case'] = {'op':op,'pattern':pattern,'reps':reps,'samples':pairs}
                for k in range(args.pairs):
                    pair = {b:sample(b,op,reps,pattern)
                            for b in ((0,1) if k%2==0 else (1,0))}
                    assert pair[0]['sink']==pair[1]['sink'],(op,pattern,pair)
                    pairs.append(pair)
                ratios = [p[1]['cpu_ns']/p[0]['cpu_ns'] for p in pairs]
                draws = sorted(statistics.median(rng.choices(ratios,k=len(ratios)))
                               for _ in range(5000))
                median = statistics.median(ratios)
                lo,hi = draws[125],draws[4874]
                result = {
                    'operation':NAMES[op], 'op':op, 'pattern':pattern, 'reps':reps,
                    'ratio_ada_over_c':median,
                    'mad_ratio':statistics.median(abs(r-median) for r in ratios),
                    'bootstrap_median_95':[lo,hi],
                    'status':'slower' if lo>1 else 'faster' if hi<1 else 'within_noise',
                    'c_ns':statistics.median(p[0]['cpu_ns']/reps for p in pairs),
                    'ada_ns':statistics.median(p[1]['cpu_ns']/reps for p in pairs),
                    'samples':pairs,
                }
                results.append(result)
                report.pop('current_case')
                write_report(args.output,report)
                print(f'{NAMES[op]:20} {pattern}: {median:.3f} [{lo:.3f}, {hi:.3f}] '
                      f'{result["status"]}',flush=True)
        assert report['source_sha256']==source_hashes(), 'Sources changed during measurement'
        assert report['binary_sha256']==hashlib.sha256(binary.read_bytes()).hexdigest()
        report['complete'] = True
    finally:
        # Interrupted or failed runs retain their raw samples and remain incomplete.
        write_report(args.output,report)
    slower = sum(r['status']=='slower' for r in results)
    print('slower:',slower,'/',len(results))
    return 2 if slower else 0

if __name__ == '__main__':
    raise SystemExit(main())
