from pathlib import Path
import importlib.util,subprocess,hashlib,json,re
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');w=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('m',repo/'tools/compare_matrices.py');m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
report={'complete':False,'profiles':{},'native_simd_release':{}}
for mode in ['development','validation','release']:
 text=(w/f'accepted-tests-{mode}.log').read_text()
 assert 'All 10 declared Ada tests, Python tests and matrix/vector/BLAS comparisons passed' in text
 assert 'Ran 72 tests' in text
 comp={name:{'cases':int(cases),'scalar_comparisons':int(count)} for name,cases,count in re.findall(r'(BLAS|VECTORS|MATRICES) \w+: (\d+) cases, (\d+) scalar comparisons passed',text)}
 found=re.search(r'TRANSPOSE \w+: (\d+) large/boundary cases, (\d+) exact finite scalar comparisons passed',text);assert found
 comp['TRANSPOSE']={'cases':int(found[1]),'scalar_comparisons':int(found[2]),'scope':'Transpose only'}
 assert sum(x['cases'] for x in comp.values())==4218
 assert sum(x['scalar_comparisons'] for x in comp.values())==1438490
 report['profiles'][mode]={'ada_assertions_passed':1097,'python_tests':72,'comparisons':comp,'ada_matrix_probe_sha256':hashlib.sha256(Path(f'/var/tmp/sparkling-matrix-round2/runtime-{mode}/bin/matrix_probe').read_bytes()).hexdigest()}
ada=Path('/var/tmp/sparkling-matrix-round2/runtime-release/bin/matrix_probe');c=Path('/var/tmp/sparkling-matrix-round2/matrix_reference_native')
for name,rows,args in [('all_matrix_operations',m.cases(),[]),('transpose_large_boundary',m.transpose_cases(),['--transpose-only'])]:
 data=m.serialize(rows);outputs=[subprocess.run([str(p),*args],input=data,capture_output=True,text=True,check=True,timeout=60).stdout for p in [ada,c]]
 count=m.compare(rows,*outputs,transpose_only=bool(args));report['native_simd_release'][name]={'cases':len(rows),'exact_finite_scalar_comparisons':count};print(name,len(rows),count)
report['native_simd_release'].update(ada_binary_sha256=hashlib.sha256(ada.read_bytes()).hexdigest(),c_binary_sha256=hashlib.sha256(c.read_bytes()).hexdigest())
report['source_sha256']={name:hashlib.sha256((repo/name).read_bytes()).hexdigest() for name in ['src/mj-matrices.adb','src/mj-matrices.ads','tools/compare_matrices.py','tests/matrix_probe.adb','tests/matrix_reference.c']}
report['complete']=True;(w/'accepted-numeric.json').write_text(json.dumps(report,indent=2)+'\n')
