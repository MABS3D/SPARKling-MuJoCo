# Pubblicazione del 29 settembre 2026

Questo checkpoint raccoglie le modifiche successive al commit pubblicato
`672b75e0`: un'ottimizzazione del kernel dei quaternioni e un candidato autonomo
per il contatto senza attrito. Il riferimento delle due consegne è MuJoCo
3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

## Conversione matrice → quaternione

Le divisioni indipendenti e i quadrati della norma sono ora raggruppati in
istruzioni SIMD, conservando il modello floating-point, l'ordine delle somme,
le soglie, il controllo numerico e l'API pubblica. Nessuna approssimazione del
reciproco, riassociazione o contrazione FMA è stata introdotta.

- Quaternioni, pose e rotazioni: **990 controlli chiusi, zero aperti** sulle
  unità complete, incluse le operazioni preesistenti. Il contratto Gold
  funzionale della conversione resta invariato, sotto i contratti runtime.
- **6.207 matrici e 24.828 confronti scalari per profilo**, più le regressioni
  di quaternioni e pose, passano in development, validation e release.
- Nei dieci pattern e nelle due sessioni bilanciate, il tempo mediano è
  **5,6–10,8% inferiore a C** e **10,8–18,5% inferiore alla precedente Ada**.
  Sono intervalli fra risultati individuali, non una media di carichi diversi.

La misura riguarda il throughput del kernel sul processore documentato. La
dinamica smooth non chiama questa API: non è un'accelerazione dell'intero motore.
I risultati del 28 settembre, che mostravano un rallentamento, restano conservati
come evidenza storica.

[Sorgenti, prove, confronti e campioni delle misure](../tests/matrix_to_quaternion/optimization_20260929/README.md).

## Candidato di contatto senza attrito

Il nuovo modulo realizza rilevamento, costruzione del vincolo, forza normale,
accelerazione e passo Euler per **una sfera su un solo slider verticale sopra
un piano orizzontale fisso**. Include la regolarizzazione del contatto morbido
di MuJoCo e la conservazione completa dello stato in caso di rifiuto numerico.

- **404 controlli chiusi, zero aperti e zero avvisi**: 298 delle nuove unità e
  106 della libreria di collisione riutilizzata e riverificata.
- **751 casi e 9.012 confronti scalari per profilo** passano in development,
  validation e release; due ulteriori casi per profilo verificano il rifiuto
  atomico. Il confronto con C usa tolleranze esplicite.
- I benchmark confrontano questo caso scalare specializzato con il motore C
  generale. Non dimostrano parità o superiorità per contatti arbitrari.

Il candidato resta in `experimental/frictionless-contact-candidate`, separato
da `MJ.Data`. Non abilita contatti nel simulatore principale. Contatti multipli
accoppiati, attrito tangenziale, limiti articolari, vincoli di uguaglianza e
solver iterativi generali restano fuori da questa consegna.

[API e limiti](../experimental/frictionless-contact-candidate/README.md),
[proprietà funzionali](../experimental/frictionless-contact-candidate/verification.md).

## Controllo della pubblicazione

Il confronto è effettuato dopo l'aggiornamento dei riferimenti da GitHub.
Checksum, manifest dei sorgenti e inventari interni degli archivi sono verificati
contro i file consegnati. I risultati sopra provengono dalle esecuzioni archiviate
sugli stessi sorgenti; la verifica dei manifest non è una nuova esecuzione delle
prove o dei benchmark.

I worktree di tendini fissi e forze passive non lineari coincidono ancora con
gli snapshot già pubblicati. Il precedente
[checkpoint del 27–28 settembre](publication-2026-09-28.md) conserva gli altri
lavori e i rispettivi obblighi aperti. Nessuna di queste pubblicazioni costituisce
una dimostrazione Gold dell'intero simulatore.
