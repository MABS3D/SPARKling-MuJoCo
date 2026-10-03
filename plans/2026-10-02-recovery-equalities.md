# R06 — connect/weld, recupero e integrazione

Root; riferimento C 3.14.0, commit 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd.
Nessun commit/push. Coordinamento file centrali con recover_dynamics.

## Implementazione

- Nuovi `mj-equality_geometry.ads/adb` in constraint-assembly-candidate/src, per riusare le Source_Dirs dei progetti integrati.
- Harness, progetto e confronto isolato in experimental/equality-constraints.
- Child `MJ.Data.Constrained.Equalities`: copia autonoma di metadati body/site, ancore locali, quaternion, solref/solimp, torquescale firmato (anche zero/negativo), attivazione.
- Union degli antenati precomputata a Create, includendo gli antenati comuni come C (diversamente dai contatti). Righe prima di attrito/limiti/contatti.
- Impedenza usa norma del blocco 3/6, risposta usa posizione firmata per componente. diagApprox traslazionale/rotazionale senza torquescale quadratico.
- API per leggere/impostare l'attivazione delle uguaglianze.
- Aggiunta correzione Jdot*v presente in C 3.14.0. Bias dei punti dalle cache di moto; parte quaternionica con i tre termini della derivata del prodotto. Nessun valore calcolato da C entra nello step Ada.
- Solo connect/weld; le uguaglianze scalari joint/tendon restano da integrare. Prova globale del child e della composizione OPEN.

## Evidenza

- Geometria validation: 656/656 (336 righe native engine + 320 kernel; 84 modelli, dense/sparse, corpi/siti, mondo/indipendenti/antenati comuni, scale estreme, cambi di segno quaternion).
- Prima integrazione senza Jdot*v: divergenze riprodotte; ricevute preservate in /var/tmp/sparkling-equality-step-20261002-r1.
- Dopo Jdot*v: 500/512 campioni confrontabili passano su 30 passi. J, aref, regolarizzazione e traiettorie passano in tutti i campioni confrontabili. Restano 12 scostamenti acc/force/qfrc su torquescale10000, più 2 configurazioni interrotte. Il corpus totale NON è accettato.
- Due uguaglianze attive espongono il limite R,D in [1e-12,1e12] del solver; C usa R=1e-15 per righe angolari a Jacobiano nullo. Dynamics sta estendendo il dominio e riprovando i kernel, senza eliminare righe.
- 15 problemi assemblati estratti per dynamics in /var/tmp/sparkling-equality-solver-replay-20261002-r2/problems.json. Include lo stato Ada precedente al primo fallimento PGS nel passo.
- Prove minime: tre overload Bounded passano (1+1+3 checks). Anchor inizialmente timeout/watchdog240s, poi diagnosi per_path espone inizializzazione del loop. Sostituito loop con aggregato identico; prova r7 con 5 obblighi aperti (overflow/postcondizione). Estratto Anchor_Component con sottotipi scalari e contratto esatto; prova minima r8: 16/16 check passati, zero aperti/warning. Ripresa Anchor composto (r9). Non attribuire Gold alla geometria.
- Ricevute compatte sotto experimental/equality-constraints/evidence/20261002-recovery. I risultati numerici r2 precedono la riscrittura dell'inizializzazione Anchor; dynamics prepara build integrata successiva.
- Nessun benchmark conclusivo durante lavoro concorrente.

## Prossimi passi

1. Chiudere sottoprogrammi minimi geometria, unità intera e poi bias/quaternion nel child.
2. Rinnovare corpus integrato dopo minval e correzioni solver/pose centrali.
3. Verificare attivazione dinamica e atomicità su capacità/rifiuto; completare joint/tendon equality.
4. Misurare prestazioni integrate a macchina libera e confrontare con C.

## Checkpoint successivo

- Anchor_Component 16/16 e Anchor composto 17/17 provati (r8/r10), zero aperti/warning. Il contratto vettoriale usa la formula scalare provata, senza assunzioni. Multiply in prova minima r11.
- Build dynamics r3 dopo minval: 502/514 campioni confrontabili passano; due-active-equalities risolto. Rimangono12 scostamenti estremi e PGS-shared interrompe2 campioni. I problemi assemblati riproducono gli scostamenti anche con metrica C: diagnosi solver in carico a dynamics. PGS espone aref oltre1e10 ma accelerazione entro il dominio; estensione ammissione in corso.

## Checkpoint attivazione e prodotti

- Test equality_lifecycle aggiunto al progetto constrained: 4/4 su build dynamics r5 (connect, weld, inizialmente inattivo, 43weld/258righe oltre capacità). Controlla indice invalido, toggle, uso dopo Free del modello, preservazione stato su Evaluate e Step rifiutati, ripartenza disattivando e doppio Free.
- Product_At iniziale 62check e identità finale aperta, con CVC5/Z3 high failure e Alt-Ergo timeout. Separazione in quattro componenti scalari: Product_W 18/18 chiuso. Batch r17 prosegue X/Y/Z/At/Multiply; nessuna prova dell’intera geometria ancora dichiarata.

- Diagnosi bound: le formule W/X/Y/Z con sola relazione esatta passano18check ciascuna; aggiungere bound condizionali alla formula completa riapre la prova. Scomposta la moltiplicazione elementare in Product_Term, con relazione esatta e due bound condizionali:6/6 in3,9s. Batch r20 ricollega componenti e prodotto; niente assunzioni, stesse moltiplicazioni/addizioni C.

- R21: Product_W con contratto composto sui Product_Term già dimostrati passa10/10, inclusi i due bound condizionali. Il tentativo con formula moltiplicativa nuovamente espansa nel post trascinava i problemi nonlineari; composizione non cambia né indebolisce la formula floating-point specificata. Batch r22 in corso per X/Y/Z/At/Multiply.

## Checkpoint 2026-10-03 — composizione scalare

- R22: Product_X/Y 10check ciascuno, Product_At3 e Multiply12 chiusi. Product_Z aveva un post aperto; retry per_check10s r23 chiude10/10.
- R24: esteso Product_Term con bound per Q32 e V1e21; introdotto Axis_At che conserva esattamente ordine e segni del prodotto quaternionico per asse C. Product_Term6, Axis_At25, Model.Axis_Product9 e Multiply_Axis11 chiusi, zero warning/aperti. Modello e runtime compongono gli stessi contratti scalari dimostrati, senza assunzioni.
- R25 in corso sui modelli Position/Jacobian, rotazioni e procedure Connect/Weld. Prime prove modello chiuse; Rotation_Position ha ancora post di bound aperto. Nessuna Gold globale dichiarata. Ricevute /var/tmp/sparkling-equality-{product-z,axis,geometry}-20261003-r{23,24,25}.
- Su richiesta utente avviato reviewer indipendente review_upstream_sdf per valutare opportunità PR sul bug del riferimento C. recover_collision ha completato un checkpoint e ceduto temporaneamente slot; riprendere quel worker dopo review. Nessuna pubblicazione upstream autorizzata nella richiesta di valutazione.

### Preparazione uguaglianze scalari

Lettura diretta C3.14 `engine_core_constraint.c`: righe709–790 per joint/tendon,1747–1760 perdiagApprox. Preservare polinomio quartico e derivata nell'ordine esplicito C, non Horner. Posizione relativo a qpos0 oppure tendon_length0; secondo oggetto opzionale. Jacobiano J0+(-deriv)*J1, anche colonne comuni; diagApprox somma invweight0 dei due oggetti, senza derivata quadratica. `mj_Jdotv` attuale corregge connect/weld; non inventare correzione scalare in un port allineato. Precomputare union e aggiornare cache tendon prima dell'assemblaggio; coordinare con pipeline centrale. Ancora non implementato.

## Checkpoint composizione chiusa (r37)

