"""Smallest routines first, followed by complete kernel unit and integration flow."""
import argparse,json,re,shutil,subprocess,time,resource
from pathlib import Path
from build import environment,ROOT
def main():
    p=argparse.ArgumentParser();p.add_argument('--build',type=Path,required=True);p.add_argument('--out',type=Path,required=True)
    p.add_argument('--only',action='append',help='A routine, whole, or integration-flow; repeat to select more than one')
    p.add_argument('--timeout',type=int,default=3)
    p.add_argument('--prover',default='cvc5,z3,altergo')
    a=p.parse_args();a.out.mkdir(parents=True,exist_ok=False)
    resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    (a.out/'sources.json').write_text((a.build/'manifest.json').read_text())
    snap=a.build/'source';project=snap/'experimental/flex-elasticity-integration/flex.gpr'
    kernel_project=a.out/'kernels.gpr'
    kernel_project.write_text('project Kernels is\n'
        ' for Source_Dirs use ("'+str(snap/'src')+'", "'+str(snap/'experimental/flex-elasticity-integration/src')+'");\n'
        ' for Source_Files use ("mj.ads", "mj-types.ads", "mj-flex_elastic_kernels.ads", "mj-flex_elastic_kernels.adb");\n'
        ' for Object_Dir use external ("FLEX_BUILD_ROOT") & "/validation/obj";\n'
        ' for Create_Missing_Dirs use "True";\n'
        ' package Compiler is for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off"); end Compiler;\n'
        'end Kernels;\n')
    targets=[]
    for suffix in ['ads','adb']:
        source=snap/f'experimental/flex-elasticity-integration/src/mj-flex_elastic_kernels.{suffix}'
        for i,line in enumerate(source.read_text().splitlines(),1):
            m=re.match(r'\s*function (\w+)',line)
            if m and (suffix=='adb' or m[1]=='Elongation'):targets.append((m[1],f'mj-flex_elastic_kernels.{suffix}:{i}'))
    targets += [('whole',None),('integration-flow',None)]
    if a.only:targets=[t for t in targets if t[0] in a.only]
    if not targets:raise ValueError('No selected routine')
    records=[]
    for label,limit in targets:
        env=environment();env['FLEX_BUILD_ROOT']=str(a.out/label);env['FLEX_MODE']='validation'
        unit='mj-data-flex_elasticity' if label=='integration-flow' else 'mj-flex_elastic_kernels'
        cmd=['gnatprove','-P',str(project if label=='integration-flow' else kernel_project),'-u',unit+'.adb','--prover='+a.prover,'--timeout='+str(a.timeout),'--memlimit=650',
             '--steps=0','--proof=per_check','-j1','--checks-as-errors=on','--warnings=continue','--report=all','--counterexamples=off']
        if limit:cmd+=['--limit-subp='+limit]
        if label=='integration-flow':cmd+=['--mode=flow','--no-inlining']
        started=time.monotonic()
        r=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2200','--timeout','180','--',*cmd],
                         env=env,capture_output=True,text=True)
        (a.out/(label+'.log')).write_text(r.stdout+r.stderr)
        row=dict(label=label,exit=r.returncode,seconds=time.monotonic()-started,command=cmd)
        report=next((q for q in (a.out/label).rglob('*.spark') if q.stem==unit),None)
        if report:
            data=json.loads(report.read_text());shutil.copyfile(report,a.out/(label+'.spark.json'))
            entries=[m for kind in ['proof','flow','warn_error'] for m in data.get(kind,[])]
            row.update(proved=sum(m.get('severity')=='info' for m in entries),
                       open=sum(m.get('severity') not in ['info','warning'] for m in entries),
                       warnings=sum(m.get('severity')=='warning' for m in entries))
        records.append(row);print(json.dumps(row),flush=True)
        (a.out/'results.json').write_text(json.dumps(records,indent=2)+'\n')
    raise SystemExit(any(row['exit'] != 0 or row.get('open',1) != 0 for row in records))
if __name__=='__main__':main()
