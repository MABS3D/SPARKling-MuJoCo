# Correzione CSR — confronto con C e versione precedente

**Esito della fase: 17/17 carichi più veloci di C nella sessione misurata.** Il candidato conserva i risultati numerici. La condizione per integrare nel motore resta aperta: questa prova misura la fase di attuazione su stati preparati, non l’intera simulazione. Le prove formali complete sono riportate separatamente nel resoconto corrente.

## Cambiamento

`Result` è ora un record limited con workspace CSR dimensionato dal chiamante. Le trasmissioni sono procedure che scrivono nel buffer esistente. Le righe condividono colonne e valori contigui, con conteggi e indirizzi. `Reset` modifica soltanto metadati e lunghezze; il payload non viene cancellato. Anche `Row` ha dimensione scelta dal chiamante e semantica limited, per impedire copie implicite. Le routine di velocità e proiezione lavorano su slice attive con offset arbitrario.

Le formule muscolari, PID, DC, SO3 e geometriche sono rimaste invariate. La compressione seleziona i nonzeri prima dello scaling, mantiene l’ordine delle colonne e conserva la coda non scritta. Le colonne nulle strutturali dei tendini sono conservate. Nel benchmark il workspace è allocato una sola volta fuori dal ciclo, con capacità massima di 3×NV; ogni attuatore scrive solo il proprio prefisso attivo.

## Risultati in microsecondi per batch

| Caso | Precedente | Corretta | C | Corretta/C | IC95 del rapporto | Accelerazione sulla precedente |
|---|---:|---:|---:|---:|---|---:|
| hinge_motor | 3.274 | 0.013 | 0.053 | 0.235 | 0.210–0.378 | 259.7× |
| ball_motor | 3.273 | 0.047 | 0.083 | 0.561 | 0.558–0.590 | 69.1× |
| free_parent | 3.322 | 0.045 | 0.076 | 0.591 | 0.563–0.606 | 73.6× |
| muscle | 3.270 | 0.025 | 0.082 | 0.301 | 0.294–0.310 | 131.4× |
| pid_integral | 3.254 | 0.015 | 0.065 | 0.235 | 0.223–0.246 | 215.1× |
| pid_slew | 3.246 | 0.016 | 0.063 | 0.250 | 0.246–0.257 | 206.3× |
| dc_full | 3.264 | 0.073 | 0.127 | 0.581 | 0.392–0.590 | 44.6× |
| so3_quat | 3.363 | 0.117 | 0.139 | 0.844 | 0.821–0.854 | 28.5× |
| so3_expmap | 3.357 | 0.120 | 0.143 | 0.838 | 0.813–0.846 | 27.7× |
| dc_chain_8 | 26.536 | 0.513 | 0.710 | 0.726 | 0.699–0.951 | 50.9× |
| dc_chain_32 | 106.526 | 2.019 | 2.688 | 0.742 | 0.706–0.787 | 52.4× |
| dc_chain_64 | 210.424 | 4.061 | 5.403 | 0.766 | 0.554–0.973 | 51.4× |
| site_ref | 3.630 | 0.099 | 0.187 | 0.557 | 0.465–0.583 | 36.5× |
| so3_site | 4.013 | 0.131 | 0.218 | 0.589 | 0.559–0.607 | 30.8× |
| slidercrank | 3.448 | 0.030 | 0.141 | 0.214 | 0.202–0.230 | 114.7× |
| fixed_tendon | 3.792 | 0.015 | 0.057 | 0.269 | 0.231–0.282 | 245.6× |
| adhesion | 3.561 | 0.024 | 0.113 | 0.208 | 0.104–0.218 | 153.6× |

Rapporti e accelerazioni sono mediane di rapporti appaiati tra blocchi; possono differire dai quozienti delle mediane marginali. IC95 ottenuti tramite 10000 ricampionamenti bootstrap dei nove blocchi. Per esempio, il DC a 64 attuatori ha rapporto mediano 0.766 e IC95 0.554–0.973: il vantaggio centrale è circa 23%, con incertezza ampia. La misura non garantisce lo stesso margine su ogni dispositivo.

## Metodo e limiti

Riferimento MuJoCo 3.14.0, commit 9ecbb9d7b5ee623f54745638d36799ff90e6f7cd. GCC/GNAT 16.1.0, ottimizzazione -O3, ISA nativa, LTO, contrazione FP disabilitata. C usa la build nativa con SIMD/AVX normali. AMD Ryzen 7 9800X3D, WSL, CPU 15. Nove blocchi, tre campioni per eseguibile e blocco, otto snapshot per modello. L’ordine Ada/C viene alternato, la baseline occupa ciclicamente tutte e tre le posizioni. La baseline è esattamente il binario del confronto iniziale: hash verificato.

Il tempo comprende trasmissione, velocità, legge di forza/dinamica, avanzamento dell’attivazione e proiezione sparsa. Preparazione e I/O sono esclusi per tutti; barriera di memoria e checksum impediscono l’eliminazione del lavoro. Lunghezze, velocità, forze, act_dot, attivazioni successive, forze generalizzate e schema CSR sono confrontati con il C ufficiale (2e-11 assoluta/relativa; checksum 2e-10). Tutti i 3672 frame archiviati delle tre versioni sono stati verificati nuovamente.

Site/refsite, SO3-site, slider-crank e adesione ricevono Jacobiani/preparazione già disponibili in Ada, mentre C li calcola nella fase. Il confronto in questi casi favorisce Ada: non costituisce prova di parità della preparazione completa o del movimento. I benchmark non coprono tendini con wrapping, callbacks/plugin, integrazione Model/Data/MJCF o tutte le funzioni globali del simulatore.

La prova aggiuntiva del passo completo C del confronto iniziale resta soltanto contesto storico. La catena DC iniziale era instabile nella traiettoria; non è stata riutilizzata come prova aggregata Ada/C e non è stata dichiarata risolta da questa correzione.

## Evidenze

- [Risultati e provenienza](stage-results.json); output originali, input e modelli in `runs/`.
- Sorgenti misurati in `sources/`; i sorgenti della baseline sono nell’archivio [precedente](../20260930/README.md).
- [Assembly della fase](stage-disassembly.txt): zero chiamate a memcpy e nessuna copia da 147512 byte. Restano azzeramenti limitati ai dati effettivamente necessari, come le forze generalizzate.
- [Prove SPARK correnti](../../proofs.md) e test numerici sono distinti dalla misura prestazionale.

Correzione applicata al candidato isolato; nessun commit, push o integrazione nel motore principale.
