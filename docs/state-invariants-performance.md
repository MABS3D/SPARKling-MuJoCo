# Invarianti dello stato e costo del passo — 2026-09-24

L'indagine sulle prove ha individuato un costo concreto: **sette scansioni di
`Is_Ready` per passo**. La query controlla layout, configurazione, ingressi e
cache derivate. È richiamata all'ingresso di `Step`, cinematica, assemblaggio
dell'inerzia, forze, attuazione e delle due risoluzioni.

Le procedure richiedono già `Valid_State`, cioè uno stato vuoto oppure pronto.
Abbiamo dimostrato una query privata, `Ready_Flag`, che sotto **quella stessa
precondizione** restituisce esattamente `Is_Ready`, leggendo solo `Allocated`.
Non è un validatore di memoria arbitraria né uno stato valido ottenuto per
assunzione: la validità è la precondizione già richiesta, che i chiamanti devono
stabilire e le fasi devono conservare.

## Esperimento completo, senza strumentazione

Una copia isolata sostituisce soltanto le sette guardie d'ingresso. Restano i
controlli numerici, di freschezza delle cache, del condizionamento, le soglie e
gli stati di errore. La copia non modifica il codice attivo del prototipo.

Sono ripetuti gli stessi nove scenari della [prima prova integrata](movement-performance.md):
tre stati per modello, traiettorie di 100 passi, 24 blocchi bilanciati e quattro
campioni per processo. La tabella mostra le mediane dei tre stati nella prima
sessione, in microsecondi per passo. I rapporti provengono dai blocchi appaiati.

| Modello | Originale | Scorciatoia sperimentale | Riduzione del tempo | C nativo |
|---|---:|---:|---:|---:|
| Giunto, 1 DOF | 0,685 | 0,267 | circa 61% | 0,428 |
| Ramificato, 5 DOF | 3,019 | 1,780 | circa 41% | 0,986 |
| Catena, 12 DOF | 15,540 | 11,714 | circa 25% | 2,064 |

La seconda sessione conferma circa 61%, 42% e 24% di riduzione. In entrambe,
tutti i nove intervalli appaiati al 95% sono sotto 1. Sono due esecuzioni sulla
stessa macchina, non una verifica su altri modelli o hardware. Nessuna prova
formale o compilazione era in corso durante le misure.

Il giunto sperimentale impiega circa il 62% del tempo del C; gli altri due
modelli restano intorno a 1,8× e 5,7×. Quindi eliminare le scansioni ripetute
può recuperare molto tempo, ma non basta a raggiungere la parità nei sistemi
articolati più grandi. Il risultato riguarda il sottoinsieme senza contatti.

## Profilo delle fasi

Una build distinta aggiunge cronometri alle fasi e alle scansioni. Gli stessi
risultati finali sono confrontati esattamente con la build originale. Su ogni
traiettoria misurata si osservano sette chiamate di prontezza e due stime del
condizionamento per passo.

Nella catena a 12 DOF, le quote indicative del tempo **strumentato** sono:

| Attività | Quota indicativa |
|---|---:|
| Assemblaggio della matrice d'inerzia | 35,5% |
| Scansioni di prontezza, sommate attraverso le fasi | 24,4% |
| Stima del condizionamento nelle due risoluzioni | 17,6% |
| Cinematica | 11,7% |

Queste quote **non vanno sommate**: le scansioni sono incluse nelle rispettive
fasi e la stima del condizionamento è inclusa nelle risoluzioni. I cronometri
aggiungono costo, particolarmente importante nel modello a un solo giunto.
Per il guadagno complessivo valgono le misure separate senza strumentazione.

Le due stime riguardano matrici diverse: `M` per l'accelerazione ordinaria e
`M + h*D` per Euler con smorzamento implicito. Non sono automaticamente
intercambiabili e non ne abbiamo eliminata una. L'assemblaggio denso calcola
inoltre `Inertia_Times(R, Diagonal, Aj)` ripetutamente per lo stesso corpo e la
stessa colonna dentro il ciclo delle coppie di DOF: è un candidato concreto a
un riuso del risultato, da specificare, provare e misurare mantenendo l'ordine
delle somme e il dominio numerico.

## Avanzamento formale e decisione

La proprietà di `Ready_Flag` passa: un obbligo funzionale, due controlli di
flusso, zero irrisolti. I sette controlli completi restano attivi nel prototipo.
La scorciatoia non viene promossa finché manca la prova composizionale che le
fasi mantengano lo stato valido. Questo evita di trasformare un contratto di un
chiamato ancora non chiuso in una garanzia dell'intero percorso.

La diagnosi minima di `Euler.Integrate` ha ristretto gli obblighi aperti alla
conservazione di `Input_Values`, cioè controlli e forze esterne. La strategia
progressiva chiude la conservazione della configurazione che rimaneva aperta
nel tentativo iniziale. Sono state aggiunte solo asserzioni ghost sulla
corrispondenza delle immagini degli ingressi e sui punti di uscita; non cambiano
il calcolo né indeboliscono i contratti. Il rapporto delle prove conserva lo
stato di ogni tentativo: il migliore sul sorgente finale chiude **54 obblighi
su 55**, oltre a dieci controlli di flusso. Il successivo tentativo con il solo
Z3 lascia otto obblighi aperti e non sostituisce il risultato più forte della
combinazione di prover. Nessun timeout diventa una giustificazione Silver.

Il runner di diagnosi ora espone la strategia `--proof-mode progressive` e, per
una riga contrattuale in una specifica, analizza il corpo quando presente.
Una selezione con zero obblighi non restituisce più un successo di prova.
È mantenuta la distinzione tra un'analisi completata e una proprietà dimostrata.
Per le postcondizioni si preferisce la selezione del sottoprogramma: la selezione
puntuale della riga di specifica, anche analizzando il corpo, non ha emesso
obblighi nei tentativi registrati e non viene contata come una prova.

La copia con scorciatoia passa 360 scenari / 33.840 confronti numerici, sette
casi di normalizzazione e quattordici casi di rifiuto/status. Ogni sessione
senza strumentazione aggiunge 33.696 confronti con l'oracolo e 11.232 uguaglianze
esatte tra le due varianti Ada. Questi test non chiudono le prove delle fasi.

[Fixture e riproduzione](../tests/movement_performance/state_invariants/README.md)
· [Evidenze](../tests/movement_performance/state_invariants/evidence/README.md)

L'[analisi successiva degli algoritmi C](c-dynamics-algorithm-audit.md) quantifica
il lavoro evitato da CRB e RNE e distingue la fattorizzazione dal costo della
politica di condizionamento del prototipo.

Follow-up: [validated entry reuse and deferred Jacobians](readiness-performance.md)
records the next implementation, proof scope and whole-step measurements.
