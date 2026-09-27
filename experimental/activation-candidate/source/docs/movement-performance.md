# Prima misura del movimento completo — 2026-09-24

L’indagine successiva sugli [invarianti dello stato](state-invariants-performance.md)
misura il costo delle scansioni ripetute e una scorciatoia ancora sperimentale.
I risultati sotto rimangono la prima baseline.

**Il prototipo non raggiunge ancora il C sul passo completo.** Sui tre modelli
provati impiega circa 1,6×, 3,1× e 7,5× il tempo del C. I guadagni dei singoli
kernel non dimostrano quindi la parità del simulatore. Questo risultato riguarda
il sottoinsieme sperimentale senza contatti, non tutto MuJoCo.

Abbiamo misurato sequenze di **100 passi Euler consecutivi**, con posizione e
velocità che evolvono, su un giunto motorizzato, un modello ramificato a cinque
gradi di libertà e una catena a dodici gradi di libertà. Ogni modello ha tre stati
iniziali deterministici e controlli/forze applicate costanti. Il percorso include
cinematica, inerzia, forze, attuazione, risoluzione e integrazione. Non comprende
collisioni, vincoli, sensori o rendering.

## Risultati

Tempi in **microsecondi per passo**, ottenuti dividendo il tempo della traiettoria
per 100. La tabella riporta la mediana dei tre tempi mediani degli stati nella
prima sessione; non è una ponderazione del carico di una particolare applicazione.
I risultati dei singoli stati e gli intervalli appaiati sono conservati nei dati.

| Modello | C nativo | Ada originale, mantenuta | Ada con collegamento sperimentale | Originale/C, circa |
|---|---:|---:|---:|---:|
| Giunto motorizzato, 1 DOF | 0,424 | 0,676 | 0,694 | 1,6× |
| Ramificato, 5 DOF | 0,983 | 2,996 | 3,083 | 3,1× |
| Catena, 12 DOF | 2,071 | 15,441 | 15,648 | 7,5× |

Nella seconda sessione i tempi mediani Ada originali sono rispettivamente
0,679, 3,027 e 15,510 µs; il C misura 0,425, 0,980 e 2,076 µs. Il divario ampio
si ripete. Sono due esecuzioni sulla stessa macchina e nello stesso periodo,
non una verifica su hardware, giorni o modelli differenti.

Il collegamento sperimentale impiega più tempo dell'originale in tutti i rapporti
mediani: nella prima sessione **+0,99%…+4,76%**, nella seconda **+0,63%…+3,41%**.
Gli intervalli bootstrap appaiati escludono 1 in otto scenari su nove nella prima
sessione e nove su nove nella seconda. Sono intervalli entro sessione, senza
correzione per confronti multipli; il caso da +0,63% è vicino al limite. Non
usiamo questi dati per stabilire una soglia universale del rumore. Il candidato
non mostra un vantaggio integrato che ne giustifichi l'adozione.

**Decisione: candidato respinto e corpo matematico originale ripristinato
identico byte per byte.** Il benchmark, i sorgenti del candidato e le prove
restano disponibili per ripetere e confrontare interventi successivi. Nei JSON
la chiave storica `current` indica il candidato respinto, non il codice attivo.

## Quale modifica abbiamo effettivamente misurato

Il prototipo usa proprie routine matematiche. Il candidato collega `Apply` e
`Apply_Transpose` ai kernel Gold `MJ.Matrices.MulMatVec3` e `MulMatTVec3`.
Per vettori fuori da Tier0 mantiene le formule originali: il prototipo ammette
valori fino a 1e280, mentre i kernel di produzione richiedono Tier0. Il controllo
del dominio è incluso nel costo. Le formule e l'ordine delle operazioni non
cambiano; nessun input ammesso viene escluso.

La trasposizione generica, le operazioni sulle pose e gli altri kernel ottimizzati
non sono stati artificialmente aggiunti alla traiettoria. Questa prova misura
l'effetto di due collegamenti reali e il costo del prototipo completo; **non**
ricostruisce il saldo di tutte le ottimizzazioni storiche.

