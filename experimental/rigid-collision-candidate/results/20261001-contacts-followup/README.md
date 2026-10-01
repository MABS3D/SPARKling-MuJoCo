# Collisioni: correzioni, prove e prestazioni — 1 ottobre 2026

Il lavoro resta nel candidato isolato. **Il rilevamento generale, la Gold globale
e la parità dell'intera simulazione con C non sono completati.** Nessun commit,
push o cambiamento alla branch principale in questa consegna.

Riferimento: MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.
Il C ufficiale è usato esclusivamente negli oracoli e nei benchmark.

## Modifiche

- Inflazione dei testimoni: normalizza di nuovo `second-first` come C. La distanza
  Minkowski GJK usa una riduzione arrotondata diversa; sostituirla alla norma dei
  testimoni causava la discrepanza capsule–cilindro nelle perturbazioni.
  Le componenti con margine zero vengono preservate, come C.
- Coppie mesh–primitive: stesso ordine dei tipi di C, normale ripristinata
  all'ordine richiesto. La chiamata di ordinamento avviene una volta al massimo,
  con variante intera provata. Il test invertito rileva 462 errori nella vecchia
  build, fra cui 30 differenze nel numero di punti.
- `Mix_Reference`: separa il riferimento positivo miscelato dal modo diretto.
  La prova di tutti i parametri è chiusa, mantenendo le proprietà di ogni campo.
- Limite conservativo della normalizzazione, ricavato dal guard sulla norma
  piccola; non assume una sqrt esatta né un teorema di lunghezza unitaria.
  Scalatura iniziale della normale del frame isolata e dimostrata.
- Supporto analitico inlining, ricerca diretta per gli hull piccoli nel piano–mesh,
  vista della faccia compilata senza copiarne tutti i 64 indici.
- Il programma delle prove segnala con exit code nonzero qualsiasi verifica
  fallita. Le varianti prestazionali intermedie restano archiviate.

## Risultato dell’ottimizzazione

Rispetto alla build precedente: ellissoide–ellissoide −15,4% nel tempo
(IC 95% da −16,8% a −14,3%); piano–mesh −8,7%
(IC 95% da −11,7% a −7,0%). Nessuna delle 24 coppie mostra una regressione
rispetto alla precedente con intervallo accoppiato interamente sopra zero.
Questo è un risultato locale, non una prova di miglioramento universale.

Rispetto a C: sfera–sfera impiega il 40,9% di tempo in meno, sfera–capsula
il 46,2% in meno. Capsula–cilindro con margine ha rapporto 1,002
[0,987, 1,026], compatibile con la parità in questo campione.
Ellissoide–ellissoide resta a 1,019 [1,010, 1,046], piccolo divario ancora
visibile nella misura; non viene dichiarato pari. Restano divari più grandi:
piano–cilindro +44,2%, sfera–ellissoide +38,1%, mesh–mesh +36,7% e
piano–mesh +25,6%. La tabella completa e i campioni grezzi sono sotto.

## Risultati numerici

I conteggi sono per profilo: tutti i casi sono eseguiti con controlli Ada,
contratti e overflow attivi, e in release. Nessuna tolleranza allargata.

| Ambito | Casi per profilo | Risultato |
|---|---:|---|
| Regressione capsule–cilindro, tolleranza `1e-12` | 1 | Passa; fallisce sulla build precedente |
| 21 coppie di primitive, tutti i 10 campi geometrici | 21.000 | 0 discrepanze inattese; rimangono 14 normali C invertite diagnosticate e 4 falsi negativi C capsule–box verificati indipendentemente |
| GJK/EPA con un punto contro CCD nativo | 15.000 | 0 discrepanze oltre tolleranza |
| Mesh, entrambi gli ordini, contro C ufficiale | 4.200 | 0 discrepanze oltre tolleranza |
| Heightfield contro C ufficiale invariato | 600 | 65 differenze documentate; 0 crash in questo campione |
| Stesso heightfield contro C con il solo indice del prisma corretto | 600 | 0 differenze; oracolo diagnostico modificato |
| Parametri e finalizzazione dei 71 campi contro `mj_collision` | 2.000 | 0 differenze |
| Collegamento geometria → finalizzazione | 25.800 | 0 differenze rispetto al percorso separato e alle operazioni vettoriali C del frame |

