# Ripresa dynamics — 2 ottobre 2026

## Checkpoint 0: ricostruzione avviata

- Proprietà e baseline iniziale lette dal piano comune; preservate tutte le modifiche anteriori al crash.
- Primo obiettivo in esecuzione: nuova chiusura congelata e build dello step vincolato; confronto numerico con MuJoCo C 3.14.0.
- Corretto `experimental/constrained-step/tests/build.py`: un solo job (`-j1`) e limiti watchdog espliciti.
- Le integrazioni dei diversi lavori sono già salvate, ma README e ricevute storiche non dimostrano la composizione attuale. Non sono ancora attribuite prove né risultati numerici alla sorgente corrente.
- Benchmark conclusivi sospesi finché gli altri agenti compilano/provano.

## Coda (12 lavori distinti)

| ID | Lavoro | Stato corrente |
| --- | --- | --- |
| R01 | Prestazioni step vincolato | Misure isolate root: Newton r7 6,00x più lento del controllo a96DOF; nuovo percorso sparse C in verifica, parità non raggiunta |
| R03 | Relazione funzionale globale Cholesky | Denso C348 nella revisione locale +385 differenziali; modello finale/rango e congruenza minimi avviati, composizione globale aperta |
| R04/R05 | Unificazione forze e vincoli | Ripreso: nuova build integrata; forze 452/452 su 30 passi |
| R06 | Uguaglianze connect/weld | Root: runtime integrato, denseNewton senza residui nel corpus ampliato; stress CG/sparse e prove complete aperti; joint/tendon in sviluppo |
| R07 | Vincoli dei tendini | Ripreso: differenziale 76/76; prove locali successive |
| R08 | Coni ellittici | Ripreso: simple-DOF manifold corretti; 254/254 originali passati |
| R09 | NoSlip | Ripreso: 628 confronti passati, 4 errori riferimento; variante densa 12/12 |
| R10 | Potenze solimp | 3874 casi C finiti esatti, 197 C nonfinite rifiutati; sette minime + unità finale 78 check chiusi; prestazioni integrate pendenti |
| R16 | Surface velocity | Kernel finale171 check chiusi; ultima validation92/92, nuova composizione in regressione |
| R30 | Prove di composizione | Pubblicazione12 e setter endpoint11 chiusi nelle rispettive closure; composizione totale aperta |
| R31 | Invarianti inizializzazione | Sette helper sul vecchio snapshot; contratti mocap aggiornati, Create e setter globale aperti |
| R32 | Prove PGS/CG/Newton | Sparse_Kernels 72, Scalar 54; riduzioni minime/intera verificate, integrazione solver aperta |

Prossimo checkpoint: esito reale della build e confronto di una fixture minima, con manifest e log esterni in `/var/tmp`.

## Checkpoint 1: composizione eseguibile e primo differenziale

- Build validation completata (92,3 s, RSS di gruppo 452 MB), senza errori di compilazione; controlli runtime attivi.
- 8/8 casi su 30 passi con Newton, slide, filterexact/actearly, fluidi box/ellissoidali, tendini e contatti/limiti: nessun fallimento rispetto a C.
- Riferimento riconfermato mediante API ufficiale release: MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
- Chiusura congelata, manifest, log e ricezione release: `/var/tmp/sparkling-recovery-dynamics-20261002-01`; confronto: `checkpoint-forces/results.json`.
- Nessuna conclusione di parità prestazionale né prova universale dedotta dal differenziale.
- Prossimi passi: corpus più ampio di forze/vincoli, poi prove minime sulla pubblicazione e sui kernel; avvio degli adapter NoSlip e diagnosi dell'inizializzazione.

## Checkpoint 2: corpus integrato e regressione isolata

Sulla stessa build congelata validation, con carichi esterni e 30 passi:

- Corpo rigido, limiti e solimp: 106/106 casi.
- Forze/attivazioni/tendini passivi: 452/452 casi.
- Vincoli tendinei: 76/76 casi.
- Surface velocity: 92/92 casi.
- Atomicità attivazione/capacità: 3/3 casi.
- Coni ellittici alla tolleranza solver originale `1e-12`: 251/254. Tre casi CG, condim 6, impratio 100 superano la tolleranza differenziale; massimo errore accelerazione circa 6,33e-5. Corpus e input preservati, nessuna tolleranza di confronto allargata.
- Diagnosi distinta dello stesso corpus ellittico con tolleranza solver `0` in entrambi i motori: 254/254. Indica sensibilità all'arresto iterativo, non chiude i tre fallimenti della configurazione originale.

