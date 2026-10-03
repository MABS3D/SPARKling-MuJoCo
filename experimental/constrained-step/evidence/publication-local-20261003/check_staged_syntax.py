from pathlib import Path
import subprocess,json,collections,ast,hashlib
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
paths=[p.decode() for p in subprocess.check_output(['git','diff','--cached','--name-only','-z'],cwd=repo).split(b'\0') if p]
proc=subprocess.Popen(['git','cat-file','--batch'],cwd=repo,stdin=subprocess.PIPE,stdout=subprocess.PIPE)
counts=collections.Counter();failures=[];sizes=[]
for name in paths:
 if Path(name).suffix not in ('.py','.json'):continue
 proc.stdin.write((':'+name+'\n').encode());proc.stdin.flush()
 header=proc.stdout.readline().decode().strip().split()
 if len(header)!=3:raise RuntimeError(header)
 size=int(header[2]);data=proc.stdout.read(size);assert proc.stdout.read(1)==b'\n'
 try:
  if name.endswith('.py'):ast.parse(data.decode('utf-8-sig'),filename=name);counts['python']+=1
  else:json.loads(data.decode('utf-8-sig'));counts['json']+=1
 except Exception as ex:failures.append(dict(path=name,error=str(ex)))
proc.stdin.close();assert proc.wait()==0
result=dict(files=len(paths),syntax=dict(counts),failures=failures,scope='Syntax of changed staged blobs only; no new formal proof or numerical claim.')
Path('/var/tmp/sparkling-publication-local-checks-20261003.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result,indent=2))
raise SystemExit(bool(failures))
