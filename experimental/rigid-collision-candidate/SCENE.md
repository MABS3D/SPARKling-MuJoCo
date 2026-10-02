# Ricerca condivisa delle coppie — 2 ottobre 2026

`Rigid_Detector.Detect` e `Find_Candidates` usano la stessa `Traverse`:
endpoint, assi, AABB, sfere di ingombro, raggruppamento per corpo, maschere
unsigned, saldature, genitori, esclusioni, riposo e coppie esplicite.
`Detect` conserva il test booleano e il suo comportamento precedente;
`Find_Candidates` seleziona le coppie e i loro metadati senza chiamarlo.
La capacità si applica alle coppie accettate dal percorso scelto: nei contatti
di scena è una capacità di candidati, non soltanto delle coppie in contatto.

`Collision_Scene.Initialize` prepara metadati, materiali e parametri espliciti.
`Generate` chiama `Find_Candidates` e poi un solo generatore per ogni coppia
selezionata con una funzione di collisione supportata. Non antepone `Test`
al generatore GJK/EPA o alle routine analitiche. La normale viene ripristinata
nell'ordine degli ID canonici anche quando il terreno ha il secondo ID.
Le combinazioni terreno–piano e terreno–terreno restano vuote, come nella
tabella di dispatch di MuJoCo 3.14.0.

Ogni candidato conserva margine di rilevamento e indice della coppia esplicita
nell'ordine di ingresso; zero indica una coppia automatica. Ordinare le chiavi
per escludere duplicati non riordina quell'associazione. I parametri delle
coppie automatiche sono miscelati/configurati una volta prima della generazione;
quelli espliciti sono configurati all'inizializzazione. `Declared_Pair.Margin`
e `Gap` sono separati; in `Rigid_Detector.Explicit_Pair.Margin` il gap è già
incluso. Il dominio di quest'ultimo è esteso a `4e10` per contenere le somme
ammesse, senza restringere i precedenti ingressi.

Le primitive usano i loro ingombri analitici. Hull e prismi usano box contenenti
le coordinate locali dei vertici, compreso `Skin`; i terreni usano il box
`[±Half_X, ±Half_Y, ±max(Height, Base)]`. Questi box servono alla selezione,
mentre il generatore riceve la geometria reale. I vertici decentrati sono
inclusi direttamente; `Center_Offset` resta il seme di GJK. Dimensioni oltre
il profilo `1e10` restituiscono `Numeric_Limit`. Non sono introdotti BVH o assi
da covarianza.

L'override del margine è usato esattamente nella sfera di ingombro e nel
generatore (`Override.Margin + gap`). Le AABB sono conservativamente espanse
del margine intero per geometria, invece del mezzo margine di C: possono
produrre candidati aggiuntivi. Questo evita anche l'arrotondamento a zero del
mezzo margine subnormale; non costituisce una dimostrazione generale di
accuratezza per forme estreme. L'override disabilitato mantiene i margini
precedenti.

Scene e buffer sono riutilizzabili; nessuna allocazione per frame o contatto.
Il chiamante possiede un `Full_Array` di capacità scelta, anche con origine
diversa da zero. Soltanto il prefisso indicato da `Length` è valido. Qualunque
fallimento azzera quel prefisso logico; le celle già scritte non sono esposte
come risultato completo. Per cambiare metadati, materiali, filtri o override
occorre reinizializzare. `Assets_Admissible` richiede che gli asset successivi
restino validi e contenuti negli ingombri installati; il contratto non viene
rivalidato tramite una scansione degli asset in release. La validazione delle
pose viene effettuata dalla ricerca condivisa, riusando le rotazioni già
ammesse e includendo i frame delle sfere richiesti dai generatori.

## Verifiche

I test `check_scene.py` confrontano 270 casi nei profili validation/release:
scene primitive, filtri, 80 frame, campi dei contatti completi, hull decentrati,
terreni nei due ordini, margini/gap/override, capacità dei candidati e dei
contatti, duplicati e associazione dei parametri espliciti. L'oracolo è MuJoCo
3.14.0 ufficiale. `check.py` li esegue insieme alle regressioni precedenti.
Sono confronti sul corpus, non una prova di equivalenza universale con C.

Le prove partono da `Append_Pair`, `Expanded` e `Make_Proxy`. Dimostrano
rispettivamente registrazione canonica e metadati con conservazione delle
coppie precedenti; aggiornamento binary64 delle estensioni; contenimento
locale dei vertici e validità del proxy nel profilo dichiarato. Questi risultati
non chiudono la Gold della traversal, dei generatori geometrici o del driver
completo. Gli obblighi residui sono ingegneria di prova da completare, non
eccezioni Silver giustificate dalla virgola mobile.

Le [misure della fase collisioni](results/20261002-scene-performance/REPORT.md)
includono ricerca e contatti completi, su 16 pose precalcolate e 31 serie
alternate: il percorso unificato riduce il costo dei misti del 14–25% rispetto
alla ricostruzione a due passaggi, ma rallenta alcune scene sparse piccole.
Restano regressioni rispetto a C sui terreni e sul misto a 32 geometrie.
Nei misti grandi le normali C differenti impediscono un rapporto di parità
fisica, pur confermando il miglioramento Ada prima/dopo. Cinematica, vincoli,
dinamica e integrazione non sono misurati: la parità della simulazione completa
resta da verificare.

Evidenze della build finale: [results/20261002-scene-search](results/20261002-scene-search),
con [stato delle prove](results/20261002-scene-search/proof-status.json), hash
delle sorgenti e dei binari, versioni dei compilatori e log. I tre helper
chiudono 41 verifiche (14 + 7 + 20); l'analisi flow passa per entrambe le unità.
I due tentativi di prova delle unità intere sono stati interrotti dal limite
di 180 secondi ciascuno, senza completamento: non sono risultati Gold o Silver
complessivi. Non sono state aggiunte assunzioni o soppressioni.

```sh
/var/tmp/sparkling-movement-env/bin/python tests/check.py --out /var/tmp/scene-check --samples 300
/var/tmp/sparkling-movement-env/bin/python tests/prove_scene.py --out /var/tmp/scene-check --whole
```
