# MuJoCo: prodotto A·Bᵀ con righe corte

**La parità complessiva con C resta aperta.** Un output con uno degli assi
vuoti ritorna immediatamente, prima della selezione della larghezza. Il prodotto generico
`MulMatMatT` (`A·Bᵀ`) seleziona le larghezze 0, 1, 2, 3 e 4 prima dei cicli
sugli output. Il compilatore può specializzare stride e coda del prodotto
scalare per ciascuna larghezza. I cinque rami distinti sono intenzionali e
l'helper corto viene inlined. Per le larghezze maggiori, `Rows_Blocks`
aggiorna due blocchi consecutivi per corsia e poi il blocco residuo,
preservando ogni ricorrenza. `MulMatMatT` richiede `Inline_Always` per
conservare le informazioni sui limiti disponibili nei chiamanti. Il ciclo
corto sulle celle usa `No_Vector`; il prodotto di larghezza quattro conserva
le sue corsie SIMD. Le implementazioni di `MulMatVec` e `MulVecMatVec`
restano quelle della versione precedente.

Il codice macchina Ada usa già `vmulpd` e `vaddpd` su registri YMM:
quattro moltiplicazioni o somme double in parallelo. SIMD è una capacità
del processore disponibile anche ad Ada/SPARK; i contratti mantengono
la ricorrenza ordinata di ciascuna corsia.

API, dominio, contratti pubblici e ordine floating point sono invariati.
La primitiva corta prova l'uguaglianza allo stesso `Dot_Value`: con meno di
quattro termini le corsie sono zero e il risultato resta `0.0 + Tail_Sum`;
con quattro termini si conserva la riduzione originale a quattro corsie.
Inizializzazione, limiti e relazione per cella hanno invarianti separati.
Nessun nuovo `Assume`, corpo trusted o soppressione. Un nuovo `Hide_Info`,
giustificato nel ledger, evita di riespandere il modello ricorsivo già provato
nel ciclo corto: la composizione usa le uguaglianze dei contratti provati,
senza assumere la correttezza di alcun corpo.

## Prestazioni

| Versione, 228 casi | Più veloce di C | Intervallo include 1 | Più lenta di C |
|---|---:|---:|---:|
| Precedente, rimisurata | 76 | 43 | 109 |
| A·Bᵀ ottimizzato | 82 | 42 | 104 |

Tempi in ns; il rapporto Ada/C usa la mediana delle coppie, con IC bootstrap 95%.
Le mediane dei singoli tempi non vanno divise per ricostruire quel rapporto.

| Operazione | Forma | Ada prima | Ada dopo | C dopo | Rapporto [IC] | Esito |
|---|---|---:|---:|---:|---|---|
| `MulMatVec` | 1×1 | 0.595 | 0.596 | 0.789 | 0.752 [0.733, 0.793] | faster |
| `MulMatVec` | 3×3 | 2.048 | 2.119 | 2.266 | 0.931 [0.841, 0.980] | faster |
| `MulMatVec` | 4×4 | 3.788 | 3.582 | 2.847 | 1.254 [1.191, 1.314] | slower |
| `MulMatVec` | 64×64 | 215.191 | 217.140 | 208.673 | 1.028 [1.024, 1.088] | slower |
| `MulMatVec` | 128×128 | 834.997 | 838.665 | 891.673 | 0.972 [0.938, 0.993] | faster |
| `MulMatMatT` | 1×1 | 1.388 | 1.190 | 1.300 | 0.907 [0.839, 0.975] | faster |
| `MulMatMatT` | 3×3 | 7.310 | 5.814 | 6.657 | 0.881 [0.855, 0.894] | faster |
| `MulMatMatT` | 4×4 | 14.928 | 10.128 | 9.387 | 1.118 [0.987, 1.160] | overlap |
| `MulMatMatT` | 7×7 | 68.958 | 69.017 | 51.823 | 1.353 [1.292, 1.363] | slower |
| `MulMatMatT` | 16×16 | 426.215 | 340.066 | 242.676 | 1.378 [1.330, 1.430] | slower |
| `MulMatMatT` | 64×64 | 15378.260 | 14442.669 | 14423.198 | 0.991 [0.974, 1.025] | overlap |
| `MulMatMatT` | 128×128 | 122016.923 | 110112.344 | 127761.160 | 0.869 [0.858, 0.872] | faster |

