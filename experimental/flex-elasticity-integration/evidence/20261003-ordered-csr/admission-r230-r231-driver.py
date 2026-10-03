from pathlib import Path
import hashlib,json,subprocess
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base=Path('/var/tmp/sparkling-flex-equality-step-20261003-r229-admission-tests')
prior=Path('/var/tmp/sparkling-flex-equality-step-20261003-r225-allocation')
roots=[Path('/var/tmp/sparkling-flex-equality-step-20261003-r230-validation-admission'),Path('/var/tmp/sparkling-flex-equality-step-20261003-r231-release-admission')]
profiles=['validation','release'];receipts=[]
expected=json.loads((base/'manifest.json').read_text())['sources']
old=json.loads((prior/'manifest.json').read_text())['sources']
changed=sorted(n for n in expected.keys()|old.keys() if expected.get(n)!=old.get(n))
assert changed==['experimental/flex-elasticity-integration/tests/flex_load_checks.adb'],changed
for root,profile in zip(roots,profiles):
    subprocess.run(['python3',str(repo/'experimental/flex-elasticity-integration/tests/build_constrained.py'),'--base',str(base),'--out',str(root),'--mode',profile],cwd=repo,check=True)
    actual=json.loads((root/'manifest.json').read_text())['sources'];assert actual==expected
    for name,h in actual.items():assert hashlib.sha256((root/'source'/name).read_bytes()).hexdigest()==h,name
    binary=root/'build'/profile/'bin/flex_constrained_probe'
    tests=root/'source/experimental/flex-elasticity-integration/tests'
    with (root/'admission.log').open('w') as log:
        subprocess.run(['/var/tmp/sparkling-movement-env/bin/python',str(tests/'check_flex_load.py'),'--binary',str(binary),'--out',str(root/'admission')],cwd=repo,stdout=log,stderr=subprocess.STDOUT,check=True)
    result=json.loads((root/'admission/results.json').read_text());assert result['passed'] and result['checks']==164,result
    receipts.append({'profile':profile,'source_files':len(actual),'result':result})
    print(json.dumps({'profile':profile,'checks':result['checks'],'passed':result['passed']}),flush=True)
a,b=roots
left={p.name:p for p in (a/'admission').iterdir() if p.suffix in ('.mjb','.xml','.output')}
right={p.name:p for p in (b/'admission').iterdir() if p.suffix in ('.mjb','.xml','.output')}
assert left.keys()==right.keys()
for name in left:assert left[name].read_bytes()==right[name].read_bytes(),name
result={'profiles':receipts,'only_changed_source_from_r225':changed,'profile_identical_files':len(left),'production_applied':False,'runtime_scope':'Admission only, including duplicate/unsorted CSR and restore; unchanged implementation separately exercised by r227/r228 full corpora.'}
Path('/var/tmp/sparkling-flex-ordered-admission-20261003.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'identical_files':len(left)}),flush=True)
