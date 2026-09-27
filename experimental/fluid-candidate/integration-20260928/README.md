# Integrazione formale dei fluidi — candidato del 28 settembre 2026

**Stato: avanzamento parziale, non dimostrazione completa dell'integrazione.**
Il codice è una copia isolata del candidato fluidi, con patch incrementale e prove
riproducibili. Non è stato applicato ai sorgenti della conversazione principale,
che contiene modifiche concorrenti agli stessi chiamanti. Nessun commit o push.

## Modifiche

- Validità della memoria degli elementi fluidi inclusa nella configurazione.
  Creazione/liberazione ricevono soltanto i dati che possiedono e modificano.
  La costruzione controlla capacità, indici e dimensioni; il wrapper libera gli
  elementi e azzera le opzioni su errore. Sono controlli di inizializzazione.
- Separazione di costruttori box/ellissoide, inserimento di un elemento e
  aritmetica della massa inversa/dimensioni. Inserimento con contratto esatto sul
  nuovo elemento e conservazione degli altri.
- Contratti su forma e limiti delle velocità RNE riutilizzate e validità della
  cache spaziale; scrittura della velocità con contratto esatto e frame.
- Trasporto dei momenti, proiezione sul giunto e fusione dei sottoalberi separati
  in sottoprogrammi piccoli. Formule floating point nell'ordine dell'algoritmo;
  gli accumulatori rimangono invariati quando la singola operazione fallisce.
- `Build_Wrenches` legge la simulazione; `Accumulate` passa le forze passive alla
  risalita dell'albero. I contratti dichiarano la conservazione di stato,
  configurazione, tempo, cache, gravità e bias; alcune prove restano aperte.
- Corrette le dipendenze SPARK illegali dei vincoli degli array da `D` mutabile
  e l'uso di `Initialized` su buffer ordinari. Nessuna nuova assunzione,
  soppressione o disattivazione di SPARK. Deallocatori modellati invariati.

## Evidenza formale

I conteggi sono quelli emessi dal prover per il sottoprogramma, non percentuali di
completamento della fisica. Una prova modulare usa i contratti dei chiamati:
la riga `Initialize` non dimostra automaticamente il corpo di `Build`.
Le esecuzioni sono snapshot separati; non sommare righe duplicate o diagnostiche
con budget diversi. `proof-index.json` e i singoli report conservano gli esiti.

| Ambito | Obblighi chiusi nella prova indicata | Perimetro |
| --- | ---: | --- |
| `Inverse_Mass`, `Box_Length` | 6 + 17 | Formule scalari e sicurezza; `metadata` |
| `Make_Box` | 25 | Contratto completo del costruttore; `frame-details2` |
| `Append_Element` | 8 | Prefisso valido, indice e conservazione elementi; `lifecycle-final` |
| `Fluid_Phase.Initialize`, `Release` | 7 + 1 | Wrapper sotto contratto di Build; azzeramento/cleanup; `lifecycle-final` |
| `Data.Free` | 1 | Stato vuoto sotto contratti dei deallocatori; `lifecycle-callers` |
| `Store_Velocity`, `Forward_Bodies` | 9 + 80 | Scrittura esatta e limiti delle velocità riusate; `velocity-store` |
| `Recursive_Forces_Buffers`, `Try_Recursive` | 33 + 9 | Propagazione dei limiti ai chiamanti; `reuse-final` |
| `Publish_Gravity_Bias` | 21 | Copia delle forze e conservazione della cache spaziale; `reuse-final` |
| `Lever_Component`, `Lever_Torque`, `Project`, `Merge` | 13 + 32 + 10 + 16 | Formule esatte, limiti, rifiuto senza modifica; `transport2` |
| `Project_Into` | 15 | Aggiornamento esatto di una componente e frame; `transport2` |
| `Fluid_Tree.Fold` | 58 | Limiti, indici, non-aliasing, conservazione del corpo mondo; `local-lifecycle` |

Il contratto di Fold **non è ancora un modello funzionale completo della somma
ordinata di tutti i sottoalberi**. Le proprietà funzionali delle operazioni locali
sono provate; non chiamare Gold globale la sola prova di limiti/frame del ciclo.

## Lavoro ancora aperto

