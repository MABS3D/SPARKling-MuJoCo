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
| R01 | Prestazioni step vincolato | LDL-only 96DOF -4,05% appaiato vs forza originale, CI sotto1; circa4,95xC. Confronto cumulativo r16 distinto, ancora5,11xC; nessuna parità globale |
| R03 | Relazione funzionale globale Cholesky | Denso C348 nella revisione locale +385 differenziali; modello finale/rango e congruenza minimi avviati, composizione globale aperta |
| R04/R05 | Unificazione forze e vincoli | Produzione Total originale+LDL; Full_Bias riferimento634/634 validation e getter6/6 conservati. Kernel totale42chiusi,198/198 per profilo; movimento a una RNE ancora draft |
| R06 | Uguaglianze connect/weld | Root geometria619/scalar83; connect/weld con fattore Ada766/768 nei due profili, restano2qfrc sharedCG e2abortPGS; XML/MJB/input identici r72. Joint/tendon576/576 nella ricevuta r72 |
| R07 | Vincoli dei tendini | Differenziale76/76 con forza originale+LDL, entrambi profili; composizione Gold aperta |
| R08 | Coni ellittici | 254/254 con forza originale+LDL, entrambi profili; prove composte aperte |
| R09 | NoSlip | Ripreso: 628 confronti passati, 4 errori riferimento; variante densa 12/12 |
| R10 | Potenze solimp | 3874 casi C finiti esatti, 197 C nonfinite rifiutati; sette minime + unità finale 78 check chiusi; prestazioni integrate pendenti |
| R16 | Surface velocity | Kernel171 chiuso; forza originale+LDL92/92 in entrambi profili |
| R30 | Prove di composizione | Pubblicazione12 e setter endpoint11 chiusi nelle vecchie closure; weighted186/186 nei due profili, nuovi contratti atomici da provare |
| R31 | Invarianti inizializzazione | Sette helper sul vecchio snapshot; contratti mocap aggiornati, Create e setter globale aperti |
| R32 | Prove PGS/CG/Newton | LDL produttiva: kernel181 chiusi,230/230 bitwise per profilo; relazione globale/caller aperti. Ponte CSR: Pack17 minimo152, whole340chiusi/1aperto; nuovo Append_Row23 24chiusi/1aperto; Incremental26/16 e CSR/rankone/Factor ancora aperti |

Prossimo checkpoint: Full_Bias e movimento privato a una RNE con diagnostici preservati nei rami pubblici/errore; prosegue Pack/fattore→caller su snapshot distinta. Nessuna nuova prestazione senza finestra quieta.

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

## Checkpoint 21: supporto sparso e nuova composizione

- Misura root r7→r62:24DOF19,28→13,44µs;48DOF73,76→32,22µs;96DOF400,39→89,48µs, intervallo rapporto[0,2217;0,2275]. C16,00µs sul caso maggiore: prestazione ancora5,60x. Fonte `sparkling-sparse-newton-benchmark-20261003-r62`. Le modifiche di r62 oltre al solver restano esplicite; regressioni6–11% sui piccoli casi da attribuire.
- Eliminata la ricostruzione del supporto attraverso scansioni N×N ripetute per blocco: uso liste di colonne già disponibili e unione delle sole colonne presenti. Nessuna modifica al mask finale né all'ordine della fattorizzazione; la prova universale del costruttore di supporto nel solver resta aperta.
- R10 standalone passa428/428 dense e428/428 sparse; kernel395/395 bitwise anche con signed-zero e adiacenza soglia. R10 integrato validation107,73s, manifest cd80572bf9777bc87173e3dcaea08d7307fe438924f14703257baf7dd4a08159: rigido106/106, ellittico254/254, surface92/92, forze452/452, tendini76/76, asset117/126 e asset locali120/126. Residui asset preservati. Fonte `sparkling-recovery-dynamics-20261003-10`.
- La closure r10 include weighted endpoint e Velocity con riduzione densa/sparsa C. Services aveva isolato questa sola correzione e chiuso R22 da297/300 a300/300; ora si rinnova la composizione. Collision usa la closure per flex esteso. SDF separato su r62 passa44/44 a100passi; abort del C mesh/SDF rimane distinto.
- Factor sparse raggiunge watchdog anche nel tentativo diagnostico1s/check; nessun esito intero dichiarato. Scomposizione in contributi di righe iniziata con contratti funzionali e frame; lemma Columns_Ordered14 chiuso, Separate_Column in prova. Il nuovo Update_Row non è ancora chiamato nel runtime e non altera le ricevute r10.
- Root ha scoperto36configurazioni miste equality/contatto/limite/attrito rifiutate già in r62: restringimento Force a±1e10 in CK.Accumulate_Force, mentre C produce6,58e15 su righe J=0 con accelerazioni e forze totali ammissibili. Root prende quei due kernel per ampliamento/prova. Nessuna modifica dei dati, delle soglie o del riferimento; nuova build necessaria dopo la correzione.


## Checkpoint 22: forze grandi, rotazioni e prove sparse locali

- Root ha ampliato il dominio di Accumulate_Force senza cambiare la formula: minima7 e intera MJ.Constrained_Kernels39 chiuse, zero aperti/warning. R72 scalar576/576 a100passi comprende i108 campioni misti prima rifiutati, con J/aref/R esatti e stato massimo3,91e-14. Connect/weld rimane755/768 confrontabili e2configurazioniPGSinterrotte; la correzione Velocity non chiude quei13scostamenti. Ricevute del root attribuite alla closure r72.
- Collision rinnova flex sulla closure r10:186/186 a100passi sia validation sia release, inclusi self/cross/internal, pesi, elasticità e rifiuti atomici. Flow child57/stato66/elasticità83 senza aperti, con warning26/8/90 espliciti. Non è prova globale dello step.
- Sparse: Separate_Column17 e Update_Row78 chiusi, inclusi relazioni funzionali per componente e frame. Factor ora usa Update_Row, ma la prova composta raggiunge ancora watchdog240s senza report finale. Occorre scomporre ulteriormente; nessuna eccezione Gold e nessuna assunzione. I395 confronti bitwise precedenti risalgono al runtime non scomposto e saranno rinnovati.
- Applicata la correzione quaternion delle tre rotazioni asse/anchor fornita da services. La loro ablation chiude960/960FD; ricevuta produttiva separata960/960FD,2848/2848inverse e412/412risposte vincoli. Aggiunto Rotate_Config in Pose_Arithmetic come wrapper dell'identica routine, con bound e contratto esatto per componente; la prova locale e quella del parent sono ancora da eseguire.
- Nuova closure centrale r11 congelata per compilazione e regressione, comprendente il fix Force_Value, quaternion e Update_Row. Nessuna ricevuta di r72/r10 viene estesa automaticamente a questa closure.


## Checkpoint 23: stato alla pausa comunicata dal root

- Il root comunica che get_goal riporta l'obiettivo globale in pausa; non avviate nuove lavorazioni. Rimaneva una sola minima Rotated_Component attiva con watchdog120s; il suo risultato finale è riportato sotto. I runner preparati per ulteriori prove e ablation non sono stati avviati.
- Root conferma r72 validation/release dalla stessa closure: scalar576/576 a100passi e lifecycle46/46 ciascuna, record identici. Non si estende tale ricevuta alle modifiche successive.
- R11 centrale validation compilata in106,02s, manifest9490d1eccdea636bfcaa40877d58116ad5994e14e4c824ee5a31dd0c110fd4f3, binarioe202c427de1e9a1ae656c2d572956c21a47b5d426499cefd4293b2cd1fcdf230. Ellittico254/254, surface92/92, forze452/452, tendini76/76, asset117/126, asset-locali120/126. Rigido e release non ancora rinnovati su r11.
- Pose: la prima Rotate_Config chiudeva12check ma lasciava due bound intermedi in timeout. Introdotti helper esclusivamente ghost: Intermediate_Value18, Intermediate_Component9, Rotated_Value18 e Rotate_Config14 passati nelle rispettive minime. Rotated_Component conserva un post esatto aperto nei tentativi5s/check; la prova complessiva dell'unità e Apply_One_Joint non sono ancora state eseguite. Snapshot di prova separati pose-proof-source02/03/04, nessun binario ereditato. Primo errore del nome Identity (matrice anziché quaternion) conservato e corretto.
- Sparse: Prepare_Row27check senza aperti, ma il runner inizialmente non classificava l'avviso runtime Sqrt presente nel contratto di Store_Row. Aggiunta classificazione esplicita della stessa frontiera standard già recensita nel Dense; nessuna soppressione del warning o assunzione. Store_Row69check con due obblighi aperti sul bound matrice; introdotto Store_Element con post esatto/frame, minima10check passata. Store_Row ora lo usa ma non è stato riprovato; Clear_Row e Factor scomposto sono ancora da provare.
- La build r11 precede i nuovi Prepare_Row/Store_Row/Clear_Row/Store_Element e gli helper ghost pose. Ultime sorgenti salvate in `sparkling-recovery-dynamics-20261003-11/paused-checkpoint` con hash. Il checkout preserva tutto il lavoro; nessun commit/reset/clean.
- Ablation dell'ordine massa nell'Hessiana preparata soltanto come script `run-hessian-mass-ablation.py`, non eseguita e non applicata al solver produttivo. Nessun nuovo risultato prestazionale: ultima misura valida resta r62,96DOF89,48µs contro C16,00µs.

