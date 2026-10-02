# Rilevamento delle collisioni rigide — candidato isolato

Implementazione Ada/SPARK indipendente del rilevamento delle **coppie di
geometrie rigide in collisione**, e dei **precontatti geometrici**, riferita a MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. L'ultima versione stabile è stata
controllata il 2 ottobre 2026: [release ufficiale](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0).
La versione e gli hash delle sorgenti C esaminate sono in
[results/reference.json](results/reference.json).

È la prima fase richiesta: piano, sfera, capsula, ellissoide, cilindro e box,
con tutte le **21 combinazioni non ordinate**, inclusa piano–piano, che non
produce collisioni. Il codice di produzione di questo candidato non chiama C.
Il programma di confronto, invece, usa la libreria nativa ufficiale MuJoCo.

La seconda fase aggiunge distanza/profondità, posizione, normale, tangente e
manifold delle primitive; supporti e facce delle mesh convesse; contatti del
terreno heightfield; materiali, attrito, adesione e frame dei contatti completi.
Il driver `Rigid_Detector` continua a restituire coppie; `Collision_Scene`
riusa la sua selezione e produce direttamente i contatti completi di scena;
le API dei contatti sono descritte in [CONTACTS.md](CONTACTS.md).

**Non è completato il rilevamento generale di MuJoCo:** mancano SDF, gestione
completa dei flex, costruzione dei vincoli e collegamento alla
dinamica. La Gold dell'intero motore dei contatti e la parità prestazionale
restano aperte. I risultati della prima fase sulle sole coppie non dimostrano
la parità sui contatti completi o su una simulazione completa.

## Implementazione

- `MJ.Rigid_Detector`: inizializzazione dei metadati immutabili; coppie esplicite,
  esclusioni fra corpi, maschere unsigned, filtri dei corpi saldati, genitori,
  corpi statici e stato di riposo fornito dal chiamante. Le coppie esplicite
  precedono la ricerca e scavalcano i filtri corrispondenti, come nel riferimento.
- `MJ.Collision_Scene`: selezione condivisa delle coppie e generazione dei
  contatti completi per primitive, hull convessi e heightfield. Usa
  `Find_Candidates`, senza eseguire prima il test geometrico booleano;
  conserva l'associazione ai parametri delle coppie esplicite e il riuso degli
  endpoint e delle rotazioni. Dettagli in [SCENE.md](SCENE.md).
- Broad phase sweep-and-prune con endpoint compatti, riuso dell'ordine fra frame,
  riparazione incrementale e ripiego sul mergesort. Usa l'asse di maggiore
  estensione oppure una diagonale per distribuzioni quasi isotrope. Controlla
  anche AABB secondarie e sfere di ingombro. Raggruppa le geometrie per corpo
  quando conviene, per scartare insieme gruppi incompatibili.
- `MJ.Rigid_Narrowphase` e `MJ.Rigid_Primitives`: algoritmi specifici per
  piano–primitive, sfera–sfera/capsula/cilindro/box, capsula–capsula/box e box–box.
  La distanza segmento–box della capsula usa la minimizzazione di una funzione
  quadratica a tratti. Box–box comprende SAT sui 15 assi e le decisioni sulle
  caratteristiche geometriche del riferimento.
- `MJ.Rigid_Support`, `MJ.Rigid_Simplex` e `MJ.Rigid_CCD`: supporti analitici delle
  primitive, riduzione del simplex secondo Montanari, GJK e ricerca ausiliaria
  d'intersezione del riferimento. Per la decisione booleana vengono riprodotti
  i controlli di ammissione del politopo usati da C. Il percorso booleano rimane separato dal nuovo `Convex_Contacts`, che
  conserva i testimoni del simplex ed espande il politopo EPA per produrre
  distanza, profondità, normale e punto di contatto.
- `MJ.Rigid_Math`: operazioni vettoriali binary64 e trasformazioni con modelli
  funzionali che conservano l'ordine delle operazioni in virgola mobile.

Il confronto con C ha guidato i supporti, l'ordine delle operazioni GJK, i
filtri, i margini e le decisioni sui casi degeneri. La broad phase resta
diversa: mancano il BVH dei corpi di C e il suo sistema di assi da covarianza.
Non si sostiene che l'algoritmo complessivo sia identico a C.

## API e limiti

Chiamare `Initialize` con forme, filtri, coppie esplicite ed esclusioni; poi
`Detect` con le pose aggiornate e un `Pair_List` riutilizzabile. `Scene` possiede
metadati e spazio di lavoro: la ricerca non alloca memoria. Il chiamante può
allocare la scena e il buffer dei risultati una volta, prima della simulazione.
Per modificare le forme o i filtri occorre reinizializzare la scena.

