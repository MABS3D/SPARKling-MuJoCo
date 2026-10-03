# Ripresa collision — 2 ottobre 2026

## Checkpoint 1: ripartenza da BVH/scena

HEAD iniziale: `2b601cc27e1f5d46a0708b1d90646a08e1d9aec2`.
Preservate modifiche locali. Nessun commit/push/reset. Riferimento corrente: MuJoCo 3.14.0; nessuna migrazione introdotta.

| Lavoro | Stato | Prossimo passo |
| --- | --- | --- |
| R02 costruzione/attraversamento BVH | Codice e invarianti già presenti; prove in /var/tmp recuperate, scope da consolidare | Riprendere sottoprogrammi minimi e unità completa |
| R11 mesh/heightfield nello step | Asset e collegamenti constrained-step già presenti | Coordinare verifica dello step con dynamics |
| R12 BVH scena | Collegamento mj-rigid_bvh già implementato; recuperata ricevuta precedente 138 casi senza errori | Nuova build congelata validation/release e regression |
| R13 stato/collisioni flex | Stato, adapter e harness già presenti | Build congelata; prove kernel e confronti C |
| R17 SDF simulazione | Child entry, asset/scene e harness già presenti | Build congelata; confronto C del passo |
| R19 elasticità/flessione flex | Kernel e child entry già presenti | Prove kernel minime poi unità completa; confronto C |

Ripartenza concreta: harness di build/prova collisioni aggiornati a `-j1` (common rigid, build flex-state/flex-elasticity/SDF e prova flex-elasticity). Guardia memoria/tempo conservata. Le prove, i test numerici e le prestazioni restano evidenze distinte; nessun benchmark conclusivo sotto carico concorrente.

Ricevuta pre-crash R12: `/var/tmp/sparkling-scene-bvh-20261002-1790970393888/delivery-compounds/results.json`, 138 casi / 130 native / 118 frame BVH attivi; da ricontrollare sullo snapshot attuale. Non estesa automaticamente alle sorgenti correnti.

## Checkpoint 2: R12 numerica ripetuta

Snapshot `/var/tmp/sparkling-recovery-collision-scene-20261002`: build validation e release riuscite con guardia e `-j1`. Manifest SHA-256 della chiusura e dei binari salvato. Nessuna modifica alla chiusura rigid durante la verifica.

Regressione `/var/tmp/sparkling-recovery-collision-scene-checks-20261002/results.json`: **138/138** casi, **130** confronti native C, **60** frame BVH attivi, nessuna differenza nell'ordine o nei campi completi Ada baseline/validation/release. Le variazioni del contatore BVH rispetto alla ricevuta pre-crash riflettono lo snapshot corrente; i contatti restano identici. `Merge_Bounds`, `Append_Id` e flow dell'unità chiusi; prova globale ancora diagnostica.

R02 in implementazione: invarianti di `Refit_Shaped` spostati prima della modifica del nodo per esplicitare la conservazione topologica anche nelle uscite anticipate; separate proprietà di foglia e contenimento, con validità locale prima delle precondizioni geometriche. Verifica della modifica in avvio, nessuna pretesa Gold nuova finché non chiude.

R11/R13/R17/R19: prossimo lavoro invariato dal checkpoint 1. Non modificati file centrali posseduti da dynamics.

## Checkpoint 3: costruzione BVH e confine della prova

Snapshot `/var/tmp/sparkling-recovery-collision-refit-20261002`: `Work_Fits` **9**, `Schedule` **43**, `Build` **88**, wrapper `Refit` **11** obblighi chiusi. Le ultime due sono prove modulari che dipendono dal contratto di `Refit_Shaped`: **non** stabiliscono ancora la Gold globale della costruzione/refit.

`Refit_Shaped` è passato da quattro diagnostiche residue a due sul contenimento, con conservazione topologica e validità ora chiuse. `Traverse` conserva tre diagnostiche sull'inizializzazione del prefisso dei risultati. Unità completa in diagnosi limitata. Aggiunto helper `Set_Bounds` con contratto esplicito di conservazione degli altri nodi; questa ulteriore variante deve ancora essere provata.

Release ufficiale ricontrollata oggi dagli altri agenti: confermata 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

R19: recuperate regressioni pre-crash: forze/accelerazioni iniziali coincidenti in 18 campioni ma traiettorie divergenti, e 16 modelli con flessione fallivano un precontratto di layout. Lo snapshot corrente ha correzioni successive non ancora coperte da quelle ricevute; prossima azione build corrente e ripetizione del corpus, senza attribuire gli errori vecchi al codice attuale.
R13: ricevute pre-crash 304/304 geometria e 8/8 policy; ancora da riverificare sulla chiusura aggiornata.
R11: richiesto a dynamics il checkpoint compare_assets/prove_assets, perché il collegamento è nei suoi file centrali. R17: build e corpus completo SDF restano il passo successivo a flex.

## Checkpoint 4: R19 elastico integrato passa il corpus corrente

