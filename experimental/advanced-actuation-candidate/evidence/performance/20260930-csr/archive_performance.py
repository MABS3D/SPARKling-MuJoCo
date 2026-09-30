from pathlib import Path
import hashlib,importlib.util,json,shutil
import mujoco,numpy as np
p=Path('/mnt/c/Users/Chello/Desktop/Sparkling Mujoco/experimental/advanced-actuation-candidate')
scratch=Path('/var/tmp/sparkling-actuators-csr-20260930');run=scratch/'comparison';dest=p/'evidence/performance/20260930-csr';dest.mkdir(parents=True,exist_ok=True)
r=json.loads((run/'results.json').read_text())
def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()
for name,value in r['candidate_sources'].items():
 assert digest(p/name)==value,name
 q=dest/'sources'/name;q.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(p/name,q)
for row in r['binaries'].values():assert digest(Path(row['path']))==row['sha256']
baseline=json.loads((p/'evidence/performance/20260930/stage-results-raw.json').read_text())
assert r['binaries']['baseline']['sha256']==baseline['binaries']['ada']['sha256']
assert r['native_library_sha256']==baseline['native_library_sha256']
shutil.copytree(run,dest/'runs',dirs_exist_ok=True)
shutil.copyfile(scratch/'stage-disassembly.txt',dest/'stage-disassembly.txt')
shutil.copyfile(p/'performance.gpr',dest/'sources/performance.gpr')
assert digest(p/'performance.gpr')==r['performance_project_sha256']
# Recheck the recorded outputs, including the baseline, against the C oracle.
spec=importlib.util.spec_from_file_location('bench',p/'tests/performance/compare.py');bench=importlib.util.module_from_spec(spec);spec.loader.exec_module(bench)
checked=0
for row in r['results']:
 f=run/row['name'];m=mujoco.MjModel.from_binary_path(str(f/'model.mjb'));data=np.fromstring((f/'c.input').read_text(),sep=' ');assert data[0]==8;offset=1;targets=[]
 for frame in range(8):
  d=mujoco.MjData(m)
  for field in ['qpos','qvel','ctrl','act']:
   a=getattr(d,field);a[:]=data[offset:offset+len(a)];offset+=len(a)
  mujoco.mj_forward(m,d);targets.append(bench.expected(m,d))
 assert offset==len(data)
 for block in range(9):
  pair={}
  for kind in ['baseline','ada','c']:
   frames,times,sink=bench.parse((f/f'block-{block}-{kind}.output').read_text());assert len(frames)==8 and len(times)==3
   for actual,expected in zip(frames,targets):np.testing.assert_allclose(actual,expected,atol=2e-11,rtol=2e-11);checked+=1
   pair[kind]=(times,sink)
  for kind in ['baseline','ada']:np.testing.assert_allclose(pair[kind][1],pair['c'][1],atol=2e-10,rtol=2e-10)
  np.testing.assert_allclose(np.median(pair['ada'][0])/np.median(pair['c'][0]),row['block_ratios'][block],atol=0,rtol=1e-14)
  np.testing.assert_allclose(np.median(pair['baseline'][0])/np.median(pair['ada'][0]),row['baseline_block_ratios'][block],atol=0,rtol=1e-14)
assert len(r['results'])==17 and all(x['stage_faster_confirmed'] for x in r['results'])
r.update(stage_gate_passed=True,all_stage_cases_faster_confirmed=True,archived_frame_checks=checked,
         integrated_in_engine=False,aggregate_movement_measured=False,integration_gate_passed=False,
         baseline_provenance='../20260930/stage-results-raw.json',
         decision='actuation-stage correction accepted; whole movement and full proofs pending')
(dest/'stage-results.json').write_text(json.dumps(r,indent=2)+'\n')
lines=['# Correzione CSR — confronto con C e versione precedente','',
 '**Esito della fase: 17/17 carichi più veloci di C nella sessione misurata.** Il candidato conserva i risultati numerici. La condizione per integrare nel motore resta aperta: questa prova misura la fase di attuazione su stati preparati, non l’intera simulazione. Le prove formali complete sono riportate separatamente nel resoconto corrente.','',
 '## Cambiamento','',
 '`Result` è ora un record limited con workspace CSR dimensionato dal chiamante. Le trasmissioni sono procedure che scrivono nel buffer esistente. Le righe condividono colonne e valori contigui, con conteggi e indirizzi. `Reset` modifica soltanto metadati e lunghezze; il payload non viene cancellato. Anche `Row` ha dimensione scelta dal chiamante e semantica limited, per impedire copie implicite. Le routine di velocità e proiezione lavorano su slice attive con offset arbitrario.', '',
 'Le formule muscolari, PID, DC, SO3 e geometriche sono rimaste invariate. La compressione seleziona i nonzeri prima dello scaling, mantiene l’ordine delle colonne e conserva la coda non scritta. Le colonne nulle strutturali dei tendini sono conservate. Nel benchmark il workspace è allocato una sola volta fuori dal ciclo, con capacità massima di 3×NV; ogni attuatore scrive solo il proprio prefisso attivo.', '',
 '## Risultati in microsecondi per batch','',
 '| Caso | Precedente | Corretta | C | Corretta/C | IC95 del rapporto | Accelerazione sulla precedente |', '|---|---:|---:|---:|---:|---|---:|']
