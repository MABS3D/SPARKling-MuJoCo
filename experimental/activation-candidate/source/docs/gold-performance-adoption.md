# Adozione progressiva delle ottimizzazioni Gold

Il piano persistente delle cinque famiglie è
[2026-09-26-gold-performance.md](../plans/2026-09-26-gold-performance.md).
Stato corrente del 27 settembre: **adottata la parità delle scansioni globali
nel percorso Euler release: 3 → 0, come C per questa categoria**. Tutti gli
88 ambiti richiesti dalla modifica hanno prove complete e continuità dei
contratti verificata; l'intera unità Euler chiude 160 proof + 31 flow.
Strict/Compatible passano 624 scenari/168.192 confronti ciascuna. Due sessioni
integrate confermano tempi per passo inferiori del 17,8–41,7% rispetto alla
precedente versione, in tutti i 33 casi. I controlli numerici e quelli delle API
standalone restano; la parità dei tempi con C e la dimostrazione della dinamica
completa sono questioni distinte. La sezione finale contiene le evidenze attuali;
i resoconti precedenti conservano i singoli checkpoint.

Aggiornamento successivo: [rimozione provata del controllo sulla gravità](force-guard-elimination.md), con 11 ambiti/295 obblighi chiusi. Il benchmark finale misura un risparmio del 3–7,4% sui principali modelli a catena e ramificati, con piccole regressioni documentate sulle cerniere. Il checkpoint delle scansioni sopra rimane la baseline storica; il nuovo report contiene gli hash e le evidenze della modifica successiva.

## Prima adozione: controlli delle pose

Sono attive tre sostituzioni in MJ.Data.Pipeline:

- Fixed_Position controlla Position: Center e le componenti di moto sono già zero.
- Fixed_Frame controlla velocità e bias lineari: gli altri campi hanno già i limiti richiesti.
- Finalize_Body_Frame controlla Center, il solo campo del predicato modificato qui.

Ciascun punto contiene un'asserzione Static che dimostra l'uguaglianza booleana
fra il vecchio Motion_Bounded e il nuovo controllo. Quindi si conservano anche
rifiuti ed errori, non solo risultati sui benchmark. Le formule floating-point,
le precondizioni e le postcondizioni originarie sono invariate. Nessun Assume,
nuova soppressione o modifica ai deallocatori. Sono riduzioni dei controlli
numerici locali (punto 3), non rimozioni delle tre Phase_Ready (punto 1).

| Sottoprogramma | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Fixed_Position | 34 | 4 | 0 |
| Fixed_Frame | 18 | 3 | 0 |
| Finalize_Body_Frame | 14 | 5 | 0 |
| Build_One_Body, chiamante invariato | 52 | 4 | 0 |
| Totale | 118 | 16 | 0 |

Questa è la chiusura delle quattro routine e delle loro proprietà esistenti,
con l'equivalenza dei nuovi controlli. Non è una nuova prova dell'intera Pipeline
o della dinamica completa. Il manifest documenta la continuità esatta dei corpi
verificati prima/dopo l'aggiunta dell'ultimo assert Static in Fixed_Position.

## Validazione della prima adozione

Strict e Compatible: ciascuna passa 624 scenari e 168.192 confronti, compresi i
casi limite e i modelli di fallback. Due sessioni integrate, ciascuna con
11 modelli × 3 stati × 24 blocchi × 3 eseguibili × 4 campioni da 100 passi:
4.752 processi, 1.900.800 passi cronometrati in totale, oltre ai warm-up.
Affinità CPU 12, Ryzen7 9800X3D, GNAT 16.1 O3/LTO/march=native, stessa semantica
FP precedente; C MuJoCo 3.14.0 normale SIMD. Nessuna prova/build/test concorrente
nelle finestre di timing. Risultati finali Ada serializzati bit per bit identici; errore
massimo rispetto a C 3,8914e-14 nei benchmark.

Riduzione del tempo totale, intervallo delle mediane fra stati e sessioni
(non un CI né una media globale):

| Modello | Riduzione tempo | CI95 sotto 1, su6 |
|---|---:|---:|
| hinge_motor | 4,16–4,94% | 6 |
| simple_sliders_6 | 1,60–2,34% | 6 |
| simple_hinges_6 | 0,22–0,80% | 4 |
| simple_mixed_8 | 0,23–0,70% | 4 |
| chain_12 | 0,00–1,10% | 1 |
| crb_no_damping | −0,32–0,33% | 1 |
| branched_multijoint | −0,73–0,17% | 0 |
| crb_chain_24 | −0,34–0,57% | 0 |
| ancestor_star_24 | −0,22–0,87% | 1 |
| ancestor_forest_24 | −1,10–0,75% | 0 |
| ancestor_branches_24 | −0,50–0,68% | 0 |

Nessuno dei 66 confronti ha CI95 interamente sopra 1. Questo non dimostra assenza
di ogni possibile regressione: sui modelli grandi non è stabilito un guadagno.
L'adozione è sostenuta dal miglioramento ripetuto nei due carichi indicati e
dall'equivalenza formale; non da un conteggio non pesato di modelli più veloci.
CI bootstrap appaiati entro sessione, nessuna correzione per confronti multipli.
Le prestazioni Strict non sono state misurate da questo benchmark Compatible.

## Tentativo non adottato: inlining del prodotto spaziale

Inline_Always(Multiply) conserva formula e ordine e passa 154 obblighi proof,
i test numerici di entrambe le policy e due sessioni complete. I risultati
sono però misti: guadagni piccoli nei casi semplici, nessun beneficio convincente
sui 24 DOF e fino a +1,2% su ancestor_branches_24. Due CI isolati interamente sopra 1,
in stati diversi nelle due sessioni: non prova una regressione universale.
Non adottato come soluzione al divario sui 24 DOF. SIMD resta abilitato.

## Smorzamento: controllo dimostrato ridondante, varianti non adottate

Il lemma Static `Prove_Damping_Bound` dimostra che il calcolo floating-point
`Previous + Step * Damping` resta in Work_Real per gli intervalli già richiesti:
Previous entro ±1e60, Step e Damping fra 0 e 1e10. È una prova dell'operazione
arrotondata, non un'asserzione sulla somma reale. Il corpo del lemma è nullo e
verificato; nessun Assume o dominio ristretto aggiunto. Il chiamante mantiene
esattamente espressione e assegnazione originarie, sostituendo il solo rifiuto
con una chiamata ghost e un'asserzione Static.

