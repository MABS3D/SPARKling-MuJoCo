# Ottimizzazione della dinamica articolata — 2026-09-24

Questo rapporto conserva il confronto precedente al cambio di politica del
solver. Per il nuovo default e le misure aggiornate vedere
[Politica dell'inerzia e costo residuo](inertia-policy.md).

Implementazione nel prototipo sperimentale `experimental/smooth`, successiva
all'[analisi degli algoritmi C](c-dynamics-algorithm-audit.md). Il riferimento
rimane MuJoCo 3.14.0, commit `9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

## Cosa cambia

* **Massa CRB:** riferimenti comuni centrati sul centro di massa della radice,
  inerzie spaziali a dieci componenti, accumulo figli→genitori, un prodotto
  inerzia–asse per DOF e prodotti scalari con i soli antenati. Il risultato
  resta nella matrice densa pubblica. Sono gestiti corpi fissi, più giunti per
  corpo e alberi separati.
* **Forze ricorsive:** le forze dei corpi vengono accumulate lungo l'albero e
  proiettate una volta per giunto. Gravità e bias restano due risultati pubblici
  separati. Si riutilizzano le accelerazioni di bias della cinematica esistente;
  non è ancora un porting completo di `mj_comVel`/`mj_rne`.
* **Percorso denso:** conserva il prodotto inerzia–colonna una volta per corpo
  e colonna, mantenendo l'ordine delle somme dei contributi.
* **Risoluzioni:** il controllo del condizionamento conserva le divisioni della
  diagonale scalata tra le risoluzioni dei vettori della base. Non sostituisce
  divisioni con reciproci. Se lo smorzamento è nullo, Euler riutilizza
  l'accelerazione già calcolata evitando la seconda fattorizzazione/risoluzione.

CRB e accumulo ricorsivo sono selezionati da tre DOF in su. Centri e ancoraggi
oltre il dominio rapido, o somme che eccedono i limiti intermedi, attivano il
percorso denso. I risultati rapidi sono preparati in array locali con `D` in
sola lettura e pubblicati soltanto a completamento riuscito. Non vengono
introdotti nuovi buffer persistenti o modifiche alla deallocazione.

Le sette scansioni `Is_Ready`, il controllo relativo del condizionamento, le
politiche di rifiuto e il solver LDL denso restano attivi. Lo stato Ready_Flag
misurato nell'esperimento precedente non viene promosso in questa modifica.

## Correttezza e ambito delle prove

I kernel spaziali specificano l'ordine effettivo delle operazioni floating point,
con leggi per componente e limiti numerici: trasformazioni di riferimento,
inerzie, somme, prodotti spaziali, assi e forze. Le prove sono state avviate sui
sottoprogrammi minimi; l'unità completa `MJ.Spatial_Kernels` chiude **413 obblighi,
zero non dimostrati**. Chiudono separatamente anche i nuovi helper per cache,
diagonale scalata, forze dei corpi, presenza dello smorzamento e il lemma di
scrittura simmetrica.

Questo è Gold locale rispetto ai contratti, non una dimostrazione della dinamica
intera. Gli invarianti e le precondizioni nelle due nuove ricorsioni hanno ancora
obblighi aperti nelle invocazioni diagnostiche archiviate. Non sono classificati
Silver: sono lavoro di prova ancora da completare, non limiti matematici.
Nessun `Assume` o nuova esclusione dalla verifica è stato aggiunto.

La diagnostica finale limitata a CVC5, un secondo per obbligo, riporta 75
obblighi aperti su 174 nel CRB e 45 su 89 nell'accumulo delle forze. Sono
precondizioni, invarianti e postcondizioni ancora da chiudere, non errori di
esecuzione dimostrati. I log distinguono questi esiti dalle prove locali chiuse.

Il confronto con C usa una build con controlli e contratti attivi: **480 scenari,
78.720 confronti**, sette casi limite di normalizzazione e 14 casi di politica
degli errori. Include le matrici di massa, forze separate, accelerazioni, residui,
traiettorie, rami multipli, radici multiple, 24 DOF, smorzamento nullo e fallback.
La tolleranza è `2e-10 + 2e-10*abs(riferimento)`. Il nuovo ordine di sommatoria
non richiede identità bit per bit con il vecchio assemblaggio.

## Prestazioni del movimento completo

I risultati sono registrati dopo build, prove e confronti numerici, in due
sessioni separate sulla CPU 12. Ogni caso usa 24 blocchi con le sei permutazioni
dell'ordine baseline/SPARK/C, quattro traiettorie da 100 passi per processo e
tre stati iniziali per modello. C conserva le normali ottimizzazioni SIMD.

| Modello | Prima, µs/passo | Ora, µs/passo | C, µs/passo | Variazione tempo SPARK | Ora / C |
|---|---:|---:|---:|---:|---:|
| 1 DOF | 0,696 | 0,699–0,701 | 0,429 | +0,3…+1,0% | 1,62–1,64× |
| 5 DOF ramificati | 3,043–3,123 | 2,805–2,816 | 0,997–0,998 | −7,3…−8,4% | 2,81–2,91× |
| 12 DOF in catena | 15,601–15,821 | 10,521–10,720 | 2,069–2,102 | −31,9…−33,2% | 5,04–5,16× |
| 6 DOF, smorzamento nullo | 4,441–4,519 | 3,344–3,348 | 0,951–0,952 | −24,0…−25,1% | 3,50–3,55× |
| 24 DOF in catena | 74,004–74,760 | 36,908–37,194 | 4,706–4,746 | −50,2…−50,6% | 7,77–7,89× |

I tempi riportano l'intervallo fra le due mediane di sessione, ciascuna ottenuta
dalle tre mediane degli stati. Le variazioni e i rapporti riportano invece il
minimo/massimo delle sei stime appaiate stato–sessione: non sono intervalli di
confidenza e non sono calcolati dividendo gli estremi della tabella.

Tutti i 12 casi con più DOF, in entrambe le sessioni, hanno intervalli
appaiati al 95% sotto 1 per il rapporto nuovo/precedente. Nel caso a 1 DOF le
mediane indicano una piccola regressione: cinque intervalli su sei comprendono
1, mentre uno della prima sessione è `[1,0025; 1,0172]`. Non si dichiara né un
guadagno né equivalenza certa su quel caso, e non si applica una soglia arbitraria
di rumore. La modifica è mantenuta per il recupero ripetuto nei casi multi-DOF;
il piccolo caso resta da rifinire.

**La parità con C non è raggiunta.** Il tempo della catena a 24 DOF è circa
dimezzato, ma resta quasi otto volte quello del C. Le due sessioni confrontano
2.160 esecuzioni di processo; tutti gli stati finali passano, con scarto massimo
osservato rispetto all'oracolo `1,63e-14` e fra versioni Ada `1,47e-14`.

Gli intervalli sono bootstrap appaiati sui blocchi della singola sessione,
senza correzione per confronti multipli. La variabilità fra sessioni e fra stati
va letta insieme agli intervalli; una differenza piccola non viene dichiarata
automaticamente rumore. I casi senza contatti del prototipo non rappresentano
ogni applicazione MuJoCo.

## Lavoro che rimane

* Chiudere le prove di composizione e conservazione dello stato prima di usare
  il recupero già misurato sulle scansioni `Is_Ready`.
* Ridurre il costo del controllo del condizionamento con un criterio numerico
  giustificato e fallback: nella catena smorzata a 12 DOF restano 24 risoluzioni
  aggiuntive per passo rispetto al C.
* Portare e specificare fattorizzazione/risoluzione compatte del C, inclusi
  arrotondamenti e politica dei pivot. La catena ha triangolo pieno: il solo
  formato sparso non elimina il costo cubico.
* Ridurre la costruzione dei Jacobiani densi nella cinematica, che sono ancora
  prodotti per l'interfaccia e per il percorso di fallback.

[Riproduzione ed evidenza](../tests/movement_performance/dynamics_optimization/README.md).

Follow-up: [validated entry reuse and deferred Jacobians](readiness-performance.md)
records the next implementation, proof scope and whole-step measurements.
