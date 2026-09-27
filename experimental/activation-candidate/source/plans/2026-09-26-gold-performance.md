# Adozione sequenziale delle cinque ottimizzazioni sotto Gold

Richiesta esplicita del 2026-09-26: registrare e adottare una alla volta tutte le
cinque famiglie discusse. Riferimento: docs/cost-attribution.md. L'autorizzazione
comprende implementazione, prove e benchmark; non richiede di disabilitare
controlli non dimostrati né di cambiare la semantica delle API.

| Priorità | Intervento | Stato | Criterio di adozione |
|---|---|---|---|
| 1 | Eliminare le tre scansioni interne Phase_Ready | PRIMA RIMOSSA E ADOTTATA; DUE RESIDUE | Prove delle precondizioni ai chiamanti e della preservazione dello stato nelle fasi; mantenere controllo iniziale e comportamento degli ingressi pubblici |
| 2 | Massa costruita direttamente nel formato compatto | DA INTEGRARE | Chiudere pubblicazione/frame, inizializzazione, reset e caricamento fattore del prototipo verification; API dense invariate |
| 3 | Ridurre i controlli numerici dentro i calcoli | PARZIALE: POSE E ACCUMULO CRB ADOTTATI | Eliminare solo quelli ridondanti sotto i contratti dimostrati; verificare e misurare ogni ulteriore adozione |
| 4 | Combinare gravità e bias nel percorso RNE | NUCLEO GOLD INTEGRATO; COLLEGAMENTO PENDENTE | Contratti sul nuovo ordine FP, disponibilità corretta delle grandezze separate e test C; niente cambio silenzioso dell'API |
| 5 | Ottimizzare codice generato, accessi e inlining | VARIANTI MISURATE, NON ADOTTATE | Trasformazioni concrete con proprietà funzionali dimostrate e beneficio integrato ripetibile; SIMD è già attivo |

Per ogni riga: guardare prima il percorso corrispondente in MuJoCo C 3.14.0;
prove a partire dai sottoprogrammi minimi; completare la chiusura delle dipendenze
rilevanti; test differenziali Strict e Compatible; benchmark movimento integrato
Ada precedente/Ada candidata/C normale SIMD in due sessioni senza job concorrenti.
Le varianti diagnostiche senza controlli non sono candidati Gold.

Gold ovunque possibile. I timeout sono prove incompiute, non limiti matematici.
Preservare warning, deallocatori e ordine FP, salvo un nuovo algoritmo esplicito
con contratti e verifiche adeguati. Registrare risultato e obblighi ancora aperti
qui dopo ogni adozione. Non sommare i guadagni delle varianti isolate.

## Registro

- 2026-09-26: piano creato; analisi e prove isolate delle fasi forze/Euler in
  parallelo; integrazione sequenziale. Sorgenti attivi inizialmente invariati.
- Prima prova del punto 5: `Inline_Always(Multiply)` chiude 154 obblighi e passa
  624 scenari/168.192 confronti per ciascuna policy. Due sessioni integrate
  mostrano guadagni dell'1–3% su alcuni modelli piccoli ma nessun beneficio
  convincente sui 24 DOF; ramificato24 registra fino a +1,2% (due CI sottoinsieme
  interamente sopra 1). NON adottata. Evidenza in
  `tests/movement_performance/gold_adoption/evidence/inline-trial.zip`.
- Per il punto 1: individuata la necessità di restringere i buffer modificabili
  dei solver o dimostrare frame espliciti. Pubblicazione massa e diagonale
  smorzata vengono isolate in helper; non sono ancora autorizzazione a togliere
  le tre scansioni. Preparazione spaziale ha ancora obblighi aperti/timeouts.

