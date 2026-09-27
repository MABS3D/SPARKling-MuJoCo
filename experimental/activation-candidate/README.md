# Attuatori con dinamica di attivazione

Implementazione isolata di `integrator`, `filter` e `filterexact`, con limiti di attivazione, `actearly`, stato posseduto e integrazione Euler. La repository principale e il suo stato Git non sono stati modificati.

**Il requisito completo di parità con C non è ancora soddisfatto.** I test funzionali passano; le catene da 24 DOF e 24 attuatori restano circa il 20–36% più lente. Restano anche prove di composizione da chiudere: non è una consegna Gold completa.

- [Risultati, prove e misure ripetute](risultati.md)
- [Sorgenti e documentazione](source/docs/activation-dynamics.md)
- [Patch rispetto alla copia iniziale](activation.patch)
- [Evidenze: test, log, snapshot, eseguibili e misure](evidence.zip)
- [Hash dei file modificati](changed-files.json)

La patch è stata verificata e riapplicata a una copia della baseline; i file ottenuti coincidono con quelli consegnati. La baseline comprendeva già modifiche locali del lavoro principale, incluse le forze esterne: non è una patch rispetto al solo HEAD Git. Il contenuto di questa consegna va integrato con revisione dei conflitti rispetto agli eventuali aggiornamenti successivi; non sovrascrivere integralmente la repository principale con `source`.

La directory `source` contiene la copia di lavoro autonoma. I comandi riproducibili sono in `source/tests/movement_performance/activation_dynamics/README.md`. Il riferimento C è MuJoCo 3.14.0. Le misure sono del passo completo sui modelli supportati, su un host condiviso; non una garanzia per tutti i modelli MuJoCo.
