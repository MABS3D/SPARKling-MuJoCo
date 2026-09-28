# MJ.LU — candidato LU densa e sparsa

Implementazione autonoma SPARK, non ancora integrata nei chiamanti della dinamica.
Riferimento: MuJoCo 3.14.0, `engine_util_solve.c`, funzioni `mju_factorLU`,
`mju_solveLU`, `mju_factorLUSparse`, `mju_solveLUSparse`.

## API e comportamento

- Densa: ordine 0..4096, array piatto row-major con primo indice 0;
  pivoting parziale, primo massimo assoluto, pivot singolare se abs < 1e-15.
  Fattori L/U sovrapposti, diagonale unitaria L implicita; P registra gli scambi
  sequenziali. Solve_Dense applica gli scambi durante la sostituzione in avanti.
- Sparsa: CSR canonico, colonne strettamente crescenti, diagonale presente in ogni
  riga. Row_Start contiene N+1 offset; Diagonal contiene indici globali del buffer.
  Analyze verifica la struttura e produce Diagonal una volta, fuori dal ciclo.
  Fattorizzazione inversa A=(I+U)*L, senza pivoting e senza allocare fill-in, come C.
  Non è un solver universale per matrici sparse arbitrarie: Fill_Required segnala
  una struttura insufficiente. Non implementa il sottoinsieme opzionale `index` di C.
- Buffer e scratch sono del chiamante; nessuna allocazione nel kernel.
  Remaining ha N elementi. First_Clamped è -1 oppure la prima riga incontrata
  nell'ordine inverso con pivot corretto a +/-1e-15 (zero diventa positivo).
- Dominio finito +/-1e100. Numeric_Limit interrompe un risultato fuori dominio;
  C può continuare producendo valori finiti maggiori. I buffer dopo un errore
  possono essere parzialmente modificati: usare i fattori solo dopo Success.
  Forme, domini e precondizioni restano obblighi del chiamante.
- Nessuna contrazione FMA. Solve_Sparse usa sottrazioni scalari ordinate: non
  promette identità bit per bit con la riduzione SIMD di C.

## Verifica e limiti

I rapporti `evidence/numerical.json`, `formal-status.json` e `performance.json`
riportano risultati, dimensioni, sorgenti congelati e limiti delle misure.
Le prove locali funzionali non costituiscono una prova globale del solver.
Restano da chiudere gli invarianti di scambio/eliminazione/fattorizzazione e
specificare e dimostrare il modello funzionale globale dei due solver.
Sono lavoro aperto, non deroghe matematiche al requisito Gold.
Il percorso denso veloce usa un limite conservativo per stadio e un controllo
esplicito del moltiplicatore; l'induzione globale di tale limite resta aperta.

I test differenziali confrontano fattori, pivot, clamp e soluzioni con le quattro
routine estratte da C. Il residuo è verificato separatamente con NumPy.
I benchmark misurano copia + fattorizzazione + soluzione su matrici dense e su
strutture sparse ad albero; non misurano un movimento integrato. Il carico host
non è controllato e i campioni mostrano variabilità elevata: nessuna conclusione
di parità generale. La build benchmark disabilita le verifiche Ada (`-gnatp`),
mentre conserva i controlli numerici espliciti; non è una build certificata Gold.

## Riprodurre nell'ambiente corrente

GNAT / GNATprove 16.1.0, GPRbuild 26.0.0. Gli script cercano il toolchain sotto
`/var/tmp/sparkling-matrix-recovery/toolchains` e il riferimento C sotto
`/var/tmp/sparkling-movement-c/source` (MuJoCo 3.14.0). Adeguare questi percorsi
per un'altra macchina. NumPy è disponibile nel Python indicato sotto.

```
python3 tests/build.py
python3 tests/build_reference.py
/var/tmp/sparkling-movement-env/bin/python tests/compare.py
python3 tests/build_bench.py
python3 tests/benchmark.py
python3 tests/prove.py nuova_prova Subtract_Product Multiply Divide Clamped
```

Il nome della cartella di prova deve essere nuovo. Le prove procedono per singolo
sottoprogramma con timeout di 5 secondi per tentativo e watchdog di 180 secondi.
I sorgenti congelati nei rapporti storici consentono di distinguere ogni versione;
consultare formal-status.json per la copertura della versione consegnata.

`lu.patch` aggiunge solo src/mj-lu.ads e src/mj-lu.adb. La copia di MJ.Types e MJ
serve per la compilazione autonoma e non va usata per sostituire quella principale.
Prima dell'integrazione occorrono revisione, chiusura delle prove aperte e
precondizioni dimostrate nei chiamanti; non è stata modificata la dinamica attiva.

## Risultati di questa esecuzione

421 casi superati; residuo scalato massimo 4.006e-16.
144 verifiche chiuse su dieci sottoprogrammi locali; non sono tutte funzionali
(ad esempio Solve_Sparse prova sicurezza e dominio, non ancora la soluzione).

| Kernel | N | Tempo Ada / C |
|---|---:|---:|
| Denso | 8 | 1.620 |
| Denso | 32 | 1.914 |
| Denso | 128 | 1.549 |
| Sparso ad albero | 8 | 1.099 |
| Sparso ad albero | 32 | 0.842 |
| Sparso ad albero | 128 | 0.471 |

Rapporto <1 significa meno tempo di C. Mediane di sette campioni, CPU vincolata;
forte variabilità del carico host. Sono diagnostica, non un risultato di parità
nel movimento integrato.
