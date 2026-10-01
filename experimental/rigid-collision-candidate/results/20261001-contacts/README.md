# Contatti completi e geometrie avanzate — 1 ottobre 2026

Il candidato locale implementa i precontatti delle 21 combinazioni di primitive,
mesh convesse e heightfield, e la loro finalizzazione fisica per coppia.
**Non è completo il rilevamento generale di MuJoCo. Non sono raggiunte la Gold
complessiva o la parità prestazionale con C.** La chat principale non è stata
modificata: il lavoro rimane in `experimental/rigid-collision-candidate`.

Il riferimento è la libreria ufficiale MuJoCo **3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Nessuna chiamata MuJoCo C nel
codice di produzione Ada. La libreria C serve soltanto come oracolo.

## Codice aggiunto

- GJK con testimoni, espansione EPA e attraversamento del bordo con pila limitata.
- Manifold delle primitive, clipping di facce/spigoli e contatti perturbati.
- Supporto alle mesh compilate: vertici, facce, grafo, cache e semi direzionali
  identici a C; hill climbing sui grandi hull.
- Heightfield: riferimento locale, AABB, sottogriglia e prismi triangolari.
- Materiali: priorità, `condim`, `solmix`, `solref`, `solreffriction`, `solimp`,
  attrito a cinque componenti, adesione, coppie esplicite e override globali.
- Contatti finalizzati: frame, esclusione nel gap, adesione nel gap con dimensione
  effettiva 1, ID delle geometrie, campi iniziali `efc_address`, `mu` e Hessiana.
- API `Collision_Contacts.Generate` / `Generate_Terrain`: collegamento fra
  geometria e finalizzazione, con parametri configurati una volta per coppia.

Nessuna allocazione per contatto o triangolo. I buffer temporanei inizializzano
solo il prefisso prodotto. Il supporto box/cilindro riusa la trasformazione locale
per punto e indice della caratteristica. La scelta dell'asse delle perturbazioni
usa gli stessi confronti stretti di C, anche sulla soglia ±0.5.

Dettagli, contratti e capacità: [CONTACTS.md](../../CONTACTS.md).

## Verifiche numeriche

Ogni riga viene eseguita sia con controlli Ada/contratti/overflow/validità attivi,
sia in release. Il conteggio indica ingressi distinti, non la somma dei profili.

| Ambito | Ingressi per profilo | Risultato |
|---|---:|---|
| Primitive: distanza, posizione, normale, tangente e numero di punti | 21.000 | **1 discrepanza residua**; 14 inversioni di normale C diagnosticate; 4 falsi negativi C capsule–box verificati indipendentemente |
| GJK/EPA con un testimone contro CCD C nativo | 15.000 | 0 discrepanze oltre tolleranza |
| Mesh e heightfield contro C ufficiale invariato | 2.700 | 65 discrepanze, tutte heightfield–box/mesh; 0 crash in questo campione |
| Stessi ingressi contro C con il solo indice del supporto prisma corretto | 2.700 | 0 discrepanze; **oracolo diagnostico modificato** |
| Materiali e finalizzazione contro contatti reali di `mj_collision` | 2.000 | 0 discrepanze sui 71 campi confrontati |
| API geometria → finalizzazione | 23.700 | 0 discrepanze rispetto al percorso geometrico separato e al frame ricostruito con operazioni vettoriali C native |

L'ultima riga verifica il collegamento delle API: **non costituisce un secondo
confronto della geometria contro C**. I suoi limiti sono quelli delle righe
geometriche precedenti. Nei test dei materiali i precontatti vengono forniti
 dall'oracolo C per isolare miscelazione e finalizzazione.

I 2.000 casi includono 667 coppie esplicite, 400 override, 180 contatti adesivi
nel gap, 180 esclusioni nel gap, 500 riferimenti diretti e 1.283 casi con almeno
un fattore `solmix` sotto `mjMINVAL`. Con override automatico gli ingressi restano
entro l'ammissione della SAP C: la SAP nativa non espande il gap in quel percorso.
Le coppie esplicite con override esercitano comunque il gap.

La discrepanza ancora aperta è capsule–cilindro, campione 263: un punto perturbato
ha distanza identica, ma posizione/normale differiscono fino a circa `6.7e-7`.
La tolleranza del confronto rimane `3e-7 × (1 + |componente|)`; **non è stata
allargata** per far passare il test. L'EPA è configurato a `1e-6`, ma ciò non
costituisce una dimostrazione che la differenza sia accettabile.

