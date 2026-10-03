# Ripresa services — 2 ottobre 2026

Stato: esecuzione ripresa, non semplice audit. Proprietà dei file conforme al piano comune; i quattro nuovi file adesione in `constrained-step` restano di questo gruppo, gli altri file comuni vengono modificati solo dal proprietario dynamics tramite patch coordinate.

Baseline ufficiale ricontrollata il 2026-10-02: [MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0), commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Nessuna migrazione di versione.

| ID | Incarico | Stato e prossimo passo |
| --- | --- | --- |
| R14 | PID/DC/SO3 | Build validation e808/808 traiettorie C passate,101configurazioni. Prove kernel/composizione in corso; integrazione vincoli e altri integratori pendenti. |
| R15 | Trasmissioni | Audit 21/21 manifest Ada/base identici; unità complete con obblighi aperti conservate come tali. Miglioramento prove e composizione pendenti. |
| R18 | Adesione/contatti | Integrata nella centrale; 440/440 C validation e release dopo fix grouping; 106/106 regressioni sulla precedente closure. Kernel 303 proof + 43 flow identico per hash, adapter flow 11 chiusi. Composizione/performance pendenti. |
| R20 | Integratori | Corretti discrete gyro/drag; PCG nativo con tolerance/iterations.512/512 completi; kernel intero42 proof check. prove composizione aperte. |
| R21 | Dinamica inversa | Nuova build e 2848/2848 scenari C, 412/412 risposte vincoli esatte. Helper/model bounds provati; relazione Multiply=Model ancora aperta. |
| R22 | Derivate | Collegata l’inversa ordinata e la risposta ellittica densa/sparsa; nuova build/confronto pendenti. Sonno FD rifiutato esplicitamente dal C. |
| R23 | Sensori | 264/264 traiettorie C, tutti i tipi builtin0..46 rappresentati; kernel73/73. Composizione/produttori avanzati da completare. |
| R24 | Ray casting | Kernel72/72; confronto1440 primitivi+6480 scene; lifecycle PASS. Composizione/performance pendenti. |
| R25 | Mocap | Recuperato e integrato dal proprietario dynamics;272/272 traiettorie, kernel45 proof +1 flow. Prove setter e mapping esatto pendenti. |
| R26 | Plugin | 212/212 C; protocollo29, runtime61, callback54 controlli provati. Composizione/performance pendenti. |
| R27 | Sonno | Manager/kernel/adapter e test recuperati; verificare chiusura. |
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
- Nuova build validation **PASS**; confronto **272/272** traiettorie C3.14.0 (9modelli, smooth/constrained,16campioni,100passi), con input zero/nonunit/tiny/grandi/near-unit, figli hinge/ball, contatti con piano mobile, tendini e fluido. Reset bit-per-bit, input raw, atomicità su errori e lifecycle PASS.
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
- Rebuild della closure condivisa e confronto nuovo: **808/808 traiettorie** (101configurazioni ×8campioni,1/100passi) PASS, comprese tutte64combinazioni DC con actearly, PID hinge/slide/ball, SO3 joint/site/refsite, muscolo, blocchi misti, gruppi e flag. Pose, forze, accelerazioni e step sono calcolati interamente da Ada; il modello sorgente è liberato prima del movimento.
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