Entrambe le versioni sono rimisurate con il medesimo nuovo harness: ogni
operazione ha un chiamante separato con un ciclo di ripetizione proprio,
in Ada e in C. Il dispatcher e il confine `No_Inline` sono esterni al ciclo;
l'inlining del kernel dentro il ciclo mantiene la normale politica release.
Questo evita che l'allocazione dei registri di un kernel dipenda dagli altri
19 rami del medesimo chiamante. Le barriere, i dati e il consumo dei risultati
sono preservati. I 228 casi mantengono il checksum del vecchio harness per
entrambe le versioni e i backend; non è una prova di equivalenza bit per bit.
L'assembly normalizzato dei chiamanti matrice-vettore, bilineare e trasposizione
è identico tra le due versioni; cambia quello del prodotto trasposto.
Rilevamento completo: 11 coppie alternate C/Ada, circa 12 ms CPU per campione,
buffer in cache, CPU 12 del Ryzen 7 9800X3D, Linux/WSL. Bootstrap della mediana
di 5.000 ricampionamenti, senza correzione per confronti multipli. Riconferma
separata: 44 casi con 21 coppie, comprese larghezza 2, forme rettangolari,
assi vuoti e dimensioni grandi. I dati grezzi includono mediana, MAD e tutte
le coppie. Nessuna compilazione, prova o suite durante le misure.

Il vecchio harness aggregato aveva mostrato effetti consistenti anche sulla
trasposizione invariata: per esempio, nel caso 7×19 il rapporto Ada/C passava
circa da 1,67 a 2,74. Questi risultati sono conservati e restano un limite
rilevante per l'integrazione in altri chiamanti; il risultato isolato non
cancella le regressioni osservate nel chiamante aggregato. La parità del motore
integrato non è stabilita da nessuno dei due microbenchmark.

Una successiva misura isolata ha evidenziato un costo aggiuntivo su output
vuoti; il ritorno anticipato è incluso nella versione finale e nella sua
prova completa. I risultati intermedi sono conservati come storia.

La variante precedente che modificava anche `MulMatVec` e l'inlining del
bilineare è stata scartata: il confronto su 68 casi mostrava regressioni
anche dove i guadagni sui prodotti corti erano netti. I suoi dati sono
conservati nel pacchetto come evidenza della decisione, non come risultato
della versione integrata.

Riferimento MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, normale SIMD C abilitato.
Harness identico tra versioni. GNAT/GCC/GNATprove 16.1 e GPRbuild 26;
`-O3 -march=native -flto -ffat-lto-objects -ffp-contract=off
-ffinite-math-only -fno-trapping-math -fno-math-errno` per entrambi i linguaggi.

Le classificazioni vicine a 1 possono cambiare con rumore e collocazione del
codice. L'intervallo che comprende 1 è inconcludente, non prova equivalenza.
Ogni rallentamento riproducibile resta aperto; i casi veloci non compensano
quelli lenti. La conferma separata va letta insieme alla misura completa.

## Confronto diretto tra versioni

Una campagna diretta alterna i quattro processi C precedente, Ada precedente,
C nuova e Ada nuova, invertendo l'ordine a ogni campione: 21 gruppi per
ciascuno di 66 casi. Include le forme dei kernel modificati e tutti i casi
nuovamente classificati lenti nella misura completa. Questo limita la deriva
temporale nel confronto prima/dopo; non elimina gli effetti di collocazione
del codice né costituisce una prova universale delle prestazioni.