R07, R08, R10 e R16 sono ora effettivamente ripresi con questi differenziali; R08 mantiene aperta la diagnosi CG. R30 avviato sui due sottoprogrammi minimi e sull'istanza completa della pubblicazione dello stato. Nessun benchmark prestazionale conclusivo eseguito.

## Checkpoint 3: prove di pubblicazione e inizializzazione

- R30: istanza produttiva `MJ.Owned_Step_Publication`, prima `Has_Iterate` (3 check) e `Publish` (9 check), poi intera unità (12 check): nessun obbligo aperto né warning. È la frontiera locale di pubblicazione, non una prova di tutto Step.
- R31: `Zero_Array`, `Set_Dimensions`, `Allocate_State`, `Allocate_Kinematic`, `Allocate_Dynamics`, `Allocate_Actuators` completati senza obblighi aperti; `Set_Options` supera il limite watchdog di 35 secondi e resta da riprendere. Snapshot del runner originariamente in `/tmp` conservato anche in `proof-initialization/source` sotto `/var/tmp` con manifest degli hash.
- R03: aggiunto il lemma ghost `Preserve_Factor_Sum` per la conservazione di prefissi invariati; prova minima in esecuzione. Non cambia le operazioni runtime né dichiara già ottenuta la relazione globale.
- Runner NoSlip/solver portati a `-j1` e limiti espliciti. Verificatore NoSlip ora rifiuta output con numero campioni errato e controlla la baseline 3.14.0.
- R06: il recupero non ha trovato un produttore connect/weld; `Create` rifiuta ancora uguaglianze. Richiede nuova implementazione e rimane in coda effettiva.

R06 è ora preso dal root, che prepara `experimental/equality-constraints`; l’integrazione centrale sarà coordinata tramite API/patch. R11: aggiunti alla coda locale i corpus `compare_assets.py`/`prove_assets.py` per la parte già presente nello step.

Diagnosi R03: i primi tentativi del lemma conservazione prefissi hanno 1 postcondizione aperta per timeout, senza errori runtime; risultato non dichiarato provato. Aggiunti contratti esatti del valore 0 dei rifiuti Start/Subtract e asserzioni intermedie per localizzare l’obbligo.

## Checkpoint 4: lemma Cholesky e isolamento CG

- `Equal_Extensions`: prova minima 2 check, nessun aperto.
- `Preserve_Factor_Sum`: prova minima 49 check, nessun aperto; i tentativi precedenti e i timeout sono conservati. La divisione del lemma evita di trascinare i quantificatori delle matrici nel problema di congruenza delle operazioni floating point.
- Contratti `Start`/`Subtract` ora specificano anche il valore 0 del risultato rifiutato; implementazione runtime invariata. Richiedono riprova delle rispettive routine e dell’intera unità finale.
- Replay dei tre scostamenti CG su solver standalone riproduce gli stessi errori: origine isolata dal passo integrato. C/Ada terminano in 35/34, 48/50, 61/62 iterazioni. Tutti gli iterati sono numericamente dualmente ammissibili e i gap spiegano la diversa accelerazione; non è una prova formale né un superamento del test originale.
- Esperimento separato in `dot-variant` per l’accumulazione a quattro lane di `mju_dot`, conservando la baseline sequenziale. Nessuna modifica runtime del solver è ancora incorporata per questo esperimento.

## Checkpoint 5: estensione asset e ipotesi CG

- R11 richiesto da collision: differenziale asset sulla prima chiusura 109/126 su 30 passi, 17 fallimenti soprattutto mesh/cylinder e heightfield/cylinder/mesh. Inviati input, modelli e risultati all’agente collision per la diagnosi narrowphase. Non dichiarato completato il collegamento.
- Esperimento `dot-variant`: quattro lane da sole non eliminano gli scostamenti CG; nessuna variazione runtime accettata sulla sola base di questa prova.
- Preparata seconda ipotesi isolata: massa diagonale applicata mediante inversa diagonale come `mj_solveLD`, evitando il doppio arrotondamento della radice Cholesky. Verifica in coda dopo la riprova Cholesky corrente.
- Cholesky: riprova minima dei contratti rafforzati di Start/Subtract e intera unità con i due lemmi nuovi in corso.