- Named Conjugate elimina la ricostruzione di aggregati anonimi; Angular_Difference fa lo stesso per le differenze angolari. Le formule e i segni, incluso zero, sono invariati.
- Il tentativo di lemma Product_Equal_Left è rimasto aperto ed è stato rimosso, insieme alle asserzioni diagnostiche dipendenti. Non è evidenza di prova. R28/29/36 Weld interrotti deliberatamente per rivedere la struttura; non accettati.
- Nuovi costruttori eseguibili Quaternion_Product_Value e Axis_Product_Value hanno post esatto per ogni componente (Product_At/Axis_At) e bounds: rispettivamente19/17 check chiusi. Il modello superiore ed eseguibile compongono queste operazioni specificate, non un contratto di soli bounds. Gli helper scalari mantengono la formula ordinata fino ad A*B.
- R37: modelli Position4/Jacobian5, wrapper Multiply5/Multiply_Axis5, Rotation_Position7, Rotation_Jacobian8; tutti chiusi, zero warning. Questo chiude la composizione rotazionale nello snapshot r37.
- Weld mantiene una colonna per iterazione ma assegna esplicitamente le sei righe, evitando invarianti intermedi su un secondo ciclo di tre elementi. Prova minima r38 in corso; unità intera e confronto numerico fresco ancora necessari.
- Reviewer upstream concluso: dossier plans/2026-10-03-upstream-sdf-review.md e patch pronta, nessuna pubblicazione. Root ha verificato427 hash delle evidenze (zero discrepanze) e clone mujoco pulito al pin3.14.0. Collisione ripresa nello stesso subagente.

### Inizializzazione Weld

R38/r39 restituiscono rispettivamente128/126 check chiusi ma tre obblighi aperti: preservazione inizializzazione Pos(I+3), preservazione inizializzazione J(I,K), inizializzazione finale J. I bounds espliciti del modello (Position_Value/Jacobian_Value) sono provati ma non risolvono questi frame. Sostituito il ciclo Pos con aggregato completo e introdotto Store_Column: sei assegnazioni, contratto di esattezza della colonna e conservazione di ogni cella precedentemente inizializzata fuori colonna. Prima prova minima r40:29/29 chiusi. Nessuna inizializzazione a zero preventiva o scansione runtime aggiuntiva. Weld r40 in corso.

R40: Store_Column29/29; Weld watchdog240s prima del report completo, quindi ancora OPEN, non attribuire successo né usare i contratti del chiamato per proclamare Gold dell'unità. È necessaria ulteriore separazione della costruzione delle posizioni/delle colonne e diagnostica delle invarianti. Build validation r41 e rinnovo corpus geometria avviati per verificare tutte le modifiche operative correnti.

### Numerica rinnovata e frame del prefisso

- Build validation r41 e release r42 dello stesso snapshot operativo passano656/656 ciascuna (336 native engine +320 kernel); riferimento3.14.0 e hash delle librerie/binari nei JSON. Copie in evidence/20261003-recovery. Questi risultati NON chiudono Weld o l'unità Gold.
- R43 rafforza esclusivamente il contratto di Store_Column con una precondizione statica di prefisso già inizializzato, un post esplicito sul nuovo prefisso e preservazione incondizionata delle celle precedenti. Corpo operativo identico (sei assegnazioni), nessuna scansione runtime. Prova minima in corso, sessione root43926, output /var/tmp/sparkling-equality-weld-20261003-r43. Serve verificare il risultato prima di proseguire; non riavviare il job senza verificarne lo stato.

R43 concluso: Store_Column37/37; Weld di nuovo watchdog240 senza report completo, quindi ancora OPEN. Sessione43926 terminale, nessun job root rimasto attivo. Prossimo passo: limitare la diagnostica alle singole VC delle invarianti/post o separare costruzione posizioni e Jacobiano, prima della prova intera. Le rotazioni sono chiuse nei loro minimi r37, ma l'unità completa non ha ancora ricevuta Gold. Le build numeriche r41/r42 precedono solo il rafforzamento statico del contratto Store_Column: corpi operativi invariati.

## Ripresa — diagnostica Weld e kernel joint/tendon

- Runner: aggiunta diagnostica `--limit-line`, valida solo con un sottoprogramma minimo; scope distinto nell'accettazione. Selezioni inesistenti rifiutate. Timeout complessivo ora esplicito, senza confonderlo con il timeout del singolo prover.
- R44 chiude la conservazione dell'inizializzazione del prefisso Weld (4check). R45/46/48 lasciano aperta la relazione funzionale con quantificatore annidato. Separare le invarianti per ciascuna riga chiude la prima relazione lineare (r49,4check), senza cambiare operazioni runtime.
- Store_Column r47:27check chiusi. Il contratto è dedicato alla costruzione incrementale: colonna corrente esatta, prefisso inizializzato e valori delle colonne precedenti preservati. Le colonne successive, ancora da costruire, non fanno parte del contratto; il corpo rimane sei assegnazioni.
- R50 full Weld watchdog240: non accettato. R51 e r53 isolano ancora il timeout nella conservazione della componente angolare. R52 prova Conjugate3/Angular_Difference9 con post esatti di componente, oltre ai bounds. In r57 si isola la lettura della colonna angolare in un modello e wrapper dedicati; obblighi ancora da verificare, nessuna Gold dell'unità.
- Nuova `MJ.Equality_Scalar`: quartico espanso, derivata con moltiplicazione del coefficiente prima delle potenze, sottrazione separata del coefficiente costante, secondo oggetto opzionale e Jacobiano J0+(-deriv)*J1. Ordine preso direttamente da C3.14 `engine_core_constraint.c:709–790`; nessuna conversione a Horner, normalizzazione o derivata al quadrato.
- R54: tutti12 minimi scalar passano, totale83check. R55: intera unità83check, zero aperti/warning, coverage completa e nessuna assunzione/skip. Gold limitato alle formule floating-point e al dominio dichiarato; integrazione e proprietà fisiche globali non provate.
- R56 validation:432/432 confronti nativi scalar esatti (joint, tendon fisso/spaziale, uno/due oggetti, dense/sparse, coefficienti e posizioni firmati/estremi). Range output più largo dello storage: l'adapter dovrà verificare il narrowing, senza cast impliciti insicuri. Build e hash salvati nelle ricevute scalar_*.
- Ripetuto corpus integrato connect/weld sulla build centrale dynamics r7:751/768 campioni confrontabili passano,17 scostamenti estremi e2 configurazioni PGS interrotte (6campioni mancanti). Questa esecuzione usa3samples contro2 di r5: i conteggi non sono direttamente confrontabili. I Newton densi non compaiono fra i fallimenti; restano Newton sparse e CG con torquescale10000, oltre al resetQACC nativo non ancora portato. Ricevuta equality_step_r7.json; dati completi `/var/tmp/sparkling-equality-step-20261003-r7`. Dynamics informato per diagnosi su input identici.

## Integrazione scalar e snapshot comune r62