La completa unità Solver_Kernels chiude 104 verifiche proof, incluse le3 del
lemma; altri 7 controlli selezionati dimostrano gli argomenti al chiamante e
l'asserzione sostitutiva. Non è una chiusura completa di Load_Ancestor_Factor,
che conserva obblighi di frame/stato non inclusi in questo esperimento.
C mj_EulerSkip aggiorna direttamente la diagonale e mantiene il successivo
controllo del pivot; il candidato conserva la nostra politica di pivot/errori.

La prima forma usava un helper runtime con array in out e flag Accepted;
la seconda usa soltanto il lemma ghost. Entrambe passano Strict e Compatible,
624 scenari/168.192 confronti per policy, e due sessioni integrate ciascuna.
La seconda conserva i risultati serializzati dei benchmark bit per bit. Tuttavia i tempi
sono misti anche eliminando il solo ramo: sui sei slider −1,39..2,15% con 6/6
CI95 sotto 1, sul giunto motorizzato +0,91..1,34% con 6/6 CI95 sopra 1. Nessun
beneficio stabilito sulla catena24 o sulla foresta24. Queste varianti restano
NON ADOTTATE: la prova di ridondanza è riutilizzabile, il beneficio integrato
non è generale. Non si attribuisce automaticamente ogni differenza al costo
del ramo, perché può cambiare anche il codice generato.

Evidenze separate: damping-proofs.zip, damping-helper-trial.zip e relativa
summary per la prima forma; damping-ghost-proofs.zip, damping-ghost-trial.zip
e damping-ghost-summary.json per la seconda. Non sommare i conteggi delle
prove del lemma e dell'unità che lo contiene, né i guadagni dei due esperimenti.

## Prerequisito RNE integrato, fusione ancora da collegare

La nuova unità MJ.Fused_RNE è integrata come libreria indipendente. Definisce
l'accelerazione del mondo con gravità negativa e la forza arrotondata di un
corpo `I*a + v ×* (I*v)`. Il contratto specifica l'espressione FP, i due rami
di rifiuto, l'equivalenza del flag Ok ai limiti richiesti e l'uscita nulla
in caso di rifiuto. La prova dell'intera nuova unità chiude 34 obblighi proof
più 10 flow; i test checked e O3/gnatp passano anche sui due rami di rifiuto.

Il passo di simulazione non chiama ancora il nuovo helper. Quindi questo
intervento non completa il punto4 e non ha un risultato di accelerazione
integrata. Il collegamento richiede scratch separato, ricorsione sull'albero,
formula della forza totale con ordine FP esplicito e preservazione delle API
Gravity/Bias anche sulle uscite per errore. Il progetto di integrazione è in
`tests/movement_performance/gold_adoption/fused-rne-integration.md`.
Le prove e i test del nuovo nucleo non dimostrano l'intera dinamica o un limite
d'errore rispetto all'aritmetica reale.

## Preparazione delle scansioni ancora aperta

Le tre Phase_Ready restano, insieme a Is_Ready all'ingresso di Step.
Il rinforzo Static di Spatial_Storage è adottato:104 obblighi proof chiusi,
corpo eseguibile invariato e vecchi contratti esatti di valore/frame mantenuti.
Il rebuild finale ha sezioni .text, .rodata e .data identiche al binario pose
misurato, pur avendo un diverso hash ELF. Non viene attribuito un nuovo guadagno
alle sole annotazioni Static o al nuovo helper RNE ancora inutilizzato.

Ulteriori risultati sono conservati come preparazione, separati dal codice attivo:

- Mass_Publication: completa unità chiusa 64/64; dipendenze Matrix_Offset 6/6 e
  Prove_Configuration_Equality 28/28. Un wrapper del produttore in sola lettura
  chiude 4/4. Rimuovendo Relaxed_Initialization dall'array che il produttore
  inizializza integralmente, il wrapper d'integrazione arriva a 6/7: le
  precondizioni di Publish passano. L'unica diagnostica residua riguarda la
  simmetria, ma la postcondizione combinata rimane aperta, quindi nemmeno il
  frame è dichiarato complessivamente chiuso. Il successivo tentativo con
  predicato opaco termina per timeout.
  Nessuna adozione: anche i corpi dei produttori chiamati restano da chiudere.
  Evidenza nuova in mass-publication-followup.zip, distinta dalla bozza iniziale.
- Preparazione spaziale: Build_Centers 42/42 e piccoli helper esatti chiusi;
  l'ultimo follow-up chiude anche la direzione del giunto (4/4). Build_Buffers
  emette 94 controlli con 3 obblighi residui su prefisso scritto, corrispondenza
  con i giunti del corpo e limite finale. Prepare conserva gli obblighi di
  pubblicazione/frame. Sorgenti e diagnostica in spatial-motion-followup.zip.
- Lifecycle compatto: Reset resta 43 verifiche con 1 aperta sulla configurazione;
  Build_Topology ristretto e Initialize sono bozze con timeout, non prove chiuse.

I tentativi sulla preparazione spaziale e sulla pubblicazione/soluzione sono
archiviati con i rispettivi timeout, crash del compilatore e obblighi aperti;
zero obblighi emessi non è un esito positivo. Il lavoro si sta concentrando su
helper che modificano buffer circoscritti e specificano esattamente ciò che
preservano. Nessuno dei contratti ancora aperti autorizza altre rimozioni.

## Accumulazione CRB: prerequisiti chiusi, controllo ancora attivo

Il candidato segue l'accumulazione dei corpi negli antenati di `mj_crb` in C,
mantenendo l'ordine delle somme floating-point. La contabilità ghost associa
un numero di contributi a ogni inerzia composita e conserva il totale durante
il trasferimento figlio-genitore. Non aggiunge lavoro al programma eseguibile.

| Ambito locale | Verifiche chiuse | Ancora aperte |
|---|---:|---:|
| Limiti della somma FP, Composite_Bounds | 39 | 0 |
| Trasferimento/conservazione interi, Composite_Weights | 99 | 0 |
| Modello esatto del ciclo controllato originario | 31 | 0 |
| Lemma di espansione del modello | 16 | 0 |
| Ciclo Accumulate_Composite completo | 65 | 10 |

La dipendenza Spatial_Kernels.Add è verificata nuovamente con 26 verifiche.
L'asserzione che sostituirebbe il controllo numerico passa sotto gli invarianti;
alcuni di questi invarianti e la postcondizione del ciclo non sono ancora chiusi.
Questo impedisce l'adozione. Un ulteriore tentativo che nasconde Prefix_Sum
termina per timeout senza report finale: non è un miglioramento dimostrato.
Il modello mantiene anche il comportamento del vecchio ramo di rifiuto;
nessun dominio ristretto, Assume o contratto funzionale indebolito.

