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
