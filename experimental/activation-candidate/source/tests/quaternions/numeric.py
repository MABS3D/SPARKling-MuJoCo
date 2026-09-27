#!/usr/bin/env python3
"""Exact finite-value comparison with the pinned MuJoCo C source, plus anchors."""
import argparse, json, math, random, subprocess
from pathlib import Path
from reference import validate

HERE = Path(__file__).resolve().parent

def corpus():
    rng = random.Random(20260923)
    quats = [[1.,0.,0.,0.],[-1.,0.,0.,0.],[0.,0.,0.,0.],
             [0.,1.,0.,0.],[0.,0.,1.,0.],[0.,0.,0.,1.],
             [.5,.5,.5,.5],[1.,2.,3.,4.],[1e10,-1e10,1e10,-1e10],
             [1e-160,-2e-160,3e-160,-4e-160],[5e-324,-5e-324,0.,-0.]]
    for center in (1e-15, 1., 1.-1e-15, 1.+1e-15):
        for val in (math.nextafter(center,0.),center,math.nextafter(center,math.inf)):
            quats.append([val,0.,0.,0.])
    for mask in range(16):
        quats.append([(-1. if mask&(1<<i) else 1.)*1e10 for i in range(4)])
    vectors = [[0.,0.,0.],[1.,2.,3.],[-1e10,1e10,-1e10],[5e-324,-5e-324,0.]]
    rows = []
    for a in quats:
        for b in quats:
            rows.append(a+b+vectors[len(rows)%len(vectors)])
    for k in range(2500):
        a=[rng.uniform(-1,1) for _ in range(4)]
        b=[rng.uniform(-1,1) for _ in range(4)]
        if k%3==0:
            a=[v/math.sqrt(sum(x*x for x in a)) for v in a]
            b=[v/math.sqrt(sum(x*x for x in b)) for v in b]
        else:
            scale=10.**rng.uniform(-160,10)
            a=[x*scale for x in a];b=[x*scale for x in b]
        rows.append(a+b+[rng.uniform(-1e10,1e10) for _ in range(3)])
    # Independent Hamilton product and half-turn anchors.
    rows.extend([[1.,2.,3.,4.,5.,6.,7.,8.,1.,2.,3.],
                 [0.,0.,0.,1.,1.,0.,0.,0.,1.,2.,3.]])
    return rows

def run(binary,backend,rows):
    data=''.join(' '.join(format(x,'.17g') for x in row)+'\n' for row in rows)
    result=subprocess.run([str(binary),str(backend),'0','1','0'],input=data,text=True,capture_output=True,check=True)
    out=[[float(x) for x in line.split()] for line in result.stdout.splitlines()]
    assert len(out)==len(rows), (len(out),len(rows),result.stderr)
    assert all(len(row)==38 for row in out)
    return out

def main():
    validate()
    parser=argparse.ArgumentParser();parser.add_argument('--mode',choices=['development','validation','release'],default='release')
    args=parser.parse_args();binary=HERE/'build'/args.mode/'bin/main'
    rows=corpus();c=run(binary,0,rows);ada=run(binary,1,rows)
    for n,(left,right) in enumerate(zip(c,ada)):
        for col,(x,y) in enumerate(zip(left,right)):
            assert math.isfinite(x) and math.isfinite(y) and x==y, (n,col,x,y,rows[n])
    for out in (c,ada):
        assert out[-2][12:16]==[-60.,12.,30.,24.]
        assert out[-2][16:20]==[-60.,12.,30.,24.]
        assert out[-1][26:29]==[-1.,-2.,3.]
        assert out[-1][29:]==[-1.,0.,0.,0.,-1.,0.,0.,0.,1.]
        assert all(x[0:4]==[1.,0.,0.,0.] for x in out)
    print(json.dumps({'mode':args.mode,'cases':len(rows),'scalars':38*len(rows),'comparison':'exact finite numerical equality','anchors':'passed'}))

if __name__=='__main__':main()
