# Primo passo integrato con vincoli — 2 ottobre 2026

`MJ.Data.Constrained` collega il modello MJB alla simulazione con contatti,
attrito piramidale e limiti articolari. Riusa lo stato posseduto e le fasi del
simulatore smooth, i materiali/collisioni rigide, l'assemblaggio CSR, la risposta
dei vincoli e i solver PGS/CG/Newton. I test forniscono ad Ada soltanto modello,
stato, controlli, forze generalizzate e carichi esterni: nessun contatto,
Jacobiano, coefficiente di risposta o forza risolta viene importato da C.

È un **ingresso sperimentale esplicito**, compilato da `constrained.gpr`.
Il percorso ordinario `MJ.Data.Create` / `MJ.Data.Euler.Step` conserva il suo
ambito: questa integrazione non rimuove globalmente il controllo sui vincoli.
Usare `Constrained.Create`, i relativi setter e `Constrained.Step`.
L'API espone anche `Evaluate`, `State` e `Diagnostics` per verificare i passaggi.

## Collegamenti implementati

1. Il modello viene validato e geometrie primitive, materiali, metadati dei
   giunti, pesi inversi e catene degli antenati vengono copiati nel nuovo stato.
   `Create` prende il modello in prestito esclusivo (`in out`), abilita soltanto
   durante l'inizializzazione interna il flag richiesto dal sottosistema smooth,
   quindi ripristina le opzioni anche su eccezione. Non copia i puntatori
   proprietari in un secondo modello. Il modello può essere liberato subito dopo
   `Create`, come fanno i test.
2. La cinematica produce le pose delle geometrie; `Collision_Scene.Generate`
   genera contatti completi e parametri dei materiali.
3. I Jacobiani vengono trasportati dal centro di massa al punto di contatto,
   sottratti fra i corpi e proiettati nel riferimento normale/tangenziale.
   La catena sparsa esclude gli antenati comuni. Il produttore dei Jacobiani
   corporei resta il cache denso della dinamica esistente.
4. Le righe vengono assemblate nell'ordine C: attrito dei DOF, limiti dei giunti,
   contatti. Sono calcolati velocità, impedenza, K/B, R/D e accelerazione di
   riferimento; il caso piramidale applica anche l'aggiustamento con `impratio`.
5. Il solver riceve massa e Jacobiano densi tramite un adattamento esplicito
   dell'assemblaggio CSR. Restituisce accelerazioni e forze delle righe.
   Le forze vincolari generalizzate vengono accumulate con `J' * force`.
6. Euler usa l'accelerazione vincolata; con smorzamento implicito risolve
   `(M + h*damping)*rate = smooth_force + constraint_force`, come
   `mj_EulerSkip`. Aggiornamenti scalari e quaternionici sono preparati prima
   della pubblicazione di posizione, velocità e tempo.

Non sono inserite allocazioni esplicite nell'avanzamento. Scene e buffer sono
riutilizzati; il solver generale mantiene però temporanei densi. L'oggetto
`Engine` contiene buffer fissi di grandi dimensioni: i probe lo allocano una
volta sullo heap. `Free` libera lo stato smooth; l'oggetto Engine è del chiamante.

## Ambito ammesso e limiti

- Euler, giunti hinge/slide/ball/free; contatti fra primitive rigide supportate
  dal modulo collisioni (piano, sfera, capsula, ellissoide, cilindro, box).
- Contatti senza attrito o piramidali con `condim` 1/3/4/6, compresa frizione
  torsionale e di rotolamento; attrito secco dei DOF; limiti hinge/slide/ball.
- Le forze libere, motori, molle/smorzamento e carichi esterni del sottoinsieme
  ammesso dalla dinamica smooth. Attivazioni `na > 0` escluse da questo ingresso.
- `solimp` lineare/quadratico: il parametro effettivo dopo la miscelazione deve
  avere potenza 1 o 2 (valori <= 1 vengono portati a 1 come in C). Altri casi
  restano esplicitamente non supportati.
- 1–128 DOF, massimo 256 geometrie, 128 contatti e 256 righe.
- Warmstart e isole devono essere disabilitati esplicitamente nel modello;
  tutti gli enable-flags sono esclusi. Limiti/contatti/frictionloss possono
  essere disabilitati singolarmente e i flag vengono rispettati.