Snapshot `/var/tmp/sparkling-recovery-flex-elasticity-20261002`, build validation in 70.5 s, picco gruppo 453 MB, `-j1`. Confronto `/var/tmp/sparkling-recovery-flex-elasticity-numerics-20261002/results.json`: **75/75** campioni su 25 modelli, **100 step** per traiettoria, nessun errore. Copre membrane stretch/bend/both, pinned/rotated/shared, tetra/slides/free, multipli, edge chain, flag spring/damper e muscle. Forze/velocità/accelerazioni/stato completo controllati a tolleranza 2e-10. Correzioni pre-crash presenti nel sorgente hanno chiuso le vecchie regressioni del corpus; nessuna tolleranza allargata.

Ricevute copiate in `experimental/flex-elasticity-integration/evidence/20261002-recovery/`. Le dipendenze cambiate dopo lo snapshot sono riportate in `scope.json`; l'evidenza resta della chiusura congelata. Prossimi passi: release sullo stesso snapshot, kernel minimi e unità completa. Questo è il passo elastico senza contatti: collisioni flex/solver composito ed elasticità interpolata rimangono da comporre.

R02 seconda variante: helper Set_Bounds e inizializzazione del prefisso separata dai predicati di appartenenza; diagnosi in `/var/tmp/sparkling-recovery-collision-refit2-20261002`. R11/R12/R13/R17 come checkpoint precedenti.

## Checkpoint 5: riproduzione R11 e chiusura scalare R19

**R11:** differenze del corpus step localizzate nella trasformazione quaternion→matrice, prima della narrow phase. Lo stesso `contact_probe` frozen con pose C produce zero differenze in 90 frame di tre casi falliti; sostituendo solo le matrici con la formula Ada originaria si riproducono gli stessi contatti divergenti (leva circa 0.023 nel caso mesh). Patch/contratto consegnati a dynamics, proprietario di `smooth`, in `experimental/rigid-collision-candidate/integration/rotation-c-formula.patch`; dynamics ha applicato il cambiamento e chiuso 155 check proof + 2 flow della funzione Rotation. La regressione dello step completo attende la sua nuova build dopo il collegamento delle equalities.

Aggiunto `tests/replay_geom_composition.py` nel candidato rigid: su geom locali ruotati di 0.37 rad, il prodotto delle matrici differisce dalle pose C di 4–5e-16 e cambia i contatti in 10/30 frame heightfield/mesh e 1/30 heightfield/cylinder; composizione quaternion poi matrice coincide esattamente con le pose C e passa tutti 90 frame. Risultati/MJB/input/output/hash: `/var/tmp/sparkling-recovery-geom-composition-local2-20261002`. Il flag compilato `geom_sameframe` viene aggiornato coerentemente quando il replay ruota il geom. Nel corpus originario tutte le rotazioni locali erano identità; nessun errore dopo la formula diagonale C nel replay isolato. Diagnosi trasferita a dynamics senza modificare file centrali.

**R19:** release dello snapshot del checkpoint 4 passa anch'essa 75/75 campioni, 100 step. Prove mirate a timeout 10 s chiudono Damping_Elongation (20) e Bending_Row (19). Due asserzioni sui limiti delle somme parziali, senza cambiare l'ordine aritmetico, chiudono Tension (51) nel secondo snapshot `/var/tmp/sparkling-recovery-flex-elasticity2-20261002`. Corrette inoltre le allocazioni SPARK nell'integrazione: default espliciti delle componenti Storage e array vuoto inizializzato. Build validation passata; prove unità/flow e regressione post-modifica ancora in esecuzione. Il primo flow aveva 2 errori SPARK E0019, quindi non era una ricevuta di successo.

**R02:** Set_Bounds (10), Push (21), Emit (42) chiusi. Refit_Shaped mantiene due obblighi aperti; la separazione sperimentale delle clausole Initialized in Traverse è stata ritirata perché aumentava le diagnostiche. Rimangono da verificare numericamente gli invarianti di refit finali e da chiudere costruzione/traversal globali.

**R12:** invariato, 138/138 numerica; prova globale ancora aperta. **R13:** ancora da ripetere la chiusura corrente (304/304 + 8 policy sono ricevute precedenti). **R17:** predisposto runner di prove scalari/unità/flow e salvataggio incrementale del corpus con timeout registrati; build/corpus corrente restano da eseguire. Nessuna dichiarazione di parità prestazionale o port globale completo.

## Checkpoint 6: R19 kernel completo, limiti integrazione espliciti

`/var/tmp/sparkling-recovery-flex-elasticity-proof2-20261002`: **intera unità scalare 145 check chiusi, zero aperti**, timeout 10 s/check, tre prover, guardia e -j1. Dopo le inizializzazioni allocatori e le asserzioni di Tension, il corpus validation ripetuto passa nuovamente **75/75**, 100 step (`/var/tmp/sparkling-recovery-flex-elasticity2-numerics-20261002`). Copiate ricevute/hash/prova e README nel candidato.

Il flow dell'integrazione ora supera i vecchi errori di allocazione ma espone **17 diagnostiche** (rinominazioni attraverso accessi variabili e inizializzazione Trace) più 81 warning. Non è chiuso. Le prove dei kernel non si estendono al loader o al passo composito; resta lavoro di contratti/ownership/flow. La release precedente non copre le ultime modifiche allocator/assert.

