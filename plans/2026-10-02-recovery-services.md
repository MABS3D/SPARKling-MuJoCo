# Ripresa services — 2 ottobre 2026

Stato: esecuzione ripresa, non semplice audit. Proprietà dei file conforme al piano comune; i quattro nuovi file adesione in `constrained-step` restano di questo gruppo, gli altri file comuni vengono modificati solo dal proprietario dynamics tramite patch coordinate.

Baseline ufficiale ricontrollata il 2026-10-03: [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0), commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Nessuna migrazione di versione.

La tabella riassume gli ultimi checkpoint verificati. Ogni prova e confronto vale per gli hash della relativa ricevuta; le modifiche successive richiedono un rinnovo esplicito.

| ID | Incarico | Stato e prossimo passo |
| --- | --- | --- |
| R14 | PID/DC/SO3 | R16-r1 validation/release: smooth 808/808, vincolati fixed 800/840 e mobile 839/840, edge e minimi 8/8 PASS. Replay ordinari isolano residui comuni. Publication whole r14 46+1, Set_Activation minimo 7+2; caller aperti, preparazione separata in prova. Altri integratori pendenti. |
| R15 | Trasmissioni | Expmap tiny: 2222/2222 esatti dopo helper Cosine comune; contratto FP minimo chiuso; whole aperta. Log allineato al reciproco/fallback C: 4836/4836 kernel validation, confronto esatto 416/559 con residui atan/atan2 documentati. Audit precedente 21/21 manifest; whole e composizione restano aperte, vecchie prove non estese al Log modificato. |
| R18 | Adesione/contatti | Integrata nella centrale; 440/440 C validation e release dopo fix grouping; 106/106 regressioni sulla precedente closure. Kernel 303 proof + 43 flow identico per hash, adapter flow 11 chiusi. Composizione/performance pendenti. |
| R20 | Integratori | Corretti discrete gyro/drag; PCG nativo con tolerance/iterations.512/512 completi; kernel intero42 proof check. prove composizione aperte. |
| R21 | Dinamica inversa | Produzione 2848/2848 scenari C, 412/412 risposte esatte per ciascuna modalità densa/sparsa. Kernel35 proof+9flow; Multiply=Model e composizione aperti. |
| R22 | Derivate | Produzione960/960 C, incluse55configurazioni adesione, dopo fix Velocity/Nudge/rotazioni giunti. Kernel82 proof+14flow; sensori, altri integratori e composizione pendenti. |
| R23 | Sensori | 264/264 traiettorie C, tutti i tipi builtin0..46 rappresentati; kernel73/73. Composizione/produttori avanzati da completare. |
| R24 | Ray casting | Kernel72/72; confronto1440 primitivi+6480 scene; lifecycle PASS. Composizione/performance pendenti. |
| R25 | Mocap | Recuperato e integrato dal proprietario dynamics;272/272 traiettorie, kernel45 proof +1 flow. Prove setter e mapping esatto pendenti. |
| R26 | Plugin | 212/212 C; protocollo29, runtime61, callback54 controlli provati. Composizione/performance pendenti. |
| R27 | Sonno | Kernel13+10, cicli40+6, Wake34+5 e Update49+2 chiusi. Controller1075/1075, smooth39/39 e rollback12/12 validation/release sulla stessa closure; Copy_Sign/island producer aperti. |
| R28 | API MuJoCo | BuildPASS;2992/2992 stato,330/330 nomi,smokePASS. Inventario630simboli; prove e integrazione totale pendenti. |
| R29 | Compilatore | Passi indirizzi recuperati; non è un compilatore MJCF/URDF completo. Prove e confronto da riprendere. |

## Checkpoint 0: ripartenza plugin

- I log pre-crash terminavano durante la compilazione del runtime; la prova completa era stata interrotta dal watchdog e non costituisce una riuscita.
- Driver build e prova plugin adattati a `-j1`, mantenendo `tools/guarded.py` e snapshot esterni.
- Build corrente: `/var/tmp/sparkling-services-plugin-recovery-20261002`, sorgenti/hash nel manifest. Dipendenze congelate, nessuna compilazione nelle directory condivise.
- Verificato il caso `mjSTAGE_NONE` direttamente in `engine_sensor.c`: la selezione del callback include la fase posizione, il cutoff C mantiene il confronto stretto sullo stadio del sensore. Preservato il comportamento C; nessuna modifica semantica basata soltanto sull'intuizione.
- Ancora nessun risultato finale di build/prova attribuito alle sorgenti correnti. Nessun benchmark eseguito con carico concorrente.

## Checkpoint 1: plugin nuovamente eseguibili

- Build validation completa con controlli runtime, `-j1`, watchdog; snapshot `/var/tmp/sparkling-services-plugin-recovery-20261002`, `manifest.json` e `build.log`.
- C ufficiale 3.14.0: **106/106 casi** (53 configurazioni, 2 campioni; 0/1/100 passi; slide/hinge; stadi none/pos/vel/acc; attivazione, flag disabilitazione, cutoff, limiti, plugin multi-capacità). Risultati e hash binario in `compare/results.json`.
- `runtime_edges`: lifecycle, selezione stadi, interrogazioni SDF e preservazione atomica su fallimento **PASS**.
- Il runtime `Copy` ha ora l'invariante esplicito che preserva ready/count/config durante i callback. Questa modifica di prova è successiva al binario appena confrontato; serve una verifica fresca prima di estendere l'evidenza.
- Driver `prove.py` ora congela e verifica hash anche del progetto, seleziona sottoprogrammi per nome, raccoglie `.spark` e rifiuta verifiche senza obblighi. Nessuna assunzione o soppressione introdotta.
- Ancora aperti: prova completa del runtime/adapter e prestazioni integrate; non è dichiarato Gold per tutto il plugin engine.

## Checkpoint 2: protocollo plugin e regressioni sensori

- Prove fresche plugin `Cutoff` 5, `Add` 8, `Multiply` 8 obblighi; unità completa `mj-plugin_protocol` **29/29**, copertura SPARK completa, zero obblighi aperti. Ricevute `/var/tmp/sparkling-services-plugin-proof-*`.
- Prova per istanziazione reale `Test_Runtime`: `Call`, `Create`, `Free`, `Reset`, `Copy`, `Dispatch` passati dopo invarianti di preservazione espliciti; `Query` e unità completa ancora da chiudere. Il warning che la definizione generica isolata non viene analizzata è conservato: la prova riguarda l'istanza e il suo callback Ada, non qualsiasi callback esterno.
- R23: aggiunti test rangefinder con materiale opaco/geometria trasparente e caso inverso. Il binario pre-crash fallisce entrambi i casi contro C (0/2), salvati in `/var/tmp/sparkling-services-sensor-regression-before/results.json`.
- Correzione in corso: riusare la scena nativa `MJ.Rays` dentro `MJ.Data.Sensors`, con sincronizzazione dalle pose Ada, invece della vecchia scansione primitiva. La scena gestisce già la precedenza del materiale e consente ray su mesh/BVH e heightfield. Scene allocate solo se servono ai sensori rangefinder e rilasciate insieme al contesto. Questa integrazione richiede una build/confronto nuovo, ancora in attesa della fine delle prove plugin.
- Aggiunti inoltre fixture sensori camera, attuatore/tendine e distanza/normal/fromto; non ancora attribuiti come passati.

## Checkpoint 3: runtime plugin completo

- Dopo diagnosi minima, l'unità completa dell'istanza `Test_Runtime` passa **61/61 controlli**, nessun obbligo aperto, SPARK completo. Ricevuta `/var/tmp/sparkling-services-plugin-proof-runtime-whole`; le prove riguardano le sorgenti finali con invarianti di `Create`, `Copy` e `Dispatch`.
- Proprietà funzionali: metadati preservati, rollback del runtime su callback rifiutato, preservazione degli stati delle istanze non selezionate e della coda oltre `State_Count`; conteggi/lifecycle coerenti. Non è una prova della composizione con tutto lo smooth engine né una portabilità universale del plugin ABI.
- È in corso la prova separata del callback Ada di test; il suo corpo non viene reso trusted per inferenza.
- Ricevute compatte build/confronto/prove copiate in `experimental/plugin-runtime/evidence/recovery-20261002`, insieme ai relativi manifest di sorgenti. I log falliti iniziali restano in `/var/tmp` e non sono riclassificati.

## Checkpoint 4: callback plugin dimostrato

- La prova separata ha individuato due domini non gestiti dal callback di test: lunghezza array che può superare `Integer` e indice di attivazione frazionario che arrotonda oltre il buffer. Sostituito il confronto della lunghezza con quello dei limiti e verificato l'indice prima della conversione/lettura.
- `Native_Plugins.Invoke` minimo e unità completa: **54/54 controlli provati**, zero aperti, copertura SPARK completa. Ricevute `/var/tmp/sparkling-services-plugin-proof-callback3` e `...-callback-whole`. Test esplicito del rifiuto atomico aggiunto in `runtime_edges.adb`.
- Rebuild fresco del runtime finale avviato prima di rinnovare i confronti numerici. I numeri del checkpoint 1 restano attribuiti al relativo snapshot.

## Checkpoint 5: plugin finali e avvio build sensori/ray

- Build validation rinnovata dopo tutte le modifiche, più test lifecycle/indice frazionario **PASS**. Hash della closure del build verificati contro il checkout: **nessuna divergenza** al momento del checkpoint.
- Confronto finale ampliato a **212/212 casi** (53 configurazioni × 4 campioni), ricezione `compare-final/results.json`; il manifest del build finale e i risultati sono anche in `experimental/plugin-runtime/evidence/recovery-20261002`.
- Prova dell'intero runtime rinnovata dopo la correzione del callback: **61/61**, zero aperti, stessa sorgente finale. Protocollo **29/29**, callback reale **54/54**; nessuna attribuzione di Gold all'engine intero.
- R23/R24: collegamento scena ray completato nel codice e aggiunti i 6 campi rangefinder site (`dist`, `dir`, `origin`, `point`, `normal`, `depth`), inclusi valori C su miss. Build nuova su dipendenze correnti congelate avviata in `/var/tmp/sparkling-services-sensors-rays-recovery-20261002`.
- Prossimi: risolvere build/test sensori ampliati, prove dei kernel/ray, poi riprendere attuazione/integratori/inversa/derivate/sonno e adapter mocap/API/compilatore. Prestazioni plugin integrate ancora pendenti; nessun benchmark conclusivo in concorrenza.

## Checkpoint 6: primo confronto sensori/ray e schema condiviso

- Nuova build sensori/ray **PASS** (snapshot working-tree, 88.8 s, picco watchdog 453 MB).
- Corpus ampliato: **36/44** al primo run; gli 8 fallimenti si fermano al caricamento dei rangefinder multi-campo, perché lo schema condiviso imponeva erroneamente dim=1. Non sono occultati dai risultati del kernel.
- Separando i fixture scalari dai multi-campo, range materiale visibile, materiale invisibile, mesh e heightfield passano tutti (**4/4**), compresi i due difetti riprodotti prima della correzione.
- Preparata patch in `experimental/sensors-candidate/integration/rangefinder-dimensions.patch`; il proprietario dynamics ha applicato il collegamento centrale con controllo minimo Dim>=1, conservando la sua ownership di `src`. L'adapter sensori ora controlla esattamente la dimensione attesa dal dataspec.
- Nuovo kernel `Range_Width`: **26/26** controlli provati, dimensione esatta della selezione dei 6 campi. Resto dei kernel minimi in prova, poi unità intera e ricompilazione con la nuova closure condivisa.

## Checkpoint 7: kernel sensori completi

- I minimi `Range_Width`, `Clip`, `Sum3`, `Relative`, `Accumulate`, `Projection` passano; unità finale completa `MJ.Sensor_Kernels`: **73/73** controlli, zero aperti, SPARK completo. Proprietà: larghezza esatta dataspec, cutoff e operazioni floating-point ordinate.
- Evidenze persistite in `experimental/sensors-candidate/evidence/recovery-20261002`. Non provano la composizione totale sensori/dinamica/ray.
- Driver build migliorato: `--resume --working-dependencies` aggiorna esplicitamente tutta la closure con hash e controllo di concorrenza; non tocca timestamp di contenuti invariati; include il progetto nel manifest. La modalità default mantiene dipendenze core HEAD e congela i sorgenti ray/sensor posseduti.
- Build aggiornata ora include la correzione centrale delle dimensioni e l'esatto controllo dataspec nell'adapter.

## Checkpoint 8: integrazione sensori/ray verificata contro C

- Rebuild su closure aggiornata **PASS**. Confronto ampliato finale **208/208 traiettorie** (26 modelli × 8 campioni, 30 passi): nessun fallimento. Include ora rangefinder scalari e multi-campo su materiale/mesh/BVH/heightfield, miss, camera, attuatori/tendini e distanza/normal/fromto, oltre al corpus recuperato.
- Ricevuta `/var/tmp/sparkling-services-sensors-rays-recovery-20261002/compare-final/results.json`; build e sorgenti nello stesso snapshot. Kernel sensori unità completa 73/73 già documentati.
- R23/R24 avanzano come integrazione reale: nessun dato di pose/ray fornito dal C all'implementazione Ada. La sorgente Model viene liberata nel probe, quindi il confronto esercita anche la proprietà dei dati copiati.
- Restano da ampliare contatti/tactile/limiti tendini e provare la composizione totale. Prove fresche dei kernel ray in corso; i vecchi hash ray divergono e non vengono ereditati come evidence corrente.

## Checkpoint 9: nuovi sensori di contatto e regressione tactile

- Ray kernel: minimi e unità completa fresca **72/72** controlli, zero aperti. Build separata ray avviata per rinnovare anche il suo differential corpus.
- Corpus sensori esteso a contatti con tutte le riduzioni e orientamento geom invertito, limiti tendini e tactile. **64/66** sul primo run: contatti e limiti passano; due soli rifiuti riguardano tactile senza frame tangente.
- Confronto diretto `mjs_sensorDim`/test C `TactileSkipTangents`: tactile ha sempre 3 canali per taxel; quando mancano le tangenti i due canali velocità restano zero. Corretto il controllo del loader locale che richiedeva erroneamente un solo canale. Ricompilazione/confronto ancora da eseguire su questa modifica.

## Checkpoint 10: sensori e ray, più sorgenti mocap/API ritrovati

- Sensori: il confronto esteso264 casi ha isolato un secondo difetto: la riduzione netforce con zero contatti deve ancora restituire assi globali normal/tangent. Ramo corretto secondo engine_sensor.c; nuova build validation e **264/264** traiettorie (33modelli ×8campioni,30passi) passate. Tutti i tipi builtin0..46 sono rappresentati, non ogni configurazione o produttore avanzato. Tactile senza tangenti ora passa.
- Ray: confronto separato **1440/1440** primitivi e **6480/6480** scene su9modelli; test lifecycle/stale/invalid/atomic batch PASS. Minimi e unità completa kernel **72/72**. Evidence compatta con hash in experimental/ray-casting/evidence/recovery-20261002.
- Ricevute finali sensori in experimental/sensors-candidate/evidence/recovery-20261002. Proof73/73 del kernel non è una prova dell'intera composizione. Prestazioni integrate ancora pendenti.
- R25/R28: sorgenti pre-crash ritrovati solo in /var/tmp. Ripristinati gli originali in experimental/mocap e experimental/public-api. Mocap: ricostruita dal suo script originale una patch minima sulla closure attuale, senza sovrascrivere unità condivise; nuovo snapshot /var/tmp/sparkling-services-mocap-recovery-20261002. Il proprietario dynamics applicherà le modifiche core soltanto dopo verifica. API: runner recuperati adattati per snapshot esterni e -j1.

## Checkpoint 11: mocap recuperato e reintegrato

