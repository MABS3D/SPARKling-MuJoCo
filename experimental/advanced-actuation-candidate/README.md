# Trasmissioni e attuazione avanzata — candidato isolato

Implementazione Ada/SPARK degli algoritmi di trasmissione e dei modelli avanzati
di MuJoCo **3.14.0**, riferimento
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`.

Questo progetto compila ed esegue i nuovi sottoprogrammi separatamente dal motore.
Il candidato usa ora buffer CSR dimensionati e riutilizzati dal chiamante:
**tutti i 17 carichi di attuazione misurati sono più veloci di C**, con risultati
numerici verificati. La parità della simulazione completa e la dimostrazione
formale globale restano aperte. L’adapter [advanced-step](../advanced-step/README.md) collega ora PID/DC/SO3 e
trasmissioni joint/SO3-site a Model/Data e al movimento Euler, con808/808
traiettorie verificate nella ripresa del3ottobre. La composizione completa resta
pendente; i numeri storici sotto sono riferiti ai propri hash, non alla pipeline
attuale.

## Funzionalità implementate

| Unità | Funzionalità |
|---|---|
| `MJ.Actuator_Curves` | Guadagno e bias affini, curve muscolari attive/passive, dinamica di attivazione, sigmoid, filtro, Euler, wrapping periodico, antiwindup e leggi scalari PID/DC |
| `MJ.Actuator_Geometry` | Normalizzazione e prodotto di quaternioni, log/expmap, errore di orientamento, rotazione di vettori, geometria e derivate slider-crank, forza SO3 e limite di norma |
| `MJ.Transmissions` | Compressione CSR, conservazione dello schema dei tendini, velocità con quattro accumuli, proiezione sparsa delle forze, colonne site/refsite e adesione |
| `MJ.Actuator_Transmissions` | Joint hinge/slide/ball/free, joint-in-parent, tendon, slider-crank, site/refsite, body adhesion e tre uscite SO3; identificazione degli antenati comuni |
| `MJ.Advanced_Actuators` | Muscolo, PID con slew e integrale, motore DC con corrente/termica/cogging/LuGre, avanzamento degli stati, servo SO3 quaternion/expmap |

I moduli ricevono dati cinematici già preparati. `Tendon` riceve lunghezza e
Jacobiano del tendine; non costruisce percorsi o wrapping. `Site` riceve pose e
Jacobiani dei due siti. `Body_Adhesion` riceve la proiezione dei contatti attivi,
la somma ordinata dei Jacobiani normali dei contatti nel gap e il conteggio dei
contatti rilevanti. Collisioni, vincoli e Jacobiani devono essere prodotti dal
motore chiamante.

Gli stati DC seguono l'ordine di C: **slew, integrale, temperatura, bristle,
corrente**, omettendo quelli disabilitati. La tensione usa l'integrale precedente
anche con `actearly`; soltanto la forza dovuta alla corrente usa la corrente
avanzata. Il limite della forza elettrica viene applicato prima di cogging e
LuGre. L'integrale DC viene limitato durante l'avanzamento; quello PID segue il
diverso comportamento di C. Corrente e bristle usano gli aggiornamenti esatti
di C, gli altri stati usano Euler.

La velocità CSR combina i quattro accumuli come `(s0+s2)+(s1+s3)` e poi tratta
la coda. La proiezione salta le forze nulle. La compressione elimina gli zeri
prima del prodotto per gear: un gear nullo conserva lo schema prodotto da valori
inizialmente non nulli. Il tendine conserva anche gli zeri strutturali del suo
schema originale.

## Contratti e dominio

Le specifiche contengono precondizioni su dimensioni, indici, topologia,
resistenza, parametri e limiti numerici, insieme a relazioni funzionali e modelli
ghost della sequenza delle operazioni floating point. I modelli statici non
introducono scansioni di verifica nella build release.

Il dominio del candidato è esplicito: al massimo 4096 DOF e 4096 contatti nel
conteggio dell'adesione; ingressi scalari
Tier0 limitati a ±1e10; passo e denominatori positivi indicati nelle specifiche
almeno `Min_Val` (1e-15). La resistenza termica grezza deve restare positiva e
almeno `Min_Val`. Non sono ammesse NaN o infinità. Alcuni casi geometrici estremi
restituiscono `Accepted=False`: il chiamante deve gestirlo. Questi limiti non
costituiscono equivalenza per ogni input accettato da MuJoCo C.

Le prove chiuse riguardano i contratti indicati nel [resoconto](evidence/proofs.md),
sotto le precondizioni e i contratti dei chiamati. I timeout, gli invarianti
ancora aperti e i modelli incompleti delle funzioni elementari rimangono lavoro
di dimostrazione da completare. **Non sono eccezioni matematiche che autorizzano
a dichiarare Silver concluso.** Le unità con obblighi aperti non sono neppure
interamente dimostrate per l'assenza di errori runtime.

## Verifica numerica

La suite contiene **4836 casi**, passati con controlli attivi e nella build
ottimizzata. L'oracolo usa la libreria C della distribuzione ufficiale Python
MuJoCo 3.14.0 e, per le funzioni private necessarie, estratti C conservati
letteralmente. Versione, hash, intestazioni e compilazione dell'oracolo sono
registrati in [oracle.json](evidence/oracle.json). La suite verifica che il
riferimento non sia cambiato prima di eseguire i confronti.

Sono coperti tutti i tipi di joint, joint-in-parent, site/refsite/SO3, tendini
fissi e slider-crank; tutte le 32 combinazioni degli stati DC; PID con integrale
oppure slew e wrapping periodico; SO3 in entrambi i formati; muscoli; adesione
con contatti attivi/gap/assenti, coni pyramidal/elliptic e condim 1/3/4/6;
riduzioni CSR da 0 a 40 DOF, code e cancellazione; filtro esatto e antenati comuni.

Due gruppi diagnostici, le 200 verifiche algebriche dello slider e i 75 casi
topologici, hanno un'aspettativa calcolata separatamente in Python. Gli altri
4561 casi comprendono confronti con C; alcune fixture includono anche intermedi
calcolati in Python. I casi completi slider/tendon/site/joint usano
pose, lunghezze e momenti prodotti da `mj_forward`. Gli stati e le forze DC,
gli stati PID e l'avanzamento del filtro sono confrontati con C; tre intermedi
privati DC (tensione, resistenza e posizione efficace) non vengono confrontati
direttamente. La tolleranza usuale è assoluta e relativa 2e-12; il caso CSR con
cancellazione richiede uguaglianza numerica esatta.

Limite del riferimento 3.14.0: il compilatore XML rifiuta il PID con integrale
e slew entrambi attivi (`actdim=2`, controllo in `user_objects.cc`). L'API Ada
prevede i due stati insieme, ma quel caso non ha una fixture XML differenziale
completa. Non è stata aggirata la validazione del compilatore C.

I risultati e gli hash dei sorgenti/eseguibili sono in
[numerics-validation.json](evidence/numerics-validation.json) e
[numerics-release.json](evidence/numerics-release.json).
Questi test non dimostrano equivalenza universale, stabilità fisica o prestazioni.

## Riproduzione

Servono GNAT/GPRbuild, GNATprove per le prove, GCC e Python con MuJoCo 3.14.0 e
NumPy. Nel dispositivo usato, Python è
`/var/tmp/sparkling-movement-env/bin/python`; i percorsi del toolchain usato
sono riportati negli esiti delle prove. Eseguire da questa cartella, con un
PATH contenente i binari GNAT/GPRbuild nativi Linux:

```sh
gprbuild -P actuation.gpr -j1
/var/tmp/sparkling-movement-env/bin/python tests/build_oracle.py
/var/tmp/sparkling-movement-env/bin/python tests/compare.py
ACTUATION_MODE=release gprbuild -P actuation.gpr -j1
ACTUATION_MODE=release /var/tmp/sparkling-movement-env/bin/python tests/compare.py
python3 tests/prove.py --unit mj-transmissions --subprogram Compress \
  --out /var/tmp/actuation-proof-compress --timeout 10 --provers cvc5,z3,altergo
