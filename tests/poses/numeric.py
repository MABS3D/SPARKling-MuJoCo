#!/usr/bin/env python3
"""Finite numerical equality with pinned C; independent geometric/branch anchors."""
import argparse, json, math, random, subprocess
from pathlib import Path
from reference import validate
HERE=Path(__file__).resolve().parent

def corpus():
    rng=random.Random(20260924)
    quats=[[1.,0.,0.,0.],[-1.,0.,0.,0.],[0.,0.,0.,0.],
           [1e10,-0.,0.,-0.],[-1e10,0.,-0.,0.],
           [0.,1.,0.,0.],[0.,0.,1.,0.],[0.,0.,0.,1.],
           [.5,.5,.5,.5],[1.,2.,3.,4.],
           [1e-160,-2e-160,3e-160,-4e-160],[5e-324,-5e-324,0.,-0.]]
    for center in (1e-15,1.,1.-1e-15,1.+1e-15):
        for value in (math.nextafter(center,0.),center,math.nextafter(center,math.inf)):
            quats.append([value,0.,0.,0.])
    for mask in range(16):
        quats.append([(-1. if mask&(1<<i) else 1.)*1e10 for i in range(4)])
    vectors=[[0.,-0.,0.],[1.,2.,3.],[-1e10,1e10,-1e10],[5e-324,-5e-324,0.]]
    rows=[]
    for a in quats:
        for b in quats:
            for v in vectors:
                rows.append(v+a+vectors[len(rows)%4]+b+v)
    for k in range(3000):
        a=[rng.uniform(-1,1) for _ in range(4)]
        b=[rng.uniform(-1,1) for _ in range(4)]
        if k%3==0:
            a=[v/math.sqrt(sum(x*x for x in a)) for v in a]
            b=[v/math.sqrt(sum(x*x for x in b)) for v in b]
        else:
            a=[x*10.**rng.uniform(-160,10) for x in a]
            b=[x*10.**rng.uniform(-160,10) for x in b]
        p=[rng.uniform(-1e10,1e10) for _ in range(9)]
        rows.append(p[:3]+a+p[3:6]+b+p[6:])
    # Exact half-turn, pure translation, zero-product fallback, and nonunit
    # scalar product that must normalize (catch an omitted normalize step).
    rows += [
      [10.,20.,30.,0.,0.,0.,1.,1.,2.,3.,1.,0.,0.,0.,4.,5.,6.],
      [10.,20.,30.,1.,0.,0.,0.,1.,2.,3.,1.,0.,0.,0.,4.,5.,6.],
      [10.,20.,30.,0.,0.,0.,0.,1.,2.,3.,1.,0.,0.,0.,4.,5.,6.],
      [10.,20.,30.,2.,0.,0.,0.,1.,2.,3.,3.,0.,0.,0.,4.,5.,6.]]
    return rows

def run(binary,backend,rows):
    data=''.join(' '.join(format(x,'.17g') for x in row)+'\n' for row in rows)
    result=subprocess.run([str(binary),str(backend),'0','1','0'],input=data,text=True,capture_output=True,check=True)
    out=[[float(x) for x in line.split()] for line in result.stdout.splitlines()]
    assert len(out)==len(rows) and all(len(row)==38 for row in out)
    return out

def main():
    validate()
    parser=argparse.ArgumentParser();parser.add_argument('--mode',choices=['development','validation','release'],default='release')
    args=parser.parse_args();binary=HERE/'build'/args.mode/'bin/main'
    rows=corpus();c=run(binary,0,rows);ada=run(binary,1,rows)
    for n,(left,right) in enumerate(zip(c,ada)):
        for col,(x,y) in enumerate(zip(left,right)):
            assert math.isfinite(x) and math.isfinite(y) and x==y,(n,col,x,y,rows[n])
        assert right[:7]==right[7:14] and right[14:21]==right[21:28] and right[28:31]==right[31:34]
    for out in (c,ada):
        assert out[-4][:7]==[9.,18.,33.,0.,0.,0.,1.]
        assert out[-4][14:21]==[10.,20.,-30.,0.,0.,0.,-1.]
        assert out[-4][28:31]==[6.,15.,36.]
        assert out[-3][:7]==[11.,22.,33.,1.,0.,0.,0.]
        assert out[-3][14:21]==[-10.,-20.,-30.,1.,0.,0.,0.]
        assert out[-3][28:31]==[14.,25.,36.]
        assert out[-2][:7]==[11.,22.,33.,1.,0.,0.,0.]
        assert out[-1][:7]==[11.,22.,33.,1.,0.,0.,0.]
        assert out[-1][34:]==[6.,0.,0.,0.]
    print(json.dumps({'mode':args.mode,'cases':len(rows),'scalars':38*len(rows),'comparison':'exact finite numerical equality; zero sign not asserted','anchors':'passed','frame':'input storage unchanged','in_place':'matches separate result'}))
if __name__=='__main__':main()