1. `Make_Ellipsoid` e `Build`: layout dei buffer geometrici, conservazione degli
   invarianti del prefisso e conclusione della validità della memoria. Le prove
   lunghe hanno raggiunto il watchdog; la passata diagnostica breve riporta gli
   obblighi specifici, senza trasformarli in bug dimostrati.
2. `Build_Wrenches`: costruzione delle velocità di ripiego, trasformazioni tra
   frame, limiti intermedi e precondizioni dei kernel. Il contratto del kernel
   ellissoidale non fornisce ancora il limite in uscita necessario a chiudere
   tutta la catena. Le sue prove fisiche rimangono fuori da questo candidato.
3. `Accumulate`: resta aperta la postcondizione `Is_Ready`; le altre proprietà
   di frame e le precondizioni dei chiamati sono chiuse in `frame-details2`,
   sotto i contratti di `Build_Wrenches` e `Fold`.
4. `Recursive_Path`, `Complete_Passive`, `Compute_Ready`, `Data.Initialize/Create`:
   chiusura delle proprietà di readiness/cache e dei chiamanti di creazione.
   Consultare `reuse-final`, `passive-callers`, `lifecycle-callers` per i dettagli.
   La vecchia diagnostica E0007 in `passive-callers` è corretta nel sorgente
   finale; il successivo `reuse-final` analizza `Compute_Ready` senza quel blocco.
5. Modello funzionale dell'intera risalita e verifica finale di unità/chiamanti
   sullo stesso snapshot. Non è stata eseguita una prova completa della dinamica.

Questi sono obblighi di ingegneria della prova, **non limiti matematici che
legittimano un'eccezione Silver**. Nessuna equivalenza universale con C viene
inferita dai test numerici.

## Test eseguiti

MuJoCo C 3.14.0, modello numerico e tolleranze del candidato di origine;
68 modelli, 12 scenari per modello, forze esterne non nulle abilitate.

| Test | Risultato |
| --- | --- |
| Compatible | 816 scenari, 132.072 confronti, zero fallimenti |
| Strict | 816 scenari, 132.072 confronti, zero fallimenti |
| Ciclo di vita box/ellissoidi | 200 cicli complessivi: creazione, già allocato, doppia Free, opzioni/coefficiente invalidi, ricreazione; pass |

Il probe differenziale libera il modello sorgente prima dei passi della
simulazione: esercita anche l'indipendenza dei dati copiati. I test coprono il
riuso RNE e i casi piccoli che usano le velocità di ripiego. I risultati restano
confronti numerici con tolleranza, non uguaglianza bit per bit.

Non sono stati misurati nuovi tempi integrati in questo intervento: **parità di
prestazioni con C non stabilita da questi risultati**. La risalita conserva la
struttura lineare negli elementi/corpi/giunti del candidato di origine; il nuovo predicato di validità degli elementi può aggiungere una scansione
quando `Is_Ready` viene valutata a runtime, anche attraverso un chiamante
esistente. Occorre misurarne il costo e chiudere le prove prima di eliminarne
le valutazioni ridondanti. Le build con asserzioni abilitate eseguono inoltre
i nuovi contratti, come negli altri moduli del progetto.

## Riproduzione e integrazione

- `work/` è il progetto completo di riferimento; `integration.patch` è il delta
  rispetto a `../work/` del candidato originale, con hash in `changes.json`.
  Verificare gli hash prima di applicarlo ad altri sorgenti e risolvere le
  modifiche concorrenti; non applicarlo alla cieca al checkout principale.
- Ogni `proofs/<run>/manifest.json` conserva opzioni e hash. Per ricostruire il
  suo snapshot, copiare `work/` e sovrapporre `source-overlay/` di quel run.
  I percorsi `/tmp` nei log indicano la posizione originale dell'esecuzione.
- Usare `experimental/smooth/tools/prove_fragments.py` con `--unit` e `--name`
  come nei manifest, iniziando sempre dal sottoprogramma minimo.
- I manifest numerici in `tests/verified-compatible` identificano il binario e
  tutti i sorgenti. Strict usa lo stesso eseguibile controllato.
- `tests/check_lifecycle.py` ricompila il probe specifico con la toolchain
  locale indicata nello script; i due MJB richiesti sono inclusi.

Le evidenze restano sperimentali fino alla chiusura degli obblighi elencati.
