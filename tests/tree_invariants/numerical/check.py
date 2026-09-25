#!/usr/bin/env python3
"""Replay universal local error bounds and real-algebra obligations.

A successful run is not a proof of libm's sin/cos accuracy or of the entire
SPARK pipeline. See tree-error.md for the exact composition and boundaries.
"""
import argparse
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys

HERE = Path(__file__).resolve().parent

def normalized(s):
    return re.sub(r'\s+', '', s).lower()

def source_link(repo):
    math = repo/'experimental/smooth/src/mj-smooth_math.adb'
    spec = repo/'experimental/smooth/src/mj-smooth_math.ads'
    s = normalized(math.read_text())
    expressions = [
        'C0 : constant Component := P00 - P11 - P22 - P33;',
        'C1 : constant Component := P01 + P10 + P23 - P32;',
        'C2 : constant Component := P02 - P13 + P20 + P31;',
        'C3 : constant Component := P03 + P12 - P21 + P30;',
        'Temp := Scaled_Quaternion (Q);',
        'Norm := Scaled_Norm (Q);',
        'if Norm < 1.0 or else Norm > 2.0 then',
        'Temp := [Temp (0)/Norm, Temp (1)/Norm, Temp (2)/Norm, Temp (3)/Norm];',
        'return Math.Sqrt (((T (0)*T (0) + T (1)*T (1)) + T (2)*T (2)) + T (3)*T (3));',
    ]
    expressions += [f'P{i}{j} : constant Product := A ({i})*B ({j});' for i in range(4) for j in range(4)]
    for expr in expressions:
        assert normalized(expr) in s, ('source expression changed',expr)
    gate = '''abs (((Q (0)*Q (0) + Q (1)*Q (1)) + Q (2)*Q (2)) + Q (3)*Q (3) - 1.0)
        <= 64.0 * Real'Model_Epsilon'''
    assert normalized(gate) in normalized(spec.read_text())
    assert 'type' in (repo/'src/mj-types.ads').read_text()
    return {str(p.relative_to(repo)):hashlib.sha256(p.read_bytes()).hexdigest() for p in [math,spec,repo/'src/mj-types.ads']}

def main():
    ap=argparse.ArgumentParser()
    ap.add_argument('--repo',type=Path,required=True)
    ap.add_argument('--gappa',required=True)
    ap.add_argument('--z3',required=True)
    ap.add_argument('--out',type=Path,required=True)
    a=ap.parse_args(); a.out.mkdir(parents=True,exist_ok=False)
    sources=source_link(a.repo)
    runs=[]
    expected={'hamilton_norm.smt2':1,'local_budget.smt2':2,
              'normalization_rewrite.smt2':2,'unit_gate_to_norm.smt2':1}
    for name,count in expected.items():
        path=HERE/'smt'/name
        p=subprocess.run([a.z3,str(path)],text=True,capture_output=True,timeout=30)
        (a.out/(name+'.log')).write_text(p.stdout+p.stderr)
        assert p.returncode == 0 and p.stdout.split() == ['unsat']*count and not p.stderr,(name,p.stdout,p.stderr)
        runs.append(dict(file=str(path.relative_to(HERE)),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),checks=count,status='proved_unsat'))
    for name in ['hamilton.g','unit_gate.g','normalization-div-hints.g']:
        path=HERE/name
        p=subprocess.run([a.gappa,str(path)],text=True,capture_output=True,timeout=30)
        (a.out/(name+'.log')).write_text(p.stdout+p.stderr)
        assert p.returncode == 0,(name,p.stdout,p.stderr)
        if name == 'normalization-div-hints.g':
            # Each algebraic rewrite denominator warning is discharged by the
            # independently replayed normalization_rewrite.smt2 obligations.
            warnings=[x for x in p.stderr.splitlines() if x]
            assert all(re.fullmatch(r'Warning: the expression .* has been assumed to be nonzero when checking a rewriting rule\.',x) for x in warnings),p.stderr
        else:
            assert not p.stderr and not p.stdout,(name,p.stdout,p.stderr)
        runs.append(dict(file=name,sha256=hashlib.sha256(path.read_bytes()).hexdigest(),status='proved_gappa',rewrite_side_conditions='normalization_rewrite.smt2' if name.startswith('normalization') else None))
    u=Fraction(1,2**53)
    # This is a counterexample to eliminating normalization using ONLY the
    # existing Unit_Quaternion contract, not a claim of reachability after Create.
    eps=2.0**-52
    x=1.0+32*eps
    product=x*x
    gate=lambda v:abs(v*v-1.0)<=64*eps
    assert gate(x) and not gate(product)
    # Exact rational arithmetic on certificate constants, not sampled error.
    assert Fraction(64,1)/Fraction(49,100)+128 < 512
    results=dict(sources=sources,tools={
        'gappa':subprocess.check_output([a.gappa,'--version'],text=True).strip(),
        'z3':subprocess.check_output([a.z3,'--version'],text=True).strip()},
        obligations=runs,unit_roundoff=str(u),
        squared_norm_error_bound=str(144*u),
        squared_norm_error_bound_decimal=float(144*u),
        direction_error_per_product=str(512*u),
        examples={str(n):{'quaternion_chord_bound':float(n*512*u),'rotation_angle_bound_radians':float(4*n*512*u)} for n in [1,2,24,48,4351,4352]},
        contract_counterexample=dict(input=x.hex(),product=product.hex(),input_gate=gate(x),product_gate=gate(product)),
        limits=['Requires binary64 round-nearest-even and gradual underflow.',
                'Normalization error certificate additionally requires correctly rounded sqrt.',
                'Direction composition requires every supplied factor to have norm >= 1/2.',
                'Direction target uses the actual returned local factors, normalized exactly; sin/cos and model/input errors are not included.',
                'Source expressions are checked; no verified Ada-to-Gappa translator or whole-pipeline proof is claimed.'])
    (a.out/'results.json').write_text(json.dumps(results,indent=2)+'\n')
    print('Proved 3 Gappa obligations and 6 SMT real-algebra checks; counterexample confirmed.')

if __name__=='__main__': main()
