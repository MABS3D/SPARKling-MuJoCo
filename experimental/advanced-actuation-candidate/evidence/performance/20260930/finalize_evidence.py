from pathlib import Path
import copy,hashlib,importlib.util,json,shutil,subprocess
import mujoco,numpy as np
candidate=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/advanced-actuation-candidate')
scratch=Path('/var/tmp/sparkling-actuators-performance-20260930')
run=scratch/'comparison-v2';destination=candidate/'evidence/performance/20260930'
destination.mkdir(parents=True,exist_ok=True)
def digest(p):return hashlib.sha256(p.read_bytes()).hexdigest()
raw=json.loads((run/'results.json').read_text())
assert raw==json.loads((destination/'stage-results-raw.json').read_text())
for name,value in raw['candidate_sources'].items():
 assert digest(destination/'sources'/name)==value,name+' archived measured source'
 if name.startswith(('src/','base/')):assert digest(candidate/name)==value,name+' current kernel changed'
for name,row in raw['binaries'].items():assert digest(Path(row['path']))==row['sha256'],name+' measured binary changed'
shutil.copyfile(candidate/'performance.gpr',destination/'sources/performance.gpr')
assert digest(destination/'sources/performance.gpr')==raw['performance_project_sha256']
assert digest(Path('/var/tmp/sparkling-movement-c/build/lib/libmujoco.so.3.14.0'))==raw['native_library_sha256']
shutil.copytree(run,destination/'runs',dirs_exist_ok=True)
shutil.copyfile(scratch/'stage-disassembly.txt',destination/'stage-disassembly.txt')
for name in ['movement_reference.c','movement_reference.py']:
 shutil.copyfile(candidate/'tests/performance'/name,destination/'sources/tests/performance'/name)
shutil.copyfile(Path('/var/tmp/sparkling-actuators-20260930/oracle/oracle.c'),destination/'oracle.c')
shutil.copyfile(Path('/var/tmp/sparkling-movement-c/build/compile_commands.json'),destination/'c-engine-compile-commands.json')
assert digest(destination/'c-engine-compile-commands.json')==raw['c_engine_compile_commands_sha256']
# Recheck every archived output against C, beyond the original run's checks.
spec=importlib.util.spec_from_file_location('benchmark',candidate/'tests/performance/compare.py');bench=importlib.util.module_from_spec(spec);spec.loader.exec_module(bench)
checks=0
for row in raw['results']:
 folder=run/row['name'];m=mujoco.MjModel.from_binary_path(str(folder/'model.mjb'))
 values=np.fromstring((folder/'c.input').read_text(),sep=' ');assert int(values[0])==8;cursor=1;targets=[]
 for frame in range(8):
  d=mujoco.MjData(m)
  for field in ['qpos','qvel','ctrl','act']:
   array=getattr(d,field);array[:]=values[cursor:cursor+len(array)];cursor+=len(array)
  mujoco.mj_forward(m,d);targets.append(bench.expected(m,d))
 assert cursor==len(values)
 for block in range(9):
  outputs={}
  for kind in ['ada','c']:
   frames,times,sink=bench.parse((folder/f'block-{block}-{kind}.output').read_text())
   assert len(frames)==8 and len(times)==3
   for actual,expected in zip(frames,targets):np.testing.assert_allclose(actual,expected,atol=2e-11,rtol=2e-11);checks+=1
   outputs[kind]=(times,sink)
  np.testing.assert_allclose(outputs['ada'][1],outputs['c'][1],atol=2e-10,rtol=2e-10)
  np.testing.assert_allclose(np.median(outputs['ada'][0])/np.median(outputs['c'][0]),row['block_ratios'][block],atol=0,rtol=1e-14)
