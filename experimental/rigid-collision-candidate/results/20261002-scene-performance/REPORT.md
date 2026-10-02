# Prestazioni della ricerca condivisa — 2 ottobre 2026

Il percorso unificato riduce sensibilmente il tempo nei casi misti con GJK:
−25,2% (32 geometrie), −15,5% (128), −14,4% (512) rispetto alla ricostruzione
del percorso a due passaggi. Il risultato non è uniforme: nella scena sparsa
con 32 sfere aumenta del 27,3%, pari a circa 0,14 µs/frame. Il costo nei casi
densi di sole sfere cambia poco; i piccoli scarti non vanno interpretati come
un vantaggio generale. Con 128 primitive sul piano il risparmio è del 6,3%.

La misura comprende selezione, filtri, materiali, geometria, finalizzazione e
scrittura dei contatti completi. Le 16 pose sono precalcolate fuori dal timer;
non sono inclusi cinematica, vincoli, dinamica o integrazione. La baseline
Ada è una **ricostruzione diagnostica**: stessa traversal con `Test` booleano
prima degli stessi generatori completi. Non esisteva prima un driver completo
di scena. Questa baseline è definita soltanto per le primitive.

Sono eseguite 31 serie appaiate, con ordine dei tre metodi alternato sulle
sei permutazioni e CPU 15, AMD Ryzen 7 9800X3D in WSL2. Ogni campione mira a
40 ms (minimo due cicli), preceduto da quattro cicli di riscaldamento. I/O,
allocazioni, compilazione di grafi/incidenze, cinematica e checksum sono fuori
dal timer. Una chiamata opaca comune rende osservabile il buffer completo per
impedire a LTO di eliminare le scritture; il costo di tale chiamata è incluso.
C usa la libreria ufficiale MuJoCo 3.14.0 senza modificare `mj_collision`.

I tempi sotto sono mediane per frame. Le variazioni sono mediane dei rapporti
appaiati: possono differire dal rapporto tra le due mediane dei tempi. Gli
IC95% sono bootstrap delle mediane dei rapporti e descrivono la dispersione di
questo esperimento; non coprono tutti gli effetti sistematici di compilazione,
scheduler, hardware o altri modelli. Il primo controllo a 15 serie è conservato
separatamente e rende visibile la variabilità tra esecuzioni. Non si usa una
media non pesata delle percentuali per dichiarare parità globale.

| Scenario | Geometrie | Contatti/frame | Unificato (µs) | Δ vs due passaggi [IC95%] | C (µs) | Δ vs C [IC95%] |
|---|---:|---:|---:|---|---:|---|
| sparse-32 | 32 | 0–0 | 0.660 | +27.33% [+23.89%, +27.92%] | 0.954 | -31.55% [-32.73%, -30.93%] |
| dense-32 | 32 | 52–52 | 4.422 | +1.69% [+0.34%, +3.10%] | 5.718 | -23.13% [-24.38%, -21.60%] |
| mixed-32 | 32 | 83–94 | 119.425 | -25.17% [-26.25%, -24.02%] | 104.213 | +14.69% [+13.35%, +16.54%] |
| sparse-128 | 128 | 0–0 | 4.377 | +3.44% [+2.18%, +6.01%] | 4.104 | +4.62% [+3.28%, +10.62%] |
| dense-128 | 128 | 288–288 | 37.322 | +0.05% [-4.11%, +4.26%] | 57.673 | -36.13% [-37.34%, -34.76%] |
| mixed-128 | 128 | 838–858 | 1386.324 | -15.46% [-16.90%, -14.80%] | 1234.565 | non comparabile: normali differenti |
| sparse-512 | 512 | 0–0 | 24.058 | -4.11% [-7.33%, -0.67%] | 77.117 | -68.50% [-69.26%, -67.80%] |
| dense-512 | 512 | 1344–1344 | 291.853 | -0.49% [-2.10%, -0.23%] | 551.422 | -47.06% [-48.15%, -46.03%] |
| mixed-512 | 512 | 4833–4895 | 8351.681 | -14.42% [-14.81%, -13.97%] | 7558.722 | non comparabile: normali differenti |
| floor-mixed-32 | 33 | 62–62 | 3.329 | -1.58% [-4.91%, +0.51%] | 3.902 | -14.40% [-17.23%, -11.59%] |
| floor-mixed-128 | 129 | 253–253 | 13.819 | -6.33% [-7.65%, -4.79%] | 15.674 | -12.61% [-14.05%, -11.17%] |
| hull-sphere-16 | 32 | 16–16 | 6.262 | — | 9.164 | -30.79% [-32.87%, -30.24%] |
| hull-sphere-64 | 128 | 64–64 | 26.293 | — | 42.604 | -38.68% [-39.32%, -37.68%] |
| terrain-sphere-16 | 17 | 27–32 | 18.244 | — | 15.409 | +18.43% [+16.86%, +19.34%] |
| terrain-sphere-64 | 65 | 154–164 | 82.089 | — | 68.707 | +20.71% [+18.41%, +21.74%] |

Il guadagno vs C nelle scene di sfere o mesh non si estende ai terreni: con
64 sfere sul heightfield il candidato richiede circa 82,1 µs contro 68,7 µs,
+20,7% [18,4%, 21,7%]. Il misto a 32 geometrie richiede ancora circa il 14,7%
in più di C, pur migliorando sensibilmente rispetto ai due passaggi.

Prima dei tempi sono confrontati tutti i 16 frame: conteggi, ID canonici,
distanze, posizioni, normali, dimensione, attrito, include margin ed esclusione;
i frame devono essere finiti e ortogonali. Il confronto Ada prima/dopo passa
anche nei misti grandi. In quei due modelli alcune normali del driver C sono
opposte: per ogni differenza si verifica che distanza, posizione e normale
Ada coincidano con il CCD C grezzo, entro 1e-9. È il comportamento `polygonClip`
vuoto già documentato in CONTACTS.md. Le differenze precise sono registrate nel
JSON e i log/input sono conservati in diagnostics. I tempi C di questi modelli
sono diagnostici; **il rapporto Ada/C è omesso**, perché le normali differenti
non dimostrano equivalenza della risposta fisica. Non si conclude la parità
prestazionale di una simulazione completa.

Gli algoritmi di produzione e i loro contratti non sono modificati per questa
misura. Le differenze della baseline esistono soltanto nello snapshot esterno;
esso non è una nuova variante di produzione Gold. I manifest registrano hash
di sorgenti, eseguibili, librerie e comandi; il JSON registra versioni di
compilatori, hardware, misure singole e intervalli.

Riproduzione dalla directory del candidato:

```sh
/var/tmp/sparkling-movement-env/bin/python tests/benchmark_scene.py --out /var/tmp/scene-perf --rounds 31 --target-ms 40
```