## Checkpoint 6: causa CG riprodotta e correzione candidata

- La variante separata a quattro lane più applicazione diretta dell’inversa per massa diagonale porta i quattro replay alle stesse iterazioni C (35,45,48,61).
- Gli errori massimi di accelerazione scendono a 1,91e-6, 2,12e-8, 3,08e-7, 3,63e-7: tutti sotto la soglia originale 3e-6.
- Questo checkpoint riguarda i problemi assemblati riprodotti; serve ora integrare la correzione nella sorgente corrente e ripetere i corpus completi, senza allargare le soglie.
- L’intera prova Cholesky ha raggiunto il watchdog 180 s senza un report finale; i lemmi minimi risultano provati, la nuova prova di unità rimane aperta e sarà rilanciata con lo stesso profilo per_path della ricevuta precedente e limite maggiore.
- R09: build completa NoSlip da nuova chiusura congelata avviata in `/var/tmp/sparkling-recovery-dynamics-20261002-noslip-01`.

## Checkpoint 7: NoSlip e kernel del percorso diagonale

- R09: build validation NoSlip completata; 628/628 confronti eseguibili su 30 passi passati. Quattro configurazioni coupled_limits_friction con NoSlip1/12 non vengono compilate dal riferimento C 3.14.0 (`pre and post-count of Y_rownnz ... row 1`); il test le registra come errori del riferimento e mantiene l’esito complessivo non accettato. XML conservati; nessun caso è contato come passato senza confronto.
- R08/R01/R32: correzione candidata CG inserita nel solver corrente, insieme a due kernel scalari per inversa diagonale e scala. Prove minime: 7 e 5 check, tutti passati.
- La prima prova intera Sparse_Kernels passa 72 obblighi ma segnala 11 warning di riassociazione su espressioni già esistenti. Aggiunte parentesi esplicite coerenti con l’ordine sinistro originale; prove minime e intera unità finale in corso.
- Cholesky globale e prova completa rimangono aperti; nessuna eccezione Silver o assunzione introdotta.

## Checkpoint 8: correzioni condivise coordinate

- R11: collision ha isolato le discrepanze di contatti nell’ordine floating point di `Rotation`. Applicate diagonali `((WW+XX)-YY)-ZZ`, `((WW-XX)+YY)-ZZ`, `((WW-XX)-YY)+ZZ` di `mju_quat2Mat`, aggiornati contratti e asserzioni. Prova minima Rotation completata senza obblighi aperti (63,7 s); la prova intera e i corpus sulla nuova build seguono.
- R23: applicata richiesta services nel validatore comune: rangefinder tipo7 accetta la dimensione compilata >=1 anziché imporre dim1. Il minimo C di indirizzamento resta conservato; l’adapter sensori verifica dataspec/dimensione esatta. Services ricongela e verifica i propri casi.
- Root ha preso la finestra di edit dei file constrained principali per gli hook Equalities. La build integrata successiva aspetta il suo checkpoint coerente.

## Checkpoint 9: ricevute locali chiuse e coordinamento

- `MJ.Constraint_Solvers.Sparse_Kernels`: unità finale 72 check, complete coverage, zero aperti e zero warning. Minime interessate eseguite prima: Inverse_Diagonal7, Diagonal_Scale5, Outer_Update11, Zero_Contribution3, Copy_Block45.
- `Rotation`: 155 proof check + 2 flow passati, nessun aperto; è ancora necessaria la prova del resto dell’unità sulla revisione finale.
- NoSlip, controparte dense del solo modello coupled_limits_friction: 12/12 su 30 passi. L’oracle comune ora distingue denso/CSR mediante `mj_isSparse`; il primo tentativo dense che decodificava erroneamente CSR rimane conservato come test non valido, non risultato del motore.
- Services conferma 208/208 traiettorie sensori con la nuova validità rangefinder e 73/73 prove kernel sensori. L’interfaccia tendini viene riusata per estendere i suoi test, senza nuovi edit centrali.
- Build standalone solver corrente in corso; saranno ripetuti differenziale, robustezza e sistemi separati/permutati. Nessuna misura di prestazioni conclusiva mentre i processi degli altri gruppi sono attivi.

## Checkpoint 10: regressione integrata dopo le correzioni

