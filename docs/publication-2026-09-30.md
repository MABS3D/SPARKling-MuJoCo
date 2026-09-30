# Pubblicazione del 30 settembre 2026

Questo checkpoint raccoglie i sorgenti e le evidenze successivi al commit
`b6f47c98`. Il riferimento delle implementazioni è MuJoCo 3.14.0, commit
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. I candidati isolati sono conservati
con le proprie dipendenze e istruzioni di riproduzione; la loro pubblicazione
non li abilita automaticamente nel simulatore smooth.

## Dinamica attiva e verifica della combinazione corrente

La pipeline smooth gestisce ora giunti hinge, slide, ball e free, con indirizzi
separati per coordinate e velocità, integrazione dei quaternioni nel frame
usato da C, trasmissioni joint/joint-in-parent e conservazione dello stato
quando un passo è rifiutato. Il limite corrente è 512 coordinate e 256 DOF.

Sono collegati al caricamento posseduto del modello e a Forward/Euler i tendini
spaziali: siti, avvolgimenti su sfere/cilindri, sidesite, pulegge, Jacobiani,
velocità e molle/smorzatori polinomiali. **Questa integrazione accetta soltanto
giunti hinge/slide**: ball/free insieme a tendini spaziali restituisce
`UNSUPPORTED_FEATURE`. Tendini fissi, attuatori sui tendini e armatura dei
tendini richiedono ancora integrazione separata.

Una nuova esecuzione con controlli runtime abilitati, effettuata per questa
pubblicazione sugli stessi sorgenti consegnati, passa:

| Verifica corrente | Esito |
|---|---:|
| Giunti e regressioni scalari | 400 scenari, 45.584 confronti |
| Tendini spaziali e regressioni scalari | 320 scenari, 21.944 confronti |
| Quaternioni e rifiuti atomici | 32 scenari limite |
| Capacità ball | 280 coordinate, 210 DOF |
| Combinazioni ball/free + tendini | 2 rifiuti espliciti verificati |

I confronti usano la libreria C ufficiale 3.14.0, forze esterne e traiettorie
di 100 passi, a tolleranze assolute/relative `2e-10`. I due gruppi di regressioni
si sovrappongono sui modelli scalari: i conteggi non sono modelli unici né una
percentuale di copertura. Le prove composizionali complete dei nuovi percorsi
ball/free e dei tendini rimangono aperte.

[Semantica dei giunti](manifold-joints.md),
[tendini e limiti](../experimental/spatial-tendon-candidate/RESULTS.md),
[verifica fresca e hash](../tests/publication/2026-09-30/README.md).

## Ottimizzazioni del passo completo

La pipeline riutilizza quaternioni già accettati dal predicato di normalizzazione,
inizializza direttamente le pose free, calcola una sola volta il seno
dell'incremento angolare, espande piccoli kernel spaziali/di soluzione ed evita
un azzeramento ridondante della massa prima di CRB. La soglia del predicato dei
quaternioni differisce da quella di C ed è documentata: i test non dimostrano
equivalenza universale di questa scelta floating point.

Nei campioni registrati il tempo Ada dei casi multi-DOF diminuisce circa
15–25% rispetto allo snapshot precedente. **La parità generale con C resta
aperta**: senza carichi esterni la catena scalare da 12 DOF ha rapporto Ada/C
1,177; la catena ball 1,034. Con carichi esterni i rapporti sono rispettivamente
0,972 e 0,962, con gli intervalli riportati nel resoconto. Non viene calcolata
una media fra carichi diversi.

I tendini integrati hanno ancora rapporti Ada/C 1,246, 1,567 e 1,772 nei tre
carichi misurati. CRB conserva tuttora un candidato denso e lo ricompatta prima
della soluzione; costruzione direttamente compatta e costo dei Jacobiani
rimangono obiettivi concreti. Le misure sono già archiviate, non rieseguite
durante questa pubblicazione.

[Metodologia, dispersione, rapporti e prove locali](manifold-performance.md).

## Solutori e nuovi candidati