R02: avviato harness numerico completo validation/release sulla variante finale del refit in `/var/tmp/sparkling-recovery-advanced-numerics-20261002`. R11: replay locali ruotati consegnati a dynamics; R12 invariato; R13 e R17 prossimi snapshot della coda.

## Checkpoint 7: R02 e R13 numerica corrente

R02 `/var/tmp/sparkling-recovery-advanced-numerics-20261002`: **2425/2425 confronti C** e **3969 casi limite union BVH**, sia validation sia release. Include 24 casi refit e 96 traversal-pairs. Copertura numerica riuscita della variante finale; le prove globali di refit/traversal restano aperte.

R13 `/var/tmp/sparkling-recovery-flex-state-20261002` e `...-cases-20261002`: build validation riuscita; **312/312** campioni di geometria/contatti, **8/8** policy d'ammissione/capacità. Il corpus contiene ora 39 modelli (8 campioni), rispetto ai 38 della vecchia ricevuta. Prime prove Component (15), Point (9), Rotation_Component (14) chiuse; Compose a loop supera la guardia 180 s. Avviata variante con nove componenti esplicite, stesso ordine aritmetico, da provare e ricompilare. Runner aggiornato a leggere report `.spark`, usare snapshot congelati e restituire failure anche per flow aperto, senza dipendere da messaggi testuali legacy.

R11 dopo diagonali C: dynamics riporta **118/126** nel corpus step (prima 109/126). Replay 90 stati C identici ora senza divergenze fisiche: massimo accelerazione 8.6e-14, forza generalizzata 2.1e-12; gli otto fallimenti sono traiettorie multiple, da investigare senza allargare tolleranze. La composizione quaternionica dei geom è in lavoro da dynamics. R12 invariato. R17 dipendenze constrained compilabili confermate da root, nuova build segue R13. R19 preparata separazione dei parametri rigid state/storage nei calcoli elastici per rimuovere rinominazioni SPARK illegali senza copiare le grandi catene topologiche; variante ancora da compilare/provare/testare, ricevute checkpoint 6 restano dello snapshot precedente.

## Checkpoint 8: SDF integrato, errore C ridotto e flow flex chiuso

R17 build `/var/tmp/sparkling-recovery-sdf-20261002` riuscita in 97 s, picco 457 MB, con chiusura SHA-256 stabile al congelamento. Il child usa ora `Generate_Geom_Poses` condiviso con constrained: stessa composizione quaternion, SameFrame e pose inerziali, senza duplicare il calcolo corretto da dynamics.

Corpus isolato per processo `/var/tmp/sparkling-recovery-sdf-isolated2-20261002`: 23 modelli tentati; 35/42 campioni confrontati passano, 9 failure totali incluse ammissione plane/SDF e reference mesh/SDF. Tolleranze invariate. Il runner ora salva input prima dell'oracle, conserva risultati incrementali e registra abort/timeout del singolo modello; nessun failure viene convertito in pass/skip. La nuova modalità isola anche la sequenza casuale per modello (seed fisso 261002): le ricevute precedenti non sono numericamente identiche a questa nuova estrazione.

**Errore del riferimento, non pass Ada:** `native_replay.c` riproduce in C puro con la libreria ufficiale 3.14.0 sia da XML sia da MJB il messaggio `collisionTask`: sei contatti contro un budget di quattro. Riduzione in `evidence/20261002-recovery/native-mesh-sdf/reduced/tetra-1.xml`: cubo SDF + tetraedro di quattro vertici, forze e velocità zero, zero step; `mj_forward` restituisce due contatti contro budget uno. Con initpoints=4 il controllo completa. Hash libreria/commit/input, sorgente C e log conservati. La collision driver `mj_maxContact` restituisce `sdf_initpoints` per ogni pair SDF, mentre mesh/SDF campiona più facce. Il punto esatto dell'eventuale corruzione heap nella gestione Python non è ancora attribuito; il fallimento nativo del budget è confermato.

Correzioni Ada SDF in preparazione: bounds conservativi C del piano (1e10) ammessi separatamente dai proxy finiti (1e9); ordine della coppia per tipo mantenuto fino a Finalize, per evitare una ricostruzione diversa dei tangenti e delle righe piramidali PGS. Nuovo dump opzionale dei contatti nel probe. Queste modifiche devono ancora essere ricompilate e confrontate.

R13 fix alias: Append riceve parametri materiali già combinati, evitando alias tra input Material e lo stato mutato. **Flow completo dei due moduli chiuso: 66 check, zero aperti, 15 warning** in `/var/tmp/sparkling-recovery-flex-state-proof2-20261002`. Non è una prova funzionale end-to-end. Compose resta in diagnosi: vecchie varianti loop e aggregato con quantificatori superano 180 s; ora relazioni e precondizioni delle nove componenti sono esplicite, stesso dominio e ordine aritmetico, da riprovare. R02/R12 e R19: ricevute precedenti restano valide soltanto per i rispettivi snapshot; refactor storage R19 ancora da verificare.

## Checkpoint 9: R17 chiude i difetti Ada del corpus, resta il riferimento

