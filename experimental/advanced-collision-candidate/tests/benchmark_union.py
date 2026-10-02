"""Diagnostic union microbenchmark; this does not measure a simulation step."""
from __future__ import annotations
import argparse, hashlib, json, os, platform, shutil, statistics, subprocess
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[1]
TOOLS=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
GNAT=TOOLS/'gnat/gnat-x86_64-linux-16.1.0-1/bin'
GPR=TOOLS/'gprbuild/gprbuild-x86_64-linux-26.0.0-1/bin/gprbuild'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--out',required=True,type=Path)
    ap.add_argument('--baseline-dir',required=True,type=Path,
                    help='directory with the original mj-bvh.adb and mj-bvh.ads')
    ap.add_argument('--steps',type=int,default=4000000)
    ap.add_argument('--samples',type=int,default=11)
    a=ap.parse_args()
    if a.steps<10000 or a.samples<5:ap.error('use >=10000 steps and >=5 samples')
    out=a.out.resolve();out.mkdir(parents=True,exist_ok=False)
    env={**os.environ,'PATH':str(GNAT)+':'+str(GPR.parent)+':'+os.environ['PATH']}
    cpu=min(os.sched_getaffinity(0));binaries={};sources={};commands=[]
    for variant in ('baseline','current'):
        snap=out/variant;snap.mkdir()
        for directory in ('src','vendor','tests'):
            shutil.copytree(ROOT/directory,snap/directory,ignore=shutil.ignore_patterns('__pycache__'))
        shutil.copy2(ROOT/'advanced.gpr',snap/'advanced.gpr')
        if variant=='baseline':
            for name in ('mj-bvh.adb','mj-bvh.ads'):
                shutil.copy2(a.baseline_dir/name,snap/'src'/name)
        cmd=[str(GPR),'-Padvanced.gpr','-j2','-XADVANCED_MODE=release',
             '-XADVANCED_BUILD_ROOT='+str(out/(variant+'-build')),'union_bench.adb']
        commands.append(cmd)
        with (out/(variant+'-build.log')).open('w') as f:
            subprocess.run(cmd,cwd=snap,env=env,stdout=f,stderr=subprocess.STDOUT,check=True)
        binaries[variant]=out/(variant+'-build/release/bin/union_bench')
        sources[variant]={str(p.relative_to(snap)):sha(p) for p in sorted(snap.rglob('*'))
                          if p.is_file() and '__pycache__' not in p.parts}
    def measure(variant,size):
        raw=subprocess.check_output([str(binaries[variant]),str(size),str(a.steps)],text=True,
                                    preexec_fn=lambda:os.sched_setaffinity(0,{cpu}))
        elapsed,c,h=map(float,raw.split())
        return {'seconds':elapsed,'checksum':[c,h]}
    results=[];rng=np.random.default_rng(20261002)
    for size in (16,256,4096):
        for variant in binaries:measure(variant,size)
        samples=[]
        for i in range(a.samples):
            sample={}
            order=('baseline','current') if i%2==0 else ('current','baseline')
            for variant in order:sample[variant]=measure(variant,size)
            assert sample['baseline']['checksum']==sample['current']['checksum']
            samples.append(sample)
        ratios=np.array([s['current']['seconds']/s['baseline']['seconds'] for s in samples])
        draws=np.median(rng.choice(ratios,(10000,len(ratios)),replace=True),axis=1)
        result={'boxes_per_input':size,'steps':a.steps,'samples':samples,
                'paired_ratio_median':float(np.median(ratios)),
                'paired_ratio_bootstrap_95':np.quantile(draws,[.025,.975]).tolist()}
        for variant in binaries:
            times=[s[variant]['seconds']/a.steps*1e9 for s in samples]
            result[variant+'_ns_per_union']={'median':statistics.median(times),
                                            'p25':float(np.quantile(times,.25)),
                                            'p75':float(np.quantile(times,.75))}
        results.append(result)
        print(size,result['paired_ratio_median'],result['paired_ratio_bootstrap_95'],flush=True)
    report={'scope':'Union microbenchmark with moving input and consumption of all six outputs; not full BVH or simulation timing.',
            'reference':'Initial Ada candidate versus current Ada candidate; no native C timing claim.',
            'date':'2026-10-02','cpu':cpu,'platform':platform.platform(),
            'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0],
            'source_sha256':sources,'binary_sha256':{k:sha(v) for k,v in binaries.items()},
            'compiler':subprocess.check_output([str(GNAT/'gcc'),'--version'],text=True),
            'commands':commands,'results':results}
    (out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
if __name__=='__main__':main()
