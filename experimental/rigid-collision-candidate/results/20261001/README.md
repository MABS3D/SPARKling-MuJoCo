# Evidenze — 1 ottobre 2026

**Ambito: coppie rilevate da Ada contro contatti completi prodotti da `mj_collision` C. Il lavoro e gli output differiscono. Queste misure non certificano parità su contatti completi o simulazione integrata.**

Le misure riguardano la stessa fotografia delle sorgenti descritta in `manifest.json`. Ryzen 7 9800X3D, WSL2, CPU 15; 11 round alternati, pose e allocazioni preparate fuori dal cronometro. Le opzioni di compilazione della libreria C precompilata non sono note. Il suo percorso AVX è presente. Il sistema era condiviso con lavori di prova della conversazione principale: non si tratta di un host dedicato.

La colonna Ada/C è la mediana dei rapporti appaiati; può differire dal rapporto fra le due mediane temporali. I tempi sono microsecondi per ricerca/frame, ammortizzati sul numero di ripetizioni dichiarato nei JSON. Gli intervalli sono bootstrap al 95%, non limiti universali.

## Correttezza

| Verifica | Validazione | Release |
|---|---:|---:|
| Casi di coppia sulle 21 combinazioni | 21.000 | 21.000 |
| Errori inattesi nelle decisioni | 0 | 0 |
| Differenze intenzionali rispetto a C | 539 | 539 |
| Scene statiche | 30 passate | 30 passate |
| Filtri e frame variabili | 97 passati | 97 passati |
| Scene dei benchmark statici, coppie complete | 20 passate | 20 passate |

Le 539 differenze sono intersezioni con centri coincidenti che C non segnala: 536 nel CCD e 3 capsula–box. Gli input, le aspettative C e le motivazioni sono conservati; non si dichiara equivalenza bit per bit. I 192 frame dei benchmark in movimento sono controllati uno per uno prima delle misure release.

## Prove

| Ambito | Obblighi dimostrati | Stato |
|---|---:|---|
| Intera `Rigid_Geometry` | 12/12 | Sicurezza dei contratti ed ID canonici |
| Intera `Rigid_Math` | 84/84 | Proprietà funzionali binary64; confine runtime sqrt |
| `Key` | 5/5 | Frammento: firma unsigned canonica |
| `Contains` | 20/20 | Frammento: appartenenza al prefisso ordinato |
| Sei unità delle collisioni | Analisi flow passata | Prova completa Silver/Gold aperta |

I sette avvisi `imprecise-call` sulla radice quadrata non sono soppressi. `Transform` e `Local` hanno raggiunto il timeout nei tentativi isolati da 5 secondi; le ripetizioni fresche da 20 secondi sono passate, così come il report completo della matematica. I tentativi iniziali di ripetizione con un percorso errato del watchdog sono conservati nei log e non sono conteggiati come prove. Tutti i tentativi sono in `proof-summary.json`; gli ambiti accettati e gli avvisi sono in `proof-status.json`.

I report compressi `.spark.gz` e i log distinguono prove complete, prove di sottoprogrammi e solo flow. Il report flow non dimostra assenza di tutti gli errori runtime. La correttezza geometrica universale, la completezza della broad phase e la correttezza del driver restano da dimostrare.

## Scene statiche

