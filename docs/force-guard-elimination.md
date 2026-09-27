# Rimozione provata del controllo sulla gravità

Aggiornamento del 27 settembre 2026, dopo il commit `677e7547`. È adottata la rimozione del controllo `SK.Bounded (Sum, 1.0e54)` dopo ogni accumulo della gravità dal figlio al genitore. L’ordine delle somme floating point, il percorso di fallback e i contratti pubblici restano invariati.

## Limite dimostrato

La gravità del singolo corpo è già limitata a `1.0e48` dal contratto di `Gravity_Force`. Tale garanzia è ora propagata da `Body_Wrenches` a `Forward_One_Body` e `Forward_Bodies`. Nel ciclo inverso, pesi Ghost contano i contributi ancora attivi. Il budget `(3*N-1) * 2**159` contiene le somme arrotondate di N contributi e rimane entro `1.0e54` per tutti i 4.096 corpi supportati. I lemmi verificano anche il margine di arrotondamento; non si assume l’associatività dei floating point.

I pesi e le prove di conservazione sono Ghost Static: non introducono scansioni, array di lavoro o operazioni nel percorso release. La precondizione privata di `Backward_Bodies` richiede ora genitori precedenti ai figli e il limite iniziale più stretto della gravità: entrambe le proprietà sono dimostrate nel chiamante. Nessuna restrizione aggiunta alle API pubbliche, nessun Assume o soppressione.

Il confronto strutturale resta quello con `mj_rne` in `src/engine/engine_core_smooth.c`, MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`: passaggio inverso sui corpi e accumulo solo se il genitore non è il mondo. C combina gravità e bias; il port mantiene ancora i due risultati separati. Questa modifica non implementa quella fusione.

## Prove accettate

| Ambito | Obblighi proof | Aperti |
|---|---:|---:|
| Budget | 2 | 0 |
| Budget_Bounds | 1 | 0 |
| Bound_Wrench_Sum | 14 | 0 |
| Bound_Sum | 14 | 0 |
| Body_Wrenches | 16 | 0 |
| Forward_Bodies | 76 | 0 |
| Recursive_Forces_Buffers | 30 | 0 |
| Transfer_Motion_Bound | 3 | 0 |
| Preserve_Gravity_Prefix | 32 | 0 |
| Forward_One_Body | 47 | 0 |
| Backward_Bodies | 60 | 0 |
| **Totale adottato** | **295** | **0** |

Sono 11 ambiti locali. I corpi accettati corrispondono esattamente ai rispettivi snapshot, anche quando l’aggiunta dei lemmi ne ha spostato le righe. Le dipendenze preesistenti e non modificate conservano le prove del checkpoint precedente; il manifest distingue questo riuso dalle nuove prove. I timeout e i tentativi intermedi sono archiviati ma esclusi dal totale. Non si rivendica una nuova dimostrazione dell’intera dinamica fisica.

## Validazione e prestazioni

La versione finale checked passa Strict e Compatible: 624 scenari e 168.192 confronti per modalità, tolleranze assoluta e relativa `2e-10`. I controlli della frontiera pubblica Forces in release passano entrambe le modalità: 26 scenari e 7.008 confronti ciascuna.

Due sessioni senza compilazioni/prover concorrenti, CPU 12, 11 modelli × 3 stati, 24 blocchi con ordine bilanciato. Ogni processo esegue 2 riscaldamenti e 4 traiettorie misurate da 100 passi. Preparazione e I/O sono esclusi. Sono confrontati la baseline pubblicata, le due rimozioni insieme, la sola gravità e C con SIMD normale. Le percentuali seguenti riguardano **solo la gravità**, adottata; gli intervalli riportano gli estremi tra stati e sessioni, non intervalli di confidenza. Gli IC95 sono bootstrap sui rapporti per blocco, 10.000 ricampionamenti.

| Modello | Riduzione tempo/passo (%) | Rapporto nuovo/C | IC95 interamente migliore / peggiore |
|---|---:|---:|---:|
| hinge_motor | -2.21–-0.29 | 0.757–0.775 | 0/6 ; 4/6 |
| branched_multijoint | 1.07–1.47 | 1.026–1.035 | 5/6 ; 0/6 |
| chain_12 | 3.04–3.77 | 1.347–1.387 | 6/6 ; 0/6 |
| crb_no_damping | 1.73–2.52 | 1.269–1.287 | 6/6 ; 0/6 |
| crb_chain_24 | 3.14–4.07 | 1.446–1.469 | 6/6 ; 0/6 |
| ancestor_star_24 | 6.54–7.42 | 1.562–1.585 | 6/6 ; 0/6 |
| ancestor_forest_24 | 3.29–5.16 | 1.500–1.529 | 6/6 ; 0/6 |
| ancestor_branches_24 | 3.96–5.37 | 1.494–1.522 | 6/6 ; 0/6 |
| simple_hinges_6 | -1.58–-0.32 | 1.527–1.548 | 0/6 ; 6/6 |
| simple_sliders_6 | -0.34–1.49 | 0.877–0.890 | 2/6 ; 0/6 |
| simple_mixed_8 | 0.66–1.98 | 0.989–1.002 | 6/6 ; 0/6 |

Una riduzione negativa è un rallentamento. Restano regressioni piccole ma misurabili sulla cerniera singola e sulle sei cerniere; non vengono classificate automaticamente come rumore. Il guadagno sui modelli grandi è confermato in tutti e sei i confronti per modello. Non si sommano né si mediano percentuali tra carichi diversi. I dati grezzi contengono MAD, p95 e IC95: il p95 è del costo medio per passo di una traiettoria, non della latenza del singolo passo.

Gli output Ada serializzati (qpos, qvel e tempo) coincidono numericamente con la baseline in tutti i processi misurati; differenza massima 0. Scarto massimo dalla reference C: `3.8913317013111737e-14`. Questi test non costituiscono una prova universale di equivalenza con C.

## Variante non adottata e lavoro restante

È stata dimostrata anche la ridondanza del controllo `Within_Work` nelle forze passive (32 ulteriori obblighi chiusi). La rimozione combinata rallentava i sei cursori di circa 1,4–3,0% nelle prime due sessioni, mentre la sola gravità elimina una regressione sistematica su quel modello nei confronti finali. Il codice delle forze passive è quindi ripristinato esattamente alla baseline: la relativa prova è conservata come esperimento, esclusa dai 295 obblighi della modifica adottata.

Restano i controlli sulle velocità/accelerazioni propagate, sulle forze giroscopiche e di bias e sulle proiezioni. Ai contratti locali attuali non sono tutti ridondanti: ad esempio `Advance_Joint` ammette una componente iniziale `1e12`, un asse unitario e una velocità `1e10`, la cui somma supera il limite `1e12` del percorso rapido. Rimuovere questi controlli richiede limiti più precisi dimostrati a monte oppure un cambiamento esplicito del percorso numerico e del suo fallback. La parità con C non è ancora raggiunta nei modelli multi-DOF.

## Evidenze

[Archivio riproducibile](../tests/movement_performance/force_guard_elimination/evidence.zip), [manifest delle prove](../tests/movement_performance/force_guard_elimination/proof-closure.json), [risultati delle prestazioni](../tests/movement_performance/force_guard_elimination/performance.json). L’archivio contiene baseline/finale, script, comandi di prova, snapshot, tentativi intermedi, binari, input, risultati e checksum. Il binario release adottato è esattamente quello misurato come `gravity_only`; hash e sorgenti sono verificati nel manifest.