- Patch originale recuperata dal salvataggio pre-crash, ricostruita sulla closure corrente e provata in isolamento. Corretto un difetto reale: il reset ora ripristina il quaternione grezzo del modello senza una seconda normalizzazione. Le pose usano ancora la normalizzazione locale C.
- Nuova build validation **PASS**; confronto **272/272** traiettorie C3.14.0 (9modelli, smooth/constrained,16campioni,100 passi), con input zero/nonunit/tiny/grandi/near-unit, figli hinge/ball, contatti con piano mobile, tendini e fluido. Reset bit-per-bit, input raw, atomicità su errori e lifecycle PASS.
- Kernel Write_Pose minimo e unità completa **46/46** controlli funzionali provati. Non attribuiti al setter o alla composizione completa: vecchia prova setter era scaduta. Nuova diagnosi selettiva pianificata.
- Il proprietario dynamics ha applicato la patch finale467righe a7unità condivise, senza conflitti. Evidence compatta experimental/mocap/evidence/recovery-20261002, snapshot /var/tmp/sparkling-services-mocap-recovery-20261002. API recuperate ora in build, con test aggiuntivo delle tabelle nomi native.

## Checkpoint 12: API recuperate e inventario pubblico completo

- Build API validation su snapshot **PASS**. Confronto C **2992/2992** operazioni stato/type/solver-info,6rifiuti atomici; tabelle nomi native **330/330** (inclusi UTF-8, NUL, assenti, ID invalidi e tutti i tipi enumerati). Smoke runtime create/free-model/forward/100step/reset/doppio-free PASS.
- Proof minima Copy_Block **22/22** e From_Model/Prefix_Size passate. State_Size inizialmente aveva un post aperto: aggiunta al modello Prefix_Size la relazione ricorsiva esatta, provata separatamente; State_Size ora passa. Resto dei minimi e unità totale in corso. Queste modifiche di contratto sono successive al binario numerico e richiedono nuova build prima del checkpoint finale.
- Inventario stable C in experimental/public-api/inventory/public-symbols.{json,csv}: **630simboli** (609funzioni,12callbackhook,9dati), inclusi i63entry Filament non marcati MJAPI. Tutte563dichiarazioni MJAPI di mujoco.h risultano censite;26contratti callback plugin separati.22mappature native iniziali; i non mappati non sono dichiarati implementati né assenti senza audit.
- Coda esplicita per API engine/utility mancanti, produttori owned-state, compiler/spec completo, render/visualization/UI, plugin ABI/resources e inventario separato degli header USD sperimentali. Il successo di questa facade non è completezza MuJoCo. Nessun benchmark conclusivo in concorrenza.

## Checkpoint 13 (continuazione 3 ottobre): unità stato API dimostrata

- Isolato il lemma Preserve_Matches (**8/8**) e la copia di un singolo campo Extract_Block (**15/15**), quindi Extract_State (**14/14**) e Get_State (**7/7**). Il modello esplicito conserva il prefisso già estratto senza assumere l'equivalenza C.
- Unità completa MJ.API.State: **157 proof check +2 diagnostiche flow**, zero aperti, SPARK completo. Set_State e Copy_State chiudono safety/atomicità su errore (**13/13** ciascuno), ma il contratto completo del successo/frame resta da aggiungere: nessun claim Gold dell'intera API.
- I runner prova ora distinguono proof_checks e flow_checks; il gate richiede almeno un obbligo di prova effettivo, non sole diagnostiche informative. Evidence in experimental/public-api/evidence/recovery-20261002. Rebuild/numerici finali ancora da rinnovare dopo refactoring.
- Mocap: Free_State con postesteso chiude; il setter era aperto per due overflow nel contratto con First elevato, corretti usando First+(I-offset), senza pre artificiali. I22controlli locali passano; un postcomposto resta aperto. Separati i post equivalenti per diagnosi, soltanto in patch/snapshot concordati col proprietario. Aggiunto test concreto con origini array vicine a Integer'Last.
- La prossima priorità dopo chiusura API/mocap è attuazione avanzata e integratori effettivamente collegati al movimento.

## Checkpoint 14: API finali ricompilate

- Build validation dopo refactoring **PASS**; ripetuti confronto stato **2992/2992**, nomi **330/330**,6rifiuti atomici e runtime smoke **PASS**. Sorgenti/binari dei risultati finali sono registrati separatamente in evidence; non ereditano il binario precedente.
- Prova unità stato **157 proof check +2 flow**, con limiti del contratto successo Set/Copy ancora espliciti. Inventory pubblico conserva630simboli e i sottosistemi mancanti.
- Mocap: il contratto del setter è stato separato senza indebolirlo; resta1post aperto. Diagnosi ora espone separatamente stabilità del layout, bounds degli input e cache. Nessuna assunzione o nuova precondizione restrittiva.

## Checkpoint 15: attuazione avanzata nella pipeline reale

- Corretti due errori di compilazione nel bench recuperato (nome Time ambiguo e conversione fra sottotipi array). La build validation resta con controlli runtime attivi.
- Il primo confronto ha riprodotto una regressione d’integrazione: tutti101modelli erano rifiutati. Create_Dynamics ometteva i nuovi buffer mocap, anche vuoti. Patch minima di due allocazioni preparata in mocap/integration e applicata dal proprietario dynamics.
- Rebuild della closure condivisa e confronto nuovo: **808/808 traiettorie** (101configurazioni ×8campioni,1/100 passi) PASS, comprese tutte64combinazioni DC con actearly, PID hinge/slide/ball, SO3 joint/site/refsite, muscolo, blocchi misti, gruppi e flag. Pose, forze, accelerazioni e step sono calcolati interamente da Ada; il modello sorgente è liberato prima del movimento.
- Snapshot /var/tmp/sparkling-services-advanced-recovery-20261003, risultato compare-fixed/results.json. Evidence compatta in experimental/advanced-step/evidence/recovery-20261003. Prove minime e unità completa avviate; flow dell’adapter separato dalla correttezza funzionale.
- Questo adapter è ancora Euler senza vincoli, non l’intera pipeline unificata. Trasmissioni tendon/slidercrank/site scalari, damping/armature attuatore, ritardi, sonno e composizione con plugin/contatti restano espliciti. Nessuna misura prestazionale conclusiva con carico concorrente.

## Checkpoint 16: flusso attuazione e avvio integratori

- I tre minimi Advanced_State e l’unità completa chiudono **8 proof check + 6 flow**, zero aperti.
- Il flow dell’adapter ha inizialmente esposto 7 alias E/Config, un percorso Target non inizializzato esplicitamente e una dimensione array dipendente da input variabile. Sostituiti i rename con snapshot costanti, fissata la dimensione locale e inizializzato Target. Nessuna assunzione introdotta.
- Flow completo rinnovato: **79 controlli**, zero errori aperti, 53 warning conservati. Non è una prova funzionale del movimento o delle leggi PID/DC/SO3. Rebuild e confronto finali rinnovati: **808/808 PASS**. Evidence finale separata dal primo run.
- Mocap: controllo lineare della mappatura estratto e usato da entrambi i costruttori, applicato da dynamics. Test per Create_Dynamics con mocap nonzero e rifiuto dei duplicati aggiunto; prova esatta del nuovo helper in preparazione.
- Integratori oltre Euler: build fresca avviata, con test aggiuntivo di rifiuto atomico degli operatori di dimensione errata e controlli lifecycle. La correzione pre-crash Has_Metric viene preservata e verificata prima di modificarla.

## Checkpoint 17: correzioni integratori e arresto PCG

- Prima build fresca integratori PASS; corpus originale rinnovato **408/416**. Tutti gli scarti riguardavano discrete/free e discrete/fluid_ellipsoid. Il fix Has_Metric salvato prima del crash non era sufficiente.
- Il confronto con engine_derivative.c/engine_forward.c ufficiali ha identificato due rami: il giroscopio locale va escluso sulle righe accoppiate da metriche di attuatori/tendini; la derivata fluida va simmetrizzata nello spazio locale prima della proiezione. Corrette entrambe le operazioni, inclusa implicitfast sui corpi non liberi.
- Corpus mirato ampliato **120/120**; il completo era **478/480**, con due differenze circa 2.2e-10 dovute al precedente solve diretto che ignorava opt.tolerance/iterations. Nessuna tolleranza del test è stata allargata.
- Implementato PCG nativo della metrica effettiva, separando backbone simmetrico, accoppiamenti e successivo solve giroscopico locale. Selection conserva ora tolerance/iterations. Aggiunti casi di tolleranza larga/stretta, free senza attuatore, PGS e fluido su discendenti fissi. Nuova build PASS; **128/128** discrete mirati PASS; confronto completo512 casi in corso.
- Kernel Symmetric_Entry aggiunto con contratto floating-point esatto; tutti7minimi Integration_Kernels passano (42 proof check complessivi). Unità completa ancora da eseguire. PCG/composizione conservano prove e warning C sul limite iterazioni ancora pendenti; non dichiarati Gold.
- R15: audit di21manifest pre-crash delle prove, tutti con hash Ada/base identici. I risultati4836 di validation/release differiscono soltanto nel driver prove.py modificato a-j1; nessuna prova di unità con obblighi aperti è stata riclassificata come chiusa.

## Checkpoint 18: integratori ricompilati e verificati

- Corpus completo dopo il collegamento PCG: **512/512** (32 configurazioni × 4 integratori × 4 campioni, 100 passi), senza modificare la tolleranza differenziale 2e-10. Build validation e input di confronto identificati da hash.
- Minimi e unità completa Integration_Kernels: **42 proof check**, zero aperti. La composizione del PCG e degli operatori rimane distinta e da provare; il warning pubblico su limite iterazioni è ancora da collegare.
- Evidence persistita in experimental/integrators-candidate/evidence/recovery-20261003. README esplicita il dominio smooth, i produttori/composizioni mancanti e la politica dei pivot.
- Prossima ripresa: adesione nel constrained corrente; il vecchio overlay è stato preservato e differenziato, ma i suoi cambi devono essere riapplicati in modo scoped alle interfacce nuove. Mocap: diagnosi funzionale del mapping in corso su snapshot.

## Checkpoint 19: mocap sulla produzione comune

- Build validation e confronto rinnovati sulla closure produttiva: **272/272** traiettorie C, più origini array vicine a Integer'Last, Create_Dynamics con mocap zero/nonzero e rifiuto atomico degli ID duplicati. Nessun difetto numerico residuo in questo corpus.
- Il progetto runtime/proof seleziona soltanto il kernel comune in smooth. Minimo Write_Pose e unità completa: **45 proof check + 1 flow**, zero aperti, SPARK completo; il precedente totale46 comprendeva il flow. Evidence in experimental/mocap/evidence/recovery-20261003.
- La prova funzionale del controllo mapping e il post aggregato Set_Mocap rimangono lavori separati. Nessun trasferimento della prova kernel alla composizione. Adesione in preparazione sulla centrale attuale, con patch scoped verificata prima dell’applicazione.

## Checkpoint 20: adesione verificata nella pipeline constrained

- Recuperato e ribasato l’adapter sulle nuove interfacce comuni (mocap, asset, equality, surface velocity, endpoint). I contatti con endpoint flex vengono esclusi dalla trasmissione body, come in C.
- Build validation **PASS** e confronto **440/440** (55 configurazioni × 8 campioni, 100 passi). Contatti, momenti, forze, accelerazioni, vincoli e traiettorie sono prodotti da Ada; modello C usato soltanto come oracolo. Sono rappresentati PGS/CG/Newton, coni pyramidal/elliptic, dimensioni 1/3/4/6, gap, body liberi/articolati, motori intercalati, attivazioni, flag e clamp.
- Patch production-core.patch inviata al proprietario dynamics: quattro unità comuni modificate e quattro nuove unità produttive in constrained-step/src. In questo modo le closure degli altri adapter acquisiscono un’unica copia. Applicazione e regressione produttiva ancora pendenti al momento del checkpoint.
- Prove minime fresche in corso; prime sette chiuse. Nessuna prova pre-crash viene attribuita automaticamente alla nuova composizione. Evidence numerica in experimental/adhesion-contact-integration/evidence/recovery-20261003.

## Checkpoint 21: adesione produttiva, prove e regressioni

- Il proprietario dynamics ha applicato la patch comune e le quattro nuove unità; hash verificati. Copie originarie archiviate e escluse dai GPR. I runner ora selezionano le unità produttive in constrained-step/src.
- Tutti12 minimi kernel passano; unità completa **303 proof check + 43 flow**, zero aperti e copertura SPARK completa. I warning dei modelli ricorsivi restano nella ricevuta.
- Flow adapter: corretto alias sulla configurazione, inizializzato il buffer temporaneo e aggiunte varianti di terminazione. Nuovo flow **10 controlli**, zero errori,11 warning conservati; nessun claim di prova funzionale dell’intera composizione.
- Build produttiva rinnovata **PASS**, confronto finale **440/440**, regressione constrained ordinaria **106/106**. Numeric_Limit e Capacity_Exceeded preservano lo stato; il caso numerico riprende dopo correzione del controllo. I primi due edge fixture rifiutati mancavano il flag warmstart richiesto: corretti i fixture, nessun allargamento della semantica o delle tolleranze.
- Ricevute separate production-* in evidence/recovery-20261003. Ripresa R21: corpus inverso esteso ai nuovi attuatori body/attivazioni e ai profili solimp ormai supportati, build fresca avviata.

## Checkpoint 22: adesione release sulla medesima closure

- Build release completata con ottimizzazioni normali del progetto; il runner --frozen verifica gli hash e non ricopia sorgenti. La mappa sorgenti è identica a quella validation.
- Corpus release **440/440** e i due casi Numeric_Limit/Capacity_Exceeded con preservazione/ripresa **PASS**. Ricevute distinte di comando, sorgenti e hash binario in evidence/recovery-20261003. Nessun tempo di questo run è un benchmark conclusivo sotto carico concorrente.
- R21 build iniziale PASS. Corpus esteso include adesione con attivazioni e profili solimp; preparata una proprietà composta di preservazione dei bounds per Scatter, da provare al minimo prima di usarla nelle invarianti del prodotto inverso.

### Diagnosi R21 e finestra di misura comune

Il nuovo post composto di Scatter passa al minimo (11 proof check +2 flow) e chiude le due precedenti invarianti Work della funzione Model. Il nuovo post finale Work(Model’Result) resta aperto (26 controlli chiusi,1 aperto): occorre esporre il bound al termine dell’ultima iterazione e sui ritorni anticipati prima di provare la relazione completa Multiply/Model. Nessuna prova integrale della massa viene dichiarata. Il sorgente del nuovo contratto è congelato separatamente dal primo binario; il confronto finale attenderà una ricompilazione coerente.

Su richiesta del coordinatore, dopo la conclusione del job corrente non sono avviati altri build/prover/test durante la breve finestra prestazionale comune. L’attività prosegue con analisi e documentazione; nessuna modifica dello stato dell’obiettivo persistente.

### Collegamento individuato per R22

L’analisi del vecchio adapter derivate mostra in Inverse_Sample un prodotto denso per riga e la somma `(((M*a+bias)-gravity)-passive)-constraint`, mentre il modulo inverso recuperato segue diagonal/reverse-lower/upper-scatter e `(bias-gravity)+((M*a-passive)-constraint)`. La sua proiezione scalare separata usa inoltre una riduzione a coppie delle quattro lane. La prossima implementazione riuserà MJ.Data.Inverse e MJ.Inverse_Constraints, prima su fixture minime e poi sul corpus, includendo i coni ellittici; nessuna tolleranza sarà allargata per nascondere l’ordine differente. Il risultato pre-crash225/228 appartiene al suo snapshot, non alla produzione corrente.

Il riferimento C3.14.0 rifiuta esplicitamente sleep in mjd_transitionFD e mjd_inverseFD; tali errori non costituiscono un difetto da imitare come capacità supportata. Occorre mantenere esplicito il dominio dei test e preservare lo stato sui rifiuti dell’API nativa.

### Audit riduzioni C, dopo checkpoint 22

