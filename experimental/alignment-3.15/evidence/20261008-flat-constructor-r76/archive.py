from pathlib import Path
import hashlib, json, re, shutil, gzip

root = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
base = Path('/var/tmp')
evidence = root/'experimental/alignment-3.15/evidence'
dest = evidence/'20261008-flat-constructor-r76'
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def copy(p, q):
    q.parent.mkdir(parents=True, exist_ok=True)
    assert not q.exists(), q
    shutil.copyfile(p, q)
def write(p, d):
    p.parent.mkdir(parents=True, exist_ok=True)
    assert not p.exists(), p
    p.write_text(json.dumps(d, indent=2)+'\n')
def canonical(s): return re.sub(r'\s+', '', re.sub(r'--[^\n]*', '', s))
def fragment(s, n):
    m = re.search(r'^   (?:procedure|function) '+n+r'\b', s, re.M)
    if not m: return None
    end = re.search(r'^   (?:procedure|function) \w+\b|^end MJ\.', s[m.end():], re.M)
    return s[m.start():m.end()+end.start()] if end else s[m.start():]
inventory = json.loads((evidence/'inventory.json').read_text())
old = dict(inventory['files'])
assert len(old) == 4408
for n, h in old.items(): assert sha(evidence/n) == h, n
assert not dest.exists()
unit = Path('experimental/constraint-solvers-candidate/src/mj-constraint_solvers-packed_cholesky')
engines = {}
for stage in range(68, 77):
    engine = base/f'sparkling-alignment-315-flat-engine-proof-r{stage}-20261008'
    m = json.loads((engine/'manifest.json').read_text())
    assert all(sha(engine/'source'/n) == h for n, h in m['sources'].items())
    engines[sha(engine/'manifest.json')] = (stage, engine)
    out = dest/'source'/engine.name
    copy(engine/'manifest.json', out/'manifest.json')
    for suffix in ['.ads', '.adb']: copy(engine/'source'/unit.with_suffix(suffix), out/unit.with_suffix(suffix).name)
    sparse = unit.with_name('mj-constraint_solvers-sparse_cholesky.ads')
    copy(engine/'source'/sparse, out/sparse.name)
current = base/'sparkling-alignment-315-flat-engine-proof-r76-20261008'
sources = json.loads((current/'manifest.json').read_text())['sources']
for suffix in ['.ads', '.adb']:
    assert sha(root/unit.with_suffix(suffix)) == sources[str(unit.with_suffix(suffix))]
attempts = []
selected = {}
for receipt in sorted(base.glob('sparkling-alignment-315-flat-*-scope-r*-20261008/results.json')):
    stage = int(re.search(r'-r(\d+)', receipt.parent.name)[1])
    if stage not in range(68, 77): continue
    d = json.loads(receipt.read_text())
    assert d['manifest_sha256'] in engines
    runner = (base/f'sparkling-flat-runner-r{stage}.py' if stage in [68, 69, 70] else
              base/'sparkling-flat-runner-r73.py' if stage in [71, 72, 73] else
              base/'sparkling-flat-runner-r75.py' if stage in [74, 75] else
              root/'experimental/alignment-3.15/tests/prove_flex.py')
    assert sha(runner) == d['runner_sha256'], (stage, runner)
    assert d['runner_source_unchanged'] and d['guard_source_unchanged'] and d['source_hashes_unchanged']
    out = dest/'attempts'/receipt.parent.name
    for n in ['results.json', 'proof.log', 'unit.spark.json']:
        if (receipt.parent/n).exists(): copy(receipt.parent/n, out/n)
    copy(runner, out/'prove_flex.py')
    scope = d['subprogram'].removeprefix('Packed_')
    record = dict(stage=stage, scope=scope, receipt=receipt.parent.name, checks=d.get('checks'),
                  passed=d['passed'], closed=d.get('obligations_closed', False), open=len(d.get('open', [])), warnings=d['warnings'])
    attempts.append(record)
    if scope == 'Valid' and d['obligations_closed']:
        assert all(w['file'] == 'mj-constraint_solvers-sparse_cholesky.adb' and w['line'] == 363 and w['rule'] == 'imprecise-call' for w in d['warnings'])
        write(dest/'validator-totality.json', dict(receipt=record, owned_checks_closed=True, unrelated_existing_sqrt_warning_preserved=True))
    if not (d['passed'] and d['obligations_closed'] and not d['warnings']): continue
    engine = engines[d['manifest_sha256']][1]
    same = True
    owner = unit.with_name('mj-constraint_solvers-sparse_cholesky') if scope == 'Valid' else unit
    for suffix in ['.ads', '.adb']:
        a = fragment((engine/'source'/owner.with_suffix(suffix)).read_text(), scope)
        b = fragment((current/'source'/owner.with_suffix(suffix)).read_text(), scope)
        same &= (a is None and b is None) or bool(a and b and canonical(a) == canonical(b))
    if same and (scope not in selected or stage > selected[scope]['stage']):
        selected[scope] = dict(record, owned_contract_body_identical=True)