- R57 chiude Model.Column_Jacobian19 e Rotation_Column22 check, zero aperti. R58–60 lasciano aperta la preservazione angolare Weld: né il modello per colonna né la matrice attesa Ghost Static risolvono ancora l'obbligo. La matrice ghost non introduce scansioni runtime. È lavoro di prova incompleto, non una limitazione matematica Silver.
- Integrati joint e tendon equality nel child comune. Metadati e riferimenti copiati a Create; unione delle colonne CSR e mappe ai due tendini precomputate, senza eliminare colonne comuni o zeri strutturali. Narrowing di residuo/J esplicito; diagApprox somma le inverse weight senza derivata al quadrato. Nessuna correzione Jdot*v scalare, coerentemente con C3.14.
- Tendons.Initialize include gli oggetti referenziati anche da uguaglianze inizialmente inattive. Tendons.Update precede Equalities.Assemble senza cambiare l'ordine delle righe. La cache delle lunghezze spaziali è già aggiornata dalla fase passiva anche con spring/damper disabilitati. I fixed tendon con colonne duplicate restano rifiutati esplicitamente.
- R61 build interrotta da una visibilità CS.Method mancante nel dispatch Newton concorrente; corretta da dynamics. R62 validation e release costruite dalla medesima snapshot immutabile, manifest SHA256 `a16a42478e09cc54d4cda230ef2910cb26757dad39272cb436a03299280a1e6e`.
- R62 scalar integrato:468/468 su100 passi in entrambi i profili, record numerici identici.156 configurazioni: joint/fixed/spatial, uno/due oggetti, dense/sparse, PGS/CG/Newton, quartico/lineare/costante, inattive, disabilitate, spring/damper disabilitati, due righe. J/aref/R esatti nel corpus; massimo errore stato1.066e-14, accelerazione2.274e-13. Solo MJB, stato, controlli e forze esterne entrano in Ada.
- Lifecycle esteso:46/46 in entrambi i profili. Include attivazione dopo Free del modello, tendini inizialmente inattivi, passive disabilitate, 42weld+5scalar/257righe: fallimento atomico su Evaluate/Step e ripresa dopo disattivazione. Le prove formali dell'adapter restano aperte.
- R62 connect/weld:755/768 confrontabili su30 passi;13 scostamenti e2 configurazioni PGS interrotte. Le13 anomalie includono12CG e1Newton sparse (weld-independent-1-10000.0, sample0, acc2.57e-5); i reset C su QACC non sono ancora riprodotti. Soglie originali mantenute. Rispetto a r7 quattro scostamenti in meno, non accettazione completa.
- Ricevute in `experimental/equality-constraints/evidence/20261003-recovery`: `scalar_*r62`, `lifecycle_*r62`, `integrated_*r62`, `equality_step_r62.json`, più minimi r57 e diagnostica aperta r60. La standalone scalar release e la geometria standalone dopo Rotation_Column devono ancora essere rinnovate. Nessuna Gold dell'intera geometria o della composizione integrata.

### Rinnovo standalone e induzione Weld

R63 validation/R64 release hanno lo stesso manifest sorgenti:656/656 geometria e432/432 scalar esatti in ciascun profilo. Includono Rotation_Column e matrice attesa ghost. Rinnovate le ricevute `standalone_*r63/r64`, `geometry_*r63/r64`, `scalar_*r63/r64`.

Diagnostica minima Weld: r65 chiude la colonna corrente (6check). R66 preservazione ancora timeout. R67 Store_Column con frame per riga passa57check ma non risolve r68; ritirata questa riscrittura, ripristinato il contratto di prefisso r47. R69 chiude la preservazione del solo prefisso precedente della riga4 (4check). Con questo lemma locale esplicito, r70 chiude finalmente l’invariante estesa fino alla colonna corrente (4check). Estesa la stessa asserzione alle righe5/6; intera procedura Weld r71 in corso. Sono esclusivamente asserzioni Static: nessuna scansione eseguibile aggiunta e nessuna assunzione. L’accettazione dell’intera procedura/unità deve ancora arrivare.

### Casi misti e dominio della proiezione delle forze

R71 Weld intera procedura raggiunge watchdog180s (321MB) senza report completo: non accettata. Rimane la prova locale di prefisso r69/r70, nessuna Gold globale.

Esteso compare_scalar_step con36config aggiuntive uguaglianza+attritoDOF+limite+contatti, senza modificare i156modelli precedenti né la loro sequenza casuale. Tutte36 verificate native con tipi riga0/1/3/6 e ncon>0. Su r62 tutti36 vengono rifiutati in Evaluate in entrambi i profili; i468precedenti restano passati. La ricezione non viene contata come confronto superato. Ablation0step: disabilitare uguaglianze/limiti/attrito non elimina il rifiuto, disabilitare i contatti sì.

C produce R=2e-15 e forze6.578947e15 sulle righe di contatto a J=0 del corpo con solo hinge. Qacc resta[247.86,25.24] e qfrc[.22,64.29]. La causa è il narrowing Force:Small±1e10 in CK.Accumulate_Force, successivo al solver che già ammette ±1e100. R/D e fixture non cambiati. Esteso solo Force_Value a±1e100 e Force_Sum a±1e120; formula Previous+Jacobian*Force invariata, controllo finale dello stato invariato.

R72: minima Accumulate_Force7check chiusi; unità MJ.Constrained_Kernels39check, zero aperti/warning, tutti4sottoprogrammi coperti, nessun assume/skip. Runner prove_subprogram ora supporta --whole con verifica completa di coverage, scope distinto dalle minime e hash del runner. Questa prova riguarda il kernel e non chiude il chiamante integrato.

R72 validation:576/576 scalar integrati su100passi, inclusi108campioni misti; stessi input e tolleranze originali. Release e connect/weld in verifica. R72 contiene la closure r10 più dominio forze, ma precede la successiva correzione pipeline rotVecQuat del worker services/dynamics: attribuzione da manifest, non al checkout mobile.

R72 release conclusa:576/576 su100passi, record numerici identici a validation. Lifecycle46/46 in entrambi i profili. Massimo errore traiettoria3.908e-14, accelerazione3.638e-12, J/aref/R esatti nel corpus. Connect/weld755/768, medesimi13scostamenti e2interruzioni: la correzione Velocity non li risolve in questa closure. Manifest `20ab31beefbb677805f98e3b0d0b55fb33b7898a3d1534342f17cc84f770e5a9`; tutte4dipendenze sorgente del kernel provato ancora identiche al checkout al checkpoint.

R73 Weld in diagnosi completa per_check dopo avere espresso il post per ciascuna delle sei righe, equivalente ai quantificatori annidati precedenti. Nessuna formula/cella esclusa, nessuna modifica runtime. La dimostrazione resta pendente fino alla ricevuta.

R73 terminale: watchdog150s, nessun report completo. Il post per righe preserva la specifica ma non basta a chiudere la procedura; snapshot e log conservati. Nessun job root di compilazione/corpus/prova resta attivo a questo checkpoint. L’intera geometria e i chiamanti rimangono da dimostrare; nessuna eccezione Silver matematica dichiarata. Prossima diagnosi: singole VC/post e contesto del prover, senza rilanciare budget lunghi alla cieca.

### Ripresa r74–r77 — diagnostica verificata e prova completa

Turno precedente classificato come progresso: r74–r76 hanno prodotto ricevute nuove sui reali obblighi Weld. R74 post finale:3 check, incluso1 VC post. R75: linee149/158/164/166/180/182 con5/4/4/4/4/4 check; r76 chiamate150/159 con4/4. Tutti zero aperti/warning e almeno una VC di proof presente, hash della geometria ancora identici al checkout. Ricevute copiate in evidence/20261003-recovery/weld_r*. Queste sono diagnostiche per linea, non chiusura globale.

R77 avviata sulla procedura Weld completa, --no-inlining/per_check/timeout3/level1, watchdog420s. Il budget deriva dai10–29s effettivi di ciascuna diagnosi, non da una nuova eccezione Silver. Runner rafforzato: una selezione per linea con sole voci flow e nessuna VC proof viene ora rifiutata. Risultato ancora pendente; non attribuire la chiusura prima del report.

Lettura diretta C3.14 conferma ulteriori uguaglianze FLEX (una riga per edge nonrigido), FLEXVERT (due strain/vertice) e FLEXSTRAIN (eigenmode corotato per cella/faccia). Restano realmente mancanti nel producer, che ammette0..3. FLEX richiede length-rest, Jacobiano CSR endpoint2-endpoint1 proiettato sulla direzione normalizzata e flexedge_invweight0. La sola matrice geometrica non basta: Flex.Create stacca temporaneamente i dati flex e deve mantenere riferimenti, ordine delle uguaglianze, attivazione e metadati dopo Free del modello. DISTANCE è rifiutata anche da C e non è una funzionalità C da portare. Nessuna implementazione flex-equality ancora dichiarata.