Un collegamento del prodotto quaternion è rimasto fuori dal candidato finale:
quattro uguaglianze del collegamento non si sono chiuse nelle prove mirate. La
routine originale è stata mantenuta. È lavoro di prova ancora aperto, non una
limitazione matematica che autorizzi Silver. Normalizzazione e conversione
quaternion→matrice sono rimaste originali perché le formule o i comportamenti
di rifiuto differiscono dai corrispondenti kernel di produzione.

## Correttezza e limiti formali

Le due modifiche matriciali passano prima le prove ai sottoprogrammi minimi,
poi la verifica dell'intera `MJ.Smooth_Math` candidata: **751 obblighi di prova,
61 controlli di flusso, zero irrisolti e zero errori**. Questo dimostra i contratti
dell'unità sotto i contratti dei chiamati; non chiude le prove delle unità di
dinamica e gestione dello stato, che restano nel loro ambito sperimentale.

Il programma con controlli attivi passa **360 scenari / 33.840 confronti** con
MuJoCo 3.14, sette casi limite di normalizzazione e quattordici casi di errore o
funzionalità non supportata. Ogni sessione cronometrata controlla inoltre 33.696
valori contro l'oracolo, più 11.232 uguaglianze esatte fra le due varianti Ada.
Le uguaglianze sono sui valori floating point, non sui payload NaN o sui bit
dello zero con segno. La tolleranza rispetto a C è
`abs(error) <= 2e-10 + 2e-10*abs(reference)`; non è un limite d'errore provato.

## Metodo

Linux/WSL, Ryzen 7 9800X3D, affinità CPU 12; GNAT/GCC 16.1 e GPRbuild 26.
Riferimento C: MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, ricompilato con SIMD ordinario attivo,
`-O3 -march=native`, LTO e `-ffp-contract=off`. Le opzioni sulle operazioni
floating point sono comparabili con quelle Ada. Ada usa LTO nell'eseguibile;
C usa LTO nella libreria condivisa e una chiamata esterna a `mj_step`.

Ogni scenario usa 24 blocchi, sei ordini di esecuzione bilanciati, due traiettorie
di riscaldamento e quattro campioni per processo. Sono 259.200 passi misurati per
sessione, oltre al riscaldamento. Caricamento, reset, impostazione ingressi,
allocazione dei risultati, stampa e confronti sono fuori dal cronometro.
Il codice interno al passo rimane interamente incluso. Ada controlla lo stato
restituito dopo ogni passo; il C controlla gli avvisi dopo la traiettoria.
Nessuna compilazione o prova formale era in esecuzione durante le misure.

Sono conservati tutti i campioni, mediana, MAD, p95 e intervalli bootstrap dei
rapporti fra mediane di blocchi appaiati. Il p95 riguarda il costo medio per
passo delle traiettorie, **non** la latenza del singolo passo né un limite per
tempo reale. I modelli sono privi di contatti e geometrie: questi risultati non
si estendono a simulazioni con collisioni o a distribuzioni d'uso diverse.

## Priorità risultante

Il prossimo bersaglio è la dinamica completa. Il prototipo costruisce una
matrice d'inerzia densa tramite Jacobiani ed esegue ulteriori risoluzioni per
stimare il condizionamento; non usa gli stessi algoritmi strutturati del C.
Queste sono differenze accertate nel codice, ma questa misura non attribuisce
ancora una percentuale di tempo a ciascuna fase. Serve profilare assemblaggio,
fattorizzazione, controlli numerici e forze prima di scegliere l'intervento.
Non eliminiamo le verifiche numeriche per ottenere un miglior numero.

Il banco completo diventa il criterio per valutare tali interventi. I
microbenchmark restano utili per spiegare un risultato, ma il conteggio delle
matrici più lente o più veloci non sostituisce questa misura.

[Riproduzione](../tests/movement_performance/README.md) ·
[Evidenze e manifest](../tests/movement_performance/evidence/README.md)