I conteggi formali sotto riguardano gli ambiti e i contratti delle esecuzioni
archiviate, sotto precondizioni e contratti dei chiamati. Non sono una misura
della percentuale portata di MuJoCo o una prova Gold dell'intero simulatore.

| Consegna | Evidenza e ambito | Lavoro ancora aperto |
|---|---|---|
| [Cholesky denso](../experimental/cholesky/verification.md) | 769 controlli chiusi, zero aperti sui contratti correnti; limiti numerici e stato esplicito `Success`/`Numeric_Limit` | Modello globale di ricostruzione/soluzione, integrazione nella dinamica e parità prestazionale |
| [LU](../experimental/lu-candidate/integration-20260928/README.md) | 1.150 controlli chiusi, zero aperti; pivot, eliminazione ordinata, conservazione, crescita limitata e RHS nullo | Correttezza funzionale globale della fattorizzazione/soluzione e prestazioni dense |
| [Cholesky sparse/band](../experimental/cholesky-sparse-band/verification-results.md) | 1.731 casi per profilo; contratti funzionali locali dell'aritmetica chiusi | 45 controlli aperti nelle unità di matrici; modelli globali, chiamanti e misure integrate |
| [Muscoli](../experimental/muscle-candidate/risultati.md) | 400 controlli chiusi sulle due unità complete; 10.179 casi e 26.523 confronti per profilo | Caricamento, calibrazione, stati e trasmissioni nella pipeline attiva |
| [Attuazione avanzata](../experimental/advanced-actuation-candidate/README.md) | Trasmissioni CSR, site/slider-crank/SO3, PID, DC e muscoli; 4.836 casi per profilo; 17 carichi isolati misurati più rapidi di C | Obblighi formali aperti in tutte le cinque unità complete; collegamento al motore e prestazioni del movimento completo |
| [Adesione e attivazione](../experimental/adhesion-activation-candidate/README.md) | Kernel adesivo, filtri, stato posseduto e candidato di passo scalare; 69 controlli chiusi sul passo adesivo e 366 casi differenziali | Una prova aperta al confine runtime di `Exp`, copertura del kernel completo e composizione generale Euler/attuazione |
| [Rete elastica con contatti](../experimental/elastic-contact-candidate/results/README.md) | Unità matematica 123/123, coordinate 47/47; 53 casi differenziali e correzione della deriva rispetto alle coordinate di C | Prova aritmetica/funzionale della pipeline accoppiata e collegamento al motore |
| [Flex su piano](../experimental/flex-contact-candidate/README.md) | 2.003 controlli chiusi incluse dipendenze riverificate, 946 nelle nuove unità; filtro C fino a 50 contatti, 144 casi per profilo | Caricatore principale, attrito, altre forme, autocollisione e accoppiamento articolato |

Timeout, invarianti mancanti e modelli funzionali incompleti restano lavoro di
dimostrazione. Non sono eccezioni matematiche che permettono di dichiarare
Silver concluso. Gli avvisi registrati rimangono visibili.

## Controllo della pubblicazione

I riferimenti GitHub sono stati aggiornati prima del confronto. I checksum
delle consegne Cholesky, LU e adesione, gli archivi nuovi e i manifest selezionati
dei sorgenti correnti sono verificati. Per conservare integralmente il pacchetto
sigillato di adesione sono inclusi anche i 18 input MJB del suo benchmark;
gli altri prodotti di compilazione restano fuori dal commit.

Il resoconto dei tendini conserva lo snapshot precedente alle ultime
ottimizzazioni concorrenti di sei file della pipeline. Questo scarto è registrato
nell'audit: le sue prove e misure valgono per quello snapshot. La nuova regressione
sopra verifica numericamente la combinazione attuale; non è una nuova esecuzione
delle prove formali di quel resoconto.

I worktree separati di tendini fissi e forze passive non lineari coincidono
ancora con i rispettivi snapshot già pubblicati. Nessuna modifica è persa o
copiata sopra il codice corrente. Il [checkpoint precedente](publication-2026-09-29.md)
conserva gli interventi sui quaternioni e sul contatto scalare.
