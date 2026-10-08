from pathlib import Path
import subprocess,json
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco');rows=[]
for scope in ['Gram_Scaled','Gram_Row_Flat','Packed_Factor_Values']:
 out=Path('/var/tmp')/('sparkling-alignment-315-hessian-'+scope.lower().replace('_','-')+'-scope-r102-20261008')
 r=subprocess.run(['python3',str(root/'experimental/alignment-3.15/tests/prove_flex.py'),'--engine','/var/tmp/sparkling-alignment-315-hessian-engine-r102-20261008','--out',str(out),'--subprogram',scope],cwd=root)
 d=json.loads((out/'results.json').read_text());rows.append(dict(scope=scope,out=str(out),exit=r.returncode,checks=d.get('checks'),passed=d.get('passed'),open=[dict(file=e['file'],line=e['line'],message=e['message']['text']) for e in d.get('open',[])]))
 Path('/var/tmp/sparkling-hessian-pending-r102.json').write_text(json.dumps(rows,indent=2)+'\n');print(json.dumps(rows[-1]),flush=True)
 if d.get('checks') is None:break
