# Risultati — 30 settembre 2026

## Stato effettivo

L’integrazione dei tendini spaziali nel motore smooth sperimentale è operativa nel dominio descritto sotto. **La verifica formale completa è ancora aperta: non si dichiara Gold globale, né Silver globale.** Il riferimento è MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

## Integrazione

- Caricamento MJB con copia posseduta di percorsi, siti, geometrie e parametri elastici: il modello originale può essere liberato dopo `Data.Create`.
- Avvolgimento sfera/cilindro, sidesite interno/esterno, pulegge e percorsi con più avvolgimenti; aggiornamento delle pose mondiali e Jacobiano riferito correttamente al centro di massa.
- Lunghezza, velocità, molle/smorzatori polinomiali, proiezione sulle forze passive, Forward ed Euler; molle e smorzatori sono accumulati in canali separati come in C.
- Uscite pubbliche tramite `Get_Tendon_Outputs`, invalidazione delle cache, rilascio della memoria e pubblicazione atomica delle forze; nessuna doppia accumulazione ripetendo il calcolo.
- Ambito verificato: giunti hinge/slide, vincoli disabilitati. Il lavoro concorrente sui giunti free/ball è preservato; la loro combinazione con questi tendini è esplicitamente rifiutata. Tendini fissi, trasmissioni di attuatori sui tendini e armatura non sono integrati qui. MuJoCo stesso rifiuta l’armatura combinata con avvolgimenti sulle geometrie.

## Confronto numerico

Tutti i test standalone passano nei profili development, validation e release. La prova integrata usa il motore con controlli abilitati e la vera libreria C. Hash e risultati si trovano in `evidence/tests-*.json` e `evidence/integration/results.json`.

| Controllo | Esito |
|---|---|
| Geometria | 4.097 casi: 1.858 avvolgimenti, 2.238 tratti diretti, 1 NaN di C respinto |
| Geometria finita contro C | Errore massimo osservato 0 |
| Percorsi standalone | 1.044 casi; lunghezza 0, Jacobiano 3,33e-16, velocità 1,33e-15, forza 7,11e-15 di errore massimo |
| Differenze finite del Jacobiano | 24 righe, errore massimo 5,64e-9 circa |
| Input malformati standalone | 7 percorsi respinti e un fallimento dopo accumulazione parziale azzerato correttamente |
| Forward/Euler integrati | 25 modelli con tendini + 15 regressioni; 480 configurazioni, 12.800 passi |
| Modelli con tendini | Errore massimo accelerazione 7,78e-16; forza passiva 3,89e-16 |
| Uscite tendini integrate | Lunghezza 8,89e-16; velocità 9,55e-18; forza scalare 1,78e-15 |
| Regressioni senza tendini | Errore massimo accelerazione 2,41e-13 |
| Casi rifiutati | Giunti quaternion+tendine, armatura, attuatore su tendine; limite numerico senza modifica di stato/tempo |

Le tolleranze numeriche non sono dimostrazioni universali di equivalenza. I test standalone con cinematica free/ball non attestano che quella combinazione sia supportata dalla pipeline integrata.

## Verifica formale

Le prove sono modulari e valgono sotto i contratti dichiarati dei chiamati. I controlli nella tabella seguente sono quelli del messaggio `Success: all checks proved` di GNATprove, comprensivi dei controlli di flusso quando presenti; non vanno sommati tra scope sovrapposti.

| Ambito | Risultato |
|---|---|
| Intera unità `MJ.Tendon_Vectors` | 81 controlli chiusi; contratti esatti di somma, prodotto scalare, prodotto vettoriale e trasformazione |
| 7 sottoprogrammi geometrici minimi | `Norm`, `Unit`, `Dot2`, `Norm2`, `Unit2`, `Determinant`, `Intersect`: chiusi |
| 6 sottoprogrammi minimi dei percorsi | `Valid_Path`, `Point_Column`, `Project_Component`, `Velocity_Prefix`, `Velocity`, `Project_Force`: chiusi |
| Conversione dei Jacobiani | `Column`: 20; `Jacobian`: 10 controlli chiusi |
| Forze elastiche | `Displacement`: 5; `Polynomial`: 10; `Spring_Damper`: 16 controlli chiusi |
| Lettura delle uscite | `Get_Tendon_Outputs`: 37 controlli chiusi |
| Conservazione nello sviluppo dei Jacobiani | `Ensure_Jacobians`: 39 controlli chiusi, incluse conservazione di gravità e bias |
| Analisi dei flussi | Passata per i tre moduli standalone e per modello/fase integrata; gli avvisi sui risultati geometrici temporanei inutilizzati restano visibili |
| Avvolgimento e percorso completi | **Aperti**: `Circle`, `Inside`, `Wrap`, `Evaluate` e modello funzionale globale |
| Caricamento e fase integrata | **Aperti**: `Load_Valid`, `Load`, `Compute_Passive`, composizione con `Complete_Passive` e audit globale del ciclo di vita |

