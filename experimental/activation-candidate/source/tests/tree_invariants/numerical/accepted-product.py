from fractions import Fraction as F
from pathlib import Path
import subprocess,json
ROOT=Path(__file__).resolve().parent
import argparse
ap=argparse.ArgumentParser()
ap.add_argument('--z3',type=Path,required=True)
ap.add_argument('--gappa',type=Path,required=True)
ap.add_argument('--repo',type=Path,required=True)
ap.add_argument('--out',type=Path,required=True)
args=ap.parse_args()
z3=args.z3;gappa=args.gappa
import re,hashlib
normalize=lambda s:re.sub(r'\s+','',s).lower()
math=args.repo/'experimental/smooth/src/mj-smooth_math.adb'
spec=args.repo/'experimental/smooth/src/mj-smooth_math.ads'
types=args.repo/'src/mj-types.ads'
assert 'min_val:constantreal:=1.0e-15;' in normalize(types.read_text())
assert normalize('if not Bounded (Q, Work_Limit) or else Scale_Of (Q) < Min_Val then') in normalize(math.read_text())
assert normalize("Post => Bounded (Axis_Angle'Result, 1.000001)") in normalize(spec.read_text())
U=F(1,2**53); ETA=F(1,2**1074); MIN=F.from_float(1e-15)
def q(x):return f'(/ {x.numerator} {x.denominator})'
head=f'(set-logic QF_NRA)\n(define-fun u () Real {q(U)})\n(define-fun eta () Real {q(ETA)})\n(define-fun minimum () Real {q(MIN)})\n'
scalar=head+'\n'.join(f'(declare-const {v} Real)' for v in ['t0','t1','t2','t3','P'])+'\n'
scalar+='(assert (and (>= t0 0) (>= t1 0) (>= t2 0) (>= t3 0) (>= P (+ t0 t1 t2 t3))))\n'
# Each multiplication admits error u*abs(exact product)+eta.
for i in range(4):scalar+=f'(define-fun e{i} () Real (+ (* u t{i}) eta))\n'
scalar+='(define-fun E0 () Real e0)\n'
for i in range(1,4):
 partial='(+ '+' '.join('t'+str(j) for j in range(i+1))+')'
 scalar+=f'(define-fun E{i} () Real (+ (* (+ 1 u) (+ E{i-1} e{i})) (* u {partial}) eta))\n'
scalar+='(assert (> E3 (+ (* 5 u P) (* 8 eta))))\n(check-sat)\n'
accepted=head+'''(declare-const P Real)
(declare-const H Real)
(assert (and (>= P 0) (>= H minimum) (<= H (+ (* (+ 1 (* 10 u)) P) (* 16 eta)))))
(assert (<= P '''+q(F(1,2**51))+'''))
(check-sat)
'''
local=head+'''(declare-const P Real)
(assert (> P '''+q(F(1,2**51))+'''))
(assert (>= (+ (* 10 u) (/ (* 16 eta) P)) (* 11 u)))
(check-sat)
'''
budget=head+'''(assert (>= (+ (* 2 11 u) (* 128 u)) (* 512 u)))
(check-sat)
'''
out=args.out;out.mkdir(parents=True,exist_ok=False)
results={}
for name,body in [('hamilton-relative-bound',scalar),('accepted-nonzero-product',accepted),('accepted-relative-error',local),('accepted-direction-budget',budget)]:
 p=out/(name+'.smt2');p.write_text(body)
 r=subprocess.run([str(z3),str(p)],capture_output=True,text=True,timeout=30)
 (out/(name+'.log')).write_text(r.stdout+r.stderr)
 assert r.returncode==0 and r.stdout.strip()=='unsat',(name,r.stdout,r.stderr)
 results[name]='unsat'
for name in ['rounding-normal','rounding-subnormal','hamilton-intermediates']:
 r=subprocess.run([str(gappa),str(ROOT/(name+'.g'))],capture_output=True,text=True,timeout=30)
 (out/(name+'.log')).write_text(r.stdout+r.stderr)
 assert r.returncode==0,(name,r.stdout,r.stderr)
 results[name]='proved'
results['sources']={str(p.relative_to(args.repo)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [math,spec,types]}
results['minimum_exact']=str(MIN)
results['local_direction_bound_units']=150
results['tree_budget_units']=512
(out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
