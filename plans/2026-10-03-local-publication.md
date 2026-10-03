# Pubblicazione di tutte le modifiche locali — 3 ottobre 2026

Fotografia successiva a `6bd2d161` sul branch `spark-port`. Include tutte le
modifiche locali ai sorgenti, test, contratti, documentazione ed evidenze:
solver sparso e riuso LDL, catene FLEX, caricamento e vincoli, matematica,
controller e attivazioni, stato/contatti shell, inversa, derivate, sleep e API.
Sono inclusi anche i candidati Full_Bias e signed-contact, con i rispettivi
obblighi e collegamenti ancora aperti. La PR upstream non viene pubblicata.

| Verifica fresca sul contenuto preparato per il commit | Risultato |
|---|---|
| Sintassi dei blob cambiati | 230 Python e 2073 JSON validi |
| Ricevute delle prove / composizione delle sorgenti | 15/15 e 2/2 |
| Identità fra sorgenti staged e manifest congelato | 317/317 |
| Build validation constrained, `gprbuild -j1` | PASS |
| Confronto C 3.14.0 con carichi esterni, 100 passi | 106/106 |
| Attivazioni e rifiuto atomico per capacità | 3/3 |
| Whitespace delle modifiche a sorgenti/documentazione | PASS |

La sintassi è stata verificata prima di aggiungere queste ricevute; il numero
indica i blob effettivamente controllati in quel run. Le prove ed i benchmark
archiviati mantengono il riferimento alle loro snapshot, non diventano prove
universali dell'intero commit. Whole loader FLEX, composizione della dinamica,
integrazione shell e parità prestazionale restano aperti. Gli avvisi ed i
fallimenti diagnostici originali sono conservati. Nessuna nuova assunzione,
soppressione o soglia numerica è introdotta dalla pubblicazione.

Ricevute: `experimental/constrained-step/evidence/publication-local-20261003/`.