Alla ripresa: chiudere Rotated_Component e unità Pose_Arithmetic/parent; riprovare Store_Row, Clear_Row e Factor; nuova build solver e395bitwise+428dense/sparse; poi nuova closure centrale validation/release identica e corpus rigido/ellittico/forze/tendini/assets, contratti setter weighted e benchmark soltanto in finestra coordinata. R03 relazione globale e R32 completezza solver, oltre alle altre code già documentate, restano aperti.

Esito ultimo job alla pausa: Rotated_Component10s/check termina regolarmente in47,41s,15check provati e1postcondizione esatta in timeout, zero warning. Nessun processo dynamics rimasto attivo. Ricevuta `11/proof-rotated-component-05/results.json`; il post resta aperto e nessuna prova intera è dichiarata.


## Checkpoint 24: ripresa esplicita dell'obiettivo globale

- Ripresa autorizzata dal root dopo richiesta esplicita dell'utente. Tutti i cinque hash sorgente salvati al checkpoint23 coincidevano con il checkout; nessun lavoro precedente ripetuto da zero.
- Sparse: rinnovo Prepare_Row27 e Clear_Row29 passati; Factor scomposto30 passa per il suo contratto locale bounds/diagonale/rank. Store_Row mantiene tre obblighi aperti di bound/frame; la sua prova è necessaria prima di accettare la composizione. Il post globale della fattorizzazione resta distinto e aperto.
- Pose: tre helper ghost per asse rendono Rotated_Component9 e Rotate_Config14 provati, ma i post dei tre helper sono ancora aperti. Diagnosi X con asserzioni separa i rami zero/identity (provati) dal ramo generale;27check chiusi e1assert esatta in timeout. Nessuna formula runtime o contratto indeboliti. Esperimento Inline_For_Proof del modello già esistente confinato a snapshot separato, non applicato live.
- Collision estende la propria ricevuta r10 a234/234flex e48/48midphase-off nei due profili, con323hash totali/266comuni uguali. Rimane attribuita a r10. Services prepara controller PID/DC/SO3 su un solo Simulation e patch parent minima, non ancora applicata.


## Checkpoint 25: nuova closure numerica prima della misura

- Root mantiene la priorità prestazionale integrata: dopo le minime attive, congelare validation/release correnti senza aspettare la prova globale, mantenendo aperti espliciti.
- Store_Element con frame equivalente separato chiude14check. Store_Row con frame separato e bound astratto chiude71check; resta1postcondizione sul frame globale. Le invarianti funzionali e i bounds precedentemente aperti sono ora provati.
- Rotated_X: rami zero/identità e27check provati, resta il collegamento esatto del ramo generale. Esperimento Inline_For_Proof isolato non lo risolve, quindi non applicato al comune. Nuova variante ghost con argomenti del modello espliciti salvata, ancora da provare; contratto e runtime invariati.
- R12 standalone:395/395 bitwise C (struttura/fattore/rank/solve),428/428 dense e428/428 sparse. I15replay equality coincidono esattamente coi record r10; nessun residuo chiuso attribuito alla sola scomposizione.
- Closure corrente congelata in `sparkling-recovery-dynamics-20261003-12/integrated`; build validation in corso, poi release --frozen e gli stessi7corpus. `verification-scope.json` elenca precisamente modifiche incluse e prove mancanti. Nessun benchmark durante questa sequenza.

- R12 composizione completata: validation e release dalla stessa closure5d9f092a14a903a5323e006d9ed7e60cc24b4cc42ec8263e68ecad568edb8c2b, checkout_matches_snapshot=true alla fine release. Tutti i report numerici dei due profili coincidono esclusi identificativi binario: rigido106/106,ellittico254/254,surface92/92,forze452/452,tendini76/76,asset117/126,asset-locali120/126. Fonte `12/profile-comparison.json`; compilazione release132,67s non è misura runtime.
- Terminati tutti i job locali e comunicata disponibilità al root per finestra quieta r62/r12/C. Nessun nuovo prover/build finché termina la misura coordinata.
- Audit ulteriore: il solver ricostruisce Columns da J/=0 e perde gli zeri strutturali CSR. Per l'ordine esatto delle riduzioni sparse occorrerà conservare il supporto per riga nell'API/export; l'attuale Hessian_Pattern da solo non basta. Nessuna attribuzione causale ai residui finché le ablation non dimostrano l'effetto.


## Checkpoint 26: benchmark integrato r62/r12/C in finestra quieta

- Dopo consenso root e verifica processi senza compiler/prover concorrenti, eseguito il comando preparato immutato: CPU2, 15 blocchi alternati, 8 batch, 100 passi, un warmup esterno per blocco. Guardia conclusa exit0 in7,3s, RSS80MB. Tutti7workload rispettano le soglie originali; massimo errore stato r12 5,88e-15. Driver/helper/fixture identici alla precedente misura r62.
- 96DOF: r62 82,37µs, r12 71,90µs, C14,84µs per passo. Rapporto appaiato r12/r62 0,8729 CI95%[0,8457;0,9012]; r12/C4,815 CI95%[4,790;4,943]. P95 delle traiettorie: r62 8722,54µs, r12 7843,71µs, C1566,03µs.
- 48DOF:29,48→27,05µs, rapporto0,9106 CI95%[0,8927;0,9275], C8,19µs. 24DOF:12,46→12,25µs, CI rapporto[0,9586;1,0021]. Nei quattro modelli più piccoli gli intervalli r12/r62 includono1; nessun miglioramento o regressione conclusivi su quei casi.
- Fonte completa `sparkling-sparse-newton-benchmark-20261003-r12/results.json`, campioni e dispersioni conservati. Binario r12 SHA9aabe02a83f87c78c0293a890c7343c89a281f1182aaa68f6043c6160451235c; closure5d9f092a14a903a5323e006d9ed7e60cc24b4cc42ec8263e68ecad568edb8c2b. I14file mutati da r62 sono elencati in `12/benchmark-prepared.json`; la misura complessiva non attribuisce il guadagno a una modifica singola. Asset esclusi dai7workload, loro residui invariati e parità complessiva ancora aperta.
- Terminata la finestra, ripresa la minima Rotated_X sullo snapshot05 già congelato. Prossime attività: chiusura delle relazioni pose/frame sparse, ablation ordine Hessiana e futura API CSR con valori per slot, mantenendo ordine, zeri e duplicati (anche larghezza>N), senza ripetere valori già aggregati.


## Checkpoint 27: CSR nativo e prima riduzione C

- Nuova API Sparse_Jacobian conserva offset/width/column/value per slot: zeri strutturali, ordine arbitrario, duplicati e larghezze maggiori del numero DOF sono rappresentabili. Prepare_And_Solve passa lo storage nativo; il solver usa le quattro lane C per J*a e J*search. Hessiana, gradiente e percorso duale mantengono per ora il precedente J denso/supporto numerico: non si dichiara completata la compatibilità dei duplicati in tutti gli algoritmi.
- Kernel Jacobians nuova build validation:312/312 confronti esatti contro mju_mulMatVecSparse della libreria C normale e mju_dot denso;174 casi distinguono l'accumulo sequenziale. Corpus con gap CSR, colonne duplicate/non ordinate, zeri, code0..3, width1025>N7 e3 layout malformati rifiutati. Il primo generatore usava scale1e120 anche per la matrice densa coalescata: duplicati ne superavano il dominio Operand; corretto il generatore a1e116 per mantenere anche quell'ingresso nel contratto, senza cambiare il dominio del kernel.
- Differenziale solver428/428 dense,428/428 sparse ricostruito e428/428 CSR nativo. Fonte `sparkling-recovery-dynamics-20261003-13`. Riesportati15problemi equality con native_jacobian/provenienza; il solo ordine J*v non chiude il Newton stress (errore accelerazione2,30e-5). I replay restano diagnostici, nessuna tolleranza cambiata.
- Rotated_X snapshot05 chiude34check esatti: il ramo generale collega gli argomenti Model.Rotation_Intermediate esplicitamente. Y/Z e composizione intera ancora da rinnovare; la sola minima non è Gold dell'intera unità.
- Prove minime Jacobians avviate prima della nuova build integrata. Prima Product5 senza obblighi aperti, runner inizialmente rifiutava i warning strutturali delle ricorrenze ghost: classificazione estesa con le stesse regole delle ricorrenze già recensite, mantenendo warning/report e obbligo di dimostrare corpo/terminazione. Nessuna soppressione o assunzione.

- R13 integrata conclusa: validation/release stessa closure5ce2787d39990ef126dc8758395011d36ffd63d86e22674cbee90358584dd313, record numerici identici fra profili. Rigido106/106, ellittico254/254, surface92/92, forze452/452, tendini76/76; asset118/126 e locali118/126 (r12:117/126 e120/126). Restano8residui in ciascun corpus, senza modifica delle soglie. `13/profile-comparison.json` e `13/verification-scope.json` delimitano precisamente sorgenti/prove.
- Minime r13 iniziali: Product5/Add10/Valid6/Lane_Sum21 chiuse; Row_Value27+1range aperto, Dense_Row30+5range aperti, Sparse_Row watchdog120 senza report. Nuova scomposizione live successiva alla freeze: Combine10, Tail111, Unfold_Lane17 e Advance_Lane21 chiuse. Blocks in prova; nessuna ricevuta estesa al binario r13.

