# Collegamento delle forze smooth al passo vincolato

Il passo `MJ.Data.Constrained` usa lo stesso stato posseduto, caricatore e
`Forward` dello smooth. Sono stati rimossi i rifiuti generici di attivazioni,
fluidi e tendini passivi: valgono i domini e i tipi di attuatore già ammessi
dallo smooth. Contatti, attrito e limiti articolari possono quindi convivere
con integrator/filter/filterexact, muscoli articolari, fluidi inertia-box o
ellissoidali e forze/armatura dei tendini fissi o spaziali supportati.

## Stato e avanzamento

- `Set_Activation` delega al setter dello stato posseduto e invalida la
  diagnostica vincolare soltanto quando riesce.
- `Activation_Count`, `Activation_Values` e `Activation_Rates` espongono lo
  stato e la derivata valutata da Forward.
- `State` conserva il formato precedente `[qpos,qvel,time]`; `Complete_State`
  comprende anche l'attivazione. I contratti statici di conservazione e
  fallimento si riferiscono ora a questo stato completo.
- Forward prepara l'attivazione successiva, compresi `actearly`, limiti e
  disabilitazione dell'attuazione. Il passo controlla `Activation_Can_Advance`
  prima di pubblicare posizione, velocità, attivazione e tempo.
- Un fallimento numerico, un input di dimensione errata o una capacità
  esaurita non avanza alcuna delle quattro parti dello stato.

I solver primali di C terminano normalmente quando la ricerca restituisce
`alpha = 0`. L'integrazione ora accetta anche gli iterati pubblicati con
`Stalled` e `Line_Search_Limit`, mantenendo questi stati distinti nella
diagnostica. Non vengono equiparati a `Converged`; errori di input, dominio o
fattorizzazione continuano a rifiutare il passo.

## Verifica

`tests/compare_forces.py` confronta modello/stato/controlli/carichi e traiettorie
con MuJoCo 3.14.0. Nessuna forza, massa, riga o soluzione calcolata da C entra
nel percorso Ada. Il corpus incrocia PGS/CG/Newton, hinge/slide/ball/free,
quattro dinamiche di attivazione, `actearly`, due modelli fluidi, tendini fissi
con giunti ripetuti e armatura, tendini spaziali con wrapping e flag di
disabilitazione. Confronta anche la derivata e lo stato finale di attivazione.

`tests/activation_edges.py` verifica dimensioni errate, transizioni fuori
dominio, differenza fra `actearly` attivo/inattivo, recupero dopo un rifiuto e
capacità vincolare esaurita in presenza di attivazione.

Il corpus e la build ottimizzata mantengono i controlli runtime. Le ricevute
di questa modifica sono salvate separatamente dagli altri lavori concorrenti
in `evidence/2026-10-02-force-merge`. La composizione globale Gold resta aperta;
le prove dei componenti e l'accordo numerico campionato non la sostituiscono.

I produttori di vincoli dei tendini, gli altri tipi di collisione, i coni e
le curve di impedenza sono stati modificati anche nella chat principale.
Questo rapporto descrive il collegamento delle forze e dello stato di
attivazione; il manifest di ogni verifica identifica la precisa revisione
dei chiamati effettivamente usata.

## Riproduzione

Compilare in un percorso esterno nuovo con `tests/build.py`. Poi, usando Python
con MuJoCo 3.14.0:

```sh
python tests/compare_forces.py --binary /path/to/constrained_probe --out /tmp/merged-forces-check --samples 4 --steps 100
python tests/activation_edges.py --binary /path/to/constrained_activation_edges --capacity-binary /path/to/constrained_edges --out /tmp/merged-activation-check
python tests/benchmark.py --binary /path/to/release/constrained_probe --out /tmp/merged-forces-perf --forces
```

Ripetere il confronto con entrambi i profili. I tempi misurano il passo
completo con vincoli e nuove forze; non dimostrano parità prestazionale senza
un confronto equivalente e dispersione registrata.