Il risultato contiene ID canonici `First < Second`; il consumatore non deve
presupporre l'ordinamento globale del buffer. `Candidate_Count` e
`Narrowphase_Count` permettono di analizzare il lavoro svolto.

Per produrre i contatti di scena usare `Collision_Scene.Initialize` e
`Collision_Scene.Generate`, con un `Full_Array` del chiamante. Per consumatori
diversi è disponibile `Rigid_Detector.Find_Candidates`: le coppie selezionate
possono essere separate, perché la selezione comprende soltanto broad phase,
filtri e sfere di ingombro. Il suo `Narrowphase_Count` rimane zero.

Limiti dichiarati: 4.096 geometrie, 65.536 coppie, ID dei corpi a 16 bit,
coordinate e dimensioni fino a `1e10`. Le dimensioni richieste sono positive.
Le pose non sferiche richiedono matrici ortogonali entro `1e-10`; la validazione
della rotazione viene riusata se la matrice non cambia. L'orientamento della
sfera non influisce sul risultato booleano. `Find_Candidates` richiede e
valida anche il frame delle sfere, necessario ai generatori dei contatti.

Un errore segnalato dall'API restituisce `Invalid_Input`, `Capacity_Limit`, `Numeric_Limit` oppure
`Iteration_Limit` e azzera la lunghezza del risultato; un superamento del
buffer non viene presentato come ricerca completa. Il contratto di questo
comportamento nel driver è ancora da dimostrare integralmente. I test non
certificano tutto il dominio numerico ammesso dai tipi, specialmente le
dimensioni subnormali o i rapporti di forma estremi.

`Explicit_Pair.Margin` è il margine effettivo **già comprensivo del gap**.
Per le coppie automatiche si sommano margini e gap delle due geometrie, come
nel driver 3.14.0. La determinazione delle isole addormentate è esterna: il
candidato riceve `Pose.Asleep`, non implementa il gestore del riposo di MuJoCo.

## Correttezza e prove

Le evidenze della build consegnata sono in [results/20261001](results/20261001),
con [stato delle prove](results/20261001/proof-status.json) e
[risultati misurati](results/20261001/README.md). Distinguere
tre risultati:

1. **Test differenziali:** 21.000 casi di coppia per profilo, 30 scene statiche,
   17 casi di filtri e 80 frame con pose variabili. I profili con controlli
   attivi e release devono entrambi passare. I casi di movimento includono
   cambi improvvisi delle pose per esercitare il ripiego dell'ordinamento.
2. **Prove complete delle unità di base:** `Rigid_Geometry` e `Rigid_Math` hanno
   report freschi. La prima dimostra, fra l'altro, la canonicalizzazione degli
   ID. La seconda dimostra le relazioni componente per componente, le
   riduzioni ordinate, la composizione delle trasformazioni e i rami della
   normalizzazione, sotto le rispettive precondizioni.
3. **Prove parziali del rilevatore:** impacchettamento degli ID e ricerca binaria
   sono verificati separatamente rispetto ai loro modelli, con la precondizione
   di ordinamento della porzione di array cercata; questo non chiude
   l'unità del driver. Gli eventuali report `--mode=flow` verificano flusso e
   inizializzazione, non costituiscono una prova Silver o Gold completa.

La radice quadrata di runtime è un confine esplicito del modello: GNATprove
segnala sette avvisi `imprecise-call` nei report completi della matematica.
La composizione con tale runtime è verificata; non è dimostrata qui
l'implementazione della libreria né un limite d'errore rispetto ai reali.
Gli avvisi non sono soppressi. Non sono state introdotte assunzioni per far
passare gli obblighi.

**Gold globale resta aperto**, così come la prova completa di sicurezza delle
unità del driver, dei supporti, delle primitive, del simplex e del CCD. Restano
da modellare e provare in particolare completezza della broad phase, arrotondamento
conservativo degli ingombri, assenza di duplicati, corrispondenza delle decisioni
geometriche e proprietà dei simplex. Un timeout o un modello ancora assente
sono lavoro di prova incompleto, non un'eccezione matematica che autorizzi a
dichiarare completato Silver.

### Differenze intenzionali rispetto a C

I 21.000 casi non hanno errori inattesi, ma **539 decisioni differiscono da C**
in ciascun profilo. Le differenze sono registrate singolarmente in
`numerics.json`, con gli input conservati:

- 536 casi con centri coincidenti nelle combinazioni servite dal CCD di C:
  primitive con dimensioni positive condividono un punto interno, mentre
  il CCD 3.14.0 può uscire senza simplex e senza contatto;