- Ablation gradiente separata `13/gradient-ablation`: cambiata soltanto formazione qfrc (dense per righe, sparse via JT ordinato a quattro lane) e sottrazione finale Grad=(Ma-Smooth)-qfrc. Tutti7replay CG weld-independent prima divergenti diventano esatti per accelerazione/forza/iterazioni;428/428dense e432/432native passano (4 nuovi rifiuti CSR atomici). Newton sparse estremo resta aperto,2,30e-5→3,28e-5; shared CG migliorano senza diventare esatti. Non applicata produzione: transpose e azioni richiedono estrazione/prove/confronto minimo.
- Ulteriore prova CSR live: Blocks44, Tail_Value69, Tail50, Row_Value31, Dense_Values12 chiuse. Sparse_Row14 lascia l'asserzione di composizione aperta; Dense_Row conserva obblighi di composizione. La scomposizione preserva formule/ordine, senza assumere i post aperti come risultato conclusivo.

- Congruenza CSR chiusa: Combine_Value6, Combine10, Equal_Tails6 e Sparse_Row34 passano. La sostituzione di una somma floating numericamente uguale nel modello opaco Tail_Value richiedeva un lemma esplicito, provato aprendo il solo modello. Dense_Row conserva obblighi di composizione; nessuna Gold intera dichiarata.
- Seconda ablation, solo ordine della massa nell'Hessiana sopra il gradiente corretto: Newton weld sparse estremo scende3,28e-5→1,82e-12 in accelerazione, forza2,10e-10. I7CG indipendenti restano esatti. `13/gradient-mass-ablation/replay-native.json`. Nuovo ball/plane servizi resta aperto: gradiente riduce0,1088→0,0137, ulteriore ordine massa non lo chiude; errore forza1ULP.
- Estratto Jacobian_Transpose a tre passaggi stabili, con modello di conteggio/posizione per slot e contratto funzionale completo ancora da provare. Prima build riuscita. Il confronto bitwise ampliato espone1/390 riduzioni e2/312 transpose/forza differenti soltanto per segno dello zero: la libreria SIMD C inizializza le lane col primo prodotto, il fallback scalare con+0. Allineata la nuova ricorrenza e il runtime al percorso SIMD normale; nuovo build/rinnovo in corso, vecchie ricevute non estese alla modifica.


## Checkpoint 28: gradiente e pubblicazione delle forze C

- Composizione produzione Solve_With_Force passa428/428dense e432/432CSR nativo. Preserva la vecchia API come wrapper; pubblica qfrc col medesimo ordine del metodo (primal sparse via trasposta a quattro lane; PGS scatter per righe). Nuovo corpus215/215 confronti bitwise delle forze generalizzate con le routine native C, con rifiuti atomici e origine errata dell’output esercitata in ogni caso.
- I15replay riproducono gli esiti delle ablation: sette CG indipendenti esatti per acc/force/iterazioni; Newton sparse estremo acc1,82e-12 eforce2,10e-10. SharedCG conserva piccoli scarti e PGS instabile continua Invalid_Input contro il recupero/resetC: entrambi aperti. Ball/plane servizi ancora aperto dopo miglioramento parziale precedente.
- SIMD lane seeding rinnovato numericamente:390/390riduzioni e312/312transpose+forza bitwise, inclusi signedzero/gap/duplicati. Prove nuove Layout6 eWidth_Prefix9 chiuse; Build e rinnovo composizione Jacobians ancora aperti, nessuna Gold globale.
- Parent collegato alla forza generalizzata già calcolata dal solver, con ammissione fisica prima della pubblicazione invariata. R14 congelata dopo hook flex equality del root; build validation e release dalla stessa closure in corso. Manifest e scope dettagliato in `sparkling-recovery-dynamics-20261003-14/verification-scope.json`. Nessuna misura prestazionale nuova.

- R14 validation/release completate dalla stessa closuref7843d1f16461f744a52bf3edd0c852d11a551776d760ff0b84ff232c7cf5577: rigido106/106,ellittico254/254,surface92/92,forze452/452,tendini76/76,asset121/126 eassetlocali120/126. Record numerici identici fra profili; rispetto r13 i residui asset scendono8→5 e locali8→6, non tutti chiusi. Nessun benchmark nuovo; collegamento controller ancora escluso daquesta closure.

- Minime CSR SIMD rinnovate: Lane_Sum29,Unfold_Lane24,Advance_Lane27,Blocks44,Sparse_Row34 passano. Dense_Row97check con4aperti; isolata funzione Term e aggiunta congruenza prodotti Equal_Products4, Term28 chiusi. La prova densa composta successiva è in corso. Trasposizione: Layout6,Width_Prefix9,Unfold_Width8,Total_Width14,Before18 chiusi; Build inizialmente rifiutato da SPARK per dimensione Cursor dipendente dall’out T, ora usa copia costante della dimensione. Nuova minima Build ancora necessaria.
- Riesportati15problemi con native_smooth_force originale: problem e CSR invariati. Ablation smooth-force e successiva sola moltiplicazione massa nell’ordine simmetrico C non chiudono sharedCG; effetti marginali, non applicate produzione. Sul ball/plane servizi entrambe lasciano acc0,0136958321,force1,qfrc0,125; M è esatta C e Ada termina2iterazioni contro6C. Prossimo trace per primo aggiornamento diverso.
- Applicati dopo r14 soltanto i due hook factory services con backup in `14/factory-before`. Services rinnova: smooth808/808,minimi8/8,edgePASS; corpus fissi794/840 rispetto755/840 r13,46residui ancora aperti. R14 non include i hook né queste modifiche di prova successive. checkout_matches_snapshot=false a fine release r14 per aggiornamento child Equalities del root; entrambe snapshot_hashes_unchanged=true.


## Checkpoint 29: ricerca del passo e aggiornamento incrementale

- Isolati quattro raggruppamenti += errati in Evaluate_Line rispetto C: la sola correzione di parentesi porta il replay ball/plane sample6 daacc0,0137/force1/qfrc0,125 aacc4,98e-10/force4,21e-11/qfrc1,68e-10. Corpus standalone428/428dense e432/432CSR passa; fix applicato live. I15equality replay invariati.
- Trace a budget0..6: dopo grouping la prima iterazione diventa esatta C; la seconda diverge quando3righe cambiano stato. Ablation ulteriore implementa soltanto aggiornamenti/downdate Cholesky densi/sparsi e fallback rank come C: ora iterazioni0..3 esatte acc/force/qfrc; resta arresto Ada a3 mentreCprosegue6. Incrementale ancora solo snapshot diagnostico, non integrato: va estratto/provato e confrontato come kernel.
- Audit trova tre differenze concrete nei ritorni della ricerca bracketed: Ada richiede costo negativo anche dove C restituisce comunque il candidato/punto medio. Ablation pronta per separare questo effetto, senza cambiare dati o soglie.
- Prove: Dense_Lane_Updated12 chiusa; Dense_Row composto mantiene watchdog150/120 (con e senza inlining), nessuna Gold attribuita. Transpose.Build, dopo correzione dimensione, produce finalmente82check chiusi/5aperti (bound count/prefix/scatter e postfunzionale). Servono invarianti e lemma di conteggio, non assunzioni.


## Checkpoint 30: aggiornamento rank-one confrontato con C

- Le tre correzioni cumulative nello snapshot diagnostico (grouping, aggiornamento incrementale, uscite bracketed) chiudono il ball/plane sample6: accelerazione, forza, qfrc e iterazioni esatte a budget0..6/10/100. Corpus standalone428/428dense e432/432native passa anche sull'ultima ablation. Solo il grouping è finora nel solver produttivo; i840casi integrati non sono ancora rinnovati.
- Nuova unità Cholesky_Updates estratta dai distinti algoritmi C denseLL' e sparseL'L. Dieci minime scalari con contratti esatti chiudono92check; prima build e346/346confronti bitwise contro i corpi ufficiali C3.14 passano, inclusi zero/rank/clamp/downdate e due rifiuti numerici nel dominio esplicito. Ricevute `14/proof-updates-scalars-02-*`, `14/updates-build-01`, `14/updates-cases-01`.
- Prova iniziale Update_Dense senza invarianti produce39check e8aperti. Scomposto in aggiornamento colonna/vettore con post funzionali esatti e frame; Dense_Vector35chiuso, Dense_Column54con4aperti nella prima variante. Store_Lower e invarianti dell'ingresso congelato sono in preparazione. Nessuna Gold dell'unità o del solver dichiarata.
- Term29 della riduzione densa chiuso dopo correzione delle invarianti contigue; Dense_Row e trasposta Build restano composizioni aperte. Nuovo replay mobile services riproduce7,289e-10anche senza controller ma mostra differenze free/J/aref: distinto dal ball/plane geometricamente esatto.