Le differenze intenzionali da C e il difetto degli indici del prisma sono
spiegati in [CONTACTS.md](../../CONTACTS.md). Restano archiviati entrambi gli
oracoli, i casi non conformi e una fixture heightfield–cilindro che provocava un
crash C in un campione precedente: non è stata cancellata perché il nuovo
campione non incontra quel crash. I falsi negativi capsule–box sono verificati
con minimizzazione segmento–box indipendente, Decimal a 100 cifre.

## Stato delle prove

| Unità/proprietà | Esito | Limite della conclusione |
|---|---|---|
| `Contact_Geometry`, unità intera | 58/58 controlli provati | Inizializzazione del prefisso e inversione del manifold, sotto le precondizioni |
| `Convex_Assets`, unità intera | 86/86 controlli provati | Ammissione strutturale del grafo e massimo della ricerca completa, comprese le parità; non teorema globale del hill climbing |
| `Rigid_Math`, unità intera | 108/108 controlli provati | Contratti operazionali binary64; 7 avvisi sulla precisione del contratto della sqrt standard |
| `Weight`, `Mix_Value`, `Configure` | 9/9, 11/11, 9/9 | Proprietà funzionali dei singoli sottoprogrammi |
| `Contact_Parameters`, unità intera | 54/55 | Resta il contratto funzionale sul riferimento miscelato; tentativo più lungo fermato dal limite di tempo |
| `Full_Contacts.Finalize` | 77/77 | Conservazione di distanza/posizione, parametri, esclusioni, inizializzazione; assume il contratto del chiamato `Make_Frame` |
| `Full_Contacts`, unità intera | 89/103 | 14 obblighi aperti nel frame: 5 precondizioni e 9 controlli di intervallo |
| GJK/EPA, clipping, perturbazioni, primitive, avanzate, terrain, finalizzazione e collegamento API | Analisi di flusso delle 8 unità riuscita | Restano le prove dei limiti, inizializzazione con `Relaxed_Initialization` e proprietà geometriche/funzionali |

Non sono stati introdotti `Assume`, soppressioni o nuovi corpi fidati.
Un timeout o un modello/invariante mancante è **lavoro di prova incompleto**,
non una ragione per dichiarare definitivamente Silver. I report delle unità
intere restano separati dalle prove dei sottoprogrammi minimi.

## Prestazioni misurate

Microbenchmark della **narrow phase con precontatti geometrici completi**:
16 pose variabili, 30 round alternati Ada/C, checksum su distanza, tutti i
componenti di posizione/normale/tangente e numero di punti. Nessun I/O nel
tratto cronometrato. Le 16 pose di ogni caso sono confrontate prima dei tempi.

Non misura broad phase, materiali/finalizzazione, vincoli, dinamica o un passo
completo della simulazione. C sceglie la funzione specializzata prima del ciclo;
Ada include il dispatcher. Il C è la libreria ufficiale con SIMD nativo; i suoi
flag di compilazione non sono pubblicati nella wheel. Ada usa O3, LTO e
`-march=native`, senza fast math né contrazione FMA.

La sessione finale non sovrappone nostri solver o verifiche al benchmark.
Il computer è comunque condiviso con altre attività. Sono conservate anche
le sessioni precedenti con carico concorrente; non si dichiara un host inattivo.
Rapporto < 1 significa Ada più veloce. L'intervallo è il bootstrap al 95% della
mediana dei rapporti accoppiati, non una garanzia universale sui modelli.