Confrontati engine_util_blas.c e engine_util_sparse.h della copia ufficiale3.14.0 (identici nei due checkout di riferimento). Entrambi combinano le quattro lane come `(r0+r2)+(r1+r3)`. Il dot denso somma la coda di2/3 prodotti prima di aggiungerla al totale; quello sparso aggiunge i residui sequenzialmente. Da correggere/riverificare: Sparse_Velocity adesione e riduzioni inverse (raggruppamento); Dot PCG (coda densa); vecchia Derivative_Projection (raggruppamento e riuso della risposta inversa). Anche la norma tangenziale dim6 inversa deve rispettare il grouping di mju_norm/mju_dot.

Fixture mirate previste: quattro termini `[1e16,1,-1e16,1]` danno2 con il grouping C e1 con quello recuperato; un totale iniziale1e16 e coda densa `[-1e16,1]` danno0 in C e1 col vecchio accumulo sequenziale. Il dominio dei dati è rappresentabile con momenti e velocità entro1e8. I corpus440/512 restano ricevute reali delle loro closure, ma non costituiscono una prova di questi casi di cancellazione. Nuovi build/proof/test attendono il termine della seconda finestra prestazionale coordinata.

## Checkpoint 23: ordine C verificato con cancellazioni

- La libreria ufficiale C3.14.0 conferma esattamente quattro fixture dense/sparse: lane, zero strutturale, coda2 e coda3. Il nuovo probe adesione include le fixture sparse e le passa in validation e release.
- Corretto il grouping Sparse_Velocity; **440/440** rinnovati in ciascun profilo sulla stessa closure. Flow child fresco: **11 controlli**, zero aperti,11 warning conservati. I quattro file del kernel già provato303+43 sono identici per hash; ricevuta di riuso limitata a quei quattro Source_Files.
- Evidence attuale adesione in experimental/adhesion-contact-integration/evidence/recovery-order-20261003. La prima esecuzione dell’oracolo piccolo ha esaurito il limite durante l’avvio OpenBLAS; il driver seriale elimina quell’allocazione e passa con la stessa libreria ufficiale.
- La coda densa PCG è stata corretta e sono stati aggiunti gli stessi controlli esatti al probe integratori; nuova build in corso. Anche inverse/derivatives sono stati collegati al prodotto inverso ordinato e alla risposta condivisa, con rami denso/sparso espliciti e nuovi casi elliptic6. Build/confronti di questi cambi ancora pendenti.

## Checkpoint 24: PCG coda densa rinnovata

- Il probe integratori passa le fixture esatte C di cancellazione con code2/3. Build validation fresca e confronto completo **512/512** nuovamente passati dopo la correzione, su dipendenze comuni aggiornate. Tolleranze differenziali invariate.
- Evidence in experimental/integrators-candidate/evidence/recovery-order-20261003. La prova dei42 controlli Integration_Kernels non copre Dot/Solve PCG; composizione, warning C sul limite iterazioni e misure integrate restano pendenti.
- R21: estratto Initialize_Entry con post esatto sul prodotto e preservazione dei restanti elementi/bounds. Prova minima avviata per rendere esplicita la preservazione nel modello della massa, senza rafforzare artificialmente le precondizioni del chiamante.

### R21: modello della massa chiuso

Initialize_Entry minimo passa (7 proof check +1 flow), con prodotto esatto, frame completo e preservazione condizionale dei bounds. Usato in Model/Multiply al posto dell’assegnazione opaca per la composizione: il modello ora chiude tutti29 controlli riportati, comprese le due invarianti precedentemente aperte e il nuovo post shape/Work. Questa è una proprietà del modello e dei suoi bounds; la relazione finale Multiply = Model resta da verificare separatamente, senza dedurla dal successo del modello stesso.

La verifica minima Multiply conferma29 controlli riportati chiusi e1 post aperto, esattamente la relazione Value = Model. Il modello procedurale deve ancora essere esposto mediante una relazione di prefisso/composizione utile al loop eseguibile; non è un’eccezione matematica alla policy Gold. La nuova build runtime R21 contiene gli helper provati e le riduzioni C corrette; nessuna vecchia prova dell’unità completa è stata ereditata.

## Checkpoint 25: inversa allineata nelle pipeline correnti

- Build validation fresca PASS. Confronto completo **2848/2848 scenari** su712modelli,29072valori: include ora tutte55configurazioni adesione/attivazioni e i profili solimp attuali, oltre a smooth/manifold/tendini e attuazione mista.
- Risposta dei vincoli **412/412**,4682valori, errore assoluto esattamente zero rispetto a C. Quattro nuovi casi esercitano cancellazione delle lane, zero strutturale e code sparse2/3; driver e libreria ufficiale registrati per hash.
- L’inversa constrained preserva l’intero stato, non soltanto posizioni/velocità; il probe verifica anche array con origine nonzero, rifiuto atomico e modello sorgente già liberato.
- Ricevute della closure /var/tmp/sparkling-services-inverse-order-20261003 in experimental/inverse-dynamics/evidence/recovery-20261003. La relazione funzionale Multiply=Model resta separatamente aperta; proof dei piccoli kernel e unità completa in corso. R22 usa ora questa stessa inversa e risposta vincoli, con confronto ancora da eseguire.

Tutti i cinque minimi Inverse_Kernels passano e l’unità completa chiude **35 proof check +9 flow**, zero aperti e copertura SPARK completa. Il risultato riguarda Product/Accumulate/Required/Initialize_Entry/Scatter, con formule ordinate, bounds e frame; non prova il loop Multiply né la risposta completa dei vincoli. Build R22 avviata con dipendenze congelate aggiornate.

## Checkpoint 26: derivate collegate, residuo numerico isolato

- Build R22 con inversa ordinata e proiezione ellittica condivisa PASS. Nuovo corpus **297/300**, inclusi tutti72casi elliptic6 denso/sparso passati. Restano tre casi pyramidal già presenti nel salvataggio: PGS/CG/Newton, campione5, epsilon1e-7. Nessuna tolleranza modificata.
- Diagnosi sulle forze prima della differenza finita: scarto di5.68e-14/1.13e-13 su una riga e2.27e-13 su qfrcZ, poi amplificato da1/epsilon. Il trace comune espone Aref diverso di1.42e-14, mentre R coincide. Solve_Rows calcola J*qvel sequenzialmente, ma C usa la riduzione densa/sparsa a quattro lane. Ablation minima preparata solo in uno snapshot esterno; proprietario dynamics informato e file produttivo invariato.
- Ricevute iniziali in experimental/dynamics-derivatives-candidate/evidence/recovery-20261003. Non dichiarato completamento numerico o Gold delle derivate. Inventario pubblico aggiornato a27mappature candidate su630simboli includendo inversa e risposta vincoli con limiti espliciti.
- Nuova finestra prestazionale del coordinatore: il build ablation già attivo viene concluso; altri job pesanti attendono il via, mentre analisi/documentazione proseguono.

Ablation conclusa dopo la finestra: modificando **soltanto** la riduzione Velocity comune, il corpus passa **300/300** con le tolleranze originali. La causalità dello scarto FD è quindi riprodotta e risolta nello snapshot. Patch scoped constraint-velocity-order.patch e ricevute della stessa closure preparate per dynamics; l’applicazione produttiva e le prove della riduzione restano distinte.

## Checkpoint 27: causa corretta nel comune e kernel FD provati

- Dynamics ha applicato la patch Velocity al parent produttivo preservando weighted flex; ha aggiunto soltanto varianti di terminazione ai due while. La ricezione300/300 rimane attribuita allo snapshot ablation finché il nuovo build produttivo termina.
- Tutti sette kernel FD eseguibili e l’unità completa passano: **82 proof check +14 flow**, zero aperti e copertura completa. Within è una definizione booleana totale: la verifica minima genera solo2flow e zero obblighi aritmetici. Il runner inizialmente la segnalava fallita solo per il gate proof>0; ora registra esplicitamente questa definizione senza riclassificare flow in prove. Rerun Within PASS.
- Implementata la composizione FD con adesione nel workspace constrained: la creazione conserva entrambi i flag temporaneamente presi in prestito; le forze/attuazioni usano il produttore dei contatti nativo. Corpus aggiuntivo55configurazioni preparato, ancora da verificare. Build sulla closure comune corrente avviata.

### Diagnosi FD estese all’adesione

La prima composizione adesione passa941/960. Il corpus scopre una discrepanza reale in Nudge_Position: C normalizza il quaternione **prima** della moltiplicazione, il vecchio adapter lo normalizzava dopo. Corretto usando MJ.BLAS.Normalize4 e conservando il prodotto grezzo; nuova build/confronto **952/960**, senza tolleranze modificate. Gli otto residui riguardano solo Fq dei contatti fra corpi con antenato libero condiviso. Sul medesimo q perturbato in C, Aref/R coincidono e i coefficienti J dei due slide differiscono di2.22e-16: Apply_One_Joint usa una matrice, mentre C usa rotVecQuat. Una seconda ablation modifica soltanto quel helper nello snapshot, senza cambiare i file comuni produttivi.

## Checkpoint 28: derivate960/960 dopo allineamento geometrico C

- L’ablation di Apply_One_Joint sostituisce soltanto le tre rotazioni asse/anchor tramite matrice con MJ.Rotations.Rotate(quaternione), già presente nel port, come mji_rotVecQuat in engine_core_smooth.c. Nuovo corpus **960/960** (80modelli ×12campioni) passa, comprese tutte55configurazioni adesione e i contatti con antenati condivisi. Nessuna tolleranza modificata.
- Patch scoped joint-quaternion-rotation.patch e ricevute axis-ablation-* pronte per dynamics. Il helper di composizione e le prove del parent devono essere rinnovati; la prova82+14 dei kernel FD resta separata e su file identici.
- La produzione corrente aveva952/960 dopo il fix locale Nudge_Position; il960/960 appartiene alla chiusura ablation finché la patch centrale non viene applicata/verificata.

## Checkpoint 29: produzione inversa/derivate verificata insieme

- Build sulla closure produttiva aggiornata PASS, con fix Velocity, rotazioni giunti, weighted flex e dominio forza comune aggiornato. Stessa closure per tre probe. Derivate **960/960**; inversa **2848/2848** su712modelli,29072confronti.
- R21 ora rispetta E.Settings.Sparse; la proiezione trasposta salta le righe con forza zero come C. Confronti preparati separati denso/sparso: **412/412 ciascuno**,4682valori ciascuno, differenze esattamente zero, comprese cancellazioni e code.
- Evidence production-* in entrambe le directory. I quattro file kernel FD provati82+14 sono identici per hash alla nuova produzione; audit esplicito salvato. Prove globali della composizione restano aperte.
- R27: nove minimi e unità kernel passati, **13 proof check +10flow**. Cinque funzioni enum sono definizioni totali che generano solo flow, mantenuto separato; nessuna prova aritmetica inventata. Build controller sleep avviata.

## Checkpoint 30: sonno ricostruito nella pipeline smooth

- Controller nativo contro engine_sleep.c ufficiale: **1075/1075** casi,10438 operazioni. Build e hash sorgenti separati dalle precedenti ricevute.
- Pipeline smooth con stato posseduto: **39/39** modelli,2652 operazioni, comprese quattro tipologie di giunto,1/4/16 alberi, policy allowed/never/init, gravità, damping, reset, carichi e zero con segno. Il modello sorgente viene liberato prima del movimento.
- La composizione attuale è limitata ad alberi indipendenti smooth/Euler; vincoli/island producer, plugin, mocap e attivazioni non sono dichiarati collegati. Nessun benchmark conclusivo sotto carico concorrente.
- Aggiunto modello ghost esatto della visita limitata dei cicli; bounds del modello e reveal lemma passano ai minimi. Il contratto del loop eseguibile è in verifica e richiede nuova compilazione prima del rinnovo runtime. Copy_Sign mantiene il confine di traduzione formale aperto, senza nuovi corpi trusted.

## Checkpoint 31: visita cicli esatta, arresto coordinato

- Estratta MJ.Sleep_Cycles, usata dal manager tramite rename senza una seconda implementazione. Tutti i minimi e l’unità intera passano: **40 proof check +6 flow**, zero aperti, copertura completa. Il contratto segue esattamente i link, il minimo visitato, il ritorno a Start e il budget che rifiuta cicli malformati. Ghost/reveal verificati, nessun overhead ricorsivo runtime.
- Rafforzato Wake_Island: oltre al rifiuto atomico, contatore awake aggiornato esattamente con min(old,requested), frame completo in quel ramo, valore preciso dei nodi modificati e conservazione dei nodi già awake. Minimo **34 proof +5 flow**, zero aperti sul suo snapshot. Update è stato modificato dopo questa ricevuta; non viene dichiarata una nuova prova dell’intero manager corrente.
- Il primo minimo Update riportava cinque obblighi aperti. Invarianti di prefisso/conteggio e relazione esatta Body_Awake aggiunti; nuovo minimo **49 proof +2 flow**, zero aperti. I conteggi e i prefissi compatti completi richiedono ancora un modello funzionale più forte.
- Can_Sleep minimo riproduce l’errore del tool: `unbound function or predicate symbol Float64.copy_sign`. Ricevuta completa conservata. Nessun Assume, corpo trusted o soppressione aggiunto; il manager intero non è Gold.
- Build controller finale **PASS** su sorgenti attuali. Audit dei sei file effettivi di Sleep_Cycles identico fra prova intera, build e checkout. I risultati1075/1075 e39/39 appartengono invece alle closure precedenti: differenziale finale, nuovo driver edges.py e ricompilazione integrazione restano da eseguire. Il runner engine ora supporta --frozen per confrontare validation/release sulla medesima closure.
- Su indicazione del coordinatore, obiettivo globale in pausa: concluso il solo job già vivo, nessun altro job avviato. Tutte le nuove ricevute sono persistite in experimental/sleep-candidate/evidence/recovery-20261003. Nessun processo pesante servizi rimane attivo.

### Punto di ripresa dopo checkpoint31

1. R27: eseguire differential.py ed edges.py sul controller finale in /var/tmp/sparkling-services-sleep-controller-final-20261003; rinnovare build_engine e confronto39modelli, poi release sulla stessa closure. Rinnovare minimo Wake_Island dopo le modifiche a Update e proseguire le prove del manager senza aggirare Copy_Sign.
2. Verificare separatamente il rollback dei cache Previous_Pos/Previous_Quat/Have_Frame di MJ.Data.Sleeping.Step: l’analisi suggerisce che un errore dopo Capture possa perdere una perturbazione di posa al retry. È un’ipotesi non ancora riprodotta o corretta, non un risultato sperimentale.
3. R29: riprendere prove minime/intera, build validation/release e confronto dei passi indirizzi; il frontend MJCF/URDF e le altre fasi restano esplicitamente mancanti.
4. R14/R20: estrarre il controller attuazione da Advanced per usarlo con il Simulation già posseduto da constrained, evitando una seconda pipeline di pose. Dynamics informato dell’intento; nessuna patch comune preparata o applicata in questa fase.
5. R26 regressione comune recente, R25 mapping/setter, R21 relazione Multiply=Model, R28 success-frame e restante inventario API rimangono lavori aperti descritti nei checkpoint precedenti.

## Checkpoint 32: sonno finale rinnovato, rollback corretto

