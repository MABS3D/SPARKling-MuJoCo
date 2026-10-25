"""Prove admission minima/callers on an immutable complete 3.17 source overlay."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import time

ROOT=Path(__file__).resolve().parents[3]
SCOPES={name:('mj-model_admission','.ads' if name=='CSR_Error' else '.adb')
        for name in ['CSR_Error','Reveal_Flex_Layout','Check_Flexedge_J','Check_Flexvert_J','Check_Efm0_L','Check_Efm0_Dofs','Check_Flex','Check_Bodies','Reveal_Dof_Layout','Check_Dofs','Check_Maps','Reveal_Joint_Count_Layout','Reveal_Tendon_Layout','Check_M_CSR','Check_B_CSR','Check_D_CSR','Check_Tendon_CSR']}
SCOPES.update({name:('mj-models-validity','.ads') for name in [
    'Sparse_M_OK','Sparse_B_OK','Sparse_D_OK','Sparse_Ten_J_OK',
    'Sparse_Flexedge_J_OK','Sparse_Flexvert_J_OK','Sparse_Efm0_L_OK','Efm0_Dofs_OK',
    'Flex_Structures_OK','B_Inputs_OK','B_Root_OK','B_Parent_Subset_At','B_Ancestor_At',
    'B_Structure_OK','D_B_Row_At','D_B_Rows_OK','D_Diag_At','D_Diags_OK','Mesh_Faces_Core','Meshes_OK']})
SCOPES.update({name:('mj-models-validity','.adb') for name in ['Reveal_Mesh_Layout','Mesh_Faces_At']})
SCOPES.update({name:('mj-validation','.adb') for name in ['Count_Equality_Rows','Count_Positive','Count_Enabled','Count_Limit_Rows','Compute_Caps','Reveal_Layout','Diagnose','Diagnose_Sparse','Diagnose_Assets','Validate']})

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--engine',type=Path,required=True)
    parser.add_argument('--out',type=Path,required=True)
    selection=parser.add_mutually_exclusive_group(required=True)
    selection.add_argument('--subprogram',choices=SCOPES)
    selection.add_argument('--whole-admission',action='store_true')
    parser.add_argument('--analysis',type=Path)
    args=parser.parse_args();engine=args.engine.resolve();out=args.out.resolve();out.mkdir(parents=True,exist_ok=False)
    source=engine/'source';manifest_path=engine/'manifest.json';manifest=json.loads(manifest_path.read_text())
    assert manifest['reference']=='3.17.0' and manifest['commit']=='800a109a4bdd02cb60404d565db4ae16fb04a53b'
    assert manifest['phase']=='admission-prepared'
    def matches():return all(digest(source/n)==v for n,v in manifest['candidate_sources'].items())
    assert matches(),'Frozen engine differs'
    runner_hash=digest(Path(__file__));guard_hash=digest(ROOT/'tools/guarded.py')
    shutil.copyfile(Path(__file__),out/'runner.py');shutil.copyfile(ROOT/'tools/guarded.py',out/'guarded.py')
    unit,suffix=('mj-model_admission','.adb') if args.whole_admission else SCOPES[args.subprogram]
    locations=set();definitions=[];line=None
    for ext in ['.ads','.adb']:
        path=source/'src'/(unit+ext)
        if path.exists():
            for i,text in enumerate(path.read_text().splitlines(),1):
                if args.subprogram and re.match(r'\s*(?:function|procedure) '+args.subprogram+r'\b',text):
                    locations.add((unit+ext,i))
                    if ext==suffix:definitions.append((i,text))
    if not args.whole_admission:
        if len(definitions)>1:
            definitions=[entry for entry in definitions if re.search(r'\bis\b',entry[1])]
        assert len(definitions)==1,'Ambiguous definition'
        line=definitions[0][0]
    analysis=args.analysis.resolve() if args.analysis else out/'build'
    analysis.mkdir(parents=True,exist_ok=True)
    stamp=analysis/'admission-manifest.sha256';signature=digest(manifest_path)
    if stamp.exists():assert stamp.read_text().strip()==signature,'Analysis source mismatch'
    else:
        assert not any(analysis.iterdir()),'Unknown existing analysis cache'
        stamp.write_text(signature+'\n')
    for p in analysis.rglob(unit+'.spark'):p.unlink()
    env=os.environ.copy();tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains')
    env['PATH']=':'.join(str(p) for name in ['gnat','gprbuild','gnatprove'] for p in (tc/name).glob('*/bin'))+':'+env['PATH']
    env['SPARKLING_BUILD_ROOT']=str(analysis)
    command=['gnatprove','-P',str(source/'sparkling_mujoco.gpr'),'-XSPARKLING_BUILD_MODE=development',
        '-u',unit+suffix,'-j1','--report=all','--checks-as-errors=on',
        '--warnings=continue','--no-inlining','--mode=prove','--prover=cvc5,z3,altergo','--timeout=3','--memlimit=650',
        '--steps=0','--proof=per_check','--counterexamples=off']
    if not args.whole_admission:command.append('--limit-subp='+unit+suffix+':'+str(line))
    start=time.monotonic();log=out/'proof.log'
    with log.open('w') as stream:
        run=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','2500','--timeout','240','--',*command],
                           env=env,cwd=source,stdout=stream,stderr=subprocess.STDOUT)
    kind=('whole_unit' if args.whole_admission else 'body_contract' if suffix=='.adb' or args.subprogram=='CSR_Error' else 'expression_safety')
    result=dict(subprogram=args.subprogram or 'whole admission',minimum_kind=kind,command=command,exit=run.returncode,
        seconds=time.monotonic()-start,engine_manifest_sha256=signature,source_hashes_unchanged=matches(),
        runner_sha256=runner_hash,guard_sha256=guard_hash,log_sha256=digest(log),
        driver_hashes_unchanged=(digest(Path(__file__))==runner_hash and digest(ROOT/'tools/guarded.py')==guard_hash),
        obligations_closed=False,passed=False)
    if args.subprogram and args.subprogram.startswith('Count_'):
        result['contract_scope']='Reduction bounds only; exact counting behavior is not specified by the current contract and remains a Gold objective.'
    reports=list(analysis.rglob(unit+'.spark'))
    if len(reports)==1:
        data=json.loads(reports[0].read_text());shutil.copyfile(reports[0],out/'unit.spark.json')
        selected=[data.get('entities',{}).get(key,{}) for key,value in data.get('spark',{}).items() if value=='all']
        if args.whole_admission:
            scope_matches=all(any(e.get('name','').lower().endswith('.'+name.lower()) for e in selected)
                              for name in ['CSR_Error','Reveal_Flex_Layout','Check_Flexedge_J','Check_Flexvert_J','Check_Efm0_L','Check_Efm0_Dofs','Check_Flex','Check_Bodies','Reveal_Dof_Layout','Check_Dofs','Check_Maps','Reveal_Joint_Count_Layout','Reveal_Tendon_Layout','Check_M_CSR','Check_B_CSR','Check_D_CSR','Check_Tendon_CSR'])
        else:
            scope_matches=any(e.get('name','').lower().endswith('.'+args.subprogram.lower())
                and any((p.get('file'),p.get('line')) in locations for p in e.get('sloc',[])) for e in selected)
        entries=[e for kind in ['proof','flow','warn_error'] for e in data.get(kind,[])]
        result.update(checks=sum(e.get('severity')=='info' for e in entries),proof_checks=len(data.get('proof',[])),
            flow_checks=len(data.get('flow',[])),open=[e for e in entries if e.get('severity') not in ['info','warning']],
            warnings=[e for e in entries if e.get('severity')=='warning'],report_scope_matches=scope_matches,
            scope_coverage_complete=(all(k in data for k in ['skip_proof','skip_flow_proof','pragma_assume'])
                and not data.get('skip_proof') and not data.get('skip_flow_proof') and not data.get('pragma_assume')
                and bool(data.get('spark')) and all(v=='all' for v in data['spark'].values())
                and data.get('progress')=='PROGRESS_PROOF' and data.get('stop_reason')=='STOP_REASON_NONE'))
        result['obligations_closed']=(run.returncode==0 and result['source_hashes_unchanged'] and result['driver_hashes_unchanged']
            and result['report_scope_matches'] and result['scope_coverage_complete'] and not result['open']
            and (result['proof_checks']>0 or (kind=='expression_safety' and result['flow_checks']>0)))
        result['passed']=result['obligations_closed'] and not result['warnings']
    else:result['report_rejected']='Expected exactly one fresh scoped report'
    (out/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result.get(k) for k in ['subprogram','exit','checks','obligations_closed','passed']}))
    raise SystemExit(not result['obligations_closed'])

if __name__=='__main__':main()