| Operazione | nr×nc×nk | Ada nuova/precedente [IC] | Ada nuova/C | Esito contro C |
|---|---|---|---:|---|
| MulMatMatT | 1×1×1 | 0.880 [0.845, 0.907] | 0.955 | faster |
| MulMatMatT | 2×2×2 | 0.864 [0.826, 0.925] | 0.679 | faster |
| MulMatMatT | 3×3×3 | 0.786 [0.766, 0.802] | 0.880 | faster |
| MulMatMatT | 4×4×4 | 0.689 [0.666, 0.712] | 1.035 | overlap |
| MulMatMatT | 7×7×7 | 1.054 [1.033, 1.089] | 1.367 | slower |
| MulMatMatT | 16×16×16 | 0.781 [0.770, 0.788] | 1.354 | slower |
| MulMatMatT | 64×64×64 | 0.959 [0.950, 0.967] | 1.004 | overlap |
| MulMatMatT | 128×128×128 | 0.903 [0.896, 0.908] | 0.880 | faster |
| MulMatMatT | 7×3×11 | 0.791 [0.774, 0.812] | 0.841 | faster |
| MulMatVec | 64×64×64 | 1.005 [0.981, 1.033] | 1.022 | slower |
| MulMatVec | 128×128×128 | 0.999 [0.980, 1.008] | 0.990 | overlap |
| MulVecMatVec | 4×4×4 | 0.976 [0.955, 1.007] | 1.291 | slower |
| MulVecMatVec | 7×7×7 | 1.003 [0.972, 1.031] | 1.163 | slower |
| MulVecMatVec | 128×128×128 | 1.013 [0.964, 1.041] | 0.885 | faster |

Nel confronto diretto emergono i seguenti peggioramenti rispetto alla versione precedente; restano aperti e non sono compensati dai miglioramenti delle righe corte.

| Operazione | nr×nc×nk | Pattern | Ada nuova/precedente [IC] | Controllo C nuova/precedente [IC] |
|---|---|---:|---|---|
| MulMatVec | 64×3×64 | 0 | 1.024 [1.001, 1.035] | 0.998 [0.979, 1.005] |
| MulMatMatT | 7×7×7 | 0 | 1.054 [1.033, 1.089] | 0.992 [0.980, 1.005] |

Il controllo C usa lo stesso sorgente e rende visibili anche variazioni del
riferimento tra i due binari. Queste misure identificano casi da correggere o
riconfermare; da sole non isolano la causa di ogni differenza.

## Verifica

| Unità completa | Proved | Unproved | Avvisi revisionati |
|---|---:|---:|---:|
| `mj-blas` | 607 | 0 | 25 |
| `mj-vector_models` | 142 | 0 | 4 |
| `mj-matrix_types` | 51 | 0 | 2 |
| `mj-matrix_models` | 307 | 0 | 6 |
| `mj-matrices` | 2193 | 0 | 28 |

**3,300 obblighi provati, zero non provati, 65 avvisi revisionati.**
Diagnostica prima su `Rows_Dot_Short` e `Rows_Blocks`, poi sul ciclo corto
e su `MulMatMatT`, infine sulle cinque unità complete.

Per ciascuno dei profili development, validation e release:
1,097 asserzioni Ada, 72 test Python e 4,094 casi
C differenziali / 1,049,825 confronti. Il corpus matriciale conserva
i 371 casi storici e aggiunge 80 casi sulle diramazioni corte rettangolari e
vuote. In release: 451 casi / 307,332
confronti esatti di valori finiti contro ciascun riferimento C scalare e SIMD.
Lo zero con segno non è confrontato bit per bit; i test non costituiscono una
prova universale di equivalenza con C.

L'audit non trova FMA, funzioni ghost eseguibili o chiamate allo stack secondario
nei venti cicli cronometrati. Le prove riguardano le cinque unità indicate;
i file concorrenti dei quaternioni sono preservati e non ereditano questa prova.

La priorità resta chiudere i divari prestazionali, prima di estendere il kernel.
