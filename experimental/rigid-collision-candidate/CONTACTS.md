# Precontatti e geometrie avanzate — stato del candidato

Implementazione locale sperimentale Ada/SPARK, separata dal refactoring attivo
nella chat principale. Riferimento ufficiale MuJoCo 3.14.0,
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`. Nessuna chiamata C nel codice di
produzione del candidato. C compare esclusivamente negli oracoli dei test.

## Percorsi implementati

- `MJ.Primitive_Contacts.Generate`: tutte le 21 combinazioni delle sei primitive;
  distanza firmata, posizione, normale e tangente. Manifold specifici di piani,
  sfere, capsule e box; fino a due punti capsule–box; GJK/EPA, recupero di facce e
  spigoli dei cilindri; perturbazioni aggiuntive sulle coppie previste da C.
- `MJ.Convex_Contacts.Generate`: conserva i testimoni di ciascun vertice del
  simplex. GJK, ammissione del politopo ed EPA seguono il riferimento; il bordo
  del politopo viene attraversato con una pila limitata, evitando la ricorsione.
- `MJ.Contact_Features.Expand`: recupero di facce/spigoli dalle caratteristiche
  della faccia EPA; clipping di poligoni; riduzione a quattro contatti con la
  selezione di C. Facce dei cilindri discretizzate con lo stesso poligono a 16
  lati. Le mesh usano vertici **e poligoni compilati**, non un triangolo arbitrario
  scelto dopo il rilevamento della coppia.
- `MJ.Advanced_Contacts.Generate`: mesh convesse contro primitive e altre mesh;
  piano–mesh con selezione dei vertici di supporto. Margini e perturbazioni
  seguono C. `Rigid.Size` contiene le semiestensioni dell'AABB della mesh
  compilata; la diagonale è il raggio usato da C per distinguere i contatti.
- `MJ.Convex_Assets`: ammissione strutturale del grafo immutabile; selezione del
  massimo con conservazione del vertice precedente a parità di proiezione.
  I grafi compilati usano gli stessi semi direzionali 3×3×3 e lo stesso ordine
  degli adiacenti di C. Il massimo per i piccoli hull usa una ricerca completa;
  gli hull con almeno dieci vertici e grafo disponibile usano hill climbing.
- `MJ.Heightfield_Contacts.Generate`: trasformazione nel riferimento del terreno,
  AABB del secondo oggetto, restrizione alla sottogriglia, strisce di prismi
  triangolari, margini separati e ritorno dei contatti nel riferimento globale.
  Il limite di 50 contatti per coppia riproduce `mjMAXCONPAIR` di C.
- `MJ.Contact_Parameters`: priorità, `condim`, `solmix`, riferimento standard e
  diretto, `solimp`, attrito a cinque componenti e adesione di MuJoCo 3.14.
  `Configure` applica gli override globali e il minimo di attrito `mjMINMU`.
  Il margine di ammissione è separato dal margine di rilevamento, che include
  anche il gap. Le coppie esplicite forniscono direttamente `Parameters`,
  compreso `solreffriction`, prima della configurazione.
- `MJ.Full_Contacts.Finalize`: completa il frame come `mju_makeFrame`, marca
  i contatti nel gap, mantiene quelli adesivi nel gap con `condim=1` e
  inizializza soltanto i contatti prodotti. Azzera `mu` e l'Hessiana per questi
  contatti e imposta `efc_address=-1`, come il driver C prima dei vincoli.
- `MJ.Collision_Contacts.Generate` / `Generate_Terrain`: collegano la geometria
  alla finalizzazione, ricevendo i parametri già configurati una volta per
  coppia. Non effettuano una seconda ricerca geometrica né una seconda
  scansione di validazione dei contatti in release. Il chiamante sceglie le
  coppie; l'integrazione con il driver di scena resta da completare.

Lo spazio di lavoro viene riusato. Non viene allocata memoria per ogni contatto
o triangolo del terreno. I buffer di contatti sono inizializzati soltanto nel
prefisso attivo; `Relaxed_Initialization` sposta la verifica dell'inizializzazione
sugli obblighi di prova dei dati letti, senza azzerare tutta la capacità.
Questo aspetto **non sostituisce** la dimostrazione degli obblighi dei produttori.
Anche i parametri dei contatti non hanno inizializzazioni implicite per tutta
la capacità; `Default_Parameters` viene usato esplicitamente per la singola
configurazione della coppia.

## Differenze dal riferimento ufficiale

1. I centri coincidenti hanno un seme GJK deterministico; C può uscire senza
   simplex e perdere una collisione. È la correzione già documentata nella fase
   delle coppie.
2. Se l'euristica capsule–box di C non produce contatti, il candidato verifica la
   distanza esatta segmento–box e recupera il contatto con GJK/EPA. I falsi
   negativi C sono verificati indipendentemente in Decimal a 100 cifre.
3. Nel recupero edge–face, `polygonClip` di C può restituire zero nuovi punti;
   il chiamante inverte comunque i testimoni EPA originali. Il candidato
   conserva il contatto EPA originale. La fixture cilindro–cilindro dimostra
   distanza e posizione identiche e normale C opposta. Una ricompilazione di
   sola diagnosi della sorgente GJK conferma il poligono vuoto.
4. Il supporto nativo del prisma heightfield non imposta `vertindex`. Il criterio
   di arresto discreto di EPA usa invece la coppia degli indici dei vertici: due
   supporti di prismi differenti possono risultare indistinguibili. Il candidato
   conserva l'indice effettivo del vertice. I test mantengono **entrambi** gli
   oracoli: libreria ufficiale invariata e traversata C con questa sola
   correzione del supporto. Il secondo è un riferimento diagnostico modificato,
   **non** il C ufficiale e non è usato per dichiarare parità prestazionale.

Si conserva l'ordine delle operazioni del riferimento, comprese le divisioni
per componente in EPA e la formula nativa della matrice di semina a 120 gradi.
Quest'ultima è un seme di ricerca; non se ne afferma l'ortogonalità matematica.

## Prove e test

Le prove differenziali confrontano tutti i campi dei contatti e il numero di
punti; i benchmark consumano tutti i campi del risultato. I test C sono oracoli
campionati, non dimostrazioni universali.

I risultati aggiornati e i limiti aperti sono in
[results/20261001-contacts-followup/README.md](results/20261001-contacts-followup/README.md).
La proprietà del massimo supporto, incluse le parità del vertice precedente,
e il cambio di orientamento del manifold hanno prove funzionali. La prova
dell'intero GJK/EPA, della validità geometrica del grafo, del clipping e dei
chiamanti resta aperta: sono lavori di dimostrazione da completare, non
limitazioni matematiche che autorizzano un declassamento definitivo a Silver.
La miscelazione/configurazione dei parametri e l'inflazione dei punti di contatto
hanno prove funzionali complete delle loro unità. L'inflazione normalizza di
nuovo la differenza dei punti, come C, senza riutilizzare la distanza GJK:
le riduzioni arrotondate non sono intercambiabili.
La finalizzazione ha un contratto funzionale sulla conservazione di distanza
e posizione, sui parametri, sulle esclusioni e sui campi iniziali dei vincoli;
la sua prova modulare assume il contratto di `Make_Frame`. La prova del frame
e dell'intera unità resta distinta, con obblighi aperti: non si afferma la Gold
globale di `Full_Contacts`.

Il dispatcher ordina le coppie mesh–primitive come C e ripristina la normale
dell'ordine richiesto. La ricorsione di ordinamento è limitata a una chiamata
aggiuntiva, con variante intera provata. I test includono entrambi gli ordini
delle coppie mesh. Il driver delle prove restituisce ora un codice di errore
quando almeno una sua verifica non riesce.

## Ambiti ancora mancanti

SDF e relativi plugin/octree, collisioni complete dei flex, BVH e connessione
con il driver di scena dei contatti; costruzione dei vincoli e collegamento alla
dinamica. Una mesh di MuJoCo in questo percorso collide come hull convesso:
non si promette una superficie triangolare concava generale.

Le API hanno capacità esplicite: 50 contatti per coppia, 64 vertici per faccia,
64 caratteristiche incidenti e 128 vertici di clipping. Un superamento nelle
caratteristiche restituisce `Capacity_Limit`, non un manifold presentato come
completo. Il programma di prova usa pool di 8.192 vertici/poligoni e 65.536
interi per grafi; non sono limiti universali del formato MuJoCo.

Le misure disponibili sono della narrow phase con precontatti completi e pose
variabili. Mancano misure integrate della simulazione. Il riferimento C sceglie
la funzione della coppia prima del ciclo; Ada include il suo dispatcher. I
risultati rendono visibili i costi del percorso candidato, ma non stabiliscono
la parità di tutta la simulazione. Non vengono riusate le vecchie misure del
rilevamento booleano per sostenere questa fase.
