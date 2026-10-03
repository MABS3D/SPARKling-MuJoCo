"""Build only the flat ancestry kernel from a manifest-verified source closure."""
import argparse,hashlib,json,subprocess
from pathlib import Path
from build import ROOT,environment

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--build',type=Path,required=True)
    p.add_argument('--out',type=Path,required=True)
    p.add_argument('--mode',choices=['validation','release'],required=True)
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    source=a.build.resolve()/'source'
    manifest=json.loads((a.build/'manifest.json').read_text())
    for name,digest in manifest['sources'].items():
        assert hashlib.sha256((source/name).read_bytes()).hexdigest()==digest,name
    (a.out/'sources.json').write_text(json.dumps(manifest,indent=2)+'\n')
    flags='"-O3", "-gnatn", "-march=native"' if a.mode=='release' else '"-O1", "-g", "-gnata", "-gnato", "-gnatVa"'
    project=a.out/'ancestors.gpr'
    project.write_text('project Ancestors is\n'
        ' for Source_Dirs use ("'+str(source/'src')+'", "'+str(source/'experimental/flex-elasticity-integration/src')+'", "'+str(source/'experimental/flex-elasticity-integration/tests')+'");\n'
        ' for Main use ("ancestors_probe.adb");\n'
        ' for Object_Dir use "obj"; for Exec_Dir use "bin";\n'
        ' for Create_Missing_Dirs use "True";\n'
        ' package Compiler is for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off", '+flags+'); end Compiler;\n'
        'end Ancestors;\n')
    command=['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','1600','--timeout','180','--','gprbuild','-P',str(project.resolve()),'-j1']
    with (a.out/'build.log').open('w') as log:
        run=subprocess.run(command,env=environment(),stdout=log,stderr=subprocess.STDOUT)
    receipt=dict(exit=run.returncode,mode=a.mode,command=command,
        source_manifest_sha256=hashlib.sha256((a.build/'manifest.json').read_bytes()).hexdigest(),
        project_sha256=hashlib.sha256(project.read_bytes()).hexdigest(),
        builder_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    if run.returncode==0:
        receipt['binary_sha256']=hashlib.sha256((a.out/'bin/ancestors_probe').read_bytes()).hexdigest()
    (a.out/'results.json').write_text(json.dumps(receipt,indent=2)+'\n')
    print(json.dumps(receipt));raise SystemExit(run.returncode)
if __name__=='__main__':main()