R77 terminale con report completo dopo415.11s:193 check chiusi,5 aperti, zero warning. I cinque sono range Angular(2) all’aggregato, preservazione delle tre righe lineari, inizializzazione J finale. Il report distingue timeout da errore di formula; nessuna prova globale dichiarata. R78 aggiunge solo Assert Static: bound Angular, conservazione del prefisso e colonna corrente lineari, chiusura esplicita inizializzazione; allinea il quantificatore dell’invariante di inizializzazione al frame Store_Column. Formule operative e dominio di Weld invariati. Minime159/161/182/184/186/197 in esecuzione sequenziale; risultato pendente.

R78 tutti sei minimi passati: bound3, aggregato20, invarianti lineari4/4/4, inizializzazione finale3. R79 chiude inoltre prefissi lineari4/4/4, colonna lineare corrente10, invariant inizializzazione4, chiusura delle celle3 e post finale3. Zero aperti/warning e selezioni reali proof non vuote; tutto rimane diagnostica per linea, non una prova globale. Test negativo del runner: linea9999 produce solo2flow e0proof e viene correttamente rifiutata (exit1, empty_diagnostic=true). Ricevute r78/r79 persistite.

Preparato nuovo MJ.Equality_Flex: residuo length-rest e proiezione edge in tre aggiornamenti ordinati, con i rami direction=0 di mju_mulMatTVec preservati e accumulatore iniziale +0. Cinque sottoprogrammi, nessun contratto fidato nuovo. Minime e unità intera r80 avviate; harness compare_flex usa la libreria C ufficiale e controlla anche i bit degli zeri firmati. Questo kernel non è ancora chiamato dal producer integrato e non completa le uguaglianze flex.

R80: cinque minimi6/8/8/8/3 e intera MJ.Equality_Flex33 check, coverage completa, zero aperti/warning/assume/skip. R81 validation e release:1883/1883 confronti bitwise in ogni profilo, stessi input e stessi sorgenti della prova. Include25residui, componenti nulle/zeri firmati, campioni fino1e30 e normali chiamate C mju_mulMatTVec con larghezze1/4/5/16/17/64/128 (blocchi SIMD e code). Questo dimostra le formule floating-point e verifica il corpus del kernel, non la sua integrazione flex né equivalenza bitwise universale. Ricevute persistite flex_kernel_r80/r81.

R82 intera geometria avviata --no-inlining/per_check/timeout5/level1/watchdog900 dopo tutte le nuove minime r78/r79. È l’unico job root pesante; sessione66160, output /var/tmp/sparkling-equality-geometry-whole-20261003-r82. Non mutare i sorgenti inclusi finché è vivo. Risultato ancora pendente.

R83: export_solver_cases conserva ora CSR nativo con rowadr/rownnz/colind/values, compresi zeri e duplicati, senza cambiare problem consumato dai replay precedenti. Helper verificato su84modelli,1302slot zero sparse preservati. Aggiunti hash input/MJB/binario/libreria al replay. Il solver corrente ricostruisce ancora Columns da J/=0: API di supporto per riga e raggruppamento esatto C restano da implementare. Non usare gli export densi preesistenti come prova di quell’ordine.

Barriera benchmark riservata: dynamics r12 ha completato validation/release su identica closure e395bitwise/428dense/428sparse locali. Tutti i worker evitano nuovi heavy dopo i job correnti (whole BVH collision, r82 root). Services ha segnalato zero job; dynamics pure. La misura r62/r12/C sarà ammessa solo dopo terminale dei due whole e verifica processi. Nessuna nuova prestazione ancora rivendicata.

R82 TERMINALE PASS in740.08s: intera MJ.Equality_Geometry619check,33entità incluse le overload/pacchetti, complete_coverage=true, missing_entities=[], zero aperti/warning/Assume/skip. Ora è chiusa l’intera geometria connect/weld nel dominio e con le formule floating-point specificate. Questa ricevuta sostituisce la precedente mancata chiusura Weld; non estende Gold al child Equalities/Bias né alla simulazione globale. Prova, build validation e release r81 hanno sorgenti identici. Rinnovo geometria corrente:656/656 in entrambi i profili (336engine+320kernel), zero fallimenti. Ricevute geometry_whole_r82 e geometry_numerical_r81 persistite.

Barriera completata: root619terminato, collision whole BVH terminale99/900s senza ricevuta completa, services e dynamics zeroheavy; ps conferma0compiler/prover. Misura r62/r12/C terminata con exit0:96DOF r62=82.37us, r12=71.90us, C14.84us. Rapporto appaiato r12/r62=.8729 CI95[.8457,.9012] (miglioramento reale ~12.7%), r12/C=4.815 CI95[4.790,4.943] (parità lontana). 48DOF ratio=.9106 CI[.8927,.9275];24DOF e quattro piccoli CI includono1. Tutte traiettorie entro soglie originali. Stessi7modelli/CPU2/15blocchi/8batch/100passi, nessuna attribuzione causale ai singoli14file mutati. Snapshot e dati: /var/tmp/sparkling-sparse-newton-benchmark-20261003-r12/results.json; metadata preparazione in dynamics12/benchmark-prepared.json. Barriera liberata; dynamics prende CSR completo/riduzioni C, services controller integrato, collision SDF+flex/BVH Prepare. Obiettivo globale ancora attivo, non completo.


## Cache flex e kernel righe: r92/r95

La costruzione della cache CSR degli spigoli ora conserva rowadr/rownnz/colind
compilati C e slot strutturali zero, e la forza sugli spigoli riusa la cache.
Ordine dei quattro accumulatori SIMD e inizializzazione ai primi prodotti seguono
il riferimento normale C3.14.0. Il kernel MJ.Equality_Flex_Rows.Append è chiuso
nell'intera unità:54 proof+2 flow,56/56, copertura completa e nessun aperto,
warning, Assume o skip. Le sei sorgenti delle due unità flex/assembler coincidono
con quelle della closure runtime r95. Questo non chiude Load/Geometry né il
producer composto Append_Storage o i suoi chiamanti.

R95 validation/release:216/216 cache/forze/accelerazione/movimento a100 passi,
240/240 righe assemblate dal C nativo, incluse240 verifiche atomiche di capacità
per profilo. Sorgenti, input e record numerici identici tra profili. Nella numerica
righe il peso è confrontato con flexedge_invweight0 compilato; diagApprox non è
un campo pubblico di MjData3.14. Due tentativi precedenti conservati: r93 falliva
il test invalid-size nel caso Nv0; r94 il trace della cache a zero slot. Il trace
usa ora il range target esplicito; r95 chiude anche quei casi. Ricevute:
experimental/flex-elasticity-integration/evidence/20261003-edge-cache/.
Nessuna nuova prestazione misurata e nessuna parità dichiarata.

## Passo con uguaglianze FLEX: composizione r96 in verifica

Parent Assemble separato in Begin/Finish; Equalities.Prepare/Assemble_One
mantengono algoritmo rigido precedente. Metadata flex conserva Kind/Object/ID,
mentre Create ordinario rifiuta i tipi4..6 e Assemble_One non omette un flex
attivato runtime. Il child ammette soltanto FLEX edge4, ripristina tutti gli array
e nomi originali dopo la factory, reinizializza i requisiti tendon ed equality,
inserisce i gruppi nell'ordine originale e usa un peso per riga consumata.
Nessun azzeramento addizionale dell'intero buffer pesi. FLEXVERT/FLEXSTRAIN e
interpolazione restano esplicitamente rifiutati. Contratti/caller Gold ancora
aperti; test differenziali e prove minime non sono Gold globale.

R96 closure immutabile con comune dynamics14 e FE/test aggiornati compila
validation (106,1s); confronto dei passi avviato, non ancora risultato acquisito.
Il runner nuovo controlla ID originali, J/aref/R/efc_force, qfrc_constraint,
accelerazione, stato finale, dense/sparse e PGS/CG/Newton, uguaglianze miste
joint/tendon/contact e attivazione runtime. Build senza benchmark.


