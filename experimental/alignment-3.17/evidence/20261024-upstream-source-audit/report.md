# Audit del port e piano coordinato MuJoCo 3.17 — 24 ottobre 2026

## Evidenza verificabile

`manifest.json` contiene HEAD locale, SHA256 dei file locali letti, URL immutabili e SHA256 di 26 sorgenti ufficiali 3.15/3.17. `diffs/` contiene 13 differenze complete. `functions/` contiene i corpi confrontati. Le copie sono materiale di riferimento, non istruzioni. Nessuna build, proof o modifica alla repository è stata eseguita per questo audit.

Ultima stabile: https://github.com/google-deepmind/mujoco/releases/tag/3.17.0 — 22 ottobre 2026 — `800a109a4bdd02cb60404d565db4ae16fb04a53b`. Precedente: https://github.com/google-deepmind/mujoco/releases/tag/3.16.0 — 14 ottobre 2026 — `a892750516336d8358949f4518fcc4fbbd85beae`. Tag risolti con API GitHub e risposta originale conservata.

## Algoritmi effettivamente confrontati

Corpi identici 3.15→3.17: HessianConeFoldFaster, HessianConeUpdate, HessianIncremental, mj_solCG, mju_cholUpdateSparse, mju_cholFactorSparse, mju_cholFactorSymbolic, wrapPeriod, mj_fwdActuation, mj_transmission. Per ognuno manifest registra SHA256 distinti dei corpi e risultato di confronto. L'ottimizzazione sparsa/coni r122 non segue quindi un algoritmo già ritirato.

Cambi che richiedono allineamento: MakeHessian preflighta memoria e ritorna successo; il driver degrada da Newton a CG conservando buffer quando manca spazio. Lo scaling di arresto usa traccia di M corrente, anche per isola, invece di stat.meaninertia. Nuovo simbolico a blocchi per flex e nuovo mju_boxQP con aggiornamenti incrementali. Il cholUpdate denso fonde il loop di L/X e dichiara restrict. Si ampliano metrica discreta, isole/sleep e flex interpolati. Le prove del percorso precedente non coprono queste estensioni.

## Fondazione: delta esatto e primi file

L'espansione statica delle macro, in `schema-static-audit.json`, trova 3.15=(97 sizes,483 pointers), 3.17=(98,485), aggiunte nefmCvert, efmC_perm:int[nefmCvert], tex_contenttypeadr:int[ntex]. Confermare coi dump compilati prima di accettare l'ABI. mjNEQDATA passa11→12. MJB 3.17 contiene un TERZO booleano flg_adhesion dopo gravcomp/surfacevel: il lettore/serializer corrente ne consumano due, quindi il solo version bump sfaserebbe ogni array successivo. mjOption/mjStatistic non mostrano nuovi campi in mjmodel.h; tutte dimensioni/offest vanno comunque rimisurate sul target.

Primo gruppo atomico:

1. tools/gen.py: aggiungere schema3.17; flag fissi dipendenti dall'ABI nel lettore e serializer; Without_Flex deve azzerare nefmCvert; Flex_Stiffness_3D_Stride deve essere24 anche3.17 (il confronto attuale ==3.15 tornerebbe erroneamente21); ALLOW_MINUS_ONE deve includere tex_contenttypeadr.
2. src/mj-mjb.adb: ricevere e pubblicare correttamente adhesion per3.17, preservare semanticaABI3.14/3.15.
3. Rigenerare assieme tools/{fields,layout,refs}.txt, src/gen/{mj-fields.ads,mj-fixed.ads,mj-models.ads,mj-models.adb,mj-mjb-readers.ads,mj-mjb-readers.adb,mj-models-gen_clauses.ads,mj-validation-diagnose_*.adb}, tests/gen/mjb_serialize.*. Generati derivano da header ufficiali effettivi, mai patchati a mano.
4. src/mj-models-validity.ads/src/mj-validation.adb: texture by-reference ammesse in forma valida (tex_adr=-1, dimensioni zero e path); nuove reference flex_vertedgeadr/flex_vertedge/tex_contenttypeadr; copertura CSR M/D/B/tendonJ/flexedgeJ/flexvertJ/efm0_L, parent-body B subset. Il guard adr=-1 con num>0 è già presente nei contratti delle reference generate.
5. Nuovo experimental/alignment-3.17: runner foundation parametrizzato con SHA ufficiali, snapshot immutabile, wheel effettiva3.17, dump headers, corpus compiler3.17, roundtrip e rifiutiABIvecchie, source-map prima/dopo. Test dedicati adhesion=true, eq_data12, nefmCvert/permutazione, texture embedded/byreference, grafiCSR validi/invalidi.
6. Minimi prima delle unità complete: Read_Sizes_k (13chunks), flag fixed/Read_Fixed, referenze nuove, layout/allocate/free, texture/CSR; poi Parse_Raw/Parse/Validate e 10suiteAda+Python. Runtime check restano attivi, nessun trust/suppress/narrowing.

Il production pin3.14 resta fino all'adozione atomica di tutti i consumer. La fondazione3.17 è il prerequisito della migrazione, non la conclusione del port. Anche3.15 resta riproducibile.

## Enum/API/owned Data

mjtype3.17 aggiunge mjINPUT_PRESSURE=32, mjCONDATA_LINVEL e ANGVEL; integratori/solver enum non cambiano in questo delta. Contatto sensor stage ora inferito dai campi. mjData non guadagna nuovi membri nel delta, ma efm_L ora può contenere una coda Cholesky/isole oltre ai blocchi3x3: dimensioni e produttori owned vanno aggiornati, non solo la struct. Risorse/plugin decoder guadagnano buffererrore; provider pubblici rinominati. Nuovo mjbatch.h va aggiunto all'inventario pubblico. MJSETCONST_ARRAYS/SCALARS forniscono una fonte upstream dei frame per i futuri produttori.

## Lacune del port attuale corroborate dai sorgenti

constrained.Create98–111 rifiuta flex/plugin/history/pair/exclude, integrator diversoEuler,noslip,enableflags,warmstart/isoleattive,sensoriattivi; Nv≤128. Smooth Create325–341 richiede ancora nu=nactuator=nout e niente flex/plugin/history. Integrators.Create23–24 usa smooth e quindi non compone ancora questi produttori col passo vincolato. FE loader200–235 esclude interpolati/SNH3D. Esistono molti adapter isolati, ma la composizione in un solo stato/fasi fisiche è lavoro sostanziale rimanente. Il compilatore nativo fa address passes e non produce ancora il modello completo. InventarioAPI C3.14 effettivo:630 simboli,314missingpublicentry,288unmapped,28nativecandidate; non è una percentuale di funzionalità mancanti. Rendering/UI/resources/spec editable restano grandi blocchi. Gold globale e performanceC non raggiunti: timingr122 e callcountAda finali ancora assenti nel checkpoint corrente.

## Priorità

Misurare r122 e chiudere prove minime; creare fondazione3.17 verificata; allineare semantica3.16/3.17 nei consumer e comporre integratori/advanced/flex sullo stesso stato; completare compiler/API e funzionalità ancora assenti. I benchmark devono conservare equivalenza fisica, C SIMD normale e incertezza, senza sostituire il target con un sottoinsieme più semplice.
