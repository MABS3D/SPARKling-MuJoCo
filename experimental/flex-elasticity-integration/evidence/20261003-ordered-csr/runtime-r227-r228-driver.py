from pathlib import Path
import hashlib,json,os,subprocess,sys
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base=Path('/var/tmp/sparkling-flex-equality-step-20261003-r225-allocation')
roots=[Path('/var/tmp/sparkling-flex-equality-step-20261003-r227-validation'),Path('/var/tmp/sparkling-flex-equality-step-20261003-r228-release')]
profiles=['validation','release']
python='/var/tmp/sparkling-movement-env/bin/python'
rows=[]
for root,profile in zip(roots,profiles):
    command=['python3',str(repo/'experimental/flex-elasticity-integration/tests/build_constrained.py'),'--base',str(base),'--out',str(root),'--mode',profile]
    subprocess.run(command,cwd=repo,check=True)
    actual=json.loads((root/'manifest.json').read_text())['sources']
    expected=json.loads((base/'manifest.json').read_text())['sources']
    assert actual==expected,'Frozen implementation, project and test closure differs'
    for name,h in actual.items():
        assert hashlib.sha256((root/'source'/name).read_bytes()).hexdigest()==h,name
    binary=root/'build'/profile/'bin/flex_constrained_probe'
    tests=root/'source/experimental/flex-elasticity-integration/tests'
    profile_results={}
    for driver,leaf in [('check_flex_load.py','admission'),('compare_equality_constrained.py','equalities'),('compare_constrained.py','contacts')]:
        out=root/leaf
        command=[python,str(tests/driver),'--binary',str(binary),'--out',str(out)]
        if leaf!='admission':command+=['--steps','100']
        with (root/(leaf+'.log')).open('w') as log:
            run=subprocess.run(command,cwd=repo,stdout=log,stderr=subprocess.STDOUT)
        assert run.returncode==0,(profile,leaf,run.returncode)
        profile_results[leaf]=json.loads((out/'results.json').read_text())
        print(json.dumps({'profile':profile,'suite':leaf,'passed':profile_results[leaf].get('passed'),'cases':profile_results[leaf].get('cases'),'checks':profile_results[leaf].get('checks')}),flush=True)
    rows.append({'profile':profile,'source_files':len(actual),'binary_sha256':hashlib.sha256(binary.read_bytes()).hexdigest(),'suites':profile_results})
left,right=roots
files=[]
for suite in ('admission','equalities','contacts'):
    a={str(p.relative_to(left/suite)):p for p in (left/suite).iterdir() if p.suffix in ('.mjb','.xml','.input','.json','.output') and p.name!='results.json'}
    b={str(p.relative_to(right/suite)):p for p in (right/suite).iterdir() if p.suffix in ('.mjb','.xml','.input','.json','.output') and p.name!='results.json'}
    assert set(a)==set(b),(suite,'filenames differ')
    for name in a:assert a[name].read_bytes()==b[name].read_bytes(),(suite,name,'bytes differ')
    files.append({'suite':suite,'identical_files':len(a)})
result={'profiles':rows,'profile_identical_files':files,'source_equal':True,'production_applied':False,'claim':'Runtime correctness of the frozen ordered CSR / private loader candidate; no timing or full constructor Gold claim.'}
Path('/var/tmp/sparkling-flex-ordered-runtime-20261003.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({'complete':True,'source_files':rows[0]['source_files'],'profile_identical_files':files}),flush=True)
