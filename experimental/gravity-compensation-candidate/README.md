# Compensazione della gravità — candidato isolato

Implementazione della compensazione **passiva per corpo**, basata su MuJoCo C 3.14.0.
**L'obiettivo completo non è raggiunto:** parità prestazionale non ottenuta in tutti i modelli e prove dell'integrazione ancora aperte. La repository principale non è stata modificata da questa conversazione.

## Modifica

- Importa e conserva `body_gravcomp` nel modello immutabile del simulatore.
- Calcola `gravity[k] * (-(mass * coefficient))` e proietta la forza al centro di massa sui soli giunti antenati. Nessun Jacobiano denso aggiuntivo.
- Somma prima i contributi di compensazione, poi aggiunge il vettore alle forze passive, come C.
- Rispetta il flag compilato `flg_gravcomp`, la disabilitazione della gravità, la gravità nulla (compreso l'underflow della norma) e il ritorno anticipato di C quando spring e damper sono entrambi disabilitati.
- Mantiene il controllo del risultato accumulato; elimina quello non necessario sul Jacobiano temporaneo, dimostrandone il limite `1e62`.
- Usa memoria temporanea sullo stack, senza nuove allocazioni dinamiche per passo. Non aggiunge una scansione delle compensazioni quando il flag globale è disattivato.
- Il percorso sperimentale resta quello dei giunti scalari hinge/slide. `actuatorgravcomp` e i limiti di forza a livello di giunto restano rifiutati con `Unsupported_Feature`.

Il riferimento è [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0), commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`: `engine_passive.c`, `mj_gravcomp` e aggiunta a `qfrc_passive`; `engine_support.c`, `mj_applyFT`. Le formule del Jacobiano diretto possono avere arrotondamenti diversi da quelle interne C: i confronti numerici non sono una prova di equivalenza universale né di identità bit per bit con C.

## Verifica della versione finale

| Ambito | Risultato |
|---|---|
| `MJ.Gravcomp_Kernels`, unità completa | **43/43** obblighi verificati; formule funzionali e limiti |
| `MJ.Data.Gravity_Compensation`, unità completa | **65/65** obblighi verificati; sicurezza, contributo singolo, somma finale; un avviso di assegnazione iniziale inutilizzata |
| Esposizione delle precondizioni della compensazione | **7/7** |
| Validazione coefficienti / opzioni | **13/13** e **16/16** |
| Copia corpi / uguaglianza configurazioni, selezioni locali | **26/26** e **28/28**, sotto i contratti dei chiamati |
| `Read_Body_Config` | **41/42**: postcondizione ancora aperta |
| `Complete_Passive` | Budget di prova esaurito a 400 s; nessuna chiusura dichiarata |
| `Compute_Ready` e composizione globale | Rivalidazione e dimostrazione funzionale globale ancora da completare |
| Confronto C, Compatible | **456 scenari / 98.460 confronti**, superati |
| Confronto C, Strict | **456 scenari / 98.460 confronti**, superati |

Le due modalità usano lo stesso eseguibile checked, associato agli hash finali dei sorgenti. Tolleranze assoluta e relativa: `2e-10`. Inclusi carichi esterni contemporanei, alberi fino a 24 DOF, più giunti per corpo, corpi fissi, compensazione sparsa/totale/mista, coefficienti negativi misti e superiori a uno, coefficienti grandi, gravità vettoriale e quasi nulla, disabilitazioni e traiettorie Euler. Verificati anche il rifiuto di `actuatorgravcomp` e di coefficienti oltre il dominio numerico del loader.

La relazione funzionale dell'intera visita topologica con il vettore finale resta da formalizzare: i 65 obblighi del secondo modulo non chiudono quella relazione. I timeout non sono classificati come limiti matematici né come eccezioni Silver approvate. Nessuna nuova assunzione o soppressione è stata usata.

## Prestazioni del passo Euler completo

Due sessioni, sette modelli, tre stati iniziali, 24 blocchi bilanciati per caso, quattro traiettorie di 100 passi per campione, due warmup, CPU 12. Preparazione e I/O fuori dal tratto cronometrato. Build release native `-O3 -march=native -flto`, contrazione floating point disabilitata, libreria C nativa con i normali percorsi SIMD.

**Misure diagnostiche:** altri processi di prova e compilazione erano attivi. Una sessione a macchina libera è ancora necessaria per l'accettazione prestazionale. La tabella riporta il minimo e massimo delle mediane dei sei casi (tre stati × due sessioni), non un intervallo di confidenza aggregato. Segno positivo = più tempo di C. Gli intervalli bootstrap al 95%, MAD e p95 dei singoli casi sono in `performance-summary.json`.

| Modello | Compensazione assente | Un corpo compensato | Tutti i corpi compensati |
|---|---:|---:|---:|
| `ancestor_forest_24` | +34.8% … +43.2% | +31.5% … +43.4% | +2.0% … +6.6% |
| `ancestor_star_24` | +37.6% … +40.9% | +33.5% … +50.0% | -3.0% … +1.5% |
| `branched_multijoint` | -8.0% … -3.4% | -9.5% … -6.8% | -17.7% … -14.2% |
| `chain_12` | +25.3% … +32.9% | +20.4% … +25.7% | +3.8% … +8.2% |
| `crb_chain_24` | +28.2% … +41.5% | +32.3% … +40.4% | +14.9% … +26.8% |
| `hinge_motor` | -28.2% … -23.0% | -32.4% … -28.6% | -32.4% … -29.2% |
| `simple_mixed_8` | -14.6% … -10.6% | -17.3% … -13.6% | -22.2% … -17.9% |

Con compensazione disattivata, i risultati finali serializzati di posizione, velocità e tempo sono identici alla baseline Ada congelata (116,928 valori confrontati bit per bit). Questo controllo riguarda la numerica; eventuali variazioni del tempo con compensazione assente restano nei dati grezzi e negli intervalli per caso. Non si deduce il costo isolato della compensazione sottraendo tempi di traiettorie fisicamente diverse.

## Consegna e riproduzione

- `candidate/`: copia dei sorgenti e degli strumenti con la modifica.
- `gravity-compensation.patch`: sette file modificati/aggiunti; verificata con `git apply --check` sulla baseline congelata.
- `candidate-hashes.json`, `baseline-hashes.json`: identità dei sorgenti.
- `proof-summary.json`, `performance-summary.json`: risultati strutturati, inclusi gli obblighi aperti.
- `evidence.zip`: baseline, candidate, fixture, script di build/misura, manifest, log delle prove, eseguibili finali e output grezzi delle due sessioni finali.

La patch è relativa alla copia di lavoro con le modifiche precedenti non ancora committate, non direttamente al solo HEAD pubblicato. Verificare gli hash e risolvere eventuali modifiche sopraggiunte prima dell'integrazione; nessun merge, commit o push è stato eseguito qui.

Per riprodurre, estrarre `evidence.zip` e usare l'ambiente Python con `mujoco==3.14.0` e NumPy. `build.py` usa i percorsi locali della toolchain e della libreria C registrati nei manifest; aggiornarli se l'ambiente cambia. `measure.py 7 24` avvia una nuova sessione con 24 blocchi. I comandi GNATprove esatti, i limiti e le strategie sono nei manifest di ciascuna prova. Le prove filtrate per singola linea presenti negli esperimenti intermedi **non** sono contate come prove di sottoprogrammi completi.

Per completare: chiudere le prove del chiamante e dell'importazione, formalizzare la visita globale, integrare con la pipeline corrente, aggiungere il percorso attuatori se richiesto, e ottenere la parità sui modelli ancora più lenti con misure prive di interferenze.
