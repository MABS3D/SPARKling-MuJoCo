"""Check exact generic row values and rejection in each SIMD lane and tail.

This separate corpus exercises Add_Row and Scale_Row. The disjoint-row corpus
continues to test Add_Row_Disjoint; neither substitutes for the other. The
bitwise conversion belongs only to the executable test oracle, not production
code or a premise of the SPARK proofs.
"""
import argparse, hashlib, json, shutil, subprocess
from pathlib import Path
from build import ROOT, environment, FOLDERS, compiler_flags, linker_flags, solver_kernel_switches


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--build', type=Path, required=True)
    p.add_argument('--out', type=Path, required=True)
    a = p.parse_args()
    a.build = a.build.resolve()
    a.out = a.out.resolve()
    hashes = json.loads((a.build/'sources.json').read_text())
    assert all(digest(a.build/'source'/name) == h for name, h in hashes.items())
    a.out.mkdir(parents=True, exist_ok=False)
    shutil.copy2(Path(__file__), a.out/'runner.py')
    shutil.copy2(Path(__file__).with_name('generic_rows_probe.adb'),
                 a.out/'generic_rows_probe.adb')
    source = a.out/'source'
    shutil.copytree(a.build/'source', source)
    relative = 'experimental/dynamics-derivatives-candidate/tests/generic_rows_probe.adb'
    shutil.copy2(Path(__file__).with_name('generic_rows_probe.adb'), source/relative)
    hashes[relative] = digest(source/relative)
    (a.out/'sources.json').write_text(json.dumps(hashes, indent=2)+'\n')
    results = []
    for mode in ['validation', 'release']:
        flags = compiler_flags(mode)
        work = a.out/mode
        work.mkdir()
        project = work/'rows.gpr'
        project.write_text('project Rows is\n for Source_Dirs use ('+
            ', '.join('"'+str(source/f)+'"' for f in FOLDERS)+');\n'
            ' for Object_Dir use "obj";\n for Exec_Dir use "bin";\n'
            ' for Create_Missing_Dirs use "True";\n for Main use ("generic_rows_probe.adb");\n'
            ' package Compiler is\n'+solver_kernel_switches(mode,flags)+' for Default_Switches ("Ada") use ('+
            ', '.join('"'+f+'"' for f in flags)+');\n end Compiler;\n package Linker is\n for Default_Switches ("Ada") use ('+
            ', '.join('"'+f+'"' for f in linker_flags(mode))+');\n end Linker;\nend Rows;\n')
        command = ['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000',
                   '--timeout','600','--','gprbuild','-P',str(project),'-j1']
        with (work/'build.log').open('w') as log:
            subprocess.run(command, env=environment(), stdout=log, stderr=subprocess.STDOUT, check=True)
        binary = work/'bin/generic_rows_probe'
        run = subprocess.run([str(binary)], text=True, capture_output=True, timeout=60)
        (work/'output.txt').write_text(run.stdout+run.stderr)
        assert run.returncode == 0 and run.stdout.startswith('passed '), run.stdout+run.stderr
        results.append(dict(mode=mode, flags=flags, passed=True, output=run.stdout.strip(),
                            binary_sha256=digest(binary), build_command=command))
        print(mode, run.stdout.strip(), flush=True)
    unchanged = all(digest(source/n) == h for n,h in hashes.items())
    assert unchanged
    (a.out/'results.json').write_text(json.dumps(dict(passed=True, sources_unchanged=True,
        sources_sha256=digest(a.out/'sources.json'), records=results,
        scope='Bit-exact Add_Row/Scale_Row ordered arithmetic and rejection corpus, all lengths 0..256, each rejected lane/sign, constrained numeric limits, signed zero and nonzero/maximum origins. Separate from universal language proof, real accuracy, C equivalence and full movement performance.'), indent=2)+'\n')


if __name__ == '__main__':
    main()