Gli archivi crb-bound-proofs.zip e crb-weight-proofs.zip contengono le unità
ghost chiuse. crb-accumulation-draft.zip conserva modelli, ciclo incompleto,
tentativo successivo e sorgenti esatti. Non sono sorgenti attivi né risultati
di accelerazione del simulatore.

Anche il follow-up del reset compatto è conservato separatamente in
compact-reset-followup.zip: il lemma di espansione di Configuration chiude
13 proof + 1 flow, mentre il chiamante completo termina per timeout. Resta
valido soltanto il risultato precedente di 43 verifiche con una ancora aperta.

Evidenze, script di ricostruzione e hash:
`tests/movement_performance/gold_adoption/`. La ricevuta storica pose-adoption-source-match.json
conserva i 98 sorgenti della prima adozione, inclusi benchmark e probe. La ricevuta
active-source-match.json distingue i 97 rimasti identici, la specifica Static
rinforzata e i 2 nuovi sorgenti RNE ancora inutilizzati dal passo. Il confronto
del rebuild finale è archiviato.

## Ripresa del 27 settembre: solver con buffer circoscritti

Il nuovo candidato isola `Solve_Compatible_Buffers`: può modificare soltanto
fattore, soluzione e diagnostica del pivot. Conserva struttura, formule e ordine
del percorso precedente, confrontato nuovamente con `mj_factorI` e `mj_solveLD`
del C fissato. Due helper specificano esattamente l'aggiornamento di un prefisso
e di una singola cella. Il wrapper conserva configurazione, stato, ingressi e
cache su tutte le uscite.

| Sottoprogramma | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Add_Prefix_Row | 12 | 2 | 0 |
| Store_Work_Entry | 4 | 1 | 0 |
| Solve_Compatible_Buffers | 80 | 6 | 0 |
| Solve_Compatible, wrapper | 8 | 11 | 0 |
| Totale distinto | 104 | 20 | 0 |

La prova del nucleo copre sicurezza, limiti dei risultati sul successo e
conservazione della diagnostica già presente. **Non è un refinamento funzionale
dell'intera soluzione lineare**, né la chiusura di Solve, dei suoi altri rami
o della fase. I modelli esatti dei due piccoli helper sono invece verificati.
La ricevuta controlla l'identità dei quattro sottoprogrammi nei rispettivi
snapshot finali e la continuità delle dipendenze già provate: Ancestor_Rows,
Solver_Kernels, Solver_Reductions e Bounds_Kernels. Nei primi due cambiano
soltanto commenti della specifica rispetto alle ricevute riutilizzate.

Strict e Compatible passano ciascuna 624 scenari e 168.192 confronti con C.
Il replay di 40 output precedenti è identico. Il probe di errore inietta
fallimenti in ogni posizione della prima riga aggiornata: rifiuto, diagnostica,
stato/ingressi invariati e ripartenza con scratch precedentemente alterato
passano sia checked sia con gli stessi flag release O3/LTO della simulazione.

Due sessioni integrate senza job concorrenti conservano tutti i 167.616 valori
finali serializzati bit per bit. Tuttavia i sei slider rallentano di
0,92–2,23%, con tutti i sei CI95 sopra 1; la foresta24 ha un CI sopra 1 nello
stesso stato in entrambe le sessioni. I guadagni su altri casi sono piccoli o
incerti. **Candidato NON ADOTTATO nel runtime attivo**: resta una preparazione
verificata da rivalutare insieme alla futura rimozione delle scansioni.
Le tre Phase_Ready restano attive. La tabella completa e i dati grezzi sono in
solver-buffer-performance-summary.json e solver-buffer-validation.zip;
solver-buffer-proofs.zip conserva anche i tentativi precedenti, senza contarli
nuovamente come prove chiuse. Non si attribuisce automaticamente il costo
osservato a una singola istruzione: il refactoring cambia anche il codice generato.

Una seconda variante aggiunge soltanto `Inline_Always(Solve_Compatible_Buffers)`:
i quattro sottoprogrammi/contratti provati sono identici tolto questo pragma.
Replay checked di entrambe le policy e probe release di fallimento passano;
i 167.616 valori finali dei due benchmark restano identici bit per bit.
L'inlining anticipato produce però mediane peggiori per tutti i casi nelle due
sessioni, con 63 CI95 su66 interamente sopra1. Sui sei slider il rallentamento è
5,68–6,65%. Anche questa forma è NON ADOTTATA. solver-inline-trial.zip conserva
fonte, flag, risultati e continuità delle prove; la tabella separata evita di
mescolare le due varianti. La review indipendente in solver-source-review.zip
confronta la sequenza algoritmica della prima forma dopo l'espansione degli
helper; non è una prova dell'equivalenza dei binari prodotti dal compilatore.

## Ripresa CRB: passo esatto chiuso, composizione ancora aperta

Quattro nuovi lemmi chiudono 72 verifiche distinte: singola componente del
modello (17), estensionalità degli array annidati (4), estensione del prefisso
(8), equivalenza del passo completo al precedente modello controllato (43).
Formule e modello di rifiuto originali restano identici. Il nuovo tentativo del
ciclo Accumulate_Composite chiude 69 verifiche su 77: restano otto obblighi
sull'inizializzazione, conservazione e conclusione degli invarianti/modello.
Le nuove precondizioni del lemma di passo passano, ma non bastano a rimuovere
il controllo numerico attivo. L'archivio crb-step-composition-evidence.zip
conserva separatamente questi due risultati e le fonti esatte. Non è un limite
matematico documentato: è lavoro di prova ancora da completare.

Un ultimo taglio minimo chiude il lemma di inizializzazione (4 proof +1 flow).
La sua precondizione nel chiamante è provata, ma il singolo obbligo di
inizializzazione dell'uguaglianza resta aperto (1/2 nel run mirato). Non è stata
rieseguita né dichiarata chiusa l'intera accumulazione. Fonti e risultati in
crb-initialization-checkpoint.zip, che conserva anche il checkpoint69/77.

## Pubblicazione massa: ramo ristretto e modello della configurazione

Il ramo Try_Ready_CRB, chiamato dopo la preparazione spaziale, chiude6/6;
Equal_Configurations è verificato nuovamente con22/22. Il wrapper che comprende
Prepare resta4/5: non è ancora chiuso il frame della configurazione. La prova
del produttore CRB originario resta anch'essa incompleta. La separazione dei
postcondizionamenti non risolve l'obbligo e non viene contata come progresso.