- Variante con store esatto: Store_Lower12 eStore_Diagonal12 chiusi. Dense_Column54con6aperti; Sparse_Row/Update_Dense/Update_Sparse raggiungono watchdog120s. Invarianti portate all'inizio del loop e separazione colonne ghost aggiunta dopo questi snapshot: composizione ancoraOPEN, nessuna precondizione o post indeboliti.
- R15 produttiva standalone rinnovata:346/346rankone bitwise,428/428dense,432/432native,215/215forze. Trace ball/plane produttivo coincide C a tutti9budget, incluse6iterazioni finali. I15export con native_mass conservano problem/CSR/smooth originali esatti; rimangono sharedCG,Newtonstress ePGS recovery. Freeze centrale validation/release avviata e comunicata agli altri worker; include anche prima laneSIMD parent e hookfactory.

## Checkpoint 31: r15 riproducibile e ordine dei geom C

- R15 centrale validation/release completate dalla stessa closure `cf08f2fe79c2f534277f373713a0fb989fb5e72971da98047bd5a3f9177794da`. Record numerici identici: rigido106/106, ellittico254/254, surface92/92, forze452/452, tendini76/76, asset119/126, asset locali122/126. Entrambi gli snapshot immutati e checkout coincidente a fine build; le modifiche successive non ereditano queste ricevute. Nessun nuovo benchmark.
- Il solver produttivo ora include aggiornamenti Cholesky scalar Newton e ritorni bracketed C: trace ball/plane sample6 esatto a tutti9budget. Services rinnova sulla r15: fixed794/840 e mobile839/840 nei due profili,47 lacune complessive conservate; la chiusura locale non equivale alla chiusura delle traiettorie.
- Replay degli11residui asset su31stati C identici individua9permutazioni di J/aref/forze: C ordina i geom per tipo prima di narrowphase e frame, Scene Ada conservava ID crescente. Ablation dei soli due file Scene e relativo contratto Contact_Order chiude tutte le differenze J/aref/R del replay, porta asset121/126 e locali125/126, rigido106/106. Fonte `15/geom-order-*`. Collision ha applicato personalmente la patch live verificando hash/backup; release e prova Scene ancora da rinnovare. R15 resta immutata e precedente a questo cambiamento.
- Ablation nativa LDL diagnostica usa esclusivamente nello snapshot fattori C esportati: sharedCG dense acc1,605e-9→1,874e-13, sparse2,43e-9→1,110e-11; force residua1,26e-10 e8,27e-9. Non applicata al runtime, non è un port della massa. Newton stress e PGS recovery restano aperti. Tutti15export conservano problem/CSR/smooth identici, aggiungendo native_mass con M_* CSR e provenienza.
- Avviato confronto minimo Manifold_Math contro C: audit documenta divisioni invece di reciproco per normalize3, azzeramento errato dell'angolo tiny e no-op normalize4 più largo. Prima si isolano i tre comportamenti senza modificare il controller Expmap, il cui algoritmo C è diverso. Prove di composizione rank-one/CSR/pose, sei residui asset dopo ablation e parità prestazionale restano aperti.

## Checkpoint 32: normalizzazione e incremento quaternionico

- Audit C riprodotto con probe minimo: controllo r15 normalize204/384, increment334/824, integrate94/824 bitwise. Solo normalize3 con reciproco, norma tiny restituita e ramo angle=0 esatto porta increment820/824. Normalize4 con norma ordinata e no-op abs(N-1)<=1e-15 porta normalize384/384 e integrate820/824. I4residui sono tutti il shortcut Cos del runtime GNAT.
- Candidato tinyCos `1-(X*X)/2` per abs(X)<2^-26 confrontato con libm in124576campioni, inclusi nextafter delle soglie di arrotondamento; nessuna equivalenza universale dichiarata. Kernel reale Ada poi passa18416/18416 contro MuJoCo3.14.0, inclusi16384nextafter nel percorso completo Rotation_Increment. Driver/input/binario/libreria sono identificati nelle ricevute `16/manifold-boundaries`.
- Ablation integrate appaiate2samples×30: Scene-control asset121/126/local125/126; sola correzione Rotation_Increment125/126 e125/126. Normalize4 e tinyCos mantengono gli stessi2residui, rispettivamente heightfield_cylinder_9_False/sample0 e heightfield_mesh_9_True/sample1. La precedente esecuzione a3samples186/189 e188/189 è distinta e non usata nell'attribuzione appaiata.
- Applicati i due Manifold_Math e nuova MJ.Trigonometry.Cosine comune, con backup e hash. Nessun cambio all'algoritmo Expmap degli attuatori. Normalized mantiene il post Unit_Quaternion e aggiunge relazione FP per componente; il vecchio post di preservazione è corretto alla vera condizione C sul norm, mentre Already_Normalized resta il separato predicato geometrico della pipeline.
- Minime locali Normalization_Component7, Unchanged3, Value8 e Cosine9 proof chiuse. Normalization_Length10+1postbound aperto; Normalized composizione in diagnosi. Non dichiarata Gold del modulo. Cosine estratto min/intera: code0,11check proof+flow chiusi, copertura completa; runner strictpassedfalse a causa di4warning imprecise-call sullo standard Ada.Cos. Warning conservati, nessuna assunzione/soppressione/binding nuovo. La relazione esatta concerne il ramo FP e il richiamo standard, non il corpo libm.
- R16 congelata con314file in `sparkling-recovery-dynamics-20261003-16/integrated`; composizione validation/release e regressioni in corso. Nuove ricevute non ancora attribuite ai child services/flex. Nessuna nuova misura prestazionale; ultimo benchmark valido resta r12.

- R16 conclusa: validation/release stessa closure6042889313ba7aa5f985bded0f16331f0a6bd5c46703bd8d76da0b0c0a6120d3, snapshot immutati e checkout coincidente alla fine di entrambi. Tutti7corpus hanno record identici fra profili; i conteggi sono quelli sopra. Nuovo kernel produttivo, compilato separatamente con i due profili, conferma18416/18416 in ciascuno.
- Replay dei2residui su31stati C identici: conteggi/J/aref/R esatti; cylinder acc<=4,27e-14 e stato singolo<=5,56e-17, mesh locale acc<=3,56e-15 e stato singolo<=1,39e-17. La divergenza di traiettoria resta registrata e non è chiusa da questi replay locali. Ricevute `16/asset-same-state`.
- Minimo Normalized emette14check, resta il post Unit_Quaternion aperto; non eliminato. Avviato rinnovo Rotated_Y/Z con la stessa scomposizione Ghost già chiusa per X, poi Rotated_Component/Rotate_Config. Queste sole asserzioni Ghost successive alla freeze non sono incluse nella r16.


## Checkpoint 33: intera Pose e ammissione del solver

- Rotated_Y/Z chiudono 29 check ciascuno, Rotated_Component 7 e Rotate_Config 11; intera MJ.Pose_Arithmetic chiude 300 proof + 62 flow, zero aperti, copertura completa, senza assunzioni. Fonte `16/proof-pose-whole-06`. I soli cambi successivi a r16 sono nei corpi Ghost Y/Z; la closure `16/integrated-pose` (manifest 89f46e8d29494989bfd14cb4cb921cb8d0e7f217d8b1e09a7bb72c908925c65c) conserva identico runtime. `equivalence.json` verifica il testo esterno ai due corpi Ghost; root la usa per la nuova composizione FLEX.
- Preparata soltanto in snapshot `17/original-force-v2` l'API opzionale per la forza smooth originale: evita la ricostruzione M*A_Free quando il caller possiede già Dynamics.Total. Nessun valore C viene inserito nel runtime produttivo; nessun risultato numerico nuovo ancora attribuito alla proposta.
- Il primo minimo Smooth_Force_Valid fallisce prima di emettere check perché Incremental_Hessian, introdotta nel percorso R15, è una funzione che modifica la matrice HL catturata. SPARK rifiuta correttamente la funzione con output globale. La correzione richiede una procedura con esito out e preservazione delle stesse uscite/fallback; non una soppressione né una nuova boundary trusted. Ricevuta `17/proof-smooth-force-valid/results.json`; prova/composizione restano aperte.
- Applicata la patch di dominio Cosine di services: rimosso soltanto il pre arbitrario ±1e21, post funzionale e bound risultato invariati. Minimo/intera hanno 9 proof + 2 flow chiusi con copertura completa; 5 warning del richiamo standard Ada.Cos conservati, strict_passed=false. Probe diretto 4096/4096 bitwise host libm, inclusi 1887 input oltre il vecchio dominio: confronto campionato, non equivalenza universale. Fonte `sparkling-services-cosine-wide-{min,whole,runtime}-20261003`. R16 congelata resta precedente.
- Finestra quieta root: nessun job dynamics attivo; nessun nuovo build/prover/benchmark avviato finché termina la misura r12/r16/C. Ultimo benchmark valido resta r12 fino alla nuova ricevuta.


## Checkpoint 34: regressione r16 e controlli causali

