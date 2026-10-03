"""Freeze minimum-first proofs for the signed contact response draft."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import time
from build import ROOT, environment


def digest(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--out',type=Path,required=True)
    a = p.parse_args()
    a.out.mkdir(parents=True,exist_ok=False)
    src = a.out / 'source'; src.mkdir()
    base = Path('/var/tmp/sparkling-recovery-shell-endpoint2-20261003')
    bm = json.loads((base / 'manifest.json').read_text())
    hashes = {}
    for name in ('src/mj.ads','src/mj-types.ads'):
        origin = base / 'source' / name
        assert digest(origin) == bm['sources'][name]
        shutil.copyfile(origin,src / Path(name).name); hashes[name] = digest(origin)
    for ext in ('ads','adb'):
        name = 'experimental/flex-state-integration/integration/shell-dynamics/src/mj-flex_response_kernels.'+ext
        shutil.copyfile(ROOT / name,src / Path(name).name); hashes[name] = digest(src / Path(name).name)
    project = src / 'response.gpr'
    project.write_text('''project Response is
 for Source_Dirs use (".");
 for Object_Dir use external ("RESPONSE_BUILD_ROOT");
 for Create_Missing_Dirs use "True";
 package Compiler is
 for Default_Switches ("Ada") use ("-gnat2022", "-O1", "-g", "-gnata", "-gnato", "-gnatVa", "-ffp-contract=off");
 end Compiler;
end Response;
''')
    shutil.copyfile(ROOT / 'tools/guarded.py',a.out / 'guarded.py')
    shutil.copyfile(Path(__file__),a.out / Path(__file__).name)
    env = environment(); rows = []
    manifest = dict(base=str(base),base_manifest_sha256=digest(base / 'manifest.json'),
        sources=hashes,project_sha256=digest(project),runner_sha256=digest(Path(__file__)),
        guard_sha256=digest(a.out / 'guarded.py'),steps=rows,complete=False,
        toolchains={n:subprocess.check_output([n,'--version'],env=env,text=True) for n in ('gprbuild','gnatprove')})
    def save(): (a.out / 'manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save()
    for scope in ('Scale','Add','Advance','Fold','Combine','Frame_Step','Project','whole'):
        if scope == 'whole' and any(r['exit'] or r.get('report_absent') or r.get('counts',{}).get('open') for r in rows):
            manifest['whole_deferred'] = True; break
        cmd = ['gnatprove','-P',str(project),'-XRESPONSE_BUILD_ROOT='+str(a.out / scope),
            '-j1','--report=all','--checks-as-errors=on','--warnings=continue','-u',
            'mj-flex_response_kernels.adb','--mode=prove','--prover=cvc5,z3,altergo',
            '--timeout=5','--memlimit=650','--steps=0','--proof=per_check','--no-inlining',
            '--counterexamples=off']
        if scope != 'whole':
            line = next(i for i,t in enumerate((src / 'mj-flex_response_kernels.adb').read_text().splitlines(),1)
                        if re.match(r'\s*(function|procedure) '+scope+r'\b',t))
            cmd += ['--limit-subp=mj-flex_response_kernels.adb:'+str(line)]
        command = ['/var/tmp/sparkling-movement-env/bin/python',str(a.out / 'guarded.py'),
            '--cap-mb','2500','--timeout','240','--',*cmd]
        start = time.monotonic()
        with (a.out / (scope+'.log')).open('w') as log:
            r = subprocess.run(command,env=env,stdout=log,stderr=subprocess.STDOUT)
        row = dict(name=scope,command=command,exit=r.returncode,seconds=time.monotonic()-start)
        report = next((a.out / scope).rglob('mj-flex_response_kernels.spark'),None)
        if report:
            shutil.copyfile(report,a.out / (scope+'.spark.json'))
            d = json.loads(report.read_text()); entries = [e for k in ('proof','flow','warn_error') for e in d.get(k,[])]
            row['counts'] = dict(proof=sum(e.get('severity') == 'info' for e in d.get('proof',[])),
                flow=sum(e.get('severity') == 'info' for e in d.get('flow',[])),
                warnings=sum(e.get('severity') == 'warning' for e in entries),
                open=sum(e.get('severity') not in ('info','warning') for e in entries))
        else: row['report_absent'] = True
        rows.append(row); save(); print(json.dumps(row),flush=True)
    manifest['complete'] = True; save()
    raise SystemExit(any(r['exit'] or r.get('report_absent') or r.get('counts',{}).get('open') for r in rows))


if __name__ == '__main__':
    main()