Una variante indipendente rende la snapshot Configuration un costruttore ghost
con soli argomenti readonly. Chiude64/64, inclusa l'equivalenza totale alla
precedente espressione anche per stati vuoti/incompleti. Non aggiunge precondizioni
pubbliche e non cambia l'uguaglianza. Poiché il wrapper resta aperto anche con
questa forma, il modello è conservato separatamente e non adottato globalmente.
mass-publication-split-followup.zip e configuration-image-followup.zip registrano
esattamente questi ambiti e gli input di prova. Nessun vantaggio di runtime o
rimozione di scansioni deriva da queste prove locali.

## Buffer spaziali: composizione locale chiusa

Il nuovo checkpoint chiude Write_Joint_Motion20/20, Build_Body_Motions70/70,
Build_One_Body62/62 e Build_Buffers66/66. I primi tre helper specificano valori
esatti, limiti e frame, compresi gli aggiornamenti parziali sui rifiuti. Il
contratto del composer Build_Buffers garantisce sicurezza e limiti sul successo:
**non espone ancora un modello funzionale completo dell'intero risultato**.
Anche Build_Centers non specifica l'intero accumulo ordinato nel proprio post.
La review indipendente non rileva cambiamenti alle formule, all'ordine FP o
alle scritture prima di un fallimento; distingue queste verifiche di sorgente
dai risultati formali effettivamente dichiarati dai contratti.

Due ponti ghost di Prepare chiudono5/5 ciascuno, ma Prepare completo termina
al limite di100s senza obblighi emessi. Non è una prova chiusa e non autorizza
alcuna scansione in meno. Il checkpoint finale passa624 scenari e 168.192
confronti con C in **Compatible**, più7 casi di normalizzazione e14 casi
di policy eseguiti dal runner in Strict. Questi14 casi non equivalgono alla
suite624 in Strict. Candidato non adottato nel runtime e nessuna accelerazione
attribuita; prova, test e revisione sono conservati nel suo handoff.
L'archivio persistente è spatial-motion-composer-evidence.zip, con sorgente
finale e ricevute di continuità delle dipendenze. Il manifest dei100 sorgenti
attivi resta interamente invariato dopo questa ripresa.

## Preparazione spaziale: intera unità chiusa

Il nuovo Prepare_Buffers riceve configurazione, pose e topologia in sola lettura
e modifica soltanto inerzie, moti e validità spaziale. Prepare richiama questa
routine e conserva le proprie precondizioni/postcondizioni pubbliche originali.
Gli helper del checkpoint precedente sono byte per byte invariati. Il confronto
di sorgente delle istruzioni, sostituendo i parametri ai campi originali e
togliendo soltanto la strumentazione ghost, conserva ordine, rifiuti, scritture
parziali e uscita sulla cache già valida. Non è una prova di equivalenza binaria.

| Ambito | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Nuovo Prepare_Buffers | 34 | 3 | 0 |
| Wrapper Prepare | 8 | 20 | 0 |
| Intera MJ.Data.Spatial, inclusi i due precedenti | 391 | 55 | 0 |

La prova completa chiude i contratti presenti: sicurezza, limiti, cache,
conservazione di configurazione/stato/ingressi e formule esatte degli helper
locali. **Non chiude ancora un modello funzionale globale dell'accumulo ordinato
dei centri e di tutti i buffer**, né la dinamica completa. La bozza che aggiunge
il modello esatto delle inerzie è archiviata separatamente: due lemmi minimi
chiudono 6 e 8 proof, ma corpo/composer terminano per timeout. Non viene mescolata
con il sorgente della prova completa riuscita.

La prima invocazione completa con quattro worker lascia due obblighi aperti;
quella finale aggiunge Z3 mantenendo esattamente gli stessi sorgenti e la cache
di prova valida, e termina con zero obblighi aperti. Entrambe le ricevute sono
conservate, insieme al precedente timeout. Nessun Assume o controllo soppresso.
I conteggi locali non vanno sommati nuovamente ai 391 dell'intera unità.

Il probe checked costruito dallo stesso snapshot passa **624 scenari e 168.192
confronti per ciascuna policy, Strict e Compatible**, contro C 3.14.0. Sono test
differenziali, non una dimostrazione universale di equivalenza con C. Riesaminati
anche mj_comPos e mj_crb del riferimento fissato.

Fonti esatte, comandi, hash, tentativi incompleti, probe e risultati grezzi sono
in spatial-prepare-closure.zip; spatial-prepare-closure.json delimita la chiusura.
I 100 sorgenti del manifest attivo restano invariati. Nessun nuovo benchmark
integrato è stato eseguito per questa forma, quindi non viene adottata nel
runtime e non si attribuisce un'accelerazione. La chiusura è un prerequisito
per proseguire la composizione delle fasi e la rimozione delle scansioni.

## CRB: inizializzazione chiusa e quattro obblighi residui

Le asserzioni esplicite sull'immagine iniziale chiudono l'inizializzazione
dell'invariante di uguaglianza al modello. La ricevuta mirata contiene nove
record proof tutti dimostrati; non è un totale dell'intero ciclo. Include anche
flow dell'intero file, con un avviso di assegnazione inutilizzata conservato.

Il checkpoint successivo usa direttamente lo stato del modello ricorsivo come
testimone ghost Before. Il modello controllato originale e il lemma del passo
esatto sono byte per byte invariati. Con il limite artificiale di passi del
prover disattivato, la verifica dell'intero Accumulate_Composite chiude
**79 dei 83 obblighi proof e tutti i 3 flow**. Il precedente checkpoint era69/77;
il denominatore cambia per i nuovi passaggi di prova, non per obblighi rimossi.

Restano aperti:

- Il limite della somma del testimone nella precondizione del lemma di passo.
- La conservazione del limite pesato delle inerzie.
- La conservazione dell'uguaglianza degli array al modello ricorsivo.
- L'uguaglianza finale nella postcondizione.

Un lemma minimo sulla singola componente della somma chiude13proof+1flow.
Sono chiusi anche piccoli lemmi di proiezione e uguaglianza, registrati
individualmente nell'archivio; questo non implica la chiusura della loro
composizione. I tentativi successivi su somma completa e proiezione dello stato
terminano per timeout senza un nuovo risultato completo. La copia di lavoro
è ripristinata esattamente al checkpoint 79/83, verificando tutti i104file del
manifest di prova; le bozze successive restano separate e riproducibili.

