from pathlib import Path
import re,json,subprocess,hashlib
w=Path(__file__).resolve().parent;exe=Path('/var/tmp/sparkling-matrix-round2/final-bench/bin/bench_main')
asmt=subprocess.check_output(['objdump','-d','-M','intel','--no-show-raw-insn',str(exe)],text=True)
p=re.split(r'(?m)^([0-9a-f]+) <([^>]+)>:\n',asmt);fs={p[i+1]:p[i+2] for i in range(1,len(p),3)}
def norm(s):
 ins=[]; labels={}
 for line in s.splitlines():
  m=re.match(r'\s*([0-9a-f]+):\s*(.+)',line)
  if not m:continue
  addr,line=m.groups();labels[addr]=len(ins)
  if re.match(r'(?:data16 |cs )*nop|xchg\s+ax,ax',line):continue
  ins.append(line)
 lines=[]
 for line in ins:
  line=line.replace('bench_ada_baseline__','bench_ada__').replace('mj__matrices_baseline__','mj__matrices__')
  def target(m):
   addr,name=m.groups()
   return f'<instruction_{labels[addr]}>' if addr in labels else f'<{name}>'
  line=re.sub(r'\b([0-9a-f]+) <([^>]+)>',target,line)
  line=re.sub(r'\[rip[+-]0x[0-9a-f]+\]','[rip+OFFSET]',line)
  lines.append(line.split('#')[0].strip())
 return '\n'.join(lines)
rows=[]
for i in range(1,21):
 a=next(n for n in fs if n.startswith(f'bench_ada__run_{i}.'));b=next(n for n in fs if n.startswith(f'bench_ada_baseline__run_{i}.'))
 aa,bb=norm(fs[a]),norm(fs[b]);rows.append({'operation':i,'normalized_wrapper_equal':aa==bb,'current_normalized_sha256':hashlib.sha256(aa.encode()).hexdigest(),'baseline_normalized_sha256':hashlib.sha256(bb.encode()).hexdigest()})
 (w/f'final-wrapper-{i}-current.txt').write_text(aa+'\n');(w/f'final-wrapper-{i}-baseline.txt').write_text(bb+'\n')
r=json.loads((w/'final-codegen.json').read_text());r['normalized_wrapper_comparison']={'scope':'instruction text with internal branch targets mapped to instruction indices, baseline package names normalized, RIP displacements and alignment NOPs removed; not a claim of identical microarchitectural behavior','script_sha256':hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),'results':rows};(w/'final-codegen.json').write_text(json.dumps(r,indent=2)+'\n');print([(r['operation'],r['normalized_wrapper_equal']) for r in rows])
