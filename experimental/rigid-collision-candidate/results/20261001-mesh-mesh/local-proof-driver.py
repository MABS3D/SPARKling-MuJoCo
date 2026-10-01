from pathlib import Path
import sys,subprocess,os,json,hashlib,re
sys.path.insert(0,'/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/rigid-collision-candidate/tests')
from common import environment, ROOT
out=Path(sys.argv[1]); snapshot=Path(sys.argv[2])/'source';out.mkdir(parents=True,exist_ok=False)
units={'mj-convex_assets.ads':['Graph_Header'], 'mj-convex_assets.adb':['Seed_Coordinate','Encode_Neighbour','Find_End','Encode_Parts','Valid_Graph','Compile_Graph','Compile_Degrees','Best_Vertex'], 'mj-contact_incidence.adb':['Find_Corner','Model_Count','List_Matches','Reset','Append_Vertex','Build']}
summary=[]
for unit, subs in units.items():
    source=snapshot/'src'/unit
    lines=source.read_text().splitlines()
    for sub in subs:
        line=next(i+1 for i,s in enumerate(lines) if re.match(r'\s*(function|procedure) '+sub+r'\b',s))
        env=environment();env['RIGID_BUILD_ROOT']=str(out/sub);env['RIGID_MODE']='validation'
        cmd=['gnatprove','-P',str(snapshot/'rigid.gpr'),'-u',unit,'-j1','--checks-as-errors=on','--report=all','--level=2','--prover=cvc5,altergo','--timeout=5','--counterexamples=off',f'--limit-subp={unit}:{line}']
        with (out/(sub+'.log')).open('w') as log:
            result=subprocess.run(['python3',str(ROOT/'tools/guarded.py'),'--cap-mb','3000','--timeout','100','--',*cmd],env=env,stdout=log,stderr=subprocess.STDOUT)
        row=dict(unit=unit,subprogram=sub,exitcode=result.returncode,command=cmd,source_sha256=hashlib.sha256(source.read_bytes()).hexdigest())
        summary.append(row);(out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(sub,result.returncode,flush=True)
