# Checkpoint di pubblicazione — 3 ottobre 2026

Fotografia del lavoro recuperato e aggiornato dopo `2b601cc2`, pubblicata su
`spark-port` nella repo MABS3D/SPARKling-MuJoCo. Include solver Newton sparso,
uguaglianze joint/tendon, collisioni e flex, adesione/attuazione, mocap,
sensori, ray casting, API, integratori, inversa e candidati per le derivate,
oltre ai test, ai contratti e alle evidenze. Le prove aperte rimangono aperte.
Il dossier per la correzione C upstream è incluso; nessuna PR upstream è pubblicata.

La fotografia usa un indice Git separato e un export immutabile. La build e i
test sotto si riferiscono esattamente ai sorgenti congelati; le modifiche della
chat principale successive alla fotografia restano locali.

| Verifica fresca prima della pubblicazione | Risultato |
|---|---|
| Build validation del motore constrained | PASS |
| Contatti rigidi, 100 passi con carichi esterni | 106/106 |
| Vincoli ellittici, 30 passi | 254/254 |
| Uguaglianze scalari già coperte, 100 passi | 468/468 campioni confrontabili |
| Nuove configurazioni scalari miste | 36 configurazioni interrotte con Numeric_Limit |
| Attivazione, durata dei dati e atomicità | 46/46 |
| Sintassi Python / JSON / integrità ZIP | 120 / 407 / 1, tutti validi |

Il corpus scalare esteso **non passa integralmente**: le 36 configurazioni
interrotte non sono incluse nei 468 campioni confrontabili. I relativi nomi,
output, hash e comandi sono conservati nelle ricevute. Non sono state cambiate
le soglie né le sorgenti per nascondere il limite.

I controlli di whitespace dei sorgenti e della documentazione passano; patch
e log grezzi sono conservati nella loro forma originale. I risultati storici
di prova e benchmark valgono per le rispettive snapshot, non automaticamente
per tutto questo commit. Questa pubblicazione non dichiara Gold globale o
parità prestazionale con C.

Ricevute: `experimental/constrained-step/evidence/publication-20261003/`.
