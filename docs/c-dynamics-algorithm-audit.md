# Perché il percorso C fa meno lavoro — 2026-09-24

Questa pagina conserva l'analisi precedente alla modifica. Il seguito con
implementazione, prove e misure è in [Ottimizzazione della dinamica](dynamics-optimization.md).

Confronto con **MuJoCo 3.14.0**, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, già usato nel benchmark.
I quattro file C esaminati coincidono con il commit. Questa è un'analisi degli
algoritmi del riferimento fissato, non una migrazione a una nuova versione.

Il vantaggio principale individuato è la quantità di lavoro: il prototipo
assembla la massa sommando contributi di Jacobiani per corpo; il C accumula
inerzie composite sull'albero. Inoltre il prototipo esegue controlli numerici
più costosi, con una politica di rifiuto diversa da quella del C.

## Assemblaggio della massa

In [mj_crb](../mujoco/src/engine/engine_core_smooth.c), il C:

1. Parte dalle inerzie spaziali `cinert`, preparate una volta per corpo da
   `mj_comPos`. Sono rappresentate da dieci numeri nel riferimento comune
   centrato sul centro di massa del sottoalbero della radice.
2. Accumula le inerzie dai figli ai genitori con una visita inversa.
3. Calcola una volta per DOF il prodotto tra inerzia composita e asse di moto.
4. Riutilizza quel prodotto nei prodotti scalari con i soli DOF antenati.

Il prototipo, in [Assemble](../experimental/smooth/src/mj-data-inertia.adb),
visita invece tutti i corpi e tutte le coppie del triangolo inferiore dei DOF.
Ogni `Mass_Contribution` richiama `Inertia_Times`, che ruota il vettore nel
riferimento inerziale, applica la diagonale e lo riporta nel riferimento globale.
Il prodotto per lo stesso corpo e la stessa colonna viene ripetuto.

Conteggi dei cicli nei tre modelli effettivamente misurati:

| Operazione per assemblaggio | 1 DOF | 5 DOF ramificati | 12 DOF in catena |
|---|---:|---:|---:|
| SPARK: contributi corpo–coppia, ciascuno con `Inertia_Times` | 1 | 60 | 936 |
| C: prodotti inerzia spaziale–vettore, dopo accumulo | 1 | 5 | 12 |
| C: prodotti scalari finali a sei componenti | 1 | 14 | 78 |
| C: corpi non world da preparare prima del CRB | 1 | 4 | 12 |

Sono operazioni diverse e **non sono rapporti di velocità**. In particolare,
il C deve preparare i riferimenti e accumulare le inerzie. I conteggi mostrano
comunque la differenza strutturale: su una catena con un DOF per corpo,
l'assemblaggio attuale cresce come O(n³), il CRB come O(n²).

Applicazioni possibili, in ordine di invasività:

* **Riuso locale:** conservare `Inertia_Times` per corpo/colonna, mantenendo
  l'ordine di visita delle coppie e delle somme. Le chiamate scenderebbero da
  936 a 144 nella catena, e da 60 a 20 nel ramificato. Non serve ancora cambiare
  l'algoritmo fisico. Occorre provare il contenuto della cache e preservare anche
  limiti numerici, uscite anticipate e dati non modificati.
* **Solo antenati:** usare la topologia per evitare colonne strutturalmente
  nulle, senza una soglia numerica. I contributi scenderebbero a 364 e 36;
  combinando anche il riuso, i prodotti di inerzia sarebbero 78 e 15.
  Serve dimostrare quali colonne sono nulle e l'effetto dell'omissione delle
  operazioni, incluse le convenzioni sugli zeri floating point.
* **CRB:** adottare direttamente l'accumulo del C. È il cambiamento con il
  vantaggio asintotico sull'assemblaggio. Può inizialmente scrivere nel formato
  denso pubblico attuale, evitando di legare il primo porting al cambio di
  tutti i buffer. Richiede i nuovi kernel spaziali e contratti sul nuovo ordine
  di calcolo; non è una riscrittura equivalente bit per bit alle somme attuali.

## Fattorizzazione e risoluzioni

`mj_factorM` conserva una fattorizzazione sparsa `L' D L` e gli inversi della
diagonale; `mj_solveLD` li riutilizza. Le righe sono contigue, descritte da
`M_rowadr`, `M_rownnz` e `M_colind`; i cicli percorrono gli elementi presenti.
Il prototipo usa una fattorizzazione densa `L D L'`, calcola esplicitamente la
norma della matrice e chiama `Check_Condition` prima della risoluzione fisica.

**La sparsità da sola non spiega il divario della catena:** a 12 DOF tutti i 78
elementi del triangolo sono strutturalmente presenti. A 5 DOF ne mancano solo
uno su 15. Nella catena entrambe le fattorizzazioni hanno 286 termini scalari
di aggiornamento/somma nei rispettivi cicli, con costi diversi per termine;
la fattorizzazione rimane cubica nel caso denso. La rappresentazione compatta
riduce memoria e traffico, ma non rende lineare questo caso.