- Root ha completato la misura quieta r12/r16/C su 7 modelli, 15 blocchi alternati × 8 traiettorie × 100 passi, CPU2. Correttezza: stato esatto C in 6/7 modelli, shared_ancestors differisce 1,11e-16. Tutti e 7 i rapporti r16/r12 hanno CI95% sopra 1; corpi liberi 24/48/96 DOF: +4,54%/+7,36%/+10,20%. A 96 DOF r16 76,733 µs contro C 14,392 µs, rapporto appaiato 5,272 [5,222;5,398]. Fonte `sparkling-sparse-newton-benchmark-20261003-r16/run/results.json`; non attribuito a una singola modifica.
- Sospesa l'estensione forza originale/LDL per localizzare prima il costo. Tre controlli congelati derivati da r16, ciascuno con manifest e diff: `17/manifold-r12` ripristina soltanto due file Manifold; `17/scene-r12` soltanto due file Scene; `17/solver-r12` ripristina il solver r12 e il suo solo adapter nel parent, mantenendo nuove uguaglianze/factory/seed Velocity. Sono controlli diagnostici, non correzioni da integrare. Build release e correttezza degli stessi 7 workload in corso, nessun timing ablation ancora effettuato.
- Audit del binario r16 conferma che Sparse_Row contiene numerosi controlli dei sottotipi e degli indici per prodotto, oltre alla nuova costruzione/copia/trasposizione CSR per passo. Queste sono ipotesi di costo da distinguere con misura, non cause già attribuite. Qualunque ottimizzazione successiva dovrà conservare ordine C, frame e proprietà funzionali.
- Preparata in `17/original-force-v3` la conversione Incremental_Hessian a procedura con esito out; gli stessi due ritorni di fallback e l'ordine numerico restano invariati. Non applicata live e non ancora provata/compilata: rimane separata dai controlli prestazionali.

- Tutte tre le ablation release completate; 7/7 workload a 100 passi passano ciascuna, soglie originarie 2e-9 assoluta/relativa. Massimo stato manifold 4,86e-15, scene 1,11e-16, solver 1,38e-14. Tempi emessi dai probe esplicitamente scartati nel controllo di correttezza. Command/manifest/hash e proposta paired salvati in `17/benchmark-proposal.json`; worker fermo in attesa della nuova finestra quieta.

- Seconda finestra quieta completata con tre confronti appaiati, preflight zero heavy e ACK di tutti i worker. A 96 DOF: manifold-r12/r16 0,9966 [0,9794;1,0117], scene-r12/r16 1,0116 [0,9932;1,0340], solver-r12/r16 0,9232 [0,9160;0,9531]. Il cluster solver+adapter riduce quindi il tempo del 7,68% appaiato e migliora significativamente 6/7 workload; shared_ancestors ha CI che include 1. Nessun beneficio significativo a 96 DOF per i ripristini Manifold/Scene. Dati completi, dispersioni e hash in `17/benchmark-{manifold-r12,scene-r12,solver-r12}/results.json`; sintesi `17/ablation-benchmark-summary.json`.
- Tutti gli stati restano entro le soglie originali; max_abs=0 indica uguaglianza numerica, non confronto bitwise dei signed zero. Il solver storico perde correzioni funzionali già necessarie e non viene reintegrato. Il costo assoluto residuo di r16 contro C resta quello misurato nel checkpoint precedente; i tre confronti non dimostrano causalità di una singola riga o proprietà Gold del solver intero.
- Primo candidato per il costo delle conversioni preparato solo in `17/product-real`: Product accetta Real con pre A/B in Operand, invece dei due sottotipi formali. Il dominio ammesso e il post esatto restano identici; stessa moltiplicazione e nessuna soppressione. Inizia dal minimo Product e dal caller Sparse_Row prima di compilare il checkpoint integrato.


## Checkpoint 35: conversioni Product isolate e provate

- Il candidato `17/product-real` mantiene dominio/pre e formula Product, sostituendo soltanto i due sottotipi formali con Real più precondizione equivalente. Minime: Product 5, Advance_Lane 25, Tail 44, Blocks 44, Sparse_Row 34 (152 check complessivi), zero aperti. In ogni report restano 4 warning ricorsivi dei modelli già presenti, strict_passed=false; nessuna soppressione e nessuna Gold globale nuova.
- Probe validation delle riduzioni passa 390/390 bitwise contro C, inclusi signed-zero/duplicati/gap e 3 rifiuti di layout. Solver nativo 432/432. Build release integrata passa gli stessi 7 workload a 100 passi con max stato 1,11e-16 e soglie invariate. Snapshot immutato; `verification-scope.json` distingue minime, differenziale e composizione.
- Solo come audit del codice generato, Sparse_Row passa da 2525 a 1837 byte, Dense_Row.Term da 195 a 164 byte; la dimensione non dimostra un beneficio temporale. Binario cfedbfe2cec9c87e6fd04892678dcfb04110a52c9971e5624d51751594eceb02. Candidato ancora non applicato live; prossimo passo misura appaiata quieta r16/candidato/C, previo ACK di tutti i worker.

- Terza finestra quieta conclusa: Product-real/r16 a 96 DOF 0,9984 [0,9857;1,0223], nessun guadagno generale dimostrato; 24/48 DOF hanno anch'essi CI che include 1. Solo box_multiple migliora, 0,9500 [0,9312;0,9965]. Stato candidato e controllo identici numericamente: 6/7 errore zero, shared 1,11e-16. Fonte `17/benchmark-product-real/results.json`; nessuna modifica live di Product.
- Nuovo candidato isolato `17/sparse-mass-add-kernel-v2`: visita per H+M delle sole colonne nel Pattern della fattorizzazione, compresi fill e zeri strutturali. Il ramo denso e l'azzeramento completo H restano invariati; quest'ultimo è richiesto dal contratto attuale di Factor e viene tenuto per separare le cause. C ufficiale MakeHessian/FactorizeHessian aggiunge M dopo J'DJ con struttura sparsa.
- Prima minima Add_Mass_Row chiude 49 check: relazione FP esatta sulle celle selezionate e preservazione di tutte le altre. Per rendere il helper componibile su più righe, il secondo contratto ammette nelle righe già visitate il bound di uscita, mantenendo il bound d'ingresso nella riga attuale. Minime rinnovate Row e nuovo Add_Mass in corso; nessuna prova globale Factor o solver ereditata.

- Sparse mass addition: minime v2 Add_Mass_Row 51 e Add_Mass 39 chiuse (90 check), zero aperti; un warning imprecise-call Sqrt già nel modulo, non soppresso. Corpus standalone validation 428/428 dense e 432/432 nativo. I 15 replay di stress hanno stdout identico al controllo r15/r16, inclusi residui Newton/sharedCG e rifiuto PGS già aperti. Build release e 7/7 workload passano con max stato 1,11e-16. Snapshot immutato; nessuna integrazione live né prestazione ancora attribuita al candidato.

- Quarta finestra quieta conclusa: sparse H mass-add/r16 a 96 DOF 0,9683 [0,9462;0,9829], miglioramento appaiato del 3,17%. Mediane di step 75,50 vs 77,81 µs, C 14,96 µs; candidato/C 5,130 [4,961;5,200]. Gli altri 6 CI includono 1; nessuna regressione significativa osservata. Stati candidato/controllo numericamente identici (6 zero/shared 1,11e-16). Fonte `17/benchmark-sparse-mass-add/results.json`. È un confronto integrato del cambio Add_Mass, non un tempo isolato del kernel o di Factor.
- Recupero soltanto parziale della regressione r12→r16; il restante divario circa 5x richiede ulteriore lavoro sulla struttura e sul precondizionatore/LDL. Patch concreta salvata in `experimental/constraint-solvers-candidate/integration/sparse-mass-pattern.patch` con hash before/after, prove e misura collegati nel JSON. Product-real resta escluso; sparse pattern non ancora applicata al momento di questo checkpoint, composizione rigido/FLEX corrente ancora da rinnovare.


## Checkpoint 36: sparse mass integrata e regressione corrente

- Applicata la patch verificata dei soli tre file Sparse_Cholesky e solver dopo controllo SHA e backup. Patch cf55d6ea093b16b8bf3d88b727078169725de6b593aaca8ad8542d17e5bf93b9; Product-real escluso. Nessun cambiamento all’ordine della somma o al ramo denso.
- Closure centrale r18 congelata: manifest 15f2e82b5e8694a915f6e891eefa524f7e2c32633649aac0cac136600b698324, 311 sorgenti. Include anche i due corpi Ghost Pose già provati e il dominio Cosine ampliato; non include nuove API forza originale o fattore LDL. Rispetto alla vecchia mappa r16 mancano soltanto tre file di test Manifold aggiunti manualmente, non dipendenze del binario centrale.
- Validation e release completate dalla stessa closure immutata: rigido106/106, ellittico254/254, surface92/92, forze452/452, tendini76/76, asset125/126 e locali125/126. Tutti i record numerici coincidono fra i due profili e con r16; restano i medesimi due residui di traiettoria asset. Fonte `18/profile-comparison.json` e `18/verification-scope.json`, che distinguono anche corrispondenza checkout e snapshot. Nessun nuovo timing attribuito a questi binari.
- Prossimo passaggio separato: correzione della funzione Incremental_Hessian con output catturato, illegale in SPARK, in procedura equivalente; minimo di legalità/prova e controllo numerico prima dell’applicazione. Poi riprendere forza smooth originale e fattorizzazione LDL nativa. Le composizioni Gold ancora aperte e il divario prestazionale circa5x non sono chiusi da questo checkpoint.


## Checkpoint 37: forza originale e legalità dell’aggiornamento