# Contextual C-only trajectory records: recover only the three completed cases.
movement=[]
for name in ['hinge_motor','dc_full','so3_quat']:
 folder=run/name;m=mujoco.MjModel.from_binary_path(str(folder/'model.mjb'));d=mujoco.MjData(m)
 initial=np.fromstring((folder/'c.input').read_text(),sep=' ')[1:];offset=0
 for field in ['qpos','qvel','ctrl','act']:
  array=getattr(d,field);array[:]=initial[offset:offset+len(array)];offset+=len(array)
 for _ in range(2000):mujoco.mj_step(m,d)
 assert all(w.number==0 for w in d.warning)
 expected=np.r_[d.time,d.qpos,d.qvel,d.act];times=[];states=0
 for block in range(9):
  for line in (folder/f'movement-reference-{block}.output').read_text().splitlines():
   kind,*values=line.split();values=np.array(list(map(float,values)))
   if kind=='sample':times.append(float(values[0])/2000)
   else:
    assert kind=='state';np.testing.assert_allclose(values,expected,atol=2e-8,rtol=2e-8);states+=1
 assert len(times)==27 and states==27
 movement.append({'name':name,'steps':2000,'blocks':9,'samples_per_block':3,'c_whole_step_us':float(np.median(times)*1e6),'native_vs_official_trajectory_passed':True,
                  'timings_us':dict(zip(['p10','p50','p90'],map(float,np.percentile(times,[10,50,90])*1e6)))})
# Explicitly preserve the supplementary run's failure, without treating unstable trajectories as accepted.
folder=run/'dc_chain_8';m=mujoco.MjModel.from_binary_path(str(folder/'model.mjb'));d=mujoco.MjData(m)
initial=np.fromstring((folder/'c.input').read_text(),sep=' ')[1:];offset=0
for field in ['qpos','qvel','ctrl','act']:
 array=getattr(d,field);array[:]=initial[offset:offset+len(array)];offset+=len(array)
for _ in range(2000):mujoco.mj_step(m,d)
assert any(w.number>0 for w in d.warning)
movement.extend([{'name':'dc_chain_8','status':'rejected_unstable_official_reference','warnings':[{'index':i,'number':int(w.number),'lastinfo':int(w.lastinfo)} for i,w in enumerate(d.warning) if w.number]},
                 {'name':'dc_chain_32','status':'not_run_after_dc_chain_8_failure'}, {'name':'dc_chain_64','status':'not_run_after_dc_chain_8_failure'}])
context={'scope':'C-only complete mj_step on evolving trajectories; contextual measurements, not aggregate Ada/C comparison','recovered_completed_results_from_raw_outputs':True,
         'supplementary_run_completed':False,'results':movement,'cpu':raw['cpu'],'native_library_sha256':raw['native_library_sha256'],
         'binary_sha256':digest(scratch/'bin/movement_reference'),'sources':{str(p.relative_to(candidate)):digest(p) for p in [candidate/'tests/performance/movement_reference.c',candidate/'tests/performance/movement_reference.py']}}
(destination/'movement-reference.json').write_text(json.dumps(context,indent=2)+'\n')
corrected=copy.deepcopy(raw)
for row in corrected['results']:
 if row['name']=='so3_site':row['prepared_geometry_advantage']=True
corrected['metadata_corrections']=[{'field':'results[so3_site].prepared_geometry_advantage','original':False,'corrected':True,'reason':'SO3 site uses prepared site/reference Jacobians too; no timing or numerical change'}]
corrected.update(stage_gate_passed=False,all_17_stage_cases_slower_confirmed=True,numerical_frames_rechecked=checks,
                 aggregate_movement_measured=False,integration_performed=False,decision='reject_candidate_integration',
                 reasons=['all 17 stage ratios have CI95 lower bound above 1','complete formal proof obligations remain open','aggregate Ada/C movement not integrated or measured'])
(destination/'stage-results.json').write_text(json.dumps(corrected,indent=2)+'\n')
proofs=json.loads((candidate/'evidence/summary.json').read_text())
for name,value in proofs['sources'].items():assert digest(candidate/name)==value
for mode in ['validation','release']:
 numeric=json.loads((candidate/f'evidence/numerics-{mode}.json').read_text());assert numeric['passed'] and numeric['cases']==4836
 actual={str(p.relative_to(candidate)):digest(p) for folder in ['base','src','tests'] for p in (candidate/folder).iterdir() if p.is_file()}
 assert actual==numeric['sources'],mode+' numerical evidence freshness'