write(dest/'attempts.json', attempts)
write(dest/'selected-owned-proofs.json', dict(scopes=list(selected.values()), checks=sum(r['checks'] for r in selected.values()),
      claim='Individual scoped proofs whose owned contract/body match r76. Dependency closure is reported separately; this is not whole-package Gold.'))
names = set()
for suffix in ['.ads', '.adb']:
    names.update(re.findall(r'^   (?:procedure|function) (\w+)\b', (current/'source'/unit.with_suffix(suffix)).read_text(), re.M))
dependencies = []
for name, record in selected.items():
    engine = base/f'sparkling-alignment-315-flat-engine-proof-r{record["stage"]}-20261008'
    owned = '\n'.join(fragment((current/'source'/unit.with_suffix(suffix)).read_text(), name) or '' for suffix in ['.ads', '.adb'])
    deps = {}
    for dep in sorted(names-{name}):
        if not re.search(r'\b'+dep+r'\b', owned): continue
        same = True
        for suffix in ['.ads', '.adb']:
            a = fragment((engine/'source'/unit.with_suffix(suffix)).read_text(), dep)
            b = fragment((current/'source'/unit.with_suffix(suffix)).read_text(), dep)
            same &= (a is None and b is None) or bool(a and b and canonical(a) == canonical(b))
        deps[dep] = dict(definition_matches_proved_context=bool(same), owned_closed_scope_available=dep in selected)
    before = json.loads((engine/'manifest.json').read_text())['sources']
    changes = [n for n,h in before.items() if sources.get(n) != h]
    external_same = all(n in [str(unit.with_suffix('.ads')), str(unit.with_suffix('.adb'))] for n in changes)
    dependencies.append(dict(scope=name, dependencies=deps, source_changes=changes,
                             all_direct_definitions_match=all(d['definition_matches_proved_context'] for d in deps.values()),
                             external_sources_identical=external_same))
write(dest/'dependencies.json', dict(scopes=dependencies,
    claim='Direct definition/source audit. Missing owned scope receipts may be covered by older archived closure; no whole-package Gold inferred.'))
copy(root/'experimental/alignment-3.15/tests/prove_flex.py', dest/'prove_flex.py')
copy(root/'experimental/alignment-3.15/tests/build_flex.py', dest/'build_flex.py')
copy(root/'experimental/alignment-3.15/tests/build_packed.py', dest/'build_packed.py')
copy(root/'tools/guarded.py', dest/'guarded.py')
copy(Path(__file__), dest/'archive.py')
native = base/'sparkling-alignment-315-flat-native-r76-20261008'
assert json.loads((native/'results.json').read_text())['complete']
cases = json.loads((native/'cases/results.json').read_text())
assert cases['passed'] == cases['cases'] == 395
native_sources = json.loads((native/'manifest.json').read_text())['sources']
assert all(native_sources.get(n) == h for n, h in sources.items())
for p in native.iterdir():
    if p.is_file(): copy(p, dest/'native'/p.name)
for p in native.joinpath('cases').iterdir():
    if p.is_file() and p.name in ['results.json', 'reference.c', 'test_sparse_cholesky.py']:
        copy(p, dest/'native/cases'/p.name)
for name in ['input.txt', 'output.txt']:
    p = native/'cases'/name
    q = dest/'native/cases'/(name+'.gz')
    q.parent.mkdir(parents=True, exist_ok=True)
    q.write_bytes(gzip.compress(p.read_bytes(), mtime=0))
    assert gzip.decompress(q.read_bytes()) == p.read_bytes()
for name in ['packed_cholesky_probe.adb', 'test_sparse_cholesky.py']:
    copy(native/'source/experimental/constraint-solvers-candidate/tests'/name, dest/'native'/name)
copy(native/'source/experimental/constraint-solvers-candidate/solvers.gpr', dest/'native/solvers.gpr')
pending = [r for r in attempts if r['stage'] == 76 and not r['closed']]
write(dest/'results.json', dict(reference='3.15.0', source_count=len(sources), native_passed=395,
    selected_scope_checks=sum(r['checks'] for r in selected.values()), selected_scopes=len(selected),
    pending=pending, goal_complete=False, whole_factor_functional_closed=False, whole_backsolve_functional_closed=False,
    scope='Proof engineering of exact flat CSR/CSC conversion and malformed CSC validation fix. No new performance claim.'))
for n, h in old.items(): assert sha(evidence/n) == h, n
for p in dest.rglob('*'):
    if p.is_file(): inventory['files'][str(p.relative_to(evidence))] = sha(p)
inventory['count'] = inventory['current_entries'] = len(inventory['files'])
inventory['constructor_prior_entries_preserved'] = len(old)
(evidence/'inventory.json').write_text(json.dumps(inventory, indent=2)+'\n')
for n, h in inventory['files'].items(): assert sha(evidence/n) == h, n
print(json.dumps(dict(entries=inventory['count'], prior_preserved=len(old), scopes=len(selected), checks=sum(r['checks'] for r in selected.values()))))