- Ripresa esplicita dell’utente dopo la pausa. Controller finale identico nei10file registrati; prima regressione1075/1075 C e532/532 rifiuti bounded PASS. Nuova closure comune r2 congelata include Pose_Arithmetic corrente e compila entrambi i probe.
- Riprodotta l’ipotesi del checkpoint31: **0/12** retry corretti prima della correzione, mentre stato pubblico e successo senza errore erano corretti. Capture consumava la perturbazione di posa anche quando il passo falliva per limite del tempo. Il rollback ripristina ora Previous_Pos, Previous_Quat e Have_Frame insieme allo stato e al sonno.
- Validation e release compilate dalla **stessa mappa sorgenti**: controller **1075/1075** ciascuno, integrazione **39/39** e2652operazioni ciascuna, nuovi casi rifiuto/ripresa **12/12** ciascuno. Rifiuti bounded controller release **532/532**. Nessuna tolleranza cambiata e nessun benchmark conclusivo. Ricevute in experimental/sleep-candidate/evidence/recovery-composition-20261003.
- Wake_Island minimo rinnovato dopo tutte le modifiche manager: **34 proof +5 flow**, zero aperti. Update49+2 e cicli40+6 restano su identici file rilevanti; composizione totale e Copy_Sign rimangono aperti, non ereditano Gold da questi risultati.
- Dynamics ha concordato il prossimo collegamento PID/DC/SO3: Controller indipendente da Simulation, nuovo child constrained con un solo Base.D, due piccoli hook parent da verificare frozen prima dell’applicazione. Estratto il controller nel mio spazio; primo build smooth del refactoring in corso, nessun hook comune applicato.

## Checkpoint 33: controller riusabile estratto, hook constrained preparati

- MJ.Data.Advanced_Control ora possiede soltanto configurazione, controlli, attivazione e output; Simulation viene passato dal chiamante. L’adapter smooth pubblico MJ.Data.Advanced mantiene la propria interfaccia e delega. Prima build r2 PASS e confronto completo **808/808** dopo l’estrazione, con tolleranze originali.
- Aggiunto Evaluation_State dimensionato ai soli output/attivazioni/DOF attivi. Capture/Restore conservano output e attivazione preparata; Evaluate e Step ripristinano il controller in caso di rifiuto e invalidano le cache della dinamica. Il post Restore specifica snapshot esatto e frame di controlli/attivazione pubblicata. Build r3 PASS dopo aver corretto i bounds dei discriminanti Ada; prove e nuovo confronto r3 ancora da eseguire.
- Scritto il child MJ.Data.Constrained.Advanced: un solo Base.D, controller separato, collisioni/assemblea/solver/Advance del parent. Dynamics ha concordato il disegno. advanced-factory-hooks.patch contiene soltanto Create_Core privato con selezione Dynamics_Only e dichiarazione privata Generate_Contacts. Il wrapper Create ordinario conserva il percorso normale. **Patch non applicata al comune; child non ancora compilato o validato.**
- Nuovi progetto constrained_advanced.gpr, probe e build_constrained.py preparati; il runner verifica hash base e applica i due hook soltanto alla copia frozen. I fixture vincolati e gli edge di rifiuto/ripresa sono il prossimo passo. Il controller continua a rifiutare le trasmissioni e metriche non ancora implementate, senza allargamenti silenziosi.
- Finestra benchmark r62/r12/C richiesta dal coordinatore: terminato il build r3 già vivo, **zero job pesanti servizi**, nessun nuovo build/prover/corpus fino al via. Evidence r2/r3 separata in experimental/advanced-step/evidence/recovery-controller-20261003. La finestra non modifica l’obiettivo globale, che rimane attivo.

### Ripresa dopo finestra del checkpoint33

1. Confronto r3 smooth808 e prove minime Capture_Evaluation/Restore_Evaluation, quindi unità/flow rinnovati; nuovo test Numeric_Limit/Invalid_Size e retry del controller.
2. Preparare corpus advanced constrained con flag warmstart/island disabilitati (dominio parent), limiti/frizione/contatti reali e PGS/CG/Newton; compilare la closure con hook frozen e testare prima minimi, poi corpus e regressione parent normale.
3. Inviare a dynamics la patch con ricevuta coerente soltanto dopo verifica. Nessun edit diretto dei due file comuni.


## Checkpoint 34: controller r3 verificato, slot assegnato a revisione C

- Confronto smooth sulla closure r3: **808/808** con tolleranze originali. Minimi Capture_Evaluation **14 proof +2 flow** e Restore_Evaluation **37 proof +1 flow**, zero aperti. Ricevute r3-compare/r3-state-proof in experimental/advanced-step/evidence/recovery-controller-20261003.
- Flow intero controller: **78 flow**, zero errori riportati, ma **gate coverage non superato e ancora da diagnosticare** (driver exit1); non dichiarato PASS né Gold globale. Ricevuta r3-flow preservata separatamente.
- Preparati compare_constrained.py, test export e advanced_edges/constrained_advanced_edges, progetto e builder constrained. Questi nuovi test e il child constrained **non sono ancora compilati o eseguiti**. Due hook parent rimangono soltanto in advanced-factory-hooks.patch, non applicati.
- Nessun job pesante servizi vivo. Per richiesta del coordinatore, lavoro servizi sospeso mentre questo slot esegue la revisione indipendente upstream C. Nessuna modifica annullata.
- Ripresa: diagnosticare gate flow; rigenerare hook/hash sulla nuova closure comune concordata con dynamics; compilare frozen; prima fixture PID a Stage_Advance rifiutato con rollback/riprova, poi collisioni/limiti/tendini/equality con PID/DC/SO3 e regressione parent. Inviare hook a dynamics soltanto dopo verifica. Il sorgente r3 verificato è /var/tmp/sparkling-services-advanced-controller-r3-20261003; nuove unità/test risiedono in experimental/advanced-step.


## Checkpoint 35: controller collegato nella closure CSR r13, scarto solver isolato

- Conclusa e salvata la revisione indipendente C SDF in plans/2026-10-03-upstream-sdf-second-review.md, senza modificare il vecchio dossier né pubblicare. Ripresa servizi autorizzata dal coordinatore.
- Diagnosi gate controller: la modalità flow termina normalmente con STOP_REASON_FLOW_MODE/PROGRESS_FLOW. Il runner richiedeva erroneamente STOP_REASON_NONE. Controllo ora distinto per modalità; nuova esecuzione **78 flow**, zero aperti e copertura SPARK completa. Nessuna safety/Gold globale dedotta dal flow.
- Build constrained avanzato validation **PASS**, sorgenti comuni esclusivamente dalla closure r13 immutabile (/var/tmp/sparkling-recovery-dynamics-20261003-13/integrated/source). Hook Create_Core/Generate_Contacts applicati solo alla copia frozen. Parent produttivo invariato. Nuovo builder registra origine e hash del manifest comune.
- Rifiuto Stage_Advance dopo Evaluate riuscito, rifiuto Invalid_Size, snapshot controller e stato pubblico, ripresa esatta rispetto al reset: **PASS** in smooth e constrained; quattro passi freschi confrontati anche con C. Minimi PID/DC con equality/tendini e SO3 connect/weld: **8/8**.
- Corpus completo su anchor fissi: **755/840**,85scarti. Ablation senza contatti chiude tutti i residui dei tre modelli isolati; togliere soltanto limiti o frizione non basta. Modello global_disabled ridotto eliminando TUTTI gli attuatori riproduce nel constrained_probe ordinario lo stesso scarto: Free/J/Aref/R esattamente C, ma qacc differisce0.1088395 al campione6, con forza C6.58e15. Artefatto comune affidato a dynamics; tolleranze invariate e corpus conservato aperto.
- Aggiunto un secondo corpus con basi libere e inerzia positiva, mantenendo quello degli anchor fissi. Minimi aggiuntivi **8/8**, completo in corso. Il collegamento parent non viene ancora presentato come verificato in tutti i casi. Evidence r13 separata in experimental/advanced-step/evidence/recovery-controller-constrained-20261003.


Il corpus mobile r13 conclude **839/840**: residuo unico so3_sites_expmap/campione4 in qacc8.60e-10, stato dopo100 passi1.05e-13. La regressione del parent ordinario con gli hook passa **106/106**. Dynamics conferma che il riordino del gradiente migliora il replay estremo ma non lo chiude; nessun risultato globale dichiarato.

Prova minima Evaluate controller: due obblighi aperti, precisamente shape necessaria a Restore_Evaluation e frame State_Values attraverso Evaluate_Into. Refactoring r2 in corso: Compute legge soltanto Simulation, la scrittura del campo Actuator/cache avviene nel chiamante dopo successo; contratti espliciti sul frame pubblico e sul ripristino Evaluation_State dopo rifiuto. Non altera formule/ordine floating-point. Primo build r2 fermato su attributi Old potenzialmente non valutati nel nuovo contratto privato, corretto usando congiunzioni totali; rebuild in corso. Nuove prove/runtime ancora da eseguire; r1 rimane immutata e documentata.


## Checkpoint 36: refactoring controller r2 verificato, composizione ancora aperta

- Nuova build validation su r13 immutabile PASS. Compute legge Simulation; la pubblicazione Actuator/cache è nel chiamante soltanto dopo successo, senza cambiare formule o ordine numerico. Confronto smooth **808/808** e rollback/riprova smooth+constrained PASS.
- Replay degli stessi input persistiti: **105/105 modelli fissi e105/105 mobili byte-identici** ai rispettivi output r1. Questo conserva i risultati differenziali **755/840** e **839/840**, non trasforma i residui in successi. Hash degli input/MJB/binari/output e riferimento salvati.
- Prova minima modulare Evaluate_Into: **20 proof +1 flow chiusi,3 aperti** (conversione Length di External, Stable_Ready dopo pubblicazione forza, post frame del controller). Evaluate: **1 proof +2 flow chiusi,1 post aggregato aperto**; la precondizione shape di Restore ora chiude. Il precedente tentativo Evaluate_Into ha esaurito guard180s senza report completo, conservato senza conteggi inventati.
- Evidence r13-r2-* in experimental/advanced-step/evidence/recovery-controller-constrained-20261003. Nessuna prova globale/Gold attribuita alla composizione né hook applicati al parent produttivo. Prossimi passi: release sulla stessa closure, poi minimi di pubblicazione/frame con nuovo snapshot se serve; diagnostics solver estremi restano a dynamics.
- Gli altri 12 incarichi mantengono stato e limiti dell'inventario dei checkpoint precedenti; nessun avanzamento dedotto da questo collegamento.


Release r13-r2 conclusa sulla stessa mappa sorgenti: **808/808** smooth, edge smooth+constrained PASS e **105/105+105/105** modelli constrained byte-identici ai due corpus validation r1. Conservati gli stessi86residui differenziali complessivi. Nuovo helper locale Publish_Forces in prova minima su r13-r3 separato; il nuovo sorgente non eredita queste ricevute runtime.


## Checkpoint 37: hook produttivi applicati, rinnovo sulla forza C r14

- Dynamics ha applicato i due hook Create_Core/Generate_Contacts dopo revisione e backup. Entrambi i parent live coincidono per SHA con r14 immutabile più la patch rigenerata; nessuna modifica comune diretta dei servizi. Nuova build advanced su r14 in corso.
- Replay ordinary senza attuatori rinnovato sul binario r14: **4/8** campioni passano con tolleranze originali; il campione6 ha qacc0,0136958321, forza1ULP, qfrc0,125 e scarto di stato dopo100 passi5,369e-6. Free/J/Aref/R sono esatti. Gli altri tre residui riguardano soprattutto la traiettoria; nessuna chiusura anticipata del caso ball/plane. Nuovo replay_common.py registra SHA di input/MJB/binario/driver.
- Publish_Forces ora separa l'ammissione e pubblicazione della forza, preservando stato e input; il gate della lunghezza usa Int64 senza restringere il dominio. Prove minime r3/r4/r5 conservate: ultima **22 proof +1 flow chiusi,2 aperti**, precisamente frame State_Values e bounds della nuova cache. Layout/Stable_Ready chiusi. Nuova variante scompone i post e usa i lemma di uguaglianza delle immagini già presenti; ancora non verificata. Nessuna assunzione o nuova implementazione trusted.
- Evidence r13-publication-proof-r3/r4/r5 e r14-common-replay conservata. Gli altri incarichi restano agli stati dei checkpoint precedenti; runtime r13-r2 non attribuito alla nuova variante.


## Checkpoint 38: controller avanzato rinnovato sulla centrale r14

- Build validation con parent r14 più hook produttivi e helper Publish_Forces PASS. Gli hash dei due parent frozen coincidono con la produzione verificata al congelamento. Smooth **808/808**, rifiuti/riprova PASS, minimi equality/tendini/SO3 **8/8**, parent ordinario **106/106**.
- Corpus anchor fissi **794/840**: la nuova forza e il solver comuni chiudono39 dei precedenti85 scarti. Restano46 casi. Corpus mobile **839/840**, unico residuo so3_sites_expmap/sample4 ancora presente. Tolleranze invariate; la composizione resta parziale.
- Ricevute r14-r1-* persistite con manifest e hash. Prova minima Publish_Forces avviata sulla stessa closure, con post separati e lemma esatti sulle immagini; nessuna prova funzionale globale dedotta dal differenziale. Release della nuova closure e minimi Evaluate restano da rinnovare.


### Correzione geometria SO3 dopo checkpoint38

- Individuata una discrepanza effettiva in Log: C3.14.0 usa un reciproco condiviso per normalizzare l'asse e conserva la norma nel fallback tiny. Il commento Ada recuperato era errato; corrette entrambe le operazioni. Il confronto esatto mirato migliora **218/559 →416/559**; tutti i primi41 casi di fallback/bordo scelti passano esattamente. I143 residui esatti restano dichiarati: il runtime GNAT Local_Atan riduce per rapporto e chiama atan, diversamente da atan2 C. Nessun nuovo binding/trusted aggiunto.
- Il corpus kernel completo passa ancora **4836/4836** con le tolleranze originali. Sorgenti C e runtime GNAT registrati per hash; evidence separata recovery-log-20261003. Build integrated r14-r2 in corso, quindi il residuo mobile non è ancora dichiarato chiuso.
- Il minimo Publish_Forces r14-r1 termina con **GNAT Storage_Error stack overflow** e senza .spark completo; conserva diagnostiche e nessun conteggio finale. Runner aggiornato a stack64MiB, già adottato nel runner kernel; prossimo rerun manterrà limiti memoria/tempo. L'obbligo sul bound della cache resta visibile nelle diagnostiche parziali, nessun claim Gold.


## Checkpoint 39: origine del residuo mobile separata dal controller

- Build r14-r2 con Log corretto PASS. Sullo stesso so3_sites_expmap/sample4 persistito, lunghezza, velocità, forza e forza generalizzata del controller diventano **esattamente C**. Qacc resta diverso di7,2889e-10 e stato100 passi1,2469e-12; non dichiarato superamento del test di accelerazione.
- Replay ordinary senza attuatori, con la forza generalizzata originale sommata una volta all'ingresso applied: C ordinary coincide esattamente con C controller per free/J/aref/R/force/qfrc/qacc. Ada ordinary riproduce lo stesso scarto, con free9,00e-12, J5,55e-17 e aref7,11e-15. Consegnati a dynamics modello, input originale, provenienza forza, matrice massa C completa, problema solver e hash. Nessuna forza C inserita nella produzione.
- Publish_Forces estratto senza modifica delle operazioni nella piccola unità privata MJ.Data.Controller_Forces; prova minima sulla closure separata avviata con stack64MiB. Il nuovo adapter ancora non eredita una prova funzionale globale né la ricevuta runtime r14-r2. Corpus completo dopo il fix Log e release restano da rinnovare; gli altri incarichi conservano stati e limiti precedenti.


## Checkpoint 40: pubblicazione controller provata al minimo

- Isolata MJ.Data.Controller_Forces senza cambiare l'ordine runtime di copia/cache. Prove minime **Prove_Array_Bounded11/11** e **Publish35 proof +1 flow**, zero aperti e copertura completa, sulla closure isolated5 r14. Il helper conserva Ready, shape, stato e input; sul successo pubblica esattamente Values e invalida la forza precedente. Il lemma del predicato è verificato, non assunto. Verifica dell'unità completa in corso.
- Conservati anche i tentativi precedenti: annotazione Unhide in posizione non ammessa, parametro access incompatibile con ghost borrowing e due post/assert aperti. Questi fallimenti non sono riclassificati come prove; la versione finale usa un osservatore Simulation e un lemma locale.
- Set_Activation ora confronta lunghezze in Int64 e usa una copia di slice; aggiunto contratto esatto della copia, frame e rifiuto atomico. La sua prova e il rinnovo runtime attendono l'esito whole. L'adapter che chiama la nuova unità non eredita ancora i test r14-r2.
- Il builder supporta esplicitamente --factory-hooks present per future closure già integrate: registra gli hash senza riapplicare la patch. Nessun file comune modificato. Gli altri incarichi mantengono lo stato precedente.

