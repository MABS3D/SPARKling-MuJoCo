# Prove dei componenti ellissoidali — candidato isolato

Le prove funzionali locali richieste sono state estese e chiuse nei componenti
sotto elencati. **La dimostrazione dell'intero chiamante `Ellipsoid` resta aperta**:
il candidato non è pronto per essere dichiarato Gold nell'intera pipeline.
La repository principale e il candidato fluidi originale non sono stati modificati.
Non sono stati creati commit, merge o pubblicazioni GitHub.

Il riferimento controllato è il sorgente C MuJoCo 3.14.0,
`9ecbb9d7b5ee623f54745638d36799ff90e6f7cd`, in particolare
`mj_addedMassForces`, `mj_viscousForces` e `mji_ellipsoid_max_moment`.
La massa aggiunta include i termini dipendenti dalla velocità: il percorso forward
C passa `NULL` per l'accelerazione. Non si aggiungono i termini disabilitati in C.

## Risultati formali

| Unità/sottoprogramma | Obblighi verificati | Proprietà |
| --- | ---: | --- |
| `MJ.Fluid_Added_Mass`, intera unità | 110 | Momenti lineari/angolari, tre componenti di forza e tre di coppia; composizione esatta e limiti |
| `MJ.Fluid_Geometry`, intera unità | 95 | Volume, dimensione intermedia, area, normalizzazione dei semiassi, viscosità e momenti angolari |
| `MJ.Fluid_Lift`, intera unità | 130 | Portanza Magnus, circolazione e portanza Kutta; formule scalari e vettoriali |
| `MJ.Fluid_Projection`, intera unità | 101 | Numeratore/denominatore della proiezione, normale, coefficienti di resistenza e composizione della norma con il runtime |
| `Prepare_Ellipsoid` | 72 | Limiti e valore funzionale di tutti i campi della cache |
| `Blend_Force`, `Blend_Torque` | 20 | Composizione ordinata delle forze e coppie con il coefficiente di interazione |
| `Fourth` | 4 | Potenza quarta floating point e limite del risultato |
| **Totale dei risultati selezionati** | **532** | **Nessun obbligo aperto nei risultati di queste righe** |

I conteggi comprendono sicurezza, contratti e terminazione; non sono 532 teoremi
fisici distinti né necessariamente 532 nuove verifiche. Le funzioni specificano
l'algoritmo floating point ordinato, senza identificare le operazioni arrotondate
con identità esatte sui reali. I rapporti e gli hash sono in `proof-summary.json`
e nell'archivio. La corrispondenza tra sorgenti finali e dipendenze dei progetti di
prova selezionati è stata controllata automaticamente.

La scomposizione mantiene l'ordine aritmetico dei prodotti, prodotti vettoriali e
somme. `Torque_Sum` isola la somma delle coppie; le nuove unità isolano formule
prima concentrate in `Ellipsoid`. I contratti della cache sono più completi.
I limiti di alcuni intermedi sono conservativi; il dominio interno di `Blend_Input`
è stato ampliato per rappresentarli. Nessuna nuova scansione, allocazione nel passo,
assunzione, soppressione di controlli o corpo escluso da SPARK è stata introdotta.
L'asserzione sulla normalizzazione è dimostrata; non è un'assunzione.

## Cosa rimane aperto

`Ellipsoid` deve ancora dimostrare i contratti dei chiamati e i limiti dei risultati
intermedi. I tre risultati di radice quadrata coinvolgono velocità, area proiettata
e norma del momento angolare. Il contratto di `Sqrt` della libreria GNAT garantisce
nonnegatività e alcuni casi particolari, ma non un limite superiore quantitativo.
I limiti da giustificare sono `1e14` per la velocità e `1e76` per gli
altri due risultati. Sono conservativi: il problema è esprimere e verificare
il collegamento con la radice del runtime, non cambiare le formule fisiche.
La prova di `Norm` ne specifica l'esatta composizione: **non prova da sola il limite
superiore necessario al chiamante**. Analogamente, i contratti della portanza sono
chiusi per gli ingressi dichiarati; resta da provare che il chiamante li fornisca.

Questo è lavoro di modellazione/verifica ancora aperto, non un'eccezione matematica
che autorizzi a dichiarare Silver concluso o Gold globale. Non sono stati inventati
assiomi sulla radice né aggiunti rami che scartano ingressi per facilitare la prova.
La specifica funzionale globale di `Ellipsoid`, l'integrazione con il percorso
fluidi, i metadati e la traversata dei corpi rimangono fuori dalla chiusura locale.

L'ultimo tentativo sull'intero sottoprogramma termina in timeout dopo 250.2 secondi: non ha dimostrato la chiusura, né consente di contare gli obblighi residui. Il precedente tentativo completo, sulla variante con intermedi scalari tipizzati, riportava sei diagnostiche aperte: tre sui limiti delle radici, una sul segno dell'argomento e due sui limiti delle forze. Non si trasferisce automaticamente questo conteggio alla variante finale. Tutte le evidenze sono conservate.

## Confronti numerici

