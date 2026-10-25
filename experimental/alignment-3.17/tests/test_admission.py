"""Differential admission tests using the real 3.17 compiler and validator.

An immutable complete source overlay is copied into a fresh Linux build tree.
Both profiles retain runtime checks. Full FLEX admission remains unsupported;
malformed FLEX images therefore exercise the new helper, not that early guard.
"""
import argparse
import ctypes
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess

import mujoco
import numpy as np

ROOT = Path(__file__).resolve().parents[3]
PIN = '800a109a4bdd02cb60404d565db4ae16fb04a53b'
FLEX = '''<mujoco><option jacobian="sparse"/><worldbody><flexcomp name="f" type="grid" count="3 3 1" spacing=".1 .1 .1" dim="2" radius=".01" mass="1" pos="0 0 1"><edge equality="vert"/><elasticity young="1000" poisson=".3" damping=".01" thickness=".01" elastic2d="bend"/></flexcomp></worldbody></mujoco>'''
CHAIN = '''<mujoco><worldbody><body name="a"><joint/><geom type="sphere" size=".1" mass="1"/><body name="b" pos="0 0 .3"><joint/><geom type="sphere" size=".1" mass="1"/><body name="c" pos="0 0 .3"><joint/><geom type="sphere" size=".1" mass="1"/></body></body></body><body name="other" pos="1 0 0"><joint/><geom type="sphere" size=".1" mass="1"/></body></worldbody></mujoco>'''
TENDONS = CHAIN
for joint_number in range(4):
    TENDONS = TENDONS.replace('<joint/>', '<joint name="j' + str(joint_number) + '"/>', 1)
TENDONS = TENDONS.replace('</mujoco>', '<tendon><fixed name="a"><joint joint="j0" coef="1"/><joint joint="j1" coef="2"/></fixed><fixed name="b"><joint joint="j0" coef="3"/><joint joint="j1" coef="4"/></fixed></tendon></mujoco>')
MESH = '<mujoco><asset><mesh name="m" vertex="0 0 0 .1 0 0 0 .1 0 0 0 .1" texcoord="0 0 1 0 0 1 1 1" face="0 2 1 0 1 3 0 3 2 1 2 3"/></asset><worldbody><geom type="mesh" mesh="m"/></worldbody></mujoco>'
OK = ['OK', 'NONE', -1]


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()



def rearrange_sparse(model, stem, mode):
    """Mutate only C model arrays; disjoint permutations remap associated maps.

    Shared spans deliberately exercise validator admission, not equivalence of
    a simulation with aliased numeric storage. Unused columns become invalid.
    """
    widths, addresses, columns = [np.asarray(getattr(model, stem + '_' + part)).reshape(-1)
                                   for part in ['rownnz', 'rowadr', 'colind']]
    rows = [columns[int(a):int(a + n)].copy() for a, n in zip(addresses, widths)]
    old_addresses = addresses.copy()
    if mode == 'reverse':
        order = list(range(len(rows) - 1, -1, -1))
        if stem == 'B': order = [0] + [i for i in order if i != 0]
        cursor, permutation = 0, {}
        for row in order:
            addresses[row] = cursor
            columns[cursor:cursor + len(rows[row])] = rows[row]
            for k in range(len(rows[row])): permutation[int(old_addresses[row]) + k] = cursor + k
            cursor += len(rows[row])
        if stem == 'M':
            first, second, third = model.mapM2M.copy(), model.mapD2M.copy(), model.mapM2D.copy()
            for old, new in permutation.items(): model.mapM2M[new], model.mapD2M[new] = first[old], second[old]
            model.mapM2D[:] = [permutation[int(slot)] if slot >= 0 else -1 for slot in third]
        elif stem == 'D':
            old = model.mapM2D.copy()
            for before, after in permutation.items(): model.mapM2D[after] = old[before]
            model.mapD2M[:] = [permutation[int(slot)] for slot in model.mapD2M.copy()]
    else:
        assert mode == 'shared'
        if stem == 'M':
            assert [row.tolist() for row in rows] == [[0], [0, 1], [0, 1, 2], [3]]
            columns[:4] = [0, 1, 2, 3]; addresses[:] = [0, 0, 0, 3]
        elif stem == 'B': addresses[2:4] = addresses[1]
        elif stem == 'D': addresses[1:3] = addresses[0]
        else:
            assert stem == 'ten_J' and len(rows) == 2 and np.array_equal(rows[0], rows[1])
            addresses[1] = addresses[0]
        used = {int(addresses[i]) + k for i in range(len(rows)) for k in range(int(widths[i]))}
        for slot in range(len(columns)):
            if slot not in used: columns[slot] = -123


