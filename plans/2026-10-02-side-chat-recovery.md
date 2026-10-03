# Ripresa delle side chat — 2 ottobre 2026

Richiesta dell'utente: recuperare e far ripartire i lavori interrotti dal crash.
Recuperati 32 incarichi dalla cronologia locale dei prompt; 31 attività distinte,
con due richieste di unificazione dello step riunite. Il tentativo di riaprire
una side chat originale ha restituito `no rollout found`; le vecchie cronologie
non sono state ricostruite. I file già scritti sono presenti nella repository.

## Regole di ripartenza

- Riprendere dal codice e dai risultati salvati, senza riscrivere da zero.
- Tre agenti, nessuna ulteriore delega. Un processo di prova/build per agente,
  job singolo, limiti di memoria/tempo tramite `tools/guarded.py`.
- Prima i sottoprogrammi minimi; poi unità completa sulla sorgente finale.
  Gold dove possibile, Silver solo per limiti matematici documentati.
- Confrontare sempre l'algoritmo C ufficiale; verificare la release stabile
  prima di migrare. Non confondere prove locali, test numerici e prestazioni.
- Preservare tutte le modifiche precedenti. Niente commit, push, reset o pulizia.
- Congelare la chiusura di sorgenti usata nelle verifiche fuori dalla repository.
  Rilevare modifiche concorrenti prima di attribuire i risultati al codice attuale.
- Aggiornare il proprio diario di avanzamento a ogni checkpoint concreto.

## Proprietà dei file

**dynamics:** `experimental/constrained-step`, `experimental/smooth`,
`experimental/constraint-solvers-candidate`, `experimental/constraint-assembly-candidate`,
`experimental/joint-limit-candidate`, `experimental/noslip-candidate`,
`experimental/spatial-tendon-candidate` e il codice comune `src`.
È l'unico agente autorizzato a modificare l'ingresso principale e le strutture
Model/Data condivise. Priorità: rendere coerenti le integrazioni già scritte,
verificare lo step, proseguire con solver e prove. Coordinare le richieste altrui
sulle strutture comuni.

**collision:** `experimental/advanced-collision-candidate`,
`experimental/rigid-collision-candidate`, `experimental/materials-candidate`,
`experimental/sdf-step`, `experimental/flex-state-integration`,
`experimental/flex-elasticity-integration`, `experimental/flex-contact-candidate`.
Per collegamenti che richiedono modifiche allo step comune, preparare una patch
scoped fuori dai file posseduti da dynamics e comunicare il contratto necessario.

**services:** `experimental/advanced-step`, `experimental/advanced-actuation-candidate`,
`experimental/adhesion-contact-integration`, `experimental/integrators-candidate`,
`experimental/inverse-dynamics`, `experimental/dynamics-derivatives-candidate`,
`experimental/sensors-candidate`, `experimental/ray-casting`,
`experimental/plugin-runtime`, `experimental/sleep-candidate`,
`experimental/model-compiler-candidate` e nuovi adapter isolati per API/mocap.
Non modificare smooth/constrained-step/src comuni: preparare patch e comunicarle
a dynamics quando necessarie. Priorità ai lavori già iniziati prima del crash.

## Coda recuperata

### Dinamica, vincoli e prove

- R01: migliora prestazioni benchmark del passo vincolato fino alla parità prestazionale — in coda nel gruppo
- R03: su cholesky dei solver continua su relazione funzionale globale ancora incompleta&#x20; — in coda nel gruppo
- R04: unisci le due integrazioni, il passo vincolato esclude ancora attivazioni gluidi e tendini presenti nello smooth — in coda nel gruppo
- R05: Unifica forze e vincoli nello step — accorpato alla richiesta precedente
- R06: Completa le uguaglianze connect/weld — in coda nel gruppo
- R07: Integra i vincoli dei tendini — in coda nel gruppo
- R08: Integra i coni ellittici nello step — in coda nel gruppo
- R09: Implementa NoSlip — in coda nel gruppo
- R10: Completa tutte le potenze solimp — in coda nel gruppo
- R16: Integra surface velocity — in coda nel gruppo
- R30: Chiudi le prove di composizione — in coda nel gruppo
- R31: Dimostra gli invarianti di inizializzazione — in coda nel gruppo
- R32: Dimostra i solver PGS/CG/Newton — in coda nel gruppo

### Collisioni e deformabili

- R02: su BVH procedi su dimostrazioni di costruzione e attraversamento — in coda nel gruppo
- R11: Integra collisioni mesh e heightfield — in coda nel gruppo
- R12: Integra BVH nella scena — in coda nel gruppo
- R13: Integra stato e collisioni flex — in coda nel gruppo
- R17: Integra SDF nella simulazione — in coda nel gruppo
- R19: Integra elasticità e flessione flex — in coda nel gruppo

### Attuazione e servizi

- R14: Integra attuatori PID/DC/SO3 — in coda nel gruppo
- R15: Completa le trasmissioni degli attuatori — in coda nel gruppo
- R18: Integra adesione e contatti — in coda nel gruppo
- R20: Completa gli integratori oltre Euler — in coda nel gruppo
- R21: Implementa la dinamica inversa — in coda nel gruppo
- R22: Implementa le derivate della dinamica — in coda nel gruppo
- R23: Completa e integra i sensori — in coda nel gruppo
- R24: Integra il ray casting — in coda nel gruppo
- R25: Integra mocap — in coda nel gruppo
- R26: Integra i plugin — in coda nel gruppo
- R27: Implementa la gestione del sonno — in coda nel gruppo
- R28: Completa le API MuJoCo — in coda nel gruppo
- R29: Completa il compilatore dei modelli — in coda nel gruppo

## Evidenze del recupero

HEAD iniziale: `2b601cc27e1f5d46a0708b1d90646a08e1d9aec2`.
Backup del diff tracciato e di 246 sorgenti/documenti non tracciati: `/var/tmp/sparkling-sidechat-recovery-yg9h5cu1`.
Identificativi e prompt originali: `2026-10-02-side-chat-recovery.json`.

## Agenti riavviati

- `/root/recover_dynamics`: 12 attività distinte; [avanzamento](2026-10-02-recovery-dynamics.md).
- `/root/recover_collision`: 6 attività; [avanzamento](2026-10-02-recovery-collision.md).
- `/root/recover_services`: 13 attività; [avanzamento](2026-10-02-recovery-services.md).

Gli agenti procedono serialmente nella propria coda. Assegnazione e avvio non
significano completamento dei 31 lavori; i risultati sono nei diari dedicati.