crb-model-continuation.zip/json conservano fonti, ricevute, diagnostiche e
ambiti. Il corpo eseguibile del candidato non cambia rispetto alla precedente
bozza CRB; cambiano soltanto testimoni, lemmi e asserzioni ghost. **Il ciclo
resta incompleto e il controllo numerico nel programma attivo resta presente.**
Gli obblighi locali dimostrati sotto gli invarianti non autorizzano a rimuoverlo
finché tutti gli invarianti e le precondizioni non sono chiusi. Nessun limite
matematico invocato, nessuna scansione aggiuntiva rimossa, nessun nuovo risultato
di prestazione attribuito.

## Chiusura dell'accumulo CRB

SUPERSEDE il checkpoint 79/83 per il sottoprogramma Accumulate_Composite.
La nuova prova completa chiude **99 obblighi proof e 3 flow, zero aperti**:
inizializzazione e conservazione di tutti gli invarianti, precondizioni dei
lemmi chiamati, limiti numerici e postcondizione funzionale finale. Il risultato
è ottenuto su uno snapshot immutabile con CVC5/Z3/Alt-Ergo, 3 s per verifica,
senza limite artificiale di passi; esecuzione completata in 223 s. Non è una
somma di verifiche di righe isolate e non usa Assume o nuove soppressioni.

Per array con 1..4096 corpi, genitori precedenti ai figli e componenti iniziali
entro ±1e36, l'accumulo conserva componenti entro ±1e40 e coincide con il
precedente modello controllato, che termina con successo. Le precondizioni e
la postcondizione originarie sono identiche. Anche Model_Step,
Accumulation_Model e il precedente lemma di aggiornamento rimangono invariati.
L'ordine delle somme e il passaggio inverso sui corpi restano quelli di mj_crb
in C 3.14.0; il modello conserva il vecchio ramo di rifiuto e la prova dimostra
che non viene preso nel dominio dichiarato.

| Nuovo lemma ghost | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Prove_Inertia_Sums_Equal | 21 | 1 | 0 |
| Transfer_Inertia_Bound | 3 | 1 | 0 |
| Preserve_Weighted_Prefix | 32 | 1 | 0 |
| Reveal_Accumulation_Values | 22 | 1 | 0 |
| Advance_Accumulation_Model | 37 | 1 | 0 |
| Retire_Weight | 19 | 1 | 0 |
| Expose_Inertia_Equality | 1 | 1 | 0 |
| Describe_Model_Update | 28 | 1 | 0 |
| Totale nuovi lemmi, distinto dal ciclo | 163 | 8 | 0 |

La somma è collegata al modello tramite le dieci componenti già provate; due
lemmi separano la contabilità intera e i limiti pesati dalla scrittura effettiva
dell'array. Un ulteriore ponte espone direttamente i valori del passo ricorsivo.
Tutto questo lavoro è ghost. La revisione riproducibile verifica che le
istruzioni eseguibili del candidato precedente, escluse strumentazione dei
contratti e codice ghost, siano identiche. È una revisione del sorgente, non
una prova di equivalenza dei binari.

Le dipendenze riutilizzate sono confrontate con i loro sorgenti provati:
Composite_Bounds 39, Composite_Weights 99, Spatial_Kernels.Add 26, i modelli
originari 31, i quattro lemmi del passo 72 e l'inizializzazione 4. Sono inoltre
identici i tre piccoli lemmi riutilizzati per componenti, righe e transitività.
Le ricevute originali e i confronti sono conservati senza contarli come nuove
prove del turno. Il tentativo intermedio 97/100 e il precedente timeout restano
separati dal risultato finale riuscito.

Il probe checked dello stesso sorgente passa **624 scenari e 168.192 confronti
per ciascuna policy**, Strict e Compatible, inclusi i modelli CRB e ramificati
a 24 DOF. Sono distinti dai due controlli iniziali più piccoli da 360 scenari.
Sorgenti, prove, dipendenze, comandi, probe e risultati grezzi sono in
crb-accumulation-closure.zip/json, con hash verificati.

Questa è la chiusura funzionale dell'**accumulo delle inerzie composite**.
Restano l'integrazione nel produttore di massa attivo e nei suoi chiamanti,
e le misure integrate prima dell'adozione. Non chiude l'intera costruzione della
massa né la dinamica completa. I 100 sorgenti attivi restano invariati: controllo
numerico CRB e tre scansioni interne ancora presenti, nessun guadagno di runtime
attribuito a questa prova.

## Precondizioni CRB nei chiamanti

Il candidato integra la preparazione spaziale già verificata con l'accumulo
CRB provato. Le precondizioni del chiamante originario Try_Assemble_CRB e tutte
le specifiche di package esistenti sono invariate: Is_Ready, Pose_Valid e
Spatial_Valid forniscono già struttura dei genitori, dimensioni e limiti iniziali.
Non è stata aggiunta una scansione runtime per stabilire queste proprietà.

Il caricamento del buffer contiguo è separato in Load_Composite: prova
l'inizializzazione completa, il limite ±1e36 e l'uguaglianza esatta di ogni
componente alla sorgente. Zero_CRB_Mass specifica l'azzeramento esatto.
Fill_CRB_Mass riceve soltanto topologia, inerzie composite, moti e massa;
la restrizione dei parametri evita di trascinare l'intero stato nelle prove
del ciclo sugli antenati. Il suo contratto conserva limiti e simmetria: non
è ancora il modello funzionale completo della costruzione della massa.

| Ambito completo | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Load_Composite | 23 | 1 | 0 |
| Zero_CRB_Mass | 4 | 2 | 0 |
| Fill_CRB_Mass | 37 | 2 | 0 |
| Try_Assemble_CRB | 14 | 3 | 0 |
| Totale produttore/chiamante | 78 | 8 | 0 |
| Ingresso pubblico MJ.Data.Inertia.Assemble, invariato | 2 | 2 | 0 |

Try_Assemble_CRB chiude l'intero suo contratto attuale e tutte le chiamate:
caricamento, accumulo e riempimento della massa. L'accumulo 99+3 e i suoi
lemmi sono identici al sorgente già provato; non sono conteggiati di nuovo.
Anche la preparazione spaziale corrisponde esattamente alla precedente unità
391+55. Nessun Assume, nuova soppressione o modifica ai deallocatori.

