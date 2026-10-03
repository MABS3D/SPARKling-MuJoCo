# Misura integrata r5/r7 e regressione Newton

2026-10-03, root. Obiettivo globale ancora aperto; nessuna parità dichiarata.

## Metodo e attribuzione

Eseguito `experimental/constrained-step/tests/benchmark_compare.py` sul Ryzen7
9800X3D, WSL/Linux, affinità CPU2. Quindici blocchi con ordine alternato fra
baseline Ada, candidato Ada e C; otto traiettorie misurate più una di warm-up per
blocco, cento passi per traiettoria. Reset, parsing e stampa fuori dal tempo.
Stato finale confrontato in ogni blocco alle tolleranze originali.

I tre worker hanno confermato la conclusione dei propri job pesanti prima della
misura; anche la build root era terminata. Non sono disattivate le attività di
fondo del sistema operativo. Campioni grezzi, p95 e intervalli bootstrap95% dei
rapporti appaiati sono nelle ricevute; non si deduce parità da una soglia fissa.

- Baseline: snapshot dynamics r5 del2026-10-02, compilato ora in release dai
  sorgenti congelati, hash verificati prima/dopo.
- Candidato: snapshot dynamics r7 del2026-10-03, già validato in entrambi i profili.
  Precede adesione e gli ultimi helper equality; non è l'intero checkout corrente.
- C: libreria nativa ufficiale3.14.0, nessun SIMD disattivato. Hash nella ricevuta.
- Entrambi gli Ada: GNAT16.1, O3, gnatn2, march=native, LTO,
  ffp-contract=off. Nessun nuovo controllo soppresso.

Artefatti ripetibili: `/var/tmp/sparkling-equality-window-benchmark-20261003`.
Ricevute conservate in
`experimental/constrained-step/evidence/20261003-performance/r5-r7-*`.

## Risultati

Microsecondi mediani per passo; i rapporti sono mediane dei blocchi appaiati e
possono differire dal rapporto tra le due mediane dei tempi.

| Modello | r5 | r7 | C | r7/C | r7/r5 |
|---|---:|---:|---:|---:|---:|
| Sfera Newton,6DOF |3.47|3.70|2.69|1.39|1.06|
| Limiti/attrito,3DOF |2.49|2.54|2.13|1.19|1.03|
| Box,16righe |5.79|5.91|3.40|1.74|1.04|
| Antenati comuni,8DOF |4.57|4.73|2.63|1.85|1.04|
| 4corpi liberi,24DOF |11.98|19.31|5.45|3.57|1.66|
| 8corpi liberi,48DOF |26.51|74.27|9.07|8.24|2.82|
| 16corpi liberi,96DOF |68.06|399.43|16.29|24.79|5.82|

Tutti gli stati passano, errore massimo nell'ordine di1e-14. La regressione di
96DOF è molto oltre il rumore: r7/r5 CI95%[5.66,5.92], r7/C[23.93,25.27].
Non si media questa regressione con casi piccoli per presentare una parità.

## Diagnosi e prossima azione

Gli XML misurati chiedono esplicitamente `jacobian="sparse"`. La nuova r7 usa
il fattore Newton denso per tutti i modelli, mentre il precedente Factor_Metric
sfruttava i componenti indipendenti. Inoltre il kernel denso costruisce vettori
Prefix temporanei dentro la fattorizzazione. Sono ipotesi concrete da isolare,
non ancora una scomposizione misurata del costo.

Dynamics ha preparato un controllo che mantiene tutta r7, incluso il dominio
warm-start, e ripristina solo il precedente fattore/solve Newton. Copia isolata
in `/var/tmp/sparkling-newton-ablation-20261003`; manifest differisce in un solo
sorgente. Build release completata con hash congelati verificati prima/dopo.

Priorità comunicata a dynamics: preservare il ramo denso ordinato come C per
i modelli densi e implementare/selezionare il ramo sparse corretto. Non
riclassificare la regressione come rumore, non cambiare tolleranze e non
perdere i contratti già dimostrati.