L'ultima riga verifica le API, non costituisce un secondo oracolo C della
geometria. Le 65 differenze terreno restano esplicite. La diagnosi indipendente
dei difetti C e i limiti sono descritti in [CONTACTS.md](../../CONTACTS.md).

## Prove formali

| Proprietà | Esito fresco | Ambito |
|---|---|---|
| `Contact_Parameters`, unità intera | 61/61 | Proprietà funzionali dei parametri, priorità, adesione, riferimenti, impedenza, attrito e override |
| `Rigid_Math`, unità intera | 108/108 | Operazioni binary64 e nuovo limite conservativo di `Unit`; restano 7 avvisi sul contratto della sqrt standard |
| `Contact_Inflation`, unità intera | 18/18 | Conservazione dei punti con margine zero e offset esatto dei testimoni, sotto i limiti espliciti |
| `Scale_Normal` | 9/9 | Componenti e limiti della scalatura con lunghezza già calcolata almeno 0,5 |
| `Finalize`, sottoprogramma | 77/77 | Conservazione, parametri e inizializzazione; sotto il contratto del chiamato `Make_Frame` |
| Richiamo di ordinamento | 5/5 | Precondizioni e variante intera della ricorsione, sul sottoprogramma minimo |
| Otto unità del percorso dei contatti | Analisi di flusso riuscita | Non è la prova globale di sicurezza o funzionalità |
| `Full_Contacts`, unità intera | Aperta | Tentativi completi a livello 2 interrotti dal watchdog a 180 s; diagnosi più rapida: 96/110, 14 obblighi non provati |

La diagnosi rapida del frame usa CVC5 con due secondi per obbligo: include anche
obblighi del finalizzatore che passano nel suo tentativo dedicato più completo.
**Non si sommano le prove di tentativi diversi per dichiarare l'unità chiusa.**
Il [proof-index.json](proof-index.json) seleziona i tentativi riusciti con hash
delle unità uguali alla consegna. Gli altri log conservano tentativi intermedi
e falliti; il vecchio errore di flow su `Advanced_Contacts` è superato dal
report `advanced-final`. I log identificano sorgenti e comandi.
Restano aperti i contratti geometrici di GJK/EPA, clipping, hill climbing e
chiamanti. Non sono introdotti Assume, soppressioni o corpi fidati.

## Prestazioni

Confronto nella stessa sessione di build precedente, build corrente e C:
30 round, tutte le sei permutazioni dell'ordine ripetute, CPU 15, 16 pose diverse,
checksum di tutti i campi e confronto geometrico prima dei tempi.
Nessun nostro solver o controllo gira durante il benchmark finale. Il computer
resta condiviso con altre attività. Le dispersioni delle varianti sono archiviate.

Sono microbenchmark della narrow phase con precontatti completi. Escludono
broad phase, materiali/frame, vincoli, dinamica e integrazione. C sceglie il
callback prima del ciclo, Ada include il dispatcher. Il C conserva il SIMD
ufficiale; i flag della wheel non sono noti. Ada usa O3, LTO, architettura nativa,
nessun fast math e nessuna contrazione FMA.

Rapporto Ada/C sotto 1 significa Ada più veloce. Intervalli bootstrap al 95%
sulla mediana dei rapporti accoppiati. Variazione negativa rispetto alla build
precedente significa miglioramento; non si usa una media di percentuali come
prestazione aggregata della simulazione.