In Assemble sono chiuse **separatamente entrambe le precondizioni** alle
chiamate Spatial.Prepare e Try_Assemble_CRB: due obblighi selezionati, non una
prova dell'intero sottoprogramma. Il tentativo completo di Assemble termina
per timeout a 160 s senza un risultato finale. È chiusa anche l'asserzione
Static Phase_Ready che precede le due chiamate, inclusa la sua precondizione
(2 obblighi selezionati), quindi non è lasciata come ipotesi non verificata.
Nella pipeline invariata,
Evaluate_Ready dimostra la precondizione della chiamata a Inertia_Phase.Assemble,
ma il suo controllo completo lascia **1 obbligo aperto su 41 proof**, relativo
alla postcondizione di conservazione di State_Values. Sono lavori di prova
ancora pendenti, non limiti matematici.

Il confronto riproducibile del sorgente espande i tre nuovi helper e verifica
che le istruzioni eseguibili coincidano con quelle del precedente candidato
CRB, escluse le sole annotazioni. Ordine floating-point e rami di rifiuto
residui sono conservati. Non è una prova di equivalenza dei binari. La struttura
è confrontata con mj_crb di MuJoCo C 3.14.0, riferimento già fissato.

Il probe checked del sorgente finale passa **624 scenari/168.192 confronti
per ciascuna policy**, Strict e Compatible. crb-callers-closure.zip/json
conservano sorgenti, prove riuscite, tentativi intermedi distinti, confronto
del sorgente, risultati numerici e manifest con hash. Il tentativo interrotto
con selettori di riga errati è marcato esplicitamente e non conta come prova.

**Candidato isolato, non adottato.** I 100 sorgenti attivi sono invariati;
controllo numerico CRB e tre scansioni interne restano presenti. Restano la
composizione completa di assemblaggio/stato, il modello completo della massa
e le due sessioni di prestazione integrata prima dell'adozione. Nessun nuovo
guadagno di runtime è attribuito a queste prove.

## Composizione dell'assemblaggio e conservazione dello stato, 27 settembre

Il candidato `mass-frame-closure` chiude l'intero contratto attuale di
`MJ.Data.Inertia_Phase.Assemble` e la composizione di `Evaluate_Ready`, inclusa
la conservazione di `State_Values`. Questo risultato supera, per il nuovo
sorgente isolato, il timeout di Assemble e il precedente 40/41 di Evaluate_Ready.
Le precondizioni pubbliche e la specifica di Inertia_Phase restano invariate.

Le prove partono dai sottoprogrammi minimi. Il percorso CRB, quello denso e la
pubblicazione della massa hanno ora confini separati, con contratti sulla
conservazione di stato, configurazione, ingressi e buffer. `Ensure_Jacobians`
riceve postcondizioni Static più forti nel package privato Pipeline: conserva
la massa e, quando presenti in ingresso, i suoi limiti e la sua simmetria.
Queste proprietà sono dimostrate, senza rafforzare le precondizioni.

| Ambiti completi selezionati, raggruppati senza duplicati | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Assemble_Ready e Inertia_Phase.Assemble | 36 | 5 | 0 |
| Build_And_Publish_CRB e Assemble_CRB_Path | 34 | 6 | 0 |
| Fill_Dense_Ready, Fill_And_Mark_Mass e Assemble_Dense_Path | 70 | 11 | 0 |
| Prove_Dense_Inputs, Expose_Assembly_Layout, Reset_Mass e Ready_Properties | 36 | 4 | 0 |
| Assemble_Dense_Mass | 59 | 3 | 0 |
| Prepared_Mass_Contribution, Prepare_Mass_Columns e Store_Symmetric | 62 | 5 | 0 |
| Refresh_Jacobian_Buffers e Ensure_Jacobians | 26 | 19 | 0 |
| Evaluate_Inertia_Forces, Evaluate_Actuation_Acceleration e Evaluate_Ready | 62 | 6 | 0 |
| Intera unità MJ.Data.Mass_Publication, incluso Mark_Ready | 74 | 10 | 0 |
| Totale dei 21 ambiti selezionati | 459 | 69 | 0 |

Il totale comprende dipendenze già esistenti ricontrollate: non rappresenta
459 nuove proprietà funzionali. Non include di nuovo l'accumulo CRB 99+3,
il produttore CRB 78+8 o la preparazione spaziale 391+55, i cui sorgenti provati
sono conservati. Anche i lemmi Matrix_Offset e Prove_Configuration_Equality
riusano ricevute precedenti con gli stessi ingressi sorgente.

Una verifica finale dei quattro chiamanti Inertia.Assemble,
Inertia_Phase.Assemble, Ensure_Jacobians ed Evaluate_Ready passa sul sorgente
esatto usato per i test numerici. Non sommare questi controlli ripetuti al
totale della tabella. Nessun Assume, nuova soppressione, modifica agli avvisi
esistenti o ai deallocatori.

Il confronto con `mj_crb` di MuJoCo C 3.14.0 resta fissato al commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. La revisione del sorgente verifica
l'identità dei produttori CRB e della preparazione spaziale, l'ordine delle
cinque fasi e delle operazioni floating-point del percorso denso, espandendo
i contratti dei piccoli helper di indice e scrittura. La scrittura simmetrica
sulla diagonale scrive due volte lo stesso valore nella stessa posizione.
Sono cambiati i confini dei sottoprogrammi, alcune riscritture dei flag e la
durata del buffer candidato: non si afferma equivalenza binaria o temporale.

Strict e Compatible passano **624 scenari e 168.192 confronti ciascuna**, con
tolleranze assoluta e relativa 2e-10, inclusi i modelli ramificati a 24 DOF e
i casi di ripiego dal CRB. Il probe checked è identico per le due policy;
gli hash del sorgente corrispondono alla verifica finale dei chiamanti.

[mass-frame-closure.json](../tests/movement_performance/gold_adoption/evidence/mass-frame-closure.json)
registra gli ambiti accettati;
[mass-frame-closure.zip](../tests/movement_performance/gold_adoption/evidence/mass-frame-closure.zip)
contiene il candidato completo in `candidate-source/`, 67 rapporti di prova,
158 oggetti sorgente deduplicati, comandi, revisione e risultati numerici.
I tentativi falliti, scaduti e superati sono distinti dalle prove accettate.
Gli hash interni e quelli dell'archivio sono verificati. Il punto di ripresa
locale è `/var/tmp/sparkling-mass-frame-20260927/source`.

Sono chiusi i contratti attuali di sicurezza, limiti, simmetria, pubblicazione
e conservazione dello stato **sotto i contratti dei chiamati**. Restano il
modello funzionale completo della costruzione della massa e le prove dei
corpi delle altre unità necessarie alla dinamica completa: forze, attuazione,
soluzione e integrazione. Non sono limiti matematici documentati.

