#!/usr/bin/env python3
"""C differential, in-place equivalence, and independent direction anchors."""
import argparse
import json
import math
import random
import subprocess
from pathlib import Path
from reference import validate

HERE = Path(__file__).resolve().parent
IDENTITY = [1.,0.,0., 0.,1.,0., 0.,0.,1.]

def corpus():
    rng = random.Random(20260923)
    quaternions = [[1.,0.,0.,0.], [-1.,0.,0.,0.], [0.]*4,
                   [.5]*4, [0.,1.,0.,0.], [0.,0.,1.,0.], [0.,0.,0.,1.],
                   [.25,-.75,1.25,-2.], [5e-324,-5e-324,0.,-0.]]
    quaternions += [[(-1. if mask & (1<<i) else 1.)*1e10 for i in range(4)]
                    for mask in range(16)]
    vectors = [[0.,-0.,0.], [1.,2.,3.], [5e-324,-5e-324,5e-324]]
    vectors += [[(-1. if mask & (1<<i) else 1.)*1e10 for i in range(3)]
                for mask in range(8)]
    matrices = [IDENTITY, [0.]*9, [float(i) for i in range(1,10)],
                [(-1. if i%2 else 1.)*1e10 for i in range(9)],
                [(-1. if i%2 else 1.)*5e-324 for i in range(9)]]
    rows = [q+a+v for q in quaternions for a in matrices for v in vectors]
    for k in range(5000):
        q = [rng.uniform(-1,1) for _ in range(4)]
        if k%2:
            length = math.sqrt(sum(x*x for x in q))
            q = [x/length for x in q]
        else:
            scale = 10.**rng.uniform(-160,10)
            q = [x*scale for x in q]
        a = [rng.uniform(-1,1)*10.**rng.uniform(-160,10) for _ in range(9)]
        v = [rng.uniform(-1,1)*10.**rng.uniform(-160,10) for _ in range(3)]
        rows.append(q+a+v)
    # Exact cyclic permutation distinguishes forward from conjugate/transpose.
    rows.append([.5]*4 + [0.,0.,1., 1.,0.,0., 0.,1.,0.] + [1.,2.,3.])
    # Asymmetric matrix distinguishes row/column indexing independently of Q.
    rows.append([0.,0.,0.,1.] + [float(i) for i in range(1,10)] + [1.,2.,3.])
    return rows

def run(binary, backend, rows):
    data = ''.join(' '.join(format(x,'.17g') for x in row)+'\n' for row in rows)
    result = subprocess.run([str(binary),str(backend),'0','1','0'], input=data,
                            text=True,capture_output=True,check=True)
    output = [[float(x) for x in line.split()] for line in result.stdout.splitlines()]
    assert len(output) == len(rows)
    assert all(len(row) == 24 for row in output)
    return output

def main():
    validate()
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode',choices=['development','validation','release'],default='release')
    args = parser.parse_args()
    rows = corpus()
    binary = HERE/'build'/args.mode/'bin/main'
    c,ada = [run(binary,backend,rows) for backend in (0,1)]
    for n,(left,right) in enumerate(zip(c,ada)):
        for col,(x,y) in enumerate(zip(left,right)):
            assert math.isfinite(x) and math.isfinite(y) and x==y, (n,col,x,y,rows[n])
        for result in (left,right):
            for offset in (0,6,12,18):
                assert result[offset:offset+3] == result[offset+3:offset+6]
    for result in (c,ada):
        assert result[-2] == [3.,1.,2.]*2+[2.,3.,1.]*2+[3.,1.,2.]*2+[2.,3.,1.]*2
        assert result[-1] == [-1.,-2.,3.]*4+[14.,32.,50.]*2+[30.,36.,42.]*2
    print(json.dumps({'mode':args.mode,'cases':len(rows),'scalars':24*len(rows),
                      'comparison':'exact finite numerical equality',
                      'in_place':'passed','independent_anchors':'passed'}))

if __name__ == '__main__':
    main()
