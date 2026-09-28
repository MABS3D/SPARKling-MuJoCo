import os,sys,re,json,subprocess,signal,time,hashlib
from pathlib import Path
root=Path(__file__).resolve().parents[1];os.chdir(root)
tc=Path('/var/tmp/sparkling-matrix-recovery/toolchains');env=os.environ.copy();env['PATH']=':'.join(str(p) for part in ['gnat','gprbuild','gnatprove'] for p in (tc/part).glob('*/bin'))+':'+env['PATH']
out=root/'evidence'/sys.argv[1];out.mkdir(exist_ok=False)
(out/'source').mkdir()
for p in (root/'src').glob('*'):(out/'source'/p.name).write_bytes(p.read_bytes())
(out/'proof.gpr').write_text('project Proof is\n for Source_Dirs use ("source");\n for Object_Dir use "obj";\n for Create_Missing_Dirs use "True";\n package Compiler is\n for Default_Switches ("Ada") use ("-gnat2022");\n end Compiler;\nend Proof;\n')
rows=[]
for name in sys.argv[2:]:
 text=(out/'source/mj-lu.adb').read_text();m=re.search(r'^   (?:procedure|function) '+name+r'\b',text,re.M);line=text[:m.start()].count('\n')+1
 cmd=['gnatprove','-P',str(out/'proof.gpr'),'-u','mj-lu.adb',f'--limit-subp=mj-lu.adb:{line}','--timeout=5','--steps=0','--prover=cvc5,z3,altergo','--proof=per_path','-j2','--report=all','--checks-as-errors=on','--counterexamples=off']
 start=time.monotonic()
 with (out/(name+'.log')).open('w') as f:
  p=subprocess.Popen(cmd,env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
  try:rc=p.wait(timeout=180)
  except subprocess.TimeoutExpired:os.killpg(p.pid,signal.SIGKILL);rc=p.wait();rc=124
 log=(out/(name+'.log')).read_text();warnings=[x for x in log.splitlines() if re.search(r'(^|: ) *(medium|high|error):',x)]
 r=dict(name=name,line=line,exit=rc,seconds=time.monotonic()-start,open=warnings,proved=len(re.findall(r'info: .*proved',log)),command=cmd)
 rows.append(r);(out/'results.json').write_text(json.dumps(rows,indent=2));print(name,rc,len(warnings),r['proved'],flush=True)