for x in r['results']:
 lo,hi=x['ratio_ci95'];lines.append(f"| {x['name']} | {x['baseline_us']:.3f} | {x['ada_us']:.3f} | {x['c_us']:.3f} | {x['ada_over_c']:.3f} | {lo:.3f}–{hi:.3f} | {x['baseline_over_current']:.1f}× |")
lines += ['', 'Rapporti e accelerazioni sono mediane di rapporti appaiati tra blocchi; possono differire dai quozienti delle mediane marginali. IC95 ottenuti tramite 10000 ricampionamenti bootstrap dei nove blocchi. Per esempio, il DC a 64 attuatori ha rapporto mediano 0.766 e IC95 0.554–0.973: il vantaggio centrale è circa 23%, con incertezza ampia. La misura non garantisce lo stesso margine su ogni dispositivo.', '',
 '## Metodo e limiti','',
 'Riferimento MuJoCo 3.14.0, commit 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd. GCC/GNAT 16.1.0, ottimizzazione -O3, ISA nativa, LTO, contrazione FP disabilitata. C usa la build nativa con SIMD/AVX normali. AMD Ryzen 7 9800X3D, WSL, CPU 15. Nove blocchi, tre campioni per eseguibile e blocco, otto snapshot per modello. L’ordine Ada/C viene alternato, la baseline occupa ciclicamente tutte e tre le posizioni. La baseline è esattamente il binario del confronto iniziale: hash verificato.', '',
 'Il tempo comprende trasmissione, velocità, legge di forza/dinamica, avanzamento dell’attivazione e proiezione sparsa. Preparazione e I/O sono esclusi per tutti; barriera di memoria e checksum impediscono l’eliminazione del lavoro. Lunghezze, velocità, forze, act_dot, attivazioni successive, forze generalizzate e schema CSR sono confrontati con il C ufficiale (2e-11 assoluta/relativa; checksum 2e-10). Tutti i 3672 frame archiviati delle tre versioni sono stati verificati nuovamente.', '',
 'Site/refsite, SO3-site, slider-crank e adesione ricevono Jacobiani/preparazione già disponibili in Ada, mentre C li calcola nella fase. Il confronto in questi casi favorisce Ada: non costituisce prova di parità della preparazione completa o del movimento. I benchmark non coprono tendini con wrapping, callbacks/plugin, integrazione Model/Data/MJCF o tutte le funzioni globali del simulatore.', '',
 'La prova aggiuntiva del passo completo C del confronto iniziale resta soltanto contesto storico. La catena DC iniziale era instabile nella traiettoria; non è stata riutilizzata come prova aggregata Ada/C e non è stata dichiarata risolta da questa correzione.', '',
 '## Evidenze','',
 '- [Risultati e provenienza](stage-results.json); output originali, input e modelli in `runs/`.',
 '- Sorgenti misurati in `sources/`; i sorgenti della baseline sono nell’archivio [precedente](../20260930/README.md).',
 '- [Assembly della fase](stage-disassembly.txt): zero chiamate a memcpy e nessuna copia da 147512 byte. Restano azzeramenti limitati ai dati effettivamente necessari, come le forze generalizzate.',
 '- [Prove SPARK correnti](../../proofs.md) e test numerici sono distinti dalla misura prestazionale.', '',
 'Correzione applicata al candidato isolato; nessun commit, push o integrazione nel motore principale.']
(dest/'README.md').write_text('\n'.join(lines)+'\n')
shutil.copyfile(Path(__file__).resolve(),dest/'archive_performance.py')
manifest={str(f.relative_to(dest)):digest(f) for f in dest.rglob('*') if f.is_file() and f.name!='manifest.json'}
(dest/'manifest.json').write_text(json.dumps({'files':manifest,'stage_passed':True,'integrated_in_engine':False},indent=2)+'\n')
print(json.dumps({'cases':17,'all_stage_faster':True,'rechecked_frames':checked,'archive_files':len(manifest)},indent=2))