- Correzione Incremental_Hessian applicata separatamente: procedura con esito out al posto della funzione con output catturato. E0005 eliminato; il minimo emette26check chiusi e16aperti (precondizioni dipendenti dal contesto ed eccezioni numeriche), con16warning conservati. Nessuna Gold della composizione attribuita. Standalone428/428dense,432/432native,15replay stdout identici. R18 iniziale resta immutata e antecedente.
- Smooth_Force_Valid minimo chiude5check e0aperti, con12warning preesistenti del modulo. Nuova API opzionale preserva l’ingresso originale Dynamics.Total invece di ricostruirlo come M*A_Free; l’omissione conserva l’API precedente. Probe verifica origine/dimensione/dominio errati con preservazione A/F/G in ogni caso. Corpus API428/428dense e432/432native, medesimi criteri; default15replay identici.
- Closure `18/original-force`, manifest1a7ce220173ca4b3a0ea9ef179124ebdfa865719e577fe070f1dcc9eda34fd62: validation e release chiudono tutti7corpus (106,254,92,452,76,126,126), record numerici identici fra profili. Sono chiusi i due residui asset/locali del checkpoint36 senza alterare fixture o tolleranze. Patch dei3file e probe applicata dopo verifica hash/live e backup; nessun nuovo timing. Fonte `18/force-regression/profile-comparison.json`.
- Avviato separatamente Native_Inertia.Solve, copia ordinata del backsolve mj_solveLD; fattore da riusare dal precedente solve Ada, nessun fattore C nel runtime. Bozza non integrata, quattro minime scalari/frame chiudono7+5+5+6check; due warning da modelli di riduzione propagati, conservati. Minime dei passaggi e test C seguono prima del collegamento. Il modello globale del solve e la provenienza funzionale del fattore restano da comporre.


## Checkpoint 38: LDL riusata nello step congelato

- Native_Inertia variante04 intera unità:147proof+34flow=181check chiusi, copertura completa, zeroassume;14warning ricorsivi dei modelli Jacobians conservati, strict_passed=false. Relazioni FP e frame dei tre passaggi sono specificate/provate; il post globale riguarda bound e atomicità, la composizione funzionale fattore→soluzione resta aperta. Reciprocal7 e Apply13 aggiunti dopo le minime iniziali.
- Confronto kernel indipendente con mj_solveLD:230/230 bitwise in validation e release della medesima variante04. Include192layout casuali,30ingressi dai15replay nativi e8rifiuti di struttura/dominio/numerici, oltre a origine output errata suogni caso. I fattori esportati C esistono solo nel test.
- API nativa preparata nel frozen `18/native-integrated`: il parent usa Scratch.Ancestor_Factor calcolato da Solve_Acceleration(D,0), conserva zeri e ordine CSR e calcola le stesse inverse diagonali; salta la seconda Factor_Metric. Ammissione struttura una volta, Apply opera su scratch con pre statici. La relazione fra questo fattore e la M corrente resta obbligo del caller, non una nuova assunzione di prova.
- Replay diagnostico15: default API conserva stdout; usando fattori C solo al probe, sharedCG dense acc1,604e-9→2,36e-13 eforce1,67e-10; sparse acc2,425e-9→2,22e-16 eforce0. Newtonstress ePGS recovery invariati e aperti. Fonte `18/native-solver-standalone/results.json`.
- Composizione reale con fattori Ada:1232/1232 casi per profilo (rigido106, ellittico254, surface92, forze452, tendini76, asset126 e locali126), tutti i record validation/release identici. Manifest898501e2b473b1aee7ed84e4d860cb62fda2796589cebf36d08db3f33c886dd8. Nessun LDL applicato live ancora, nessuna prestazione nuova misurata. Preparati confronti paired native/original-force/C e native/r16/C; worker zeroheavy in attesa della barriera esplicita root.
- Controllo preliminare degli stessi 7 input benchmark a 100 passi: original-force e native-integrated passano entrambi 7/7, massimo scarto stato C 1,11e-16; tempi scartati. Ricevute `18/{original-force,native-integrated}/workload-correctness.json`. Parametri della proposta: CPU2, 15 blocchi alternati, 8 traiettorie misurate più warmup esterno per blocco, soglie 2e-9 invariate. Nessuna misura avviata prima del VIA root e della chiusura del job BVH concorrente.

## Checkpoint 39: misura integrata LDL in finestra quieta

- Dopo VIA esplicito root, quattro ACK e fresh ps senza compiler/prover, eseguiti i due paired seriali della proposta invariata (handle61015 exit0). CPU2, 15 blocchi × 8 traiettorie × 100 passi, warmup esterno; driver SHA4b48fdc0e46e237985fa8deeb350b197bdf34ea4cd968b7731f0104d5bbd5944. Entrambe le guardie concluse, 7,6s e 7,3s, RSS80MB. Sorgenti congelati invariati dopo i timing.
- LDL contro original-force: a96DOF candidato73,859µs, controllo78,470µs, C15,037µs per passo. Rapporto appaiato0,95948 CI95%[0,86991;0,98327], miglioramento4,05%; candidato/C4,945[4,789;5,205]. Anche sphere migliora significativamente0,96487[0,94477;0,98667]; gli altri cinque intervalli includono1, nessuna regressione significativa. La misura isola il complesso API/adapter/backsolve LDL dentro lo step; non è il costo isolato del kernel.
- Confronto cumulativo contro r16: 24/48/96DOF rapporti0,95282[0,91997;0,99293],0,93867[0,90478;0,95319],0,94022[0,89355;0,99145]. A96DOF75,259µs contro83,303µs e C14,815µs; candidato/C5,106[4,973;5,239]. Gli altri quattro intervalli includono1. Non attribuito interamente al solo LDL: comprende anche sparse mass-add, forza originale e le altre differenze elencate nella proposta.
- Correttezza: entrambi i confronti rispettano2e-9 assoluta/relativa in tutti7modelli;6stati hanno max_abs0, shared1,11e-16 (uguaglianza numerica, non confronto signed-zero bitwise). Dispersione96DOF, P95 traiettoria LDL-only: candidato9684,775µs, controllo11257,980µs, C1986,513µs. Campioni, MAD e dispersioni complete in `18/native-benchmark-summary.json` e `18/benchmark-{ldl-only,ldl-vs-r16}/results.json`.
- Barriera terminata e root notificato. Nessuna integrazione LDL ancora eseguita; il divario circa5x e le prove globali fattore→soluzione/caller/solver restano aperti. La proposta numericamente verificata conserva181check locali e1232/1232 per profilo già delimitati nel checkpoint38.

## Checkpoint 40: LDL produttiva e contratti dell’adapter

- Dopo autorizzazione root applicata la patch LDL verificata: hunk sul parent, nessun overwrite dell’intero file; kernel e probe copiati con hash identici alla snapshot. Backup `19/before-native-inertia`, ricevuta `19/integration.json`, patch produttiva SHA24720e05f42108dbd9bc30f2995170a06defc534c59b2bb50af5278581e4c64e. Aggiornato soltanto l’elenco sorgenti/main del progetto standalone per i nuovi file.
- Manifest comune `19/integrated` identica alle315sorgenti già compilate/confrontate in `18/native-integrated` (898501e2b473b1aee7ed84e4d860cb62fda2796589cebf36d08db3f33c886dd8); tutti i file coincidono con il checkout al controllo. `composition.json` dichiara esplicitamente il riuso delle build per identità sorgenti, senza attribuire una nuova compilazione. Root rinnova full FLEX da questa closure.
- Minimo caller Apply_Mass_Inverse:2check chiusi,7aperti,13warning. Include due eccezioni numeriche previste e obblighi di trasporto forma/dominio/Lower_Valid/inizializzazione; non è Gold del chiamante. Nessuna restrizione artificiale degli ingressi né soppressione introdotta per chiuderlo.
- Snapshot separata `19/adapter02`: lemma Ghost Ancestor_Rows.Row_Properties28check chiusi (contiguità/ordine dall’invariante esistente), Copy_Row78check chiusi (copia per componente, reciprocità FP, colonne ordinate e inizializzazione per prefisso). Zero aperti/warning in entrambi. Nessuna scansione runtime o azzeramento aggiuntivo; nuova composizione Pack ancora in prova e fuori produzione. Le ricevute LDL/FLEX precedenti non si estendono a questo refactor non integrato.

## Checkpoint 41: rinnovo equality con fattori Ada reali

