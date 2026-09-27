from pathlib import Path
import subprocess,re,json,hashlib
w=Path(__file__).resolve().parent
paths={k:Path('/var/tmp/sparkling-matrix-round2')/('standalone-baseline' if k=='baseline' else 'standalone-boundary-fixed')/'bin/bench_main' for k in ['baseline','current']}
def get_functions(exe):
 s=subprocess.check_output(['objdump','-d','-M','intel','--no-show-raw-insn',str(exe)],text=True)
 p=re.split(r'(?m)^([0-9a-f]+) <([^>]+)>:\n',s)
 return {p[i+1]:p[i+2] for i in range(1,len(p),3)}
def normalize(s):
 ins=[];labels={}
 for line in s.splitlines():
  m=re.match(r'\s*([0-9a-f]+):\s*(.+)',line)
  if not m:continue
  addr,line=m.groups();labels[addr]=len(ins)
  if re.match(r'(?:data16 |cs )*nop|xchg\s+ax,ax',line):continue
  ins.append(line)
 out=[]
 for line in ins:
  def target(m):
   addr,name=m.groups();return f'<instruction_{labels[addr]}>' if addr in labels else f'<{name}>'
  line=re.sub(r'\b([0-9a-f]+) <([^>]+)>',target,line)
  line=re.sub(r'\[rip[+-]0x[0-9a-f]+\]','[rip+OFFSET]',line)
  out.append(line.split('#')[0].strip())
 return '\n'.join(out)
fs={k:get_functions(p) for k,p in paths.items()};report={'binaries':{},'comparison':[]}
for k,funcs in fs.items():
 roots=[n for n in funcs if re.match(r'(bench_ada__run_|c_run_)\d+(?:\.|$)',n)];assert len(roots)==40,len(roots)
 selected=set(roots);todo=list(roots)
 while todo:
  n=todo.pop()
  for target in re.findall(r'\b(?:call|jmp)\s+[0-9a-f]+ <([^>]+)>',funcs[n]):
   if '+' not in target and target in funcs and target not in selected:selected.add(target);todo.append(target)
 text='\n'.join(f'<{n}>:\n{funcs[n]}' for n in sorted(selected));(w/f'standalone-{k}-hot-loops.asm').write_text(text)
 report['binaries'][k]={'sha256':hashlib.sha256(paths[k].read_bytes()).hexdigest(),'timing_roots':len(roots),'reachable_functions':len(selected),'ghost_or_secondary_stack_symbols':[n for n in selected if any(x in n for x in ['secondary_stack','matrix_models','vector_models'])],'fma':re.findall(r'\bv?f(?:n?madd|n?msub|maddsub|msubadd)\w*',text),'calls_by_wrapper':{n:re.findall(r'\bcall\s+[^\n]+',funcs[n]) for n in roots}}
for language,prefix in [('Ada','bench_ada__run_'),('C','c_run_')]:
 for i in range(1,21):
  norms={k:normalize(v[next(n for n in v if n.startswith(f'{prefix}{i}.'))]) for k,v in fs.items()}
  report['comparison'].append({'language':language,'operation':i,'normalized_instructions_equal':norms['baseline']==norms['current'],'hashes':{k:hashlib.sha256(v.encode()).hexdigest() for k,v in norms.items()}})
report['scope']='40 wrappers per binary and resolved direct targets. Normalization removes alignment NOPs, address relocation and RIP displacement; branch targets map to instruction indices. This is not a universal equivalence or identical-layout claim.'
(w/'standalone-codegen.json').write_text(json.dumps(report,indent=2)+'\n')
print('different normalized wrappers',[(x['language'],x['operation']) for x in report['comparison'] if not x['normalized_instructions_equal']])
print('calls in MulMatVec, bilinear, MulMatMatT', {k:{n:calls for n,calls in d['calls_by_wrapper'].items() if any(n.startswith('bench_ada__run_'+str(i)+'.') for i in [7,9,16])} for k,d in report['binaries'].items()})