Il costo aggiuntivo più evidente è `Check_Condition`: risolve il sistema per
ciascun vettore della base per accumulare le somme assolute delle righe
dell'inversa scalata. Il percorso C esaminato non esegue questo controllo.

| Per passo, con lo smorzamento dei benchmark | 5 DOF SPARK / C | 12 DOF SPARK / C |
|---|---:|---:|
| Fattorizzazioni | 2 / 2 | 2 / 2 |
| Risoluzioni per ottenere accelerazioni | 2 / 2 | 2 / 2 |
| Risoluzioni aggiuntive per il condizionamento | 10 / 0 | 24 / 0 |
| Totale risoluzioni | **12 / 2** | **26 / 2** |

Le due matrici sono `M` e `M + h*diag(damping)`: anche il C le distingue.
Non c'è una seconda fattorizzazione da eliminare automaticamente nei benchmark.
Il C evita quella di Euler quando non vi è smorzamento effettivo; nel prototipo
`Implicit_Damping` dipende dai flag, senza questa verifica sul contenuto.
Questo percorso rapido è applicabile ai modelli senza smorzamento, ma non
spiega un guadagno nei tre benchmark attuali, che hanno smorzamento positivo.

Il C limita dal basso i pivot troppo piccoli a `mjMINVAL` e segnala un warning.
Il prototipo rifiuta i casi singolari/mal condizionati, usa soglie relative e
controlla il dominio numerico. **Eliminare il controllo del condizionamento o
copiare il clamp cambia la politica**, non è un'ottimizzazione a comportamento
invariato. Possibili lavori: riutilizzare meglio i fattori, valutare un controllo
sufficiente più economico con fallback, oppure specificare una politica nuova.
Un nuovo criterio deve avere una giustificazione numerica, inclusi gli errori di
arrotondamento e il comportamento alla soglia; non basta che passi i modelli
ordinari. Le divisioni sostituite con moltiplicazioni per inversi richiedono
anch'esse contratti sull'effettivo algoritmo floating point.

## Forze e cinematica

Il C usa `mj_comVel` e `mj_rne`: passaggio in avanti per accelerazioni e forze
spaziali, accumulo delle forze dai figli ai genitori, un prodotto scalare finale
per DOF. Il prototipo costruisce Jacobiani per corpo e proietta separatamente
gravità e bias su tutti i DOF. Nella catena sono 144 visite corpo–DOF, contro
12 proiezioni finali del C, oltre ai rispettivi passaggi per corpo.

Una RNE ricorsiva è applicabile anche ai corpi fissi e ai corpi con più giunti
presenti nel benchmark. Va però mantenuta l'interfaccia che espone separatamente
gravità e bias: si possono accumulare separatamente, oppure valutare una
decomposizione specificata. Non si può sostituire in silenzio due risultati
pubblici con la sola somma restituita dal C.

Sonno dei corpi e scorciatoie `dof_simplenum` non spiegano questi risultati:
il sonno è disabilitato e tutti i DOF delle fixture hanno `dof_simplenum = 0`.
Il C usa anche kernel SIMD e percorsi specializzati, ma questa analisi non
attribuisce loro una percentuale del vantaggio. Gli algoritmi e le strutture
descritte sono esprimibili in SPARK; non richiedono caratteristiche esclusive
del linguaggio C.

## Evidenza e sequenza di implementazione

[algorithm_audit.py](../tests/movement_performance/algorithm_audit.py) verifica
i conteggi sulla topologia reale e riproduce scalarmente il CRB del riferimento,
incluso l'ordine del prodotto a sei componenti. Nei tre modelli, tre stati
iniziali e 100 passi per stato: **900 matrici, 27.900 elementi confrontati,
errore massimo osservato zero**. Usa `cinert` e `cdof` prodotti dalla libreria C:
è una verifica della ricostruzione dell'assemblaggio, non del futuro porting
della cinematica né una prova formale. Non misura prestazioni Python.

La sequenza proposta è:

1. Chiudere gli invarianti per rendere utilizzabile il recupero sulle sette
   scansioni già [misurato separatamente](state-invariants-performance.md).
2. Provare e misurare il riuso di `Inertia_Times`, mantenendo il riferimento
   denso corrente come confronto; poi kernel spaziali e accumulo CRB.
3. Portare fattorizzazione e risoluzione del C con una politica numerica
   esplicita; trattare il costo dei controlli come un obiettivo separato.
4. Portare l'accumulo ricorsivo delle forze e ridurre la necessità di Jacobiani
   completi, preservando i risultati pubblici di gravità e bias.

Per ogni passo: prove funzionali sui sottoprogrammi minimi prima delle unità,
confronti numerici/errori di stato, poi benchmark dell'intero passo senza
strumentazione. Il CRB richiede un nuovo modello ghost dell'ordine di calcolo;
un'identità in aritmetica reale non dimostra uguaglianza delle somme arrotondate.
Nessuna delle ottimizzazioni elencate è stata attivata da questa analisi, e i
conteggi non stabiliscono ancora la parità con il C.

[Risultati e riproduzione](../tests/movement_performance/algorithm_evidence/README.md)