| Coppia | Ada ns | C ns | Rapporto Ada/C | Intervallo 95% |
|---|---:|---:|---:|---|
| sphere-sphere | 13.7 | 22.3 | 0.606 | 0.593–0.644 |
| sphere-capsule | 15.7 | 29.5 | 0.531 | 0.527–0.535 |
| sphere-ellipsoid | 5414.7 | 3986.6 | 1.372 | 1.321–1.404 |
| sphere-cylinder | 32.9 | 30.0 | 1.090 | 1.080–1.105 |
| sphere-box | 19.1 | 13.7 | 1.412 | 1.380–1.427 |
| capsule-capsule | 42.8 | 39.4 | 1.081 | 1.068–1.113 |
| capsule-ellipsoid | 3121.1 | 2661.1 | 1.165 | 1.154–1.185 |
| capsule-cylinder | 17535.1 | 16261.7 | 1.078 | 1.053–1.084 |
| capsule-box | 183.6 | 165.6 | 1.106 | 1.103–1.116 |
| ellipsoid-ellipsoid | 3868.4 | 3268.8 | 1.190 | 1.135–1.207 |
| ellipsoid-cylinder | 2767.0 | 2385.1 | 1.154 | 1.138–1.175 |
| ellipsoid-box | 1624.0 | 1369.7 | 1.183 | 1.165–1.220 |
| cylinder-cylinder | 2838.5 | 2561.4 | 1.114 | 1.100–1.122 |
| cylinder-box | 1138.9 | 959.5 | 1.187 | 1.169–1.203 |
| box-box | 151.8 | 124.7 | 1.215 | 1.211–1.232 |
| plane-sphere | 10.4 | 10.7 | 0.977 | 0.963–0.985 |
| plane-capsule | 12.0 | 17.4 | 0.694 | 0.677–0.699 |
| plane-cylinder | 30.4 | 21.0 | 1.454 | 1.441–1.470 |
| plane-box | 35.6 | 25.3 | 1.398 | 1.390–1.417 |
| plane-mesh | 76.2 | 57.8 | 1.321 | 1.312–1.353 |
| box-mesh | 983.0 | 740.4 | 1.338 | 1.288–1.346 |
| cylinder-mesh | 1818.5 | 1360.5 | 1.322 | 1.304–1.341 |
| mesh-mesh | 1200.9 | 877.6 | 1.376 | 1.366–1.393 |
| capsule-cylinder-margin | 17460.5 | 16376.1 | 1.060 | 1.043–1.074 |

La parità generale resta aperta. Gli intervalli rendono visibile quando una
piccola differenza può essere rumore; non viene imposta una soglia arbitraria
come prova di parità. Le sfere e alcuni contatti con piani guadagnano, mentre
molti percorsi convessi e le mesh restano più lenti. Non vengono mediate coppie
con pesi arbitrari per sostenere il risultato di una simulazione.

## Cosa manca

1. Chiudere la differenza capsule–cilindro e le prove del frame/riferimento.
2. Dimostrare GJK/EPA, clipping, validità geometrica del grafo e precondizioni
   dei chiamanti; poi rimuovere soltanto i controlli effettivamente ridondanti.
3. Unificare broad phase/filtri e generazione dei contatti, aggiungere BVH e
   gestione della scena per mesh e heightfield.
4. Portare SDF/plugin/octree e collisioni complete dei flex. Le mesh qui
   collidono come hull convessi, non come superfici concave triangolate generali.
5. Collegare ai vincoli e alla dinamica, e confrontare traiettorie e prestazioni
   di movimenti completi a parità di output.

## Riproduzione e archivio

[manifest.json](manifest.json) contiene hash delle sorgenti, dei tre programmi
nei due profili e della libreria nativa. [environment.json](environment.json)
registra CPU, toolchain, opzioni e hash delle sorgenti C esaminate.
[source-snapshot.tar.gz](source-snapshot.tar.gz) conserva la fotografia compilata.
I quattro `*-input.txt.gz` conservano gli ingressi; i `*-numerics.json` includono
anche gli errori. [proof-index.json](proof-index.json) indica i report formali.
I tentativi falliti e il watchdog sono conservati, insieme alle fixture.

Dalla cartella del candidato, con l'ambiente/toolchain indicati:

```sh
PY=/var/tmp/sparkling-movement-env/bin/python
OUT=/var/tmp/collision-reproduction
"$PY" tests/check_contacts.py --out "$OUT" --samples 1000
"$PY" tests/check_contacts.py --out "$OUT" --reuse --samples 1000 --convex
"$PY" tests/check_full_contacts.py --out "$OUT" --reuse --samples 2000
"$PY" tests/check_advanced.py --out "$OUT" --reuse --samples 100 --indexed-terrain
"$PY" tests/check_advanced.py --out "$OUT" --reuse --samples 100
"$PY" tests/check_finalized_geometry.py --out "$OUT" "$OUT/primitive-contact-input.txt" "$OUT/advanced-input.txt"
"$PY" tests/prove_contacts.py --out /var/tmp/collision-proof-reproduction
# Attendere la conclusione delle prove prima di avviare i tempi.
"$PY" tests/benchmark_contacts.py --out "$OUT" --reuse --rounds 30
```

Sono attesi esiti nonzero dal confronto primitivo ancora aperto e dall'oracolo
terrain C invariato. Il programma delle prove conserva le unità aperte nel suo
`summary.json`; il suo solo codice di uscita non certifica la Gold complessiva.
