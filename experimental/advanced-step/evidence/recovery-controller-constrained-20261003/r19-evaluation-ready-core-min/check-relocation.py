from pathlib import Path
import re,json,hashlib
base=Path('/var/tmp/sparkling-services-advanced-evaluation-child16-r19-20261003/source/experimental/advanced-step/src')
dst=Path('/var/tmp/sparkling-services-advanced-evaluation-child17-r19-20261003')
p=dst/'source/experimental/advanced-step/src'
old=(base/'mj-data-advanced_control-evaluation.adb').read_text();new=(p/'mj-data-advanced_control-evaluation.adb').read_text()
start=old.index('   procedure Evaluate_Ready (',old.index('   procedure Evaluate_Ready (')+1)
a=old[start:old.index('   end Evaluate_Ready;',start)+len('   end Evaluate_Ready;')]
a=a.replace('procedure Evaluate_Ready (D : in out Simulation; E : in out Controller;', 'procedure Evaluate_Ready_Core (D : in out Simulation; Source : Input_Storage; Work : in out Evaluation_Storage;').replace('end Evaluate_Ready;','end Evaluate_Ready_Core;')
a=a.replace('E.Source.','Source.').replace('E.Work.','Work.').replace('Computation.Compute (D, E, Result);','Computation.Compute_Core (D, Source, Work, Result);')
a='\n'.join(line for line in a.split('\n') if not any(x in line for x in ['Initial_Na :','Initial_Activation :','pragma Assert (Static => Activation (E)','pragma Assert (Static => Source.Na =']))
start=new.index('   procedure Evaluate_Ready_Core (',new.index('   procedure Evaluate_Ready_Core (')+1)
b=new[start:new.index('   end Evaluate_Ready_Core;',start)+len('   end Evaluate_Ready_Core;')]
assert a==b
assert re.search(r'\bE\.',b) is None
name='mj-data-advanced_control-computation.adb'
assert (base/name).read_text().replace('Result : out Status) with Global => null is','Result : out Status) is')==(p/name).read_text()
result={'ready_core_body_identical_after_formal_renaming_and_removal_of_controller_ghost_images':True,'computation_core_body_identical':True,'new_calls':'Thin Ready wrapper calls Ready_Core; Ready_Core calls existing computation body directly with component formals. No arithmetic or branch order changed. Numerical equivalence still requires runtime validation.', 'source_files':{str(x.relative_to(dst/'source')):hashlib.sha256(x.read_bytes()).hexdigest() for x in p.glob('mj-data-advanced_control*')}}
(dst/'relocation-equivalence.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k!='source_files'},indent=2))
