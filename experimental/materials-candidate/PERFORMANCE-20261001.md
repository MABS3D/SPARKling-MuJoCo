# Ottimizzazione dei materiali — 1 ottobre 2026

Il triangolo e i contatti misti sono stati ottimizzati mantenendo la verifica
funzionale Gold. Questa misura confronta, nella stessa sessione, il binario
precedente congelato, il codice corrente e il riferimento C MuJoCo 3.14.0.
Sono microbenchmark dei componenti isolati con input già predisposti.

| Caso | Prima, ns | Ora, ns | C, ns | Ora/prima | Ora/C |
|---|---:|---:|---:|---:|---:|
| Triangolo | 20.84 | 10.65 | 12.43 | -48.9% | -14.3% |
| Tetraedro | 57.58 | 56.76 | 61.82 | -1.4% | -8.2% |
| 10 coefficienti/leggi scalari | 6.13 | 6.27 | 6.10 | +2.3% | +2.9% |
| Contatto: priorità uguale | 11.81 | 5.47 | 7.87 | -53.7% | -30.5% |
| Contatto: priorità diversa | 9.30 | 3.07 | 6.60 | -67.0% | -53.5% |
| Contatto: riferimento diretto | 11.97 | 5.01 | 7.60 | -58.1% | -34.1% |
| Contatto: coppia esplicita | 7.26 | 2.81 | 4.19 | -61.3% | -32.9% |
| Contatto: override | 7.43 | 3.25 | 7.91 | -56.3% | -59.0% |
| Contatto: stesso flex | 11.45 | 4.96 | 7.39 | -56.7% | -32.9% |
| Contatti misti | 10.17 | 4.29 | 6.92 | -57.8% | -38.0% |

Le percentuali in tabella sono rapporti fra mediane marginali. La mediana dei
rapporti appaiati e gli intervalli bootstrap al 95% sono conservati nel JSON.
Per il triangolo, il rapporto appaiato nuovo/C è 0.854; per i contatti misti è 0.621.
La suite delle leggi scalari presenta un piccolo aumento nel rapporto
appaiato (circa 1–2%); è riportato anche se il suo algoritmo non è cambiato.
Non si deduce una prestazione complessiva dalla media di queste percentuali.

## Cambiamenti

- Il caso triangolare ha sei coppie di spigoli esplicite. Il compilatore può
  riutilizzare le tre tracce e ottimizzare le contrazioni senza consultare le
  mappe per ogni coefficiente. Il contratto richiede ancora tutti i 21 valori,
  compreso il padding nullo. Il tetraedro conserva l'iterazione compatta.
- `Prepare` sceglie un blocco di parametri per ramo, scrive direttamente
  nell'oggetto di ritorno, calcola il peso solo nel ramo di miscelazione e
  calcola una sola volta ciascuno dei tre coefficienti di attrito superficiale.
- Gli entry point richiedono inlining. Il compilatore vede il chiamante e può
  eliminare parte del passaggio/copia dei record.
- `Minimum` e `Maximum` usano le comparazioni C su input finiti. Le loro
  proprietà numeriche sono provate separatamente; anche gli zeri con segno
  mantengono la scelta del primo operando nei pareggi, come in C. È stata
  corretta una differenza preesistente del profilo checked nel mixing generico.

I contratti di uscita, i domini di input e l'ordine aritmetico sono mantenuti.
Il modello indipendente `Expected` compone i selettori scalari dimostrati;
non chiama `Prepare` o `Mix`. `Hide_Info` rende modulari le prove dei chiamanti,
ma i corpi di tutti i selettori sono verificati. Nessun `Assume`, skip di prova,
nuovo corpo fidato o riduzione del dominio è introdotto.

## Verifiche

| Unità | Verifiche complete | Aperte | Avvisi |
|---|---:|---:|---:|
| `MJ.Elastic_Materials` | 126 | 0 | 0 |
| `MJ.Contact_Materials` | 73 | 0 | 0 |