python3 tests/prove.py --unit mj-transmissions \
  --out /var/tmp/actuation-proof-transmissions --timeout 2 --provers cvc5,z3
```

Le build finiscono fuori dalla repo, in
`/var/tmp/sparkling-actuators-20260930/build/{validation,release}`.
`ACTUATION_BUILD_ROOT` permette un'altra destinazione. Per cambiare destinazione
anche nei test, adeguare il percorso dell'eseguibile in `compare.py`.
Validation usa `-O2 -gnata -gnato -gnatVa`; release usa
`-O3 -gnatp -gnatn -march=native -flto`. Entrambe disabilitano la contrazione FP.
La release serve alla verifica numerica; non viene dichiarata pronta per uso
con input non verificati dal chiamante.

## Buffer CSR e confronto prestazionale

Il [confronto corrente](evidence/performance/20260930-csr/README.md) misura
versione precedente, versione corretta e C nella stessa sessione, con nove
blocchi e tre campioni per blocco. Sono inclusi trasmissione, velocità,
forza/dinamica dell'attuatore, avanzamento dell'attivazione e proiezione sparsa.
Tutti i 17 rapporti Ada/C hanno l'intervallo di confidenza sotto 1. Nei DC
con 1/8/32/64 attuatori i tempi corretti sono circa 0,073/0,513/2,019/4,061 µs;
la riduzione del tempo rispetto a C è circa 42/27/26/23% sui rapporti appaiati.

Il costo precedente derivava da un `Result` fisso da circa 144 KiB restituito
per valore. Ora `Result` e `Row` sono tipi `limited`: il linguaggio impedisce
copie implicite. Il chiamante sceglie la capacità del workspace e lo riusa;
le trasmissioni sono procedure che scrivono solo colonne e valori attivi.
`Reset` azzera esclusivamente metadati e lunghezze. Le righe sono contigue,
con `Row_Adr` e `Row_N`; velocità e proiezione accettano slice con offset.
Le formule geometriche, muscolari, PID, DC e SO3 sono invariate.

Esempio di allocazione fuori dal ciclo: `R : Result (3*NV-1);` riserva al
massimo tre righe di NV elementi; il discriminante indica l'ultimo indice
zero-based (`-1` per capacità nulla). Un chiamante che conosce uno schema più
piccolo può riservare il numero necessario di elementi. `Joint (R, ...)`,
`Tendon (R, ...)`, `Site (R, ...)`, `Slidercrank (R, ...)` e
`Body_Adhesion (R, ...)` aggiornano direttamente questo workspace.
I valori oltre i prefissi attivi non hanno significato fisico e non vanno letti.
La nuova compressione ne dimostra esplicitamente la conservazione.

L'assembly della fase misurata non contiene chiamate a `memcpy` né copie da
147512 byte. Restano gli azzeramenti necessari, come le forze generalizzate.
I 27 controlli aggiuntivi in `csr_workspace_probe` verificano offset, slice
vuote, gear nullo, indici fino a 4095, conservazione delle code e riuso del
workspace fra joint/SO3/tendon/adhesion/site, con controlli attivi e in release.

Questa misura riguarda la fase su stati preparati. Nei casi site/refsite/SO3-site,
slider-crank e adesione i Jacobiani sono preparati per Ada, mentre C li calcola
nella fase: il confronto favorisce Ada. Non è una misura dell'intera simulazione.
Il [confronto iniziale](evidence/performance/20260930/README.md) e le
[prove precedenti](evidence/history/20260930-fixed-capacity/proofs.md) sono
conservati come evidenza storica; non descrivono i sorgenti correnti.

Riproduzione del benchmark (build con `gprbuild -P performance.gpr -j1`):

```sh
/var/tmp/sparkling-movement-env/bin/python tests/performance/compare.py \
  --blocks 9 --samples 3 \
  --baseline /var/tmp/sparkling-actuators-csr-20260930/before/actuation_bench \
  --out /var/tmp/actuation-csr-new-run
