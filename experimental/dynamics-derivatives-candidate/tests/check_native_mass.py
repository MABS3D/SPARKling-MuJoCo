"""Compare the owned native mass image with pinned C, including aliased rows.

This checks raw M storage, not integrated dynamics with aliased numeric buffers.
"""
import argparse, ctypes, hashlib, importlib.util, json, subprocess
from pathlib import Path
import mujoco
import numpy as np

ROOT=Path(__file__).resolve().parents[3]
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def module(name,p):
    spec=importlib.util.spec_from_file_location(name,p)
    result=importlib.util.module_from_spec(spec);spec.loader.exec_module(result);return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--binary',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--reference',choices=['3.14.0','3.17.0'],required=True)
    p.add_argument('--samples',type=int,default=12)
    a=p.parse_args();assert mujoco.__version__==a.reference
    assert mujoco.mj_version()=={'3.14.0':3_014_000,'3.17.0':3_017_000}[a.reference]
    a.out.mkdir(parents=True,exist_ok=False)
    helpers={}
    for name,original in [
        ('derivative_fixtures.py',Path(__file__).with_name('compare.py')),
        ('admission_fixtures.py',ROOT/'experimental/alignment-3.17/tests/test_admission.py'),
        ('adhesion_fixtures.py',ROOT/'experimental/adhesion-contact-integration/tests/compare_adhesion.py')]:
        target=a.out/name;target.write_bytes(original.read_bytes());helpers[name]=digest(target)
    derivatives=module('native_mass_derivative_fixtures',a.out/'derivative_fixtures.py')
    admission=module('native_mass_admission_fixtures',a.out/'admission_fixtures.py')
    selected={'slide','hinge_motor','affine_chain','branched','ball','free','free_ball','fixed_tendon','spatial_ball'}
    fixtures=[(name,xml) for name,xml,mode in derivatives.fixtures(a.out/'adhesion_fixtures.py', a.reference) if name in selected]
    option='<option><flag constraint="disable" warmstart="disable" island="disable"/></option>'
    fixtures += [('chain',admission.CHAIN.replace('<mujoco>','<mujoco>'+option)),
        ('chain_tendons',admission.TENDONS.replace('<mujoco>','<mujoco>'+option).replace('<fixed name="a">','<fixed name="a" armature=".2">').replace('<fixed name="b">','<fixed name="b" armature=".4">'))]
    library=Path(mujoco.__file__).parent/('libmujoco.so.'+a.reference)
    validate=ctypes.CDLL(str(library)).mj_validateReferences
    validate.argtypes=[ctypes.c_void_p];validate.restype=ctypes.c_char_p
    reference_controls = []
    if a.reference == '3.17.0':
        original = next(xml for name,xml,mode in derivatives.fixtures(a.out/'adhesion_fixtures.py', '3.14.0') if name=='fixed_tendon')
        try:
            mujoco.MjModel.from_xml_string(original)
        except ValueError as error:
            assert 'ten_J_rownnz out of bounds' in str(error)
            reference_controls.append(dict(name='original_nv2_duplicate_tendon',outcome='C compiler rejected',error=str(error),
                scope='Known C reference limitation, not an Ada rejection; nv=3 variant retains repeated-joint coverage.'))
        else:raise AssertionError('Reference behavior changed; review the duplicate-tendon control')
    warnings=[]
    mujoco.set_mju_user_warning(lambda message: warnings.append(str(message)))
    records=[];failures=[]
    for name,xml in fixtures:
        variants=['original']
        if a.reference=='3.17.0':variants+=['reverse']
        if a.reference=='3.17.0' and name.startswith('chain'):variants+=['shared']
        for variant in variants:
            case=name+'-'+variant;model=mujoco.MjModel.from_xml_string(xml)
            if variant!='original':admission.rearrange_sparse(model,'M',variant)
            diagnostic=validate(model._address)
            assert diagnostic is None,(case,diagnostic)
            path=a.out/(case+'.mjb');mujoco.mj_saveModel(model,str(path))
            (a.out/(case+'.xml')).write_text(xml)
            warning_start=len(warnings)
            rng=np.random.default_rng(2602102);batch=[];expected=[]
            for i in range(a.samples):
                q=model.qpos0.copy();mujoco.mj_integratePos(model,q,rng.uniform(-.3,.3,model.nv),.08)
                v=rng.uniform(-.2,.2,model.nv);batch.append((q,v))
                data=mujoco.MjData(model);data.qpos[:]=q;data.qvel[:]=v
                mujoco.mj_forward(model,data);expected.append(data.M.copy())
            inputs=str(len(batch))+'\n'+'\n'.join(' '.join(format(float(x),'.17g') for x in np.r_[q,v]) for q,v in batch)+'\n'
            (a.out/(case+'.input')).write_text(inputs)
            run=subprocess.run([str(a.binary),str(path)],input=inputs,capture_output=True,text=True,timeout=120)
            (a.out/(case+'.output')).write_text(run.stdout+run.stderr)
            entry=dict(case=case,samples=a.samples,model_sha256=digest(path),c_valid=True,reference_warnings=warnings[warning_start:],passed=False)
            if run.returncode:entry['error']=run.stdout[-1500:]+run.stderr[-1500:]
            else:
                lines=[line.split() for line in run.stdout.splitlines()]
                assert len(lines)==len(batch) and all(tokens[0]=='M' for tokens in lines),case
                actual=np.array([[float(x) for x in tokens[1:]] for tokens in lines]);reference=np.array(expected)
                assert actual.shape==reference.shape,(case,actual.shape,reference.shape)
                np.save(a.out/(case+'-c.npy'),reference,allow_pickle=False)
                entry.update(passed=bool(np.all(np.isfinite(actual)) and np.all(np.isfinite(reference)) and np.allclose(actual,reference,atol=1e-13,rtol=1e-13)),
                    max_abs=float(np.max(np.abs(actual-reference))),atol=1e-13,rtol=1e-13)
            admission_run=subprocess.run([str(a.binary),str(path),'derivative-admission'],capture_output=True,text=True,timeout=120)
            (a.out/(case+'-admission.output')).write_text(admission_run.stdout+admission_run.stderr)
            expected_status='UNSUPPORTED_FEATURE' if variant=='shared' else 'SUCCESS'
            admission_ok=admission_run.returncode==0 and admission_run.stdout.strip()==expected_status
            entry.update(derivative_admission=dict(expected=expected_status,actual=admission_run.stdout.strip(),passed=admission_ok))
            entry['passed']=entry['passed'] and admission_ok
            records.append(entry)
            if not entry['passed']:failures.append(entry)
            print(case,entry['passed'],entry.get('max_abs',entry.get('error')),flush=True)
    control=subprocess.run([str(a.binary),str(a.out/'slide-original.mjb'),'invalid-inputs'],capture_output=True,text=True,timeout=120)
    (a.out/'invalid-inputs.output').write_text(control.stdout+control.stderr)
    boundary=dict(passed=control.returncode==0 and control.stdout.strip()=='invalid_input_checks 4',
        cases=4,exit=control.returncode,stdout=control.stdout,stderr=control.stderr,
        scope='Empty model, plausible scalar sizes without tables, missing dof_M0, inconsistent nC; both public constructors must reject without retaining borrowed state.')
    if not boundary['passed']:failures.append(dict(case='invalid_input_boundary',**boundary))
    shape_run=subprocess.run([str(a.binary),str(a.out/'slide-original.mjb'),'reader-shapes'],capture_output=True,text=True,timeout=120)
    (a.out/'reader-shapes.output').write_text(shape_run.stdout+shape_run.stderr)
    shapes=dict(passed=shape_run.returncode==0 and shape_run.stdout.strip()=='reader_shape_checks 5',
        cases=5,exit=shape_run.returncode,stdout=shape_run.stdout,stderr=shape_run.stderr,
        scope='Default pattern, nonzero output origin, short and long outputs reject with zero values; the correct output succeeds after freeing the source model and preserves the current mass cache.')
    if not shapes['passed']:failures.append(dict(case='reader_shape_boundary',**shapes))
    composite_run=subprocess.run([str(a.binary),'composite-bounds'],capture_output=True,text=True,timeout=120)
    (a.out/'composite-bounds.output').write_text(composite_run.stdout+composite_run.stderr)
    composite=dict(passed=composite_run.returncode==0 and composite_run.stdout.strip()=='composite_checks 5',
        cases=5,exit=composite_run.returncode,stdout=composite_run.stdout,stderr=composite_run.stderr,
        scope='Single body, maximum 4096-body chain/star/forest using exact power-of-two subtree counts, plus a cancellation case distinguishing the required descending rounded order.')
    if not composite['passed']:failures.append(dict(case='composite_boundary',**composite))
    result=dict(reference=a.reference,passed=not failures,cases=len(records),samples=sum(e['samples'] for e in records),
        binary_sha256=digest(a.binary),library_sha256=digest(library),runner_sha256=digest(Path(__file__)),
        helpers=helpers,reference_controls=reference_controls,invalid_input_boundary=boundary,reader_shape_boundary=shapes,composite_boundary=composite,records=records,failures=failures,
        scope='Raw native mass images only. Shared storage is not evidence of whole-step or force equivalence. No timing or whole-workspace Gold claim.')
    (a.out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    raise SystemExit(bool(failures))
if __name__=='__main__':main()
