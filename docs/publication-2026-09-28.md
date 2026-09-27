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
