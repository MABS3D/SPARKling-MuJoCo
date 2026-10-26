from pathlib import Path
import hashlib, json, shutil, zipfile

R = Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
E = R / 'experimental/alignment-3.17/evidence'
D = E / '20261026-row-boundaries-and-profile'
Z = D / 'row-boundaries-and-profile.zip'
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()
def dump(p, value):
    p.write_text(json.dumps(value, indent=2) + '\n')

def main():
    D.mkdir(exist_ok=False)
    shutil.copy2(__file__, D / 'package.py')
    corpus = Path('/var/tmp/sparkling-row-origin-baseline-r689-20261026')
    result = json.loads((corpus / 'results.json').read_text())
    assert result['passed'] and len(result['records']) == 2
    assert all(x['output'] == 'passed 59621 disjoint row cases' for x in result['records'])
    assert result['runner_sha256'] == sha(R / 'experimental/dynamics-derivatives-candidate/tests/check_row_update.py')
    hashes = json.loads((corpus / 'sources.json').read_text())
    owners = ['experimental/smooth/src/mj-smooth_math.adb', 'experimental/smooth/src/mj-solver_kernels.adb']
    assert all(sha(R / n) == hashes[n] for n in owners)
    probe = 'tests/movement_performance/c_parity_six/disjoint_rows_probe.adb'
    assert sha(R / probe) == hashes['experimental/dynamics-derivatives-candidate/tests/disjoint_rows_probe.adb']
    prior_sources = json.loads(Path('/var/tmp/sparkling-adopt-cross-r631-20261026/snapshot317/sources.json').read_text())
    differences = {n: {'prior': prior_sources.get(n), 'corpus': hashes.get(n)} for n in prior_sources.keys() | hashes.keys() if prior_sources.get(n) != hashes.get(n)}
    assert set(differences) == {'experimental/dynamics-derivatives-candidate/tests/disjoint_rows_probe.adb'}
    provider = 'experimental/dynamics-derivatives-candidate/tests/check_row_update.py'
    dump(D / 'source-binding.json', dict(runtime_owners={n: sha(R/n) for n in owners},
        probe_sha256=sha(R/probe), corpus_manifest_difference=differences,
        runner_bridge=dict(frozen_unused_provider_sha256=hashes[provider], executed_runner_sha256=sha(corpus/'runner.py'), current_provider_sha256=sha(R/provider)),
        scope='Exact C3.17 candidate source closure from prior adopted Cross; sole manifest addition is the test probe. The unused frozen Python provider is preserved; the executed updated runner is captured separately. Production remains pinned to C3.14; these tests do not establish migration.'))
    roots = [corpus]
    roots += [Path('/var/tmp') / n for n in [
        'sparkling-profile-current-r640-20261026', 'sparkling-profile-inputs-r640-20261026',
        'sparkling-storage-build-r638-20261026', 'sparkling-storage-movement-r639-20261026',
        'sparkling-storage-bits-r637-20261026', 'sparkling-row-origin-boundary-baseline-r677-20261026']]
    members = {}
    excluded = {'obj', 'analysis', '__pycache__', '.git'}
    with zipfile.ZipFile(Z, 'w', zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        for folder in roots:
            assert folder.is_dir(), folder
            for p in sorted(folder.rglob('*')):
                if not p.is_file() or set(p.relative_to(folder).parts) & excluded:
                    continue
                name = folder.name + '/' + p.relative_to(folder).as_posix()
                data = p.read_bytes()
                members[name] = hashlib.sha256(data).hexdigest()
                z.writestr(name, data)
    with zipfile.ZipFile(Z) as z:
        assert z.testzip() is None
        assert all(hashlib.sha256(z.read(n)).hexdigest() == h for n,h in members.items())
    dump(D/'archive-manifest.json', dict(files=members, zip_sha256=sha(Z), zip_bytes=Z.stat().st_size,
        excluded='Generated compiler/prover/Python caches only. Prior proof/adoption evidence remains in r620/r630/r632. Other private row prototypes remain local and are not adopted.'))
    shutil.copy2(corpus/'results.json', D/'row-results.json')
    shutil.copy2(Path('/var/tmp/sparkling-profile-current-r640-20261026/results.json'), D/'profile-results.json')
    (D/'README.md').write_text('''# Row boundaries, current profile and unadopted storage experiment

Both checked validation and movement-release profiles pass 59,621 disjoint-row
cases with exact arithmetic, rejection and frame comparisons. The expanded corpus
includes source origins 65,535/65,536 and near Natural'Last, plus row lengths
65,535/65,536. Large test arrays and validation contract snapshots require a
64 MiB child stack; the original 8 MiB stack failure and successful same-binary
diagnostic are preserved. This changes only the test runner, not production flags.

The runtime owners match the adopted Cross/threshold-eight C3.17 closure. The
frozen unused Python provider and the executed updated runner have distinct,
explicit hashes. Earlier C3.14/C3.17 full-unit proofs and integration evidence
remain in r620/r630/r632; no new whole-unit proof is claimed for this test change.

The qualified current chain24 CPU profile retains raw PCs, sampler, delivery
metadata and numerical endpoints. Flat samples suggest acceleration preparation,
factor/solve, row updates and compact mass remain important. These are diagnostic
sample shares, not causal timing savings or acceptance measurements.

The checked storage-slice candidate passes 4,360 bit cases per profile and its
nine-case six-copy movement run. It does not establish an improvement on chain24
or branches24: intervals include no change. It remains unadopted; production
storage and private compact-index row variants are unchanged. Whole dynamics
Gold, complete port, coordinated 3.17 migration and overall C parity remain open.

The ZIP preserves frozen inputs, build commands, binaries, raw measurements and
logs. Restore its exact bytes using tools/evidence_store.py restore with the
repository-relative ZIP path. Generated caches are excluded.
''')
    inventory = json.loads((E/'inventory.json').read_text())
    prior = dict(inventory['files'])
    for p in D.iterdir():
        if p.is_file():
            inventory['files'][p.relative_to(E).as_posix()] = sha(p)
    assert all(inventory['files'][n] == h for n,h in prior.items())
    inventory['count'] = len(inventory['files'])
    dump(E/'inventory.json', inventory)
    print(json.dumps(dict(zip_bytes=Z.stat().st_size, members=len(members), inventory_files=inventory['count'])), flush=True)

if __name__ == '__main__':
    main()