- Set_Options: 16 proof check, zero aperti (49,6 s); tutti sette helper iniziali R31 ora verificati nelle rispettive prove minime. Non equivale alla prova globale di Create.
- Solver corrente standalone: 409/409 differenziali, 240 stress + 240 replay + 5 capacità senza fallimenti, 45/45 sistemi separati/permutati. Ricevute in `/var/tmp/sparkling-recovery-dynamics-20261002-solvers-01`.
- Riutilizzata chiusura immutabile del root `sparkling-equality-integrated-build-20261002-r1` per modelli Neq=0: forze452/452, tendini76/76, surface92/92, rigido106/106. Risultati in `/var/tmp/sparkling-recovery-dynamics-20261002-02`.
- Ellittico alla soglia originale:253/254, residuo CG condim6 impratio100 sample1 (errore accelerazione5,855e-6). La variante isolata su dati C non basta a chiudere la composizione; diagnosi prosegue su metrica/Jacobiano realmente assemblati.
- Asset118/126 (prima109/126). Collision conferma che sugli stessi90stati C non rimangono errori locali significativi (accelerazione <1e-13), mentre traiettorie accoppiate hanno ancora8fallimenti. Non chiuso R11.
- Composizione locale dei geom aggiornata come mj_local2Global: quaternion + conversione C, frame BODY/INERTIA e rispettive varianti rotazionali. Nuovo parametro del corpus locale consente ruotare geom mantenendo la stessa inerzia compilata. Build/verifica di queste ultime modifiche segue.
- Root ha trovato uguaglianze con righe J=0 e R=mjMINVAL: ammissione solver e curvatura kernel estese a1e-15/1e15; Evaluate scalare già ammetteva il dominio e passa di nuovo34check. Minime dei kernel, unità e regressioni con slide-connect/slide-weld in corso.

## Checkpoint 11: domini C, frame locali e isolamento della massa

- R/D=1e-15/1e15: prove minime Evaluate34, Outer_Update11, Zero_Contribution3 e unità finali Scalar54/Sparse_Kernels72 tutte passate. Nuovo solver validation422/422, inclusi slide-connect/weld e rifiuto atomico sotto mjMINVAL.
- Build integrata r3 completata97,8s: snapshot `/var/tmp/sparkling-recovery-dynamics-20261002-03`. Conferma forze452/452, tendini76/76, surface92/92, rigido106/106; CG253/254 e asset118/126 restano aperti. Corpus aggiunto geomlocali ruotati117/126; inputsalvati, nessuna soglia cambiata.
- Pose geom centralizzate in Generate_Geom_Poses per ordinary e SDF; collision aggiorna il child.
- Root conferma due-active-equalities ora passa2/2 con minval. Dei suoi15replay stress, PGS-shared rifiutava aref2,31e10; esteso solo questo ingresso a±1e30 già coperto dal kernel scalare, con nuovo fixture C. Build/verifica successiva.
- Build r4 aggiunge esportatore diagnostico test-only del problema Ada realmente assemblato (stdout invariato, protocollo solver su stderr con terzo argomento problem). Nel residuo CG, M differisce8,67e-19 e free7,11e-15; sostituendo entrambi conC cambia62→61iterazioni e errore5,855e-6→3,63e-7.
- C usa dof_simplenum[6..1] e dof_M0, mentre Build_Manifold_Topology ignorava le diagonali semplici. Correzione implementata con metadata compilati e pattern parentale coerente; prima prova ha esposto vincoli SPARK sui bounds dipendenti da parametro inout, corretti con costanti Nb/Nv. Prova minima successiva in corso, nessuna nuova prova dichiarata ancora.
- Applicata patchmocap finale services dopo loro buildvalidation e272/272 traiettorie (100passi): setter, resetquaternionraw e kernel. Le vecchie ricevute dei sette helper di inizializzazione restano riferite alla loro chiusura precedente; services riprova gli helper modificati.

## Checkpoint 12: CG integrato chiuso sul corpus originale