Le priorità guidano il lavoro; una modifica indipendente già dimostrata può
essere adottata prima di una dipendenza ancora aperta. Ogni adozione resta
isolata e misurata, senza confondere preparazione con completamento.
- ADOTTATO un primo sottointervento del punto 3: tre controlli pose ridotti con
  equivalenza esatta. 118 obblighi proof +16flow chiusi, includendo il chiamante;
  entrambe le policy numeriche passano. Due sessioni: hinge_motor −4,16..4,94%,
  sliders6 −1,60..2,34%; sui 24 DOF nessun guadagno stabilito. Nessuno dei 66 CI95
  indica rallentamento significativo. Le tre Phase_Ready restano attive.
  Dettagli e limiti: docs/gold-performance-adoption.md.

- 2026-09-27: dimostrato ridondante il controllo sulla diagonale smorzata.
  Due forme implementate, provate e misurate separatamente (helper runtime,
  poi lemma solo ghost). Entrambe NON ADOTTATE per risultati integrati misti.
  La seconda chiude 104 verifiche proof dell'unità e7 selezionate al chiamante;
  entrambe le policy numeriche passano. Il controllo attivo resta invariato.
- Chiusura ancora in lavorazione: pubblicazione massa con lemmi di simmetria,
  preparazione spaziale con buffer modificabili circoscritti, lifecycle del
  formato compatto. Per RNE combinato è in verifica un helper indipendente
  con formule FP esatte; non ancora collegato alla simulazione.

- Integrato il prerequisito MJ.Fused_RNE con34 proof+10flow chiusi e test
  checked/release superati. Non chiamato dal passo di simulazione: punto4
  resta incompleto. Il progetto di integrazione documenta scratch separato,
  nuovo ordine FP della forza totale e materializzazione separata sugli errori.

- ADOTTATI contratti Static più forti in Spatial_Storage:104 proof chiusi,
  corpo runtime invariato. Rebuild finale: .text/.rodata/.data identiche al
  binario pose misurato. Nessun nuovo guadagno di runtime attribuito.
- Mass_Publication ora64/64 con dipendenze chiuse; integrazione ramo CRB9/2
  ancora aperta. Preparazione spaziale: Build_Centers42/42 ma buffer4 obblighi
  e Prepare ancora aperti. Lifecycle compatto resta draft: Reset43/1 e
  Build_Topology/Initialize con timeout. Non attivata la massa compatta.

- CRB: chiusi separatamente i limiti della somma FP (39 verifiche), la
  contabilità intera dei contributi (99), il modello del ciclo originario (31)
  e il lemma di espansione del modello (16). Dipendenza Add verificata di nuovo
  con 26 verifiche. Il ciclo completo resta 65/75: invarianti e postcondizione
  esatta ancora aperti. La variante che nasconde Prefix_Sum termina per timeout,
  senza nuovi risultati. Controllo numerico CRB ancora attivo; nessuna adozione
  basata sulla sola asserzione locale.
- Reset compatto: un lemma separato di espansione esatta di Configuration
  chiude 13 proof + 1 flow; la composizione termina per timeout. Ripristinata
  la migliore bozza precedente (43 verifiche, una aperta). Evidenza nuova in
  compact-reset-followup.zip, distinta dall'archivio iniziale.
