# Attuazione avanzata integrata

Adapter nativo `MJ.Data.Advanced` per MuJoCo 3.14.0: copia il modello, costruisce cinematiche e Jacobiani Ada, calcola trasmissioni/forze PID/DC/SO3 e avanza lo stato con Euler. Il probe libera il modello sorgente prima della prima valutazione.

La ripresa del 3 ottobre ha prodotto una build validation con controlli runtime e **808/808 traiettorie C** passate:101 configurazioni,8 campioni,1 o 100 passi. Include PID hinge/slide/ball,64 configurazioni DC con stati e actearly, SO3 quaternion/expmap/velocity e site/refsite, muscoli, blocchi misti, disabilitazione e clamp. Evidenze e hash in [recovery-20261003](evidence/recovery-20261003).

Il confronto iniziale ha rivelato le allocazioni mocap mancanti in Create_Dynamics; la patch comune è stata applicata e il confronto rinnovato. I minimi e l’unità completa `MJ.Advanced_State` chiudono 8 obblighi funzionali e 6 diagnostiche flow. L’adapter completo passa 79 controlli flow, senza errori aperti; restano 53 warning conservati nelle ricevute. La prova funzionale dell’adapter rimane aperta. Le prove dei kernel delle trasmissioni non sono ancora complete; il flow dell’adapter non equivale a prova funzionale.

Restano da collegare vincoli, integratori oltre Euler, trasmissioni tendon/slidercrank/site scalari, armature/damping degli attuatori, delay/history, sonno, plugin e limiti aggregati. Le misure storiche su kernel non attestano prestazioni della simulazione completa.

Riproduzione:

```sh
python3 experimental/advanced-step/tests/build.py --out /var/tmp/advanced-new
/var/tmp/sparkling-movement-env/bin/python experimental/advanced-step/tests/compare.py --binary /var/tmp/advanced-new/build/validation/bin/advanced_probe --out /var/tmp/advanced-new/compare --samples 8 --steps 100
python3 experimental/advanced-step/tests/prove.py --build /var/tmp/advanced-new --out /var/tmp/advanced-proof-new
```

Build e proof usano snapshot esterni, job singolo e watchdog. `--resume --working-dependencies` congela esplicitamente una closure aggiornata; i risultati precedenti restano attribuiti ai loro hash.