- Buildvalidation r5 (`/var/tmp/sparkling-recovery-dynamics-20261002-05`) completata93,7s con mocap, metadati simple manifold, ammissione aref estesa e test lifecycle uguaglianze.
- Ellittico254/254 alle soglie originali: il residuo CG è chiuso sul corpus, senza modificare tolleranze solver o confronto. Forze452/452, tendini76/76, surface92/92, rigido106/106 rimangono passati.
- Uguaglianze503/514 confrontabili,12failurecomplessivi (11discrepanze numeriche +1runtimePGS); C segnala instabilità QACC al tempo0,010. Il recupero automatico C (warning/reset) è comportamento da portare, distinto dal rifiuto atomico Ada; il caso resta nel corpus.
- Asset116/126 e asset con geomlocali ruotati118/126: fallimenti di traiettoria restano aperti; collision ha già verificato esattezza locale su90statiC. Non è accettata equivalenza del percorso asset finale.
- Build_Manifold_Topology: corretto errore SPARK di bounds su parametro inout mediante costanti; prova successiva timeout180s senza report finale, quindi aperta.
- Varianti isolate C-Cholesky in `r4/cholesky-experiments`: denseNewton stress accel3,7348e-5→0 e forza1,45e-12. Hessiana modificata da sola non basta. C usa due algoritmi distinti (denso LL' a colonne, sparse L'L inverso); prima dell'integrazione occorrono contratti/prove e selezione coerente. Varianti costo/gradiente preservate per diagnosi, non applicate al solver produttivo.
- Preparati kernel di riduzione a quattro lane con dominio esteso per i fattori Hessiani e modello floating point esatto, adattati ai limiti del solver. Nuove prove minime in corso; primo tentativo non aveva i sorgenti nuovi in Source_Files ed è conservato come errore di runner, non prova.

## Checkpoint 13: riduzioni ordinate e fattorizzazione C

- Il modello di riduzione largo chiude 123 check di unità; nove helper runtime chiudono 165 check minimi e l’intera Reductions chiude gli stessi 165 con complete coverage. Due warning ricorsivi del modello rimangono esplicitamente recensiti nelle ricevute: nessuna assunzione o soppressione introdotta.
- Il report intero Reductions è valido per i suoi sorgenti congelati; il runner finale è uscito non accettato perché ho aggiunto la nuova unità Dense_Cholesky durante la prova, cambiando l’elenco globale degli hash senza modificare le riduzioni. Ricevuta finale da rinnovare sulla nuova closure, risultato non riscritto.
- Nuova build validation standalone in `/var/tmp/sparkling-recovery-dynamics-20261003-06/solvers-build`; riduzioni larghe 336/336 confronti esatti binary64 con il normale mju_dot C, lunghezze0..256 e scale1e-120..1e120.
- Nuovo Dense_Cholesky separato implementa ordine C a colonne, clamp dei pivot insufficienti e rango restituito; non ancora collegato al solver. Contratto funzionale per colonna, frame e atomicità locale; proprietà globale del fattore ancora da sviluppare/provare. Corpus e diagnosi minima in corso.

## Checkpoint 14: potenze solimp e prime frontiere del fattore

- Solimp, nuova closure `/var/tmp/sparkling-recovery-dynamics-20261003-solimp-02`: build validation passa; 3874/3874 risultati C finiti esatti, altri197 ingressi producono nonfinite nel C e sono esplicitamente rifiutati da Ada. Audit separato delle197risposte C conservato, non contato come equivalenza di risultato.
- Le sette prove minime di MJ.Solimp_Curve chiudono78check senza warning/aperti. Report dell’unità contiene59proof+19flow chiusi ma il runner rifiutava erroneamente la frontiera importata Runtime_Pow (copertura spec senza corpo Ada). Aggiornata la ricevuta per riportare espressamente libm esterno senza attribuirgli una prova del corpo; fresca closure solimp03 pronta per il rinnovo.
- Dense_Cholesky:285/285 fattori e ranghi esatti contro C nella prima versione. Prime prove minime hanno isolato i bounds di un prefisso vuoto e la sua inizializzazione; contratto Last=Count e invariante Initialized aggiunti, Prefix ora25check passati. La prima prova monolitica Factor_Column ha raggiunto watchdog180s; calcolo e pubblicazione della colonna sono ora due sottoprogrammi con contratti separati. Aggiunta sostituzione densa C in verifica, ancora esclusa dal solver produttivo.

- Chiusura R10 locale: nuova ricevuta `solimp-03/proof-whole` passa78check, zeroaperti/warning, copertura di tutti i corpi applicativi; libm Runtime_Pow è registrato separatamente come interfaccia esterna senza prova del corpo. README corretto anche sul collegamento già presente nello step vincolato. Prestazioni aggregate e dominio completo upstream rimangono attività separate.

