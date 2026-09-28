# Pubblicazione dei lavori del 27–28 settembre 2026

Questo checkpoint raccoglie il lavoro svolto nelle conversazioni parallele,
compresi sorgenti, contratti, prove, confronti con MuJoCo C 3.14.0 e misure.
La pubblicazione non equivale a un'integrazione automatica dei candidati:
le modifiche concorrenti agli stessi chiamanti restano disponibili per una
successiva integrazione verificata. Non si dichiara Gold dell'intero simulatore
né parità prestazionale su tutti i carichi.

## Codice presente nel percorso attivo

| Lavoro | Stato e riferimenti |
| --- | --- |
| Forze e coppie esterne sui corpi | [API, contratti e limiti](external-body-forces.md); [prove, test e misure](../tests/movement_performance/external_forces/README.md). Resta aperto il teorema funzionale dell'intera traversata. |
| Rimozione del controllo ridondante sulla gravità | [295 obblighi locali chiusi e misure](force-guard-elimination.md). Le altre scansioni non sono dichiarate tutte eliminate. |
| Conversione matrice → quaternione | [API Gold funzionale, prove e confronto C](../tests/matrix_to_quaternion/README.md): 972 controlli chiusi sulle unità quaternioni, pose e rotazioni, incluse le operazioni preesistenti; 6.207 matrici per ciascuno dei tre profili. La nuova conversione resta circa il 3–13% più lenta di C e non è ancora chiamata dalla dinamica smooth. |
| Reti elastiche di particelle | [API indipendente](../experimental/deformable/README.md), [760 obblighi di unità chiusi](../experimental/deformable/results/README.md). Non abilita automaticamente flex nel simulatore rigido. |
| Diagnostica dei costi residui | [Misure conservate](../tests/movement_performance/cost_attribution/current_scan_parity). |

## Candidati pubblicati separatamente

| Lavoro | Consegna | Limite principale |
| --- | --- | --- |
| Compensazione della gravità | [Sorgenti e prove](../experimental/gravity-compensation-candidate/README.md) | Composizione nei chiamanti e prestazioni su tutte le catene ancora aperte. |
| Dinamica di attivazione | [Integrator, filter e filterexact](../experimental/activation-candidate/README.md) | Modello di Exp, composizione e parità multi-DOF non completi. |
| Modelli fluidi box ed ellissoidale | [Implementazione e confronto C](../experimental/fluid-candidate/README.md) | Prova globale e accettazione prestazionale non complete. |
| Integrazione formale dei fluidi | [Lifecycle, cache e traversata](../experimental/fluid-candidate/integration-20260928/README.md) | Alcuni costruttori e chiamanti restano aperti. |
| Prove ellissoidali | [532 obblighi locali e 132.072 confronti numerici](../experimental/ellipsoid-proof-candidate/README.md) | Il chiamante completo Ellipsoid resta aperto, compresi i limiti delle radici quadrate. |
| Tendini fissi | [Sorgenti, patch e risultati](../experimental/fixed-tendon-candidate/README.md) | Tendini spaziali e trasmissioni non implementati; Gold globale e parità non completi. |
| Elasticità e smorzamento polinomiali | [Sorgenti, patch e risultati](../experimental/nonlinear-passive-candidate/README.md) | Due ambiti di prova e prestazioni delle catene restano aperti. |
| Cholesky denso | [Factor, Solve e Update](../experimental/cholesky/README.md), [prove e misure](../experimental/cholesky/verification.md) | Helper scalari chiusi; 8 obblighi del modello e 89 degli algoritmi ancora aperti. Non integrato nel solver della dinamica; parità non raggiunta. |
| LU densa e sparsa | [Sorgenti, patch e risultati](../experimental/lu-candidate/integration-20260928/README.md) | 144 controlli locali chiusi; prove globali dei solver e integrazione nella dinamica ancora aperte. |

Le frasi «non pubblicato», «nessun commit» o «repository non modificata» nei
rapporti originali descrivono il momento della rispettiva consegna. In questo
checkpoint tali consegne vengono pubblicate senza alterarne gli hash o estendere
le garanzie. I numeri di prove delle diverse righe non si sommano per stimare
una percentuale di correttezza globale: alcuni sorgenti e contratti si sovrappongono.
I manifest individuano gli snapshot ai quali si riferiscono i risultati.

## Contributore del port

Il contributore e maintainer del port è **[MABS3D](https://github.com/MABS3D)**.
Prima della pubblicazione l'API GitHub elencava già soltanto questo account e
tutti i commit del ramo preesistente `spark-port` usavano la sua identità.
Non è stata necessaria una riscrittura della cronologia. Le attribuzioni e la
licenza del riferimento upstream sono conservate come descritto in
[CONTRIBUTORS.md](../CONTRIBUTORS.md).

## Controllo prima del push

Lo snapshot del codice attivo è stato ricompilato con controlli abilitati e
confrontato nuovamente con C: **156 scenari e 43.236 confronti per modalità**,
Strict e Compatible, con forze esterne. Totale 86.472 confronti passati.
[Manifest e risultati](../tests/publication/2026-09-28/README.md). Questo controllo
non costituisce una nuova prova globale né una verifica della combinazione
dei candidati separati.

### Consegne matematiche aggiunte il 28 settembre

Il commit successivo aggiunge la conversione matrice → quaternione e conserva
separatamente i candidati Cholesky e LU, con i rispettivi test, benchmark e
obblighi aperti. Prima del push sono stati verificati i checksum e la
corrispondenza dei manifest con i sorgenti consegnati; l'archivio della
conversione conserva anche i rapporti completi delle prove e i campioni grezzi.
La verifica dei manifest non è una nuova esecuzione delle prove dei solver.

I due worktree di tendini fissi e forze passive non lineari sono stati confrontati
con gli snapshot già pubblicati: tutti i file modificati o aggiunti coincidono.
Non contengono ulteriori modifiche da integrare in questa pubblicazione.
