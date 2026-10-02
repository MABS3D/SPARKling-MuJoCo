# Evidenze del primo passo con vincoli — 2 ottobre 2026

**Esito:** integrazione numericamente verificata nel dominio dichiarato; Gold globale e parità prestazionale aperti.

La chiusura di sorgenti congelata comprende 232 file. Gli hash sono in `sources.json` e il contenuto esatto in `source-snapshot.zip`. Le sorgenti di questa integrazione coincidono con quelle verificate.

| Verifica | Risultato |
|---|---|
| Confronto C, build validation | 280/280 casi; 100 passi per caso |
| Confronto C, build release | 280/280 casi; 100 passi per caso |
| Configurazioni non supportate | 10/10 rifiuti per profilo |
| Capacità esaurita | 272 righe richieste, rifiuto a 256; stato invariato in entrambi i profili |
| Kernel nuovi, unità completa | 39 verifiche chiuse; 0 aperte, 0 avvisi |
| Flow del collegamento | 10 diagnostiche di inizializzazione aperte; 41 avvisi nel rapporto |

I 280 casi sono 35 modelli/configurazioni con 8 stati ciascuno; i due profili usano gli stessi casi. Il probe verifica anche dimensioni/indici/carichi errati, doppia creazione, proprietà del modello dopo la sua liberazione e ripristino dei flag. Non sommare i controlli dei sottoprogrammi a quelli della stessa unità completa.

## Errori assoluti massimi osservati

| Campo | Massimo |
|---|---:|
| free | 2.13163e-14 |
| jac | 8.74301e-16 |
| aref | 3.89822e-12 |
| reg | 5.41234e-16 |
| force | 2.28578e-12 |
| qfrc | 5.32197e-12 |
| acc | 4.25402e-11 |
| state | 5.52222e-11 |

Le tolleranze del test sono esplicite in `compare.py`. L’accordo riguarda il corpus e non costituisce una dimostrazione universale; non sono state introdotte eccezioni a posteriori per accettare singoli casi.

## Passo completo: Ada rispetto a C

Microsecondi per passo: mediana di 15 serie alternate, dopo due serie di riscaldamento; ogni serie comprende 100 passi. Preparazione e I/O esclusi. Le traiettorie vengono confrontate a ogni serie. Warmstart/isole disabilitati in entrambi; C ufficiale con SIMD normale. Le build Ada mantengono i controlli runtime. I dati grezzi e P95 sono in `performance.json`.

| Modello | DOF | Ada µs, mediana [P10–P90] | C µs, mediana [P10–P90] | Ada/C |
|---|---:|---:|---:|---:|
| sphere_Newton_3_0.2 | 6 | 5.339 [4.973–6.613] | 2.794 [2.536–3.616] | 1.91× |
| coupled_limits_friction | 3 | 3.139 [2.861–3.480] | 2.294 [2.114–2.667] | 1.37× |
| box_multiple | 6 | 9.235 [8.962–10.114] | 3.554 [3.377–4.516] | 2.60× |
| shared_ancestors | 8 | 5.474 [5.276–6.779] | 2.681 [2.505–2.775] | 2.04× |
| 4_free_bodies | 24 | 58.769 [57.353–80.848] | 5.747 [5.269–6.865] | 10.23× |
| 8_free_bodies | 48 | 407.585 [387.874–448.102] | 9.490 [9.237–11.706] | 42.95× |
| 16_free_bodies | 96 | 2960.783 [2885.736–3075.046] | 16.345 [15.569–17.071] | 181.14× |

Il divario sui molti DOF è netto anche rispetto alla dispersione. Il percorso combina ancora Jacobiani corporei densi, conversione CSR→denso, matrici/fattorizzazioni dense del solver e workspace generali; manca una misura separata del costo delle singole fasi, quindi questi dati non ne attribuiscono quantitativamente la responsabilità.

## Obblighi rimasti

Le dieci diagnostiche flow riguardano i prefissi inizializzati delle catene degli antenati, le matrici di Jacobiani locali/compatte, la matrice di massa e il vettore delle accelerazioni libere. I cicli richiedono invarianti/modularizzazione per rendere visibile al prover la porzione valida senza aggiungere azzeramenti completi a ogni passo. Restano inoltre i contratti globali di composizione, atomicità e dominio, e le prove aperte dei componenti chiamati. Questo rapporto non certifica assenza di errori runtime dell’intero percorso e non assegna Silver come eccezione.

Il wrapper conserva eccezioni controllate sul dominio numerico e runtime checks. Nessuna assunzione, soppressione o nuova implementazione trusted è usata per dichiarare Gold. Il flusso ordinario smooth resta distinto dall’ingresso `MJ.Data.Constrained`.

## Lavoro concorrente

Durante la verifica altri moduli sono stati modificati nella conversazione principale. Il confronto finale degli hash rileva queste differenze rispetto allo snapshot:

- `src/mj-models-validity.ads`
- `experimental/smooth/src/mj-data-inertia_phase.adb`
- `experimental/smooth/src/mj-data-spatial_tendon_phase.adb`
- `experimental/smooth/src/mj-data.ads`
- `experimental/spatial-tendon-candidate/src/mj-spatial_tendon_models.adb`
- `experimental/spatial-tendon-candidate/src/mj-spatial_tendon_models.ads`
- `experimental/constraint-solvers-candidate/src/mj-constraint_solvers-cholesky.adb`
- `experimental/constraint-solvers-candidate/src/mj-constraint_solvers-cholesky.ads`
- `experimental/constraint-solvers-candidate/src/mj-constraint_solvers.adb`

Le ricevute descrivono esattamente lo snapshot allegato; non estendono le prove o le misure a revisioni successive dei chiamati. Nessun file condiviso è stato modificato da questa integrazione.
