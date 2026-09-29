#!/usr/bin/env python3
"""Balanced paired comparison: previous Ada/C and optimized Ada/C binaries."""
from pathlib import Path
import argparse, hashlib, itertools, json, math, os, platform, random, statistics, subprocess, time


def summarize(values, rng):
    median=statistics.median(values)
    draws=sorted(statistics.median(rng.choices(values,k=len(values))) for _ in range(10000))
    lo,hi=draws[250],draws[9749]
    return {'median':median,'mad':statistics.median(abs(x-median) for x in values),
            'bootstrap_95':[lo,hi], 'classification':'faster' if hi<1 else 'slower' if lo>1 else 'inconclusive'}


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--baseline',required=True,type=Path);p.add_argument('--current',required=True,type=Path)
    p.add_argument('--out',required=True,type=Path);p.add_argument('--session',type=int,required=True)
    p.add_argument('--blocks',type=int,default=48);p.add_argument('--ms',type=float,default=20)
    p.add_argument('--cpu',type=int,default=12)
    a=p.parse_args();assert a.blocks%24==0 and a.ms>0
    os.sched_setaffinity(0,{a.cpu});rng=random.Random(20260929+a.session)
    binaries={'old_ada':(a.baseline,1),'old_c':(a.baseline,0),'new_ada':(a.current,1),'new_c':(a.current,0)}
    def sample(label,reps,pattern):
        binary,backend=binaries[label]
        return json.loads(subprocess.check_output([str(binary.resolve()),'1',str(backend),str(reps),str(pattern)],text=True))
    process_snapshot=subprocess.check_output(['ps','-eo','comm,args'],text=True)
    active=[s.split(None,1)[0] for s in process_snapshot.splitlines() if s.split(None,1)[0] in ['gnatprove','gnatwhy3','gprbuild','cvc5','z3','alt-ergo','gcc','cc1','gnat1']]
    report={'session':a.session,'cpu':a.cpu,'platform':platform.platform(),'cpuinfo':Path('/proc/cpuinfo').read_text().split('\n\n')[0],
            'loadavg_start':Path('/proc/loadavg').read_text().strip(),'active_compiler_prover_processes':active,
            'blocks':a.blocks,'target_ms':a.ms,'started_unix':time.time(),
            'binary_sha256':{k:hashlib.sha256(b.read_bytes()).hexdigest() for k,(b,_) in binaries.items()},
            'compiler':subprocess.check_output(['readelf','-p','.comment',str(a.current)],text=True),'results':[]}
    for pattern in range(10):
        probes=[sample(k,2000,pattern) for k in binaries]
        reps=max(1000,min(50000000,int(2000*a.ms*1e6/min(r['cpu_ns'] for r in probes))))
        orders=list(itertools.permutations(binaries))*int(a.blocks/24);rng.shuffle(orders)
        rows=[]
        for order in orders:
            row={label:sample(label,reps,pattern) for label in order}
            assert len({v['sink'] for v in row.values()})==1
            rows.append({'order':order,'values':row})
        stats={}
        for label in binaries:
            times=[row['values'][label]['cpu_ns']/(64*reps) for row in rows]
            stats[label]={'median_ns':statistics.median(times),'mad_ns':statistics.median(abs(x-statistics.median(times)) for x in times),
                          'p95_sample_average_ns':sorted(times)[math.ceil(.95*len(times))-1]}
        ratios={}
        for name,n,d in [('new_over_c','new_ada','new_c'),('new_over_old_c','new_ada','old_c'),('old_over_c','old_ada','old_c'),('new_over_old','new_ada','old_ada'),('c_control','new_c','old_c')]:
            ratios[name]=summarize([r['values'][n]['cpu_ns']/r['values'][d]['cpu_ns'] for r in rows],rng)
        report['results'].append({'pattern':pattern,'repetitions':reps,'times':stats,'ratios':ratios,'samples':rows})
        a.out.write_text(json.dumps(report,indent=2)+'\n')
        s=ratios['new_over_c'];print(pattern,round(s['median'],4),[round(x,4) for x in s['bootstrap_95']],s['classification'],flush=True)
    report['loadavg_end']=Path('/proc/loadavg').read_text().strip();report['ended_unix']=time.time()
    a.out.write_text(json.dumps(report,indent=2)+'\n')

if __name__=='__main__':main()