Snapshot `/var/tmp/sparkling-recovery-sdf3-20261002`: **44/44 campioni confrontabili** su 22 modelli e 30 step; il ventitreesimo modello mesh/SDF resta failure nativo prima del confronto, con riproduttore C minimo. Exit complessivo correttamente 1, non un falso pass. Nessuna tolleranza allargata. Corretti ordine C della coppia/frame, gradiente nullo finito del box sulla superficie, e caricamento dei poligoni compilati per il manifold plane/SDF.

Prova helper scalar/unità: 8 check chiusi. Flow completo scena **27**, step **29**, zero aperti, 19 warning ciascuno. Prove di sicurezza/funzionali complete scena/step ancora da sviluppare. Copiate evidenze nel candidato. Avviata traiettoria 100 step sulla stessa chiusura, poi release; nessun benchmark conclusivo.

R13 intera unità trasformazioni **59 check chiusi**, zero aperti; flow adapter/stato **66**, zero aperti. La specifica di Compose enumera componenti/precondizioni equivalenti al dominio precedente: è bastato evitare quantificatori per portare la prova minima da timeout a 17.6 s. Ricevute finali (`...flex-state4...`) **312/312** numerica e **8/8** policy; salvate nel repository. Prove end-to-end e risposta dinamica dei contatti flex restano separate e aperte.

R19 refactor storage snapshot3 mantiene **75/75** su 100 step; diagnostiche flow ridotte da 17 a 7. Implementato successivamente trasferimento esplicito dell'ownership temporanea (saved/empty/M senza alias) e inizializzazione dei workspace; variante4 in verifica. R02/R12 invariati; R11 ultime suite e revisione simple-DOF/solver gestite da dynamics.

## Checkpoint 10: 3 ottobre, flow elastico chiuso e passaggio temporaneo

**R19:** build fresca `/var/tmp/sparkling-recovery-flex-elasticity5-20261003`, senza copiare binari. Trasferimento esplicito degli array flex e dei nomi durante detachment/Restore; array temporanei e workspace inizializzati. **75/75 campioni, 100 step**, tolleranze invariate. **Flow completo integrazione 81 check chiusi, zero aperti, 89 warning** (`...flex-elasticity-proof5-20261003`). Unità scalare invariata rispetto ai 145 check del checkpoint 6. Ricevute copiate. La variante4 aveva fallito la compilazione per aggregato eterogeneo `(others => null)`; il confronto partito sul binario copiato della variante3 è esplicitamente invalidato per variante4. Corretto con default aggregate `(others => <>)`, poi compilato e testato realmente nella variante5. Prova funzionale completa ed elasticità con contatti restano aperte.

**R17:** stessa chiusura sdf3 passa **44/44 confrontabili anche a 100 step**, con failure separato del riferimento mesh/SDF. Ricevuta e README aggiornati. Preparato `/var/tmp/sparkling-recovery-sdf3-release-20261003` contenente soltanto sorgente/manifest congelati: build release **non ancora avviata**. Serve compilare quel progetto direttamente con SDF_MODE=release senza aggiornare dipendenze, poi corpus 100 step e prova scena/step limitata. Il bug C puro è pronto per review indipendente; riproduttore e riduzione nel candidato, originali completi in `/var/tmp/sparkling-recovery-sdf-native-20261002`.

**R02:** timeout 10 s/check non chiude i due obblighi Refit_Shaped né i tre Traverse, ricevuta `/var/tmp/sparkling-recovery-bvh-refit10-20261002`. Sorgente in variante successiva non ancora verificata: loop refit con cursore `Remaining` e suffisso già aggiornato; inizializzazione del prefisso Pair_Array espressa tramite slice Initialized, stessa proprietà funzionale. Processo attivo sessione **12527**, comando `tests/prove.py --out /var/tmp/sparkling-recovery-bvh-prefix-20261003 --scope bvh-refit-shaped --scope bvh-emit --scope bvh-traverse --topology-timeout 3`. Singolo processo pesante, -j1 e guardia. Non interrompere; esaminare ricevute prima di altro build/proof pesante. Necessaria nuova regressione advanced dopo questa variante e i quattro casi esatti gradiente box sulla superficie (atteso totale 2429 + 3969 union, validation/release).

**R11:** dynamics riporta r5, CG 254/254 chiuso grazie metadata simple-DOF; assets 116/126, variante geom locale ruotato 118/126. Resta lavoro di ordine aritmetico solver nel suo spazio. Nostri replay a identico stato C non indicano difetti residui narrowphase. **R12:** numerica 138/138, prova globale aperta. **R13:** 312/312 e 8/8 policy, kernel 59 e flow 66; nuova release e integrazione risposta contatti ancora da sviluppare.

Passaggio temporaneo richiesto da root per liberare uno slot al reviewer upstream. Nessun commit/push/reset; nessun processo annullato. File BVH `mj-bvh.adb/.ads` in modifica non ancora validata; gli altri cambi documentati hanno ricevute specifiche, mai estese automaticamente alle dipendenze concorrenti. Sessioni build/flow/numerica R19 tutte concluse; resta soltanto la prova BVH 12527.

## Checkpoint 11: release SDF e avvio movimento flex composito

