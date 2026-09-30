# Adesione sui corpi e integrazione dell'attivazione

Implementazione isolata, basata sul commit `b6f47c9`, per conservare gli interventi
contemporanei della conversazione principale. Il codice principale non è stato
sovrascritto. Non sono stati creati commit o pubblicazioni.

- Trasmissione adesiva generica sui corpi: contatti attivi e nel gap, coni
  ellittici/piramidali, media dei Jacobiani e proiezione della forza.
- Attivazione `integrator`, `filter`, `filterexact`, limiti, `actearly`, reset,
  stato posseduto ed Euler nel simulatore smooth della copia isolata.
- Passo completo adesione + attivazione + contatto + Euler sul modello di
  slider/sfera/piano, con conservazione dello stato in caso di rifiuto.

La simulazione smooth generale resta senza contatti e rifiuta le trasmissioni
sui corpi. Il kernel generico riceve i Jacobiani dall'assemblatore; il collegamento
fisico completo qui verificato riguarda il modello scalare. Il parametro di
adesione delle geometrie e le dinamiche di muscoli/PID/DC motor hanno ambiti
separati.

| Verifica | Risultato |
|---|---|
| Regressione senza attivazione | 360 casi, 33.840 confronti, nessun errore |
| Attivazione, due politiche d'inerzia | 864 casi, 6.912 confronti; attivazione e derivata coincidenti nei campioni |
| Limiti e capacità dell'attivazione | 46 casi, fino a 1.024 stati |
| Passo adesione + attivazione | 366 casi, 4.026 confronti; errore massimo 1,43e-13 |
| Kernel adesivo | 194 casi; 192 modelli C e 2 casi analitici, errore osservato zero |
| Rifiuti atomici | 4 casi di attivazione e 4 del passo adesivo, stato conservato |
| Intera unità del passo adesivo | 69 obblighi chiusi, contratti funzionali inclusi |
| Kernel adesivo, sottoprogrammi | Selezione, riduzioni, normalizzazione, proiezione e lemmi chiusi singolarmente |
| `Compute_Activated` | 81 obblighi chiusi nella prova scoped |
| Funzioni di aggiornamento attivazione | 18 obblighi chiusi nelle prove scoped |
| Intera unità `MJ.Activation` | 24/25 obblighi chiusi; aperto il confine runtime di `Exp` |
| Intera unità del kernel adesivo | Tentativo completo fermato dal limite di 300 s; copertura globale ancora da confermare |
| Composizione generale Euler/actuation phase | Tentativi scoped fermati a 240 s; Gold globale ancora aperto |

Queste prove riguardano i contratti del modello floating point. Le prove dei
chiamanti e l'accuratezza rispetto alla matematica reale sono dichiarazioni
separate. I timeout restano lavoro di verifica da completare, senza classificare
le proprietà mancanti come eccezioni matematiche Silver.

Le misure con C nativo e SIMD normale sono nei risultati grezzi. Le catene da
24 DOF con un attuatore per giunto restano circa 24–28% più lente nella sessione
condivisa; le configurazioni con molti attuatori sono più rapide. Il confronto
scalare adesivo usa una pipeline specializzata, quindi non stabilisce la parità
prestazionale del simulatore generale.

## File e riproduzione

- `source/`: snapshot indipendente completo delle dipendenze Ada necessarie.
- `implementation.patch`: patch verificata sul commit iniziale; i file cambiati
  successivamente nella conversazione principale richiedono un'integrazione.
- `changed-files.json`, `base.json`, `patch-check.json`: provenienza e controllo
  della patch.
- `source/docs/adhesion-activation.md`: semantica, API, limiti e confini di prova.
- `evidence/`: input/output, prove strutturate, versioni, hash e tempi grezzi.

Dalla cartella `source`, nell'ambiente Linux/GNAT già usato dal progetto:

```sh
python3 experimental/actuation-integration/tests/build.py --out /var/tmp/adhesion-check
/var/tmp/sparkling-movement-env/bin/python experimental/actuation-integration/tests/compare.py \
  --binary /var/tmp/adhesion-check/validation/bin/adhesive_probe \
  --kernel /var/tmp/adhesion-check/validation/bin/adhesion_probe \
  --out /var/tmp/adhesion-numerics
python3 experimental/actuation-integration/tests/prove.py \
  --unit mj-adhesion --phase small --out /var/tmp/adhesion-proofs-small
python3 experimental/actuation-integration/tests/prove.py \
  --unit mj-adhesion --phase whole --out /var/tmp/adhesion-proofs-whole
```

Gli script salvano snapshot immutabili per le prove. Le prove complete con esito
positivo devono riportare tutte le entità, nessun obbligo aperto, nessuna
assunzione e nessuna analisi saltata. Una compilazione positiva non sostituisce
questa verifica. Il riferimento ufficiale verificato il 30 settembre 2026 è
[MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0).