def fixtures(folder, validate):
    folder.mkdir()
    records = []

    def add(name, xml, mutate=None, helper=None, expected=OK, c_field=None, helper_pre=True):
        model = mujoco.MjModel.from_xml_string(xml)
        if xml == FLEX:
            assert model.nefm0dof > 0 and model.nefm0L > 0
            assert np.all(model.flexedge_J_rownnz > 0) and np.all(model.flexvert_J_rownnz > 0)
        if mutate:
            mutate(model)
        error = validate(model._address)
        error = error.decode() if error else None
        if expected == OK:
            assert error is None, (name, error)
        else:
            assert error and c_field.lower() in error.lower(), (name, error, c_field)
        xml_path = folder / (name + '.xml')
        xml_path.write_text(xml + '\n')
        image = folder / (name + '.mjb')
        mujoco.mj_saveModel(model, str(image), None)
        records.append(dict(name=name, image=image.name, image_sha256=digest(image),
                            xml_sha256=digest(xml_path), c_error=error, helper=helper,
                            expected=expected, helper_pre=helper_pre, full_status='UNSUPPORTED_FLEX' if xml == FLEX else expected[0]))

    add('flex_valid', FLEX, helper='FLEX')
    for stem in ['flexedge_J', 'flexvert_J', 'efm0_L']:
        for mode in ['width_negative', 'width_large', 'address_negative', 'address_large',
                     'column_negative', 'column_large', 'duplicate', 'descending']:
            selected = {}

            def mutate(m):
                widths, addresses, columns = [np.asarray(getattr(m, stem + '_' + suffix)).reshape(-1)
                                               for suffix in ['rownnz', 'rowadr', 'colind']]
                row = int(np.flatnonzero(widths >= 2)[0])
                adr = int(addresses[row])
                ncols = int(m.nefm0dof if stem == 'efm0_L' else m.nv)
                suffix = 'rownnz' if mode.startswith('width') else 'rowadr' if mode.startswith('address') else 'colind'
                if mode == 'width_negative': widths[row] = -1
                elif mode == 'width_large': widths[row] = ncols + 1
                elif mode == 'address_negative': addresses[row] = -1
                elif mode == 'address_large': addresses[row] = len(columns)
                elif mode == 'column_negative': columns[adr] = -1
                elif mode == 'column_large': columns[adr] = ncols
                elif mode == 'duplicate': columns[adr + 1] = columns[adr]
                elif mode == 'descending': columns[adr:adr + 2] = columns[adr:adr + 2][::-1]
                selected.update(row=row, field=stem + '_' + suffix)

            # Determine the expected row from the unmodified actual C pattern.
            baseline = mujoco.MjModel.from_xml_string(FLEX)
            mutate(baseline)
            field = selected['field']
            add(stem.lower() + '_' + mode, FLEX, mutate, 'FLEX',
                ['INVALID_CSR', field.upper(), selected['row']], field)
        for mode in ['unused_storage', 'shared_rows']:
            def mutate(m):
                widths, addresses = [np.asarray(getattr(m, stem + '_' + suffix)).reshape(-1) for suffix in ['rownnz', 'rowadr']]
                if mode == 'unused_storage': widths[0] = 0
                else: widths[1], addresses[1] = widths[0], addresses[0]
            add(stem.lower() + '_' + mode, FLEX, mutate, 'FLEX')
    for value, name in [(-1, 'efm0_dof_low'), (27, 'efm0_dof_high')]:
        def mutate(m):
            assert m.nv == 27
            m.efm0_dofid[0] = value
        add(name, FLEX, mutate, 'FLEX', ['INVALID_REFERENCE', 'EFM0_DOFID', 0], 'efm0_dofid')

    add('chain_valid', CHAIN, helper='BODIES')
    for stem in ['M', 'B', 'D', 'ten_J']:
        for mode in ['reverse', 'shared']:
            def mutate(m): rearrange_sparse(m, stem, mode)
            add(stem.lower() + '_rows_' + mode, TENDONS if stem == 'ten_J' else CHAIN,
                mutate, 'VALIDATE')
    for stem, helper in [('M', 'M_CSR'), ('B', 'B_CSR'), ('D', 'D_CSR'), ('ten_J', 'TENDON_CSR')]:
        for mode, suffix in [('width_negative', 'rownnz'), ('address_negative', 'rowadr'), ('column_large', 'colind')]:
            xml = TENDONS if stem == 'ten_J' else CHAIN
            row = 1 if stem == 'M' else 0
            def mutate(m):
                values = np.asarray(getattr(m, stem + '_' + suffix)).reshape(-1)
                target = int(getattr(m, stem + '_rowadr')[row]) if suffix == 'colind' else row
                values[target] = int(m.nv) if suffix == 'colind' else -1
            field = stem + '_' + suffix
            add(stem.lower() + '_native_' + mode, xml, mutate, helper,
                ['INVALID_CSR', field.upper(), row], field, helper_pre=stem not in ['B', 'D'])
    def parent_subset(m): m.B_colind[7:10] = [0, 1, 3]
    add('body_parent_subset', CHAIN, parent_subset, 'BODIES', ['INVALID_CSR', 'B_COLIND', 2], 'B_colind')
    def ancestor(m):
        m.B_rownnz[:] = [4, 3, 3, 1, 3]; m.B_rowadr[:] = [0, 4, 7, 10, 11]
        m.B_colind[:] = [0, 1, 2, 3, 0, 1, 2, 0, 1, 2, 0, 0, 1, 3]
    add('body_ancestor_count', CHAIN, ancestor, 'BODIES', ['INVALID_CSR', 'B_ROWNNZ', 3], 'B_rownnz')
    def root(m):
        m.B_rownnz[:] = [3, 3, 3, 3, 2]; m.B_rowadr[:] = [0, 3, 6, 9, 12]
        m.B_colind[:] = [0, 1, 2, 0, 1, 2, 0, 1, 2, 0, 1, 2, 2, 3]
    add('body_root_width', CHAIN, root, 'BODIES', ['INVALID_CSR', 'B_ROWNNZ', 0], 'B_rownnz')
    def diag(m): m.D_colind[6:9] = [0, 2, 3]; m.D_diag[2] = 1
    add('dof_diagonal_position', CHAIN, diag, 'DOFS', ['INVALID_CSR', 'D_DIAG', 2], 'D_diag')
    def unequal(m): m.B_colind[-1] = 2
    add('dof_body_columns', CHAIN, unequal, 'DOFS', ['INVALID_CSR', 'D_COLIND', 3], 'D_colind')
    def width(m):
        m.B_rownnz[:] = [4, 3, 3, 2, 2]; m.B_rowadr[:] = [0, 4, 7, 10, 12]
        m.B_colind[:] = [0, 1, 2, 3, 0, 1, 2, 0, 1, 2, 0, 2, 2, 3]
    add('dof_body_width', CHAIN, width, 'DOFS', ['INVALID_CSR', 'D_ROWNNZ', 2], 'D_rownnz')
    for field, lower, limit in [('mapM2M', -1, 'nM'), ('mapM2D', -2, 'nC'), ('mapD2M', -1, 'nD')]:
        for mode in ['low', 'high']:
            def mutate(m):
                getattr(m, field)[0] = lower if mode == 'low' else int(getattr(m, limit))
            add(field.lower() + '_' + mode, CHAIN, mutate, 'MAPS',
                ['INVALID_CSR', field.upper(), 0], field)
    add('mesh_valid', MESH, helper='VALIDATE')
    def normals(m):
        assert m.mesh_normalnum[0] > 0
        m.mesh_normalnum[0] = 0
    add('mesh_normal_count_zero', MESH, normals, 'VALIDATE',
        ['INVALID_REFERENCE', 'MESH_FACE', 0], 'mesh_facenormal')
    def texcoords(m):
        assert m.mesh_texcoordadr[0] >= 0 and m.mesh_texcoordnum[0] > 0
        m.mesh_texcoordnum[0] = 0
    add('mesh_texcoord_count_zero', MESH, texcoords, 'VALIDATE',
        ['INVALID_REFERENCE', 'MESH_FACE', 0], 'mesh_facetexcoord')
    return records


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    parser.add_argument('--reference-source', type=Path, required=True)
    parser.add_argument('--mode', choices=['validation', 'release', 'both'], default='both')
    args = parser.parse_args()
    assert mujoco.__version__ == '3.17.0' and mujoco.mj_version() == 3_017_000
    engine, out = args.engine.resolve(), args.out.resolve()
    reference = args.reference_source.resolve()
    assert subprocess.check_output(['git', '-C', str(reference), 'rev-parse', 'HEAD'], text=True).strip() == PIN
    assert not subprocess.check_output(['git', '-C', str(reference), 'status', '--porcelain', '--', 'src/engine/engine_io.c'], text=True).strip()
    manifest = json.loads((engine / 'manifest.json').read_text())
    assert manifest['phase'] in ['admission-prepared', 'generated'] and manifest['commit'] == PIN
    assert manifest['reference'] == '3.17.0'
    if manifest['phase'] == 'generated':
        assert manifest.get('structural_overlay'), 'Foundation does not contain the structural overlay'
    library_sources = {n: v for n, v in manifest['candidate_sources'].items()
                       if n.startswith('src/') or n == 'sparkling_mujoco.gpr'}
    assert 'src/mj-model_admission.adb' in library_sources and 'sparkling_mujoco.gpr' in library_sources
    assert all(digest(engine / 'source' / n) == v for n, v in manifest['candidate_sources'].items())
    modes = ['validation', 'release'] if args.mode == 'both' else [args.mode]
    out.mkdir(parents=True, exist_ok=False)
    source = out / 'source'
    for name, value in library_sources.items():
        original = engine / 'source' / name
        assert digest(original) == value
        target = source / name; target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(original, target)
    harness = out / 'harness'; harness.mkdir()
    runner_hash, guard_hash = digest(Path(__file__)), digest(ROOT / 'tools/guarded.py')
    for original, target in [(Path(__file__), out / 'runner.py'), (ROOT / 'tools/guarded.py', out / 'guarded.py'),
                             (Path(__file__).with_name('admission_probe.adb'), harness / 'admission_probe.adb')]:
        shutil.copyfile(original, target)
    project = harness / 'admission.gpr'
    project.write_text('with "' + str(source / 'sparkling_mujoco.gpr') + '";\n' + '''project Admission is
   for Source_Dirs use (".");
   for Object_Dir use Sparkling_Mujoco.Build_Root & "/harness-obj";
   for Exec_Dir use Sparkling_Mujoco.Build_Root & "/bin";
   for Create_Missing_Dirs use "True";
   for Main use ("admission_probe.adb");
   package Compiler is
      for Default_Switches ("Ada") use ("-gnat2022", "-O2", "-gnata", "-gnato", "-gnatVa", "-ffp-contract=off");
   end Compiler;
   package Binder is
      for Switches ("Ada") use ("-Es");
   end Binder;
   package Linker is
      for Default_Switches ("Ada") use Sparkling_Mujoco.Link_Switches;
   end Linker;
end Admission;
''')
    library = Path(mujoco.__file__).parent / 'libmujoco.so.3.17.0'
    lib = ctypes.CDLL(str(library)); validate = lib.mj_validateReferences
    validate.argtypes = [ctypes.c_void_p]; validate.restype = ctypes.c_char_p
    result = dict(reference='3.17.0', commit=PIN, engine_manifest_sha256=digest(engine / 'manifest.json'),
                  runner_sha256=runner_hash, guard_sha256=guard_hash, c_library_sha256=digest(library),
                  c_validator_source_sha256=digest(reference / 'src/engine/engine_io.c'),
                  harness_sha256=digest(harness / 'admission_probe.adb'), project_sha256=digest(project),
                  scope='Actual MJB decoding and typed structural admission; FLEX full validation remains unsupported.',
                  library_sources=library_sources, requested_modes=modes,
                  cases=[], profiles={}, complete=False, passed=False)
    receipt = out / 'results.json'
    try:
        result['cases'] = fixtures(out / 'fixtures', validate)
        receipt.write_text(json.dumps(result, indent=2) + '\n')
        env = os.environ.copy(); tc = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
        env['PATH'] = ':'.join(str(p) for name in ['gnat', 'gprbuild', 'gnatprove'] for p in (tc / name).glob('*/bin')) + ':' + env['PATH']
        result['toolchain'] = {}
        for name in ['gnatls', 'gprbuild']:
            resolved = shutil.which(name, path=env['PATH'])
            version = subprocess.run([resolved, '--version'], capture_output=True, text=True, check=True)
            result['toolchain'][name] = dict(path=resolved, sha256=digest(Path(resolved)), version=version.stdout + version.stderr)
        for mode in modes:
            build = out / ('build-' + mode); build.mkdir(); env['SPARKLING_BUILD_ROOT'] = str(build)
            command = ['gprbuild', '-P', str(project), '-XSPARKLING_BUILD_MODE=' + mode, '-j1', '-p']
            profile = dict(command=command, cases=[], passed=False); result['profiles'][mode] = profile
            with (build / 'build.log').open('w') as stream:
                run = subprocess.run(['python3', str(ROOT / 'tools/guarded.py'), '--cap-mb', '3000', '--timeout', '600', '--', *command],
                                     env=env, stdout=stream, stderr=subprocess.STDOUT)
            profile['build_exit'] = run.returncode
            receipt.write_text(json.dumps(result, indent=2) + '\n')
            assert run.returncode == 0, mode + ' build failed'
            binary = build / 'bin/admission_probe'; profile['binary_sha256'] = digest(binary)
            for case in result['cases']:
                run = subprocess.run([str(binary), str(out / 'fixtures' / case['image'])], capture_output=True, text=True, timeout=15)
                transcript = build / (case['name'] + '.txt'); transcript.write_text(run.stdout + run.stderr)
                record = dict(name=case['name'], exit=run.returncode, transcript_sha256=digest(transcript), passed=False)
                profile['cases'].append(record)
                assert run.returncode == 0, (mode, case['name'], run.stdout, run.stderr)
                parsed = {}
                for line in run.stdout.splitlines():
                    parts = line.split()
                    if len(parts) == 4: parsed[parts[0]] = [parts[1], parts[2], int(parts[3])]
                assert ('HELPER_PRE ' + str(case['helper_pre']).upper()) in run.stdout and 'ALL_NULL TRUE' in run.stdout
                assert parsed['PARSE'] == OK and parsed[case['helper']] == case['expected'], (case, parsed)
                assert parsed['VALIDATE'][0] == case['full_status'], (case, parsed)
                if case['full_status'] != 'UNSUPPORTED_FLEX':
                    assert parsed['VALIDATE'] == case['expected'], (case, parsed)
                record.update(passed=True, actual=parsed)
                receipt.write_text(json.dumps(result, indent=2) + '\n')
            profile['passed'] = len(profile['cases']) == len(result['cases']) and all(c['passed'] for c in profile['cases'])
        result['complete'] = set(result['profiles']) == set(modes)
    finally:
        result['source_hashes_unchanged'] = (all(digest(source / n) == v for n, v in library_sources.items())
            and all(digest(engine / 'source' / n) == v for n, v in manifest['candidate_sources'].items()))
        result['driver_hashes_unchanged'] = digest(Path(__file__)) == runner_hash and digest(ROOT / 'tools/guarded.py') == guard_hash
        result['passed'] = (result['complete'] and result['source_hashes_unchanged'] and result['driver_hashes_unchanged']
                            and all(p['passed'] for p in result['profiles'].values()))
        receipt.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(dict(passed=result['passed'], cases=len(result['cases']), profiles=len(result['profiles']))))
    raise SystemExit(not result['passed'])


if __name__ == '__main__': main()
