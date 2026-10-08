from pathlib import Path
import subprocess,json
root=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
scopes=['Packed_Mass_Value_Sum','Packed_Flat_Rows_Ordered','Packed_Flat_Prior_Rows','Packed_Flat_Following_Rows','Packed_Load_Mass_Row','Packed_Load_Mass_Values','Packed_Add_Mass_Values_Row','Packed_Add_Mass_Values','Gram_Element_Flat','Gram_Row_Flat','Packed_Factor_Values']
rows=[]
for scope in scopes:
 out=Path('/var/tmp')/('sparkling-alignment-315-hessian-'+scope.lower().replace('_','-')+'-scope-r100-20261008')
 run=subprocess.run(['python3',str(root/'experimental/alignment-3.15/tests/prove_flex.py'),'--engine','/var/tmp/sparkling-alignment-315-hessian-engine-r100-20261008','--out',str(out),'--subprogram',scope],cwd=root)
 d=json.loads((out/'results.json').read_text())
 rows.append(dict(scope=scope,out=str(out),exit=run.returncode,checks=d.get('checks'),passed=d.get('passed'),open=[dict(file=e['file'],line=e['line'],message=e['message']['text']) for e in d.get('open',[])]))
 Path('/var/tmp/sparkling-hessian-minima-r100.json').write_text(json.dumps(rows,indent=2)+'\n')
 print(json.dumps(rows[-1]),flush=True)