La prova whole isolated5 termina con **45 proof +1 flow chiusi e un post di frame aperto**: State_Values invariato. Il minimo Publish era chiuso sulla stessa closure; l'unità completa resta aperta. CVC5 timeout5s e Z3 memoria700MiB sono registrati nella ricevuta; rerun identico con15s/1200MiB avviato, senza modificare contratti o sorgenti della closure. Transmission e Stage ora ricevono soltanto i campi mutabili Rows e Next_Act/Can_Advance; nuovo snapshot caller separato, ancora da verificare.

## Checkpoint 41: unità di pubblicazione controller chiusa

- Rerun whole sulla stessa closure isolated5 r14: **46 proof +1 flow**, zero aperti e copertura completa. L'aumento esplicito15s/1200MiB chiude l'ultimo frame dello stato; nessuna modifica a contratti, assunzioni o formula. Minimi11 e35+1 già chiusi sulla stessa sorgente. La proprietà include forza pubblicata esatta sul successo, Is_Ready, shape, stato e input invariati.
- Avviate serialmente le prove minime Set_Activation, Evaluate_Into ed Evaluate sulla nuova closure caller. Transmission/Stage hanno ora parametri limitati ai soli campi scritti, senza cambi di ordine numerico. Risultati ancora pendenti, così come runtime completo e release dopo estrazione/Log.
- Il replay mobile ordinario è affidato a dynamics insieme al ball/plane. Si attende la nuova closure comune con aggiornamento Cholesky incrementale e ricerca del passo per rinnovare entrambi i corpus840; i vecchi scarti restano registrati fino alla verifica integrata. Gli altri 12 incarichi conservano stati e limiti dei checkpoint precedenti.

## Checkpoint 42: copia attivazione provata, caller ancora in corso

- Set_Activation minimo sulla closure caller3: **7 proof +2 flow**, zero aperti, copertura completa. Successo copia esattamente As_Reals(Values); dimensioni/controlli/Ready invariati; rifiuto conserva attivazione e Evaluation_State. Prima conversione fra componenti di sottotipo diverso non compilava; il successivo aggregato for-of era compilabile ma non supportato da GNATprove. Entrambi i tentativi sono conservati, nessun bypass; la versione finale usa il modello As_Reals già esistente con indici espliciti.
- Evaluate_Into caller3 raggiunge il watchdog240s senza .spark completo (picco1979MiB). Nessun conteggio di prove finali attribuito; Evaluate non eseguito dopo il guard. Nuova caller4 separa le stesse sette clausole di frame e mantiene opachi i corpi delle immagini/predicati già usati modularmente nella pubblicazione. Prova minima in corso; Compute e composizione completa non dichiarati chiusi.
- Esposte nel contratto pubblico Evaluate anche le dimensioni della capsula salvata: servono ai rifiuti successivi nel child constrained. Preparato runner seriale riproducibile dei corpus su binari/sorgenti frozen, con hash della libreria C. La closure comune r15 è immutabile; si attende la sua validazione centrale prima del rinnovo advanced validation/release.
- Nessun nuovo runtime dopo estrazione/Log attribuito ai vecchi test. Gli altri 12 incarichi mantengono stati e limiti descritti in precedenza.

La caller4 termina con GNAT Storage_Error (stack overflow/accesso erroneo, posizione finale del body), anche con stack64MiB. Non produce .spark completo: diagnostiche parziali non promosse a conteggi o a chiusura. Ricevuta integrale preservata; unico rerun diagnostico della stessa sorgente con stack256MiB, guard300s, memoria prover900MiB in corso.

Il rerun caller5 sulla stessa sorgente ripete GNAT Storage_Error anche con stack 256 MiB; nessun .spark completo e nessun risultato finale inventato. L'errore è preservato in r14-caller-proof5-gnat-storage-error. La closure centrale r15 ha completato validation/release (manifest cf08f2fe79c2f534277f373713a0fb989fb5e72971da98047bd5a3f9177794da); nuova build advanced r15-r1 avviata con hook già presenti, senza modifiche comuni. Si privilegia ora il rinnovo runtime completo, conservando il difetto del prover come lavoro aperto.

## Checkpoint 43: rinnovo advanced sulla centrale r15

- Build validation PASS sulla closure comune r15 immutabile, con hook già presenti. Sono inclusi Log corretto, unità Controller_Forces, copia As_Reals e parametri mutabili limitati; questa è la prima ricevuta runtime della composizione corrente. Rifiuti/riprova smooth e constrained PASS, minimi equality/tendini/SO3 **8/8**, smooth **808/808**, parent ordinario **106/106**.
- Corpus fissi **794/840** e mobili **839/840**, tolleranze originali. Nel replay ball/plane global_disabled/sample6 l'accelerazione iniziale è ora **esattamente C**, ma la traiettoria di 100 passi scarta 7,98e-5. Nei fissi restano 46 scarti di stato e 20 di accelerazione (prima 21); global_disabled/sample4 chiude, so3_reanchor_expmap/sample0 apre uno scarto di stato. Nessuna equivalenza globale dedotta dall'invarianza del totale.
- Mobile so3_sites_expmap/sample4: lunghezza, velocità, forza, forza generalizzata e derivata sono esatti C; accelerazione scarta 7,2889e-10, stato dopo 100 passi 8,79e-13 passa. Residuo comune già riprodotto senza attuatori, ora segnalato a dynamics con i nuovi numeri.
- Release in compilazione sulla stessa mappa sorgenti. Dopo il confronto seriale si preparano replay ordinari SO3sites mirati; i valori C resteranno soltanto input diagnostici. Prove caller ferme al GNAT Storage_Error documentato, senza Gold globale. Gli altri 12 incarichi mantengono stati e limiti precedenti.

## Checkpoint 44: release r15 e replay ordinari confermati

- Release della stessa closure r15-r1: rifiuti/riprova PASS, **8/8** minimi, **808/808** smooth, **794/840** fixed, **839/840** mobile, **106/106** parent. Tutti i record numerici dei cinque corpus sono identici fra validation e release; restano 47 casi complessivi aperti, con le tolleranze originali. Nessuna misura prestazionale conclusiva.
- Nuovo replay_controller_force.py conserva gli input del controller e aggiunge una sola volta la forza C a applied dopo aver tolto gli attuatori. I quattro casi scelti conservano **esattamente** la valutazione C originale, inclusi massa, free, J, aref, R, forza, qfrc e qacc. È un replay istantaneo diagnostico, non una traiettoria con forza costante equivalente. Nessun valore C entra nella produzione.
- Gli stessi scarti qacc persistono nell'ordinary Ada: fixed SO3 quat/1 **5,493e-4**, expmap/3 **8,3238e-3**, vel/1 **5,0266e-3**, mobile expmap/4 **7,2889e-10**. Nei fixed le differenze iniziali free sono circa 5–9e-14, J circa 1–3e-17, R esatto. Tutti gli artefatti e la provenienza della forza sono stati consegnati a dynamics.
- Prossima decomposizione caller: separare la preparazione di Simulation dal record Controller, mantenendo i sette frame. Nessun ulteriore aumento dei limiti sul crash GNAT. Whole Controller_Forces r14 non è estesa alla r15: occorre ricevuta rinnovata. Gli altri 12 incarichi e gli obblighi globali mantengono gli stati precedenti.

## Checkpoint 45: Expmap tiny esatto, preparazione controller scomposta

- Collegata soltanto la componente coseno di Expmap a MJ.Trigonometry.Cosine, fornita da dynamics. Divisioni per norma e fallback identità restano quelli di expmap2Quat C; nessun riuso erroneo del diverso algoritmo quatIntegrate. Test indipendente composto dalle API C norm3 e axisAngle2Quat: **1508/2222 → 2222/2222 bitwise**, inclusi1710 casi tiny/bordo. Corpus completo kernel **4836/4836** validation, stesse tolleranze. Ricevuta frozen geometry-expmap-fix, evidence recovery-expmap-20261003.
- La nuova specifica esprime anche il modello FP esatto Expmap; prove minime in corso su snapshot separato geometry-expmap-contract, quindi non eredita automaticamente la ricevuta del primo binario. Il confine standard Sqrt/Sin/Cos e i warning restano espliciti; nessun binding/trusted nuovo.
- Prepare separato da Controller: minimo con cinque assert Ready chiude9 proof +1 flow, un post State_Values aperto. Con immagini ghost/lemma iniziale chiude17+1 ma restano due assert di frame e il post. Nuova variante usa il lemma verificato delle immagini dopo ogni fase, ancora da provare. Nessun ulteriore aumento limiti per il crash GNAT del caller.
- Dynamics ha completato r16 validation/release sulla stessa closure comune; prossimo rinnovo advanced userà quella closure, includendo il helper Prepare e Cosine. Restano dichiarati i47 residui r15 e i caller aperti finché non eseguiti nuovi corpus. Gli altri12 incarichi mantengono i limiti precedenti.

Il confine Sqrt è stato verificato direttamente nel runtime: il contratto esplicito espone positività/zero/uno, non un bound superiore. Un rename dell'identica istanza generica alla unità standard non ha cambiato gli esiti ed è stato rimosso. Il modello funzionale Expmap conserva l'espressione FP esatta; il bound superiore della norma, che riguarda anche il modello di accuratezza Sqrt, resta un obiettivo separato non dimostrato.

La patch scoped Cosine estende soltanto il dominio a tutto Real finito: minimo e whole **9 proof +2 flow** chiusi con 5 warning imprecise-call Ada.Cos conservati (strict_passed=false). Probe hostlibm **4096/4096 bitwise**,1887 input oltre il vecchio limite, inclusi±Real'Last. Patch consegnata a dynamics; r16 originale immutata. I minimi Expmap_Term8+1, Norm3 7+1 e modello9+1 chiudono; il post esatto del chiamante resta aperto nel tentativo terms, nuova variante con costruttore norm condiviso in corso.

Barriera benchmark root rispettata: handle53143 terminato, nessun job servizi vivo. La variante terms2 chiude Term8+1, Norm7+2 e modello9+1; il chiamante Expmap7+2 mantiene1uguaglianza finale aperta. Variante terms3 pronta con seno nominato identico nel corpo/modello, non eseguita durante la finestra. Anche Prepare/components4 è preparata ma la sua minima successiva non è ancora stata lanciata.

## Checkpoint 46: advanced r16 ricomposto e validato

- Build validation PASS da centrale r16/integrated-pose (manifest89f46e8d...) più la sola estensione di dominio Cosine applicata da dynamics (SHA2597c410...). Le formule comuni restano quelle r16; sorgenti avanzate includono Log, Expmap con costruttori scalari/norma/seno, Prepare. Nessuna patch al parent comune in questo passaggio.
- Edge smooth/constrained PASS; minimi equality/tendini 8/8, smooth 808/808, parent 106/106. Fixed **800/840**, mobile **839/840**. Si chiudono 6 vecchi residui fixed senza nuovi: global_disabled/2, pid_ball_00_0/0, pid_ball_00_1/0, pid_ball_01_0/0, pid_ball_01_1/0, so3_reanchor_expmap/0. Restano 40 scarti di stato,20 anche qacc; mobile unico qacc7,288916137e-10, stato100 passi2,54e-13 passa. Tolleranze invariate.
- Global_disabled/6: qacc iniziale esatto, traiettoria ancora4,18e-5. Nessuna equivalenza globale dichiarata. Dati completi e confronto r15 in r16-validation e /var/tmp/sparkling-services-advanced-regression-r16-validation-20261003. Release sulla stessa mappa sorgenti in compilazione.
- Preparata in closure separata components1-r16 l'estrazione della sola copia Publish in MJ.Controller_Array_Kernels.Copy_Prefix, con post componente per componente e frame della coda. Serve a evitare il punto del precedente crash GNAT sul record Controller; non è inclusa nel binario r16-r1 appena testato, né è ancora provata.
- Gli altri 12 incarichi e gli obblighi funzionali della composizione mantengono stati/limiti precedenti. Nessun timing durante carico concorrente.

Release r16-r1 completata: edge PASS,8/8 minimi,808/808 smooth,800/840 fixed,839/840 mobile,106/106 parent. Tutti i record numerici dei cinque corpus sono identici validation/release, stessa mappa sorgenti ricontrollata. Restano41 casi aperti. Ricevute r16-release e profile-comparison.json salvate; nessuna misura prestazionale dedotta dai tempi del runner.

## Checkpoint 47: Expmap FP minimo e kernel aggiornato

- Term8 proof +1 flow, Norm7+2, Sine2+2, Model6+1, Expmap7+2: tutti i minimi terms3 chiusi, zero obblighi aperti. Expmap conserva il post esatto rispetto al modello FP, inclusi fallback identità e ordine divisione poi moltiplicazione. Costruttori di norma/seno comuni a corpo/modello evitano l'espansione ripetuta dei primitivi. Nessuna assunzione/binding/trusted aggiunta.
- Il bound superiore della radice resta un obiettivo separato non dimostrato; non è richiesto dal modello FP. Il contratto standard della radice espone positività e casi zero/uno. La prova non dimostra accuratezza dei primitivi né equivalenza universale a libm; Cosine conserva 5 warning imprecise-call registrati nelle proprie ricevute.
- Sulla medesima closure terms3, build validation/release e **2222/2222 bitwise +4836/4836** corpus in entrambi profili. Le unità Ada kernel/comuni richieste coincidono per hash con il runtime advanced r16-r1, come registrato in advanced-source-equivalence.json; nessuna prova della composizione dedotta da questa equivalenza.
- Seconda barriera quiet root: handle59646 terminato, nessun job servizi vivo. Whole geometry ancora non avviata; Copy_Prefix e i caller restano in coda. I41 residui advanced restano espliciti; gli altri 12 incarichi mantengono lo stato e i limiti precedenti.

Whole Geometry sulla stessa terms3 raggiunge il watchdog300s (picco220MiB), senza .spark completo: nessun conteggio finale attribuito. Il tentativo è conservato in whole1-watchdog. Rimangono validi soltanto i minimi nei rispettivi scope; ripresa diagnosi caller con Copy_Prefix minimo sulla closure components1-r16.

## Checkpoint 48: copia della pubblicazione controller provata al minimo

- Copy_Prefix minimo sulla closure components2-r16: **12 proof +1 flow**, zero aperti e copertura completa. Post: copia esatta dei primi Count elementi e conservazione esatta della coda. Il primo tentativo chiudeva già il post ma lasciava due conversioni implicite di Length a Natural aperte; comparazioni ora in Int64, senza restringere il dominio degli array.
- La chiamata sostituisce la copia tra due campi del grande record Controller nel punto dell'errore GNAT precedente. Il nuovo helper è ancora distinto dalla closure runtime r16-r1; whole/helper, Prepare, caller e rinnovo runtime restano da eseguire.
- Terza finestra quiet root: handle96404 terminale, nessun job servizi attivo. Ricevute min1/min2 conservate. Gli altri 12 incarichi mantengono stato e limiti precedenti.

Whole Copy_Prefix sulla medesima components2-r16 chiude **12 proof +1 flow**, zero aperti, copertura completa e zero warning. Minimo Prepare avviato subito dopo, serialmente; nessun nuovo runtime attribuito a questo refactoring finché non ricompilato e confrontato.


## Checkpoint 49: Prepare modulare, due frame interni ancora aperti

