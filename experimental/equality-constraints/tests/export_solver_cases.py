#!/usr/bin/env python3
"""Freeze failing equality problems for isolated native/Ada solver diagnosis."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import mujoco
import numpy as np
from compare import dense_jacobian
from compare_step import step_compare


def native_jacobian_storage(m, d):
    """Retain C's actual sparse slots, including zeros and duplicate columns."""
    if not mujoco.mj_isSparse(m):
        return dict(layout='dense', rows=int(d.nefc), columns=int(m.nv),
                    values=np.asarray(d.efc_J).reshape(d.nefc, m.nv).tolist())
    addresses = np.asarray(d.efc_J_rowadr[:d.nefc], dtype=np.int64)
    widths = np.asarray(d.efc_J_rownnz[:d.nefc], dtype=np.int64)
    used = int(np.max(addresses+widths, initial=0))
    columns = np.asarray(d.efc_J_colind[:used], dtype=np.int64)
    values = np.asarray(d.efc_J[:used], dtype=np.float64)
    assert len(columns) == len(values) == used
    assert np.all(addresses >= 0) and np.all(widths >= 0)
    assert np.all((columns >= 0) & (columns < m.nv))
    return dict(layout='sparse', rows=int(d.nefc), columns=int(m.nv),
                rowadr=addresses.tolist(), rownnz=widths.tolist(),
                colind=columns.tolist(), values=values.tolist(),
                stored_zeros=int(np.count_nonzero(values == 0.0)))