R96 termina anche release:342/342×100 passi in ciascun profilo,
19varianti×3solver×2layout×3campioni. Closure/input/record identici;
maxabsJ=2.22e-16, aref=2.22e-16, R=0, efc_force=1.99e-12,
qacc=1.05e-13, qfrc_constraint=4.31e-12, stato=1.33e-15.
Tolleranze originali2e-9 non allargate. OriginalEqIDs verificati da view
solo-test delle righe effettive; modelownership/activity/rejection controllate
nel probe. Ricevute20261003-equality-step. Casi con FLEXVERT/FLEXSTRAIN,
interpolazione, sleep/advanced controller e prestazioni non inclusi.

R97 minimo Append_Storage avviato sulla closure r96 per diagnosticare sicurezza,
precondizioni e frame del producer; nessuna nuova Gold composta acquisita.

Export solver ora contiene sibling native_mass: M_*CSR del modello, d.M,
qLD/qLDiagInv e dof_simplenum, senza alterare problem/J/free. Ricostruzione
uguale a mj_fullM per84fileMJB; test esplicito a due hinge ortogonali conserva
lo slotzero nativo (non inventare slot assenti: free semplice6DOF ha6slot,
nessuno zero). Scopo ablation LDL C contro Cholesky denso; non è ottimizzazione
runtime già applicata né prova universale.


R97 diagnostica minima terminale:36 check chiusi,18 messaggi aperti (shape,
indici, contatori e capacità), nessuna Gold del producer. R98 esplicita
Edge_Layout_Valid come predicato ghost e postcondizione dell'admission Load:
nessuna nuova scansione runtime e nessuna assunzione aggiunta. Append_Storage
riceve layout/CSR cursor/range Responses in precondizione statica; chiamanti
ancora da dimostrare. Invarianti contatori preflight e preservazione Valid/Ne
aggiunte ai cicli. R98 compila validation; r99 minimo fresco avviato,
risultati runtime r96 restano attribuiti alla vecchia closure.


R99 minimo terminale:66check chiusi,2obblighi aperti (sorted chain dalla
preflight e garanzia AddedSuccess). R100 aggiunge il post di atomicità del
producer interno e prefissi ghost dei budget righe/entry, con ricorrenza,
monotonia, catene validate e invarianti di consumo. Nessuna variazione delle
operazioni float; contatori runtime preflight invariati. Compila validation
103s/RSS498MB. R101 minimo fresco in corso; prove del loader/caller rimangono
aperte. R96 resta l'ultimo checkpoint numerico completo acquisito.


R101 conserva errore GNAT: oggetto array locale prima di loop-invariant non
supportato, zero check finali; nessuna prova attribuita. Invarianti spostati in
testa e builder ora offre --freeze-only per minime rapide senza runtime build.
R103:151chiusi,2aperti (preservazione chain sort e AddedSuccess). R104 usa
Edge_Chain nominata con relazione colonna per colonna e separa asserzioni
capacità per diagnostica. R105 minimo Edge_Chain avviato; intera unità producer
ed admission/caller non ancora Gold. Nessuna variazione dell'algoritmo FP.


R105 Edge_Chain chiusa17proof+1flow. R106 Append_Storage chiuso157proof+2flow, zero residui/warning; preflight capienza, ordinamento CSR e frame di rifiuto dimostrati. Scope minimo condizionato a Edge_Layout_Valid: whole/admission e chiamanti ancora aperti, relazione funzionale completa del gruppo non ancora specificata. Nessuna nuova scansione o ipotesi trusted. R104 è la closure della prova; R96 resta il checkpoint numerico completo precedente.

R107 wrapper Force_Model:5check chiusi,1precondition shape aperta. Admission CSR estratta in Copy_Edge_Columns e Load_Edge_Layout, con contratti esatti rispetto agli array compilati. R109 frontend GNAT rifiuta aggregate diagnostic for-of; runner KeyError sul report incompleto conservato, nessun pass. Trace Length convertito a indice esplicito e collector reso robusto. R111 minimo copia colonne:8proof+1flow chiusi. R113 minimo layout completo in corso. Nuova acceptance di CSR invalida preparata ma non ancora eseguita.

R113 Load_Edge_Layout:watchdog240,2s/RSS2037MB, nessun report finale e nessun check attribuito. R114 scompone ulteriormente Copy_Flex_Edge_Ranges e Copy_Edge_Rows, entrambi con copia esatta e limiti. R115 minimo ranges in corso; test di admission sono ora nel probe tramite flex-load-checks, non ancora compilati/eseguiti.

R115 Copy_Flex_Edge_Ranges chiuso27proof+1flow; R116 Copy_Edge_Rows chiuso30proof+1flow. Copia esatta e limiti dimostrati nei minimi, compresa la cache vuota. R117 composizione Load_Edge_Layout in corso. La nuova suite di admission contiene4fixtureC, incluso Nv0/NJfe0, ed esercita rifiuto di colonne/range/width invalidi e recupero del modello ripristinato. Nessun risultato runtime attribuito ancora.

R117:14chiusi/11diagnosticaperti, tra cui range dei nullarray e pointer/frame nella post rispetto al modello intero. R118 corregge le precondizioni minime da uguale Last a uguale Length (range null diversi ammessi) e il compositore riceve i cinque array effettivi anziché il modello globale. Nessuna sorgente C fornita in fase runtime: sono sempre gli array compilati caricati nell'MJB. Minimi da rinnovare prima del runtime, R119 colonne in corso.

R119/r120/r121 rinnovano i tre minimi8+1/27+1/30+1 sulla stessa closure. R122 composizione:14chiusi/4aperti, esclusivamente well-definedness della precondition Length=Natural. R123 confronta le lunghezze direttamente alle lunghezze target, senza conversione a Natural e senza escludere cache vuote. R124 composizione aggiornata in corso.

R124 Load_Edge_Layout composizione chiusa13proof+1flow, zero residui/warning, con copia esatta del CSR e layout valido. Questa ricevuta copre la composizione minima, non il loader generale Load/Make_Chain, né i wrapper Append_Edges o la dinamica globale. R125 validation congelata dalla stessa closure r123 avviata, dipendenze common14 e FS SDF7/r12 esplicite. Non include solver r15 né liveFS interpolata/nuovaScene.

R126 validation compila103,6s/RSS473MB;342/342×100equality e234/234×100contatti passano. R128 harness corrected:86/86 admission sui4modelliC (23+23+23+17), inclusi Nv0/NJfe0. Fallimenti di harness r125/126/127 conservati: reserved Accept, stack8MiB e due fixture XML invalide; nessun falso pass. Driver aggiornato stack128MiB/edge solo1D/elastic2d none3D, con hash salvato. Nessun sorgente implementativo diverso dalla closure r123 della prova; test Ada cambia soltanto nome Expect_Accept. R129 release in corso, common14 e FS vecchia dichiarati; no nuovo timing.

R129 release terminale:342/342×100equality,234/234×100contatti,86/86admission; sorgenti Ada/progetto identici a r126, input e record numerici identici. Differenza Python harness dichiarata con hash eseguito uguale nei2profili. Nessuna nuova misura o parità globale; scope common14/FSvecchia distinto da r16. Ricevuta acceptance-r126-r129.json e minimi r130..132 per la stessa closure r123 in completamento.

R130/131/132 chiusi sulla stessa closure r123 della composizione r124:4scope totali78proof+4flow, zero residui/warning. Ricevuta admission-minima-r123.json. Runtime Ada uguale r126/r129. MainLoad/caller, whole funzionale group e interpolateddynamics rimangono aperti. Prossimo minimo Load per diagnosi della conservazione della shape, poi composizione selettiva commonr16 evitando liveFS.

R133 Load:guardia memoria2501MB in34s, nessun report finale. Collector leggeva lo .spark della precedente Copy_Edge_Rows: i31check sono ritirati per questo run, non sono di Load. Originali conservati insieme alla correzione. Runner elimina il report precedente prima di ogni invocation, verifica entity/sloc della scope e marca complete_coverage soltanto per whole. Minimi precedenti corretti restano validi, intera admission ancora aperta.