- R31/mocap: applicate le due patch scoped di services dopo controllo: parentesi nell’indicizzazione dei contratti, invarianti Nmocap/Mocap_Id, post di Free_State e due allocazioni mancanti in Create_Dynamics. Il secondo costruttore ometteva i buffer anche nel caso Nmocap=0 e invalidava gli adapter avanzati. Services rinnova corpus e prove; il post aggregato Set_Mocap rimane aperto.
- Dense solve: Forward_Row29 e Backward_Row45 check passati; modello ricorsivo Backward_Sum20, lemma Unfold16, Subtract_Term12 e Scaled_Residual7 passati. Il precedente tentativo backward lasciava aperta la relazione funzionale finale: risolta con snapshot ghost e asserzione esplicita dell’accumulo, senza variazioni runtime.

## Checkpoint 15: componenti dense e hook endpoint flex

- Dense_Cholesky: Prefix25, Scaled_Residual7, Off_Diagonal12, Inverse_Pivot7, Prepare_Column55, Store_Column24, Factor_Column27, Factor34 chiusi nelle minime, oltre alle righe forward/backward già registrate. L’ultimo residuo Prepare_Column si chiude con il contratto dell’inversa scalare e controllo dell’espansione del modello Dot già provato: nessun assioma aggiunto. Il post globale del fattore per ora dichiara bounds, diagonale e frame superiore; relazione funzionale globale/rango ancora da rafforzare, distinta dai contratti esatti per colonna.
- Applicata patch endpoint di collision: array metadata Body0/Body1 e Geom opzionali (-1); assemblaggio, risposta e surface leggono i metadata. Aggiunto contratto setter con frame e rifiuto atomico, limiti fisici espliciti. Collision prepara solo primo percorso plane/vertex con body reale unico per lato; endpoint interpolati restano futuri. Nuova build/regressione rigido/surface e prova setter in coda; SDF sarà adeguato da collision.
- Mocap: il validatore Seen è ora condiviso tra Initialize e Create_Dynamics; services rinnova runtime e sviluppa la proprietà funzionale iff per unicità/copertura. I loro808casi advanced passano dopo l’allocazione corretta; prova totale Create rimane aperta.

## Checkpoint 16: Cholesky denso con ordine C verificato localmente

- Dense_Cholesky: tutte le minime e intera unità finale chiudono 348 check con copertura completa e zero obblighi aperti. Ricevuta `sparkling-recovery-dynamics-20261003-06/proof-dense-whole-07`: snapshot immutato e checkout_matches_snapshot=true. Le frontiere sqrt runtime e ricorsione ghost rimangono recensite, nessuna assunzione aggiunta.
- Corpus ampliato 385/385: fattori, rango e sostituzioni coincidono esattamente binary64 con C, inclusi deficit misti e valori adiacenti alla soglia pivot. I contratti esatti per colonna/riga sono provati; la composizione funzionale globale del fattore/rango/soluzione resta aperta e il kernel non è ancora sul Newton produttivo.
- R16: gli helper minimi surface erano chiusi ma Geometry conservava una postcondizione aperta; introdotta Geometry_Value con relazioni per componente, in diagnosi minima prima della composizione. Non dichiarata ancora chiusa l’unità.
- Runner solver aggiornato per verificare l’immutabilità effettiva dello snapshot e registrare separatamente checkout_matches_snapshot; un successivo cambiamento del checkout non può essere confuso con una prova delle sorgenti correnti. Ricevute storiche con guardia fallita conservate senza riscrittura.

## Checkpoint 17: surface Gold locale e Newton denso collegato

- Surface Geometry_Value11 e Geometry15 ora chiusi; intera MJ.Surface_Velocity171 check, zero aperti/warning, copertura completa. Fonte: `sparkling-recovery-dynamics-20261003-surface-03-whole`. Formula e ordine floating point conservati.
- Newton usa Dense_Cholesky per Hessiana e sostituzioni, mantenendo la dimensione intera che determina il raggruppamento delle quattro lane. Replay stress weld denso: accelerazione esatta C e forza1,45e-12; sparse mantiene discrepanze poiché richiede il proprio algoritmo inverso L'L.
- Corpus solver ampliato428/428;240stress+240replay+5capacità passati. La prima esecuzione425/428 aveva tre warm-start rifiutati anche dal binario precedente: ammissione A/Force ora allineata al dominio Work delle soluzioni pubblicate. Fallimenti originali conservati.
- Collision ha isolato una regressione release delle pose: l’assegnazione array-valued case expression produceva una posizione diversa; case statement con stesse formule porta il suo replay flex da4/54 a54/54. Patch centrale applicata; causa compiler/lifetime non dimostrata. Nuova closure centrale validation/release in preparazione, nessuna vecchia ricevuta release ereditata.

