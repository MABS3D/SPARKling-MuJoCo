# Prove del candidato

Sorgenti verificati il 2026-09-30; riferimento C MuJoCo 3.14.0. I conteggi sono diagnostici per singola esecuzione, non percentuali di copertura di MuJoCo.

## Sottoprogrammi minimi

| Sottoprogramma | Obblighi chiusi | Aperti | Esito |
|---|---:|---:|---|
| [Sparse_Product](proofs/final-small-sparse_product/result.json) | 7 | 0 | chiuso |
| [Lane_Add](proofs/final-small-lane_add/result.json) | 9 | 0 | chiuso |
| [Combine](proofs/final-small-combine/result.json) | 25 | 0 | chiuso |
| [Unfold_Lanes](proofs/final-small-unfold_lanes/result.json) | 12 | 0 | chiuso |
| [Unfold_Tail](proofs/final-small-unfold_tail/result.json) | 14 | 0 | chiuso |
| [Velocity](proofs/final-small-velocity/result.json) | 79 | 2 | pendente |
| [Rank_Bounds](proofs/final-small-rank_bounds/result.json) | 9 | 0 | chiuso |
| [Compress](proofs/final-small-compress/result.json) | 51 | 0 | chiuso |
| [Project](proofs/final-small-project/result.json) | 42 | 0 | chiuso |
| [Slots](proofs/final-small-slots/result.json) | 13 | 0 | chiuso |
| [Length_Curve](proofs/final-small-length_curve/result.json) | 39 | 0 | chiuso |
| [Geometry.Product](proofs/final-small-geometry-product-v2/result.json) | 5 | 0 | chiuso |

Le prove locali sono modulari: dimostrano i contratti del sottoprogramma sotto le precondizioni e i contratti dei chiamati. Le curve dimostrano le branche del modello floating point; compressione e proiezione dimostrano schema, valori e conservazione delle componenti non interessate. Rank_Bounds e Unfold sono lemmi ghost.

## Unità complete

| Unità | Obblighi chiusi | Aperti | Esito |
|---|---:|---:|---|
| [fresh-whole-mj-transmissions](proofs/fresh-whole-mj-transmissions/result.json) | 448 | 12 | pendente |
| [fresh-whole-mj-actuator_curves](proofs/fresh-whole-mj-actuator_curves/result.json) | 494 | 33 | pendente |
| [fresh-whole-mj-actuator_geometry](proofs/fresh-whole-mj-actuator_geometry/result.json) | 240 | 54 | pendente |
| [fresh-whole-mj-advanced_actuators](proofs/fresh-whole-mj-advanced_actuators/result.json) | 201 | 127 | pendente |
| [fresh-whole-mj-actuator_transmissions](proofs/fresh-whole-mj-actuator_transmissions/result.json) | 152 | 14 | pendente |

Tutte le esecuzioni complete coprono le dichiarazioni dell’unità; le evidenze sono fresche, senza Skip_Proof, Skip_Flow o Assume. Rimangono obblighi di runtime safety e di correttezza funzionale: nessuna delle cinque unità viene dichiarata interamente Gold/Silver.

Le funzioni elementari standard producono avvisi imprecise-call, conservati negli esiti. Le prove complete con questi avvisi non sono accettate come chiuse. Nelle sole prove di Product/Slots, i cui corpi e chiamati sono stati esaminati e non usano funzioni elementari, gli avvisi esterni al sottoprogramma selezionato sono annotati come estranei alla prova locale. Non sono soppressi né dichiarati risolti per l’unità.

La riduzione Velocity ha il modello delle quattro corsie e della coda; resta aperta la conservazione dell’invariante funzionale e l’uguaglianza finale al modello. Nelle altre unità sono pendenti limiti intermedi floating point, precondizioni/index, composizione geometrica e uguaglianza alle leggi PID/DC. I log riportano posizione e diagnostica di ogni obbligo. La sicurezza universale non è deducibile dai soli test.

Timeout e modelli mancanti sono lavoro di dimostrazione da completare; non eccezioni matematiche documentate per fermarsi a Silver. Prestazioni e integrazione nel motore restano separate da questi risultati.