- Congelati senza modifiche i tre driver equality/constrained; connect/weld eseguito con gli stessi3campioni×30passi e tolleranze precedenti, senza fattori C nell’ingresso. Validation e release passano766/768 confrontabili (r72:755/768), più i medesimi due modelli PGS-shared instabili che Ada interrompe con Numeric_Limit mentre C avvisa/resetta QACC.
- Tutti XML, MJB e input sono byte-identici al corpus r72. Record dei due profili identici e output dei modelli completati byte-identici; i backtrace dei due abort non sono confrontati come dati numerici. Fonte `19/equality-profile-comparison.json`, manifest comune898501e2b473b1aee7ed84e4d860cb62fda2796589cebf36d08db3f33c886dd8.
- Chiusi11dei13scarti numerici. Restano solo qfrc dei due CG-weld-shared-0-10000.0 sample0: denso1,85619e-5, sparso3,25157e-5. J/aref/R coincidono; accelerazione, force e stato finale passano in tutti768casi confrontabili. Il miglioramento del corpus completo è distinto dal precedente replay diagnostico con fattori C; non chiude la compatibilità PGS recovery.
- Packaging standalone produttivo corretto per includere probe/unità Native_Inertia nella cattura delle sorgenti. Nuova build validation `19/production-solvers` e230/230confronti bitwise passano, senza cambiamenti dei byte runtime integrati.
- Refactor adapter resta separato: Copy_Row rinnovata78check senza warning, dopo sostituzione della richiesta Inline_Always non compilabile con Inline ordinario. Pack06 termina con136chiusi/3aperti, zero warning e rappresentazioni generate completamente; Pack05 aveva watchdog180s e03–05 anche una generazione parziale dovuta all’inlining. Sorgenti draft e ricevute preservati in `experimental/constrained-step/integration/native-mass-adapter-draft`; nuova scomposizione Ghost per il trasporto Lower_Valid in diagnosi. Nessuna nuova Gold globale o prestazione attribuita a questo refactor.


## Checkpoint 42: fattori reali e ordine del prodotto massa

- Esportazione diagnostica dei sei stati iniziali originali dei due CG-shared estremi: CSR, M, qLD e qLDiagInv Ada sono tutti bitwise uguali a C. Stdout ordinario del probe diagnostico identico al binario r19. Il campo Total esportato dopo Evaluate contiene già la forza vincolare; la ricevuta lo distingue da qfrc_smooth. Questa evidenza locale non viene estesa alle intere traiettorie. Fonte `19/factor-comparison2/results.json`.
- Audit C 3.14.0 mju_mulSymVecSparse: diagonale iniziale, poi triangolo inferiore in ordine inverso e scatter simmetrico. Il solver tradotto usava una somma crescente per riga. Ablation immutabile `19/symmetric-mass-ablation` cambia solo Multiply_Metric quando la struttura nativa è presente. Sul medesimo corpus originale di sei stati, il residuo CG denso sample0 diventa esatto per acc/force/qfrc; quello sparso resta aperto (qfrc3,48020e-5). Cinque campioni passano, uno fallisce alle soglie originali. Nessuna applicazione live o misura prestazionale.
- Prove adapter: Mapping_Row11 chiude26check e Finish_Lower13 chiude85, zero aperti/warning. La separazione di quantificatori logicamente equivalenti permette il trasporto dell’esatta mappa colonne; nessuna assunzione. Pack14 usa il lemma strutturale ed è ancora in diagnosi. Il nuovo dominio formalmente equivalente di Mapping_Row nella closure13 richiede il rinnovo minimo/intero prima di dichiarare la composizione chiusa.

- Seconda diagnostica acquisisce la forza originale prima dei vincoli, usando solo un hook del probe e confrontando stdout ordinario col controllo. Il solve C del medesimo RHS Ada coincide bitwise col free Ada in tutti6stati; il RHS sparse/sample0 differisce già di2,220446e-16 sul DOF7. Annullando i carichi esterni la differenza permane. Le sorgenti separano gravità/bias, ma questa osservazione non basta ancora per attribuire la differenza a una formula specifica. Ricevute `19/force-comparison` e `force-comparison-no-loads`.
- Pack14: watchdog180s senza report/conteggio. Pack15:129chiusi/3aperti, zero warning; restano inizializzazione/preservazione della mappa e una precondizione di Reciprocal nella specifica. Pack16 aggiunge al post la positività del fattore già garantita dal ramo runtime e riunisce inizializzazione e relazione per componente; verifica ancora in corso. Nessuna applicazione live del draft.

- Pack17 chiuso:152check, zero aperti/warning,212,4s; inizializzazione dei prefissi, mappa per componente, reciproci FP e Lower_Valid dimostrati sotto il dominio dichiarato. Aggiunta al post la positività dei diagonali già garantita dall’ammissione, e reso esplicito il legame fra fine riga e prefisso inizializzato. Pack16 aveva131chiusi/2aperti. Intera unità e chiamanti ancora da rinnovare; nessuna produzione alterata.
- Diagnostica con qvel e carichi esterni azzerati: RHS e free diventano bitwise esatti in tutti6stati. Insieme alla prova con soli carichi annullati, circoscrive il residuo smooth al percorso che dipende dalle velocità; non stabilisce ancora quale operazione RNE lo causa. Ablation combinazione gravità/cacc in build distinta.


## Checkpoint 43: origine del bias e composizione del fattore

- Intera unità adapter17 termina con 340 controlli chiusi, una preservazione della relazione Inverse/Reciprocal aperta per timeout e 24 warning di parentesi negli indici interi. Copertura completa delle cinque entità, nessuna assunzione. Pack minimo17 resta 152/152 senza warning; questa ricevuta non viene elevata a Gold dell’intera unità. Variante19 esplicita il raggruppamento e la relazione appena prodotta da Copy_Row, ancora in prova isolata.
- Ablation RNE: porre -gravity nell’accelerazione del mondo e disattivare soltanto la vecchia forza gravitazionale separata rende RHS originale e accelerazione libera bitwise esatti C nei sei stati. Il residuo sparso sample0 diventa esatto per tutti i campi iniziali esportati; quello denso mantiene il vecchio errore Multiply_Metric. Fonte `19/rne-gravity-comparison/results.json`. È una diagnosi causale iniziale, non una correzione pubblicabile: il toggle altererebbe il significato delle API Gravity_Force/Velocity_Bias, quindi non è applicato alla produzione.
- Inventariati consumatori runtime e contratti di Gravity/Bias, inclusi lifecycle Force_Buffers, Total_Forces_Buffers, noslip, inverse e derivate. La soluzione deve conservare le due quantità diagnostiche e aggiungere un lettore del bias completo C. Il percorso fisico dovrà usare `(Passive - Full_Bias) + Applied + Actuator` nell’ordine C. Kernel separato MJ.Force_Composition preparato; prove minime/composizione ancora da eseguire.
- C esegue una sola RNE per passo. Prima di introdurre una seconda passata obbligatoria, si studia diagnostica su richiesta con readiness esplicita: Force_Value è attualmente read-only e richiede Passive_Current, perciò l’eventuale cambiamento di readiness va dichiarato e coordinato con i consumatori. Nessuna forza omessa, nessun nuovo benchmark sotto carico e nessuna equivalenza universale dedotta dai sei stati.

- Kernel MJ.Force_Composition integrato come nuova unità indipendente dopo minime Smooth_Total10/Compose30 e intera unità42 chiuse, zero aperti/warning e copertura completa. Specifica FP esatta del totale C, inizializzazione/relazione per componente e rifiuto se il risultato supera il dominio del chiamante. Validation/release198/198 bitwise contro mju_sub e le due mju_addTo C; output identici fra profili. Ricevute in `experimental/smooth/evidence/recovery-20261003-force-composition`. Il percorso Step non lo usa ancora: il bias completo e i consumatori rimangono da comporre; nessuna prestazione nuova attribuita.
- Chiarimento API dal coordinamento: preservare disponibilità di Gravity_Force/Velocity_Bias dopo Evaluate, senza nuovi Stale_Results o precondizioni. La proposta con readiness obbligatoria è scartata; restano cache diagnostica facoltativa con fallback puro e riferimento a doppia passata da tenere fuori produzione fino alla verifica del costo. Pack19 chiude159check e l’inverso, ma resta una mappa colonne finale aperta;20 estrae soltanto un lemma Ghost per quel trasporto.


## Checkpoint 44: riferimento Full_Bias senza cambiare i getter

- Frozen `19/full-bias-reference03` compila validation: nuovo buffer Full_Bias con allocation/reset/free in entrambi i costruttori, lettore Full_Bias_Value e totale C. La vecchia RNE diagnostica resta distinta e invariata; è deliberatamente un riferimento a due passate, fuori produzione e senza prestazioni attribuite.
- Sei stati originali: accelerazione libera esatta C in tutti6; sparse/sample0 ora acc/force/qfrc esatti. Il bias completo stesso conserva tre differenze massime dell’ordine1e-18, quindi non si estende l’esattezza del RHS a ciascuna componente. Replay6×30:5/6 completi; resta solo qfrc denso/sample0 del vecchio Multiply_Metric. Tutti6stati finali passano alle tolleranze originali.
- Controllo vecchi getter: build r19 con solo exporter test, nessun runtime mutato. Gravity_Force e Velocity_Bias byte-identici al riferimento nuovo in tutti6stati; Get_Forces e Force_Value sono entrambi disponibili/coerenti dopo Evaluate. Fonte `19/bias-api-preservation03/results.json`.
- Minimo Total_Forces_Buffers:25check chiusi, zero aperti,12warning ricorsivi preesistenti. Fill02 non genera obblighi per un errore SPARK preesistente: uso Initialized su Velocity in-out ordinario. Reference04 rimuove quell’attributo ridondante (inizializzazione già implicita), preservando i bounds, e specifica il buffer Full_Bias iniziale bounded già fornito da Zero_Forces; minimo in corso, runtime03 non ereditato come verifica04.
- Patch/manifest/dati reviewable in `experimental/smooth/integration/full-bias-draft`. Nessuna applicazione live dei parent, nessuna modifica API obbligatoria, nessun timing. Il lettore è RNE completo: il contributo mj_tendonBias rimane distinto, nullo nel dominio oggi ammesso (armature spaziali non nulle rifiutate; armature fisse a Jacobiano costante).