R17 release sulla **stessa chiusura sdf3**, compilata senza aggiornare dipendenze, passa **44/44 a 100 step**. Il riferimento mesh/SDF resta abort -6 prima del confronto, quindi exit complessivo 1. La review indipendente upstream conferma il difetto stabile/main e conserva la proposta in `experimental/sdf-step/evidence/20261003-upstream-review`; nessuna patch applicata al riferimento dei nostri confronti. Prove complete `/var/tmp/sparkling-recovery-sdf-whole-20261003`: scena supera 2500 MB (picco 2565 MB, 46.6 s), step supera 180 s; exit 99, nessuna prova completa rivendicata.

R02 suite fresh `/var/tmp/sparkling-recovery-advanced-final-20261003`: **2429/2429 C differential**, inclusi quattro gradienti box sulla superficie, e **3969 casi limite union**, validation e release. La variante di refit con Remaining e Traverse con slice Initialized è numericamente verificata. Prove prefisso non chiuse (Refit_Shaped due, Traverse tre diagnostiche); il processo precedente terminato durante handoff non ha scritto manifest finale. Runner ora salva manifest/input hash subito e dopo ogni scope, per conservare una ricevuta parziale anche se interrotto.

R19/R13 implementazione composita in corso: `Force_Model` separa ownership delle forze elastiche da Simulation e condivide Evaluate_Model con l'entry senza contatti. Nuovo child `MJ.Data.Constrained.Flex` usa lo stesso Base.D, forze elastiche, geometria flex, endpoint reali dei corpi, solver ed Euler centrali. Primo dominio ammesso piano/vertice, con membrane/tetra/edge e contatti frictional; self/cross-flex/interpolazione sono esplicitamente rifiutati. Dynamics ha applicato metadata endpoint centrali e contratto del setter; SDF child aggiornato a inizializzare endpoint rigidi. Il primo build ha esposto la divergenza `Flex_Element` presente solo nel vendor avanzato: portati ammissione/support/radius nel candidato rigid, preservando il fix Prism del riferimento. Seconda compilazione in corso; nessuna nuova evidenza di movimento fino al confronto.

R11 resta di dynamics, con replay nostri conservati; R12 numerica 138/138 dello snapshot precedente, prova globale aperta. R13 precedenti 312/312 + 8/8 e flow66 restano del vecchio snapshot: la nuova API Update accetta pose geom globali opzionali per evitare di duplicare le correzioni quaternion/SameFrame del parent e deve essere ricontrollata. Nessuna estensione automatica delle prove precedenti alle modifiche d'integrazione.

## Checkpoint 12: movimento elastico + contatti integrato verificato

`/var/tmp/sparkling-recovery-flex-contact3-20261003`: nuova entry **MJ.Data.Constrained.Flex** compila e passa **54/54 campioni a 100 step** su 27 modelli. Una sola Simulation contiene stato, massa, forze passive elastiche, risposta di contatto e integrazione. Copre membrane stretch/bend, tetra e edge, pinned/free/shared, PGS/CG/Newton, condim 1/3/4/6, coni piramidali/ellittici, due piani, piano ruotato, margin/gap, muscle, frictionloss/limiti e flag contact/constraint. Confronta ncon/nefc, passive, qacc_smooth, qacc, qfrc_constraint e stato completo a tolleranza 2e-9. La prima variante estesa aveva 52/54: differivano soltanto i conteggi con constraint=disable. Corretto dispatch: come C non genera collisioni in quel caso. Nessuna tolleranza allargata.

Test endpoint eseguito dal probe per ogni modello: lato flex con geom=-1 valido; rifiuto atomico di Id fuori conteggio, body fuori dominio, geom-body incoerente e geom fuori intervallo. Dynamics sta provando formalmente il setter centrale. **Flow child completo 33 check chiusi, zero aperti (19 warning)**; **flow stato con pose globali opzionali 62, zero aperti (8 warning)**, sulla stessa chiusura. Il kernel elasticità riusabile mantiene **75/75 senza contatti a 100 step** e flow **83, zero aperti** sulla chiusura elasticity6. Non è ancora prova funzionale o di sicurezza end-to-end.

Build release della chiusura contact3 avviata separatamente, senza importare dipendenze correnti; numerica release ancora da eseguire. Evidenze copiate in `experimental/flex-elasticity-integration/evidence/20261003-integrated-contact`. Il confronto integrato richiede stack 128 MiB per gli attuali workspace statici; primo tentativo senza tale limite ha registrato Storage_Error prima del Create, non un errore numerico.

Dominio attuale esplicito: piani come unici geom, contatti flex-vertice con un corpo reale per lato; self/cross-flex, risposte agli elementi e interpolazione non sono ancora integrate. Il vecchio candidato cartesiano frictionless non viene usato in questo percorso. SDF release e advanced numerica come checkpoint 11; R11/R12 invariati. R02 nuova variante helper Set_Bounds esplicita il frame dei figli e asserisce Boxes_Valid alla fine del refit, **ancora da provare e verificare**. Aggiunti successivamente contratti statici al Force_Model (creazione/free/preservazione stato); le ricevute contact3 precedono questi soli contratti e non si estendono automaticamente alla revisione corrente.

## Checkpoint 13: regressione release isolata e Traverse chiuso