- Non ancora ammessi: coni ellittici, NoSlip, uguaglianze, tendini, coppie
  esplicite/esclusioni, mesh/heightfield/SDF/flex, adesione, surface velocity,
  attivazioni, mocap/plugin e gli altri integratori. I modelli vengono rifiutati
  quando queste funzioni non sono gestite. I sensori richiedono il flag disable.

Il superamento di capacità o del dominio numerico non pubblica un nuovo stato.
`Diagnostics.Valid` si riferisce al risultato di `Evaluate`; dopo un passo
riuscito descrive le forze calcolate prima dell'integrazione, come i buffer C.
`Iteration_Limit` del solver pubblica l'iterato disponibile e resta nel report;
non equivale a una prova di convergenza o di ottimalità esatta.

## Verifica e prestazioni

Il riferimento ufficiale è MuJoCo **3.14.0**; la API delle release è stata
ricontrollata il 2 ottobre 2026 e restituisce il
[tag stabile 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0).
Sono stati seguiti `engine_core_constraint.c` (`mj_diagApprox`, risposta e righe)
e `engine_forward.c` (`mj_fwdConstraint`, `mj_EulerSkip`).

I risultati congelati e lo stato delle prove sono in
[evidence/2026-10-02/REPORT.md](evidence/2026-10-02/REPORT.md).
La verifica differenziale non è una dimostrazione universale di equivalenza.

I quattro nuovi kernel hanno contratti funzionali sugli esatti passi binary64:
trasporto di un componente del Jacobiano, proiezione nel frame, accumulo della
forza generalizzata e aggiornamento della velocità. Le prove procedono per
sottoprogramma e poi per unità completa. La composizione del nuovo ingresso e
le prove ancora aperte dei solver/collisioni restano lavoro da completare,
**non eccezioni matematiche Silver**. Non sono stati aggiunti `Assume`, nuove
routine trusted o soppressioni; anche la build ottimizzata mantiene i controlli
runtime. I contratti `Static` descrivono anche conservazione dello stato in
`Evaluate` e mancato avanzamento sui fallimenti; questi contratti globali non
sono dichiarati dimostrati.

I benchmark misurano l'intero passo equivalente con controlli numerici separati,
C ufficiale con SIMD normale e I/O fuori dal tempo. Questa prima composizione
non raggiunge la parità: la rappresentazione densa del solver scala male sui
casi con molti DOF. Non esiste un vecchio passo Ada completo equivalente da
usare come baseline prima/dopo; confrontare il solo smooth avrebbe omesso fisica.
Non è stata effettuata un'attribuzione quantitativa del costo per fase.

## Riproduzione

Con l'ambiente Python MuJoCo 3.14.0 e il toolchain GNAT del progetto:

```sh
python3 experimental/constrained-step/tests/build.py --out /var/tmp/constrained-check
python3 experimental/constrained-step/tests/build.py --out /var/tmp/constrained-check --resume --mode release
/var/tmp/sparkling-movement-env/bin/python experimental/constrained-step/tests/compare.py --binary /var/tmp/constrained-check/build/validation/bin/constrained_probe --out /var/tmp/constrained-compare --samples 8 --steps 100 --loads
/var/tmp/sparkling-movement-env/bin/python experimental/constrained-step/tests/rejections.py --binary /var/tmp/constrained-check/build/validation/bin/constrained_probe --out /var/tmp/constrained-reject
python3 experimental/constrained-step/tests/prove.py --build /var/tmp/constrained-check --out /var/tmp/constrained-prove
/var/tmp/sparkling-movement-env/bin/python experimental/constrained-step/tests/benchmark.py --binary /var/tmp/constrained-check/build/release/bin/constrained_probe --out /var/tmp/constrained-perf
```

Ripetere il confronto anche sul binario release. `build.py` congela l'intera
chiusura delle sorgenti in un percorso esterno e ne registra gli hash. `--resume`
riusa le dipendenze congelate e aggiorna soltanto le sorgenti di questa cartella;
serve per compilare l'altro profilo e per sviluppo locale. Le evidenze salvate
includono l'archivio esatto per riprodurre i risultati anche se il lavoro
parallelo continua a cambiare i moduli condivisi.