proofs.update(performance_measured=True,performance_scope='isolated actuation phase',aggregate_movement_performance_measured=False,
              performance_record='evidence/performance/20260930/stage-results.json',performance_integration_gate_passed=False,
              integrated_in_engine=False,performance_summary_added_separately_from_proof_generator=True)
(candidate/'evidence/summary.json').write_text(json.dumps(proofs,indent=2)+'\n')
lines=['# Confronto attuazione avanzata — 2026-09-30','',
 '**Esito: non integrare.** Tutti i 17 carichi sono più lenti del riferimento C; nessun intervallo di confidenza comprende la parità. Il candidato e i test restano isolati in questa cartella. Il motore principale non è stato modificato.','',
 '## Tempi della fase di attuazione','',
 'Sono inclusi trasmissione, velocità, dinamica/forza degli attuatori, avanzamento delle attivazioni e proiezione sparsa delle forze generalizzate. I tempi sono per un batch completo con il numero di attuatori indicato; non per singolo attuatore e non per una simulazione intera.','',
 '| Caso | Attuatori | Ada µs | C µs | Ada/C | IC95 rapporto |','|---|---:|---:|---:|---:|---|']
for row in raw['results']:
 lo,hi=row['ratio_ci95'];lines.append(f"| {row['name']} | {row['nactuator']} | {row['ada_us']:.3f} | {row['c_us']:.3f} | {row['ada_over_c']:.2f}× | {lo:.2f}–{hi:.2f} |")
lines.extend(['', 'Il rapporto è la mediana dei rapporti dei blocchi appaiati, quindi può differire dal quoziente delle mediane marginali della tabella. Questo scarto non è rumore nell’ordine dell’1–2%.', '',
 '## Metodo e correttezza','',
 'AMD Ryzen 7 9800X3D, Linux/WSL, CPU 15 fissata per entrambi i processi. Nove blocchi alternati Ada/C, tre campioni per blocco, warmup, otto snapshot per modello. Preparazione, caricamento e I/O fuori dai loop misurati; barriera assembler e checksum impediscono eliminazione/hoisting del lavoro. Bootstrap appaiato dei nove blocchi, 10000 ricampionamenti, seed 3140930. Gli intervalli descrivono questa sessione su questo dispositivo, non ogni macchina o modello.', '',
 'Ada: GNAT 16.1.0, `-O3 -gnatp -gnatn -march=native -flto`, contrazione FP disabilitata. C: stesso GCC 16.1.0, MuJoCo 3.14.0 nativo con `-O3 -march=native -flto=auto`, SIMD/AVX abilitato e contrazione FP disabilitata. Comandi, CPU, hash di librerie, eseguibili e sorgenti sono registrati nei JSON.', '',
 'Ogni output dei due eseguibili è confrontato con il riferimento ufficiale MuJoCo 3.14.0: lunghezze, velocità, forze, derivate, attivazioni successive, forze generalizzate, conteggi/colonne/valori delle righe sparse. La tolleranza assoluta/relativa è 2e-11, il checksum 2e-10. Tutti i 136 snapshot sono passati; il controllo degli output archiviati è stato ripetuto su 2448 frame (17×9×2×8). La precedente suite di 4836 casi per build resta fresca e invariata.', '',
 'Site/refsite, SO3 site, slider-crank e adesione ricevono Jacobiani/preparazione già calcolati sul lato Ada. C esegue questa preparazione nella trasmissione. Questo vantaggio favorisce Ada e impedisce una rivendicazione positiva di parità aggregata da questi casi; tutti perdono comunque. I joint/DC equivalenti bastano a respingere questo candidato.', '',
 '## Diagnostica','',
 '`Row` conserva 4096 colonne e valori; `Result` contiene tre righe e occupa 147512 byte (circa 144 KiB). Il [disassemblato](stage-disassembly.txt) del binario misurato mostra `memset` da 0x4000 e 0x8000 byte e `memcpy` da 0x24038 byte nei percorsi della fase. L’intero buffer è inizializzato/copiato anche quando serve un solo DOF. Le istruzioni SIMD sono presenti; i contratti ghost non vengono eseguiti nella release.', '',
 'Queste operazioni identificano un costo strutturale da rimuovere. Non è stata attribuita tramite profiling una percentuale esatta del tempo a ogni copia. Il prossimo intervento è usare workspace CSR preallocati dal chiamante, dimensionati al numero effettivo di DOF/nonzeri, scrivendo solo le porzioni attive senza ritornare il record completo per valore. I contratti su schema, ordine, colonne e conservazione delle componenti devono restare dimostrabili.', '',
 '## Contesto del passo completo C','',
 'È stata misurata anche una traiettoria di 2000 `mj_step` del solo C, su tre fixture. Gli stati finali della build nativa sono verificati contro la distribuzione ufficiale (2e-8 assoluta/relativa); setup e ripristino fuori dal timer. Questa è una misura di contesto su stati che evolvono, non un confronto aggregato Ada/C e non un rapporto di speedup della simulazione.','',
 '| Caso | Passo intero C µs |','|---|---:|'])
