# Sei ottimizzazioni del percorso dinamico C

Il riferimento è MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Il confronto riguarda il percorso
sperimentale con giunti scalari hinge/slide, non l'intero motore MuJoCo.

## Implementazione

1. **Topologia immutabile.** `MJ.Smooth_Topology` conserva radice, ultimo DOF
   del corpo, associazioni corpo/giunto/DOF, genitori, masse dei sottoalberi,
   armature e inerzie diagonali costanti. I dati derivano dal modello validato
   durante `Create`; non sono ricostruiti ad ogni passo.
2. **Preparazione spaziale condivisa.** `MJ.Data.Spatial.Prepare` costruisce
   una volta per posa le inerzie a dieci componenti e gli assi a sei componenti,
   nel riferimento del centro di massa del sottoalbero radice. CRB e RNE
   condividono due array contigui, separati dai record delle pose. La cache
   viene pubblicata solo dopo il successo e invalidata al cambio di stato.
3. **Scansioni della configurazione ridotte.** Il confine pubblico mantiene
   `Is_Ready`; le fasi private richiedono `Stable_Ready` e verificano con
   `Phase_Ready` gli input e le cache mutabili. Non viene usato `Ready_Flag`.
   La strumentazione misura un controllo completo e cinque controlli mutabili
   per passo. I contratti di conservazione della parte stabile sono espliciti;
   le relative prove d'integrazione ancora aperte non sono dichiarate Gold.
4. **Velocità e forze spaziali.** La ricorrenza scalar-joint di `mj_comVel` e
   `mj_rne` evita di calcolare anche velocità e accelerazioni cartesiane nel
   percorso veloce. Gravità e bias restano risultati pubblici distinti. Un
   kernel specifico applica l'inerzia alla gravità evitando i termini nulli.
   Il percorso Jacobiano/cartesiano rimane disponibile fuori dal dominio
   numerico spaziale; il recupero preserva pose e cache condivise.
5. **Riduzione sparsa a quattro corsie.** La sostituzione in avanti usa
   prodotti indipendenti e l'ordine arrotondato del kernel C: quattro somme,
   fusione `(lane0 + lane2) + (lane1 + lane3)`, quindi coda ordinata. Le righe
   con zero, uno, due o tre antenati usano il percorso corto. Un dominio
   sufficiente provato seleziona la riduzione; fuori dal dominio rimangono i
   controlli ordinati preesistenti. Non si aggiungono FMA o riassociazioni.
6. **DOF semplici.** I casi fisicamente idonei usano diagonali costanti e righe
   compatte senza antenati. L'idoneità viene verificata conservativamente,
   incluse geometria, frame e assi esatti. Il codice non si fida del valore
   `dof_M0` importato: ricava l'inerzia da massa, inerzia locale e armatura.

Le corrispondenze C si trovano in `mj_comPos`, `mj_comVel`, `mj_crb`, `mj_rne`,
`mj_factorI` e `mj_solveLD` di `engine_core_smooth.c`, nella costruzione del
modello e in `mju_dotSparse` di `engine_util_sparse.c`.

La massa pubblica e lo scratch del solver `Strict` restano densi. La copia
massa→fattore compatto precede ancora ogni risoluzione compatibile. Costruire
la massa direttamente nel formato compatto è un intervento successivo,
separato da questi sei punti. Nessuno di essi aggiunge contatti, giunti ball/free,
fluido o altre funzionalità escluse dal dominio sperimentale.

## Prove e diagnostica

I sottoprogrammi minimi vengono verificati prima delle unità. Le prove dei
kernel descrivono il calcolo floating point effettivo; non dimostrano da sole
la correttezza fisica dell'intera simulazione. Le pagine specifiche raccolgono
contratti, test e ambito delle prove:

- [Topologia e DOF semplici](../tests/movement_performance/c_parity_six/topology/README.md).
- [Preparazione e dinamica spaziale](../tests/movement_performance/c_parity_six/SPATIAL.md).
- [Riduzioni sparse](../tests/movement_performance/c_parity_six/reductions.md).

Le sette unità complete di topologia, indici degli antenati, kernel semplici,
dinamica/accessori spaziali, aggiornamento delle righe e riduzioni chiudono
rispettivamente 208, 773, 10, 341, 94, 101 e 740 obblighi. La riduzione chiude
anche 84 controlli di flusso. Sono chiusi inoltre i sottoprogrammi di allocazione,
azzeramento e rilascio delle nuove cache e 15 controlli di conservazione dello
storage della pipeline.

