# Risultati muscoli — 30 settembre 2026

Modulo autonomo allineato alle cinque funzioni muscolari di MuJoCo 3.14.0,
più valutazione della forza e aggiornamento Euler dell'attivazione.

| Verifica | Risultato |
| --- | --- |
| Gold `mj-muscle_kernels` | 358 controlli chiusi; 0 aperti; 0 avvisi |
| Gold `mj-muscle_actuation` | 42 controlli chiusi; 0 aperti; 0 avvisi |
| Confronto C, build con controlli | 10.179 casi; 26.523 confronti numericamente identici |
| Confronto C, release | 10.179 casi; 26.523 confronti numericamente identici |
| Motore MuJoCo reale | 320 casi con giunti/tendini, gain e bias distinti, actearly e limiti |

Le prove complete coprono tutti i corpi e modelli delle due unità (41
sottoprogrammi), senza assunzioni o corpi saltati. La specifica fissa il calcolo
floating-point, i rami, ogni campo in uscita e lo stato conservato sui rifiuti.
Non dimostra l'intera simulazione o l'accuratezza rispetto alla fisica ideale.
Le diagnosi sono partite dai singoli sottoprogrammi. L'ultimo collegamento fra
controllo saturato e derivata è chiuso con lemmi verificati di congruenza.
Le sorgenti analizzate su filesystem nativo sono copie identiche byte per byte;
il rapporto registra la sola trasformazione dei percorsi del progetto.

## Prestazioni diagnostiche

GCC/GNAT 16.1, O3, march=native, LTO, contrazione FMA disabilitata su entrambi.
Dati e preparazione fuori timing, stato dipendente dal passo precedente, ordine
alternato, warmup escluso. Affinità CPU 6; host con altre prove in esecuzione.

| Carico scalare | Ada, mediana ns/passo | C, mediana ns/passo | Rapporto accoppiato mediano Ada/C | Intervallo dei rapporti |
| --- | ---: | ---: | ---: | ---: |
| hard-switch | 9.096 | 8.544 | 1.064 | 1.018–1.100 |
| smooth-actearly | 11.617 | 11.368 | 1.022 | 0.999–1.165 |
| smooth-actearly-force-limit | 11.444 | 11.558 | 0.992 | 0.852–1.014 |

Conserviamo tutti i campioni e la dispersione: le mediane non attestano una
parità generale. Questo carico comprende forza attiva/passiva, dinamica
muscolare ed Euler, con lunghezza/velocità fornite. Trasmissioni, proiezione,
massa, contatti e solver non sono cronometrati. La parità su un movimento
completo resta da misurare dopo l'integrazione.

## Da collegare al motore attivo

Loader/calibrazione dei parametri, indirizzi dell'attivazione nello stato,
trasmissioni, proiezione delle forze, limiti totali su giunti/tendini, disabilitazione
attuatori e ciclo degli integratori. L'API è utilizzabile dal candidato, ma il
loader e la pipeline smooth principali non acquisiscono ancora i muscoli.

`Step` rifiuta aggiornamenti fuori dal dominio Tier0 conservando l'attivazione;
questa politica è esplicita e più restrittiva dello stato C senza limiti.
I test numerici considerano uguali i due zeri con segno diverso.

Rapporti grezzi, comandi, copertura e hash: `results/evidence-20260930.zip`.