R134 integra tramite overlay manifest-verified: FE r129, comune r16 integrated-pose (solo Ghost delta dopo runtime r16) e FS geometry state3. Builder registra ogni folder/hash proveniente dalla closure e include nuovi file; nessun fallback a liveFS. Runner proof ripulito e copertura scope/whole separata; 6 regression di ricevute e 2 di overlay chiuse (test infrastruttura, non prove formali). Validation r134:342/342equality×100,234/234contatti×30 di smoke,86/86admission. Il corpus contatti completo a100 e il profilo release restano da acquisire. Performance paired r16/r12/C avviata soltanto dopo tre ACK e preflight zero processi pesanti,7modelli×15blocchi×8batch×100passi; nessun risultato temporale ancora attribuito.

Performance r16 quiet terminata:7/7trajectory100passi alla tolleranza rafforzata2e-9;6/7stato finale con errore assoluto nullo (nessun controllo bitwise/signed-zero),shared1.11e-16. Rispetto a r12 tutti7 regressioni fuoriCI: mediana+2.52..10.20%;24DOF12.406µs/C4.719(2.634x),48DOF28.427/C8.123(3.557x),96DOF76.733/C14.392(5.272x,CI5.222..5.398). Nessuna parità acquisita. Dynamics prepara ablation una alla volta, correttezza prima di nuovi tempi; nuovi Total/LDL distinti. Ricevuta conraw/provenienza/barriera in constrained-step/evidence/recovery-20261003/performance-r16. Non estendere tempi aFLEX/advanced/interp.

R135 release e nuovo corpus100 terminali:342/342equality×100,234/234contacts×100,86/86admission nei due profili. Tutti361sorgenti/progetto manifest identici, inputC/XML/MJB/expected e record numerici identici. Ricevuta acceptance-r134-r135.json con sei report e due manifest. Nodal endpoint3 e nuova correzione SDF restano esclusi da questa acceptance; nessuna nuova prova intera FE o claim di parità. Seconda finestraquiet avviata dopo quattroprocessi terminali e ps0 per tre ablation causali del r16.

R136..139 rinnovano minimi CSR sulla nuova closure r134:8+1/27+1/30+1/13+1 =78proof+4flow, zeroobblighi aperti e copertura minima completa. Strict pass FALSE: ogni scope conserva due entry imprecise-call Sqrt nel nuovo Manifold r16; non sono ignorate/soppresse né una nuova wholeGold. Ricevuta admission-minima-r134.json. Runner ora separa obligations_closed dalla strict passed; regression aggiunta sul warning preservato (7test pass). Fonte/line/entity e freshness verificati in tutti4run. FullLoad ancora aperto per memoria, nessuna scansione rimossa da questo run.

Ablation commonr16 completate inquiet:manifold-r12 eScene-r12 non significative96DOF;solver+adapter-r12 ratio0.92318,CI[0.91598,0.95311],recupera7.68%su96. Il rollback è solo diagnostico e perdecorrezioni numeriche, non integrato. Product-real conservaordineC e152checkminimi/390bitwise/432solver/7workload ma paired96ratio0.9984CI[0.9857,1.0223],24/48CIincludono1; solosmallbox~5%significativo. Nessuna soluzione generale o parità attribuita. Dynamics isola ora H+M sparsa sulla struttura simbolica, con fill/zeristrutturali e dense invariata; Factor richiede ancora azzeramento pieno, da cambiare con contratto distinto. Root prossimi:decomporre Load/Make_Chain su inputpiatti e propagaEdgeLayoutaiwrapper;integrazione nodale separata ancora richiede capacity27 e Nv<=256, vecchi modelliendpoint375DOF non ammessi al movimento.


2026-10-03 antenati flat: nuovo MJ.Flex_Ancestors segue mj_mergeChain C 3.14.0: body_weldid, max dei due DOF discendenti, deduplica comune, inversione finale. R143 Last_Dof15+2 chiusi; r144..148 helper chiusi. R149 cinque induzioni aperte; r152/r161 frontend ghost/sintassi non producono report e non sono prove. Freeze r169 respinto correttamente per modifica concorrente del probe, nessun risultato attribuito. Lemmi ghost Unfold_Pair/Column/Shift provati chiudono r185 Merge48+4 e r186 Build30+5; r188/189 aggiungono e provano limiti e ordinamento. R193 whole1 range aperto nel confronto Length/IntegerLast; r194 usa confronto Int64 senza limitare modelli rappresentabili. R195 whole250proof+25flow, zero aperti, copertura completa; strictfalse conserva5warning ricorsione e10reassociation intera. Il corpus r194 passa2355/2355 nei due profili:895coppie su modelli compilatiC,1440foreste valide contro C,10malformati soloAda e10recuperi. Input/output/records identici, nessuna prova universale di equivalenza C. Sorgente finale rende esplicite le parentesi delle10warning, rinnovo proof pendente. Hook FE elimina Include256+scanNv e la risalita dei corpi fissi, usando la catena provata; r196 validation integra original-force common r18 (312file manifest1a7ce2...) e SDFstage2 (350file c45839...) via overlay verificati, ancora in build. Nodal endpoint3 escluso; wholeLoad/callerFE e parità rimangono aperti.

R196 validation integrata terminale:368 file di sorgente/progetto/test,12overlay verificati, build105.9s/RSS486MB. R197 rinnova whole antenati275check chiusi, zero aperti e nessuna entità mancante;9/10warning reassociation risolte con parentesi, restano1intera+5modelli ricorsivi, strictfalse conservato. Corpo runtime FA collegato direttamente a Load, nessuna propagazione prematura ResultSuccess. Admission estesa152/152 (43slides,43shared,43free,23Nv0), inclusi Weld/Address/Width e dof_parent malformati con recupero. Movimento342/342equality e234/234contact×100 passa. R198 release identica closure in corso; minimi CSR e wholeLoad/caller sono separati e non rinnovati da queste prove. Un test collector aggiuntivo rifiuta whole con funzione espressione della spec omessa:10/10passano, verifica solo metadati, non proof.

R198 release completa:152/152admission,342/342equality×100,234/234contacts×100. I368file di sorgente/progetto/test identici e tutti gli hash ricontrollati;12file admission,684equality e702contact (inputXML/MJB/input/expected/output) byteidentici, anche tutti i record numerici. Leaf r196 rinnovata2355/2355 entrambi profili, input/expected/output identici sulla closure integrata. Receipt acceptance-r196-r198.json. Nessun dato C consegnato al kernel produttivo, nessuna nuova assunzione o soppressione. Gold per modello ordinato degli antenati resta distinta da whole loader/callerFE;6warning preservati. Prestazione integrata non misurata da questi confronti, parità ancora aperta.

R199..202 minimi CSR rinnovati sulla stessa closure integrata r196:8+1/27+1/30+1/13+1=78proof+4flow, zero aperti/copertura minima completa. Ogni scope conserva7warning (modelli antenati ricorsivi e due Sqrt imprecise-call); strictfalse non occultato. WholeLoad/produttore/chiamanti ancora separati. Barriera quiet richiesta per LDL: root3718 terminale e servizi62528 terminale, attendo collisione40456 ancora live; niente benchmark finché nuovi ps e tutti ACK non confermano quiet.


## 2026-10-03 — LDL FLEX r203/r204 e CSR ordinato r215

Il precedente turno è progresso: il paired LDL isolato ha misurato un beneficio
sul caso96DOF (ratio0.95948, IC95%0.86991–0.98327), senza regressioni significative
nei sette carichi, e il candidato è stato applicato per hunk al parent. Il divario
con C rimane circa5x a96DOF; il secondo paired è cumulativo rispetto a r16.

