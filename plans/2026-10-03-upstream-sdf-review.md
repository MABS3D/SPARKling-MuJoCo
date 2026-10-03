# Valutazione indipendente PR upstream: capacità contatti mesh/SDF

Data: 2026-10-03. Agente: `review_upstream_sdf`. Richiesta: valutare se sia corretto proporre una PR sul riferimento C. **Nessuna issue, PR, commento o push pubblicati.** Il clone di riferimento del port non è stato modificato.

## Raccomandazione

**Sì: una piccola PR correttiva è tecnicamente giustificata.** Il caso è un bug del riferimento, riprodotto indipendentemente con un nuovo programma C e XML valido. La patch cambia quattro righe nel dimensionamento e aggiunge un test di regressione, senza cambiare la generazione dei contatti. CONTRIBUTING ammette contributi diretti per correzioni piccole e semplici; una issue preliminare non appare necessaria. Prima di pubblicare servono autorizzazione dell'utente e verifica del CLA; l'accettazione resta ai maintainer.

Patch completa: `experimental/sdf-step/evidence/20261003-upstream-review/candidate.patch`.
Solo fix: `fix-only.patch`. Bozza descrizione: `pr-draft.md` nella stessa directory.
Checkout isolato e build conservati in `/var/tmp/sparkling-upstream-sdf-review-20261003/`.

## Riferimenti controllati

- Ultima stabile verificata con GitHub API e pagina release: **3.14.0**, `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, pubblicata 2026-09-22.
- Main esatto esaminato e compilato: **`16dafd8f26835d72d44842b3a5d69c233048a8e7`**, versione interna 3.14.1 di sviluppo; non presentata come release stabile.
- `engine_collision_sdf.c` ha lo stesso blob Git in entrambi: `dc896364f6caca9f39d86e2c872500737f8d7416`.
- Ambiente: Ubuntu 24.04/WSL2, Linux x86_64, GCC 13.3.0, CMake Release, compilazione `--parallel 1`, guardia 3000 MB e timeout 600 s. Singola precisione con `-DmjUSESINGLE` per C e C++.
- Hash SHA-256 di librerie, eseguibili, configurazioni e sorgenti finali: `final-build-manifest.json`; ricevute prima/dopo float: `single-before-manifest.json` e `single-after-manifest.json`. Gli hash dei binari double prima della patch non furono catturati; quei risultati sono attribuiti al commit base e al test aggiunto, non al binario finale modificato.

## Root cause e input supportato

`mj_maxContact` restituisce `sdf_initpoints` per ogni coppia che contiene SDF. Il percorso mesh/SDF usa invece quel numero **per faccia**: attraversa le facce e accumula fino a `mjMAXCONPAIR = 50` candidati. Il numero totale può quindi superare `sdf_initpoints`.

La narrow phase riserva i buffer usando `pairMaxContact`, che chiama `mj_maxContact`. Il controllo in `collisionTask` confronta il numero restituito **dopo** che il collider ha scritto i contatti. Nel caso minimo si osservano due contatti e una capacità di uno, seguiti dal fatal error. Il superamento dello spazio riservato alla coppia è stabilito dal codice e dal numero prodotto; **non** è stata dimostrata una corruzione dell'heap o un impatto di sicurezza più ampio.

Il modello ha una mesh tetraedrica di quattro vertici non complanari contro un SDF cubico generato da mesh. Non usa Ada, plugin personalizzati, Python nella dinamica, file MJB alterati, forze o velocità iniziali. Basta `mj_loadXML`, `mj_makeData`, `mj_forward`. La documentazione ammette mesh definite dai vertici senza facce e la costruzione del convex hull; descrive `sdf_initpoints` come numero di punti iniziali, senza escludere 1. Compilatore XML e GUI ufficiale accettano quel valore. Non è emersa un'esclusione documentata per questo input.

## Fix e rischio di regressione

Nel solo ramo SDF, se l'altro geom è una mesh, restituire `mjMAXCONPAIR`. Per primitive/SDF e SDF/SDF il valore preesistente resta invariato. Entrambi gli ordini degli argomenti sono coperti. Il cap 50 è giustificato dal limite già applicato ai candidati in `processSdfCorners`; non occorre introdurre una nuova scansione o moltiplicare il numero delle facce.

Si dimensiona correttamente il buffer: nessun cambiamento a ottimizzazione, ordine, selezione o coordinate dei contatti. Tagliare i contatti a `sdf_initpoints` modificherebbe invece la risposta fisica esistente, e non è la proposta. Il costo di memoria per coppia mesh/SDF diventa 50 slot: può aumentare quando initpoints è piccolo e diminuire quando supera 50. Nessuna misura prestazionale è stata rivendicata.

## Risultati ripetibili

| Verifica su main | Prima | Dopo |
|---|---:|---:|
| Intero target `engine_collision_driver_test`, double | 13/14 | 14/14 |
| Intero target `engine_collision_driver_test`, float | 13/14 | 14/14 |
| Matrice indipendente double | 76/80 | 80/80 |
| Matrice indipendente float | 72/80 | 80/80 |
| Output contatti dei casi double già validi | — | 76/76 identici |
| Output contatti dei casi float già validi | — | 72/72 identici |

La matrice contiene mesh/SDF, SDF/SDF, sphere/SDF, box/SDF, capsule/SDF; due ordini dei geom; 1, 4, 40, 80 initpoints; senza pool e con due worker. Prima falliscono mesh/SDF a 1 in entrambe le precisioni e anche a 4 in float (cinque contatti contro quattro). Gli altri percorsi conservano sia capacità sia contatti.

Un'ulteriore scena con 33 coppie, filtri che escludono mesh/mesh e tre chunk narrow-phase verifica il percorso parallelo effettivo: dopo il fix produce 66 contatti a initpoints=1, sia double sia float, con e senza worker. A initpoints=4 produce 99 contatti double e 165 float. La stabile originale fallisce a 1; il main float originale fallisce a 1 e 4. Le differenze tra precisioni non sono state mascherate.

Il nuovo googletest usa il collider registrato in `mjCOLLISIONFUNC` con buffer da 50 elementi prima di chiamare `mj_forward`, così la regressione fallisce per l'asserzione `2 <= 1` senza provocare un overrun nel test. Verifica i due ordini di `mj_maxContact` e i valori 1/4/40/80. I confronti nuovi sono interi, per cui la calibrazione delle tolleranze floating-point `MJTOL_SCALE` non si applica.

Non è stata eseguita l'intera suite MuJoCo, né altri OS/architetture, né ASan. Queste verifiche restano per CI/upstream; i risultati sopra non vengono estesi ad altri target. GCC emette un warning LTO preesistente nella catena Abseil `StrCat` / `test/fixture.cc:GetTestDataFilePath`, presente prima e dopo; nessuna diagnostica nei quattro righi correttivi o nel nuovo test. `git diff --check` passa.

## Comandi prima/dopo

Nel checkout isolato, il test è stato aggiunto prima della correzione; build e run:

```sh
cmake -S /var/tmp/sparkling-upstream-sdf-review-20261003/source \
  -B /var/tmp/sparkling-upstream-sdf-review-20261003/double \
  -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release \
  -DMUJOCO_BUILD_EXAMPLES=OFF -DMUJOCO_BUILD_SIMULATE=OFF \
  -DMUJOCO_BUILD_TESTS=ON -DMUJOCO_TEST_PYTHON_UTIL=OFF
