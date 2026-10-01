# Mesh–mesh: indici Gold e prestazioni — 1 ottobre 2026

**L’obiettivo di essere sotto C in tutti i casi non è ancora raggiunto.** La nuova build migliora tutti i 40 casi rispetto alla precedente oltre l’incertezza accoppiata misurata. I guadagni arrivano al 50,3% nel tempo. Rispetto al C nativo siamo sotto nei casi con margine di cubo e hull da 512 vertici; restano divari nei contatti senza margine e nelle coppie separate.

Il lavoro è nel candidato isolato. Nessun commit, push o cambio di branch. Sono hull **convesse**: non è collisione di superfici concave generali, né una misura del passo di simulazione.

## Implementazione conservata

- Massimo lineare: memorizza il valore migliore ed evita di ricalcolarlo a ogni confronto. Stesso ordine binary64 e stessa scelta del seed nelle parità.
- Clipping: due buffer alternati eliminano la copia della lista di punti dopo ogni piano, conservando l’ordine aritmetico.
- Mappa immutabile vertice–faccia, costruita una volta: la ricerca delle facce candidate usa le sole incidenze. La lista mantiene ordine delle facce e prima posizione del vertice. Esaurimento della capacità esplicito e fallback alle scansioni.
- Grafo: compila una parola per coppia indice locale/globale e il grado di ogni vertice nella tabella degli ID globali. Il supporto usa liste contate, preservando l’ordine dei vicini e il confronto stretto del C. I formati originali restano disponibili.
- Gli asset possono essere condivisi da due istanze, come nel modello C. Il parser di prova compila ogni asset una sola volta. La condivisione richiede identità di vertici, facce e grafo.
- Nessuna nuova Assume, soppressione o implementazione fidata; nessun fast math o FMA introdotto. Le prove partono dai sottoprogrammi minimi e terminano con due esecuzioni fresche delle unità complete.

Le varianti di riduzione delle distanze EPA, inlining esteso, scrittura diretta EPA, decodifica unsigned e routine specializzate non hanno dato un vantaggio sufficientemente coerente: non sono nella consegna. Tentativi e snapshot restano in `intermediate/`. Il bug GNAT della prima variante con snapshot Ghost è documentato nei log; la versione consegnata compila nei due profili.

## Prove formali fresche

| Unità intera | Obblighi di prova | Analisi flow/inizializzazione | Proprietà |
|---|---:|---:|---|
| `MJ.Convex_Assets` | **309/309** | 35/35 | Massimo lineare con parità del seed; header, codifiche esatte, prima sentinella, gradi e conservazione delle altre parole/attributi |
| `MJ.Contact_Incidence` | **158/158** | 28/28 | Conteggio delle facce incidenti, appartenenza e prima posizione, ordine crescente, bounds, stato vuoto su fallimento |

Sono 467 obblighi di prova e 63 controlli flow/inizializzazione, tutti chiusi senza giustificazioni esterne. Gli hash di corpo e specifica in `proof-index.json` corrispondono allo snapshot consegnato. Gold riguarda queste proprietà modulari; non la completezza topologica del grafo né la correttezza geometrica globale di GJK/EPA e clipping. Queste ultime prove e quelle dei chiamanti restano aperte.

## Confronti numerici

| Ambito | Checked | Release | Esito |
|---|---:|---:|---|
| Primitive, 10 campi geometrici | 21.000 | 21.000 | 0 discrepanze inattese; 14 normali C e 4 falsi negativi capsule–box già diagnosticati restano espliciti |
| GJK/EPA singolo punto contro CCD nativo | 15.000 | 15.000 | 0 differenze oltre tolleranza |
| Tre famiglie mesh, primitive/mesh e mesh/mesh, entrambi gli ordini | 4.200 | 4.200 | 0 differenze oltre tolleranza |
| Mesh uguali/distinte, entrambe le direzioni, grafo originale/compatto e facce scansionate/indicizzate | 1.800 | 2.184 | 0 differenze oltre tolleranza |
| Stesse 4.200 geometrie con/senza mappa vertice–faccia | 4.200 | 4.200 | Output testuale identico |
| Regressione capsule–cilindro | 1 | 1 | Passa a tolleranza 1e-12 |