Restano aperti un obbligo in `Fixed_Position`, quattro controlli selezionati in
`Spatial.Prepare`, un postcontratto in `Actuation_Phase.Compute`, due obblighi
nell'ultimo controllo completato di `Load_Ancestor_Factor`, oltre alla composizione
della topologia e alle prove complete delle fasi fisiche. Le condizioni dei
chiamati non dimostrano automaticamente la correttezza dei chiamanti.

I timeout e gli obblighi d'integrazione aperti sono lavoro di prova residuo,
non limiti matematici che autorizzino la classificazione Silver.

Il driver delle prove ora recupera anche gli errori di flusso nel file
strutturato `.spark`: `--limit-line` poteva nasconderli nell'output testuale pur
bloccando l'emissione di tutti gli obblighi. Un test conserva il caso reale di
una dimensione locale dipendente da un parametro mutabile. Nessuna esecuzione
con zero obblighi emessi viene contata come prova superata.

## Validazione e prestazioni

Il build finale passa **624 scenari e 168.192 confronti per politica** contro C,
in `Compatible` e `Strict`, con `atol=rtol=2e-10`. Passano anche 85 casi di
politica / 170 scenari, 104 scenari con guasti artificiali e ripartenza,
34.031 casi per build della riduzione e 14.905 per build dell'aggiornamento di
righe disgiunte. Le prove delle cache verificano dati invalidi, recupero
cartesiano e ritorno al percorso spaziale; quelle della topologia controllano
anche il modello esterno liberato e le costanti importate obsolete.

Due sessioni indipendenti, ognuna con 24 blocchi bilanciati, confrontano i tre
binari senza strumentazione sulla CPU 12: Ada precedente, Ada attuale e C
nativo SIMD. Ogni modello ha tre stati iniziali; ogni processo esegue due
riscaldamenti e quattro ripetizioni da 100 passi. I 4.752 processi misurati
eseguono complessivamente 1.900.800 passi, comprese le ripetizioni dei tre
binari. L'errore assoluto massimo osservato nelle traiettorie rispetto a C è
`3.8914e-14`.

La tabella riporta l'intervallo delle sei mediane (tre stati × due sessioni),
non un intervallo di confidenza aggregato. Un rapporto attuale/C di 2 indica
che Ada impiega il doppio del tempo.

| Modello | Riduzione del tempo rispetto ad Ada precedente | Tempo attuale / C |
| --- | ---: | ---: |
| Hinge, 1 DOF | 1,5–2,0% | 1,41–1,42× |
| Ramificato, 5 DOF | 5,6–6,9% | 1,81–1,83× |
| Catena, 12 DOF | 2,7–3,2% | 2,24–2,27× |
| Senza smorzamento, 6 DOF | 3,8–5,0% | 2,31–2,37× |
| Catena, 24 DOF | 2,2–3,2% | 2,17–2,20× |
| Stella, 24 DOF | 4,9–6,5% | 2,94–3,00× |
| Foresta, 24 DOF | 2,4–4,2% | 2,60–2,66× |
| Quattro rami, 24 DOF | 2,6–5,5% | 2,56–2,60× |
| Hinge semplici, 6 DOF | 5,9–7,0% | 3,02–3,11× |
| Slider semplici, 6 DOF | 6,5–7,6% | 1,94–1,98× |
| Misto semplice, 8 DOF | 13,5–14,7% | 2,00–2,02× |

In tutti i 66 confronti stato/sessione l'intervallo bootstrap appaiato al 95%
del rapporto attuale/precedente resta sotto 1. Sono intervalli per caso e
per sessione, senza correzione per confronti multipli: non dimostrano un
vantaggio su ogni macchina o modello. Anche il guadagno piccolo a un DOF è
ripetibile in queste sessioni; non è stato scartato con una soglia di rumore
arbitraria. **La parità con C non è ancora raggiunta.**

Il profilo diagnostico individua costi ancora rilevanti nella cinematica e
nelle scansioni delle cache. Nei modelli ramificati la fattorizzazione occupa
ormai una quota molto minore del passo. La costruzione diretta della massa
compatta e una riduzione ulteriormente provata delle scansioni sono i passi
successivi da valutare.

[Evidenza e comandi di riproduzione](../tests/movement_performance/c_parity_six/evidence/README.md).

Il primo pilot con cache incorporate nei record rallentava diversi modelli;
ha motivato gli array contigui e la specializzazione delle righe corte. Le
misure preliminari vengono conservate insieme a quelle finali. I profili con
clock annidati servono alla diagnosi e non sostituiscono il confronto dei
binari release senza strumentazione.
