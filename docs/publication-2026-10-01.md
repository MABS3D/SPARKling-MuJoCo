# Pubblicazione del 1 ottobre 2026

Questo checkpoint raccoglie gli aggiornamenti successivi al commit `380d9fc3`,
confrontati con il branch remoto `spark-port`. Il riferimento è MuJoCo 3.14.0,
commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. La consegna comprende sorgenti,
contratti, prove, confronti con C, misure e snapshot intermedi.

## Jacobiani dei tendini nel percorso attivo

La fase dei tendini spaziali legge direttamente i buffer piatti dei Jacobiani
lineari e angolari: elimina le due conversioni complete in `Body_Jacobian`.
L'API precedente rimane disponibile e condivide lo stesso valutatore del
percorso. Il probe standalone confronta entrambe le API, inclusi stato,
lunghezza, riga del Jacobiano, punti e risultati di fallimento.

Le prove locali chiudono 56 obblighi su lettura, validazione e wrapper. La
prova dell'intero percorso resta aperta: il report diagnostico registra 159
obblighi non chiusi al budget indicato. I tempi del passo completo non mostrano
un vantaggio stabile rispetto alla precedente Ada; la parità con C non è
raggiunta. Rimangono la costruzione della cache densa e la visita di tutti i DOF.

[Modifica, risultati e limiti](tendon-jacobian-views.md).

## Nuovi candidati isolati

| Consegna | Contenuto e verifica | Ambito ancora aperto |
|---|---|---|
| [Materiali elastici e di contatto](../experimental/materials-candidate/README.md) | Coefficienti elastici, metriche triangolari/tetraedriche, smorzamento; priorità, miscelazione, attrito, adesione e override dei contatti. Due unità complete: 199 controlli chiusi, zero aperti e zero avvisi. | Collegamento al compilatore del modello, geometria dei flex, accumulo delle forze e solver dei vincoli. |
| [Collisioni rigide](../experimental/rigid-collision-candidate/README.md) | Broad phase e filtri, 21 combinazioni di primitive, precontatti GJK/EPA, mesh convesse, heightfield, parametri e frame. Test numerici e prove modulari archiviate. | Unificazione del driver dei contatti, BVH, SDF/flex, vincoli, collegamento alla dinamica e prova globale. |
| [Indici delle mesh convesse](../experimental/rigid-collision-candidate/results/20261001-mesh-mesh/README.md) | Asset condivisi, grafo compatto, mappa vertice–faccia e clipping senza copie ripetute. `Convex_Assets` e `Contact_Incidence`: 467 obblighi di prova e 63 controlli di flusso chiusi. | Correttezza geometrica globale di GJK/EPA e clipping, chiamanti e parità prestazionale su tutti i casi. |

I materiali passano, per profilo, 3.072 casi algebrici con 101.376 valori identici
bit per bit, 64 casi aggiuntivi di zeri con segno, 96 contatti prodotti dal C
e 32 matrici flex compilate dal riferimento. I nove rifiuti di dominio sono
verificati nel profilo checked. Le misure del triangolo e dei contatti misti
mostrano miglioramenti nei kernel isolati; non misurano il beneficio di un
passo completo della simulazione.

La suite corrente delle mesh conserva confronti checked/release di primitive,
testimoni GJK/EPA e coppie mesh in entrambi gli ordini. Le discrepanze del C
diagnosticate, i limiti delle normali, i crash del riferimento su specifici
terreni e i tentativi di prova falliti restano espliciti nei rapporti. Le mesh
sono hull convesse, non superfici concave generali. I benchmark delle sole
coppie, dei precontatti per coppia e del passo completo hanno ambiti diversi:
non vengono usati per dichiarare parità dell'intero motore.

Questi candidati sono pubblicati separatamente. Non abilitano collisioni o
materiali nella pipeline smooth, che richiede ancora vincoli disabilitati.
Gold riguarda i contratti indicati nelle prove complete e modulari; timeout e
modelli mancanti restano lavoro di dimostrazione.

## Controllo della pubblicazione

Una nuova build con controlli runtime abilitati sui sorgenti combinati correnti
passa 400 scenari di giunti/regressioni scalari e 320 di tendini/regressioni,
per **67.528 confronti con C** a tolleranze assolute/relative `2e-10`.
Passano anche 32 scenari limite, il modello ball da 280 coordinate/210 DOF
e i due rifiuti espliciti di ball/free combinati con tendini spaziali.
I modelli scalari si sovrappongono fra le due suite; i conteggi non sono
percentuali di copertura di MuJoCo.

Gli hash dei sorgenti, i checksum dei pacchetti e l'integrità dei nuovi archivi
sono verificati. Il manifest delle misure mesh coincide con tutti i sorgenti
di produzione: differisce soltanto lo script di benchmark, successivamente
esteso per confrontare due layout nello stesso binario. Lo script originale
e tutti i 66 file del manifest sono conservati nello snapshot misurato;
il driver supplementare ha una propria impronta. Nessun report storico viene
riscritto per attribuirlo a un sorgente diverso.

Sono conservati anche i 67 log testuali di GNATprove elencati nel checksum delle
mesh e normalmente esclusi dalla regola `obj/`. I prodotti di compilazione
esterni non vengono aggiunti alla cartella di lavoro. I worktree di tendini
fissi e forze passive non lineari coincidono con gli snapshot già pubblicati.

[Risultati freschi e audit](../tests/publication/2026-10-01/README.md),
[checkpoint precedente](publication-2026-09-30.md).
