# Attribuzione diagnostica del costo rispetto a MuJoCo C

Misure del 2026-09-26, riferimento MuJoCo 3.14.0 con SIMD normale. Il codice
attivo del simulatore non è stato modificato. Le varianti che disabilitano
controlli sono esperimenti deliberatamente **non dimostrati**, non proposte già
accettabili per produzione né nuovi risultati Gold.

## Risultato

Le validazioni ripetute sono il primo costo eliminabile nell'esperimento;
i controlli numerici interni selezionati sono il secondo. La massa compatta e
la fusione gravità/bias incidono molto meno sui modelli misurati.

Riduzione percentuale del **tempo totale del passo rispetto alla baseline Ada**.
Ogni intervallo riporta minimo/massimo delle mediane dei rapporti appaiati,
fra tre stati e due sessioni; non è un intervallo di confidenza.

| Variante diagnostica | Catena 24 | Stella 24 | Foresta 24 | Misto 8 |
|---|---:|---:|---:|---:|
| Senza le quattro validazioni di readiness | 22,4–22,8% | 31,5–32,7% | 27,8–29,6% | 41,7–42,1% |
| Senza le tre Phase_Ready, conservando Is_Ready iniziale | 18,7–19,6% | 25,2–26,9% | 24,4–25,8% | 33,9–34,7% |
| Senza i controlli numerici interni selezionati | 15,2–16,2% | 10,9–12,0% | 10,9–12,5% | 13,8–14,4% |
| Gravità e bias combinati nel RNE | 0,6–1,3% | 0,3–1,9% | 0,5–2,0% | 1,9–2,9% |
| Massa direttamente compatta, variante verification | 1,3–2,9% | 0,1–0,9% | 2,2–4,0% | 2,9–4,2% |
| Quattro validazioni + controlli interni disabilitati | 38,2–39,5% | 42,7–44,1% | 40,8–41,8% | 52,8–53,2% |
| Precedente + massa compatta + RNE combinato | 40,9–41,6% | 45,8–46,1% | 43,7–44,9% | 55,1–55,5% |

Le prime tre righe hanno CI bootstrap appaiati al 95% interamente sotto 1
in tutti i 24 confronti stato/sessione. Il piccolo effetto del RNE combinato
non è distinto dal rumore in tutti i casi: 3/6 confronti sulla catena,
4/6 sulla stella, 5/6 su foresta e misto hanno CI sotto 1. Per la massa
compatta sono rispettivamente 5/6, 1/6, 6/6 e 5/6. Nessuna correzione per
confronti multipli: non interpretare un singolo risultato marginale come conferma.

Non sommare le percentuali: le trasformazioni interagiscono, anche attraverso
inlining, eliminazione di codice e disposizione delle istruzioni. Questi sono
effetti causali delle varianti compilate, non conteggi puri di cicli spesi nei
predicati. Non sono neppure limiti superiori matematicamente garantiti.

## Quanto divario resta

| Modello | Baseline Ada / C | Variante diagnostica combinata / C |
|---|---:|---:|
| Catena 24 | 1,95–1,99× | 1,15–1,16× |
| Stella 24 | 2,54–2,60× | 1,36–1,39× |
| Foresta 24 | 2,27–2,33× | 1,27–1,28× |
| Misto 8 | 1,70–1,72× | 0,76–0,77× |

La sola combinazione delle due famiglie di controlli rimuove diagnosticamente
il 70–81% del tempo **in eccesso rispetto a C** sui tre modelli a 24 DOF.
Il calcolo è `(T_base - T_variante) / (T_base - T_C)` su blocchi appaiati.
Questo NON prova che sia possibile conservare tutti i contratti eliminando
l'intero costo. La variante senza readiness elimina anche il controllo iniziale;
C mantiene i propri controlli. Il confronto non certifica parità di garanzie.

## Il quinto punto: compilatore e codice macchina

Non è una componente indipendente da sommare alle altre quattro. Tutte le
trasformazioni possono modificare il codice generato. Per misurare almeno
una sensibilità concreta abbiamo ricompilato la baseline con
`-fno-tree-vectorize -fno-tree-slp-vectorize`, senza cambiare sorgente.

| Modello | Aumento del tempo disabilitando l'autovettorizzazione Ada |
|---|---:|
| Catena 24 | 29,0–30,3% |
| Stella 24 | 4,2–6,4% |
| Foresta 24 | 6,8–8,2% |
| Misto 8 | 13,3–14,5% |