Per le prove minime usare `evidence/proof-small/manifest.json` insieme al rilancio `proof-small/Point_Column/manifest.json` (15 secondi per controllo). Per l’unità vettoriale usare `proof-whole/mj-tendon_vectors/manifest.json` (10 secondi), non l’audit generale con budget ridotto. Per gli altri esiti usare `integration-proof-kernels`, `integration-proof-callers/Get_Tendon_Outputs`, `integration-proof-callers/Ensure_Jacobians` e `integration-proof-flow`.

Gli audit generali a cvc5/1 secondo/300 passi sono diagnostici: molti controlli esauriscono quel budget prima di chiudersi. Il tentativo del caricatore a tre provatori/5 secondi per controllo ha raggiunto il watchdog di 600 secondi. Non è un esito positivo e non stabilisce che la specifica sia falsa. I rapporti `.spark`, i log e le istantanee immutabili sono conservati; le prove non vengono aggirate con `Assume`, soppressioni o corpi C di produzione.

Il modello della radice quadrata nel runtime GNATprove (`share/spark/theories/_gnatprove_standard.mlw`, `ada_sqrt`) non fornisce un limite quantitativo superiore né una garanzia generale di accuratezza. Le norme sono specificate come composizione con la funzione runtime; la normalizzazione specifica il fallback e la divisione effettiva. Non si asserisce una norma unitaria esatta. Limiti espliciti proteggono l’accumulo delle lunghezze. Modelli funzionali mancanti, invarianti e timeout rimangono lavoro di dimostrazione, non eccezioni matematiche Silver.

## Prestazioni del passo completo

GNAT/GCC 16.1.0, Ada release `-O3 -gnatp -gnatn -march=native -flto -ffp-contract=off`; C: libreria ufficiale MuJoCo 3.14.0, con SIMD ordinario. I flag interni della wheel non sono controllati indipendentemente. Ogni campione comprende 4.096 traiettorie di 64 passi Euler; preparazione, reset e lettura finale sono fuori dal tempo misurato. Un riscaldamento, cinque campioni alternati, stesso processore logico; checksum finali concordi. Il carico esterno del computer resta non controllato.

| DOF / tendini | Ada µs/passo, mediana | C µs/passo, mediana | Ada/C | Ada/C sul tempo CPU |
|---|---:|---:|---:|---:|
| 2 / 1 | 1.105 | 0.887 | 1.246 | 1.246 |
| 8 / 4 | 3.190 | 2.036 | 1.567 | 1.567 |
| 16 / 8 | 6.163 | 3.478 | 1.772 | 1.773 |

| DOF | Intervallo campioni Ada µs/passo | Intervallo campioni C µs/passo |
|---|---:|---:|
| 2 | 1.050–1.239 | 0.721–1.020 |
| 8 | 3.071–3.287 | 1.914–2.109 |
| 16 | 5.930–6.594 | 3.311–3.715 |

**La parità non è raggiunta:** il rallentamento misurato è circa 25%, 57% e 77% nei tre carichi. Jacobiani densi materializzati/copiati e validazioni residue sono presenti; questi test non ne isolano ancora il contributo causale.

I dati completi, i tempi delle singole traiettorie, i p95, il compilatore e gli hash sono in `evidence/performance-integration`. I primi campioni brevi, fortemente disturbati, sono conservati nelle sottocartelle `wall-clock-interference` e `short-cpu-samples`; non sono usati per dichiarare una velocizzazione. Il timer CPU separa la deschedulazione dal calcolo ma non elimina le variazioni di frequenza o delle risorse condivise.

## Microbenchmark geometrico

`tests/benchmark.py` consuma lunghezza e tutte le sei coordinate dei punti di contatto. I vecchi risultati che consumavano soltanto la lunghezza sono conservati come `benchmark-length-only-historical.json`; non rappresentano il costo completo della geometria. La misura corrente, distinta dal passo completo, è in `evidence/benchmark.json`.

| Geometria | Ada ns/chiamata | C ns/chiamata | Ada/C |
|---|---:|---:|---:|
| sphere | 114.89 | 122.30 | 0.939 |
| cylinder | 71.28 | 85.13 | 0.837 |

Le prove e i test registrano le istantanee dei sorgenti, non uno stato Git committato. Le modifiche concorrenti al motore sono state preservate; l’ultimo confronto integrato e le prove degli adattatori/lettori sono stati ripetuti sui sorgenti aggiornati. Nessun commit o push è stato eseguito in questa attività.
