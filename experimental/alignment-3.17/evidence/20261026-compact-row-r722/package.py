from pathlib import Path
import hashlib, json, re, shutil, zipfile

R = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
E = R / 'experimental/alignment-3.17/evidence'
D = E / '20261026-compact-row-r722'
Z = D / 'compact-row.zip'
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p, x):
    p.write_text(json.dumps(x, indent=2) + '\n')
def get(name):
    return json.loads((Path('/var/tmp') / name / 'results.json').read_text())

def main():
    D.mkdir(exist_ok=False)
    shutil.copy2(__file__, D / 'package.py')
    minimum = get('sparkling-compact-point-min-r707-20261026')
    dispatch = get('sparkling-compact-dispatch-min-r712-20261026')
    unit = get('sparkling-compact-point-unit-r713-20261026')
    refined_dispatch = get('sparkling-compact-long16-dispatch-r717-20261026')
    assert minimum['passed'] and minimum['checks'] == 89
    assert dispatch['passed'] and dispatch['checks'] == 44
    assert unit['obligations_closed'] and unit['checks'] == 249 and len(unit['warnings']) == 5 and not unit['open']
    assert refined_dispatch['passed'] and refined_dispatch['checks'] == 44
    for name in ['sparkling-compact-point-corpus-r714-20261026', 'sparkling-compact-long16-corpus-r719-20261026']:
        x = get(name)
        assert x['passed'] and all(y['output'] == 'passed 59621 disjoint row cases' for y in x['records'])
    runs = {}
    for name in ['sparkling-compact-point-movement-r715-20261026', 'sparkling-compact-long16-movement-r720-20261026']:
        x = json.loads((Path('/var/tmp') / name / 'replicas/results.json').read_text())
        assert x['passed'] and x['replicas'] == 6 and len(x['records']) == 9
        runs[name] = x
    runtime = {n: sha(R/n) for n in ['experimental/smooth/src/mj-solver_kernels.adb', 'experimental/smooth/src/mj-smooth_math.adb']}
    assert runtime == json.loads((E/'20261026-row-boundaries-and-profile/source-binding.json').read_text())['runtime_owners']
    roots = []
    for p in sorted(Path('/var/tmp').iterdir()):
        m = re.search(r'-r(\d+)-20261026$', p.name)
        if p.is_dir() and p.name.startswith('sparkling-') and m and 641 <= int(m[1]) <= 721:
            roots.append(p)
    assert len(roots) > 30
    members = {}
    excluded = {'obj', 'analysis', '__pycache__', '.git'}
    with zipfile.ZipFile(Z, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        def put(p, name):
            assert name not in members
            data = p.read_bytes()
            members[name] = hashlib.sha256(data).hexdigest()
            z.writestr(name, data)
        for folder in roots:
            for p in sorted(folder.rglob('*')):
                if p.is_file() and not set(p.relative_to(folder).parts) & excluded:
                    put(p, folder.name + '/' + p.relative_to(folder).as_posix())
        for p in sorted(Path('/tmp').glob('sparkling-*.py')):
            m = re.search(r'-r(\d+)\.py$', p.name)
            if m and 641 <= int(m[1]) <= 721:
                put(p, 'recipes/' + p.name)
        p = Path('/var/tmp/sparkling-publish-raw-cleanup-20261026.json')
        put(p, 'cleanup/' + p.name)
        put(Path(__file__), 'recipes/package.py')
    with zipfile.ZipFile(Z) as z:
        assert z.testzip() is None
        assert all(hashlib.sha256(z.read(n)).hexdigest() == h for n,h in members.items())
    dump(D/'archive-manifest.json', dict(files=members, zip_sha256=sha(Z), zip_bytes=Z.stat().st_size,
        roots=[str(p) for p in roots], excluded='Only generated obj/analysis/Python caches. Frozen inputs, complete copied SPARK reports, failures, logs, binaries and raw measurements retained. External reference/toolchain dependencies retain pinned hashes and are not newly embedded.'))
    dump(D/'summary.json', dict(adopted=False, runtime_owners_unchanged=runtime,
        r706_minimum=dict(checks=89, warnings=0, result_sha256=sha(Path('/var/tmp/sparkling-compact-point-min-r707-20261026/results.json'))),
        r706_dispatch=dict(checks=44, warnings=0),
        r706_whole_unit=dict(checks=249, warnings=5, obligations_closed=True, reference='C3.17 candidate closure only'),
        refined_r716=dict(dispatch_checks=44, whole_unit='Not run; predecessor proof does not prove the changed whole unit', adopted=False),
        row_cases_per_profile=59621, movement_runs=list(runs),
        conclusions=dict(r706='All three chain24 states regress about7-8percent with six-copy confidence intervals above1. Rejected.', r716='Keeping the old backend for8..15 removes the marked regression, but all nine workload confidence intervals include1. No confirmed benefit; not adopted.'),
        scope='Private compact metadata experiments preserve full contracts/domain, checked generic fallback and rounded operation order. Full C17 predecessor unit closes249 checks, five inherited warnings retained. This is not production adoption, C14 proof closure, whole dynamics Gold, complete port, migration or C parity.'))
    (D/'README.md').write_text('''# Compact row proofs and measured rejection

The private r706 compact-metadata helper closes 89 checks without warnings;
its dispatcher closes 44. The complete kernel unit closes all 249 checks on
the C3.17 candidate closure, retaining the five existing diagnostics. Strict
warning-free passed remains false; obligations_closed is true. Exact ordered
floating arithmetic, rejection, untouched frame and full original public domain
are preserved. The generic fallback covers larger/high-origin inputs. No new
assumption, suppression, trusted body, input narrowing or deallocator change.

Both validation/release profiles pass 59,621 exact row cases for r706 and the
later r716 dispatch refinement, including origins/counts 65,535/65,536 and
origins near Natural'Last. The test child keeps the documented 64 MiB stack.
Frozen unused Python provider bytes and the executed runner are distinct;
their exact versions remain inside each corpus root, as in the prior checkpoint.

Two completed nine-scenario movement comparisons use six identical replicas
per role, balanced orders, normal native C3.17 SIMD/LTO and matched flags.
All numeric endpoints pass. R706 slows chain24 by roughly 7-8%, with all three
confidence intervals above one: rejected. Its smaller 230-instruction SIMD
helper vectorizes only from 16 values, leaving counts 8..15 scalar. R716 keeps
the old backend for those counts. The marked regression disappears, but every
interval includes no change; it is not an accepted speedup. No unweighted
aggregate or parity claim. Full raw outputs and preflights are retained.

The r716 dispatcher closes 44 checks. Its unchanged helper body is identified
by the predecessor proof; a fresh complete r716 unit proof and C3.14 integration
were not run because timing does not justify adoption. These scopes are distinct.
The actual working math/kernel owners remain exactly those of commit ef66b666a.

Earlier rejected alias/view/counter/proof variants, the isolated successfully
proved equality and the intentionally interrupted redundant r709 proof remain
auditable. No missing/timed-out observation was treated as process completion.

The current accepted runtime's raw profile and selected instruction windows
identify geometry and +/-1e72 projection checks in inlined external-force work
as the next investigation. These are flat samples, not causal phase timings.
The current compatible Solve path does not construct a dummy dense inverse;
older summaries are not evidence of its current cost. Full-function control-flow
mapping is still needed before attributing the sampled costs to particular checks.

The archive also records removal of one exact-store-backed ignored ZIP duplicate
and completed archived r625 caches; source, reports, binaries and raw data remain.
No VHDX compaction or equal Windows physical recovery is claimed.

Restore compact-row.zip with tools/evidence_store.py restore using its repository
path. It preserves completed /var/tmp inputs/outputs and generation recipes,
excluding generated caches. Full port, whole dynamics Gold, coordinated migration
and integrated C parity remain unfinished. No new commit or push is performed.
''')
    inv = json.loads((E/'inventory.json').read_text())
    prior = dict(inv['files'])
    for p in D.iterdir():
        if p.is_file():
            inv['files'][p.relative_to(E).as_posix()] = sha(p)
    assert all(inv['files'][k] == v for k,v in prior.items())
    inv['count'] = len(inv['files'])
    dump(E/'inventory.json', inv)
    print(json.dumps(dict(zip_bytes=Z.stat().st_size, roots=len(roots), members=len(members), inventory_files=inv['count'])), flush=True)

if __name__ == '__main__':
    main()