Il primo flex release passa solo 4/54 contro 54/54 validation: **failure conservato**, non nascosto. Verificati identici tutti 306 hash della chiusura sorgente. Primo punto diverso in Generate_Geom_Poses prima di collisione/solver: SameFrame=3 e posizione locale piano z=-0.01 corretti, posizione globale restituita errata/non inizializzata; accelerazione differisce di 25 nel caso minimo. Snapshot diagnostico `/var/tmp/sparkling-recovery-flex-contact-debug-20261003` mostra aref/contatti cambiati, elasticità e accelerazione libera uguali.

Riscrittura equivalente da espressione `RG.Vec (case ...)` a istruzione `case` con assegnazione in ogni ramo ripristina posa z=-0.01 e **release 54/54 a 100 step**, stesse tolleranze. Nessuna modifica ai rami/formule C. Patch consegnata a dynamics in `integration/geom-pose-case-statement.patch`; diagnosi compiler/lifetime resta inferenza, osservati dipendenza da ottimizzazione e risultato della riscrittura. Ricevute prima/dopo conservate. È ancora richiesta compilazione fresh ordinaria dopo applicazione centrale, senza helper diagnostico temporaneo.

R02 `/var/tmp/sparkling-recovery-bvh-frame-20261003`: **Traverse 100 check chiusi, Emit 36, Set_Bounds 20**, zero aperti. Quantificazione sul range fisico inizializzato elimina i timeout della trasformazione First+offset; contratto funzionale conserva membership delle foglie e distinzione dei self-pairs, non dichiara completezza universale dei contatti. Refit_Shaped conserva due obblighi sul contenimento; validità dei box chiusa. Esteso ora il frame dei figli anche al nodo appena aggiornato (non solo al suffisso) e avviata prova minima/refit/build su nuova chiusura `...bvh-refit-final-20261003`. R11/R12/R13/R17/R19 come checkpoint 12, con limiti di prova/scope invariati.

## Checkpoint 14: chiusura centrale allineata, flex release ordinaria verificata

R19/R13 nuova build ordinaria flex4 prende **258 sorgenti comuni con hash identici** dalla chiusura centrale r7 di dynamics, senza helper diagnostici temporanei. **54/54 campioni a 100 step sia validation sia release**, con record di errori numerici identici nei due profili. Tutti i 307 file sorgente congelati; manifest e ricevute copiati nel candidato. Conferma la riscrittura equivalente della posa; una causa specifica del compilatore o del lifetime resta ipotesi non ancora isolata. La closure include Newton denso, dominio warm-start aggiornato, endpoint reali e nuovi contratti Force_Model. Prove flow aggiornate in corso, sicurezza e funzionalità end-to-end restano aperte.

R02 helper Set_Bounds **48 check chiusi, zero aperti**, inclusa conservazione del contenimento dei nodi già aggiornati (`/var/tmp/sparkling-recovery-bvh-containment2-20261003`). Refit_Shaped ancora 64 check chiusi e due timeout su invariante/post di contenimento. Variante successiva esplicita i tre assi della funzione Contains, relazione identica e nessuna modifica al corpo di refit; deve essere verificata. Traverse100 chiuso soltanto sulla precedente closure documentata.

R11: dynamics r7 riporta 117/126 asset e geom locali, identici validation/release; i residui sono traiettorie a 30 step, campi fisici iniziali passano. R12 resta 138/138 dello snapshot documentato, prova completa aperta. R17 resta 44/44 confrontabili validation/release della vecchia closure sdf3 più failure separata C mesh/SDF: nuova chiamata endpoint richiede una regressione fresh sul centrale aggiornato. Prossima estensione R19: endpoint di elementi flex con pesi C inversamente proporzionali alla distanza, Jacobiano pesato e regolarizzazione; ancora nessun risultato attribuito a questa estensione.

Aggiornamento checkpoint 14: flow della stessa chiusura flex4 completato: child **33**, stato **62**, elasticità **83** check, tutti zero aperti, rispettivamente 23/8/90 warning. I warning restano registrati; flow non dimostra i contratti funzionali appena aggiunti.

## Checkpoint 15: risposta dinamica di elementi flex, prima verifica integrata

Nuovo child ammette primitive rigide oltre ai piani e genera anche le coppie rigid/rigid attraverso la scena centrale. Gli endpoint degli elementi flex usano pesi C inversamente proporzionali alla distanza, eventuale rimozione dell'ultimo vertice opposto coincidente, somma ordinata e normalizzazione. Il Jacobiano somma i corpi nell'ordine lato0 negativo/lato1 positivo, conserva gli antenati comuni e le ripetizioni dei corpi; la regolarizzazione usa invweight*weight lineare nello stesso ordine. Il ramo corpo singolo conserva l'algoritmo precedente.