| Scena | C µs | Ada µs | Ada/C | IC 95% |
|---|---:|---:|---:|---|
| sparse-8 | 0.325 | 0.092 | 0.296 | 0.282–0.307 |
| dense-8 | 0.868 | 0.224 | 0.261 | 0.222–0.279 |
| mixed-8 | 4.803 | 1.866 | 0.397 | 0.379–0.406 |
| masks-8 | 5.122 | 1.868 | 0.373 | 0.351–0.384 |
| plane-8 | 1.731 | 0.344 | 0.195 | 0.143–0.230 |
| sparse-32 | 1.090 | 0.616 | 0.526 | 0.421–0.618 |
| dense-32 | 5.570 | 1.420 | 0.254 | 0.244–0.264 |
| mixed-32 | 56.450 | 15.365 | 0.272 | 0.264–0.294 |
| masks-32 | 41.418 | 13.332 | 0.299 | 0.281–0.318 |
| plane-32 | 8.093 | 1.831 | 0.228 | 0.221–0.289 |
| sparse-128 | 3.926 | 2.881 | 0.753 | 0.721–0.820 |
| dense-128 | 41.514 | 12.339 | 0.305 | 0.285–0.324 |
| mixed-128 | 574.010 | 147.317 | 0.257 | 0.254–0.265 |
| masks-128 | 335.064 | 88.540 | 0.264 | 0.261–0.269 |
| plane-128 | 37.343 | 13.351 | 0.377 | 0.355–0.382 |
| sparse-512 | 22.512 | 18.004 | 0.801 | 0.771–0.837 |
| dense-512 | 227.083 | 129.821 | 0.581 | 0.537–0.590 |
| mixed-512 | 3337.849 | 1078.045 | 0.323 | 0.319–0.327 |
| masks-512 | 1867.683 | 674.375 | 0.365 | 0.348–0.374 |
| plane-512 | 200.746 | 137.095 | 0.716 | 0.658–0.802 |

## Movimento su 16 frame

| Scena | C µs/frame | Ada µs/frame | Ada/C | IC 95% |
|---|---:|---:|---:|---|
| sparse-moving-8 | 0.350 | 0.088 | 0.257 | 0.251–0.280 |
| dense-moving-8 | 0.915 | 0.204 | 0.223 | 0.210–0.231 |
| mixed-moving-8 | 7.828 | 4.641 | 0.581 | 0.575–0.595 |
| sparse-moving-32 | 0.967 | 0.492 | 0.521 | 0.459–0.538 |
| dense-moving-32 | 6.440 | 1.642 | 0.262 | 0.253–0.299 |
| mixed-moving-32 | 107.187 | 35.931 | 0.340 | 0.333–0.349 |
| sparse-moving-128 | 4.283 | 3.746 | 0.886 | 0.842–0.913 |
| dense-moving-128 | 62.178 | 20.370 | 0.332 | 0.312–0.356 |
| mixed-moving-128 | 1282.304 | 298.638 | 0.233 | 0.231–0.238 |
| sparse-moving-512 | 75.640 | 22.640 | 0.300 | 0.287–0.304 |
| dense-moving-512 | 567.245 | 211.638 | 0.377 | 0.368–0.383 |
| mixed-moving-512 | 7713.099 | 1785.571 | 0.231 | 0.229–0.233 |

In tutte le scene misurate l'intervallo del rapporto resta sotto 1. È un risultato sul costo del rilevamento delle coppie rispetto al costo maggiore della generazione dei contatti C; non dimostra che la futura implementazione con manifold, materiali e vincoli sarà più veloce. La release rimuove i controlli mentre le prove complessive sono ancora aperte: resta una configurazione sperimentale.

## File

- `manifest.json`: hash di sorgenti, eseguibili e libreria nativa C; comando del wrapper.
- `numerics.json`, `driver-numerics.json`, `benchmark-pair-check.json`: risultati e differenze.
- `*-input.txt.gz` e `*-expected.json.gz`: input e risultati C, compressi in gzip.
- `performance.json`, `motion-performance.json`: tempi, intervalli, dispersione e ambito.
- `timing-raw.jsonl`, `motion-timing-raw.jsonl`: round individuali.
- `benchmark-models.json`: XML delle scene statiche. I modelli in movimento sono ricostruibili da `tests/benchmark_motion.py` con hash nel report.
- `proof-status.json`, `proof-summary.json`, `proof-logs/`, `proof-reports/`: prove accettate, tentativi e obblighi ancora aperti.
- `environment.json`, `reference-simd.txt`: ambiente e riscontro del riferimento AVX.

La fotografia sorgente e gli eseguibili della misura rimangono in `/var/tmp/sparkling-rigid-collision-reports-20261001`; l'archivio in repository contiene gli hash e le evidenze compatte. Per ricostruire usare i programmi della directory `tests` come indicato nel README del candidato.
