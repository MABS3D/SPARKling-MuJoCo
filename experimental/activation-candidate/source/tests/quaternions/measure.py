#!/usr/bin/env python3
"""Alternating, CPU-pinned native C/Ada microbenchmarks; retain all raw samples."""
import argparse, hashlib, json, math, os, platform, random, statistics, subprocess
from pathlib import Path
from reference import validate
HERE=Path(__file__).resolve().parent
NAMES={1:'identity',2:'conjugate',3:'conjugate_in_place',4:'multiply',5:'multiply_in_place',6:'norm_expression',7:'normalize',8:'rotate',9:'to_matrix'}

def main():
    validate()
    ap=argparse.ArgumentParser();ap.add_argument('--pairs',type=int,default=15);ap.add_argument('--ms',type=float,default=20);ap.add_argument('--output',type=Path,default=HERE/'measurements.json');ap.add_argument('--ops',default='1,2,3,4,5,6,7,8,9');ap.add_argument('--patterns',default='0,1,2,3,4,5,6,7');ap.add_argument('--cpu',type=int)
    args=ap.parse_args();assert args.pairs>=5 and args.ms>0
    cpu=args.cpu if args.cpu is not None else min(os.sched_getaffinity(0));os.sched_setaffinity(0,{cpu})
    binary=HERE/'build/release/bin/main';rng=random.Random(20260923)
    def sample(backend,op,reps,pattern):
        return json.loads(subprocess.check_output([str(binary),str(backend),str(op),str(reps),str(pattern)],text=True))
    results=[]
    for op in map(int,args.ops.split(',')):
        for pat in map(int,args.patterns.split(',')):
            probe=[sample(b,op,200000,pat) for b in (0,1)]
            reps=max(1000,min(50000000,int(200000*args.ms*1e6/min(x['cpu_ns'] for x in probe))))
            pairs=[]
            for k in range(args.pairs):
                row={b:sample(b,op,reps,pat) for b in ((0,1) if k%2==0 else (1,0))}
                assert row[0]['sink']==row[1]['sink'],(op,pat,row)
                pairs.append(row)
            ratios=[p[1]['cpu_ns']/p[0]['cpu_ns'] for p in pairs]
            draws=sorted(statistics.median(rng.choices(ratios,k=len(ratios))) for _ in range(5000))
            median=statistics.median(ratios);lo,hi=draws[125],draws[4874]
            result={'operation':NAMES[op],'op':op,'pattern':pat,'reps':reps,'ratio_ada_over_c':median,'mad_ratio':statistics.median(abs(r-median) for r in ratios),'bootstrap_median_95':[lo,hi],'status':'slower' if lo>1 else 'faster' if hi<1 else 'within_noise','c_ns':statistics.median(p[0]['cpu_ns']/reps for p in pairs),'ada_ns':statistics.median(p[1]['cpu_ns']/reps for p in pairs),'samples':pairs}
            results.append(result);print(f'{NAMES[op]:20} {pat}: {median:.3f} [{lo:.3f}, {hi:.3f}] {result["status"]}',flush=True)
    root=HERE.parent.parent
    report={'platform':platform.platform(),'cpu':cpu,'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0],'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'source_sha256':{str(p.relative_to(root)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [root/'src/mj-quaternion_math.ads',root/'src/mj-quaternions.ads',root/'src/mj-quaternions.adb',HERE/'adapter.adb',HERE/'driver.c',HERE/'checks.gpr',root/'mujoco/src/engine/engine_util_spatial.c',root/'mujoco/src/engine/engine_util_blas.c']},'compiler':subprocess.check_output(['readelf','-p','.comment',str(binary)],text=True),'pairs':args.pairs,'target_ms':args.ms,'reference':'MuJoCo 3.14.0 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd','results':results}
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print('slower:',sum(r['status']=='slower' for r in results),'/',len(results))

if __name__=='__main__':main()