Il nostro compilatore sta già fornendo un beneficio significativo. Questa prova
non misura un presunto vantaggio del compilatore C, non disabilita ogni possibile
istruzione SIMD e non attribuisce al compilatore il residuo dopo le altre
trasformazioni. Per separare ulteriormente inlining, copie e layout occorrono
esperimenti specifici sul codice macchina, mantenendo costante il lavoro eseguito.

## Trasformazioni e limiti semantici

- `scans`: sostituisce con False le quattro condizioni eseguibili Is_Ready/
  Phase_Ready all'ingresso di Step e delle tre fasi. I controlli dei setter,
  del caricamento e dei flag di cache restano.
- `phase_scans`: disabilita solo le tre Phase_Ready e conserva Is_Ready in Step.
- `guards`: disabilita le condizioni numeriche selezionate nei percorsi pose,
  preparazione spaziale, forze e inerzia; rende True i due risultati
  Motion_Bounded; azzera i contatori di rifiuto nei kernel di aggiornamento
  delle righe e nei prodotti della riduzione veloce. Le patch archiviate
  definiscono esattamente lo scope: non equivale a eliminare ogni controllo
  numerico nel programma. Readiness, pivot clamp, validità strutturale e
  gestione degli errori non selezionata restano.
- `fused`: inizializza l'accelerazione del mondo con -gravità, come mj_rne C;
  propaga una sola forza e proietta una sola volta. Il risultato interno
  Gravity diventa zero e Bias include la gravità: **non conserva la semantica
  delle API che espongono separatamente quelle grandezze**. Cambiano anche
  ordine floating-point e condizioni di rifiuto su input estremi. È un test
  del costo per il movimento, non un'implementazione pronta da integrare.
- `compact`: usa esattamente la variante verification dell'esperimento
  compact_mass_retry, con le relative prove d'integrazione ancora aperte.
- `both` combina scans e guards; `combined` aggiunge compact e fused.
- `no_vector` cambia solo le due opzioni di compilazione sopra indicate.

Le varianti scans, phase_scans, guards, both, compact e no_vector producono
risultati finali bit per bit uguali alla baseline nei 12 stati/modelli testati.
Per fused/combined l'errore assoluto massimo rispetto alla baseline è
2,9865e-14; il massimo rispetto alla traiettoria Python/C di riferimento è
3,8914e-14. Sono controlli di traiettoria finale dopo 100 passi, non prove
universali né un confronto di tutte le quantità interne a ogni passo.

## Protocollo e riproducibilità

CPU Ryzen 7 9800X3D, affinità CPU 12; GNAT/GCC 16.1, O3, march=native,
LTO, contrazione FP disabilitata e le stesse opzioni release precedenti.
La baseline congelata coincide con le unità attive della dinamica a HEAD
70800df9; differiscono soltanto un helper compatto non chiamato dalla baseline
e il suo test standalone. Sorgenti, GPR, log, binari e hash sono archiviati.

Due sessioni finali, ciascuna con 20 blocchi per stato, 4 modelli, 3 stati,
10 eseguibili, 4 campioni da 100 passi: **4.800 processi, 1.920.000 passi
cronometrati**. Ogni processo effettua inoltre il warm-up previsto dal runner.
Ordine casuale a rotazioni bilanciate: ogni eseguibile occupa ogni posizione
ugualmente. Il bilanciamento della posizione non garantisce il bilanciamento
di ogni coppia di predecessori. Nessuna compilazione, prova o altro benchmark
è stato lanciato contemporaneamente alle misure.

Preparazione e I/O sono fuori dal tempo riportato dal benchmark. Statistica:
mediana dei quattro campioni per blocco, rapporti appaiati, bootstrap 10.000
ricampionamenti e CI 95% all'interno della sessione. Gli stati coincidono fra
le sessioni: le ripetizioni non sono nuovi scenari indipendenti. È archiviato
anche il pilot a 18 blocchi con nove eseguibili, escluso dalle tabelle finali.

Gli script e le evidenze sono in
`tests/movement_performance/cost_attribution/`. La ricostruzione usa il build
congelato generabile con `compact_mass_retry/build.py --lane verification`;
le istantanee complete consentono anche di controllare l'esatto esperimento.
La libreria C è stata verificata tramite SHA-256 contro il manifest congelato.

La prossima priorità indicata dai dati è chiudere le prove necessarie per
ridurre le tre validazioni interne e poi i controlli numerici più costosi,
conservando le verifiche necessarie agli ingressi. La fusione delle forze viene
dopo: richiede anche una scelta sulla disponibilità delle grandezze separate.