- 3 casi capsula–box con centri coincidenti, anch'essi intersecanti, che
  l'euristica delle caratteristiche di C non segnala.

La giustificazione indipendente in questi 539 casi è geometrica: il centro
comune appartiene all'interno di entrambe le primitive. Il test contiene anche
un controllo segmento–AABB con aritmetica Decimal a 100 cifre per eventuali
altre discrepanze capsula–box; non va confuso con la giustificazione dei casi
coincidenti. Non si dichiara equivalenza universale o bit per bit con C.

## Prestazioni: ambito del confronto

I benchmark confrontano `Detect` con **`mj_collision` nativo ufficiale**, con
scene identiche e verifica delle coppie risultanti. C produce anche i contatti
completi: il confronto svolge lavoro diverso. I risultati sono utili per
valutare il costo della ricerca delle coppie, ma **non dimostrano parità a
parità di output**, né prestazioni di un passo completo della simulazione.

Preparazione dei modelli, pose, allocazioni e I/O sono fuori dal cronometro.
Il tempo include la validazione delle pose e i filtri del candidato. Si
alternano C e Ada, si vincola l'affinità a una CPU e si verifica il checksum
dei risultati. Il rapporto è la mediana dei rapporti appaiati Ada/C, con
intervallo bootstrap al 95%; le misure grezze conservano la dispersione.
Il benchmark statico include 20 scene; quello di movimento include 12 scene
con 16 pose precomputate ciascuna. Non viene mediato un insieme di percentuali
per fingere un risultato aggregato di simulazione.

La release Ada usa GNAT/GCC 16.1, `-O3 -gnatp -gnatn -march=native -flto
-ffp-contract=off`; la build di validazione mantiene asserzioni e controlli.
La release è sperimentale: la rimozione dei controlli precede la chiusura
delle prove globali e non costituisce una configurazione di produzione
formalmente garantita. Il wrapper C usa `-O3 -march=native -flto
-ffp-contract=off`; le opzioni con cui è stata compilata la libreria ufficiale
precompilata non sono note. Il riferimento conserva i suoi percorsi SIMD.

## Riproduzione

Servono GNAT/GPRbuild/GNATprove, Python con NumPy e MuJoCo 3.14.0, GCC, le
sorgenti C della versione indicata e gli header libccd. `tests/common.py`
contiene i percorsi della configurazione locale usata e verifica la versione
della libreria. Il watchdog della repository limita la memoria dei processi.
Eseguire dalla directory del candidato, scegliendo una directory di output
nuova:

```sh
python tests/check.py --out /var/tmp/rigid-collision-check --samples 1000
python tests/prove.py --out /var/tmp/rigid-collision-check --flow --filters
python tests/benchmark.py --out /var/tmp/rigid-collision-check --rounds 11
python tests/benchmark_motion.py --out /var/tmp/rigid-collision-check --rounds 11
```

La prima chiamata congela le sorgenti, costruisce entrambi i profili e il
wrapper di riferimento, registra gli hash, poi esegue i test. Le chiamate
successive usano quella fotografia. `--full` nel programma delle prove
richiede ulteriori tentativi sulle unità ancora aperte e conserva gli
obblighi non risolti; non va scambiato per una certificazione già ottenuta.
Non eseguire solver e benchmark contemporaneamente.

## Lavoro necessario per completare l'ambito richiesto

1. Completare le proprietà geometriche dei manifold già implementati. La
   discrepanza capsule–cilindro è risolta; la miscelazione dei parametri e
   l’inflazione dei punti hanno prove funzionali complete.
2. Chiudere le prove delle unità di collisione e propagare i contratti ai
   chiamanti, senza scambiare i test differenziali per dimostrazioni.
3. Collegare il rilevatore alle API dei contatti e ai dati della dinamica,
   applicare le opzioni di scena e generare i vincoli; misurare traiettorie
   equivalenti complete. Materiali, frame e override sono disponibili per coppia.
4. Aggiungere BVH e assi da covarianza dove i profili ne dimostrano il vantaggio.
5. Completare le geometrie avanzate: SDF, strutture flessibili e BVH. Mesh
   convesse e heightfield sono implementati per coppia. Mancano anche callback,
   propagazione dell'override alla broad phase e varianti/threading del backend C.

Le copie della base Ada appartengono solo a questo progetto isolato. Le
attribuzioni e la licenza delle parti adattate dal riferimento sono in
[NOTICE](NOTICE) e [LICENSE.upstream](LICENSE.upstream).