Patch centrale **soltanto nello snapshot**, non applicata live: `integration/constrained-weighted-endpoints.patch`. Dynamics ne possiede l'integrazione e aggiungerà i contratti atomici. `/var/tmp/sparkling-recovery-flex-element1-20261003` compila contro la chiusura r7 con la patch registrata. **114/114 campioni a 100 step** in validation: i 54 precedenti e 60 nuovi su elementi edge/tri/tetra e primitive sphere/capsule/ellipsoid/cylinder/box, condim/coni/PGS/CG/Newton. Per i nuovi casi confrontati anche Jacobiano, aref e regolarizzazione, oltre conteggi/forze/accelerazioni/stato. Ogni modello nuovo deve generare un endpoint di elemento reale nel primo campione: nessun pass da fixture vuoto. Tolleranza resta 2e-9. Evidenze in `evidence/20261003-element-contact`.

Ancora da verificare corpi duplicati, antenati comuni, rigid/rigid simultaneo e profilo release della nuova estensione. Self/cross-flex e interpolazione restano rifiutati all'ammissione; il produttore è predisposto per i due lati ma non ne dichiara la copertura. Minime pesi: Inverse_Distance9 chiusa; Distance26+1 timeout overflow somma; Normalize23+1 timeout relazione funzionale; unità completa in corso. Prove precedenti non si estendono alla nuova closure.

R02 variante Contains a tre assi espliciti aumenta gli obblighi aperti (47+1 helper,58+8 refit) ed è stata ritirata conservando ricevute. Ripristinata relazione quantificata della variante Set_Bounds48 chiusa; ora aggiunte copie locali dei due box figli e asserzioni esplicite dopo Union_Box, **non ancora verificate**. R11/R12/R17 come checkpoint14. Terminato il prover attivo, pausa dei job pesanti richiesta dal coordinatore per misure integrate senza carico concorrente; il goal prosegue, nessuna evidenza prestazionale ancora nostra.

Aggiornamento checkpoint15: unità pesi completa termina con **73 check chiusi e 1 timeout** sulla relazione funzionale di Normalize; Distance si chiude in questa esecuzione d'unità, mentre la minima aveva un timeout separato. Finestra di benchmark: nessun nostro processo attivo. Analisi del driver C individua un obbligo d'integrazione ancora aperto: rigid/rigid e rigid/flex devono seguire l'ordine delle coppie body/flex, non una semplice append dei due produttori. I 60 nuovi campioni attuali hanno una sola primitiva statica e non coprono tale ordine; l'estensione mista sarà verificata con casi dedicati prima di dichiararne la copertura.

## Checkpoint 16: elementi con accoppiamenti e rigidi simultanei

`/var/tmp/sparkling-recovery-flex-element2-20261003`: **138/138 campioni a 100 step** in validation. I 24 nuovi campioni verificano vertici pinned/free, antenato comune (anche sul lato geom), corpi ripetuti nella lista pesata e rigid/rigid simultaneo con rigid/flex, su coni piramidali3 ed ellittici6. Confrontati J/aref/reg/forze/accelerazioni/stato. Il child ora fonde stabilmente le coppie per chiave body/flex, mantenendo allineati contatto, endpoint e pesi. Passano i rifiuti atomici Count0/5, peso0/negativo/>2, geom con lista non singola o peso non1, body invalido, e la transizione weighted→single. La patch centrale resta isolata; **256 sorgenti comuni invariati**, due file centrali modificati dalla patch registrata e resto nello spazio collision.

Flow completo child aggiornato **57 check, zero aperti,26 warning**. La seconda variante del kernel pesi conserva tre obblighi aperti (67 chiusi): asserzione sul limite della somma quadratica, overflow di un prodotto e relazione Normalize. Ricevute conservate; non si dichiara Gold del kernel. Preparata una terza variante con range intermedi espliciti e relazioni per ciascuna delle quattro componenti. Esteso il solo dominio sicuro Distance a 1e100, coerente con le posizioni di contatto ammesse: non è una restrizione per facilitare la prova. Deve ancora essere ricompilata/provata. La release element2 sarà compilata sulla closure già testata, prima di importare questa variante. R02 nuove asserzioni figli non ancora provate; R11/R12/R17 invariati.

Aggiornamento checkpoint16: **release138/138 a100step**, medesimi309 hash sorgente della validation e medesimi record di errori numerici. Flow stato aggiornato66check,zero aperti,8warning. Patch centrale consegnata a dynamics per integrazione successiva al dispatch sparse Newton; nessun claim sulla composizione centrale ancora da costruire. Prova pesi terza variante: Distance31 e Inverse9 chiuse, Normalize27+2 aperti su bound aritmetici, relazione funzionale ora chiusa; unità completa ancora in corso. In preparazione helper minimi Reciprocal/Scaled_Weight per separare i bound aritmetici dagli aggiornamenti dell'array.

## Checkpoint 17: pesi Gold chiusi; regressione SDF fresca diagnosticata

`/var/tmp/sparkling-recovery-flex-weight-proof4-20261003`: **unità pesi completa93check, zero aperti**, dopo minime Distance31, Inverse_Distance9, Reciprocal7, Scaled_Weight5 e Normalize27. Proprietà funzionali: norma/distanza e divisione nell'ordine FP C, somma ordinata, ramo somma<Min_Val senza mutazione, moltiplicazione per reciproco comune e preservazione delle componenti oltre Count. Dominio posizioni1e100, compatibile col contatto finito; nessuna assunzione di somma arrotondata esattamente1 o accuratezza reale del runtime sqrt. I5warning d'unità sono registrati. Kernel nuovo richiede ancora la regressione d'integrazione; build element3 avviata con questo kernel e risposte self/cross-flex/interni tetra, nuove ricevute ancora aperte.