## Checkpoint 18: stessa closure validation/release

- Build centrale r7 validation99,4s e release145,2s dalla stessa closure congelata (manifest bfc6169c24abda3a70aed288887e869c86ec2a02f62dc318aba08135a5e9d4c8). Entrambi i profili mantengono tutti i controlli runtime richiesti; nessun benchmark conclusivo.
- Record numerici identici tra profili: rigido106/106, ellittico254/254, surface92/92, forze452/452, tendini76/76. Asset117/126 e geomlocali117/126 in entrambi, stessi9 residui di stato a30step. Fonte `sparkling-recovery-dynamics-20261003-07/profile-comparison.json`.
- Il checkout differisce dalla closure release soltanto nei due equality_geometry del root, modificati durante le sue prove; elenco registrato. Le ricevute non vengono attribuite a quei nuovi sorgenti. Collision ricompila flex con258 hash comuni identici per chiudere anche il child sulla stessa base.
- R30: prova minima Set_Contact_Endpoints avviata sulla closure reale; nessuna prova globale di Engine dichiarata. R03: avviato il modello della relazione fra fattore finale e matrice originale, con conteggio esplicito dei pivot deficitari; nuovi obblighi ancora da eseguire.

- R30 endpoint singolo: prova minima Set_Contact_Endpoints chiude11check senza warning/aperti, incluso frame e rifiuto atomico. Collision conferma flex4 54/54 a100step in validation e release, sui258 hash comuni identici a r7.
- Coordinamento servizi: applicata adesione nei4comuni e4nuoveunità produttive (copia unica, ownership servizi). La loro closure validation passa440/440 a100step e12minime; prova intera in corso al momento dell’applicazione. I4hash nuovi coincidono esattamente con la ricevuta. Nuova composizione centrale ancora da verificare; r7 resta precedente a questo ampliamento.

## Checkpoint 19: congruenza delle riduzioni e finestra prestazionale

- R03: Final_Residual11, Final_Off_Diagonal12, Completed_Column18 e Deficiency_Count11 chiusi nelle minime. Equal_Prefixes15 chiuso; i primi tentativi di uguaglianza dei residui hanno evidenziato timeout di composizione, conservati.
- Modelli riduzioni: introdotta congruenza dimostrata per induzione sulle quattro lane. Zero_Lane3, Equal_Lanes21, Combine_Lanes12 e Dot_Value37 (contratti esatti rafforzati), Equal_Combinations2, Equal_Dots60 passati. Nessuna assunzione; il null body del lemma scalare deve ancora soddisfare la propria postcondizione ed è stato provato. Prime prove fallite e un errore di identificatore riservato conservati.
- La precedente ricevuta intera Dense348 resta valida per la revisione locale pre-modelli globali; nuovi lemmi di conservazione/composizione e post finale fattore/rango ancora aperti, e nuova intera unità da rinnovare. Le operazioni runtime del kernel non sono cambiate in questo checkpoint.
- Root rilegge uguaglianze r7 con3campioni:751/768 confrontabili,17 scarti torquescale10000 (Newton solo sparse) e2configurazioni PGS con Numeric_Limit rispetto ad autoreset C. Corpus a3campioni distinto dalle vecchie ricevute a2.
- Adesione servizi ora440/440 sia validation sia release sulla stessa closure, atomicità/ripresa passate; intera unità kernel303proof+43flow chiusi, flow adapter10chiusi/11warning espliciti.
- Su richiesta root, concluso l’ultimo job pesante e riservata finestra senza build/prover per benchmark integrato r7. Nessuna conclusione prestazionale locale anticipata. Baseline pre-crash esistente individuata; patch di controllo r7 che sostituisce solo il Newton denso preparata come artefatto di analisi in `sparkling-recovery-dynamics-20261003-07/baseline-newton-control`, non compilata.