Il sorgente finale passa 408 scenari e 66.036 confronti per ciascuna delle modalità
Strict e Compatible: **132.072 confronti complessivi**. Sono gli stessi scenari
esercitati nelle due politiche, non 816 configurazioni fisiche distinte.
Sono comprese 53 fixture fluidi e 15 preesistenti, forze esterne simultanee,
forme diverse, portanza isolata/combinata, vento nullo e molto piccolo,
rami di disabilitazione e modelli a 24 DOF. Tolleranza:
`2e-10 + 2e-10*abs(riferimento)`. Anche i controlli di ciclo di vita e i test di
rifiuto della modalità Strict passano; il tool li esegue in Strict anche quando
il confronto numerico richiesto è Compatible.
Questi test non costituiscono una prova universale di equivalenza al C.

Eseguibile checked finale: `a9404009bd42c214cf88d6299fa03e8e86316ce7fb1053d769567aac0fd340b8`.

## Prestazioni integrate

Confronto tra il candidato fluidi precedente congelato, il candidato di questa
conversazione e C nativo SIMD. Una sessione: sette modelli, tre stati per modello,
24 blocchi bilanciati sulle sei permutazioni dei tre eseguibili, 12 campioni da
100 passi per invocazione, due riscaldamenti, CPU 12. Preparazione e I/O fuori dal
tratto misurato; ogni traiettoria controllata rispetto a C. Dispersione, p95 e
intervalli bootstrap al 95% sono conservati. Altri processi di prova erano attivi:
misure diagnostiche, non un'accettazione definitiva a macchina quieta.

La tabella mostra l'intervallo delle tre mediane per stato; non un intervallo di
confidenza. Negativo significa più veloce. Non si usa una media tra modelli.

| Modello | Variazione vs candidato precedente | Variazione vs C |
| --- | ---: | ---: |
| fluid_ellipsoid_branches24 | -0.82% … +1.36% | -9.35% … -5.18% |
| fluid_ellipsoid_chain24 | -6.65% … +0.30% | -5.01% … +1.15% |
| fluid_ellipsoid_ellipsoid_all | -1.59% … +0.79% | -21.21% … -20.18% |
| fluid_ellipsoid_multiple | -2.11% … +4.23% | -27.82% … -24.83% |
| fluid_ellipsoid_sphere_all | +0.77% … +2.32% | -21.24% … -14.58% |
| fluid_ellipsoid_star24 | +0.24% … +4.08% | -12.40% … -6.17% |
| fluid_flags_both_off | -0.62% … +2.01% | -0.82% … +1.47% |

Non è dimostrata l'assenza di regressioni: sulla sfera, uno stato ha mostrato circa
+2,3% rispetto al candidato precedente con intervallo sopra zero; va ricontrollato
senza carico concorrente. La catena e i fluidi disabilitati restano inconclusivi
rispetto a C. **La parità globale non è dichiarata.**

L'ultimo affinamento dei sottotipi produce un eseguibile release byte per byte
identico a quello misurato (`b344eea6e4a2137536d843f32084b7e6409e61a4dd8e4e92aa2dea1cfbb79263`); la verifica checked è stata ripetuta
sui sorgenti finali. I manifest includono compilatore, opzioni, hash di sorgenti,
eseguibili e riferimento. Non si trasferisce una misura a un binario diverso.

## File e riproduzione

- `candidate/`: copia sorgente autonoma, con le modifiche locali.
- `ellipsoid-proofs.patch`: dieci file rispetto al candidato fluidi iniziale.
- `changes.json` e `origin.json`: hash prima/dopo e provenienza.
- `evidence.zip`: rapporti riusciti, tentativi incompleti, risultati numerici,
  misure grezze, manifest di build e sorgenti iniziali dei componenti.
- `build.py`, `measure.py`: script effettivamente usati; conservano i percorsi
  `/var/tmp` della sessione, da adattare se si sposta o elimina quell'area.

La patch è stata verificata con `git apply --check` sulla copia iniziale congelata.
Non applicarla alla cieca sopra modifiche concorrenti. Il pacchetto non incorpora
la compensazione della gravità della precedente conversazione laterale.

Esempio di verifica dalla cartella di questo rapporto, con toolchain già installata:

```sh
ulimit -s 65536
python3 candidate/experimental/smooth/tools/prove_fragments.py --repo candidate --report-dir /var/tmp/ellipsoid-recheck-new --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --whole-unit mj-fluid_added_mass --whole-unit mj-fluid_geometry --whole-unit mj-fluid_lift --whole-unit mj-fluid_projection --provers cvc5,z3,altergo --prover-seconds 15 --steps 0 --jobs 2 --cap-mb 3000 --wall-seconds 300 --prepare-seconds 300 --total-seconds 1300
/var/tmp/sparkling-movement-env/bin/python candidate/experimental/smooth/tools/compare_numerics.py --repo candidate --report-dir /var/tmp/ellipsoid-numerics-new --toolchain-root /var/tmp/sparkling-matrix-recovery/toolchains --extra-fixtures fixtures --samples 6 --external --policy Strict
```

Usare nuove directory per ogni esecuzione. I timeout non sono prove riuscite e i
risultati delle sole righe (`--limit-line`) non sono prove complete di sottoprogrammi.
