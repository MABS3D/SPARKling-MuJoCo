"""Oracle for prepared CSR rows, including equality and all elliptic cone zones."""
import argparse, ctypes, hashlib, importlib.util, json, os, subprocess
from pathlib import Path
import mujoco
import numpy as np

ROOT = Path(__file__).resolve().parents[3]

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--binary', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    args = p.parse_args()
    binary = args.binary.resolve()
    out = args.out.resolve(); out.mkdir(parents=True, exist_ok=False); os.chdir(out)
    provider = ROOT / 'experimental/constraint-solvers-candidate/tests/differential.py'
    data = provider.read_bytes(); frozen = out / 'fixtures.py'; frozen.write_bytes(data)
    spec = importlib.util.spec_from_file_location('inverse_native_rows', frozen)
    module = importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    rng = np.random.default_rng(71002)
    inputs, expected, names, rowtypes = [], [], [], set()
    for name, xml in module.fixtures():
        m = mujoco.MjModel.from_xml_string(xml.replace('jacobian="dense"', 'jacobian="sparse"'))
        d = mujoco.MjData(m)
        if name == 'joint_limit': d.qpos[0] = .08
        d.qvel[:] = rng.uniform(-.5, .5, m.nv)
        mujoco.mj_forward(m, d)
        for sample in range(12):
            acc = np.zeros(m.nv) if sample == 0 else rng.uniform(-500, 500, m.nv)
            d.qacc[:] = acc
            mujoco.mj_inverseSkip(m, d, mujoco.mjtStage.mjSTAGE_VEL, 1)
            fields = [m.nv, d.nefc]
            for i in range(d.nefc):
                native = int(d.efc_type[i]); rowtypes.add(native)
                kind = 0 if native == 0 else 1 if native in (1,2) else 3 if native == 7 else 2
                dim, mu, friction = 1, 1., np.ones(5)
                if native == 7:
                    contact = d.contact[int(d.efc_id[i])]
                    dim = int(contact.dim) if int(contact.efc_address) == i else 0
                    mu, friction = float(contact.mu), np.array(contact.friction)
                width, adr = int(d.efc_J_rownnz[i]), int(d.efc_J_rowadr[i])
                fields.extend([kind, dim, width, d.efc_R[i], d.efc_D[i], d.efc_frictionloss[i], mu,
                               *friction, d.efc_aref[i]])
                for k in range(width): fields.extend([d.efc_J_colind[adr+k], d.efc_J[adr+k]])
            fields.extend(acc)
            inputs.append(' '.join(format(float(x), '.17g') for x in fields))
            expected.append((d.efc_force.copy(), d.qfrc_constraint.copy()))
            names.append((name, sample))
    # Exact cancellation regressions: official sparse C dot plus its equality
    # response F=-J*a (D=1, aref=0), then J'F. These supplement physical rows.
    library = Path(mujoco.__file__).parent/'libmujoco.so.3.14.0'
    lib = ctypes.CDLL(str(library)); D=ctypes.c_double; I=ctypes.c_int
    lib.mju_mulMatVecSparse.argtypes=[ctypes.POINTER(D)]*3+[I]+[ctypes.POINTER(I)]*4
    lib.mju_mulMatVecSparse.restype=None
    for label, values, acc in [
        ('lane-order',[1e8,1,-1e8,1],[1e8,1,1e8,1]),
        ('zero-compression',[1e8,0,1,-1e8,1],[1e8,123,1,1e8,1]),
        ('sparse-tail2',[1e8,1,1,1,-1e8,1],[1e8,1,-1,-1,1e8,1]),
        ('sparse-tail3',[1e8,1,1,1,-1e8,1,1],[1e8,1,-1,-1,1e8,1,1]),
    ]:
        indices=[i for i,v in enumerate(values) if v!=0]; count=len(indices)
        packed=(D*count)(*(values[i] for i in indices)); vector=(D*len(acc))(*acc)
        dot=(D*1)();nnz=(I*1)(count);adr=(I*1)(0);cols=(I*count)(*indices)
        lib.mju_mulMatVecSparse(dot,packed,vector,1,nnz,adr,cols,None)
        fields=[len(acc),1,0,1,count,1.,1.,0.,1.,1.,1.,1.,1.,1.,0.]
        for i in indices:fields.extend([i,values[i]])
        fields.extend(acc);inputs.append(' '.join(format(float(x),'.17g') for x in fields))
        force=np.array([-dot[0]]);expected.append((force,np.asarray(values)*force[0]))
        names.append(('C-equality-'+label,0));rowtypes.add(0)
    encoded = str(len(inputs)) + '\n' + '\n'.join(inputs) + '\n'
    (out/'input.txt').write_text(encoded)
    run = subprocess.run([str(binary)],input=encoded,text=True,capture_output=True,timeout=120)
    (out/'output.txt').write_text(run.stdout+run.stderr)
    if run.returncode: raise RuntimeError(run.stdout[-2000:])
    lines = run.stdout.splitlines(); assert len(lines) == 2*len(expected)
    maxima, comparisons = {}, 0
    for i, ((force, projected), (name, sample)) in enumerate(zip(expected,names,strict=True)):
        f = np.fromstring(lines[2*i].partition(' ')[2],sep=' ')
        g = np.fromstring(lines[2*i+1].partition(' ')[2],sep=' ')
        for key, actual, want in [('force',f,force),('generalized',g,projected)]:
            delta = np.abs(actual-want)
            if actual.shape!=want.shape or not np.all(delta<=2e-10+2e-10*np.abs(want)):
                raise AssertionError((name,sample,key,actual,want))
            maxima[key] = max(maxima.get(key,0.),float(delta.max(initial=0.)))
            comparisons += want.size
    result = dict(reference=mujoco.__version__,cases=len(expected),comparisons=comparisons,
                  max_abs_error=maxima,row_types=sorted(rowtypes),
                  binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),
                  provider_sha256=hashlib.sha256(data).hexdigest(),
                  library_sha256=hashlib.sha256(library.read_bytes()).hexdigest(),
                  driver_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),passed=True,
                  scope='Prepared native-C row oracle; not a new model/geometry/equality producer')
    (out/'summary.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))

if __name__=='__main__':main()