- Il tentativo precedente Prepare/components2 raggiunge watchdog240s senza report completo; ricevuta conservata, nessun conteggio finale. Nuova scomposizione components3 separa invalidazione cache, aggiornamento pose/Jacobiani e costruzione forze, mantenendo operazioni e ordine.
- Minimo Invalidate_Actuation **14 proof**, zero aperti. Minimo Prepare **4 proof +1 flow**, zero aperti: compone i contratti degli helper. Ensure_Poses e Compute_Forces chiudono ciascuno **2 proof +1 flow** ma conservano ciascuno **un post State_Values aperto**. Copertura completa nei quattro minimi, nessun warning; la composizione completa resta non verificata perché quei due contratti interni non sono chiusi.
- Ricevute, hash e sorgenti in r16-prepare-stages-min. Copy_Prefix resta verificato minimo/whole12+1 sulla propria closure. Il nuovo refactoring non eredita i corpus runtime r16-r1: rinnovo necessario dopo gli ultimi helper/caller. Restano41 residui avanzati numerici e gli stati/limiti degli altri12 incarichi.
- Quarta finestra quiet: handle68902 terminale, zero heavy servizi, ACK inviato al coordinatore; nessun nuovo job prima del rilascio. Prossimo passo: isolare il frame State_Values nei due helper, poi riprovare Evaluate_Into con Copy_Prefix e rinnovare runtime sulla medesima closure.

Il tentativo Compute_Forces con immagini dei componenti raggiunge watchdog240s senza report completo, salvato come r16-prepare-compute-watchdog2. La variante components5 usa State_Values opaco, snapshot prima delle due fasi e il lemma esistente Equal_Transitive: minimo Compute_Forces **4 proof +1 flow**, zero aperti, copertura completa e zero warning. Ensure_Poses sullo stesso schema è in verifica; non ancora dichiarato chiuso né estesa la prova al caller.


## Checkpoint 50: frame interni di Prepare chiusi ai minimi

- Ensure_Poses/min2 chiude il frame State_Values ma conserva un solo post Input_Values aperto. Aggiunta la medesima transitività per gli input: Ensure_Poses/min3 sulla components6 chiude **5 proof +1 flow**, zero aperti, copertura completa e zero warning. Compute_Forces/min3 era **4 proof +1 flow** chiusi; Invalidate_Actuation **14 proof** e Prepare modulare **4+1** chiusi sulle rispettive snapshot.
- La soluzione compone osservatori opachi e il lemma esistente MJ.Smooth_Kernels.Equal_Transitive dopo la seconda fase. Non cambia runtime, condizioni d'ingresso o frame; nessuna assunzione/trusted aggiunta. Il tentativo sui componenti resta archiviato come watchdog.
- Prossimi passi: rinnovo minimo del lemma comune e whole Controller_Dynamics su components6, poi Evaluate_Into con Copy_Prefix. Ancora nessun claim whole/controller o rinnovo numerico attribuito a questi edit. R18 comune immutabile ricevuta da dynamics; il runtime avanzato sarà rinnovato dopo la prova dei caller. Restano41 residui r16 e lo stato invariato degli altri12 incarichi.

Rinnovo Equal_Transitive comune sulla components6: **1 proof +1 flow**, zero aperti. Whole Controller_Dynamics: **26 proof +3 flow chiusi,1 post State_Values aperto nel compositore Prepare**; tutti i frame interni passano anche nella stessa esecuzione intera. Nessun Gold whole. Preparata components7 con transitività esplicite nel compositore; minimo in corso.


## Checkpoint 51: intera preparazione controller verificata

- Prepare/components7 con transitività esplicite: minimo **8 proof +1 flow**, zero aperti. Whole MJ.Data.Controller_Dynamics sulla medesima closure: **31 proof +3 flow**, zero aperti, zero warning, copertura SPARK completa. Readiness, dimensioni, stato e input preservati in tutte le fasi della preparazione; nessun contratto indebolito o nuova assunzione/trusted.
- Il lemma comune Equal_Transitive usato nella composizione ha ricevuta minima fresca **1+1** sulla components6; i suoi due file sono identici in components7 e r18. Ricevute whole2, minimi, sorgenti e ricontrollo hash salvati. Il precedente whole con un post aperto resta conservato separatamente.
- Scope limitato alla preparazione e ai suoi frame, usando i contratti esistenti delle fasi comuni. Non equivale alla prova dell'intero controller né del comune. Evaluate_Into in prova minima sul medesimo frozen, con Copy_Prefix già provato; runtime r18 sarà rinnovato dopo i caller. Restano41 residui avanzati r16 e tutti i limiti degli altri12 incarichi.

Evaluate_Into/components7 termina con GNAT Storage_Error sulla dichiarazione Copy_Prefix (mj-controller_array_kernels.ads:4),144,8s/picco1924MiB, senza .spark completo. Diagnostiche parziali e tre warning di handler irraggiungibile conservati, nessun conteggio finale assegnato. Isolata l'opzione Inline_Always: la components8 usa Inline ordinario, corpo e contratto identici; minimo e whole Copy_Prefix entrambi **12 proof +1 flow**, zero aperti/warning. Riprova caller in corso, senza aumento di stack/budget.

La variazione Inline non evita il medesimo Storage_Error di Evaluate_Into, ancora senza .spark finale. Ablation negativa conservata in r16-evaluate-into-crash2; ripristinato Inline_Always originale nella produzione, senza cambiare corpo o contratto. Nessun ulteriore incremento dei limiti. Il prossimo rinnovo numerico userà r18/original-force immutabile e la preparazione con whole31+3; il caller rimane aperto.


## Checkpoint 52: controller rinnovato sulla forza originale r18

- Build validation su r18/original-force immutabile (manifest1a7ce220...) più Prepare scomposto e Copy_Prefix produttivi: PASS. Rifiuto/ripresa smooth+constrained PASS, minimi equality/tendini/SO3 **8/8**, smooth **808/808**, parent **106/106**. Prima ricevuta runtime di questi refactoring; hash ricontrollati.
- Fixed **803/840**, mobile **839/840**, input e tolleranze originali. Fixed chiude global_disabled/0,/6 e pid_ball_10_0/0,pid_ball_10_1/0, ma apre so3_joint_vel_0/6 (stato1,410792e-6; accelerazione iniziale esatta). Quest'ultimo prima passava con stato1,764164e-10: regressione conservata. Global_disabled/6 ha ora accelerazione e stato100passi **esattamente C**.
- Restano37 scarti fixed di stato,20 anche di accelerazione; mobile unico so3_sites_expmap/4 con qacc7,291807e-10, stato3,775869e-13 passa. Output iniziali del controller mobile esatti C. Totale **38 casi aperti**, nessuna equivalenza globale dichiarata.
- Release compilata sulla stessa mappa sorgenti; corpus in corso. Evidence r18-validation e confronto r16 salvati. Whole Prepare31+3 rimane attribuita alla sua closure components7-r16, caller Evaluate_Into ancora aperto per errore GNAT; gli altri12 incarichi conservano i limiti precedenti.

Release r18-r1 terminale sulla medesima mappa: edge PASS,8/8 minimi,808/808 smooth,803/840 fixed,839/840 mobile,106/106 parent. Tutti i record numerici dei cinque corpus sono **identici fra validation e release**, sorgenti ricontrollate immutate.38 residui conservati, inclusa la nuova regressione so3_joint_vel_0/6; nessuna misura di performance ricavata dai tempi dei runner.

Whole Geometry terms3 con soloCVC5/1s per check/no-inlining termina in145s con report completo: **198 proof +30 flow chiusi,82 aperti,19 warning** conservati. È un inventario diagnostico a budget ridotto, non Gold né revoca dei minimi Expmap già chiusi con diverso budget. Dettaglio per sottoprogramma in recovery-expmap-20261003/whole2-inventory/open-by-subprogram.json; la precedente whole/watchdog resta separata.


## Checkpoint 53: inventario geometria e primi minimi Normalize

- Whole diagnostica terms3 a1s/check:198 proof +30 flow chiusi,82 aperti,19 warning, copertura completa. Gli aperti sono conservati per sottoprogramma; non è una prova whole e non sostituisce i minimi Expmap precedenti.
- Normalize originale a5s/tre prover:14 proof +2 flow chiusi,1post aperto. Nuova scomposizione mantiene norma nell'ordine C, un reciproco condiviso e quattro prodotti, oltre a fallback tiny e ramo near-unit. Minimi Normalize_Norm9+2, Normalize_Reciprocal6+2, Normalize_Term3+2, Model_Normalized7+1 chiusi; Normalize5+2 mantiene1post aperto. Warning standard conservati e strict_passed resta false dove presenti; nessuna equivalenza matematica universale per Sqrt dichiarata.
- Nuova geometria non ancora compilata/confrontata: non eredita i corpus runtime r18. Preparato soltanto un edit locale Hide_Info sui corpi expression-function per comporre i contratti già provati; prossimo minimo dopo quiet.
- Barriera benchmark LDL: handle62528 terminale, zero heavy, ACK al root.38 residui advanced r18 e caller GNAT restano aperti; altri12 incarichi con limiti precedenti.


## Checkpoint 54: Normalize FP composto e runtime verificati

- La sola opacità dei helper (terms2) lascia ancora un post aperto; tentativo min3 conservato. Terms3 introduce Normalize_Value puro con i tre rami C espliciti, usato da corpo e modello. Stessa norma ordinata, un solo reciproco e quattro prodotti, fallback tiny e ramo near-unit invariati; nessuna assunzione/trusted o dominio ristretto.
- Sulla medesima closure terms3 chiudono tutti i minimi: Normalize_Norm **9 proof +2 flow**, Reciprocal **6+2**, Term **3+2**, Value **7+2**, Model_Normalized **3+1**, Normalize **4+1**. Zero obblighi aperti e copertura completa. Restano10 warning standard per target,11 per Norm: strict_passed=false; non si attribuiscono accuratezza universale a Sqrt né norma matematica unitaria. L'unità Geometry intera e i caller rimangono aperti.
- Build validation/release PASS sulla stessa mappa sorgenti, ricontrollata. Normalize **4968/4968 bitwise C** (872 mirati a bordi/tiny e4096 casuali), Expmap **2222/2222 bitwise**, corpus completo kernel **4836/4836** in entrambi i profili. Record identici fra profili. Evidence in recovery-expmap-20261003/normalize-min3,min4,min5,normalize-runtime. Questa nuova geometria non è ancora nel binario advanced r18-r1.
- Traccia so3_joint_vel_0/6 sul binario r18-r1 già verificato: prima differenza bitwise dello stato al passo13, primo scarto oltre tolleranza al passo64, finale100 invariato1,410792e-6. Rivalutando101stati C con reset, tutti gli output passano; force/qforce differiscono al massimo1,39e-17, qacc2,59e-10 entro la tolleranza relativa. R16 sugli stessi input mostra un primo scarto transitorio al passo88, pur passando al passo100: il precedente test finale non garantiva tutti i prefissi. Causa della deriva ancora da isolare; dati consegnati a dynamics, nessun valore C nel runtime.
- Restano38 residui numerici advanced r18 e l'errore GNAT del caller Evaluate_Into; gli altri12 incarichi mantengono gli stati/limiti precedenti. La revisione indipendente della proposta upstream SDF è stata riconfermata senza nuove esecuzioni: vedi addendum del rapporto separato,34/34hash e fonti ufficiali immutate. Nessuna pubblicazione o benchmark servizi.


## Checkpoint 55: advanced composto sulla centrale LDL r19

- Nuova closure advanced r19-r1 da comune r19/integrated immutabile (manifest898501e2...), hook già presenti, più Normalize terms3 produttivo. Build validation PASS; prima ricevuta della composizione corrente, senza attribuirle automaticamente i minimi di Geometry o Prepare su altri manifest.
- Edge smooth/constrained PASS; minimi **8/8**, smooth **808/808**, fixed **803/840**, mobile **839/840**, parent **106/106**. Invariati gli insiemi dei37 scarti fixed e1 mobile, input originali e tolleranze invariati. Nessun residuo chiuso o nuovo dichiarato. R19 conserva so3_joint_vel_0/6 e il pass esatto global_disabled/6 documentati in r18.
- Release in compilazione sulla stessa mappa. Ricevuta validation e confronto r18 salvati in r19-validation; le38 lacune e i caller ancora aperti restano espliciti. Nessun benchmark servizi; gli altri12 incarichi conservano gli stati/limiti precedenti.


Release r19-r1 completa sulla medesima mappa: edge PASS,8/8 minimi,808/808 smooth,803/840 fixed,839/840 mobile,106/106 parent. Tutti i record numerici sono identici fra validation e release; anche i record validation dei cinque corpus coincidono con r18. Hash frozen ricontrollati,38 residui invariati. Nuovo tentativo caller soltanto frozen: estrazione Compute e helper in child privata con stesso contratto di frame; Evaluate_Into minimo in corso, nessun cambio produttivo né prova anticipata.


## Checkpoint 56: caller isolato senza errore interno GNAT

- L'estrazione della sola Compute in child privata ripete Storage_Error sulla dichiarazione Copy_Prefix:147s,picco1909MiB, nessun report finale; ricevuta r19-computation-child-crash conservata. Nessuna diagnostica parziale promossa a prova.
- Nella successiva copia frozen, anche Evaluate_Into/Evaluate sono isolati nella child Evaluation. Il minimo Evaluate_Into termina con report completo, **13 proof +1 flow chiusi e1post composto aperto**, segnalato su Output_Count;140s,picco749MiB. Tre warning su handler irraggiungibile conservati. Il crash è evitato per questo target, ma non c'è ancora prova del caller o della composizione.
- La child vedeva l'osservatore pubblico senza definizione funzionale. Preparata una nuova snapshot con i medesimi corpi degli osservatori spostati come expression-function nella parte privata della specifica; stesso runtime, nessun contratto indebolito. Prova minima in corso. Tutte le estrazioni restano soltanto frozen: la produzione è la r19 appena testata, con38 residui avanzati; gli altri12 incarichi conservano gli stati/limiti precedenti.


Child2 con osservatori privati termina ancora senza crash:13 proof +1 flow, un post composto aperto ora localizzato precisamente a `Activation(E)'Length = Activation(E)'Old'Length`; il rilievo su Output_Count è superato. Restano i tre warning degli handler. Child3 aggiunge solo snapshot ghost dell'attivazione e assert intermedi per localizzare il frame; prova minima in corso, produzione invariata.


Child3 non compila per policy ghost incompatibili: gli assert ordinari leggevano snapshot Ghost Static. Fallimento conservato, nessun risultato di prova. Child4 usa assert Static, verificati da GNATprove e coerenti con le osservazioni ghost; nessuna operazione runtime aggiunta. Minimo in corso sulla nuova closure immutabile.


Child4 termina con report completo: **20 proof +1 flow chiusi**, tutti i cinque assert sull'attivazione passano; resta un solo post composto aperto, ora identificato nel frame State_Values(D). Tre warning handler conservati. Child5 applica la transitività esplicita delle osservazioni State/Input dopo Publish e Solve_Acceleration, usando il lemma esistente già verificato ai minimi; nuova prova in corso. Nessun nuovo runtime né whole/caller dichiarato chiuso.


Child5 termina con **24 proof +1 flow chiusi e1post composto ancora aperto**; tutte le precondizioni delle quattro chiamate Equal_Transitive passano, ma il post finale raggiunge limite di tempo/memoria. Nessun claim di chiusura del caller. Child6 aggiunge il contratto esatto dei discriminanti di Capture_Evaluation: minimo **16 proof +2 flow chiusi**, Restore in corso. Child7 soltanto preparata separa l'admission già esistente da Evaluate_Ready, senza cambiare i controlli runtime; servirà a ridurre le alternative del post composto.


## Checkpoint 57: salvataggio e ripristino controller rinnovati

