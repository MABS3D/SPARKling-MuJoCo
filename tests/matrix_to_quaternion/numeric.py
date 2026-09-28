"""Differential tests against actual pinned C, plus independent rotation anchors."""
import argparse
import itertools
import json
import math
from pathlib import Path
import random
import subprocess
import sys

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent / "quaternions"))
from reference import validate


def matrix(q):
    w, x, y, z = q
    return [w*w+x*x-y*y-z*z, 2*(x*y-w*z), 2*(x*z+w*y),
            2*(x*y+w*z), w*w-x*x+y*y-z*z, 2*(y*z-w*x),
            2*(x*z-w*y), 2*(y*z+w*x), w*w-x*x-y*y+z*z]


def branch(a):
    return (0 if a[0]+a[4]+a[8] > 0 else
            1 if a[0] > a[4] and a[0] > a[8] else 2 if a[4] > a[8] else 3)


def corpus():
    rows, anchors, rotations = [], {}, {}
    def add(a, expected=None, rotation=False):
        index = len(rows)
        rows.append(a)
        if expected is not None:
            anchors[index] = expected
        if rotation:
            rotations[index] = a
    # Exact orientation anchors exercise all branches and the strict tie order.
    add([1.,0.,0.,0.,1.,0.,0.,0.,1.], [1.,0.,0.,0.], True)
    add([1.,0.,0.,0.,-1.,0.,0.,0.,-1.], [0.,1.,0.,0.], True)
    add([-1.,0.,0.,0.,1.,0.,0.,0.,-1.], [0.,0.,1.,0.], True)
    add([-1.,0.,0.,0.,-1.,0.,0.,0.,1.], [0.,0.,0.,1.], True)
    add([0.,0.,1.,1.,0.,0.,0.,1.,0.], [.5,.5,.5,.5], True)
    add([0.,1.,0.,0.,0.,1.,1.,0.,0.], [-.5,.5,.5,.5], True)
    add([0.]*9, [0.,0.,0.,1.])
    add([-1.,0.,0.,0.,-1.,0.,0.,0.,-1.], [0.,0.,0.,1.])
    add([1.,0.,0.,0.,1.,0.,0.,0.,-1.], [1.,0.,0.,0.])
    add([1.]*9, [1.,0.,0.,0.])
    # Include zero/tiny terms, diagonal ties, trace boundaries and Tier0 edges.
    values = [-1e10, -1., -5e-324, -0., 0., 5e-324, 1., 1e10]
    for diag in itertools.product(values, repeat=3):
        for off in ([0.]*6, [1e10,-1e10,1e10,1e10,-1e10,1e10]):
            add([diag[0],off[0],off[1],off[2],diag[1],off[3],off[4],off[5],diag[2]])
    for d0, d1 in itertools.product([-1e10,-1.,-.5,0.,.5,1.,1e10], repeat=2):
        d2 = -(d0+d1)
        for v in [math.nextafter(d2,-math.inf), d2, math.nextafter(d2,math.inf)]:
            if abs(v) <= 1e10:
                add([d0,.3,-.2,.7,d1,.1,-.4,.9,v])
    rng = random.Random(20260928)
    for _ in range(3000):
        q = [rng.uniform(-1,1) for _ in range(4)]
        length = math.sqrt(sum(x*x for x in q))
        add(matrix([x/length for x in q]), rotation=True)
    for axis in ([1.,0.,0.], [0.,1.,0.], [0.,0.,1.], [1.,1.,1.], [1.,-1.,0.]):
        length = math.sqrt(sum(x*x for x in axis))
        for center in (0., math.pi/2, 2*math.pi/3, math.pi):
            for angle in (math.nextafter(center,0.), center, math.nextafter(center,math.inf)):
                q = [math.cos(angle/2)] + [x/length*math.sin(angle/2) for x in axis]
                add(matrix(q), rotation=True)
    for _ in range(2000):
        scale = 10**rng.uniform(-160,10)
        add([scale*rng.uniform(-1,1) for _ in range(9)])
    return rows, anchors, rotations


def main():
    validate()
    parser = argparse.ArgumentParser()
    parser.add_argument("--mode", choices=["development","validation","release"], default="release")
    args = parser.parse_args()
    rows, anchors, rotations = corpus()
    data = "".join(" ".join(format(x,".17g") for x in row)+"\n" for row in rows)
    binary = HERE / "build" / args.mode / "bin/main"
    p = subprocess.run([str(binary),"0","0","1","0"], input=data, text=True,
                       capture_output=True, check=True)
    outputs = [[float(x) for x in line.split()] for line in p.stdout.splitlines()]
    assert len(outputs)==len(rows)
    assert all(len(q)==4 and all(math.isfinite(x) for x in q) for q in outputs)
    for i, q in anchors.items():
        assert outputs[i]==q, (i,outputs[i],q)
    error, norm_error = 0., 0.
    for i, a in rotations.items():
        q = outputs[i]
        error = max(error, max(abs(x-y) for x,y in zip(matrix(q),a)))
        norm_error = max(norm_error, abs(sum(x*x for x in q)-1))
    assert error < 6e-15 and norm_error < 4e-15, (error,norm_error)
    # Also run every timed input pattern through both checked adapters.
    for pattern in range(10):
        for backend in (0,1):
            subprocess.run([str(binary),"1",str(backend),"1",str(pattern)],
                           check=True,capture_output=True,text=True)
    boundary = 0
    if args.mode != "release":
        subprocess.run([str(binary),"2","0","1","0"],check=True)
        boundary = 18
    print(json.dumps(dict(mode=args.mode,cases=len(rows),comparisons=4*len(rows),
        comparison="exact finite value equality with pinned C; zero sign bits excluded",
        anchors=len(anchors),branches={str(b):sum(branch(a)==b for a in rows) for b in range(4)},
        rotation_roundtrips=len(rotations),max_roundtrip_error=error,max_squared_norm_error=norm_error,
        precondition_rejections=boundary,timing_fixture_comparisons=10*2*64*4)))


if __name__ == "__main__":
    main()