```

`--baseline` è opzionale: il confronto Ada/C funziona anche senza il binario
storico. La destinazione deve essere nuova. I percorsi della libreria nativa,
del toolchain e degli estratti C sono registrati negli esiti.

## Integrazione e prestazioni ancora da completare

1. Collegare i moduli a Model/Data 3.14.0: blocchi di input/output/attivazione e
   rispettivi `ctrlnum/ctrladr`, `outnum/outadr`, `actnum/actadr`. Non assumere
   che un attuatore abbia sempre un controllo o una forza scalare.
2. Preparare Jacobiani, pose, contatti e schema dei tendini nella pipeline.
   Collegare control/activation clipping, disabilitazione/sleep, limiti aggregati
   di tendini e joint e gestione globale degli stati. Per SO3 lo stato va
   avanzato e riancorato dal chiamante secondo C.
3. Chiudere gli obblighi formali indicati negli esiti e dimostrare le
   precondizioni nei chiamanti. Callbacks e plugins utente non sono inclusi.
4. Collegare il workspace CSR al compilatore del modello e ai buffer del motore,
   dimensionando la capacità in base agli schemi compilati. La verifica `Valid`
   rimane quadratica nella build con contratti attivi; le sue scansioni non
   vengono eseguite nella release.
5. Misurare una simulazione equivalente completa contro il C con SIMD normale,
   mantenendo preparazione/I/O fuori dal tempo misurato. **Parità prestazionale
   aggregata ancora non misurata.**

Licenza e attribuzione: [LICENSE](LICENSE), [NOTICE](NOTICE).
