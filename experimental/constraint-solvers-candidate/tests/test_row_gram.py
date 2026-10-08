"""Bitwise stable transpose maps and row-buffer Gram against actual C 3.15."""
import argparse
import ctypes as ct
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ('binary', 'out', 'reference'):
        parser.add_argument('--' + name, type=Path, required=True)
    args = parser.parse_args()
    assert mujoco.__version__ == '3.15.0'
    args.out.mkdir(parents=True, exist_ok=False)
    libpath = Path(mujoco.__file__).parent/'libmujoco.so.3.15.0'
    lib = ct.CDLL(str(libpath)); ip = ct.POINTER(ct.c_int); dp = ct.POINTER(ct.c_double)
    transpose = lib.mju_transposeSparse
    transpose.argtypes = [dp, dp, ct.c_int, ct.c_int] + [ip]*7
    transpose.restype = None
    numeric = lib.mju_sqrMatTDSparseNumeric
    numeric.argtypes = [dp, ct.c_int, ip, ip, ip, ip, dp, ip, ip, ip, dp, ip, ip, ip, ip, dp, ct.c_void_p]
    numeric.restype = None
    sym = lib.mju_cholFactorSymbolic
    sym.argtypes = [ip]*10 + [ct.c_int, ct.c_void_p]; sym.restype = ct.c_int
    model = mujoco.MjModel.from_xml_string('<mujoco><size memory="4M"/></mujoco>')
    data = mujoco.MjData(model)
    rng = np.random.default_rng(2026100809)
    cases = []
    for n in [1, 2, 3, 6, 12, 17, 36, 64, 128]:
        for rows in [0, 1, 3, 6, 17]:
            for kind in ['sparse', 'dense', 'duplicates', 'zero-scales', 'subnormal']:
                indices, vals, weights = [], [], []
                for r in range(rows):
                    width = n if kind == 'dense' else int(rng.integers(0, n+1))
                    col = np.sort(rng.choice(n, width, replace=False)).astype(np.int32)
                    if kind == 'duplicates' and width:
                        col = np.sort(np.r_[col, col[:min(width, 3)]]).astype(np.int32)
                    val = rng.uniform(-2, 2, len(col)).astype(np.float64)
                    if len(val) > 1: val[0] = -0.
                    weight = [0., 1e-15, 1., 1e15][r % 4]
                    if kind == 'zero-scales':
                        weight = 0. if r % 2 else 1e-15
                        val *= 1e-310
                    if kind == 'subnormal':
                        val = rng.choice([0., -0., 1e-310, -1e-310, np.nextafter(0., 1.)], len(val))
                    indices.append(col); vals.append(val); weights.append(weight)
                cases.append(dict(n=n, kind=kind, indices=indices, values=vals, weights=weights))
    for magnitude in [1e-60, 1e50, 1e60, 6.*2.**437]:
        for weight in [0., 1., 1e15]:
            cases.append(dict(n=6, kind='boundaries', indices=[np.array([0, 2, 5], np.int32)]*3,
                              values=[np.array([magnitude, -magnitude, 0.])]*3, weights=[weight]*3))
    inputs, references = [], []
    ptr = lambda x,t: x.ctypes.data_as(t)
    for case in cases:
        n = case['n']; rows = len(case['indices'])
        rn = np.array([len(c) for c in case['indices']], np.int32)
        ra = np.r_[0, np.cumsum(rn[:-1])].astype(np.int32) if rows else np.array([], np.int32)
        ci = np.concatenate(case['indices']) if rows else np.array([], np.int32)
        values = np.concatenate(case['values']) if rows else np.array([], np.float64)
        weights = np.array(case['weights'], np.float64)
        tn, ta = [np.zeros(n, np.int32) for _ in range(2)]
        ti = np.zeros(len(ci), np.int32); tv = np.zeros(len(ci), np.float64)
        encoded = np.arange(1, len(ci)+1, dtype=np.float64)
        transpose(ptr(tv,dp), ptr(encoded,dp), rows,n,ptr(tn,ip),ptr(ta,ip),ptr(ti,ip),None,
                  ptr(rn,ip),ptr(ra,ip),ptr(ci,ip))
        slots = tv.astype(np.int32)-1
        actual_t = values[slots]
        mask = np.eye(n, dtype=bool)
        for col in case['indices']:
            mask[np.ix_(col, col)] = True
        # Additional unrelated structure/fill ensures scatter and reset are
        # exercised beyond each input row's immediate numerical support.
        for r in range(1,n): mask[r-1,r] = True
        mask = np.triu(mask)
        hn = mask.sum(axis=1).astype(np.int32)
        ha = np.r_[0,np.cumsum(hn[:-1])].astype(np.int32); hi=np.where(mask)[1].astype(np.int32)
        ln,la,lt,ltadr=[np.zeros(n,np.int32) for _ in range(4)]
        count=sym(None,ptr(ln,ip),ptr(la,ip),None,ptr(lt,ip),ptr(ltadr,ip),None,
                  ptr(hn,ip),ptr(ha,ip),ptr(hi,ip),n,None)
        li,lti,ltmap=[np.zeros(count,np.int32) for _ in range(3)]
        sym(ptr(li,ip),ptr(ln,ip),ptr(la,ip),ptr(lti,ip),ptr(lt,ip),ptr(ltadr,ip),ptr(ltmap,ip),
            ptr(hn,ip),ptr(ha,ip),ptr(hi,ip),n,None)
        cvalues=np.zeros(count,np.float64)
        numeric(ptr(cvalues,dp),n,ptr(ln,ip),ptr(la,ip),ptr(li,ip),None,
                ptr(values,dp),ptr(rn,ip),ptr(ra,ip),ptr(ci,ip),ptr(actual_t,dp),
                ptr(tn,ip),ptr(ta,ip),ptr(ti,ip),None,ptr(weights,dp),data._address)
        dense=np.zeros((n,n)); buffer=np.zeros(n); accepted=True
        for p in range(n):
            for t in range(int(ta[p]),int(ta[p]+tn[p])):
                source=ti[t]; scale=weights[source]*values[slots[t]]
                if scale==0.: continue
                for s in range(int(ra[source]),int(ra[source]+rn[source])):
                    q=ci[s]
                    if q>p: break
                    buffer[q]=buffer[q]+scale*values[s]
                    if not -1e120<=buffer[q]<=1e120:
                        accepted=False;break
                if not accepted:break
            if not accepted:break
            col=li[la[p]:la[p]+ln[p]];dense[p,col]=buffer[col];buffer[col]=0.
        if accepted:
            c=np.zeros((n,n))
            for p in range(n):c[p,li[la[p]:la[p]+ln[p]]]=cvalues[la[p]:la[p]+ln[p]]
            assert np.array_equal(c.view(np.uint64),dense.view(np.uint64))
        expected_t=[]
        for p in range(n):
            expected_t.append(str(tn[p]))
            for t in range(int(ta[p]),int(ta[p]+tn[p])):expected_t += [str(ti[t]+1),str(slots[t]+1)]
        fields=[str(n),str(rows),str(len(ci))]
        for col,val,weight in zip(case['indices'],case['values'],case['weights'],strict=True):
            fields += [str(len(col)),format(weight,'.17g'),*[str(c+1) for c in col],*[format(v,'.17g') for v in val]]
        fields += [str(int(v)) for v in mask.ravel()]
        inputs.append(' '.join(fields));references.append((expected_t,dense,accepted,count))
    payload='\n'.join(inputs)+'\n';(args.out/'input.txt').write_text(payload)
    run=subprocess.run([str(args.binary)],input=payload,text=True,capture_output=True,timeout=120)
    (args.out/'output.txt').write_text(run.stdout+run.stderr)
    if run.returncode:raise RuntimeError(run.stderr+run.stdout[-1000:])
    lines=run.stdout.splitlines();assert len(lines)==2*len(cases)
    records=[]
    for k,(case,(layout,expected,accepted,count)) in enumerate(zip(cases,references,strict=True)):
        fields=lines[2*k+1].split();actual=np.array(fields[2:],float).reshape(expected.shape)
        transposed=lines[2*k].split()==layout
        passed=transposed and (int(fields[0])==int(accepted)) and int(fields[1])==count and np.array_equal(actual.view(np.uint64),expected.view(np.uint64))
        records.append(dict(n=case['n'],rows=len(case['indices']),kind=case['kind'],accepted=accepted,
                            transpose_actual_c=transposed,actual_c_bitwise=bool(passed) if accepted else None,passed=bool(passed)))
    result=dict(reference='3.15.0',cases=len(records),passed=sum(r['passed'] for r in records),
                actual_c_bitwise=sum(r['actual_c_bitwise'] is True for r in records),
                actual_c_transposes=sum(r['transpose_actual_c'] for r in records),records=records,
                failures=[r for r in records if not r['passed']],binary_sha256=sha(args.binary),
                library_sha256=sha(libpath),runner_sha256=sha(Path(__file__)),input_sha256=sha(args.out/'input.txt'),
                output_sha256=sha(args.out/'output.txt'),reference_sources={n:sha(args.reference/'src/engine'/n) for n in ['engine_util_sparse.c','engine_util_solve.c']},
                scope='Stable slot map with duplicates/zeros; full multirow Gram, single-row C accumulation path (rowsuper=NULL). Accepted cases bitwise actual C; rejection uses ordered partial-output model. No global proof, general sparse mass union or timing claim.')
    (args.out/'results.json').write_text(json.dumps(result,indent=2)+'\n');print({k:result[k] for k in ['cases','passed','actual_c_bitwise','actual_c_transposes']})
    assert not result['failures']


if __name__=='__main__':main()
