from pathlib import Path
import importlib.util,subprocess,hashlib,json,re
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
w=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('m',repo/'tools/compare_matrices.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
report={'complete':False,'profiles':{},'native_simd_release':{}}
for mode in ['development','validation','release']:
 full=(w/f'final-tests-{mode}.log').read_text();extended=(w/f'final-matrix-extended-{mode}.log').read_text()
 assert 'All 10 declared Ada tests, Python tests and matrix/vector/BLAS comparisons passed' in full
 assert f'MATRICES {mode}: 523 cases, 543296' in extended
 assert f'TRANSPOSE {mode}: 30 large/boundary cases, 134485' in extended
 comparisons={name:{'cases':int(cases),'scalar_comparisons':int(count)} for name,cases,count in re.findall(r'(BLAS|VECTORS|MATRICES) \w+: (\d+) cases, (\d+) scalar comparisons passed',full)}
 comparisons['TRANSPOSE']={'cases':30,'scalar_comparisons':134485,'scope':'only Transpose at large/boundary dimensions'}
 report['profiles'][mode]={'ada_assertions_passed':1097,'python_tests':72,'comparisons':comparisons,'matrix_probe_sha256':hashlib.sha256(Path(f'/var/tmp/sparkling-matrix-round2/runtime-{mode}/bin/matrix_probe').read_bytes()).hexdigest()}
assert 'Ran 72 tests' in (w/'final-python-extended.log').read_text() and (w/'final-python-extended.log').read_text().rstrip().endswith('OK')
ada=Path('/var/tmp/sparkling-matrix-round2/runtime-release/bin/matrix_probe');c=Path('/var/tmp/sparkling-matrix-round2/matrix_reference_native')
for name,rows,args in [('all_matrix_operations',m.cases(),[]),('transpose_large_boundary',m.transpose_cases(),['--transpose-only'])]:
 data=m.serialize(rows)
 outputs=[subprocess.run([str(p),*args],input=data,capture_output=True,text=True,check=True,timeout=60).stdout for p in [ada,c]]
 count=m.compare(rows,*outputs,transpose_only=bool(args))
 report['native_simd_release'][name]={'cases':len(rows),'exact_finite_scalar_comparisons':count}
 print(name,len(rows),count)
report['native_simd_release'].update(ada_binary_sha256=hashlib.sha256(ada.read_bytes()).hexdigest(),c_binary_sha256=hashlib.sha256(c.read_bytes()).hexdigest())
report['source_sha256']={name:hashlib.sha256((repo/name).read_bytes()).hexdigest() for name in ['src/mj-matrices.adb','src/mj-matrices.ads','tools/compare_matrices.py','tests/matrix_probe.adb','tests/matrix_reference.c']}
report['scope']='1097 Ada assertions and 72 Python tests per original profile; extended probes/generator separately rebuilt and compared in all three profiles, with the 72 Python tests repeated after their change. Kernel sources unchanged throughout.'
report['complete']=True
(w/'final-numeric.json').write_text(json.dumps(report,indent=2)+'\n')