- Fill04 ha rivelato due E0007 sulle dimensioni degli array locali dipendenti da D in-out. Reference05 congela Nv/Nb in costanti locali: minimo terminale26check chiusi, un solo post Stable_Ready in timeout, sei warning conservati. Is_Ready, frame stato/input/configurazione e preservazione Gravity/Bias risultano chiusi. Reference06 aggiunge solo il lemma Ghost Ready_Properties già esistente dopo Prepare/pubblicazione; prova in corso. Nessun parent produttivo cambiato.

- Riferimento03 esteso senza nuova build:634/634 validation (rigidi106, forze452, tendini76), stessi driver/input/soglie. Nessuna nuova evidenza release o prestazionale. Fill06 chiude27check ma lascia due obblighi (pre Ready_Properties dopo la scrittura e frame State_Values); variante07 separa Publish_Full_Bias per provarne la pubblicazione prima del caller, senza modificare i calcoli.

## Checkpoint 45: pubblicazione provata e movimento privato in composizione

- Publish_Full_Bias08:15check chiusi, zero aperti, quattro warning dei modelli conservati. Prova esatta della copia, bounds e frame/readiness; non è una prova dell’intera RNE. Variante07 aveva watchdog240s senza report;08 conserva i contratti e mantiene opaca soltanto Configuration_Valid sugli input immutati.
- Fill09:18chiusi/8aperti dopo eccessiva opacizzazione delle query di readiness;10 riduce quei soli Hide_Info, ancora da provare. La pubblicazione08 rimane identica nei byte. Nessun obbligo soppresso.
- Draft movimento12: nuovo child privato Movement seleziona Compute_Physical nello Step constrained/Euler; Forward.Evaluate pubblico conserva i diagnostici. Cleanup sui fallimenti prima di Invalidate esegue soltanto il produttore Gravity/Bias, preservando le forze passive aggiunte dai caller. FE/SDF/advanced sono inventariati e ancora da collegare con i rispettivi owner. Nessun flag persistente nuovo in Simulation.
- Compute_Physical11 minimo termina al watchdog180s senza report/conteggio. Build validation12 e test preparati di clock overflow, disponibilità scalar/bulk, preservazione bitwise dei diagnostici e delle forze passive aggiuntive, retry/reset/free; nessun esito anticipato. Patch e manifest in experimental/smooth/integration/full-bias-draft. Tutti i parent runtime restano fuori produzione.
- Adapter23 aggiunge prefisso funzionale e Append_Row:24check chiusi, una relazione colonne aperta, zero warning. Runtime Pack resta la variante precedente; il nuovo helper non è integrato. La relazione globale fattore→soluzione rimane aperta.

- Movement12 build validation e634/634 differenziali passano. Nuovi lifecycle3/3: free6DOF, hinge/fluid1DOF, catena3DOF senza gravità. Clock overflow dopo valutazione fisica conserva stato e getter G/B bitwise; cleanup conserva esattamente il carico passivo aggiunto, Full_Bias/Total/Acceleration e status. Retry/reset/free passano. Fixture originarie con warmstart/island attivi rifiutate dal dominio preesistente e preservate; fixture2 dichiara i flag ammessi, senza allargare le soglie. Release della medesima closure in build; non è un benchmark.

- Release movement12 fresca completata sul medesimo manifest1e139937898e75cca3f590f03abd08e4737e5d83450dd198fe9e39329e20cde2:634/634C e3/3lifecycle; tutti i record numerici identici validation/release. Il nuovo percorso è ancora draft e non assorbe i caller FE/SDF/advanced. Minimo Complete_Diagnostics in corso24910, guard300s; previsti anche i test esistenti di activation/capacity prima dell’integrazione.


## Checkpoint 46: diagnostici sui fallimenti e frame fisico

- Complete_Diagnostics12 termina con14 controlli chiusi e6 aperti (readiness e dereferenziazioni conseguenti), cinque warning conservati. Il toggle temporaneo Passive_Valid perde i bounds delle forze passive nei contratti dei vecchi helper; non è stato mascherato con assunzioni.
- Nuova closure movement13 separa il calcolo read-only locale dalla pubblicazione: Publish_Diagnostics chiude28 controlli, zero aperti, quattro warning preesistenti. Specifica copia esatta di G/B, cache invariata e preservazione Passive/Full_Bias/Actuator/Total/Acceleration. Minimo Complete_Diagnostics13 avviato11901, watchdog240s; caller e runtime13 non ancora accettati.
- Test esistenti activation/capacity sul runtime12:3/3 per profilo, inclusi entrambi i rami actearly e overflow capacità dopo valutazione; stato atomico e recovery passano. Si aggiungono ai634/634C e3/3lifecycle di ciascun profilo senza cambiare sorgenti né tolleranze.
- Patch e manifest13, ricevute dei minimi e test edge archiviati in experimental/smooth/integration/full-bias-draft. Tutte le modifiche Full_Bias/Movement rimangono snapshot non applicate alla produzione; nessun benchmark nuovo.

- Complete_Diagnostics13 termina al watchdog240,1s/RSS1026MB, senza report o conteggi. Avviato batch73952 di minimi separati dei tre preparatori nella closure14; le clausole aggiungono solo la preservazione fisica già rispettata dai corpi, non nuove restrizioni d’ingresso. Draft15 aggiunge test-only lo stesso lifecycle attraverso Euler.Step pubblico; nessuna prova o numerica15 anticipata.

- Spatial.Prepare14 chiude38 controlli, zero aperti/warning, includendo il nuovo frame. Entrambi i minimi Pipeline14 emettono invece un errore di legalità SPARK preesistente in Build_Bodies (record locale prima del loop invariant), zero VC numeriche; non sono conteggiati come prove. Draft16 sposta soltanto la dichiarazione C fuori dal ciclo e mantiene l’assegnazione e le operazioni nello stesso ordine, più test Euler15. Batch69288 rinnova i due minimi sul nuovo snapshot.

- I due minimi Pipeline16 superano la legalità e raggiungono entrambi watchdog240s senza report/count. I nuovi frame restano aperti; nessuna Gold ereditata. Avviato il rinnovo runtime16 validation/release con i634 confronti e lifecycle constrained/Euler più activation/capacity. Separatamente draft17 divide le fasi private prima dell’attuazione/solve per consentire un’unica risoluzione FE futura; non compilato né collegato ai FE live.


## Checkpoint 47: runtime dei diagnostici rinnovato nei due dispatch

- Closure movement16 validation compilata:634/634 confronti C, invariati driver/input/tolleranze. Tre fixture lifecycle eseguono ora ciascuna sia constrained.Step sia Euler.Step, per6percorsi: disponibilità/getter bitwise su errore clock, frame fisico, retry/reset/free passano;3/3 activation/capacity passano. Release identica in build, handle10955.
- La correzione del record locale permette di generare le prove Pipeline, ma i due minimi16 sono ancora watchdog240 senza report. Spatial.Prepare14 rimane38check chiusi; Publish_Diagnostics13 rimane28 con4warning. Nessuna Gold di composizione dichiarata.
- Draft17 separa fasi private Prepare_Physical (pose,massa,RNE/passive) e Complete_Physical (attuazione,totale,solve). FE potrà inserire l’elasticità tra le due senza il secondo solve oggi presente, mantenendo Forward pubblico e cleanup su errore. Sorgente17 è ancora non compilato e non usato da FE; nessuna prestazione attribuita.

- Release16 termina sullo stesso manifest2ea848556afa7a79f74277e5a574420e8f80eb21574d874d631d90fe889744c0:634/634C,6percorsi lifecycle e3edge passati per profilo; tutti i record numerici validation/release identici. Disponibile per ablation consumer frozen (root/services notificati), non applicata live e senza prestazioni attribuite. Minimo nuovo getter Full_Bias_Value avviato65822; i caller aperti restano distinti dalla ricevuta runtime.

- Full_Bias_Value16 minimo:5controlli chiusi, zero aperti,6warning Sqrt propagati e conservati. La prova riguarda il getter e i suoi limiti, non il valore fisico della RNE. Cleanup16 ora in diagnosi per-VC1s/watchdog300, handle75606; prima della nuova build17 saranno provati i wrapper di fase minimi.

- Diagnosi Complete_Diagnostics16 terminale185,3s:22controlli chiusi,10aperti,6warning. Aperti due pre di forma (lunghezza Jacobiano e Gravity.Last),5dereferenziazioni del post, readiness e2inizializzazioni G/B condizionate dal flag Used. Prossimo intervento proposto ma NON scritto: separare l’uscita ricorsiva riuscita dalla fallback densa, così ogni pubblicazione è dominata dalla propria inizializzazione, più helper minimo di invalidazione cache. Nessuna nuova inizializzazione runtime artificiale.
- Pausa richiesta dal root dopo get_goal=paused. Tutti i job dynamics terminali (ultimo75606); nessuna nuova build/prova/integrazione avviata. Ultimo runtime accettato rimane movement16 fuori produzione;17 private-stage è solo draft non compilato. Ricevute conservate, nessun timing nuovo.
