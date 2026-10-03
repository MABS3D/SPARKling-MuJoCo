"""Literal upstream getimpedance oracle, including noninteger powers/boundaries."""
import argparse, hashlib, itertools, json, math, random, subprocess
from pathlib import Path
from evidence import ROOT, environment, snapshot

p = argparse.ArgumentParser()
p.add_argument('--binary', type=Path, required=True)
p.add_argument('--out', type=Path, required=True)
a = p.parse_args(); a.out.mkdir(parents=True, exist_ok=False)
sources = snapshot()
upstream = ROOT / 'mujoco/src/engine/engine_core_constraint.c'
text = upstream.read_text()
literal = text[text.index('static mjtNum power('):text.index('// implicit-row factor')]
oracle = '''#include <math.h>
#include <stdio.h>
typedef double mjtNum;
#define mjMINVAL 1e-15
#define mju_pow pow
''' + literal + '''
int main(void) {
  double s[5], pos, margin, i, ip;
  while (scanf("%lf %lf %lf %lf %lf %lf %lf", s,s+1,s+2,s+3,s+4,&pos,&margin)==7) {
    s[0]=fmin(.9999,fmax(.0001,s[0])); s[1]=fmin(.9999,fmax(.0001,s[1]));
    s[2]=fmax(0,s[2]); s[3]=fmin(.9999,fmax(.0001,s[3])); s[4]=fmax(1,s[4]);
    getimpedance(s,pos,margin,&i,&ip); printf("%.17g %.17g\\n",i,ip);
  }
}
'''
(a.out/'reference.c').write_text(oracle)
subprocess.run(['gcc','-O2','-ffp-contract=off',str(a.out/'reference.c'),'-lm',
                '-o',str(a.out/'reference')],env=environment(),check=True)
cases=[]
powers=[-5.,0.,.5,1.,math.nextafter(1.,math.inf),1.1,1.25,1.5,2.,2.5,3.,4.,
        6.5,10.,32.,64.,128.,256.,1000.,1e6,1e10]
for power,mid in itertools.product(powers,[-1.,.0001,.2,.5,.8,.9999,2.]):
    m=min(.9999,max(.0001,mid))
    for x in [0.,math.nextafter(0.,1.),.01,math.nextafter(m,0.),m,
              math.nextafter(m,1.),.99,math.nextafter(1.,0.),1.,1.1]:
        for sign in [-1.,1.]:
            cases.append([.9,.95,.1,mid,power,sign*(.1*x),0.])
for d0,dw,width,power in itertools.product([-.5,.9,.95,2.],[.9,.95],
                                          [-1.,0.,1e-15,.1],[1.,1.5,3.,128.]):
    cases.append([d0,dw,width,.3,power,.025,.005])
# Exercise very steep but finite curves near either end and signed derivatives.
for x in [.9998,.9999,math.nextafter(.9999,1.)]:
    cases.append([.95,.9,.1,.9999,1e6,.1*x,0.])
rng=random.Random(20261002)
for _ in range(1000):
    cases.append([rng.uniform(.0001,.9999),rng.uniform(.0001,.9999),.1,
                  rng.uniform(.05,.95),rng.uniform(1.,30.),rng.uniform(-.11,.11),0.])
data=''.join(' '.join(format(x,'.17g') for x in c)+'\n' for c in cases)
ada=subprocess.run([str(a.binary.resolve())],input=data,text=True,capture_output=True,check=True)
c=subprocess.run([str(a.out/'reference')],input=data,text=True,capture_output=True,check=True)
(a.out/'input.txt').write_text(data);(a.out/'ada.txt').write_text(ada.stdout)
(a.out/'c.txt').write_text(c.stdout)
actual=ada.stdout.splitlines();expected=c.stdout.splitlines()
assert len(actual)==len(expected)==len(cases)
matched=exact=rejected=0;failures=[];max_abs=[0.,0.]
for n,(av,cv) in enumerate(zip(actual,expected)):
    ref=list(map(float,cv.split()))
    if av=='numeric':
        rejected+=1
        # Explicit finite-intermediate/output domain: keep bounded rejections
        # distinct from C's own underflow/overflow/nonfinite results.
        failures.append(dict(case=n,input=cases[n],c=ref,reason='bounded-domain')) if all(math.isfinite(v) and abs(v)<1e35 for v in ref) else None
        continue
    got=list(map(float,av.split()[1:]))
    if not all(math.isfinite(v) for v in ref):
        failures.append(dict(case=n,input=cases[n],ada=got,c=ref));continue
    ok=all(math.isclose(v,w,rel_tol=3e-12,abs_tol=3e-12) for v,w in zip(got,ref))
    if not ok:failures.append(dict(case=n,input=cases[n],ada=got,c=ref))
    matched+=int(ok);exact+=int(got==ref)
    for k in range(2):max_abs[k]=max(max_abs[k],abs(got[k]-ref[k]))
report=dict(cases=len(cases),matched=matched,bit_identical=exact,numerical_rejections=rejected,
            max_abs=max_abs,failures=failures,sources=sources,
            reference_source_sha256=hashlib.sha256(upstream.read_bytes()).hexdigest())
(a.out/'summary.json').write_text(json.dumps(report,indent=2)+'\n')
assert sources==snapshot()
print(json.dumps({k:v for k,v in report.items() if k!='sources'},indent=2))
assert not failures