- Follow-up spaziale: chiusa la direzione del giunto (4/4); Build_Buffers
  passa da quattro a tre obblighi residui (94 controlli nell'ultimo tentativo).
  Restano prefisso, collegamento ai giunti del corpo e limite finale; nessuna
  nuova rimozione. spatial-motion-followup.zip conserva i due tentativi.
- Follow-up pubblicazione massa: wrapper del produttore in sola lettura 4/4;
  wrapper d'integrazione migliorato a 6/7. Chiuse le precondizioni di Publish;
  la sola diagnostica residua riguarda la simmetria, ma la postcondizione
  combinata/frame non è ancora dichiarata chiusa. Tentativo
  successivo con predicato opaco scaduto senza verifiche concluse. Migliore bozza
  ripristinata e archiviata, non attiva; nessuna scansione rimossa.

## Ripresa del 27 settembre

In corso, in copie isolate e senza altre modifiche runtime attive:

- Pubblicazione massa: separato il ramo di produzione/pubblicazione dal richiamo
  a Prepare; ramo minimo Try_Ready_CRB chiuso 6/6. Composizione della snapshot
  Configuration ancora aperta nel wrapper (4/5); Equal_Configurations verificato
  fresco 22/22. Un modello ghost readonly equivalente alla vecchia Configuration,
  compreso il ramo vuoto, chiude64/64 ma non risolve la composizione: conservato
  separato, non adottato globalmente. Anche il tentativo di separare i cinque post
  resta4/5. Archivi mass-publication-split-followup e configuration-image-followup.
- Buffer spaziali: Write_Joint_Motion chiuso 20/20 e Build_Body_Motions 70/70,
  con valori esatti, uscita di rifiuto e frame; Build_One_Body62/62 e composer
  Build_Buffers66/66 chiusi. Il composer espone safety/bounds, non un modello
  funzionale globale completo. Due ponti di Prepare5/5 ciascuno; Prepare termina
  a100s senza obblighi emessi. Candidato non attivo. Numerici Compatible624scenari,
  168.192 confronti e14 edge-policy in Strict passati; non una suite624 Strict.
- Solver Compatible: estratta una routine che può modificare solo fattore,
  soluzione e diagnostica del pivot. Helper del prefisso e della singola cella
  chiusi12/12 e4/4; nucleo80/80 e wrapper8/8 chiusi (104proof+20flow distinti).
  Dipendenze corrispondenti alle ricevute esistenti, corpi esatti o specifiche con
  sole modifiche di commenti. Non è una nuova dimostrazione funzionale dell'intera
  soluzione lineare. Due policy numeriche624scenari ciascuna e test di errore
  checked/release passano,167.616 valori benchmark identici bit per bit.
  Prima forma NON ADOTTATA: sei slider0,92–2,23% più lenti in due sessioni,6/6 CI95
  sopra1. Conservata come prerequisito delle scansioni, nessuna rimossa.
  Anche la seconda forma con Inline_Always sul buffer è NON ADOTTATA: prove
  invariate, replay e fallimenti passano, ma tutti i casi hanno mediane più lente
  e63/66 CI95 sopra1. Non incorporare queste due varianti nel runtime attivo.
- CRB: singola componente17/17, estensionalità4/4, prefisso8/8 e passo esatto43/43:
  72 nuovi controlli distinti chiusi. Ciclo completo69/77; controlli numerici ancora
  attivi. Checkpoint crb-step-composition-evidence.zip, invarianti e modello esatto
  non indeboliti. Nessun limite matematico invocato per gli obblighi aperti.
  Follow-up minimo: lemma inizializzazione 4proof+1flow chiusi; chiamante mirato1/2,
  uguaglianza iniziale ancora aperta. crb-initialization-checkpoint.zip conserva
  entrambi gli stati; non sostituisce69/77 con una falsa chiusura del ciclo.

Prima dell'adozione serviranno chiusura dei chiamanti pertinenti, verifica delle
dipendenze e misure integrate separate da questi job di prova.

## Continuazione delle prove del 27 settembre

- SUPERSEDE il timeout Prepare del checkpoint precedente: estratto il buffer
  modificabile ristretto, chiusi Prepare_Buffers34proof+3flow e Prepare8proof+20flow.
  Verifica dell'intera MJ.Data.Spatial: **391proof+55flow, zero aperti**; i risultati
  locali sono inclusi nel totale. La prova finale riusa la cache valida dello
  stesso identico sorgente aggiungendo Z3; conservati entrambi i tentativi.
  Contratti pubblici e helper precedenti invariati, nessun Assume. Prova dei
  contratti presenti, non del modello funzionale globale ancora mancante.
- Numerici dello stesso candidato: Strict e Compatible passano ciascuna
  624scenari/168.192 confronti. Il tentativo aggiuntivo sul modello esatto delle
  inerzie resta una bozza separata con timeout nel corpo/composer: non sostituisce
  lo snapshot dell'unità chiusa. spatial-prepare-closure.zip/json conservano
  sorgenti, diagnostiche, scope e identità del probe. Nessuna misura integrata
  nuova: candidato NON ADOTTATO,100sorgenti attivi invariati e3scansioni interne
  ancora presenti.
- CRB: chiusa l'inizializzazione dell'uguaglianza al modello nel chiamante
  mirato. Usando direttamente lo stato ricorsivo come testimone ghost, prova
  dell'intero Accumulate_Composite migliorata a **79/83proof e3/3flow**. Restano
  limite della somma nel passo, limite pesato, conservazione dell'uguaglianza
  al modello e uguaglianza finale. Modello/ordine FP invariati. Lemma della
  singola componente della somma13proof+1flow chiuso; ulteriori lemmi minimi
  di uguaglianza/proiezione chiusi separatamente. Composizioni successive
  scadute per timeout, senza prova completa. Ripristinato il sorgente79/83,
  con104file del manifest di prova corrispondenti. crb-model-continuation.zip/json
  conservano checkpoint e bozze distinte; avvisi mantenuti. Controllo numerico
  attivo invariato. Proseguire dai quattro obblighi elencati, senza riesumare
  le bozze successive come se fossero già dimostrate.

## Chiusura CRB del 27 settembre

- SUPERSEDE 79/83: Accumulate_Composite completo **99/99 proof + 3/3 flow**, inclusi
  tutti gli invarianti, le precondizioni ai chiamati e il modello funzionale
  finale. Otto nuovi lemmi ghost chiusi separatamente 163 proof + 8 flow; dipendenze
  già dimostrate verificate per identità di corpi/contratti e sorgenti di package.
  Precondizioni, postcondizione e modello controllato originario invariati.
  Nessun Assume o nuova soppressione; nessun limite matematico invocato.
- Collegamenti chiusi: somma per componenti, descrizione della scrittura,
  contabilità del contributo ritirato, conservazione dei limiti pesati e passo
  ricorsivo del modello. Nessuna modifica alle istruzioni eseguibili rispetto
  al candidato precedente, dopo rimozione del solo codice ghost/strumentazione.
  Sorgente esatto in crb-accumulation-closure.zip, cartella closed-source.
  Il checkpoint locale corrispondente è /var/tmp/sparkling-crb-closure-20260927/source.
- Strict e Compatible passano ciascuna 624 scenari/168.192 confronti sullo stesso
  probe checked. Archivio crb-accumulation-closure.zip/json, con prove complete,
  tentativi intermedi distinti, test, sorgenti e ricevute delle dipendenze.
  Non riprendere dai precedenti quattro obblighi: sono chiusi in questo snapshot.
- DA FARE per l'adozione: integrare la versione provata con il produttore di
  massa/chiamanti attivi, chiudere le relative condizioni e misurare il passo
  integrato prima di rimuovere il controllo numerico. I 100 sorgenti attivi restano
  invariati, così come le 3 scansioni interne. La massa completa e la dinamica
  globale rimangono lavori distinti da questo teorema dell'accumulo.

## Precondizioni nei chiamanti CRB, 27 settembre

- Chiusi Load_Composite 23proof+1flow (copia esatta e inizializzazione),
  Zero_CRB_Mass 4+2 (azzeramento esatto), Fill_CRB_Mass 37+2 (contratto attuale
  di sicurezza/limiti/simmetria) e Try_Assemble_CRB 14+3 (intero contratto
  attuale e tutte le precondizioni ai chiamati). Totale nuovo 78proof+8flow,
  zero aperti. Precondizioni pubbliche e specifiche di package esistenti intatte.
- Nel candidato collegata la versione spaziale già chiusa 391+55; accumulo
  99+3 e lemmi precedenti identici. Nessun Assume o nuova soppressione.
  Il confronto del sorgente, espandendo i tre nuovi helper, conserva le
  istruzioni eseguibili del precedente candidato CRB. Non è equivalenza binaria.
- Assemble: precondizioni a Spatial.Prepare e Try_Assemble_CRB chiuse con due
  verifiche selezionate. Chiusa anche l'asserzione Static Phase_Ready di ingresso
  e la sua precondizione, altri2obblighi selezionati. Tentativo completo scaduto a160s: NON dichiarare
  l'intero Assemble provato. Ingresso pubblico invariato chiuso 2proof+2flow.
  Evaluate_Ready: precondizione della chiamata alla massa dimostrata; controllo
  completo 40/41proof, resta la postcondizione di conservazione State_Values.
- Strict e Compatible passano ciascuna624scenari/168.192confronti sul probe del
  sorgente finale. Evidenze in crb-callers-closure.zip/json, incluso ogni
  tentativo incompleto distinto. Checkpoint locale:
  /var/tmp/sparkling-crb-callers-20260927/source.
- SUPERSEDE il precedente lavoro sulle precondizioni dell'accumulo/chiamante:
  queste sono chiuse. Proseguire dalla composizione completa assemblaggio/stato
  e dal modello funzionale della massa; misurare due sessioni integrate prima
  dell'adozione. NON rieseguire le prove già chiuse senza modifiche pertinenti.
  I100sorgenti attivi sono invariati, controllo CRB e3scansioni ancora presenti;
  nessuna nuova misura di prestazione o adozione runtime in questo turno.

## Assemblaggio e conservazione dello stato chiusi, 27 settembre

- SUPERSEDE il timeout di Assemble e il 40/41 di Evaluate_Ready: il candidato
  isolato chiude l'intero contratto attuale di Inertia_Phase.Assemble mediante
  Assemble_Ready (insieme 36 proof + 5 flow). Composizione della pipeline e due
  gruppi di fasi chiusi 62+6, inclusa State_Values; confine Jacobiani e helper
  ristretto chiusi 26+19. Tutte le precondizioni pubbliche restano invariate.
- Separati e provati i percorsi CRB/denso, layout, reset e pubblicazione.
  Ensure_Jacobians conserva massa, limiti e simmetria tramite postcondizioni
  Static più forti, provate nel package privato. Intera Mass_Publication
  estesa con Mark_Ready chiusa 74+10. I 21 ambiti selezionati totalizzano
  459 proof + 69 flow, zero aperti; includono dipendenze ricontrollate, non
  sono tutte nuove prove. Non sommare di nuovo l'unità ai suoi sottoprogrammi.
- Verifica finale dei quattro chiamanti Inertia.Assemble,
  Inertia_Phase.Assemble, Ensure_Jacobians ed Evaluate_Ready tutta riuscita
  sullo stesso sorgente della build numerica. Accumulo CRB 99+3, produttore
  78+8, preparazione spaziale 391+55 e lemmi di indice/configurazione hanno
  ricevute precedenti con corpi, contratti o ingressi sorgente coincidenti.
  Nessun Assume, nuova soppressione o modifica ad avvisi/deallocatori.
- Strict e Compatible passano ciascuna 624 scenari/168.192 confronti,
  atol=rtol=2e-10. Revisione riproducibile conserva ordine delle fasi e
  aritmetica floating-point; confini degli helper, riscritture dei flag e
  durata del buffer cambiano. Nessuna equivalenza binaria o temporale
  dichiarata. Riferimento C invariato: MuJoCo 3.14.0, mj_crb.
- Evidenza permanente: mass-frame-closure.zip/json, candidato completo in
  candidate-source/, 67 rapporti con tentativi incompleti distinti, 158 oggetti
  sorgente deduplicati, risultati numerici, probe e hash. Ripresa locale:
  /var/tmp/sparkling-mass-frame-20260927/source. Non riprendere dai precedenti
  obblighi di composizione: sono chiusi per questo candidato.
- DA FARE: modello funzionale completo della costruzione della massa, corpi
  delle altre unità di dinamica e due sessioni integrate prima dell'adozione.
  I contratti chiusi dimostrano sicurezza/limiti/simmetria/pubblicazione/frame
  sotto i contratti dei chiamati, non l'intera dinamica. Nessuna adozione:
  100 sorgenti attivi invariati, controllo CRB e tre scansioni Phase_Ready
  ancora presenti. Nessun nuovo guadagno di runtime attribuito al lavoro.

## Prima scansione adottata, 27 settembre

- SUPERSEDE lo stato isolato del candidato mass-frame. Integrata la massa e
  preparazione spaziale già provate insieme alla rimozione della scansione
  all'ingresso di Forces_Phase.Compute. Precondizione privata Is_Ready stabilita
  dai due chiamanti; API pubbliche invariate. Asserzione Static selezionata
  2 proof, file flow 13, zero aperti; cinque verifiche complete dei chiamanti
  50 proof +10 flow, zero aperti. Non dichiarare l'intero corpo delle forze
  provato sulla base della verifica selezionata.
- Pubblicazione Gravity/Bias annidata nel ramo del produttore: equivalenza
  per Used_Recursive inizialmente False, nessuna nuova inizializzazione runtime.
  La vecchia diagnostica flow è risolta esplicitando il ramo, senza soppressioni.
  Dipendenze mass-frame identiche; rimosso anche il controllo numerico CRB già
  dimostrato ridondante. Nessun cambiamento ad avvisi revisionati/deallocatori.
- Strict/Compatible: 624 scenari/168.192 confronti ciascuna. Confine pubblico:
  checked e release, entrambe le policy, 26 scenari/7.008 confronti ciascuna;
  i dati corrotti violano la precondizione checked, il guard release li rifiuta
  con Not_Allocated. Conteggio su 11 modelli: 1 Is_Ready +2 Phase_Ready/passo,
  risultati release identici. Controllo pubblico conservato.
- Due sessioni integrate quiete, 33 casi ciascuna: tutti migliorano con CI95
  interamente sotto 1 in entrambe. Riduzioni del tempo 2,2–10,6%, nessuna media
  globale; guadagno dell'intero pacchetto, non attribuzione alla sola scansione.
  C resta più veloce. Rapporto e tabella in docs/gold-performance-adoption.md.
- ADOTTATO: 106 hash attivi corrispondono al candidato misurato. Evidenze
  force-entry-scan-adoption.zip/json e force-entry-scan-performance.json;
  manifest precedente pre-force-entry-scan-active-source-match.json.
  Ripresa locale /var/tmp/sparkling-first-scan-20260927/source.
- DA FARE: readiness conservata dal corpo delle forze per togliere la scansione
  prima dell'attuazione, poi dal percorso accelerazione/soluzione prima di Euler.
  Restano il modello funzionale completo della massa, la costruzione diretta
  compatta e le altre famiglie del piano. Non ripetere la prima rimozione.

## Obiettivo esplicito: scansioni alla pari con C, 27 settembre

- Richiesta: continuare fino alla parità delle scansioni, oltre la prima rimozione.
  Il riferimento C mj_step esegue checkPos/checkVel/checkAcc (e i controlli dei
  controlli attuatore), senza scansioni globali ripetute di configurazione,
  massa e cache. Distinguere queste categorie nel conteggio finale.
- Partenza: versione adottata force-entry-scan, 106 sorgenti, 1 Is_Ready pubblico
  e 2 Phase_Ready interni. Candidato locale /var/tmp/sparkling-scan-parity-20260927.
- Prima chiudere la readiness prodotta dalle forze, poi dal percorso di
  accelerazione/soluzione; verificare anche se Valid_State all'ingresso pubblico
  permette un controllo costante senza cambiare il dominio dell'API.
- Per ogni adozione: prove minime poi composizione, Strict/Compatible, controlli
  dei rami di errore, conteggio eseguibile e due sessioni integrate quiete.

### Candidato scan-parity in corso

- Lavoro isolato in /var/tmp/sparkling-scan-parity-20260927/source, non adottato.
  Boundary.Ready usa il flag Allocated sotto Valid_State: equivalenza con
  Is_Ready provata, senza cambiare precondizioni pubbliche. Eliminati nel
  candidato i guard globali di Step, Actuation.Compute e Solve_Euler.
- Primo build trial1: entrambe le policy passano624scenari/168.192confronti.
  Strumentazione delle implementazioni dei predicati:0Is_Ready+0Phase_Ready
  per passo su11modelli; controllo positivo precedente1+2, output identici.
  Il builder ora congela gli overlay prima delle varianti: nel primo trial
  il file Forces differiva per annotazioni/prova tra current e checked.
  Ripetere build e test finali sul sorgente consolidato.
- Prove minime: buffer forze dense/ricorsive, integrazione per corpo,
  accumulo inverso e proiezione chiusi; conservazione dello stato in fase
  di composizione. Rifattorizzato il risolutore Strict in buffer readonly
  e scratch; aritmetica originale, obblighi numerici ancora in corso.
  Non dichiarare l'intera dinamica Gold né il candidato adottato.
- Test necessari prima di adozione: completare la catena readiness,
  verifica finale sorgenti, numerici Strict/Compatible, rami di errore,
  conteggio definitivo e due sessioni di performance senza carico concorrente.

### Checkpoint successivo del candidato scan-parity

- Nessuna modifica Ada adottata; repository ancora1+2scansioni. Trial2 usa
  overlay congelati: current/checked condividono gli stessi sorgenti Ada.
  Strict/Compatible:624scenari e168.192confronti ciascuna, tutti passati.
  Nuovo Step_Boundary_Checks: checked/release entrambe le policy passate,
  26scenari/7.008confronti ciascuna, inclusi empty, time_limit, invalid checked
  input e massa obsoleta con smorzamento implicito.
- Risolutore Strict separato in buffer readonly/scratch: chiusi i kernel
  scalari esatti, riduzioni con inviluppi binari, sostituzioni triangolari,
  controllo della condizione, modello ordinato per entrate LDL, copia
  accelerazione, Total_Forces, Fill_Total, Solve_Acceleration e Solve_Euler.
  Solve_Workspace e facade Solve ora chiusi (solver-close-v4). Rimane
  una precondizione quantitativa in Factor_Strict_Row: tentativo factor-row-cut.
  Fattorizzazione complessiva già chiusa sotto i contratti di riga.
- Forze: verifica intera unità forces-whole-v2 ha644proof con5VC non chiusi
  (7messaggi diagnostici); verifica selezionata sullo stesso file
  force-whole-residuals in corso, primi Forward_One_Body e Backward_Bodies
  chiusi. Non contare i timeout whole-unit come prove riuscite.
- Tutto in /var/tmp/sparkling-scan-parity-20260927. Proseguire con chiusura
  residui, controllo dei chiamanti/pipeline/Euler, build definitiva,
  numerici/conteggio e due sessioni quiete prima di adozione. Nessun commit/push.

### Chiusura della composizione solver/forze

- Factor_Strict_Row chiuso con taglio Static dimostrato dopo il ciclo: mantiene
  anche Result=Numeric_Limit sui rami di rifiuto. Nessuna assunzione. Tutti i
 14ambiti di final-solver-composition passano; Division_Bounded e Store_Work_Entry
  ricontrollati separatamente. Rimossi tre wrapper privati inutilizzati.
- Forze: tutti i residui whole-unit chiusi nei sottoprogrammi minimi; l'ultima
  modifica a Dense_Path riguarda solo il frame ghost di Configuration.
  I chiamanti Pipeline e Compute passano. Rimangono al momento Compute_Ready
  dell'attuazione (Storage_Ready) e Integrate/Step (frame/Inputs_Bounded).
- proof-ledger.json indicizza gli ambiti e verifica il corpo/dichiarazione
  locale normalizzato; la continuità di interfacce/costanti va auditata a parte.
  Non sommare selezioni duplicate o contare l'intero run con timeout come pass.
- Build-final è congelato prima degli ultimi aggiustamenti ghost: rifare build,
  prove/test finali e timing sul sorgente definitivo. Runtime attivo invariato.

### Ultimi ambiti Euler

- Attuazione chiusa: State_Query_Images e Compute_Ready, con frame posizioni,
  velocità e ingressi e le proprietà funzionali attuatore già presenti.
- Integrate_Buffers isola ora l'aggiornamento Euler dai metadati di Simulation:
  entrambi i rami di rifiuto conservano Q/V/tempo; successo realizza il modello
  Euler_Update. Il piccolo corpo passa. Ordine FP e aggiornamento differito
  invariati, Inline_Always; la pubblicazione continua a invalidare le cache.
- Il wrapper Integrate e la composizione Step sono ancora in verifica.
  Per le uguaglianze degli array anche i limiti dei range nulli sono espliciti:
  stessa First e uguaglianza dei valori non bastano a imporre Last su un array
  vuoto. State_Query_Bounds espone First/Last da Is_Ready; il lemma
  Equal_Euler_Inputs usa Same_Bounds e il modello FP ordinato.
- Nessun timing finale iniziato e nessuna modifica Ada adottata.

### Chiusura locale scan-parity e validazione definitiva

- Tutti gli 88 ambiti richiesti dal candidato hanno ricevute complete, con zero
  lacune nell'audit delle interfacce. Integrate chiuso; Step_Ready chiuso sia
  per_check sia per_path. I lemmi Equal_Euler_Values/Inputs rispettano l'uguaglianza
  floating point; State_Query_Layout conserva anche Last dei range vuoti.
  I dettagli delle query e dei predicati sono opachi nel coordinatore, senza
  cambiare contratti pubblici né introdurre assunzioni. Questi lemmi sono ghost.
- Build definitiva: /var/tmp/sparkling-scan-parity-20260927/build-validated.
  Checked/release condividono108 hash di sorgente; baseline106 hash invariati.
  Strict e Compatible passano624 scenari/168.192 confronti ciascuna.
- Al momento di questo checkpoint sono in corso il controllo dell'intera unità
  Euler e la conclusione dei test di frontiera/conteggio. Seguiranno due sessioni
  integrate quiete sul build definitivo; adozione solo dopo questi controlli.


### Adozione finale scan-parity

- ADOTTATI 8 file; 108 hash attivi identici alla build checked/release misurata.
  Il precedente manifest da 106 file è preservato. Zero nuove assunzioni o
  soppressioni; specifiche pubbliche immutate; prefisso massa/CRB invariato.
- 88 ambiti coperti, 0 lacune di interfaccia. Intera unità Euler: 160 proof + 31
  flow, 0 aperti. Strict/Compatible: 624 scenari e 168.192 confronti ciascuna.
  Otto esecuzioni di frontiera da 26 scenari e 7.008 confronti, tutte passate.
  Conteggio definitivo: 0 Is_Ready + 0 Phase_Ready per Step, su 11 modelli × 400
  passi. Controllo positivo baseline: 1 + 2; output numerici identici.
- Due sessioni quiete, 33 casi e 24 blocchi: ogni CI95 nuova/precedente sotto 1.
  Riduzione tempi: 17,8–41,7%; Ada/C: 0,72–1,70 secondo il caso. Nessuna media
  delle percentuali né attribuzione del guadagno solo ai predicati rimossi.
- Evidenze scan-parity-adoption.zip/json e scan-parity-performance.json.
  Restano i controlli numerici e delle API standalone, la costruzione della massa
  direttamente compatta e i modelli globali della massa/dinamica. Le scansioni
  globali interne non sono più il prossimo passo. Nessun commit/push.
