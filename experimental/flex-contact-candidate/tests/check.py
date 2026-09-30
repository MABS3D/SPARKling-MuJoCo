#!/usr/bin/env python3
"""Isolated source snapshot, checked/release builds, small and whole proofs."""
from pathlib import Path
import argparse, hashlib, json, os, re, resource, shutil, subprocess, sys, time

HERE = Path(__file__).resolve().parents[1]
ROOT = HERE.parents[1]
TC = Path('/var/tmp/sparkling-matrix-recovery/toolchains')
def digest(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def sources():
    return [ROOT/'src/mj.ads', ROOT/'src/mj-types.ads',
        *sorted((ROOT/'experimental/smooth/src').glob('mj-elastic_*.ad?')),
        *sorted((ROOT/'experimental/frictionless-contact-candidate/src').glob('mj-contact_rows.ad?')),
        *sorted((HERE/'src').glob('*.ad?')), HERE/'tests/flex_contact_probe.adb']
def environment():
    e=os.environ.copy()
    e['PATH']=':'.join(str(next((TC/x).glob('*/bin'))) for x in ('gnat','gprbuild','gnatprove'))+':'+e['PATH']
    return e
def prepare(out, mode):
    out.mkdir(parents=True, exist_ok=True); src=out/'src'; src.mkdir(exist_ok=True)
    hashes={str(p.relative_to(ROOT)):digest(p) for p in sources()}
    for p in sources(): shutil.copyfile(p,src/p.name)
    (out/'sources.json').write_text(json.dumps(hashes,indent=2)+'\n')
    flags='"-O3", "-gnatp", "-gnatn", "-march=native", "-flto"' if mode=='release' else '"-O2", "-g", "-gnata", "-gnato", "-gnatVa"'
    (out/'flex.gpr').write_text('''project Flex is
  for Source_Dirs use ("src");
  for Main use ("flex_contact_probe.adb");
  for Object_Dir use "obj";
  for Exec_Dir use "bin";
  for Create_Missing_Dirs use "True";
  package Compiler is
    for Default_Switches ("Ada") use ("-gnat2022", "-ffp-contract=off", '''+flags+''');
  end Compiler;
  package Linker is
    for Default_Switches ("Ada") use ("-flto", "-ffp-contract=off");
  end Linker;
end Flex;
''')
    return hashes
def main():
    ap=argparse.ArgumentParser();ap.add_argument('--out',type=Path,required=True)
    ap.add_argument('--phase',choices=['build','small','whole'],required=True)
    ap.add_argument('--mode',choices=['validation','release'],default='validation')
    ap.add_argument('--only',help='substring filter for small subprogram diagnostics')
    ap.add_argument('--line',help='FILE:LINE for a single obligation diagnostic (small phase only)')
    ap.add_argument('--unit',action='append',choices=['mj-flex_contact_filter','mj-flex_contact_kernels','mj-flex_contact_network','mj-contact_rows','mj-elastic_kernels','mj-elastic_network'])
    ap.add_argument('--timeout',type=int,default=10,help='seconds per prover obligation')
    a=ap.parse_args()
    if a.line and a.phase!='small':ap.error('--line is diagnostic only; whole proofs cannot be limited')
    out=a.out.resolve(); hashes=prepare(out,a.mode);env=environment()
    resource.setrlimit(resource.RLIMIT_STACK,(64*1024*1024,resource.getrlimit(resource.RLIMIT_STACK)[1]))
    versions={x:subprocess.check_output([x,'--version'],env=env,text=True).splitlines()[0]
              for x in ('gcc','gprbuild','gnatprove')}
    (out/'toolchain.json').write_text(json.dumps(versions,indent=2))
    if a.phase=='build':
        cmd=['gprbuild','-P',str(out/'flex.gpr'),'-p','-j2']
        p=subprocess.run(cmd,env=env,capture_output=True,text=True)
        (out/'build.log').write_text(p.stdout+p.stderr)
        print((p.stdout+p.stderr)[-6000:]); p.check_returncode()
        exe=out/'bin/flex_contact_probe'
        (out/'binary.json').write_text(json.dumps(dict(path=str(exe),sha256=digest(exe),mode=a.mode,command=cmd),indent=2))
        return
    units=a.unit or ['mj-flex_contact_filter','mj-flex_contact_kernels','mj-flex_contact_network']
    targets=[]
    if a.line:
        filename,line=a.line.split(':')
        assert filename.endswith(('.ads','.adb')) and Path(filename).name==filename and int(line)>0
        assert (out/'src'/filename).is_file()
        targets=[(filename[:-4],a.line,'line-'+a.line.replace(':','-'))]
    elif a.phase=='small':
        for unit in units:
            for suffix in ('ads','adb'):
                path=out/'src'/f'{unit}.{suffix}'
                for n,line in enumerate(path.read_text().splitlines(),1):
                    m=re.match(r'\s*(function|procedure) (\w+)\b',line)
                    if m and (not a.only or a.only in m[2]):
                        # Declarations resolve to bodies as well; use body once.
                        if suffix=='ads' and re.search(r'\b'+m[2]+r'\b', (out/'src'/f'{unit}.adb').read_text().split(' is\n',1)[-1]) and m[2] in ['Normal_Load','Evaluate','Integrate','Step']: continue
                        targets.append((unit,f'{unit}.{suffix}:{n}',m[2]))
    else:
        targets=[(u,None,u) for u in (a.unit or units+['mj-contact_rows','mj-elastic_kernels','mj-elastic_network'])]
    records=[];ok=True
    for u,limit,label in targets:
        report=out/'obj/gnatprove'/f'{u}.spark'
        # GNATprove aggregates .spark diagnostics across the project. Keep old
        # reports in the evidence copies, not in a later unit's live summary.
        for old in report.parent.glob('*.spark'):old.unlink()
        cmd=[sys.executable,str(ROOT/'tools/guarded.py'),'--cap-mb','3800','--timeout','900','--',
             'gnatprove','-P',str(out/'flex.gpr'),'-u',u+'.ads','--prover=cvc5,z3,altergo',
             f'--timeout={a.timeout}','--steps=0','--proof=per_check','-j2','--checks-as-errors=on',
             '--warnings=continue','--report=all','--counterexamples=off']
        if limit:cmd+=[('--limit-line=' if a.line else '--limit-subp=')+limit]
        t=time.time();p=subprocess.run(cmd,env=env,capture_output=True,text=True)
        log=p.stdout+p.stderr; stem=f'{a.phase}-{label}-{len(records)}'
        (out/(stem+'.log')).write_text(log)
        rec=dict(unit=u,limit=limit,code=p.returncode,seconds=time.time()-t,command=cmd)
        if report.exists():
            d=json.loads(report.read_text());shutil.copyfile(report,out/(stem+'.spark.json'))
            bad=[x for k in ('proof','flow','warn_error') for x in d.get(k,[]) if x.get('severity') not in ['info','warning']]
            rec.update(checks=sum(x.get('severity')=='info' for k in ['proof','flow'] for x in d.get(k,[])),open=len(bad),warnings=[x for k in ['proof','flow','warn_error'] for x in d.get(k,[]) if x.get('severity')=='warning'])
            if not limit:
                assert not d['skip_proof'] and not d['skip_flow_proof'] and not d['pragma_assume']
                assert all(v=='all' for v in d['spark'].values())
                assert d['progress']=='PROGRESS_PROOF' and d['stop_reason']=='STOP_REASON_NONE'
                assert report.stat().st_mtime>=t-2
                rec['entities']=sorted(d['entities'][k]['name'] for k,v in d['spark'].items() if v=='all')
                expected=set();prefix='MJ.'+u.removeprefix('mj-').replace('-','.')
                for suffix in ['ads','adb']:
                    in_model=False
                    for line in (out/'src'/f'{u}.{suffix}').read_text().splitlines():
                        if 'package Model with' in line:in_model=True
                        if 'end Model;' in line:in_model=False
                        match=re.match(r'\s*(function|procedure) (\w+)\b',line)
                        if match:expected.add((prefix+('.Model' if in_model else '')+'.'+match[2]).lower())
                assert expected<={name.lower() for name in rec['entities']}, 'missing complete-unit entity coverage'
                rec['report_sha256']=digest(report)
            ok &= not bad
        else:ok=False
        ok &= p.returncode==0
        records.append(rec);(out/(a.phase+'-results.json')).write_text(json.dumps(records,indent=2)+'\n')
        print(label,p.returncode,rec.get('checks'),rec.get('open'),flush=True)
        if p.returncode:print('\n'.join(x for x in log.splitlines() if re.search(r'error:|medium:|high:|low:',x))[-6000:],flush=True)
        if not report.exists():break
    unchanged=hashes=={str(p.relative_to(ROOT)):digest(p) for p in sources()}
    (out/(a.phase+'-acceptance.json')).write_text(json.dumps(dict(passed=bool(ok and unchanged),sources_unchanged=unchanged),indent=2))
    sys.exit(0 if ok and unchanged else 1)
if __name__=='__main__':main()
