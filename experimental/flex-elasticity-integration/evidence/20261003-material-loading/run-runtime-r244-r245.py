from pathlib import Path
import hashlib, json, subprocess

repo = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base = Path('/var/tmp/sparkling-flex-equality-step-20261003-r241-edge-frame')
roots = [Path('/var/tmp/sparkling-flex-equality-step-20261003-r244-material-validation'),
         Path('/var/tmp/sparkling-flex-equality-step-20261003-r245-material-release')]
profiles = ['validation', 'release']
python = '/var/tmp/sparkling-movement-env/bin/python'
expected = json.loads((base/'manifest.json').read_text())['sources']
receipt = Path('/var/tmp/sparkling-flex-material-runtime-20261003.json')
results = dict(base=str(base), base_manifest_sha256=hashlib.sha256((base/'manifest.json').read_bytes()).hexdigest(),
               profiles=[], production_applied=False, timing_executed=False,
               claim='Frozen material-loading candidate: runtime comparison and malformed-model admission only; no whole-loader Gold or performance claim.')
for root, profile in zip(roots, profiles):
    subprocess.run(['python3', str(repo/'experimental/flex-elasticity-integration/tests/build_constrained.py'),
                    '--base', str(base), '--out', str(root), '--mode', profile], cwd=repo, check=True)
    manifest = json.loads((root/'manifest.json').read_text())
    assert manifest['sources'] == expected, 'Frozen source/project/test closure changed'
    for name, digest in expected.items():
        assert hashlib.sha256((root/'source'/name).read_bytes()).hexdigest() == digest, name
    binary = root/'build'/profile/'bin/flex_constrained_probe'
    binary_hash = hashlib.sha256(binary.read_bytes()).hexdigest()
    assert binary_hash == manifest['binary_sha256']
    row = dict(profile=profile, build=str(root), source_files=len(expected),
               manifest_sha256=hashlib.sha256((root/'manifest.json').read_bytes()).hexdigest(),
               binary_sha256=binary_hash, suites={})
    results['profiles'].append(row)
    for driver, suite in [('check_flex_load.py', 'admission'),
                          ('compare_equality_constrained.py', 'equalities'),
                          ('compare_constrained.py', 'contacts')]:
        command = [python, str(root/'source/experimental/flex-elasticity-integration/tests'/driver),
                   '--binary', str(binary), '--out', str(root/suite)]
        if suite != 'admission':
            command += ['--steps', '100']
        with (root/(suite+'.log')).open('w') as log:
            run = subprocess.run(command, cwd=repo, stdout=log, stderr=subprocess.STDOUT)
        result = json.loads((root/suite/'results.json').read_text())
        row['suites'][suite] = result
        receipt.write_text(json.dumps(results, indent=2)+'\n')
        assert run.returncode == 0 and result['passed'], (profile, suite, run.returncode, result)
        if suite == 'admission':
            assert [r['name'] for r in result['records']] == ['welded', 'slides', 'shared', 'free', 'zero_dofs']
        print(json.dumps(dict(profile=profile, suite=suite, passed=result['passed'],
                              cases=result.get('cases'), checks=result.get('checks'))), flush=True)
left, right = roots
results['profile_identical_files'] = []
for suite in ('admission', 'equalities', 'contacts'):
    a = {p.name:p for p in (left/suite).iterdir()
         if p.suffix in ('.mjb', '.xml', '.input', '.json', '.output') and p.name != 'results.json'}
    b = {p.name:p for p in (right/suite).iterdir()
         if p.suffix in ('.mjb', '.xml', '.input', '.json', '.output') and p.name != 'results.json'}
    assert a.keys() == b.keys(), suite
    for name in a:
        assert a[name].read_bytes() == b[name].read_bytes(), (suite, name, 'profile bytes differ')
    results['profile_identical_files'].append(dict(suite=suite, identical_files=len(a)))
results['complete'] = True
receipt.write_text(json.dumps(results, indent=2)+'\n')
print(json.dumps(dict(complete=True, source_files=len(expected),
                      profile_identical_files=results['profile_identical_files'])), flush=True)