Root ha rinnovato l'integrazione FLEX su una closure completa di370sorgenti,
r203 validation/r204 release:152admission,342equality e234contact per profilo.
Tutte le sorgenti, i record e12/684/702file XML/MJB/input/expected/output sono
identici tra profili. Le14warning C dei modelli contact sono identiche a r196;
nessuna è stata soppressa. Le ricevute portabili sono in
`experimental/flex-elasticity-integration/evidence/20261003-native-ldl/`.
Questa è evidenza di ammissione e confronto numerico; non è Gold della dinamica
completa né una misura di prestazioni FLEX.

Il candidato r215 (372sorgenti) sposta la verifica dell'ordinamento CSR a
Copy_Edge_Rows durante il caricamento, aggiunge un'invariante Static sui due
oggetti privati e rimuove il controllo Valid_Chain dal preflight per-frame.
Il loader è separato in una child privata; le formule e l'ordine delle operazioni
di dinamica sono invariati. La scansione per-frame non è ancora rimossa in
produzione: candidato e controlli di colonne duplicate/invertite restano fuori
produzione finché la composizione viene verificata.

Minime r216–r222 sulla medesima closure r215:108proof+9flow=117chiusi,
nessun obbligo aperto. Rows63+1,Chain18+1,Admission13+2,Model4+2,Engine4+2,
Factory3+1,Free3+0. Le warning preesistenti di modelli ricorsivi e Sqrt restano
nelle rispettive ricevute; Chain/Model/Engine hanno zero warning. Le prove di
wrapper/factory sono sotto i contratti dei chiamati: Load e conservazione
dell'invariante in Evaluate_Model sono ancora aperti. Non attribuire questi
117check alla dimostrazione globale del costruttore o della dinamica.

Il collector riconosce ora una dichiarazione sovraccaricata solo se la firma
corrisponde al corpo richiesto, e segue l'unità privata del loader quando presente.
14/14 regressioni del collector passano, inclusi rifiuto di altro overload e
firme ambigue. Il precedente r213, rifiutato correttamente per provenienza
insufficiente, resta conservato; i risultati acquisiti sono nuove invocazioni.
Ricevute e patch candidata: `evidence/20261003-ordered-csr/`.


## 2026-10-03 — allocazione scalare r225 e runtime CSR ordinato

R223, minimo Load su r215, raggiunge il watchdog di240.1s con RSS2121MB.
Non produce report; nessun conteggio di proof/flow è assegnato a questa prova.
La ricevuta preservata sostituisce esplicitamente lo stato precedente «running».
Questa è prova incompleta, non un limite matematico e non una giustificazione Silver.

R224 freeze fallisce prima del manifest finale perché il builder leggeva dal
checkout il nuovo child che esisteva soltanto nella closure congelata. R225 è
una nuova snapshot: il builder registra quel file come differenza e ne verifica
l'hash nella sorgente base; non introduce fallback live. Il fallimento precedente
non viene attribuito alla nuova snapshot.14regressioni collector e2overlay passano.

R225 separa Allocate su sole dimensioni scalari e documenta la precondizione
privata S=null già controllata dai due costruttori. Nessuna precondizione pubblica
aggiunta. R226 chiude47proof,0flow, zero aperti, copertura minima completa:
dimensioni/capacità, lunghezze e forma della struttura allocata sono funzionali.
Strict pass FALSE conserva5warning degli antenati ricorsivi. Whole Load,
conservazione CSR in Evaluate_Model e la dinamica globale restano aperti;
i117check di r215 non sono riassegnati a questa nuova closure.

R227 validation/r228 release completano la stessa closure372file:
152/152admission,342/342equality e234/234contact×100 passi per profilo.
Sorgenti/progetto/test, record e12/684/702file XML/MJB/input/expected/output
sono identici. Nessuna misura prestazionale è stata svolta. Queste sono prove
numeriche della bozza, non una chiusura formale del caricamento completo.

Precisazione sui test: il refresh tests in r215 aveva conservato i152controlli
precedenti; i due nuovi rifiuti di colonne duplicate/invertite di r209 non erano
presenti in r215/r225. R229 ripristina solo flex_load_checks.adb da quella patch.
Tutti gli altri371file restano identici a r225. R230/r231 ricompilano nei due
profili e passano164/164controlli:47slides,47shared,47free,23Nv0; i12file delle
fixture e degli output sono identici. Questi binari hanno nuova numerica solo
per admission; non si attribuisce loro un secondo run dei342/234corpora.
L'implementazione runtime resta esattamente quella confrontata in r227/r228.

La scansione Valid_Chain per-frame rimane in produzione. La patch completa
`candidate-with-allocation-and-admission-tests.patch` include child, ordinamento,
invariante Static, allocazione e test; è reviewabile ma non applicata al runtime
live finché composizione Load e frame dell'evaluazione non sono dimostrati.
Ricevute portabili: `experimental/flex-elasticity-integration/evidence/20261003-ordered-csr/`.
Prossimo confine formale: caricamento dei materiali in child con Sizes/Flex/Body/Dof
al posto di Model completo e frame sui campi CSR, poi i chiamanti minimi.

R232 rinnova Create_Forces su r225:4proof+1flow chiusi, comprese le nuove
precondizioni private sul handle vuoto;2warning Sqrt esistenti conservate,
strictfalse. Il successo resta dimostrato sotto la post di Load non ancora
chiusa: nessuna Gold completa del costruttore attribuita.

## 2026-10-03 — materiali, vertice e bordo r233–r243

Il precedente turno ha prodotto evidenza utile: la seconda revisione upstream
confermata e la prova minima r242 è terminale. Il goal completo rimane attivo;
non c'è un blocco esterno. Il divario prestazionale integrato e il completamento
del port non vengono dichiarati risolti da queste prove locali.

R233 separa Material_Loading in child privata, con sole Sizes/Flex/Body/Dof e
Storage, al posto dell'intero Model. R234 aggiunge il guard Static sulle dimensioni
FLEX. La minima Load r235 raggiunge ancora il watchdog240.2s/RSS1510MB e non
produce un report: nessun conteggio ereditato. Rimane prova incompleta.

R236 separa Load_Vertex. R237 chiude23proof+2flow; r238 corregge la descrizione
dell'ammissione. La revisione indipendente dei servizi conferma ordine
Allocate/CSR/materiali, azzeramento dello stato Success dopo ogni helper e assenza
di nuove scritture a colonne/rowadr/rownnz. Precisa due differenze per modelli
malformati: il nuovo controllo rifiuta anche blocchi locali positivi fuori Nv
quando la radice saldata è valida; Offset viene valutato prima dei vecchi controlli
Width/Simple. Questo può cambiare il punto di fallimento e la mutazione privata
parziale, senza un nuovo frame pubblico su uno Storage rifiutato. Il costruttore
libera la struttura in caso di Invalid_Model.

R238 separa Load_Edge con frame incondizionale su Rowadr/Rownnz. R239 lascia un
range check nella precondizione: conversione implicita di Bending_Data'Length.
R241 esplicita il confronto Int64 senza restringere il dominio e rafforza le post:
due estremi, catena, rest/weight/rigid, flap, flag bending, copia esatta dei17
coefficienti oppure conservazione dei campi bending non caricati.

R242 chiude42proof+2flow e r243 rinnova Load_Vertex23proof+2flow sulla stessa
closure r241,374file, manifestSHA
21e7de62e39310d3a5a8f35515a205f9b441fbdfda2de2eb12aca5940c237d6f.
Entrambe hanno copertura minima completa, zero obblighi aperti e5warning ricorsive
preservate; strict pass resta FALSE. Whole Material_Loading/Loading, conservazione
CSR nell'evaluazione e composizione dei chiamanti sono ancora separate e aperte.

R240 aggiunge una fixture compilata C con un vertice su figlio saldato, controlli
Width/span locali e Simple errato combinato con Offset eccessivo. Il profilo
validation r244 è già completo:229/229ammissione,342/342equality e234/234contact
per100passi. La somma osservata dell'ammissione è53welded+47slides+53shared+47free+
29zero_dofs; i nuovi controlli si attivano anche sulle altre fixture con figli
saldati. Il profilo release r245 è ancora in esecuzione; non si attribuiscono
gli esiti validation alla release o a r246.