def native_mass_storage(m, d):
    """Retain the native lower CSR and its mj_factorI factors unchanged.

    MuJoCo 3.14 stores M/qLD using the model's M_* CSR arrays, with the
    diagonal last in each row. dof_Madr describes an older layout and is not
    a substitute for these addresses. Structural zero slots are retained.
    """
    addresses=np.asarray(m.M_rowadr,dtype=np.int64)
    widths=np.asarray(m.M_rownnz,dtype=np.int64)
    columns=np.asarray(m.M_colind,dtype=np.int64)
    values=np.asarray(d.M,dtype=np.float64)
    factors=np.asarray(d.qLD,dtype=np.float64)
    inverse=np.asarray(d.qLDiagInv,dtype=np.float64)
    assert len(addresses)==len(widths)==len(inverse)==m.nv
    assert len(columns)==len(values)==len(factors)==m.nC
    assert np.all(addresses>=0) and np.all(widths>0)
    assert np.all(addresses+widths<=m.nC)
    for r in range(m.nv):
        row=columns[addresses[r]:addresses[r]+widths[r]]
        assert row[-1]==r and np.all(row[:-1]<r) and np.all(np.diff(row)>0)
    return dict(layout='lower-csr',rows=int(m.nv),entries=int(m.nC),
        rowadr=addresses.tolist(),rownnz=widths.tolist(),colind=columns.tolist(),
        values=values.tolist(),qLD=factors.tolist(),qLDiagInv=inverse.tolist(),
        simplenum=np.asarray(m.dof_simplenum,dtype=np.int64).tolist(),
        stored_zeros=int(np.count_nonzero(values==0.0)))


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--results', type=Path, required=True)
    ap.add_argument('--binary', type=Path, required=True)
    ap.add_argument('--out', type=Path, required=True)
    args = ap.parse_args(); args.out.mkdir(parents=True, exist_ok=False)
    assert mujoco.__version__ == '3.14.0'
    root = args.results.parent
    failures = json.loads(args.results.read_text())['failures']
    records = []
    for fail in failures:
        name = fail['model']; m = mujoco.MjModel.from_binary_path(str(root/(name+'.mjb')))
        tokens = np.fromstring((root/(name+'.input')).read_text(), sep=' ')
        width = 1+m.nq+2*m.nv+m.nu+m.na+6*m.nbody
        samples = tokens[2:].reshape(int(tokens[0]), width)
        selected = [fail['sample']] if 'sample' in fail else range(len(samples))
        for sample in selected:
            values = samples[sample].copy()
            if 'sample' not in fail and name.startswith('PGS'):
                def replay(steps):
                    text = f'1 {steps}\n'+' '.join(format(v, '.17g') for v in values)+'\n'
                    run = subprocess.run([str(args.binary), str(root/(name+'.mjb')), 'loads'],
                        input=text, text=True, capture_output=True, timeout=60)
                    return run, text
                run, text = replay(int(tokens[1]))
                if not run.returncode:
                    continue
                lo, hi = 0, int(tokens[1])
                while hi-lo > 1:
                    mid = (lo+hi)//2
                    trial, unused = replay(mid)
                    if trial.returncode: hi = mid
                    else: lo = mid
                previous, unused = replay(lo)
                state = step_compare.parse(previous.stdout, m.nv)[0]['state']
                values[0] = state[-1]; values[1:1+m.nq+m.nv] = state[:-1]
                (args.out/(name+f'-{sample}-failed.output')).write_text(run.stdout+run.stderr)
                stage = dict(first_failing_step=hi, previous_successful_steps=lo)
            else:
                stage = dict(first_failing_step=0)
            d = mujoco.MjData(m); off = 1
            d.time = values[0]
            d.qpos[:] = values[off:off+m.nq]; off += m.nq
            d.qvel[:] = values[off:off+m.nv]; off += m.nv
            d.qfrc_applied[:] = values[off:off+m.nv]; off += m.nv
            d.ctrl[:] = values[off:off+m.nu]; off += m.nu
            d.act[:] = values[off:off+m.na]; off += m.na
            d.xfrc_applied[:] = values[off:].reshape(m.nbody, 6)
            mujoco.mj_forward(m, d)
            mass = np.empty((m.nv,m.nv)); mujoco.mj_fullM(m, d, mass)
            # Constraint solve uses qM; implicit Euler damping is applied in Advance.
            rows = []
            for i in range(d.nefc):
                kind = int(d.efc_type[i])
                # This corpus has equality, dof friction, unilateral/contact rows.
                form = 0 if kind==0 else 1 if kind in (1,2) else 2
                assert kind != 7, 'elliptic needs a cone block'
                rows.append([form,1,float(d.efc_R[i]),float(d.efc_D[i]),float(d.efc_frictionloss[i]),1.,1.,1.,1.,1.,1.])
            p = dict(M=mass.tolist(), J=dense_jacobian(m,d).tolist(), free=d.qacc_smooth.tolist(),
                     ref=d.efc_aref.tolist(), a0=d.qacc_smooth.tolist(), f0=np.zeros(d.nefc).tolist(), rows=rows,
                     method=int(m.opt.solver), iterations=int(m.opt.iterations), ls_iterations=int(m.opt.ls_iterations),
                     tolerance=float(m.opt.tolerance), scale=1/(m.stat.meaninertia*m.nv))
            records.append(dict(model=name,sample=sample,**stage,problem=p,
                native_jacobian=native_jacobian_storage(m, d),
                native_smooth_force=d.qfrc_smooth.tolist(),
                native_mass=native_mass_storage(m, d),
                model_sha256=hashlib.sha256((root/(name+'.mjb')).read_bytes()).hexdigest(),
                input_sha256=hashlib.sha256((root/(name+'.input')).read_bytes()).hexdigest(),
                expected_acceleration=d.qacc.tolist(), expected_force=d.efc_force.tolist(),
                native_iterations=int(d.solver_niter[0]), state=values.tolist()))
    (args.out/'problems.json').write_text(json.dumps(records,indent=2)+'\n')
    library = next(Path(mujoco.__file__).parent.glob('libmujoco.so.*'))
    provenance = dict(reference=mujoco.__version__,
        library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
        binary_sha256=hashlib.sha256(args.binary.read_bytes()).hexdigest(),
        results_sha256=hashlib.sha256(args.results.read_bytes()).hexdigest(),
        script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        problems_sha256=hashlib.sha256((args.out/'problems.json').read_bytes()).hexdigest(),
        cases=len(records), scope='native solver replay; not integrated Ada row input')
    (args.out/'export_metadata.json').write_text(json.dumps(provenance,indent=2)+'\n')
    print('exported',len(records),'assembled problems')


if __name__=='__main__':
    main()