## Controllo concluso

Seconda finestra senza nostri job pesanti, stesso protocollo15x8x100 e CPU2.
Il controllo conserva tutta r7 e ripristina solo il fattore/solve Newton precedente.

| Modello | Controllo r7/vecchio Newton | r7 | C | r7/controllo |
|---|---:|---:|---:|---:|
| 24DOF |11.60us|19.47us|5.46us|1.69|
| 48DOF |25.87us|74.70us|8.97us|2.85|
| 96DOF |66.56us|399.63us|16.51us|6.00|

I sette workload passano nuovamente il confronto degli stati. A96DOF,
CI95% del rapporto r7/controllo[5.92,6.08]: il cambiamento del percorso Newton
aggiunge circa333us, l'83% del tempo totale della r7 in quel caso. Questo
controllo attribuisce il costo al cambiamento complessivo del percorso Newton;
non separa ancora fattorizzazione, solve, copie Prefix e riuso della massa.
Il vecchio percorso mantiene inoltre i limiti numerici già osservati nei casi
estremi, quindi il controllo non è una correzione da integrare.

Dynamics ha verificato nel C che il ramo sparse usa `mju_cholFactorNumeric`,
ordine inverso e pattern simbolici L/LT. È diverso anche dal vecchio
Factor_Metric. La correzione in corso deve conservare gli zeri strutturali di J
e massa e usare il dispatch `Opt.Jacobian`, compreso Auto(nv>=60).
Ricevute `newton-ablation-results.json`, `newton-control-*` e patch esatta nella
directory evidence. I worker sono stati rimessi in esecuzione dopo la misura.

## Newton sparso C: prima misura integrata r62

Dynamics ha aggiunto dispatch dense/sparse, struttura simbolica L/LT e ordine numerico C3.14; 380/380 confronti isolati esatti, prove dell’intera unità ancora aperte. R62 validation+release stessa snapshot299file (manifest `a16a42478e09cc54d4cda230ef2910cb26757dad39272cb436a03299280a1e6e`), con integrazione scalar e adesione. La misura non è una ablation singola.

|Modello|r7 µs/passo|r62 µs/passo|C µs/passo|r62/r7 appaiato|r62/C appaiato|
|---|---:|---:|---:|---:|---:|
|sphere_Newton_3_0.2 (6DOF)|3.707|3.932|2.622|1.072|1.505|
|coupled_limits_friction (3DOF)|2.471|2.633|2.195|1.056|1.182|
|box_multiple (6DOF)|5.981|6.726|3.472|1.112|1.917|
|shared_ancestors (8DOF)|4.738|5.113|2.591|1.084|1.972|
|4_free_bodies (24DOF)|19.284|13.435|5.466|0.697|2.485|
|8_free_bodies (48DOF)|73.762|32.219|9.131|0.437|3.539|
|16_free_bodies (96DOF)|400.394|89.478|16.004|0.226|5.596|

A96DOF rapporto r62/r7 0.2255, IC95[0.2217,0.2275]; r62/C5.5957, IC95[5.5758,5.6268]. Riduzione circa77.45%, ma resta oltre5.5volte C e più lento del vecchio controllo Newton66.56µs misurato nella finestra precedente (quest’ultimo confronto non appaiato). I quattro casi piccoli regrediscono6–11% rispetto r7; non attribuiti senza ablation perché sono cambiati anche altri moduli. Nessuna modifica delle soglie o soppressione dei controlli.

Tutte le traiettorie passano su tutti i blocchi.15blocchi alternati,8+1warmup traiettorie,100passi,CPU2; tutti3worker senza job pesanti, processi verificati, poi ripresi. I tempi e gli intervalli completi, p95, hash e manifest sono nelle ricevute `sparse-r62-*`. Questa è evidenza sullo snapshot r62; le successive modifiche weighted flex/prove non sono incluse.