python3 /var/tmp/sparkling-upstream-sdf-review-20261003/guarded.py \
  --cap-mb 3000 --min-free-mb 3000 --timeout 600 -- \
  cmake --build /var/tmp/sparkling-upstream-sdf-review-20261003/double \
  --target engine_collision_driver_test --parallel 1
/var/tmp/sparkling-upstream-sdf-review-20261003/double/bin/engine_collision_driver_test --gtest_color=no
python3 /var/tmp/sparkling-upstream-sdf-review-20261003/run_matrix.py double matrix-double-before
```

Per la seconda configurazione sostituire `double` con `single` e aggiungere in configure `-DCMAKE_C_FLAGS=-DmjUSESINGLE -DCMAKE_CXX_FLAGS=-DmjUSESINGLE`. Prima exit 1 nel test di regressione; dopo applicazione di `fix-only.patch`, ripetere build/run e usare `matrix-double-after` o `matrix-single-after`. I log salvati preservano i risultati effettivi di ciascuna fase.

Per riprodurre da un checkout pulito al commit indicato, applicare inizialmente solo il test con `git apply --include='test/**' candidate.patch`; dopo la fase prima applicare solo il fix con `git apply --include='src/**' candidate.patch`. I comandi esatti delle esecuzioni della matrice sono salvati nei rispettivi `results.json`, e quelli delle prove native in `release-runs.json` e `multipair-runs.json`. Il checkout attualmente conservato include già la correzione.

## Ricerca duplicati e fonti primarie

Query GitHub API su issue/PR aperte e chiuse: SDF (51 risultati), `sdf_initpoints` (12), `mj_maxContact` (1), `pairMaxContact`, `collision function returned`, `MeshSDF` (zero). Non trovato un duplicato specifico; una ricerca non prova l'assenza assoluta. Ricevuta `upstream-search-summary.json`.

L'issue 1539 riguarda il visualizzatore SDF e la PR 3565 la validazione degli indici in MJB malformati: entrambe sono diverse dal caso XML valido senza visualizzazione. CONTRIBUTING richiede googletest, precisione singola/doppia, CLA e review; ammette la presentazione diretta delle correzioni piccole e semplici. Licenza sorgente Apache-2.0 e stile esistente preservati.

- [Release stabile 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0)
- [Driver al main esaminato](https://github.com/google-deepmind/mujoco/blob/16dafd8f26835d72d44842b3a5d69c233048a8e7/src/engine/engine_collision_driver.c#L68)
- [Algoritmo mesh/SDF](https://github.com/google-deepmind/mujoco/blob/16dafd8f26835d72d44842b3a5d69c233048a8e7/src/engine/engine_collision_sdf.c#L969)
- [Documentazione XML](https://mujoco.readthedocs.io/en/stable/XMLreference.html#option-sdf-initpoints)
- [CONTRIBUTING](https://github.com/google-deepmind/mujoco/blob/16dafd8f26835d72d44842b3a5d69c233048a8e7/CONTRIBUTING.md)
- [Issue 1539 distinta](https://github.com/google-deepmind/mujoco/issues/1539)
- [PR 3565 distinta](https://github.com/google-deepmind/mujoco/pull/3565)

Questa è una valutazione/test del riferimento C. Non chiude alcuna prova SPARK del port, né l'obiettivo globale di completezza e parità prestazionale.