Le prove locali precedono quelle complete. Le 199 verifiche sopra includono
sicurezza, comportamento funzionale e flusso; non vanno sommate ai controlli
locali sovrapposti. La copertura di tutti i sottoprogrammi dichiarati è verificata.

Entrambi i profili checked e release superano 3.072 casi algebrici (101.376
valori identici bit per bit), 64 casi aggiuntivi con zeri con segno, 96 contatti
realmente prodotti da MuJoCo e 32 matrici `flex_stiffness` compilate dal motore.
Il profilo checked verifica inoltre nove rifiuti di input fuori dominio.
Le prove non certificano precisione rispetto ai reali o stabilità dell'intera
simulazione; il collegamento alla pipeline principale resta da implementare.

## Metodo prestazionale e controlli sul riferimento

AMD Ryzen 7 9800X3D sotto WSL2, CPU logica 5 fissata con `taskset`. GCC/GNAT
16.1.0, `-O3 -march=native -ffp-contract=off -flto`; Ada usa anche
`-gnat2022 -gnatn -gnatp`. Il riferimento C include i corpi originali delle
utility copia/minimo/massimo, consentendo a LTO di incorporarle. Nessuna
chiamata alla libreria condivisa per queste utility è aggiunta al percorso C.

Ogni gruppo contiene 64 input; riscaldamento di 1.024 batch, 21 ripetizioni
per versione, ordine ruotato e invertito, batch calibrati per almeno circa
100 ms sulla versione più veloce. Parsing, preparazione degli input, output e
confronto dei risultati sono fuori dal tempo. Una barriera C opaca identica
nei driver impedisce l'eliminazione dei batch. Ogni campo di output è
controllato bit per bit a ogni esecuzione.

Il sistema non era dedicato: i JSON riportano dispersione, p05/p95 e
intervalli sui rapporti appaiati. Il costo di futuri adattatori, incluso
l'eventuale assemblaggio delle strutture `Surface` durante lo step, non è
misurato. Le basi geometriche sono già disponibili. Non sono inclusi frame
di contatto, collision detection, proiezione delle forze, solver o integrazione.

Sono stati verificati due ulteriori riferimenti per evitare confronti deboli:

1. C con inlining esplicito anche dei wrapper. Nei controlli sui due obiettivi
   risultava meno competitivo dell'inlining scelto automaticamente dal compilatore.
2. C triangolare senza l'azzeramento del padding introdotto dal primo driver:
   il buffer globale è inizializzato fuori dal tempo, come lo storage del modello.
   Anche in questa variante tutti gli output coincidono. I tempi mediani sono:

| Caso | Prima, ns | Ora, ns | C senza padding aggiunto, ns |
|---|---:|---:|---:|
| Triangolo | 20.24 | 10.55 | 12.74 |
| Contatti misti | 9.91 | 3.98 | 6.57 |

La compilazione della rigidità triangolare avviene principalmente al caricamento;
i contatti vengono preparati durante la simulazione. Servirà una misura dello
step integrato per conoscere il beneficio complessivo.

## Evidenze e riproduzione

`results/summary-20261001.json` associa prove, sorgenti e misure.
`results/evidence-20261001.zip` contiene snapshot, report SPARK, log e confronti
numerici, sorgenti dei driver, fixture, comandi e misure grezze. Le prove di
settembre sono conservate separatamente come snapshot storico.

Per build, prove e confronti numerici usare i comandi del README con directory
nuove. I driver prestazionali congelati nell'archivio mantengono i percorsi
espliciti delle toolchain e degli snapshot del medesimo host; richiedono
l'ambiente `/var/tmp/sparkling-movement-env` e i file baseline indicati. I
binari originali e i rispettivi sorgenti sono conservati nell'archivio.
Le prove intermedie, inclusi i tentativi falliti, restano sotto
`/var/tmp/sparkling-materials-opt-20261001`; solo gli esiti finali superati
sono evidenza di accettazione del codice corrente.
