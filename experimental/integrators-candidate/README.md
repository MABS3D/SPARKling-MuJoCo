# Integratori nativi oltre Euler

`MJ.Data.Integrators` esegue RK4, implicit, implicitfast e discrete sopra lo stato owned di smooth. Pose, forze, Jacobiani e derivate sono prodotti da Ada; il test libera il modello sorgente prima della prima iterazione. Il riferimento è MuJoCo 3.14.0, commit 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd.

Ripresa del 3 ottobre: build con controlli runtime e **512/512 traiettorie C** passate, 32 configurazioni × 4 integratori × 4 campioni, 100 passi. Sono inclusi joint scalari/ball/free, muscolo e filtro esatto, flag, tendini fissi/spaziali, PGS, fluido box/ellissoidale e discendenti fissi. Ogni caso verifica anche rifiuto atomico di operatori con dimensione errata, modello sorgente liberato e doppia liberazione.

Correzioni rispetto al salvataggio pre-crash:

- Derivata del drag simmetrizzata nello spazio locale prima della proiezione; implicitfast conserva l’asimmetria sui sottoalberi rigidi liberi.
- Correzione giroscopica discrete applicata dopo il solve simmetrico alle sole righe libere non accoppiate dalla metrica di attuatori o tendini.
- PCG della metrica con backbone, tolleranza relativa e limite iterazioni del modello. Il risultato parziale al limite viene conservato, come C; la pubblicazione del warning C nell’API resta da collegare.

I sette minimi e l’unità completa `MJ.Integration_Kernels` chiudono **42 obblighi di prova**, con relazioni floating-point esatte. Il nuovo kernel Symmetric_Entry dimostra la media ordinata impiegata nella derivata fluida. Prove del PCG, delle derivate automatiche, del solve locale e della composizione integratore restano aperte: il confronto numerico non le sostituisce. Ricevute e hash in [evidence](evidence/recovery-20261003).

Il modulo supporta il dominio del costruttore smooth: vincoli/contatti, flex, PID/DC/SO3, plugin e sonno devono ancora essere composti con questi integratori. Gli operatori opzionali forniti dal chiamante non attestano un produttore nativo mancante. Pivot piccoli del solve denso sono rifiutati secondo la politica esplicita del candidato; la riparazione/clamping completa di C resta da integrare. Nessun risultato di parità prestazionale dell’intera simulazione viene dedotto dai test.

```sh
python3 experimental/integrators-candidate/tests/build.py --out /var/tmp/integrators-new
/var/tmp/sparkling-movement-env/bin/python experimental/integrators-candidate/tests/compare.py --binary /var/tmp/integrators-new/build/validation/bin/integrators_probe --out /var/tmp/integrators-new/compare --samples 4 --steps 100
python3 experimental/integrators-candidate/tests/prove.py --out /var/tmp/integrators-kernels-small
python3 experimental/integrators-candidate/tests/prove.py --out /var/tmp/integrators-kernels-whole --whole
```

The dense PCG dot tail was subsequently corrected to group its final two/three products before adding the lane sum, as C3.14.0 specifies. The probe now checks exact cancellation fixtures, independently confirmed through the official shared library (dense and sparse orders differ). A fresh validation build on updated common dependencies passes **512/512** trajectories again; receipts are in `evidence/recovery-order-20261003`. The earlier kernel42 proof covers unchanged kernel source, not the PCG implementation.