**Candidato isolato, non adottato.** Tutti i 100 hash dei sorgenti attivi
corrispondono ancora al manifest. Controllo numerico CRB e tre scansioni interne
Phase_Ready restano presenti. Nessuna misura di prestazione nuova o scansione
rimossa: servono le due sessioni integrate senza carico concorrente prima
dell'adozione. Ripartire dai lavori residui, non dagli obblighi di composizione
ora chiusi.

## Prima scansione rimossa e candidato adottato, 27 settembre

La scansione `Phase_Ready` all'ingresso di `Forces_Phase.Compute` è sostituita
da un'asserzione Static dimostrata. Il package privato richiede ora Is_Ready;
entrambi i chiamanti lo stabiliscono: l'API pubblica tramite il controllo
esistente e la pipeline tramite il contratto di Assemble appena chiuso.
Nessuna precondizione pubblica cambia. Non serve il modello fisico completo
delle forze per dimostrare che questo particolare ramo di rifiuto è irraggiungibile.

La pubblicazione dei buffer temporanei Gravity/Bias è annidata nel ramo che
chiama Try_Recursive. Used_Recursive parte False e solo quel produttore può
modificarlo: il riordino dei rami è equivalente, conserva l'ordine delle
operazioni e permette all'analisi di flusso di vedere l'inizializzazione.
Non aggiunge azzeramenti o scansioni e non sopprime diagnostiche.

| Verifica sul candidato finale | Proof | Flow | Aperti |
|---|---:|---:|---:|
| Asserzione sostitutiva e sua precondizione, selezionate | 2 | 13 | 0 |
| API pubblica Inertia.Assemble | 2 | 2 | 0 |
| Inertia_Phase.Assemble | 2 | 2 | 0 |
| API pubblica Forces.Compute | 2 | 2 | 0 |
| Evaluate_Inertia_Forces | 18 | 2 | 0 |
| Evaluate_Ready | 26 | 2 | 0 |

I 13 controlli flow della prima riga riguardano il file analizzato; i due proof
sono soltanto gli obblighi selezionati all'ingresso, non l'intera unità delle
forze. Le altre cinque righe sono verifiche complete dei sottoprogrammi.
Le dipendenze di massa, accumulo CRB e preparazione spaziale corrispondono
esattamente al candidato mass-frame già verificato. La revisione del sorgente
isola le due sole modifiche aggiuntive rispetto a quel candidato, nel corpo e
nella specifica privata di Forces_Phase. Nessun Assume o nuova soppressione.

Strict e Compatible passano ciascuna **624 scenari/168.192 confronti** sul
probe checked finale. Il test specifico del confine pubblico passa in entrambe
le policy, sia checked sia release: 26 scenari/7.008 confronti per esecuzione.
Controlla stato vuoto, pose obsolete e corruzione artificiale di velocità,
cache e configurazione. Per i dati corrotti, fuori dal contratto pubblico,
checked rifiuta tramite la precondizione; release restituisce Not_Allocated
tramite il controllo esplicito conservato. Stato e ingressi restano invariati.

Il conteggio strumentato sul sorgente finale conferma, su 11 modelli e 400 passi
ciascuno, **un Is_Ready pubblico e due Phase_Ready interni per passo**, con
output release identici. I tempi del binario strumentato non sono usati come
evidenza di prestazione.

Le due sessioni integrate confrontano la precedente versione attiva, il
candidato completo e C MuJoCo 3.14.0 con SIMD normale: 11 modelli, tre scenari
ciascuno, 24 blocchi in ordine alternato, quattro traiettorie da 100 passi per
blocco, CPU 12. Nessuna compilazione, prova o altra misurazione è concorrente.
In tutti i 33 casi, entrambe le sessioni hanno l'intero intervallo bootstrap
95% del rapporto candidato/precedente sotto 1. Gli intervalli sono per caso,
senza correzione per confronti multipli. Gli stati finali Ada coincidono nei
confronti numerici registrati (errore assoluto massimo zero).

Gli intervalli seguenti raccolgono tre scenari e due sessioni per modello;
non sono una media globale. Ada/C maggiore di 1 indica il divario residuo.

| Modello | Riduzione tempo/passo | Ada/C dopo |
|---|---:|---:|
| hinge_motor | 2,2–3,1% | 1,08–1,09× |
| branched_multijoint | 4,4–4,8% | 1,44–1,45× |
| chain_12 | 6,9–7,6% | 1,83–1,86× |
| crb_no_damping | 8,0–8,3% | 1,82–1,85× |
| crb_chain_24 | 6,4–7,4% | 1,83–1,85× |
| ancestor_star_24 | 9,6–10,6% | 2,28–2,30× |
| ancestor_forest_24 | 8,6–10,1% | 2,09–2,11× |
| ancestor_branches_24 | 8,2–9,8% | 2,04–2,09× |
| simple_hinges_6 | 6,7–7,2% | 2,33–2,35× |
| simple_sliders_6 | 3,0–3,7% | 1,51–1,54× |
| simple_mixed_8 | 7,6–8,1% | 1,55–1,57× |

**ADOTTATO.** Sono integrati anche i refactoring della massa/preparazione
spaziale e l'accumulo CRB già provati, incluso il precedente controllo numerico
dell'accumulo sostituito dalla sua asserzione Static. La prestazione misurata
riguarda questo insieme; non attribuire l'intero guadagno alla sola scansione.
I 106 sorgenti del manifest attivo corrispondono alla build misurata; il
precedente manifest da 100 sorgenti è conservato separatamente.

Evidenze: force-entry-scan-adoption.zip/json e force-entry-scan-performance.json.
Contengono sorgenti precedenti/finali, prove con snapshot, test, binari,
conteggi, comandi, compilatori/flag e entrambe le sessioni grezze. La prima
prova con due diagnostiche flow e il primo test checked che attendeva erroneamente
un ritorno invece della violazione della precondizione sono tentativi superati,
conservati separatamente. Ripresa locale: /var/tmp/sparkling-first-scan-20260927.

Restano le scansioni di **Actuation_Phase.Compute** e
**Inertia_Phase.Solve_Euler**. Il prossimo collegamento riguarda la conservazione
della readiness nel corpo delle forze per eliminare il controllo prima
dell'attuazione; poi quello di accelerazione/soluzione prima di Euler.
Il modello funzionale completo della massa e la dinamica globale restano aperti.
La massa è ancora assemblata densa e raccolta nel fattore compatto: questa
adozione non completa la costruzione direttamente nel formato compatto.


## Parità delle scansioni globali adottata, 27 settembre

