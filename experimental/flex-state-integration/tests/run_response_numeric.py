"""Build a proven response kernel unchanged, then compare isolated native models."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time
from build import ROOT, environment


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--proof',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    a = p.parse_args(); a.out.mkdir(parents=True,exist_ok=False)
    pm = json.loads((a.proof / 'manifest.json').read_text())
    if not any(s['name'] == 'whole' and s['exit'] == 0 and s.get('counts',{}).get('open') == 0 for s in pm['steps']):
        raise RuntimeError('response proof incomplete')
    src = a.out / 'source'; src.mkdir(); hashes = {}
    for name,value in pm['sources'].items():
        source = a.proof / 'source' / Path(name).name
        if digest(source) != value: raise RuntimeError('proof source changed')
        shutil.copyfile(source,src / source.name); hashes[name] = value
    for name in ('flex_response_probe.adb','compare_response.py'):
        origin = ROOT / 'experimental/flex-state-integration/tests' / name
        shutil.copyfile(origin,src / name); hashes[str(origin.relative_to(ROOT))] = digest(origin)
    reference = Path('/var/tmp/sparkling-recovery-shell-response-native1-20261003')
    shutil.copyfile(reference / 'reference_response.py',src / 'reference_response.py')
    hashes['reference_response.py'] = digest(src / 'reference_response.py')
    project = src / 'response.gpr'
    project.write_text('''project Response is
 Mode := external ("RESPONSE_MODE", "validation");
 Root := external ("RESPONSE_BUILD_ROOT");
 for Source_Dirs use (".");
 for Object_Dir use Root & "/" & Mode & "/obj";
 for Exec_Dir use Root & "/" & Mode & "/bin";
 for Main use ("flex_response_probe.adb");
 for Create_Missing_Dirs use "True";
 Flags := ("-gnat2022", "-ffp-contract=off");
 case Mode is
 when "release" => Flags := Flags & ("-O3", "-gnatn", "-march=native");
 when others => Flags := Flags & ("-O1", "-g", "-gnata", "-gnato", "-gnatVa");
 end case;
 package Compiler is
 for Default_Switches ("Ada") use Flags;
 end Compiler;
end Response;
''')
    shutil.copyfile(ROOT / 'tools/guarded.py',a.out / 'guarded.py')
    shutil.copyfile(Path(__file__),a.out / Path(__file__).name)
    env = environment(); env.update(OPENBLAS_NUM_THREADS='1',OMP_NUM_THREADS='1',RESPONSE_BUILD_ROOT=str(a.out / 'build'))
    rows = []
    manifest = dict(proof=str(a.proof),proof_manifest_sha256=digest(a.proof / 'manifest.json'),
        sources=hashes,project_sha256=digest(project),runner_sha256=digest(Path(__file__)),
        guard_sha256=digest(a.out / 'guarded.py'),steps=rows,complete=False,
        reference=str(reference),reference_manifest_sha256=digest(reference / 'reference/manifest.json'),
        reference_library_sha256=digest(reference / 'reference/reference.so'))
    def save(): (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save()
    def run(name,args,wall):
        cmd = ['/var/tmp/sparkling-movement-env/bin/python',str(a.out / 'guarded.py'),
            '--cap-mb','2500','--timeout',str(wall),'--',*args]
        start = time.monotonic()
        with (a.out / (name+'.log')).open('w') as log:
            r = subprocess.run(cmd,env=env,stdout=log,stderr=subprocess.STDOUT)
        rows.append(dict(name=name,command=cmd,exit=r.returncode,seconds=time.monotonic()-start))
        save(); print(json.dumps(rows[-1]),flush=True)
        return r.returncode
    for mode in ('validation','release'):
        env['RESPONSE_MODE'] = mode
        if run('build-'+mode,['gprbuild','-P',str(project),'-j1'],240): break
        for model in ('shell1_2x2x2_plane_plain','shell2_1x1x1_plane_pinned','shell2_2x1x2_plane_mixed'):
            run(mode+'-'+model,['/var/tmp/sparkling-movement-env/bin/python',str(src / 'compare_response.py'),
                '--binary',str(a.out / 'build' / mode / 'bin/flex_response_probe'),
                '--reference',str(reference / 'reference'),
                '--fixtures','/var/tmp/sparkling-recovery-shell-endpoint2-20261003/validation/endpoints',
                '--model',model,'--out',str(a.out / mode / model)],360)
    manifest['complete'] = True; save()
    raise SystemExit(any(s['exit'] for s in rows))


if __name__ == '__main__':
    main()