| Coppia | Prima ns | Ora ns | C ns | Ada/C [95%] | Ora/prima, variazione [95%] |
|---|---:|---:|---:|---|---|
| sphere-sphere | 13.4 | 13.2 | 22.2 | 0.591 [0.581, 0.604] | -0.9% [-4.9%, +2.4%] |
| sphere-capsule | 16.1 | 15.9 | 29.5 | 0.538 [0.532, 0.572] | +0.0% [-1.6%, +1.4%] |
| sphere-ellipsoid | 5428.3 | 5185.7 | 3769.4 | 1.381 [1.365, 1.391] | -2.6% [-3.6%, -1.9%] |
| sphere-cylinder | 31.7 | 31.8 | 29.6 | 1.075 [1.066, 1.081] | +0.2% [-0.3%, +0.8%] |
| sphere-box | 18.9 | 18.7 | 13.3 | 1.398 [1.379, 1.414] | -1.2% [-2.8%, -0.2%] |
| capsule-capsule | 41.9 | 42.2 | 39.1 | 1.079 [1.067, 1.102] | +0.4% [-0.2%, +2.1%] |
| capsule-ellipsoid | 3060.5 | 2878.6 | 2715.2 | 1.065 [1.050, 1.080] | -6.2% [-7.4%, -2.9%] |
| capsule-cylinder | 17333.1 | 16839.9 | 16420.3 | 1.041 [1.032, 1.062] | -2.7% [-3.5%, -1.1%] |
| capsule-box | 183.9 | 183.0 | 165.5 | 1.108 [1.088, 1.112] | -0.3% [-1.1%, +0.1%] |
| ellipsoid-ellipsoid | 3892.5 | 3283.0 | 3225.3 | 1.019 [1.010, 1.046] | -15.4% [-16.8%, -14.3%] |
| ellipsoid-cylinder | 2753.1 | 2525.5 | 2416.3 | 1.046 [1.032, 1.061] | -7.8% [-10.7%, -6.6%] |
| ellipsoid-box | 1603.8 | 1523.6 | 1393.1 | 1.084 [1.073, 1.102] | -4.5% [-6.6%, -3.3%] |
| cylinder-cylinder | 2812.1 | 2717.6 | 2553.0 | 1.068 [1.054, 1.085] | -3.1% [-3.8%, -1.6%] |
| cylinder-box | 1121.2 | 1109.3 | 933.0 | 1.182 [1.176, 1.192] | -0.8% [-2.5%, +0.4%] |
| box-box | 153.1 | 151.1 | 121.1 | 1.244 [1.235, 1.261] | -0.2% [-3.2%, +0.9%] |
| plane-sphere | 10.3 | 10.2 | 10.5 | 0.975 [0.967, 0.984] | -0.4% [-1.5%, +0.9%] |
| plane-capsule | 11.9 | 11.7 | 17.1 | 0.679 [0.667, 0.689] | -2.5% [-5.2%, -1.3%] |
| plane-cylinder | 30.3 | 30.5 | 21.4 | 1.442 [1.430, 1.468] | +1.1% [-0.6%, +2.2%] |
| plane-box | 35.8 | 35.0 | 25.4 | 1.381 [1.364, 1.398] | -2.2% [-4.3%, -0.7%] |
| plane-mesh | 77.4 | 70.4 | 56.2 | 1.256 [1.244, 1.268] | -8.7% [-11.7%, -7.0%] |
| box-mesh | 990.9 | 960.4 | 739.8 | 1.298 [1.270, 1.325] | -2.6% [-6.1%, -0.6%] |
| cylinder-mesh | 1792.7 | 1760.3 | 1378.9 | 1.274 [1.266, 1.282] | -2.2% [-2.6%, -0.9%] |
| mesh-mesh | 1206.3 | 1201.9 | 870.5 | 1.367 [1.353, 1.382] | -0.3% [-3.2%, +1.0%] |
| capsule-cylinder-margin | 17257.5 | 16701.8 | 16430.4 | 1.002 [0.987, 1.026] | -4.2% [-7.0%, -2.2%] |

La parità C resta aperta sui casi con rapporto superiore a 1 oltre
l'incertezza e manca una misura integrata. Eventuali regressioni della build
corrente rispetto alla precedente rimangono visibili nella tabella.

## Prossimo lavoro

Chiudere il modello e le prove del frame e dei chiamanti; profiling del GJK
sfera–ellissoide e dei percorsi piano/mesh; collegamento del driver completo
senza doppio narrowphase, BVH, vincoli e prova di movimento equivalente.
SDF/plugin/octree, collisioni complete dei flex e integrazione nel motore
restano mancanti. Le mesh qui collidono come hull convesse.

## Riproduzione ed evidenze

Eseguire dalla directory del candidato. Congelare in una directory nuova con
`tests/common.py:build`, poi usare i comandi in `verification-commands.json`.
Il codice della consegna è in `source-snapshot.tar.gz`, con hash nel manifest.
Il benchmark riproducibile è `benchmark_driver.py`; specificare i percorsi delle
build corrente e precedente come negli argomenti di `benchmark-command.json`.
Le varianti hanno i propri snapshot e manifest; il riferimento precedente è
[il report iniziale](../20261001-contacts/README.md).
