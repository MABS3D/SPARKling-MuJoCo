# MJ.LU — candidato LU denso e sparso

Aggiornato il 2026-09-30. Candidato autonomo, separato dalla dinamica.
Riferimento stabile verificato: MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, `engine_util_solve.c`:
`mju_factorLU`, `mju_solveLU`, `mju_factorLUSparse`, `mju_solveLUSparse`.

## API e dominio

- Densa: N=0..4096, row-major da indice zero, pivoting parziale con primo
  massimo assoluto, pivot singolare se abs <mjMINVAL. L/U sovrapposti, diagonale
  unitaria di L implicita. P registra scambi sequenziali; il solver li applica
  durante la sostituzione in avanti.
- Sparsa: CSR canonico, colonne strettamente crescenti, diagonali presenti.
  Analyze valida la struttura fuori dal ciclo. Eliminazione inversa A=(I+U)*L,
  senza pivoting, allocazione o creazione di fill. Fill_Required segnala una
  struttura insufficiente. Il sottoinsieme opzionale index di C è ancora assente.
- Buffer e Remaining sono del chiamante. First_Clamped è -1 oppure la prima
  riga incontrata in ordine inverso con pivot corretto a +/-mjMINVAL.
- Dominio +/-1e100. Numeric_Limit lascia buffer parziali limitati; usare i
  fattori e le soluzioni completate solo dopo Success. C può continuare con
  valori finiti fuori da questo dominio. Forme, struttura e domini sono
  obblighi dei chiamanti.
- Nessuna contrazione FMA. Le riduzioni scalari del solver sparso possono
  arrotondare diversamente dalle riduzioni SIMD di C.

## Prove complete dei contratti attuali

GNATprove chiude **1.063 obblighi di prova e 87 verifiche di flusso/terminazione**:
**zero obblighi aperti**, copertura completa di 55 sottoprogrammi/package.
[Rapporto completo](evidence/closed-contracts-20260930/ALL-summary.txt),
[copertura, avvisi e proprietà](evidence/formal-status-20260930.json).
Sorgenti congelati, hash, comandi e ALL.spark.json sono nella cartella del rapporto.
Non sono introdotti Assume, soppressioni, prove saltate o nuovi corpi trusted.

Proprietà funzionali/integrità dimostrate:

- Operazioni scalari ordinate, risultato esatto nel dominio e preservazione
  dell'operando quando la crescita viene rifiutata.
- Scambi di righe/celle esatti, massimo del pivot, clamp e diagonali valide.
- Eliminazione densa: relazione arrotondata esatta per tutte le celle della
  riga aggiornata; celle estranee preservate, anche nei risultati parziali.
- Crescita per stadio del percorso veloce dimostrata, fallback controllato e
  diagonali già elaborate preservate.
- Fattorizzazione sparsa: scratch limitato e, su Success, Remaining(I) coincide
  con Diagonal(I)-Row_Start(I); pivot già elaborati preservati.
- Solver denso/sparso: risultati parziali limitati e RHS nullo che produce
  soluzione nulla con Success. I passi scalari hanno contratti esatti.

La chiusura riguarda questi contratti. Un modello funzionale globale della
fattorizzazione/soluzione per ogni input, la ricostruzione della matrice e i
limiti generali di errore numerico restano da specificare e dimostrare. Non è
una prova completa del solver né una deroga matematica Silver. Le proprietà
Gold locali e di integrità vanno citate con questo ambito esplicito.

## Confronto numerico e prestazioni

**446 casi C superati**, inclusi 25 nuovi casi RHS nullo, pivot/clamp, strutture
ad albero/dense, fill necessario, fallback e limiti numerici. Residuo scalato
massimo 4.006e-16. [Risultati e hash](evidence/numerics-20260930/numerical.json).
La build con controlli è ricompilata da questi sorgenti; i benchmark release
confrontano anche i checksum Ada/C.

Le nuove misure sono diagnostiche: copia + fattorizzazione + soluzione,
sette campioni alternati, CPU vincolata, normale SIMD C. Il carico host non è
controllato. Non rappresentano un movimento integrato.

| Caso | N | Tempo Ada/C, mediana delle coppie | Intervallo bootstrap 95% |
| --- | ---: | ---: | --- |
| Denso | 8 | 1.581 | 1.569–1.583 |
| Denso | 32 | 3.955 | 3.668–4.132 |
| Denso | 128 | 5.888 | 5.740–6.140 |
| Sparso ad albero | 8 | 1.380 | 1.369–1.498 |
| Sparso ad albero | 32 | 1.112 | 1.103–1.120 |
| Sparso ad albero | 128 | 0.833 | 0.769–0.846 |

Il percorso denso presenta una regressione significativa dopo la scomposizione
necessaria alle prove: resta da recuperare la vettorizzazione/generazione di
codice mantenendo i contratti. I risultati sparsi dipendono dalla taglia. Nessuna
parità generale è dichiarata. [Campioni, build e sorgenti](evidence/20260930/performance.json).
I risultati storici conservati in evidence si riferiscono ai propri snapshot.

## Riproduzione e integrazione

```sh
python3 tests/prove.py nuova_prova Eliminate_Row --timeout 15
python3 tests/prove.py nuova_unità ALL --timeout 20 --memory 2048
python3 tests/build.py -f
python3 tests/build_reference.py
/var/tmp/sparkling-movement-env/bin/python tests/compare.py --output-dir /tmp/lu-numerics
python3 tests/build_bench.py
python3 tests/benchmark.py
```

Il driver congela i sorgenti e conserva rapporto, comandi e hash; il nome della
cartella deve essere nuovo. Toolchain: GNAT/GNATprove 16.1.0, GPRbuild 26.0.0,
CVC5/Z3/Alt-Ergo, per_path. Riferimento C estratto da MuJoCo 3.14.0.
`lu.patch` è rigenerato dai due sorgenti attuali; la copia locale di MJ.Types/MJ
serve alla build autonoma. Il patch non è applicato alla dinamica. L'integrazione
richiede precondizioni nei chiamanti e misure equivalenti del movimento.
