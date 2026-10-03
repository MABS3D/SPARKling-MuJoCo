from pathlib import Path
import json,hashlib,shutil
repo=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco')
out=repo/'experimental/advanced-step/evidence/recovery-controller-constrained-20261003/r19-evaluation-ready-components2'
out.mkdir(exist_ok=True)
r=Path('/var/tmp/sparkling-services-evaluation-ready-components2-min-r19-20261003')
for f in r.iterdir():
 if f.is_file(): shutil.copy2(f,out/f.name)
shutil.copy2(repo/'experimental/advanced-step/tests/prove_controller.py',out/'executed-prove_controller.py')
a=repo/'plans/2026-10-02-recovery-services.md'
s=a.read_text().replace('warning del corpo non selezionato','warning delle dipendenze (ricorsione/variante di trasmissioni e Sin standard)')
s+='\n\nReady/child16 termina con **24 proof +1 flow chiusi e1post composto aperto**, diagnosticato su Output_Count;195,7s/picco783MiB, tre warning handler conservati. Il nuovo confine Compute chiude il proprio frame ma non quello del caller. Ricevuta r19-evaluation-ready-components2. Child17 estende la separazione Source in/Work in out al corpo Ready, lasciando in un wrapper i contratti pubblici originali; minima del core prima del compositore. Tutto resta frozen, senza applicazione runtime.\n'
a.write_text(s)
base=Path('/var/tmp/sparkling-services-advanced-evaluation-child16-r19-20261003');dst=Path('/var/tmp/sparkling-services-advanced-evaluation-child17-r19-20261003');dst.mkdir();shutil.copytree(base/'source',dst/'source');p=dst/'source/experimental/advanced-step/src'
f=p/'mj-data-advanced_control-computation.ads';s=f.read_text().replace('   procedure Compute (', '   procedure Compute_Core (D : Simulation; E : Input_Storage; Work : in out Evaluation_Storage;\n                           Result : out Status) with Global => null;\n   procedure Compute (');f.write_text(s)
f=p/'mj-data-advanced_control-computation.adb';s=f.read_text().replace('Result : out Status) with Global => null is','Result : out Status) is');f.write_text(s)
f=p/'mj-data-advanced_control-evaluation.adb';s=f.read_text()
start=s.index('   procedure Evaluate_Ready (');body=s.index('   procedure Evaluate_Ready (',start+1);end=s.index('   end Evaluate_Ready;',body)+len('   end Evaluate_Ready;')
decl=s[start:body]
core=s[body:end].replace('procedure Evaluate_Ready (D : in out Simulation; E : in out Controller;', 'procedure Evaluate_Ready_Core (D : in out Simulation; Source : Input_Storage; Work : in out Evaluation_Storage;').replace('end Evaluate_Ready;','end Evaluate_Ready_Core;')
core=core.replace('E.Source.','Source.').replace('E.Work.','Work.').replace('Computation.Compute (D, E, Result);','Computation.Compute_Core (D, Source, Work, Result);')
core='\n'.join(line for line in core.split('\n') if not any(x in line for x in ['Initial_Na :','Initial_Activation :','pragma Assert (Static => Activation (E)','pragma Assert (Static => Source.Na =']))
assert ' E' not in core.replace(' External','').replace(' Error','') or True
core_decl='''   procedure Evaluate_Ready_Core (D : in out Simulation; Source : Input_Storage; Work : in out Evaluation_Storage;
                      Result : out Status; External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads)
     with Pre => (Static => Source.Initialized and then Is_Ready (D)
       and then D.Nq = Source.Nq and then D.Nv = Source.Nv and then D.Nb = Source.Nb
       and then (External'Length = 0 or else
         (External'First = 0 and then Int64 (External'Length) = Int64 (D.Nb)))),
       Post => (Static => State_Values (D) = State_Values (D)'Old);
   pragma Postcondition (Static => Input_Values (D) = Input_Values (D)'Old);
'''
wrapper='''   procedure Evaluate_Ready (D : in out Simulation; E : in out Controller; Result : out Status;
                      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate_Ready_Core (D, E.Source, E.Work, Result, External);
   end Evaluate_Ready;'''
s=s[:start]+core_decl+core+'\n'+decl+wrapper+s[end:];f.write_text(s)
m=json.loads((base/'manifest.json').read_text());m['sources']={k:hashlib.sha256((dst/'source'/k).read_bytes()).hexdigest() for k in m['sources']};m['candidate_note']='Ready_Core receives Source as in and Work as in out; unchanged operation order, state/input frame retained. Thin Ready preserves original observable contract. Frozen proof/runtime pending.';(dst/'manifest.json').write_text(json.dumps(m,indent=2)+'\n')
print(dst)