Il passo Euler release non riesamina più l'intera Simulation. Il controllo
pubblico Is_Ready e i due Phase_Ready privati sono sostituiti dalla composizione
di proprietà dimostrate. Boundary.Ready legge Allocated ed è equivalente a
Is_Ready sotto la precondizione pubblica preesistente Valid_State.
Actuation_Phase.Compute e Inertia_Phase.Solve_Euler richiedono privatamente
Is_Ready, stabilita dai chiamanti. Nessuna precondizione pubblica è rafforzata.

| Riletture globali per Step release | Prima | Adesso | Equivalenti in C |
|---|---:|---:|---:|
| Modello, layout, stato e cache: Is_Ready | 1 | 0 | 0 |
| Stato e cache alle frontiere interne: Phase_Ready | 2 | 0 | 0 |
| Totale | 3 | 0 | 0 |

La strumentazione è nelle implementazioni dei predicati: 11 modelli, 400 passi
ciascuno, conteggio0+ 0 e output identici al release non strumentato. Il controllo
positivo sul precedente runtime conta 1+ 2. Questi binari non sono cronometrati.
Il confronto C resta MuJoCo 3.14.0, commit 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd.
mj_step controlla ancora qpos/qvel/qacc; l'attuazione controlla ctrl ed Euler
cerca lo smorzamento. In C non c'è la rilettura globale di modello/cache qui
eliminata. Non si sostiene l'uguaglianza di ogni controllo numerico, né zero
scansioni nelle API standalone, nel caricamento o nella build checked.

Forze e risolutore usano helper con buffer circoscritti, frame espliciti e
l'ordine floating point precedente. Le somme delle forze rispettano
(((Gravity - Bias) + Passive) + Actuator) + Applied. Nel percorso Strict il
controllo globale dell'intervallo di lavoro della norma è ridondante sotto i
limiti provati dei fattori; stima della condizione e policy di rifiuto restano.
L'integrazione prepara entrambi i vettori prima della pubblicazione e conserva
Q/V/tempo sui rami di rifiuto. Il caso privato di accelerazione corrente, massa
obsoleta e smorzamento implicito restituisce Stale_Results prima di usare la
massa. Il normale Step aggiorna la massa prima di arrivarvi.

| Evidenza definitiva | Risultato |
|---|---|
| Ambiti locali richiesti e audit delle interfacce | 88 coperti, 0 lacune |
| Intera unità Euler, dopo prove minime | 160 proof + 31 flow, 0 aperti |
| Strict e Compatible, ciascuna | 624 scenari/168.192 confronti passati |
| Frontiere Step e Forces, checked/release, entrambe le policy | 8 esecuzioni da 26 scenari/7.008 confronti, tutte passate |
| Conteggio release strumentato | 11 modelli × 400 passi, 0+ 0 scansioni |
| Continuità build checked/release/sorgente attivo | 108 hash identici |

Le prove coprono i contratti locali, i modelli aritmetici dichiarati e la
composizione di readiness e conservazione di stato/ingressi/configurazione.
Il registro non somma selezioni duplicate. Gli ambiti completi ricavati da
verifiche whole-unit con altre diagnostiche sono usati solo per entità senza
obblighi aperti; i residui hanno prove minime complete sul codice corrispondente.
L'audit confronta le specifiche importate, i contratti degli helper e le costanti.
I tentativi falliti o scaduti e le selezioni senza obblighi non sono pass.
Nessun Assume, nuova soppressione, corpo fidato o modifica dei deallocatori.

Due sessioni indipendenti: 11 modelli,tre stati, 24 blocchi alternati per caso,
quattro traiettorie da 100 passi per blocco,CPU 12. Controlli e forze applicate
sono fissi durante ogni traiettoria; preparazione, reset e I/O sono esclusi.
Nessuna prova, compilazione o test numerico è concorrente. Tutti i 33 casi hanno
CI bootstrap 95% nuova/precedente interamente sotto 1 in entrambe le sessioni;
intervalli per caso senza correzione per confronti multipli. Nessuna regressione.
I dati conservano mediane, dispersione e p95 del costo medio per passo della
traiettoria (non latenza p95 del singolo passo). Errore assoluto massimo fra
versioni Ada 0; contro C 3,90e-14 negli stati finali misurati.

Gli intervalli raccolgono stati e sessioni, senza media delle percentuali.
Ada/C è il rapporto dei tempi: sotto 1 significa meno tempo di C.

| Modello | Riduzione tempo/passo | Ada/C dopo |
|---|---:|---:|
| hinge_motor | 32.6–34.0% | 0.72–0.73× |
| branched_multijoint | 29.6–30.2% | 1.01–1.02× |
| chain_12 | 22.2–23.4% | 1.40–1.44× |
| crb_no_damping | 28.6–29.1% | 1.29–1.30× |
| crb_chain_24 | 17.8–18.5% | 1.49–1.51× |
| ancestor_star_24 | 25.8–26.4% | 1.67–1.70× |
| ancestor_forest_24 | 23.8–24.7% | 1.57–1.59× |
| ancestor_branches_24 | 23.3–23.5% | 1.56–1.58× |
| simple_hinges_6 | 34.4–35.9% | 1.50–1.52× |
| simple_sliders_6 | 41.3–41.7% | 0.86–0.87× |
| simple_mixed_8 | 34.6–34.9% | 0.99–1.00× |

Il guadagno è dell'intero candidato verificato, compresi i confini degli helper;
non è un'attribuzione causale alla sola rimozione dei tre predicati. C resta più
veloce in diversi multi-DOF; il caso mixed è vicino alla parità, mentre hinge_motor
e simple_sliders_6 impiegano meno tempo di C. Le differenze piccole si valutano
con i CI registrati, non con una soglia percentuale arbitraria.

**ADOTTATO:** 8 file integrati, 108 hash nel manifest attivo. Il manifest da 106
sorgenti è preservato in pre-scan-parity-active-source-match.json. Evidenze in
scan-parity-adoption.zip/json e scan-parity-performance.json: baseline/candidato,
prove e snapshot ricostruibili, comandi, binari, test, conteggi e tempi grezzi.
Ripresa locale: /var/tmp/sparkling-scan-parity-20260927.

La massa continua a essere assemblata densa e poi raccolta nel formato compatto;
il suo prefisso CRB è byte-identico alla precedente adozione. Restano separati la
costruzione direttamente compatta, il modello ordinato completo della massa,
la dimostrazione fisica globale e la parità prestazionale su tutti i carichi.
Nessun commit o push in questa adozione.