R246 è una nuova bozza congelata che separa gli elementi e il disimballaggio della
matrice, con modello Ghost dell'ordine triangolare. Il sorgente ufficiale stabile
engine_passive.c, commit9ecbb9d7b5ee623f54745638d36799ff90e6f7cd,
SHA1f5ada258eae6556dfdeb5f46dbf067466f66909819d0ceef95320aca079ba36,
è stato ricontrollato direttamente:3/6bordi, stride21, scrittura superiore e
simmetrica nello stesso ordine. Nessuna nuova prova o numerica di r246 acquisita
al momento di questa nota.15regressioni collector passano; sono test di
provenienza, non dimostrazioni SPARK. Ricevute, fallimenti e patch reviewabili in
experimental/flex-elasticity-integration/evidence/20261003-material-loading/.
Le bozze r241/r246 non sono applicate al runtime live; nessun timing svolto.

R245 release è ora terminale e passa gli stessi229/342/234controlli. Le374sorgenti
di entrambi i profili coincidono esattamente col manifest r241 e tutti gli hash
sono verificati.15file admission,684equality e702contact sono byteidentici; anche
tutti i record numerici coincidono. Receipt runtime-r244-r245.json e log distinti
preservati. Questi sono nuovi run completi dei due binari, non un'eredità di r227
o r230. I confronti non dimostrano Gold universale né prestazioni e non vengono
attribuiti a r246, che contiene una nuova estrazione degli elementi.

Revisione read-only dei servizi su r246 vs r241: nessun blocco individuato.
Packed_Row_First restituisce[0,3,5,6] aWidth3 e[0,6,11,15,18,20,21] aWidth6;
il triangolo2D consuma6valori e ignora15padding del blocco21 come C. F64_OK
impone Stiffness nonnull anche a lunghezza0, quindi il nuovo .all nel casoKA=-1
è ammesso. La post di successo preserva il quarto vertice, gli ultimi3bordi e
le celle fuori3x3 in2D; tuttaM quandoKA=-1. Il controllo Coefficient esplicita il
precedente rifiuto per Constraint_Error. Nessun frame su fallimento promesso.
La revisione non contiene una nuova esecuzione o una prova formale.

R247 chiude la minima Packed_Row_First8proof+2flow sulla closure r246, con
5warning preservate. R248 Load_Metric completa48obblighi,44chiusi e4aperti:
inizializzazione/conservazione degli invarianti delle uguaglianze e post finale.
Non è una limitazione matematica. R249 esprime proprietà equivalenti del triangolo
superiore, copia simmetrica e frame esterno, evitando Min/Abs nel modello.
Il confronto testuale dei corpi eseguibili dopo rimozione dei soli pragma Static
conferma che Load_Metric/Load_Element sono invariati; non è una nuova esecuzione
né una dimostrazione del compilatore. Minima matrice r250 in corso sulla nuova
closure; ricevute negative r248 preservate, nessun conteggio attribuito a r250.

R250 termina prima della prova: confronto della matrice intera senza visibilità
dell'operatore K.Metric. Il collector non trova report e non eredita i conteggi.
R251 aggiunge soltanto use type K.Metric; minima r252 avviata su nuova analysis
con manifest esatto. Il fallimento sintattico precedente e il supplemento sono
preservati separatamente; nessuna modifica del calcolo runtime o degli input.

R252 termina143.8s/RSS483MB:119chiusi su122proof+1flow, restano4overflow
intermedi nelle sole espressioni Static Address+RowStart+Column-Row.
Le uguaglianze, simmetria e frame sono chiusi su questa formulazione; la specifica
completa non è ancora verificata. R254 raggruppa RowStart+Column-Row prima della
somma con Address, senza limitare gli input vicini aInteger'Last o cambiare FP.

R253 separa anche i metadati di un singolo FLEX, con post esatte su dimensione,
range vertici/bordi/elementi, indirizzi coefficienti, flag e parametri materiali.
R254 usa C in out e pubblica l'aggregato solo dopo i controlli, preservando il
precedente record sul rifiuto invece di scrivere un default preliminare. Il reset
di Result dopo Success resta nel chiamante. Le contiguità dei blocchi rimangono
controllate dal Load esterno. Bozza r254 congelata,374file; minime r255Metric,
r256Element,r257Flex,r258RowFirst seriali sulla stessa analysis e manifesto,
senza un secondo heavy root. Non si attribuisce ancora un esito a tali minime.
Patch cumulativa candidate-r254.patch preservata, senza applicazione live.

R255 Load_Metric chiude122proof+1flow, zero aperti/copertura minima completa,
5warning preservate. Uguaglianze esatte del triangolo e del simmetrico, frame
fuori blocco e sicurezza sono ora dimostrati nella stessa formulazione.
R256 Element termina50chiusi su51proof+2flow,3aperti: bounds delle somme VA+source
e EA+source nelle post, e uguaglianza fra le celle speculari. Il batch si ferma;
nessuna esecuzione di r258 viene dedotta. R257 Flex eseguita separatamente chiude
117proof+1flow, zero aperti/copertura minima completa,5warning conservate:
copia esatta dei metadati/materiali e span source validati.

R259 non cambia il runtime rispetto a r254: rafforza post/invarianti Element con
i limiti degli indici source prima della somma e lega entrambe le celle della
matrice allo stesso valore source. Minime r260–r265 sulla stessa nuova closure
sono un batch seriale, iniziato da Element. La numerica della closure r259 è
soltanto preparata per r266/r267, non eseguita. I numeri acquisiti di r241/r254
restano legati alle rispettive snapshot e non sono ereditati da questa bozza.

R260 termina99.1s/RSS477MB con63chiusi e1post source vertices aperta. Il batch
si ferma prima di r261–r265; tali scope non hanno ricevute. R268 trasporta
esplicitamente la validità dei source vertices attraverso il ciclo sui bordi.
R269 termina97s/RSS477MB,70chiusi su69proof+2flow; la post vertices è chiusa,
resta soltanto la post source edges. Tutti gli altri frame, mapping e bounds
sono chiusi ma la minima completa resta incompiuta; nessuna eccezione Silver.

R272 esprime la traduzione esatta degli indici nella post tramite Int64 insieme
allo span degli output. La nuova Source_Range_Lemma Ghost dimostra separatamente
che span+traslazione implica i bounds source originali. Non cambia il corpo
eseguibile o le precondizioni di Load_Element. Minima del lemma r273 in corso;
non si assume la sua post né si dichiara chiuso Element. Minime r274–r279 e
numerica r281/r282 soltanto preparate; nessuna esecuzione ereditata dai draft.

R273 Source_Range_Lemma chiude2proof+1flow, copertura minima completa e zero
aperti,5warning ricorsive conservate. La revisione indipendente dei servizi
conferma l'equivalenza della post r272 con quella r268 sotto le stesse pre:
span+uguaglianza Int64 implica0<=Source<Count; il bound originario rende sicura
la somma Integer e coincide con quella Int64. Count0 non consente successo in
entrambe. Pre/pubblica spec/runtime e tutti i frame, padding e KA=-1 invariati.
Il batch r274–r279 è ora effettivamente avviato sulla stessa analysis r272,
iniziando dalla minima Element; non si dichiara un risultato fino al report.


R274–r279 terminali sulla medesima closure r272: Element65, Metric123, Flex118,
RowFirst10, Vertex25, Edge44 =385controlli chiusi, zero obblighi aperti in tutti
i sei minimi. Ogni scope conserva5warning ricorsive; strict pass resta FALSE.
Il lemma r273 rimane separato (3controlli). Nessuna prova whole Load/caller né
runtime r281/r282 viene attribuita: questi ultimi non sono stati eseguiti.
Ricevute, log e manifest della closure copiati in evidence/20261003-material-loading
per la pubblicazione richiesta. La scansione live Valid_Chain resta presente.