Prossimi passi R03 dopo la finestra benchmark: usare Equal_Dots provato per chiudere Equal_Final_Residual/Off_Diagonal; poi Preserve/Establish_Completed_Column e Unfold/Equal_Deficiency_Count. Solo dopo aggiungere a Factor gli invarianti delle colonne già completate, delle colonne future ancora uguali a M e del rango N−Deficiency_Count. Il post globale non è ancora collegato e non è dichiarato provato. R07/NoSlip/asset minimi e intere unità restano nella coda reale, non considerati chiusi dai soli differenziali.

## Checkpoint 20: regressione Newton misurata e algoritmo sparse C

- Root ha misurato in due finestre senza processi pesanti concorrenti: r5→r7 peggiora sui corpi indipendenti; ablation con solo Newton precedente conserva tutti7stati e isola96DOF66,56→399,63µs, rapporto6,00x (CI95%5,92–6,08), C16,51µs. Ricevute `sparkling-equality-window-benchmark-20261003` e `sparkling-newton-ablation-benchmark-20261003`. Tutti i workload richiedono Jacobian sparse; il nuovo dense universale ignorava questa scelta. Il controllo storico non è integrato come correzione numerica.
- Implementata MJ.Constraint_Solvers.Sparse_Cholesky separata, con due passaggi simbolici e fattorizzazione numerica inversa L'L nell'ordine C3.14.0, incluso l'ordine CSC non necessariamente ordinato. Primo corpus380/380: strutture simboliche, fattori, rango e soluzioni coincidono esattamente binary64. Dimensioni1..128, cinque strutture, zeri strutturali, scale e pivot deficitari. Ricevuta `sparkling-recovery-dynamics-20261003-09/sparse-cases-02`.
- Il primo runner C aveva una macro SIMD errata e non caricava la libreria helper; fallimento conservato, nessuna modifica di tolleranze. Nuovo helper usa il corpo C ufficiale di cholSolveSparse e i suoi header AVX; factor symbolic/numeric chiamano direttamente la libreria ufficiale.
- Minime scalar Update7 e Scale5 chiuse; Symbolic ha esposto E0007 sul bound dipendente da parametro out, corretto con costante locale. Prove della struttura, fattore/solve e intera unità ancora aperte; nessuna Gold globale dichiarata per il nuovo percorso.
- Collegato dispatch opt.jacobian con soglia Auto nv>=60 e pattern strutturale Hessiano tratto da massa ancestor e righe CSR, conservando zeri. Dense esplicito mantiene il proprio algoritmo verificato. La build standalone passa; nuova composizione centrale r62 del root e corpus integrati sono in corso.
- Collision consegna weighted endpoint138/138 a100step sia validation sia release, con identici309hash e casi misti/common ancestor/corpi ripetuti. Patch non ancora applicata live: priorità attuale solver sparse; contratti setter e nuova composizione restano da eseguire.

- Symbolic ora91check chiusi e zero warning/aperti. Il post formalizza struttura valida; l'ordine algoritmico esatto è ancora confrontato dal corpus, non provato globalmente. Factor minimo in corso; prove globali Dense precedenti ancora pendenti.
- Standalone428/428 contro dense e428/428 contro sparse, senza allargare soglie. R62 centrale passa rigido106/106, ellittico254/254 e forze452/452 a30step; root passa468/468 nuovi joint/tendon equality a100step. Sono ricevute della closure r62, precedente agli ultimi guard/invarianti locali del kernel. Il clock civile è saltato durante il runner ellittico: durata negativa registrata e non utilizzabile; prossimo runner passa a monotonic. Nessun tempo di questi confronti viene usato per la prestazione.

- Factor sparse minimo ha raggiunto watchdog240s senza report finale; rimane aperto. Non è una limitazione matematica né un'eccezione Gold. Terminato il job, nuova finestra senza processi pesanti locali per misura r7/r62/C del root.
- Integrata patch weighted endpoint dopo ricevute collision138/138 in entrambi i profili; backup `09/weighted-before`. Contratti Static dei due setter estesi al frame e all'atomicità di Endpoints e Contact_Weights, compresa la transizione weighted→single. Questi ultimi cambi non sono ancora compilati/provati; r62 congelata resta precedente.
- Root rilegge connect/weld r62:755/768 confrontabili,13scostamenti e2configurazioniPGSinterrotte. Rimane un Newton sparse stress (weld-independent-1,torquescale10000,sample0,acc2,57e-5); non eliminato dal corpus. Occorre isolare sul problema esatto assemblaggio H e aggiornamenti C dopo il checkpoint prestazionale.