for row in movement[:3]:lines.append(f"| {row['name']} | {row['c_whole_step_us']:.3f} |")
lines.extend(['', 'La prova aggiuntiva si è interrotta su `dc_chain_8`: anche il riferimento ufficiale segnala QACC non finita/enorme al DOF 2, tempo 0.066 s. La traiettoria instabile è respinta; `dc_chain_32` e `dc_chain_64` non sono stati eseguiti per questa prova. Ciò non cambia le misure della fase su snapshot, ma non permette di dichiarare valido un benchmark del movimento completo multi-DOF. I tre risultati completati sono stati recuperati dagli output grezzi e verificati nuovamente.', '',
 '## Evidenze e decisione','',
 '- [Risultati della fase](stage-results.json), [originale grezzo](stage-results-raw.json), [contesto passo C](movement-reference.json).',
 '- `runs/` conserva XML, MJB, input Ada/C, output di ogni blocco e JSON per caso.',
 '- `sources/` conserva i sorgenti realmente misurati, incluso il driver originale. La sola correzione successiva nel driver corrente aggiunge SO3 site ai casi con preparazione favorevole ad Ada: è una correzione di metadati, senza cambiamenti a tempi, input o risultati.',
 '- `oracle.c` e `c-engine-compile-commands.json` conservano gli estratti privati usati e i comandi del riferimento nativo. Hash completi in `manifest.json`.',
 '- Le prove formali complete restano aperte (240 obblighi sulle cinque unità); l’assenza universale di errori runtime e Gold globale non sono ancora dimostrate.',
 '', '**Nessuna integrazione, commit o push eseguiti.** La condizione richiesta era superare C: questi risultati la respingono.'])
(destination/'README.md').write_text('\n'.join(lines)+'\n')
shutil.copyfile(Path(__file__).resolve(),destination/'finalize_evidence.py')
manifest={str(p.relative_to(destination)):digest(p) for p in destination.rglob('*') if p.is_file() and p.name!='manifest.json'}
(destination/'manifest.json').write_text(json.dumps({'files':manifest,'scope':'local candidate evidence only; unchanged main engine','decision':'not_integrated'},indent=2)+'\n')
print(json.dumps({'stage_cases':len(raw['results']),'all_slower':all(r['stage_slower_confirmed'] for r in raw['results']),'rechecked_frames':checks,
                  'c_whole_step_context_verified':3,'numerical_sources_fresh':True,'kernel_proof_sources_fresh':True,'archived_files':len(manifest),'integrated':False},indent=2))