R17 fresh `/var/tmp/sparkling-recovery-sdf4-20261003` prende la chiusura centrale r7, usa endpoint reali e passa **43/44** confrontabili a100step, con il consueto abort mesh/SDF C separato. Failure nuovo: box sample0, solo stato finale, max0.015998; iniziale acc8.5e-14, qfrc2.1e-14, conteggi/free esatti. Non nascosto né tolleranza allargata. Replay su101 stati C identici: per sdf4 J/reg/conteggi/free esatti, acc max4e-13 e qfrc5.3e-14; sdf3 mantiene traiettoria1.2e-15 a100step, sdf4 passa da2.1e-15 a20step a0.01595 entro30step. Non si osserva differenza narrowphase su questi stati identici; la traiettoria residua rimane failure d'integrazione e non è attribuita a una causa unica. Script/input/output/hash in `/var/tmp/sparkling-recovery-sdf4-box-replay-20261003`, ricevute copiate nel candidato e comunicate a dynamics. Release fresca da verificare dopo nuova closure centrale, il pass44/44 release precedente resta solo di sdf3.

R02 refit con asserzioni figli ancora in coda; R12 prova globale aperta; R11 residui asset in carico dynamics. Non è una chiusura globale del port né della parità prestazionale.

## Checkpoint 18: risposta self/cross-flex e contatti interni

`/var/tmp/sparkling-recovery-flex-element3-20261003`: **162/162 a100step** in validation, kernel pesi Gold93 incluso. I138 precedenti restano passa,24 nuovi campioni verificano cross-flex, self narrow/BVH/SAP/auto e contatti interni tetra con rimozione del vertice opposto dalla lista dei pesi. Il child ammette queste modalità e ordina i self contatti dopo tutte le coppie body/flex, come il driver C. Interpolazione ancora rifiutata. Questi24 nuovi casi non hanno elasticità propria (warning C conservati): dimostrano la risposta di contatto sullo stato dinamico, non ancora la combinazione self+elasticità. Da estendere tali fixture e ripetere release/flow sulla closure finale. Le ricevute release138/138 restano di element2.

Dynamics ha applicato la patch centrale weighted live e aggiunto contratti atomici/frame per entrambi i setter, senza ancora compilare/provare tale nuova composizione. I nostri162 campioni riguardano la patch isolata precedente sulla r7, non ereditano la composizione live.

R17 `/var/tmp/sparkling-recovery-sdf5-20261003` compilato prendendo la closure centrale r62 con nuovo sparse Newton. Corpus non avviato: terza finestra senza job richiesta da root per benchmark. Nessun nostro processo attivo al passaggio. Il failure43/44 della r7 resta aperto fino al nuovo confronto, senza supporre risoluzione. R02/R11/R12 e limiti di proof comecheckpoint17.


## Checkpoint 19: SDF sulla composizione sparse corrente

R17 `/var/tmp/sparkling-recovery-sdf5-20261003`, dipendenze congelate r62: **44/44 confrontabili a 100 step**. Il residuo box43/44 della r7 scompare sul nuovo corpus; questo è un confronto tra closure, non una prova causale di un unico dettaglio del solver. Resta invariato il failure mesh/SDF del riferimento C ufficiale (abort-6, exit complessivo1). Nessuna patch al riferimento e nessuna tolleranza allargata. Ricevute copiate; build release della stessa closure avviata in directory separata, ancora da verificare.

R02 ultimo tentativo `/var/tmp/sparkling-recovery-bvh-children-20261003`: Set_Bounds48, Build88 e Refit11 chiusi; Refit_Shaped77chiusi/5aperti. Le copie esplicite dei figli non eliminano i timeout, aumentano gli obblighi rispetto alla precedente variante64+2. Build/Refit restano modulari, dipendono dal contratto non ancora interamente provato di Refit_Shaped. Nessuna chiusura Gold globale.

R19/R13 nuova estensione di corpus aggiunge forze elastiche ai casi self/cross/internal mantenendo i162 precedenti. Richiede endpoint di elemento attivo e forza passiva elastica non nulla nel campione deformato; ancora in confronto sul binario element3. Dynamics prepara una nuova closure comune con weighted e contratti per rinnovo validation/release/flow. Le ricevute precedenti non si estendono ai suoi cambi concorrenti. R11 e R12 mantengono le ricevute e i limiti del checkpoint18; prove globali e prestazioni integrate restano aperte.


Aggiornamento checkpoint19: SDF5 release passa44/44x100, medesimo abortC separato. Validation/release hanno337sorgenti identici,297 condivisi con r62; ricevute copiate. I24 nuovi casi flex con elasticità attiva passano sul binario element3; è un corpus diagnostico selezionato, con sequenza RNG differente dal futuro corpus completo186. Nessuna somma impropria delle ricevute. Dynamics ha fornito closure r10 congelata con weighted/contratti/sparse ottimizzato; build flex su tale base prossima dopo prova BVH attiva.
