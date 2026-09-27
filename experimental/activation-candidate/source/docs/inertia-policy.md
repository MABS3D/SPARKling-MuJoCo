# Politica dell'inerzia e costo residuo — 2026-09-24

Il percorso normale del prototipo non calcola più la stima completa del
condizionamento a ogni passo. Usa fattorizzazione inversa `LᵀDL`, reciproci della
diagonale e soglia dei pivot del percorso generale di
[MuJoCo 3.14.0](https://github.com/google-deepmind/mujoco/releases/tag/3.14.0),
ultima versione stabile ricontrollata per questa modifica. Il solver precedente
rimane selezionabile per la diagnostica rigorosa.

## API e comportamento

```ada
Create (M, D, Result);                          -- Compatible: nuovo default
Create (M, D, Result, Solver_Policy => Strict); -- politica precedente
```

`Policy (D)` restituisce la scelta, conservata da Reset e da un Create rifiutato
perché la simulazione è già allocata. Non si cambia politica a metà simulazione.

* **Compatible:** ogni pivot `< Min_Val` viene portato a `1e-15`, compresi zero
  e valori negativi. Si prosegue senza la stima globale del condizionamento.
  `Clamped_Dof (D)` restituisce il primo DOF regolarizzato dopo Create/Reset,
  oppure `-1`. È una segnalazione consultabile, non un errore fatale né una
  stampa; rimane memorizzata anche se un controllo successivo fallisce.
* **Strict:** conserva fattorizzazione forward `LDLᵀ`, controllo relativo dei
  pivot e risoluzioni delle colonne dell'inversa scalata. Mantiene
  `Singular_Inertia` e `Ill_Conditioned_Inertia` nei casi precedentemente rifiutati.
  Non regolarizza e non imposta la segnalazione.

In entrambe le modalità restano i limiti numerici e il fallimento atomico dello
stato fisico del passo. Un pivot regolarizzato può produrre accelerazioni fuori
dominio: in quel caso si ottiene ancora `Numeric_Limit`, con la segnalazione
conservata. Regolarizzare non certifica accuratezza o buon condizionamento.

## Compatibilità e limiti

Il riferimento è `mj_factorI` / `mj_solveLD` in `engine_core_smooth.c`: visita
inversa delle righe, clamp prima del reciproco, aggiornamento del triangolo e
normalizzazione della riga. Il port mantiene array densi e una riduzione scalare
ordinata; non promette identità bit per bit con tutte le riduzioni SIMD/sparse.
La segnalazione conserva il primo indice fino a Reset; C ha invece propri
contatori e metadati. Restano differenti anche limiti di dominio e autoreset.

Le specializzazioni `dof_simplenum` di C non sono tradotte. Il test iniziale con
slide collineari in un corpo foglia selezionava in C una matrice diagonale
specializzata. I test del solver generale aggiungono un figlio fisso e verificano
`dof_simplenum = 0`. Le fixture degeneri sono compilate con armatura `1e-4`, poi
la stessa armatura di prova viene applicata al modello C e al MJB letto da Ada.
Questo mantiene i pesi inversi di riferimento prodotti dal compilatore nel
dominio del loader; quei pesi non sono usati nel percorso senza vincoli.
XML, modifica, MJB e input sono conservati. Questi non sono confronti con vincoli.

## Verifica

* Entrambe le modalità passano **480 scenari e 78.720 confronti numerici**
  ciascuna contro C, inclusi 24 DOF, ramificazioni, più radici e fallback.
  Strict riproduce esattamente i **79.680 valori/campi** emessi dalla precedente
  suite, inclusi gli esiti: uguaglianza numerica, non dei bit degli zeri con segno.
* **85 casi mirati / 170 scenari** verificano soglie, matrici singolari e
  mal condizionate, carichi nulli/non nulli, smorzamento, reset delle segnalazioni,
  conservazione della modalità e fallimenti atomici ai limiti di stato.
* I quattro kernel scalari sono stati provati prima singolarmente, poi come
  unità completa: **18 obblighi chiusi**, con leggi funzionali e limiti.
  Il solver composto ha ancora **58 obblighi aperti su 118** nella diagnostica
  CVC5/1 secondo per obbligo. Non si dichiara Gold o Silver l'intero solver:
  restano prove di composizione e del modello matriciale da completare.
  Nessuna nuova assunzione o esclusione di codice dalla verifica.

## Movimento completo

Confronto con la versione immediatamente precedente, già dotata di CRB/RNE:
due sessioni, tre stati per modello, 24 blocchi bilanciati, quattro traiettorie
da 100 passi per processo, CPU 12. Build non strumentate con gli stessi flag
del precedente esperimento; riferimento C nativo con SIMD.

| Modello | Prima, µs/passo | Ora, µs/passo | Riduzione appaiata | Ora / C |
|---|---:|---:|---:|---:|
| 1 DOF | 0,707–0,710 | 0,673–0,676 | 4,6–5,3% | 1,55–1,58× |
| 5 DOF | 2,812–2,815 | 2,275–2,285 | 18,4–19,5% | 2,29–2,33× |
| 12 DOF | 10,577–10,603 | 7,348–7,390 | 29,9–30,7% | 3,53–3,63× |
| 6 DOF senza smorzamento | 3,372–3,427 | 2,976–3,011 | 10,8–11,8% | 3,15–3,18× |
| 24 DOF | 37,042–37,239 | 20,839–20,927 | 43,3–44,2% | 4,36–4,44× |

Tempi: intervallo delle due mediane di sessione, ciascuna mediana dei tre stati.
Rapporti/riduzioni: intervallo delle sei stime appaiate stato–sessione, non un
intervallo di confidenza. Tutti gli intervalli bootstrap al 95% sono sotto 1
per nuovo/precedente, senza correzione per confronti multipli. 2.160 processi
completati; errore massimo degli stati finali rispetto a C `2,26e-14`.
**C resta più veloce.** Il confronto include nuova politica e fattorizzazione:
non attribuisce tutto il recupero al solo condizionamento.

## Profilo della nuova versione

Build strumentata separata, otto ripetizioni per stato: 120 esecuzioni, con
output identici alla build normale. Quote con costo degli orologi e perturbazioni
del codice inclusi, non previsioni del recupero eliminando una fase.
Le misure annidate non vanno sommate alle fasi che le contengono.

| Voce | 5 DOF | 12 DOF | 24 DOF |
|---|---:|---:|---:|
| Sette scansioni di validità | 43,5% | 50,4% | 52,9% |
| Costruzione Jacobiani, dentro cinematica | 3,0% | 5,1% | 7,1% |
| CRB, dentro assemblaggio massa | 5,5% | 4,8% | 4,2% |
| Ricorsione forze, dentro fase forze | 4,9% | 4,4% | 3,2% |
| Copia/preparazione matrice e fattorizzazioni | 4,2% | 6,6% | 12,1% |
| Risoluzioni fisiche, inclusa copia RHS | 3,3% | 3,4% | 3,8% |

Conteggi: **zero chiamate al condizionamento**, due risoluzioni fisiche per passo
nei modelli smorzati e una senza smorzamento. Nessun fallback denso nei casi
multi-DOF misurati; a 1 DOF resta il percorso denso previsto. Le copie complessive
e gli azzeramenti non sono tutti isolati individualmente.

Priorità successiva: dimostrare la conservazione degli invarianti per ridurre
le scansioni ripetute. I Jacobiani rimangono un costo sulla catena lunga, come
la fattorizzazione densa a 24 DOF. Nessuna scansione viene rimossa qui.

[Comandi ed evidenza](../tests/movement_performance/inertia_policy/README.md).

Follow-up: [validated entry reuse and deferred Jacobians](readiness-performance.md)
records the next implementation, proof scope and whole-step measurements.