- Sulla child6 frozen, Capture_Evaluation con discriminanti espliciti chiude **16 proof +2 flow** e Restore_Evaluation **37 proof +1 flow**, zero obblighi aperti, report completo e hash invariati. Un warning per target è conservato nella ricevuta; non si dichiara strict pass senza warning. La capsula conserva le dimensioni richieste al ripristino, che mantiene input, attivazione e readiness secondo il proprio contratto.
- Il caller rimane aperto: child5 aveva24 proof +1 flow chiusi e1post composto non risolto. Child7 separa soltanto admission ed Evaluate_Ready con precondizioni corrispondenti ai controlli già eseguiti; minimo del corpo ammesso in corso. Prove dei caller superiori, Compute, whole e runtime della scomposizione ancora pendenti. Produzione invariata alla r19 verificata e38 residui numerici aperti; gli altri12 incarichi mantengono stati/limiti precedenti.


Evaluate_Ready/child7 termina con24 proof +1 flow chiusi e1post composto ancora aperto, ora segnalato sull'uguaglianza dell'attivazione; tutti gli assert intermedi e le precondizioni dei lemmi passano. La separazione admission da sola non basta,228,6s/picco801MiB. Child8 prepara un'immagine Prefix pura degli array: contratto esatto di bounds e contenuto, chiamata dagli osservatori Input/Activation, senza cambi di contenuto o ordine. Minimo Prefix in corso prima di ritentare il caller; tutta la scomposizione resta frozen.


## Checkpoint 58: immagine del prefisso verificata

- Prefix nella child8 frozen chiude il minimo **5 proof +2 flow**; l'intera MJ.Controller_Array_Kernels, con Copy_Prefix, chiude **17 proof +3 flow**, zero obblighi aperti, zero warning e copertura completa. Il contratto conserva bounds e contenuto esatto della slice, con dominio generale degli array; nessun nuovo trusted o precondizione artificiale.
- Inputs/Activation della copia sperimentale usano questa immagine pura degli stessi componenti. Il nuovo minimo Evaluate_Ready è in corso, senza anticipare la composizione. La produzione resta la r19 verificata:38 residui numerici aperti, nessuna estrazione caller applicata. Tutti gli altri incarichi e i limiti di whole/Compute/caller restano quelli precedenti.


Child8 caller non compila: Hide_Info non può identificare una expression function completata soltanto nel body di un’altra unità. Errore conservato in r19-prefix-annotation-error; nessuna prova assegnata. Child9 sposta la medesima definizione Prefix nella specifica: rinnovo minimo **5 proof +2 flow**, unità **17+3**, zero aperti/warning. Il caller ora termina con **24+1 chiusi e1post Activation aperto**,225,2s/picco785MiB; tre warning handler conservati. Ricevute r19-prefix-spec-min/whole e r19-evaluation-ready-prefix2. Child10 sostituisce il solo frame privato di Evaluate_Ready con componenti esatti Act/Na,Control/Nu,No,Nv; i contratti osservabili di Evaluate_Into/Evaluate rimangono invariati e dovranno essere provati. Nessuna modifica produttiva o runtime.


Child10/minimo componenti termina con **24 proof +1 flow chiusi e1post E.Act=Old aperto**,212,5s/picco813MiB; tre warning handler conservati. Gli assert intermedi passano, quindi anche il frame concreto resta incompleto nella composizione finale. Ricevuta r19-evaluation-ready-components. Avviata un’ablation per_path sugli stessi sorgenti e identici limiti (5s/check,900MB,guard240s), separando i percorsi anziché aumentare il budget. Audit testuale: corpi Input/Servo/Transmission/Stage/Compute identici alla r19 verificata; l’intera estrazione necessita ancora di runtime e prove caller.


Ablation per_path sulla child10 termina con24 proof +1 flow chiusi e1post composto aperto,192s/picco744MiB, stessi tre warning. Nessun miglioramento di chiusura né modifica sorgenti; ricevuta r19-evaluation-ready-paths. Child11 separa la sola pubblicazione Acc/Valid in un helper con formali sui due componenti e contratto esatto di prefisso/coda; minimo avviato prima del caller. Nessun cambiamento produttivo;38 residui e gli altri12 incarichi invariati.


## Checkpoint 59: pubblicazione dell’accelerazione isolata e verificata

- Child11 frozen: Publish_Acceleration minimo **7 proof +2 flow**, zero obblighi aperti, zero warning e copertura completa. Copia i primi Count elementi nell’ordine esistente, conserva la coda e pubblica Valid=True; contratto esatto verificato usando Copy_Prefix. Ricevuta r19-publish-acceleration-min.
- Evaluate_Ready è in nuova verifica con questa sola estrazione. Child10 per_check e per_path restano ricevute incomplete,24+1 e un post composto aperto. I contratti pubblici e le condizioni di ammissione non sono stati indeboliti.
- Produzione ancora r19-r1 verificata,38 residui numerici aperti. La scomposizione child e i nuovi helper restano frozen fino al rinnovo runtime; Compute, caller e whole ancora pendenti. Gli altri12 incarichi conservano stati e limiti dei checkpoint precedenti.


Child11 caller termina con17 proof +2 flow chiusi e **2 obblighi aperti**: post E.Act=Old e assert finale Activation=Initial. Precondizioni del nuovo helper e non-aliasing passano;204,3s/picco810MiB, tre warning handler. Ablation negativa conservata in r19-evaluation-ready-publication; non applicata. Si ritorna a child10 con un solo post aperto, per verificare separatamente Evaluate_Into ed Evaluate. Le prove dei compositori saranno comunque condizionate dai frame interni ancora incompleti; nessuna prova whole anticipata.


## Checkpoint 60: compositore Evaluate verificato ai minimi

- Sulla child10 immutabile, Evaluate minimo **2 proof +2 flow**, zero aperti/warning e copertura completa. Il salvataggio, l’ammissione del ripristino e il frame pubblico sono verificati modularmente. Questa ricevuta è **condizionata ai contratti di Evaluate_Into/Ready/Compute**, i cui obblighi interni restano aperti; non è Gold dell’intero controller.
- Evaluate_Into minimo chiude2 proof +1 flow e lascia1post Inputs=Old aperto, senza warning; sei altri rami del post passano, alcuni tra4,08 e4,12s. Nuovo tentativo sugli stessi sorgenti con10s/check, stesso guard240s e memoria900MB; nessun aumento di stack né ritentativo del vecchio crash.
- Ricevuta r19-evaluation-wrappers-min conservata. Produzione ancora r19-r1 e38 residui numerici invariati; estrazione/runtime e whole pendenti. Gli altri12 incarichi mantengono gli stati precedenti.


Evaluate_Into a10s/check conserva2 proof +1 flow chiusi e1post Inputs=Old aperto,137,2s/picco540MiB; zero warning. Ricevuta r19-evaluation-into-min10; non si aumenta ancora il budget. Child12 torna ai contratti osservabili originali di Ready e aggiunge un lemma ghost di congruenza dei prefissi, da provare prima dell’uso nel caller. Nessun nuovo runtime o assunzione; produzione invariata.


Equal_Prefix nella child12 chiude **5 proof +1 flow**, zero aperti/warning e copertura completa: uguaglianza dei due array con First=0 implica uguaglianza dei prefissi Count ammessi. Il lemma è ghost, corpo nullo verificato sul contratto funzionale esatto di Prefix; nessuna assunzione. Il caller che compone questa proprietà è ora in prova, senza claim anticipati. Ricevuta r19-equal-prefix-min.


Child12 con congruenza dei prefissi raggiunge watchdog240,2s/picco831MiB **senza report completo**. Nessun conteggio di prova assegnato al caller; lemma minimo5+1 resta limitato alla sua ricevuta. Tentativo conservato in r19-evaluation-prefix-lemma-watchdog. Per il rinnovo unità/runtime viene scelta child10, con risultati completi e un solo post Ready aperto: nessuna nuova chiamata runtime rispetto alla scomposizione già descritta. Preparata r19-r2 come copia identica dei sorgenti child10; whole Evaluation in corso, prima delle build/corpus.


Whole Evaluation/child10 raggiunge watchdog240,2s/picco915MiB senza report completo; nessun conteggio assegnato né claim whole. Minimi Ready24+1/1post, Into2+1/1post ed Evaluate2+2/0post rimangono attribuiti ai propri report. La verifica intera Array_Kernels17+3 ha un’equivalenza esplicita dei quattro Source_Files e del progetto fra child9 e child10, tutti hash identici; non è estesa alle unità controller. Build validation di r19-r2 avviata sui sorgenti immutabili child10 per verificare il refactoring prima di applicarlo.


## Checkpoint 61: refactoring controller r19-r2 verificato in validation

- Build validation completa su copia immutabile child10. Edge rifiuto/ripresa smooth+constrained PASS; corpus minimi8/8, smooth808/808, fixed803/840, mobile839/840, parent106/106. Tutti i record numerici, gli insiemi degli scarti e gli output dei controlli edge sono **identici alla r19-r1**; input confrontati identici e source hash ricontrollati.38 residui invariati.
- Patch limitata a otto file posseduti (due child private, parent controller, Prefix e progetto minimo) preparata ma non applicata. Input/Servo/Transmission/Stage/Compute conservano corpi identici; nessun edit comune. Release è ora in compilazione sulla stessa mappa.
- Scope prove: Array_Kernels17+3 sugli stessi quattro file compilati, Evaluate minimo2+2; Ready e Into hanno un post aperto ciascuno, intera Evaluation watchdog senza report. Compute e prove superiori ancora pendenti. Nessun Gold globale o dato prestazionale. Altri12 incarichi mantengono stati/limiti precedenti.


## Checkpoint 62: scomposizione controller applicata dopo entrambi i profili

- Release r19-r2 completa sulla stessa mappa immutabile: edge PASS, minimi8/8, smooth808/808, fixed803/840, mobile839/840, parent106/106. Tutti i record numerici sono identici fra validation/release e ai rispettivi profili r19-r1; input e output edge identici, hash ricontrollati. **38 residui** invariati, nessun risultato prestazionale dichiarato.
- Applicata la patch di otto file posseduti dopo backup, git apply --check e confronto degli hash. Il controller ora separa Computation ed Evaluation in due child private; gli osservatori mantengono le stesse immagini e Capture_Evaluation espone le dimensioni della capsula. Nessuna unità comune modificata. Ricevute r19-r2-validation/release, patch e application-result conservati.
- Questo refactoring elimina il precedente Storage_Error nei minimi selezionati, ma non completa Gold: Ready conserva1post aperto, Into1post, whole Evaluation watchdog senza report. Evaluate minimo2+2 chiuso è modulare e dipende dai contratti interni ancora aperti; Compute e prove superiori pendenti. Array_Kernels17+3 rimane sul proprio scope esatto. Le ablation negative11/12 restano soltanto frozen.
- Prossimo lavoro: ridurre il frame residuo al confine della child e completare i minimi dei consumer; recepire il nuovo Full_Bias comune solo dopo API/closure concordata, con nuovi confronti inverse/derivatives. Altri12 incarichi mantengono stati e limiti documentati.


Child13 frozen ripristina il frame osservabile originale di Ready e aggiunge immagini ghost/transitività esplicita degli input in Into. Minimo Into: **3 proof +1 flow chiusi e1post composto aperto**, ora diagnosticato su Activation=Old; precondizione della nuova transitività verificata,116,7s/picco537MiB, zero warning. Il post congiunto non è ancora chiuso. Child14 aggiunge il medesimo passaggio per Activation; minimo in corso. Produzione rimane child10/r19-r2 testata.

Revisione read-only richiesta dal root su Material_Loading r236 vs r229: nessun blocco individuato su ordine/status/alias/CSR. Segnalate al proprietario due precisazioni: l’admission dei metadati DoF positivi invalida ora anche alcuni casi welded prima accettati; Offset come argomento anticipa Read_Vector rispetto ai controlli DoF/Simple. Su fallimento i caller pubblici liberano lo storage e mantengono Invalid_Model, senza promessa di frame del buffer parziale. Nessuna modifica root né esecuzione aggiuntiva per questa revisione.


## Checkpoint 63: frame di admission Evaluate_Into chiuso

- Child14 frozen: Evaluate_Into minimo **5 proof +1 flow**, zero obblighi aperti, zero warning, copertura completa e hash invariati. Il contratto pubblico originale (stato/input, attivazione, dimensioni) è verificato modularmente, usando immagini ghost e due chiamate al lemma provato Equal_Transitive attorno a Ready. Nessun cambiamento runtime o assunzione.
- La prova resta dipendente dai contratti interni Ready/Compute non ancora chiusi; non equivale a prova globale del controller. Evaluate aveva2+2 su child10 e dovrà essere rinnovato sulla closure finale.
- Child15 aggiunge lo stesso schema ghost attorno a Compute e alla pubblicazione finale Acc/Valid in Ready; minimo in corso. Produzione rimane r19-r2 testata in entrambi i profili con38 residui invariati; gli altri12 incarichi conservano gli stati precedenti.


Ready/child15 con quattro ulteriori passaggi di transitività raggiunge watchdog240s/picco795MiB senza report completo; nessun conteggio assegnato. Ricevuta r19-evaluation-ready-transitive-watchdog. Per isolare il costo dei prover è avviato lo stesso minimo con solo Alt-Ergo,5s/check e identici memoria/watchdog: nelle precedenti ricevute alcuni frame State/Input passavano in0,3s con Alt-Ergo dopo timeout CVC5 e memoria Z3. Produzione invariata; nessun aumento dei limiti né claim whole.


Alt-Ergo solo/Ready child15 termina con report completo: **18 proof +1 flow chiusi,11 aperti**,145,6s; i tre warning handler sono conservati. Gli aperti includono range/asserzione del prefisso, precondizioni delle transitività controller, accesso/lunghezza Acceleration e post finale. Ricevuta r19-evaluation-ready-transitive-alt. Nuovo minimo sulla stessa closure con CVC5+Alt-Ergo, stessi limiti, evita il costo delle ripetute OOM Z3; nessuna somma manuale di prove incomplete o claim whole.


CVC5+Alt-Ergo/Ready child15 termina con report completo: **20 proof +1 flow chiusi,9 aperti**, tre warning conservati. Gli ulteriori snapshot non migliorano il corpo interno; entrambe le varianti rimangono negative e frozen.

Child16 è una nuova separazione strutturale, soltanto frozen: Input_Storage contiene i dati letti dal calcolo; Evaluation_Storage contiene i buffer modificati. Entrambi sono limited per mantenere il passaggio per riferimento. Compute_Core riceve Source come in e Work come in out; il wrapper Compute conserva il contratto di frame esistente. Il corpo aritmetico è testualmente identico dopo la sostituzione dei nomi dei buffer. Primo minimo del wrapper in corso; nessuna applicazione o risultato anticipato, produzione r19-r2 invariata.


## Checkpoint 64: frame Compute strutturale verificato

- Child16 frozen: il minimo del wrapper Compute chiude **1 proof +3 flow**, zero aperti e copertura completa. Il contratto esistente conserva conteggi, readiness, controllo e attivazione completi. Il calcolo riceve gli input con modalità in e un distinto buffer in out; il confine di tipi consente di verificare il frame senza nuove ipotesi.
- Non è una prova della sicurezza o delle formule di Compute_Core: restano da verificare i minimi del corpo e la composizione. I record limited preservano la modalità di passaggio per riferimento; corpo aritmetico identico dopo rinomina dei buffer. La numerica e le prestazioni della nuova struttura non sono ancora misurate.
- Ready è in prova sulla child16; nessuna applicazione della nuova struttura, produzione ancora r19-r2 verificata e38 residui invariati. Gli altri12 incarichi mantengono stati/limiti precedenti.

La ricevuta Compute conserva6 warning delle dipendenze (ricorsione/variante di trasmissioni e Sin standard); il minimo ha zero obblighi aperti ma non viene presentato come strict pass privo di avvisi. Dettagli integrali nel JSON/log del checkpoint64.