I 384 casi aggiuntivi di hull da 128/512 vertici della quarta riga sono eseguiti in release; la sua copertura checked comprende cubo, poliedro e faccia ampia. Ogni benchmark verifica anche tutte le 16 pose contro i 10 campi C prima dei tempi. Tolleranza geometrica invariata 3e-7 relativa; conteggio dei punti esatto. Questi test non sono una dimostrazione universale di equivalenza C. Terreno, flex, SDF e integrazione non sono rivalutati qui.

## Metodo delle misure

30 round per caso, tutte le sei permutazioni precedente/corrente/C, CPU 15, 16 piccoli spostamenti della seconda mesh, checksum di tutti i campi. Nessun nostro test o prover eseguito durante i benchmark finali. Il computer è condiviso: gli intervalli descrivono la variabilità campionata, non ogni carico possibile.

Riferimento nativo MuJoCo **3.14.0**, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`; hash libreria `5e7623e30f55bf324d4c9648379ebeba5bcd153ee0304c52eac74bf8d441000b`. Il C conserva il SIMD della libreria ufficiale. Wrapper GCC 13.3; Ada GNAT/GCC 16.1, O3, LTO, march=native e ffp-contract=off. I flag della wheel nativa non sono interamente noti. Versioni, comandi, hash dei binari e ambiente sono nei JSON.

Sono tempi di **precontatti geometrici per coppia**. Preparazione degli asset, I/O, broad phase, materiali/frame, vincoli, dinamica ed integrazione sono fuori dal tempo. C seleziona il callback prima del ciclo, mentre Ada include il dispatcher nel ciclo. Le mesh da 512 vertici compilano 934 facce per il primo asset, 927 per il secondo asset distinto. Gli array sono ammessi secondo i contratti del candidato: mappa fino a 8.192 vertici/65.536 incidenze, poligoni fino a 64 vertici; oltre la mappa si usano le scansioni. Gli altri limiti dei workspace e gli esiti di capacità restano espliciti.

Rapporto Ada/C sotto 1 significa più veloce. IC bootstrap 95% sulla mediana dei rapporti accoppiati; mediana dei tempi in ns. La variazione corrente/precedente è anch’essa accoppiata. Non si usa la media delle percentuali come tempo di simulazione.

### Asset condiviso da due istanze

| Caso | Prima ns | Ora ns | C ns | Ada/C [95%] | Tempo vs prima [95%] |
|---|---:|---:|---:|---|---|
| cube-aligned | 1224.4 | 942.6 | 882.7 | 1.072 [1.066, 1.086] | -22.4% [-23.3%, -21.2%] |
| cube-rotated | 2557.2 | 1997.6 | 1895.3 | 1.049 [1.023, 1.059] | -21.8% [-22.9%, -21.2%] |
| cube-margin | 14114.6 | 10563.6 | 11391.9 | 0.948 [0.924, 0.961] | -23.4% [-25.3%, -23.0%] |
| cube-separated | 100.3 | 70.2 | 65.3 | 1.071 [1.055, 1.094] | -29.6% [-30.9%, -28.1%] |
| polytope-aligned | 2145.1 | 1827.9 | 1608.7 | 1.135 [1.126, 1.144] | -15.0% [-17.2%, -13.5%] |
| polytope-rotated | 2269.2 | 2042.2 | 1838.5 | 1.121 [1.098, 1.130] | -10.0% [-10.8%, -9.5%] |
| polytope-margin | 11597.1 | 10714.5 | 10257.1 | 1.034 [0.997, 1.059] | -8.2% [-10.0%, -6.2%] |
| polytope-separated | 99.8 | 92.3 | 74.1 | 1.240 [1.220, 1.263] | -8.7% [-9.8%, -6.8%] |
| wide-face-aligned | 3080.6 | 2911.6 | 2436.5 | 1.194 [1.176, 1.218] | -4.5% [-7.1%, -2.5%] |
| wide-face-rotated | 3661.2 | 3175.1 | 2903.7 | 1.082 [1.052, 1.125] | -13.9% [-14.4%, -12.0%] |
| wide-face-margin | 17120.2 | 14957.5 | 14884.1 | 1.004 [0.997, 1.016] | -12.8% [-13.8%, -9.1%] |
| wide-face-separated | 126.7 | 104.8 | 97.4 | 1.064 [1.047, 1.094] | -17.0% [-18.0%, -13.4%] |
| round-128-aligned | 8943.7 | 6174.3 | 5730.3 | 1.074 [1.054, 1.092] | -31.4% [-32.1%, -30.2%] |
| round-128-rotated | 6682.9 | 4882.6 | 4522.4 | 1.079 [1.060, 1.093] | -26.3% [-27.2%, -25.9%] |
| round-128-margin | 26627.5 | 24225.5 | 23829.1 | 1.013 [0.990, 1.028] | -9.5% [-10.7%, -7.9%] |
| round-128-separated | 116.3 | 102.3 | 89.0 | 1.143 [1.129, 1.177] | -12.3% [-13.5%, -9.8%] |
| round-512-aligned | 17320.7 | 9054.6 | 8730.3 | 1.037 [1.021, 1.064] | -48.2% [-48.5%, -47.6%] |
| round-512-rotated | 12063.9 | 6840.4 | 6642.0 | 1.030 [1.000, 1.045] | -43.7% [-44.3%, -43.2%] |
| round-512-margin | 38346.4 | 31242.6 | 32619.7 | 0.958 [0.946, 0.969] | -18.0% [-19.5%, -17.4%] |
| round-512-separated | 128.8 | 108.9 | 98.9 | 1.097 [1.090, 1.113] | -15.3% [-16.5%, -12.7%] |

### Due asset diversi

| Caso | Prima ns | Ora ns | C ns | Ada/C [95%] | Tempo vs prima [95%] |
|---|---:|---:|---:|---|---|
| cube-aligned | 1228.0 | 959.6 | 908.0 | 1.057 [1.026, 1.065] | -21.5% [-22.2%, -20.7%] |
| cube-rotated | 2469.8 | 1945.0 | 1862.9 | 1.051 [1.029, 1.066] | -20.7% [-21.7%, -19.8%] |
| cube-margin | 13110.1 | 10109.8 | 10596.7 | 0.945 [0.932, 0.964] | -22.9% [-24.0%, -21.8%] |
| cube-separated | 99.5 | 70.3 | 65.2 | 1.078 [1.065, 1.093] | -28.9% [-30.2%, -27.6%] |
| polytope-aligned | 1788.3 | 1563.0 | 1411.1 | 1.115 [1.093, 1.128] | -11.9% [-13.7%, -10.5%] |
| polytope-rotated | 3045.5 | 2704.7 | 2391.5 | 1.134 [1.120, 1.145] | -10.8% [-11.4%, -9.4%] |
| polytope-margin | 14659.9 | 13502.5 | 12822.8 | 1.046 [1.019, 1.094] | -8.9% [-10.0%, -6.5%] |
| polytope-separated | 98.4 | 91.1 | 73.4 | 1.236 [1.218, 1.264] | -8.6% [-10.7%, -7.1%] |
| wide-face-aligned | 2760.0 | 2322.8 | 2324.9 | 0.999 [0.992, 1.017] | -15.4% [-16.7%, -14.6%] |
| wide-face-rotated | 4289.4 | 3680.0 | 3457.8 | 1.061 [1.026, 1.087] | -14.6% [-16.5%, -10.9%] |
| wide-face-margin | 20388.0 | 17849.7 | 17808.4 | 0.994 [0.987, 1.012] | -12.6% [-13.7%, -12.0%] |
| wide-face-separated | 129.9 | 106.0 | 98.4 | 1.077 [1.071, 1.094] | -17.7% [-18.3%, -16.1%] |
| round-128-aligned | 5914.6 | 4286.0 | 3816.5 | 1.100 [1.081, 1.138] | -27.7% [-29.5%, -24.2%] |
| round-128-rotated | 8989.9 | 7084.0 | 6704.5 | 1.062 [1.045, 1.076] | -20.7% [-21.7%, -19.9%] |
| round-128-margin | 38196.1 | 34380.5 | 34668.7 | 0.992 [0.982, 1.005] | -10.0% [-10.5%, -9.1%] |
| round-128-separated | 116.0 | 100.2 | 88.2 | 1.145 [1.133, 1.152] | -12.4% [-13.8%, -11.2%] |
| round-512-aligned | 12136.2 | 6039.2 | 5871.6 | 1.014 [1.001, 1.054] | -50.3% [-51.2%, -49.4%] |
| round-512-rotated | 16504.5 | 10546.9 | 10230.8 | 1.024 [1.011, 1.045] | -36.7% [-37.7%, -34.5%] |
| round-512-margin | 59513.5 | 48017.1 | 52047.1 | 0.930 [0.911, 0.962] | -19.3% [-22.1%, -17.2%] |
| round-512-separated | 126.8 | 109.3 | 100.3 | 1.095 [1.055, 1.102] | -14.6% [-16.0%, -13.3%] |

### Attribuzione alla condivisione degli asset

Un terzo benchmark usa **lo stesso binario corrente** nei due ruoli Ada: asset duplicato e asset condiviso. In questo modo il vantaggio del layout non viene attribuito tutto all’algoritmo. Gli input C hanno un asset condiviso. I tempi grezzi sono in `mesh-layout-benchmark.json`.

Per l’hull da 512 vertici allineato la sola condivisione riduce il tempo dell’1,8% [−3,2%, −1,0%]; con margine del 3,7% [−10,0%, −1,3%]. Per la maggioranza degli altri casi l’intervallo include zero. Il grosso del miglioramento rispetto alla vecchia build rimane nelle modifiche del kernel.

## Cosa resta per l’obiettivo sotto C

Per l’hull da 512 vertici senza margine il rapporto è 1,037 [1,021, 1,064] con asset condiviso/allineato; 1,014 [1,001, 1,054] con asset distinto/allineato. Non sono dichiarati sotto C. Con margine diventano 0,958 [0,946, 0,969] e 0,930 [0,911, 0,962]. Il poliedro separato resta circa +24%, pur con costo assoluto vicino a 90 ns. La faccia ampia allineata con asset condiviso resta +19,4%.

I prossimi interventi devono ridurre il costo dei supporti e delle operazioni EPA residue, verificando la generazione del codice contro quella C; sui casi separati va isolato anche il costo del dispatcher. I profili instrumentati intermedi sono conservati come diagnostica, non come misura del binario finale. Manca ancora una prova integrata di movimento equivalente: il risultato locale non stabilisce parità del motore.

## Evidenze e riproduzione

`source-snapshot.tar.gz` contiene i sorgenti esatti delle build e dei due proof finali. `baseline-source.tar.gz` è il riferimento Ada precedente. `manifest.json` e `baseline-manifest.json` identificano binari e oracolo. Il driver congelato riproduce le prime due tabelle; `benchmark_driver_layout.py` aggiunge il confronto dello stesso binario con due layout. I driver vengono eseguiti dalla directory del candidato con il suo ambiente Python/NumPy/MuJoCo e PYTHONPATH indirizzato ai test congelati. Il driver layout è supplementare e ha un hash distinto dal driver dello snapshot.

`benchmark-commands.json`, `verification-commands.json`, `proof-index.json`, `source-changes.json` e `SHA256SUMS.json` conservano comandi e impronte. Gli snapshot delle varianti non consegnate e i proof falliti sono sotto `intermediate/`; i loro esiti non sono sommati alle prove finali.
