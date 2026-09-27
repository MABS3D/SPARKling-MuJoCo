# MuJoCo: prestazioni delle matrici

Il criterio corrente privilegia il movimento completo: i conteggi sotto sono
diagnostica dei kernel, non una stima delle prestazioni del simulatore. La prima
[prova integrata](movement-performance.md) misura separatamente il prototipo
senza contatti e un collegamento sperimentale ai kernel Gold.

## Trasposizione: aggiornamento del 2026-09-24

La trasposizione generica specializza le matrici con 1–5 righe, copia due
componenti per iterazione con 6–15 righe e mantiene un percorso SIMD dedicato
alle quadrate 16×16 e 64×64. Le altre forme conservano il ciclo generale. Sugli assi vuoti
ritorna immediatamente; l’output è inizializzato dalle copie, senza azzeramenti
preventivi. Ogni percorso
prova la stessa relazione per componente e l’inizializzazione completa, senza
nuove assunzioni né modifiche all’ordine floating point.

Il [fixture riproducibile](../tests/matrix_performance/README.md) confronta
la baseline immutabile `2c26e49b` e il codice corrente in due eseguibili, ciascuno
con una sola versione Ada e il normale riferimento C SIMD. I quattro slot
sono bilanciati; i rapporti Ada/Ada, C/C e Ada/C restano tutti visibili.
La prova completa corrente passa **3.504 obblighi, zero non provati e 71 avvisi
revisionati** sulle cinque unità numeriche. Anche quaternioni, pose e rotazioni
passano la riconferma completa: altri 694 obblighi, zero non provati.

Development, validation e release passano ciascuno 1.097 asserzioni Ada,
72 test Python e 1.438.490 confronti C su 4.218 casi. La parte matriciale
comprende 535 casi completi / 544.872 confronti e 40 casi dedicati alla
trasposizione / 151.125 confronti, ripetuti anche contro il C SIMD in release.

L’esperimento con entrambe le versioni Ada nello stesso eseguibile ha rivelato
un limite del banco: LTO introduce chiamate fuori linea anche nei kernel
invariati. Quei risultati restano nello storico e non sostituiscono la misura
normale. Nei due eseguibili separati, 19 kernel Ada su 20 e tutti i 20 chiamanti
C mantengono le stesse istruzioni normalizzate fra versioni. Cambia soltanto
la trasposizione; gli effetti di collocazione del codice restano misurabili.
Le [evidenze](../tests/matrix_performance/evidence/README.md) conservano anche
le varianti scartate: il percorso vettoriale su tutte le quadrate 16–64
peggiorava la 63×63, mentre una copia a coppie era insufficiente per cinque
righe. La versione corrente corregge entrambe le scelte.

### Risultato corrente

La conferma della trasposizione misura **40 casi non vuoti più veloci del C**;
i nove casi vuoti hanno sette segnali di rallentamento e due esiti inconcludenti.
Sono 49 casi e 47 forme distinte: 64×16 e 64×64 compaiono due volte con un
parametro `nk` diverso, irrilevante per questa operazione. Le forme non vuote
distinte sono 38. Rapporti inferiori a 1 significano meno tempo; le percentuali
sotto indicano riduzione del tempo, non incremento reciproco della velocità.

| Forma | Nuova/precedente Ada [IC 95%] | Ada/C [IC 95%] | Tempo in meno del C |
|---|---:|---:|---:|
| 3×3 | 0.513 [0.506, 0.518] | 0.879 [0.872, 0.885] | 12.1% |
| 4×4 | 0.369 [0.366, 0.376] | 0.584 [0.569, 0.592] | 41.6% |
| 5×7 | 0.470 [0.463, 0.483] | 0.699 [0.691, 0.729] | 30.1% |
| 5×32 | 0.374 [0.371, 0.377] | 0.594 [0.590, 0.598] | 40.6% |
| 7×7 | 0.696 [0.687, 0.701] | 0.925 [0.912, 0.931] | 7.5% |
| 7×19 | 0.578 [0.575, 0.582] | 0.871 [0.860, 0.878] | 12.9% |
| 16×16 | 0.983 [0.974, 0.993] | 0.694 [0.686, 0.697] | 30.6% |
| 63×63 | 0.982 [0.974, 0.997] | 0.589 [0.580, 0.601] | 41.1% |
| 64×64 | 1.007 [0.993, 1.031] | 0.626 [0.623, 0.636] | 37.4% |
| 128×128 | 1.023 [1.007, 1.042] | 0.257 [0.254, 0.259] | 74.3% |

Il guadagno delle forme grandi sul C era già presente e viene conservato; non è
interamente attribuito a questo incremento. Nella misura generale dei 228 casi:

| Versione | Più veloce del C | Inconcludente | Più lenta del C |
|---|---:|---:|---:|
| Baseline rimisurata | 84 | 36 | 108 |
| Corrente | 88 | 40 | 100 |

Non sono conteggi pesati per un carico reale, né otto rallentamenti sicuramente
risolti: classificazioni e collocazione del codice possono variare. Rispetto
alla precedente Ada, la misura generale segnala 20 miglioramenti, nove
peggioramenti e 199 esiti inconcludenti. La riconferma separata dei nove segnali
ne lascia uno riproducibile, sul caso vuoto della trasposizione; gli altri otto
non si ripetono. Anche il controllo C/C mostra variazioni e resta nei dati grezzi.

**Accettazione prestazionale ancora aperta.** La prova più lunga dei dodici
segnali della trasposizione riconferma, contro la precedente Ada, **+2,8% sulla
63×16** (IC [1.016, 1.041]) e **+2,0% sulla 128×128** (IC [1.010, 1.026]).
Queste forme restano rispettivamente circa il 47% e il 75% più rapide del C,
ma i peggioramenti non vengono compensati dai guadagni altrove. La 65×16 è
inconcludente nella riconferma. Sui casi vuoti, sei dei sette segnali contro C
si ripetono; si cronometra soprattutto il ciclo/barriera del chiamante, circa
un decimo di nanosecondo per iterazione, senza copiare componenti. Restano
registrati come lavoro aperto, senza applicare una soglia arbitraria di rumore.

Un’ulteriore variante con `Inline_Always` sul dispatcher passa la prova locale
e i test numerici, ma viene scartata: guadagna circa il 36% sulla 3×3 e perde
circa il 24% sulla 4×4 e il 20% sulla 5×32 rispetto alla versione corrente.
I [dati finali e le riconferme](../tests/matrix_performance/evidence/summary.json)
conservano tutti i casi. Il [codice generato](../tests/matrix_performance/evidence/standalone-codegen.json)
non contiene FMA, funzioni ghost o stack secondario nei percorsi esaminati.
Il chiamante cronometrato della trasposizione cresce da 875 a 2.800 byte;
l’effetto nella cache delle istruzioni dei chiamanti integrati resta da misurare.



## Storico: prodotto A·Bᵀ con righe corte

I dati che seguono appartengono alla precedente ottimizzazione, prima della
modifica alla trasposizione. Non sono le misure del sorgente corrente.

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

### Prestazioni

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

### Confronto diretto tra versioni

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

### Verifica

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