Ready/child16 termina con **24 proof +1 flow chiusi e1post composto aperto**, diagnosticato su Output_Count;195,7s/picco783MiB, tre warning handler conservati. Il nuovo confine Compute chiude il proprio frame ma non quello del caller. Ricevuta r19-evaluation-ready-components2. Child17 estende la separazione Source in/Work in out al corpo Ready, lasciando in un wrapper i contratti pubblici originali; minima del core prima del compositore. Tutto resta frozen, senza applicazione runtime.


## Checkpoint 65: frame Ready_Core verificato

- Child17 frozen: Evaluate_Ready_Core chiude **18 proof +1 flow**, zero obblighi aperti e copertura completa. Tre warning degli handler irraggiungibili conservati. Il contratto mantiene esattamente stato e input di Simulation; Source è un formale in separato dal buffer Work modificabile. Ricevuta r19-evaluation-ready-core-min, sorgenti e controllo della rilocazione conservati.
- Il wrapper Ready mantiene i contratti originali per stato/input, dimensioni e attivazione del controller; i minimi Ready/Into/Evaluate vengono rinnovati sulla stessa closure. Compute_Core conserva il corpo aritmetico precedente e necessita ancora delle proprie prove di sicurezza/formule: nessun claim whole o Gold globale.
- Nuova struttura non applicata: produzione r19-r2 e38 residui numerici invariati. Runtime entrambi profili ancora necessario prima di adottare Source/Work. Gli altri12 incarichi mantengono stati e limiti dei checkpoint precedenti.


## Checkpoint 66: tre caller Evaluation chiusi sulla struttura separata

- Stessa child17 immutabile: Evaluate_Ready **3 proof +2 flow**, Evaluate_Into **5+1**, Evaluate **2+2**, tutti zero aperti, zero warning, copertura completa e sorgenti invariati. Ready_Core aveva18+1 sulla stessa closure, con i tre warning handler conservati. Ricevuta r19-evaluation-component-callers-min.
- I contratti originali pubblici conservano stato, input, attivazione e dimensioni; Evaluate verifica modularmente la capsula di ripristino su errore. Capture/Restore vengono ora rinnovati sulla nuova rappresentazione, prima dell’intera Evaluation e del runtime. Le formule/safety di Compute_Core e i kernel chiamati restano uno scope distinto: il vecchio wrapper Compute non è più sul percorso Ready_Core e il suo minimo precedente non è una prova del calcolo runtime.
- Verifica dei26 campi: tipi, limiti e default identici,16 in Source e10 in Work; patch di cinque file preparata ma non applicata. Entrambi i profili runtime ancora pendenti. Produzione r19-r2,38 residui e altri12 incarichi invariati.
- Review read-only r246 Element/Metric del root: nessun blocco rilevato su domini, ordine triangolare C/stride21, frame dei campi non caricati e status. Nessun edit o test aggiuntivo; dettaglio inviato al proprietario.


Capture/Restore rinnovati sulla stessa child17: **16 proof +2 flow** e **37+1**, zero aperti/copertura completa, un warning di variante numerica per ciascun target conservato. Ricevuta r19-evaluation-capsule-components-min. La composizione Evaluation può ora essere verificata interamente sulla stessa struttura; nessun risultato runtime o prova Compute_Core ancora attribuiti.


Whole Evaluation/child17 raggiunge watchdog240,1s/picco775MiB senza report: nessun conteggio o claim whole assegnato. Nei minimi il post Ready_Core passa con Alt-Ergo in0,6s dopo10s di timeout CVC5/Z3; le precondizioni finali passano con Z3 in0,1s dopo timeout CVC5. Viene provata una diversa priorità dei medesimi prover (Alt-Ergo,CVC5,Z3), invariati5s/check,900MB,guard240s; nessun aumento dei limiti. Le ricevute minime chiuse e il limite intero restano separati.


## Checkpoint 67: intera Evaluation verificata sulla struttura Source/Work

- Child17, intera MJ.Data.Advanced_Control.Evaluation: **28 proof +6 flow**, zero obblighi aperti, copertura completa e sorgenti invariati. Alt-Ergo,CVC5,Z3 con gli stessi limiti 5s/check,900MB,guard240s chiude l’unità in238,8s; **10 warning conservati**: tre handler e sette avvisi di possibile riassociazione nei contratti comuni (mj-data, smooth_math, ancestor_rows). Nessun strict pass senza avvisi. Ricevuta r19-evaluation-components-whole. Il watchdog precedente resta archiviato separatamente.
- Sulla medesima closure i minimi Ready_Core18+1, Ready3+2, Into5+1, Evaluate2+2 e Capture16+2/Restore37+1 sono chiusi. Il risultato intero riguarda i frame osservabili e il ripristino definito dalla capsula; è modulare sui contratti degli altri kernel, non prova safety/formule di Compute_Core né accuratezza fisica o equivalenza universale C.
- Avviato rinnovo runtime r19-r3, copia dei370 file della stessa closure. Il confronto includerà output completi, input e MJB byte per byte oltre ai record numerici e ai casi di rifiuto/ripresa. Nessuna modifica produttiva ancora applicata;38 residui avanzati e gli altri12 incarichi restano quelli documentati.


## Checkpoint 68: nuova struttura verificata in validation

- Build r19-r3 validation riuscita; edge rifiuto/ripresa PASS, minimi8/8, smooth808/808, fixed803/840, mobile839/840, parent106/106. Gli stessi38 scarti restano espliciti.
- Confronto contro r19-r2 validation: record numerici, lista scarti ed edge identici; **1051 file input/MJB/output byte-identici** (315 input,368 MJB,368 output). Nessun cambiamento nascosto sotto il solo errore massimo. Hash file, binari, C e sorgenti conservati in r19-r3-validation.
- Release viene compilata sulla stessa mappa immutabile; patch non ancora applicata. Intera Evaluation28+6 chiusa con10 warning, Capture/Restore16+2/37+1 rinnovati, Core numerico e altre prove superiori ancora pendenti. Gli altri12 incarichi mantengono gli stati precedenti.


## Checkpoint 69: struttura Source/Work applicata dopo entrambi i profili

- Release r19-r3 sulla stessa closure: edge PASS, minimi 8/8, smooth 808/808, fixed 803/840, mobile 839/840, parent 106/106. Record e insiemi degli scarti identici a r19-r2 release e a r19-r3 validation. Per ciascun confronto coincidono byte per byte tutti i 1051 file dei cinque corpus (315 input,368 MJB,368 output), oltre agli output edge; i due MJB edge aggiuntivi sono inclusi nel manifest dei1053 file runtime archiviati. **38 residui numerici invariati**, nessuna tolleranza modificata.
- Applicata la patch di cinque unità possedute dopo verifica hash, backup, git apply --check e confronto finale. Il controller distingue ora Input_Storage ed Evaluation_Storage limited; Ready_Core riceve input in sola lettura e un buffer modificabile separato. Nessun file comune modificato, nessun commit o misura prestazionale. Backup e application-result nelle ricevute r19-r3-validation/release.
- Intera Evaluation **28 proof +6 flow** chiusa sui medesimi sorgenti; dieci warning conservati (tre handler, sette riassociazioni nei contratti comuni). Capture **16+2** e Restore **37+1** rinnovati con un warning di variante ciascuno. Sono prove di frame e ripristino della capsula, modulari sui kernel chiamati; sicurezza/formule di Compute_Core, parent completo e accuratezza fisica rimangono aperte.
- Prossimo lavoro: minimi funzionali del calcolo, cominciando dalla pubblicazione delle attivazioni; consumer inverse/derivatives attendono la closure comune Full_Bias validata dal proprietario. Gli altri12 incarichi conservano stati/limiti precedenti.


## Checkpoint 70: kernel di pubblicazione attivazione verificato

- Nuovo candidato frozen: Staged_Value minimo **1 proof +2 flow**, Stage_Activation **8+1**, intera MJ.Advanced_State **17+9**; zero aperti, zero warning e copertura completa. Contratto esatto del clamp nell’ordine esistente, flag Can_Advance precedente congiunto all’ammissione del valore, elemento scritto e frame di tutti gli altri. Se il valore è rifiutato, l’array rimane interamente invariato.
- La precondizione richiede l’indice valido soltanto nel ramo che scrive, come la precedente operazione runtime; valori fuori Tier0 rimangono ammessi e rifiutano l’avanzamento senza accesso all’array. Nessuna ipotesi di ordinamento dei limiti aggiunta, nessun trusted.
- Preparata separatamente la delega Stage del controller, con il medesimo contratto; minimo del wrapper in corso. I chiamanti Compute_Core devono ancora provare i bounds dei metadati, e runtime/adozione del kernel sono pendenti. Produzione resta r19-r3 verificata,38 residui invariati; Full_Bias comune e altri12 incarichi mantengono gli stati precedenti.


Stage wrapper chiude il minimo **7 proof**, zero aperti/copertura completa; sei warning delle dipendenze sono conservati. Il kernel non è ancora applicato. Prima di adottarlo, la nuova precondizione d’indice passa al livello Static già usato dal controller: evita di introdurre Assertion_Error nel percorso dei metadati privati malformati, che prima sollevava Constraint_Error al momento dell’accesso. Non cambia il requisito da provare nel caller. [La documentazione AdaCore](https://docs.adacore.com/spark2014-docs/html/ug/en/source/specification_features.html#assertion-levels) conferma che Static non genera il controllo runtime. Sorgenti diversi richiedono nuove prove del kernel e del wrapper; le vecchie ricevute non sono estese automaticamente.


## Checkpoint 71: attivazione, frame e confine d’errore rinnovati

- Sulla nuova closure con precondizione Static: Staged_Value **1+2**, Stage_Activation **8+1**, intera Advanced_State **17+9**, zero aperti/warning. Wrapper Stage **7 proof** chiuso, sei warning delle dipendenze conservati. I metadati del caller Compute_Core rimangono da dimostrare.
- Probe dedicato contro il precedente corpo Ada: **6720/6720 casi in validation e release**, stessi bit degli array, flag e classe d’errore. Include array vuoti, overflow/indici fuori intervallo, estremi finiti, limiti invertiti e zeri con segno. I casi fuori dalla precondizione sono diagnostica della compatibilità del rifiuto, non una prova fuori dominio né un confronto fisico C. Il primo harness falliva soltanto nel parsing della riga aggiunta dal watchdog: ricevuta originale conservata; nuova esecuzione completa su driver corretto.
- Kernel e wrapper restano frozen. R19-r4 è una copia identica preparata per rinnovo della composizione Evaluation e runtime integrato; la precedente whole28+6 non viene estesa a sorgenti cambiati. Il guard della nuova whole è300s perché il precedente successo richiedeva238,8s entro240; restano invariati5s/check e900MB, senza ripetere un crash.
- Produzione ancora r19-r3,38 residui invariati; Full_Bias non ancora disponibile in common, altri12 incarichi invariati.


Rinnovo dell’intera Evaluation sulla dipendenza Stage definitiva: **28 proof +6 flow chiusi**, zero aperti/copertura completa;10 warning conservati. La precedente ricevuta r19-r3 resta separata. Audit testuale: l’unico corpo esistente sostituito è Stage; il resto di Computation e le tre funzioni preesistenti Advanced_State sono identici. Build validation r19-r4 avviata prima del corpus integrato e di ogni adozione.


## Checkpoint 72: Stage collegato nel candidato e verificato in validation

- Build r19-r4 validation riuscita; edge PASS, minimi 8/8, smooth 808/808, fixed 803/840, mobile 839/840, parent 106/106. Tutti i record e i1051 file input/MJB/output sono byte-identici a r19-r3 validation;38 residui invariati. Ricevuta r19-r4-validation completa.
- Il percorso runtime del candidato ora usa Stage_Activation; la prova non resta limitata a un kernel scollegato. Sono chiusi whole Advanced_State17+9 senza avvisi, wrapper Stage7 con6 avvisi e nuova whole Evaluation28+6 con10 avvisi; il caller Compute_Core e le sue precondizioni di metadati rimangono aperti.
- Release in compilazione sulla medesima mappa prima dell’adozione. Nessun cambio live del kernel ancora; nessun benchmark o claim di parità C completa. Gli altri12 incarichi e Full_Bias mantengono lo stato precedente.


## Checkpoint 73: Stage produttivo dopo confronto completo dei due profili

- R19-r4 release: edge PASS, minimi 8/8, smooth 808/808, fixed 803/840, mobile 839/840, parent 106/106. Record, insiemi degli scarti, output edge e tutti i1051 file input/MJB/output coincidono byte per byte con r19-r3 release e r19-r4 validation. Restano38 residui C; nessuna tolleranza modificata o misura prestazionale.
- Applicata patch di quattro file posseduti dopo backup, hash prima/dopo e git apply --check: kernel Advanced_State, delega Stage in Computation e progetto minimo. Whole Advanced_State17+9 senza avvisi, Stage7 con6 avvisi e nuova whole Evaluation28+6 con10 avvisi sono sulle sorgenti adottate. Indici dei caller Compute_Core, sicurezza/formule complessive e accuratezza rimangono aperti.
- Il build driver ora include controller_state_proof.gpr nei nuovi snapshot; i driver effettivamente eseguiti prima di questa modifica sono conservati nelle ricevute. Prossimo lavoro: minimi dei metadati e del calcolo. Full_Bias comune resta draft e i consumer inverse/derivatives invariati; gli altri12 incarichi conservano stati e limiti precedenti.
- Review read-only r272-wide contro r268: post Load_Element equivalente sotto le pre invariate (span + traslazione Int64 implica i bounds source precedenti), nessun frame perso; runtime e pre identici. Prova Source_Range_Lemma demandata al proprietario, nessun edit o job root eseguito.


## Checkpoint 74: consumer Full_Bias preparati su common frozen

- Closure comune movement16 fornita dal proprietario,322 file verificati contro manifest prima della composizione. Due copie separate da371 file: controllo con consumer precedenti e candidato con quattro modifiche owned. Nessun consumer live cambiato.
- Inversa ora ha un nuovo helper Required_Full_Bias che conserva esattamente `Full_Bias + ((Inertial - Passive) - Constraint)` di C; il precedente helper pubblico resta disponibile. Minimo **7 proof +2 flow**, intera Inverse_Kernels **42+11**, zero aperti/warning e copertura completa, hash ricontrollati dopo le prove.
- Il candidato Current legge Full_Bias_Value dopo le verifiche Is_Ready/Passive_Current; Force_Sample sostituisce soltanto Bias-Gravity con lo stesso getter, mantenendo `(Actuator+Passive)-Bias`. Full_Bias indica RNE completo; mj_tendonBias è nullo nel dominio attualmente ammesso. I frame e caller comuni restano aperti e la closure non è produzione.
- Build validation del candidato avviata; numerica non ancora attribuita. Seguirà controllo sulla medesima common per separare gli effetti dei consumer. Primo script di preparazione interrotto prima del manifest per directory opzionale tendon-fixtures assente; corretto per rispettare il precedente glob vuoto, nessuna esecuzione di quella copia parziale. Gli altri lavori conservano gli stati precedenti.


## Checkpoint 75: pausa globale, zero job attivi

- Ricevuta istruzione root: get_goal paused. Nessun nuovo job o cambiamento produttivo dopo la pausa.
- Unico job già avviato58462 (build validation Full_Bias consumer candidato) terminato **exit0**, sorgenti identici prima/dopo; log e ricevuta archiviati in recovery-full-bias-20261003. **Nessun corpus Full_Bias consumer eseguito**, nessuna build controllo/release o prova caller attribuita. Minimo7+2 e whole42+11 rimangono gli unici risultati nuovi del candidato.
- Produzione servizi resta r19-r4 Stage, verificata in entrambi i profili con38 residui. Candidato Full_Bias e controllo isolati in /var/tmp/sparkling-services-fullbias-consumers-{candidate,control}-20261003. Alla ripresa: eseguire corpus candidato, build/corpus controllo sulla stessa movement16, poi release e prove caller; attendere il proprietario prima di adozione consumer/common. Nessuna pubblicazione upstream.
