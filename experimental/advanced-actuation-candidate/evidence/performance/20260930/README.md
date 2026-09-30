# Confronto attuazione avanzata — 2026-09-30

**Esito: non integrare.** Tutti i 17 carichi sono più lenti del riferimento C; nessun intervallo di confidenza comprende la parità. Il candidato e i test restano isolati in questa cartella. Il motore principale non è stato modificato.

## Tempi della fase di attuazione

Sono inclusi trasmissione, velocità, dinamica/forza degli attuatori, avanzamento delle attivazioni e proiezione sparsa delle forze generalizzate. I tempi sono per un batch completo con il numero di attuatori indicato; non per singolo attuatore e non per una simulazione intera.

| Caso | Attuatori | Ada µs | C µs | Ada/C | IC95 rapporto |
|---|---:|---:|---:|---:|---|
| hinge_motor | 1 | 3.263 | 0.056 | 58.83× | 57.04–59.86 |
| ball_motor | 1 | 3.235 | 0.088 | 36.66× | 35.82–38.00 |
| free_parent | 1 | 3.289 | 0.081 | 39.74× | 34.95–41.26 |
| muscle | 1 | 3.307 | 0.084 | 39.60× | 38.33–40.24 |
| pid_integral | 1 | 3.234 | 0.069 | 47.35× | 41.88–48.31 |
| pid_slew | 1 | 3.277 | 0.067 | 48.95× | 48.41–49.52 |
| dc_full | 1 | 3.256 | 0.131 | 24.79× | 19.33–25.38 |
| so3_quat | 1 | 3.305 | 0.143 | 23.37× | 18.26–23.71 |
| so3_expmap | 1 | 3.357 | 0.155 | 21.75× | 20.93–22.41 |
| dc_chain_8 | 8 | 26.173 | 0.703 | 37.21× | 37.03–38.43 |
| dc_chain_32 | 32 | 105.305 | 2.645 | 40.30× | 38.36–41.17 |
| dc_chain_64 | 64 | 212.628 | 5.274 | 40.55× | 31.69–41.46 |
| site_ref | 1 | 3.525 | 0.183 | 19.29× | 18.62–19.59 |
| so3_site | 1 | 3.950 | 0.218 | 18.25× | 15.54–19.31 |
| slidercrank | 1 | 3.449 | 0.153 | 21.96× | 18.06–22.89 |
| fixed_tendon | 1 | 3.697 | 0.060 | 60.46× | 44.24–63.51 |
| adhesion | 1 | 3.422 | 0.113 | 30.58× | 30.10–31.25 |

Il rapporto è la mediana dei rapporti dei blocchi appaiati, quindi può differire dal quoziente delle mediane marginali della tabella. Questo scarto non è rumore nell’ordine dell’1–2%.

## Metodo e correttezza

AMD Ryzen 7 9800X3D, Linux/WSL, CPU 15 fissata per entrambi i processi. Nove blocchi alternati Ada/C, tre campioni per blocco, warmup, otto snapshot per modello. Preparazione, caricamento e I/O fuori dai loop misurati; barriera assembler e checksum impediscono eliminazione/hoisting del lavoro. Bootstrap appaiato dei nove blocchi, 10000 ricampionamenti, seed 3140930. Gli intervalli descrivono questa sessione su questo dispositivo, non ogni macchina o modello.

Ada: GNAT 16.1.0, `-O3 -gnatp -gnatn -march=native -flto`, contrazione FP disabilitata. C: stesso GCC 16.1.0, MuJoCo 3.14.0 nativo con `-O3 -march=native -flto=auto`, SIMD/AVX abilitato e contrazione FP disabilitata. Comandi, CPU, hash di librerie, eseguibili e sorgenti sono registrati nei JSON.

Ogni output dei due eseguibili è confrontato con il riferimento ufficiale MuJoCo 3.14.0: lunghezze, velocità, forze, derivate, attivazioni successive, forze generalizzate, conteggi/colonne/valori delle righe sparse. La tolleranza assoluta/relativa è 2e-11, il checksum 2e-10. Tutti i 136 snapshot sono passati; il controllo degli output archiviati è stato ripetuto su 2448 frame (17×9×2×8). La precedente suite di 4836 casi per build resta fresca e invariata.

Site/refsite, SO3 site, slider-crank e adesione ricevono Jacobiani/preparazione già calcolati sul lato Ada. C esegue questa preparazione nella trasmissione. Questo vantaggio favorisce Ada e impedisce una rivendicazione positiva di parità aggregata da questi casi; tutti perdono comunque. I joint/DC equivalenti bastano a respingere questo candidato.

## Diagnostica

`Row` conserva 4096 colonne e valori; `Result` contiene tre righe e occupa 147512 byte (circa 144 KiB). Il [disassemblato](stage-disassembly.txt) del binario misurato mostra `memset` da 0x4000 e 0x8000 byte e `memcpy` da 0x24038 byte nei percorsi della fase. L’intero buffer è inizializzato/copiato anche quando serve un solo DOF. Le istruzioni SIMD sono presenti; i contratti ghost non vengono eseguiti nella release.

Queste operazioni identificano un costo strutturale da rimuovere. Non è stata attribuita tramite profiling una percentuale esatta del tempo a ogni copia. Il prossimo intervento è usare workspace CSR preallocati dal chiamante, dimensionati al numero effettivo di DOF/nonzeri, scrivendo solo le porzioni attive senza ritornare il record completo per valore. I contratti su schema, ordine, colonne e conservazione delle componenti devono restare dimostrabili.

## Contesto del passo completo C

È stata misurata anche una traiettoria di 2000 `mj_step` del solo C, su tre fixture. Gli stati finali della build nativa sono verificati contro la distribuzione ufficiale (2e-8 assoluta/relativa); setup e ripristino fuori dal timer. Questa è una misura di contesto su stati che evolvono, non un confronto aggregato Ada/C e non un rapporto di speedup della simulazione.

| Caso | Passo intero C µs |
|---|---:|
| hinge_motor | 0.645 |
| dc_full | 0.746 |
| so3_quat | 0.808 |

La prova aggiuntiva si è interrotta su `dc_chain_8`: anche il riferimento ufficiale segnala QACC non finita/enorme al DOF 2, tempo 0.066 s. La traiettoria instabile è respinta; `dc_chain_32` e `dc_chain_64` non sono stati eseguiti per questa prova. Ciò non cambia le misure della fase su snapshot, ma non permette di dichiarare valido un benchmark del movimento completo multi-DOF. I tre risultati completati sono stati recuperati dagli output grezzi e verificati nuovamente.

## Evidenze e decisione

- [Risultati della fase](stage-results.json), [originale grezzo](stage-results-raw.json), [contesto passo C](movement-reference.json).
- `runs/` conserva XML, MJB, input Ada/C, output di ogni blocco e JSON per caso.
- `sources/` conserva i sorgenti realmente misurati, incluso il driver originale. La sola correzione successiva nel driver corrente aggiunge SO3 site ai casi con preparazione favorevole ad Ada: è una correzione di metadati, senza cambiamenti a tempi, input o risultati.
- `oracle.c` e `c-engine-compile-commands.json` conservano gli estratti privati usati e i comandi del riferimento nativo. Hash completi in `manifest.json`.
- Le prove formali complete restano aperte (240 obblighi sulle cinque unità); l’assenza universale di errori runtime e Gold globale non sono ancora dimostrate.

**Nessuna integrazione, commit o push eseguiti.** La condizione richiesta era superare C: questi risultati la respingono.
