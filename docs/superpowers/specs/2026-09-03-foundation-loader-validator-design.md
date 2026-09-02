# Sparkling MuJoCo: Foundation, `.mjb` Loader, and Proven Model Validator

Date: 2026-09-03
Status: approved design, awaiting implementation plan
Scope: sub-projects 1 and 2 of the nine-part program described in Section 0

## 0. Program context

The program is a complete port of the MuJoCo 3.12.0 physics engine (`src/engine`, 54k lines of C)
plus the `engine_vis_*` visualization geometry to Ada 2022 in the SPARK subset, with proofs.
The charter is `bible.md` at the repository root. Reference source is the git submodule `mujoco/`
pinned to tag `3.12.0`.

The program is split into nine sub-projects, built in this order. Each gets its own spec and plan.
Every later spec inherits the binding decisions in Section 2 of this document.

| # | Sub-project | Scope |
|---|---|---|
| 1 | Foundation | Alire crate, toolchain, profiles, core types, generated `Model` record, tools |
| 2 | Loader and validator | `.mjb` parser, `Valid_Model` predicate family, proven checker, capacities |
| 3 | Numeric kernels | `engine_util_blas`, `_spatial`, `_sparse`, `_solve`, `_misc` numerics |
| 4 | Smooth dynamics and `Data` | `Data` record, `core_smooth`, `passive`, `setconst`, actuation, guards, Euler and RK4, `mj_forward` without constraints |
| 5 | Collision | `collision_driver`, `_primitive`, `_box`, `_gjk`, `_convex` native path, `_continuous`, heightfield, mesh BVH |
| 6 | Constraints and solvers | `core_constraint`, `solver` (PGS, CG, Newton, noslip), `island` |
| 7 | Sensors, inverse, support, ray, names | `sensor`, `inverse`, `support`, `ray`, `name`, `core_util` |
| 8 | Derivatives, implicit, sleep, flex, SDF | `derivative`, `derivative_fd`, implicit integrators, `sleep`, flex passive and collision, built-in SDF |
| 9 | Harness, optimization pass, `MJ.Vis` | differential tests vs reference, benchmark vs native C, profile-guided optimization, `engine_vis_*` port |

This document covers 1 and 2 together because the validator's needs drive the type design.

## 1. Goals and success criteria for this spec

1. `alr build` succeeds in the `release`, `validation` (checks on), and `development` profiles.
2. The prove script reports zero unproved checks at gnatprove level 2 for every SPARK unit
   delivered here. Flow analysis reports no uninitialized reads and no aliasing.
3. The validator carries and proves the postcondition: a result of `OK` implies `Is_Valid`.
4. Every `.mjb` produced from the corpus loads and validates. Corpus: every XML under `mujoco/model/`
   and `mujoco/test/testdata/`. Models with plugins report `Unsupported_Plugins`; models with flex
   report `Unsupported_Flex` until sub-project 8 lifts that restriction.
5. Mutation tests: for every reference clause in Section 5, a deliberately corrupted model is
   rejected with the matching status and field.
6. A command line tool `mjinfo` prints the sizes, capacities, and validation result of a `.mjb`,
   exiting non-zero on rejection.
7. The generator round-trips: regenerating from the submodule headers produces no diff.

## 2. Program-wide decisions (binding for all sub-projects)

### 2.1 Language and tooling

- Ada 2022, `SPARK_Mode => On` on every engine unit, spec and body. Non-SPARK code is confined to
  file input, the command line tools, and test drivers, each marked `SPARK_Mode => Off`.
- Toolchain via Alire 2.1.1: crates `gnat_native ^16` and `gnatprove ^16`.
- Crate name `sparkling_mujoco`. Library project `sparkling_mujoco.gpr`. Tools and tests are
  separate projects that depend on it.
- Build profiles:
  - `release`: `-O3 -march=native -flto -gnatn -gnatp -ffinite-math-only -fno-trapping-math -fno-math-errno`.
    Checks are suppressed because they are proven. Finite-math is licensed by the proof that no
    operation produces infinity or NaN. `-fassociative-math` is off by default and may be enabled
    per unit in sub-project 9 when the differential tests permit.
  - `validation`: `-O2 -gnata -gnato -gnatVa` with all checks on. Used for tests and the corpus run.
  - `development`: `-O0 -g -gnata -gnatwa -gnatyg`.

### 2.2 Proof levels

| Level | Where | Meaning |
|---|---|---|
| Stone | everything in SPARK_Mode | valid SPARK subset |
| Bronze | everything in SPARK_Mode, including `MJ.Vis` | flow analysis: no uninitialized reads, no aliasing, explicit `Global` and `Depends` on every subprogram |
| Silver | all physics units | absence of runtime errors: index, range, overflow (integer and float), division by zero, elementary function domains, discriminant and null checks |
| Gold | listed clauses | validator soundness; CSR well-formedness preserved by every sparse kernel; `ncon <= Contact_Cap`; `nefc <= Efc_Cap`; `nJ <= NJ_Cap`; every solver and line-search loop has a `Loop_Variant`; island partition well-formed |

`pragma Annotate (GNATprove, ...)` justifications are forbidden except for documented tool
limitations. Each one needs a written rationale in `docs/proof-justifications.md`, which starts
empty. The prove script fails if a justification appears without an entry there.

### 2.3 Numeric model

- `Real` is `Long_Float`, IEEE binary64, the same as `mjtNum` in the default double build.
  Single precision is out of scope.
- SPARK models floats as finite values, so every operation must be proven not to overflow. The
  mechanism is a ladder of bounded subtypes:

  | Name | Bound | Typical contents |
  |---|---|---|
  | `Tier0_Real` | 1e10 | state, controls, applied forces, model parameters (this is `mjMAXVAL`) |
  | `Tier1_Real` | 1e30 | products of two Tier0 values, sums over any array of Tier0 values |
  | `Tier2_Real` | 1e60 | products of Tier1 values |
  | `Tier3_Real` | 1e120 | products of Tier2 values |
  | `Tier4_Real` | 1e240 | products of Tier3 values; nothing may multiply two Tier4 values |

  Rules: a product of two values in tier k is in tier k+1. A division whose denominator is at
  least `Min_Val = 1e-15` (`mjMINVAL`) takes tier k to tier k+1. A sum of at most 2^31 values in
  tier k is in tier k+1. Each kernel's contract names its input and output tiers. Where a kernel
  needs a tighter bound than the ladder gives, it states it explicitly.
- Every denominator is either proven at least `Min_Val` or explicitly guarded, matching the C
  code's `mjMINVAL` guards.
- Elementary functions come from `Ada.Numerics.Long_Elementary_Functions`, whose SPARK contracts
  enforce domains (`Sqrt` needs a non-negative argument, and so on).
- Non-finite values cannot arise inside the engine. They are rejected at the two boundaries:
  the loader validates every double read from a file, and every setter of user-writable state
  (`qpos`, `qvel`, `act`, `ctrl`, `qfrc_applied`, `xfrc_applied`, mocap, `userdata`) takes
  `Tier0_Real` and returns a status instead of accepting an out-of-range value. The step-time
  guards that mirror `mj_checkPos`, `mj_checkVel`, and `mj_checkAcc` still exist, because
  integration can grow values past 1e10; they reset and count a warning exactly as C does.
- Integer arithmetic uses 32-bit `Integer`. Sizes are capped at `Max_Size = 2**27 - 1` so that
  small constant multiples (up to 11, the largest fixed column count in `mjModel`) fit in
  `Integer`. Products of two sizes are computed in `Long_Integer` and checked against `Max_Size`.
  C's own limit is `INT_MAX`; ours is stricter and is documented as a version-one limitation.
  Runtime capacities (contacts, constraint rows) are capped at `Max_Cap = 2**24 - 1` so that
  36 times a capacity fits in `Integer`.

### 2.4 Memory layout

- Every array in `Model` and `Data` is a separately allocated object referenced by an owned
  access value. Records are therefore fixed-size, component access compiles to base plus index
  like C, and SPARK ownership proves there is no aliasing between arrays.
- Two-dimensional C arrays (`nr x nc`) stay flat, indexed `I * nc + K`, matching C.
- Sizes and capacities are plain `Integer` fields, not discriminants. Predicates tie array
  lengths to them (`Valid_Layout`) and array contents to each other (`Is_Valid`).
- `Model` is immutable after load. The only later mutators are the `mj_setConst` family in
  sub-project 7, which take `in out Model` and re-establish the predicate.
- `Data` (sub-project 4) uses the same shape. The C arena arrays become capacity arrays sized from
  the capacities computed by the validator; live counts sit beside them and the type predicate
  ties each count to its capacity. The 353 `mjSTACKALLOC` temporaries become local arrays sized
  by the sizes in scope. The main task needs a large stack; the size is configured in the gpr
  and measured in sub-project 4.
- Allocation failure (`Storage_Error`) is outside SPARK's model and terminates the program, as
  C's `mju_error` does on malloc failure.

### 2.5 Fidelity

Results must match the reference implementation within tolerances set per test in sub-project 9.
Operation order is not preserved when a faster formulation exists. Algorithmic changes are allowed
only when the differential harness stays within tolerance.

### 2.6 Performance

Single-thread `mj_step` throughput is a success criterion for the program. It is measured against
a native build of upstream's `sample/testspeed.cc` with MSYS2 gcc in two configurations: upstream
default flags, and `-O3 -march=native` for a like-for-like comparison. The program goal is at
least parity with the second configuration, with 1.5x as the stretch target. Sub-project 9 owns
the benchmark and the optimization pass.

### 2.7 Callbacks, plugins, threads, errors

- The eight `mjcb_*` callbacks (`passive`, `control`, `contactfilter`, `sensor`, `time`,
  `act_dyn`, `act_gain`, `act_bias`) become generic formal subprograms of the stepping package,
  with no-op defaults.
- Plugins are rejected at validation (`nplugin` must be 0). This is permanent for version one.
- Threading is out of scope; the engine is single-threaded.
- No exceptions in SPARK code. Fallible operations return a status. Warnings increment the same
  per-kind counters C keeps in `mjData.warning`. C's fatal `mju_error` sites become either
  provably unreachable (the validator excludes the condition) or a returned status.

### 2.8 Generated code

The 486 pointer arrays of `mjModel`, the 98 sizes, and the byte layouts of `mjOption`,
`mjVisual`, `mjStatistic`, `mjContact`, and the statistics structs are generated, not typed:

1. `tools/xmacro_dump.c` includes `mujoco/include/mujoco/mjxmacro.h` and defines `X` to print
   one line per field: group, C type, name, row-size expression, column-size expression. The C
   preprocessor does the expansion, so the table is exactly what upstream compiles.
2. `tools/layout_dump.c` prints `sizeof` and `offsetof` for every scalar and array member of the
   fixed structs.
3. `tools/gen.py` reads both outputs and emits the Ada units under `src/gen/`.
4. Generated units are checked in so the build does not need the tools. `tools/check-gen.ps1`
   rebuilds the tools with MSYS2 gcc, regenerates, and fails on any diff.

### 2.9 Naming

Root package `MJ`. One child per C file family (Section 0 table). C identifiers map mechanically:
each underscore-separated segment is capitalized (`body_parentid` becomes `Body_Parentid`,
`M_rownnz` becomes `M_Rownnz`). Header constants become named numbers in `MJ.Types`:
`mjMAXVAL` becomes `Max_Val`, `mjMINVAL` becomes `Min_Val`, `mjNREF` becomes `N_Ref`, and so on.

### 2.10 Repository layout

```
Sparkling Mujoco/
  bible.md                      project charter
  alire.toml                    crate manifest
  sparkling_mujoco.gpr          library project
  src/                          hand-written SPARK units (mj-*.ads, mj-*.adb)
  src/gen/                      generated SPARK units
  tools/                        xmacro_dump.c, layout_dump.c, gen.py, check-gen.ps1, oracle.py
  tools/tools.gpr               mjinfo and later command line tools
  tests/                        unit tests, mutation tests, corpus runner, tests.gpr, run.ps1
  bench/                        benchmark harness (sub-project 9)
  docs/superpowers/specs/       design documents
  docs/superpowers/plans/       implementation plans
  docs/proof-justifications.md  rationale for every Annotate pragma (starts empty)
  prove.ps1                     runs gnatprove and enforces zero unproved checks
  mujoco/                       submodule, tag 3.12.0
```

### 2.11 Testing conventions

Tests are plain Ada programs with a small assertion helper, no external test framework. Each test
program exits non-zero on failure. `tests/run.ps1` builds the `validation` profile and runs every
test program. Python is used only in `tools/oracle.py`, which drives the official `mujoco`
3.12.0 wheel to compile XML to `.mjb` and, from sub-project 9, to produce reference trajectories.

## 3. `MJ.Types`

### 3.1 Scalars

```ada
type Real is new Long_Float;           -- IEEE binary64
Max_Val : constant := 1.0e10;          -- mjMAXVAL
Min_Val : constant := 1.0e-15;         -- mjMINVAL
subtype Tier0_Real is Real range -1.0e10  .. 1.0e10;
subtype Tier1_Real is Real range -1.0e30  .. 1.0e30;
subtype Tier2_Real is Real range -1.0e60  .. 1.0e60;
subtype Tier3_Real is Real range -1.0e120 .. 1.0e120;
subtype Tier4_Real is Real range -1.0e240 .. 1.0e240;
subtype Nonneg_Tier0 is Tier0_Real range 0.0 .. 1.0e10;
Max_Size : constant := 2**27 - 1;
Max_Cap  : constant := 2**24 - 1;
subtype Size_Type  is Integer range 0 .. Max_Size;
subtype Cap_Type   is Integer range 0 .. Max_Cap;
subtype Index_Type is Integer range 0 .. Max_Size - 1;
```

Named numbers for every constant at the top of `mjmodel.h`: `Max_Con_Pair = 50`,
`Max_Tree_Depth = 50`, `Max_Flex_Nodes = 27`, `Min_Awake = 10`, `N_Eq_Data = 11`, `N_Dyn = 10`,
`N_Gain = 10`, `N_Bias = 10`, `N_Fluid = 12`, `N_Ref = 2`, `N_Imp = 5`, `N_Poly = 2`,
`N_Sens = 3`, `N_Solver = 200`, `N_Island = 20`, `Min_Mu = 1.0e-5`, `Min_Imp = 1.0e-4`,
`Max_Imp = 0.9999`.

### 3.2 Arrays and access types

```ada
type Real_Array    is array (Natural range <>) of Real;
type Int_Array     is array (Natural range <>) of Integer;
type Byte_Array    is array (Natural range <>) of Interfaces.Unsigned_8;   -- mjtByte, mjtBool
type Float32_Array is array (Natural range <>) of Float;                   -- visual data
type Real_Array_Access    is access Real_Array;
type Int_Array_Access     is access Int_Array;
type Byte_Array_Access    is access Byte_Array;
type Float32_Array_Access is access Float32_Array;
```

Every array in the engine has `'First = 0`. `Valid_Layout` states this together with the length.
`mjtBool` is one byte in C, so boolean arrays are `Byte_Array` with the invariant that every
element is 0 or 1, stated in `Is_Valid`.

### 3.3 Enumerations

Each C enum that indexes behavior becomes an Ada enumeration with `Convention => C` and explicit
representation values equal to the C values. Values read from a file are decoded as `Integer`
and range-checked by the validator before conversion, so `'Valid` never fails in the engine.

| Ada type | C enum | Values |
|---|---|---|
| `Joint_Kind` | `mjtJoint` | Free, Ball, Slide, Hinge |
| `Geom_Kind` | `mjtGeom` | Plane, Hfield, Sphere, Capsule, Ellipsoid, Cylinder, Box, Mesh, Sdf (0..8); visual-only values 100 and up are kept as a separate `Vis_Geom_Kind` |
| `Trn_Kind` | `mjtTrn` | Joint, Jointinparent, Slidercrank, Tendon, Site, Body, So3, Undefined |
| `Dyn_Kind` | `mjtDyn` | None, Integrator, Filter, Filterexact, Muscle, Dcmotor, Pid, User |
| `Gain_Kind` | `mjtGain` | Fixed, Affine, Muscle, Dcmotor, So3, Pid, User |
| `Bias_Kind` | `mjtBias` | None, Affine, Muscle, Dcmotor, So3, User |
| `Eq_Kind` | `mjtEq` | Connect, Weld, Joint, Tendon, Flex, Flexvert, Flexstrain, Distance |
| `Wrap_Kind` | `mjtWrap` | None, Joint, Pulley, Site, Sphere, Cylinder |
| `Sensor_Kind` | `mjtSensor` | the 49 values of `mjtSensor` |
| `Obj_Kind` | `mjtObj` | the 29 values of `mjtObj` |
| `Constraint_Kind` | `mjtConstraint` | Equality, Friction_Dof, Friction_Tendon, Limit_Joint, Limit_Tendon, Contact_Frictionless, Contact_Pyramidal, Contact_Elliptic |
| `Solver_Kind` | `mjtSolver` | Pgs, Cg, Newton |
| `Integrator_Kind` | `mjtIntegrator` | Euler, Rk4, Implicit, Implicitfast |
| `Cone_Kind` | `mjtCone` | Pyramidal, Elliptic |
| `Jacobian_Kind` | `mjtJacobian` | Dense, Sparse, Auto |
| `Sdf_Kind`, `Flex_Self_Kind`, `Same_Frame_Kind`, `Sleep_Policy_Kind`, `Stage_Kind`, `Data_Kind` | the matching `mjt*` | as in `mjtype.h` |

Bit sets (`mjtDisableBit`, `mjtEnableBit`) stay `Integer` masks with named constants and
`Disabled (Opt, Bit)` / `Enabled (Opt, Bit)` helpers.

### 3.4 Status

```ada
type Load_Status is
  (OK,
   File_Error, Bad_Header_ID, Bad_Precision, Bad_Size_Count, Bad_Version, Bad_Pointer_Count,
   Truncated, Trailing_Bytes, Size_Out_Of_Range, Non_Finite_Value,
   Invalid_Reference, Invalid_Tree, Invalid_Joint_Layout, Invalid_Dof_Chain, Invalid_CSR,
   Invalid_BVH, Invalid_Enum, Invalid_Parameter, Invalid_Signature,
   Unsupported_Plugins, Unsupported_Flex, Capacity_Overflow);

type Field_Id is (None, <one literal per generated field>);   -- generated

type Load_Result is record
   Status : Load_Status;
   Field  : Field_Id;     -- the field that failed, or None
   Index  : Integer;      -- the element index that failed, or -1
end record;
```

## 4. `MJ.Model`

### 4.1 Sizes

`Sizes` is a record with the 98 `mjtSize` fields of `mjModel`, in header order. All are
`Size_Type` except: `Narena` and `Nbuffer`, which are informational and kept as `Long_Integer`;
and the legacy fields `Nemax`, `Njmax`, `Nconmax`, which may be `-1` (meaning automatic) and are
typed `Integer range -1 .. Max_Size`. `Nconmax` is used as a capacity hint.

### 4.2 Group records

Each group is a record of access values, one per array, generated from the X-macro groups.
Groups and their array counts:

| Group | Arrays | Group | Arrays |
|---|---|---|---|
| Body | 29 | Pair | 11 |
| Joint | 19 | Exclude | 1 |
| Dof | 15 | Equality | 8 |
| Tree | 5 | Tendon | 31 |
| Geom | 27 | Actuator | 36 |
| Site | 10 | Sensor | 18 |
| Camera | 16 | Qpos (`qpos0`, `qpos_spring`) | 2 |
| Light | 22 | Bvh (`bvh_*`, `oct_*`) | 8 |
| Flex | 83 | Wrap | 3 |
| Mesh | 34 | Plugin | 5 |
| Skin | 22 | Numeric, Text | 3 + 3 |
| Hfield | 6 | Tuple | 5 |
| Texture | 8 | Key | 7 |
| Material | 10 | Name (`name_*adr`, `names`, `names_map`, `paths`) | 23 |
| | | Sparse (`B_*`, `M_*`, `mapM2M`, `D_*`, `mapM2D`, `mapD2M`) | 14 |

Total 486, matching `getnptr()` in `engine_io.c`.

### 4.3 Fixed records

`Option`, `Visual`, and `Statistic` are records with the same members as `mjOption`, `mjVisual`
(nested `Global`, `Quality`, `Headlight`, `Map`, `Scale`, `Rgba`), and `mjStatistic`. Their
member offsets and total sizes are generated constants used by the loader; the byte size of each
is asserted at elaboration against the generated value.

### 4.4 The `Model` record

```ada
type Model is record
   S               : Sizes;
   Opt             : Option;
   Vis             : Visual;
   Stat            : Statistic;
   Flg_Gravcomp    : Boolean;
   Flg_Surfacevel  : Boolean;
   Flg_Adhesion    : Boolean;    -- not stored in .mjb; recomputed at load (Section 5.12)
   Caps            : Capacities; -- computed by the validator (Section 5.11)
   Bodies          : Body_Group;
   ...                           -- one component per group in 4.2
end record;
```

`function Valid_Layout (M : Model) return Boolean` is generated: every access value is non-null,
`'First = 0`, and `'Length` equals the product of its row and column size expressions.

`procedure Allocate (S : Sizes; M : out Model)` allocates every array zero-filled, with
`Pre => Sizes_In_Range (S)` and `Post => Valid_Layout (M)`. `procedure Free (M : in out Model)`
deallocates everything and nulls the access values.

### 4.5 `MJ.Model.Validity`

Declares one expression function per clause family of Section 5, `Is_Valid` as their conjunction
(evaluated after `Valid_Layout` with `and then`), and

```ada
subtype Valid_Model is Model
  with Dynamic_Predicate => Valid_Layout (Valid_Model) and then Is_Valid (Valid_Model);
```

Every engine entry point in later sub-projects takes `Valid_Model`. The clause functions are
also what later proofs cite in loop invariants and lemmas.

## 5. Validator: `MJ.Validate`

```ada
procedure Validate (M : in out Model; Options : Validate_Options; Result : out Load_Result)
  with Pre  => Valid_Layout (M),
       Post => Valid_Layout (M) and then
               (if Result.Status = OK then Is_Valid (M));
```

`M` is `in out` only because validation fills `M.Caps` and `M.Flg_Adhesion`; no array is
modified. Soundness (a true result implies `Is_Valid`) is proven. Completeness (every model
`Is_Valid` accepts is also accepted) is tested through the corpus, not proven.

```ada
type Validate_Options is record
   Contact_Cap : Cap_Type := 0;   -- 0 selects the automatic rule of Section 5.11
end record;

type Capacities is record
   Contact_Cap, Ne_Max, Nf_Max, Nl_Max, Efc_Cap : Cap_Type;
   NJ_Cap                                       : Size_Type;
   NIsland_Cap, NIdof_Cap                       : Size_Type;
end record;
```

Clauses are checked in the order below; the first failure is reported with field and index.

### 5.1 Sizes and structure

- Every size is in `0 .. Max_Size` (the loader already guarantees this; restated for the predicate).
- `Nbody >= 1`; `Nplugin = 0` (else `Unsupported_Plugins`); `Nflex = 0` (else `Unsupported_Flex`,
  lifted in sub-project 8).
- `Nq = sum over joints of Qpos_Width (jnt_type)` with widths 7, 4, 1, 1 for Free, Ball, Slide,
  Hinge; `Nv = sum of Dof_Width` with widths 6, 3, 1, 1.

### 5.2 Reference arrays

Every `(adr, num, target)` triple from the C `MJMODEL_REFERENCES` table, plus every plain id
array, satisfies: `num >= 0`, `adr >= -1`, and `adr + num <= target size`. An `adr` of `-1` is
permitted only where C permits it (optional references: `body_mocapid`, `geom_matid`,
`site_matid`, `skin_matid`, `tendon_matid`, `cam_targetbodyid`, `light_targetbodyid`,
`geom_dataid`, `jnt_actuatorid`, `eq_obj2id` for joint and tendon equalities,
`sensor_refid`, `mesh_graphadr`, `mesh_texcoordadr`, `flex_texcoordadr`, `skin_texcoordadr`,
`actuator_actadr`, `*_pathadr`). Everywhere else `adr >= 0`; in particular every `name_*adr`
is non-negative because unnamed objects own an empty string in `names` (Section 5.9).
The full per-field table is generated from the C reference macro and reviewed by hand once.

### 5.3 Body tree

- `Body_Parentid (0) = 0`; for `I >= 1`, `Body_Parentid (I) in 0 .. I - 1`.
- `Body_Rootid (I) <= I` and `Body_Weldid (I) <= I`; `Body_Rootid (0) = 0`; `Body_Weldid (0) = 0`.
- `Body_Rootid (I) = Body_Rootid (Body_Parentid (I))` for `I >= 1` unless the parent is the
  world, in which case `Body_Rootid (I) = I`.
- `Body_Weldid (I) = I` if `Body_Jntnum (I) > 0`, else `Body_Weldid (Body_Parentid (I))`.
- Joints, dofs, and geoms are laid out contiguously by body: `Body_Jntadr (I) = sum of
  Body_Jntnum (0 .. I-1)`, and `Jnt_Bodyid (J) = I` for every joint in the body's range.
  Same for `Body_Dofadr`/`Body_Dofnum`/`Dof_Bodyid` and `Body_Geomadr`/`Body_Geomnum`/`Geom_Bodyid`.
- Trees, exactly as the compiler builds them: `Dof_Treeid (0) = 0` when `Nv > 0`; `Dof_Treeid`
  is non-decreasing and increases by exactly one at each dof with `Dof_Parentid = -1` and nowhere
  else; its last value is `Ntree - 1` (and `Ntree = 0` when `Nv = 0`). `Tree_Dofadr (T)` and
  `Tree_Dofnum (T)` delimit exactly the dofs with `Dof_Treeid = T`.
- `Body_Treeid (I) = -1` when `Body_Dofnum (Body_Weldid (I)) = 0` (the world and every body
  welded to it), otherwise `Body_Treeid (I) = Dof_Treeid (Body_Dofadr (Body_Weldid (I)))`.
  The bodies with `Body_Treeid = T` are contiguous, and `Tree_Bodyadr (T)` and
  `Tree_Bodynum (T)` delimit exactly that range. `Tree_Sleep_Policy (T) in 0 .. 3`.
- `Body_Simple`, `Jnt_Limited`, `Jnt_Actfrclimited`, `Jnt_Actgravcomp`, and every other
  `mjtByte`/`mjtBool` flag array holds only 0 or 1; `Body_Sameframe` holds values of
  `mjtSameFrame` (0 .. 4).

### 5.4 Joints and dofs

- `Jnt_Type (J) in 0 .. 3`.
- `Jnt_Qposadr (0) = 0`, `Jnt_Qposadr (J+1) = Jnt_Qposadr (J) + Qpos_Width (Jnt_Type (J))`;
  same for `Jnt_Dofadr` with `Dof_Width`. Together with 5.1 this pins the layout of `qpos` and
  `qvel` exactly as the engine assumes.
- `Dof_Jntid (D)` is the joint whose dof range contains `D`; `Dof_Bodyid (D) = Jnt_Bodyid (Dof_Jntid (D))`.
- `Dof_Parentid (D) in -1 .. D - 1`. Within one joint the dofs chain consecutively: for the
  second and later dofs of a joint, `Dof_Parentid (D) = D - 1`. For the first dof of a joint,
  `Dof_Parentid (D)` is the last dof of the parent body chain, or `-1` if none.
- `Dof_Madr` describes the row layout of the sparse inertia `M`: `Dof_Madr (0) = 0`,
  `Dof_Madr (D+1) = Dof_Madr (D) + Chain_Length (D)` where `Chain_Length (D)` is the number of
  ancestors of `D` including itself along `Dof_Parentid`, and `Dof_Madr (Nv-1) + Chain_Length (Nv-1) = Nm`.
  Chain lengths are bounded by `Nv` and by `Max_Tree_Depth * 6`; the clause computes them once.
- `Dof_Simplenum (D) in 0 .. Nv - D`.

### 5.5 Sparse maps (`M_*`, `B_*`, `D_*`, `mapM2M`, `mapM2D`, `mapD2M`)

A CSR triple `(rownnz, rowadr, colind)` with `n` rows and `nnz` non-zeros is well-formed when:
`rowadr (0) = 0`; `rowadr (i+1) = rowadr (i) + rownnz (i)`; `rowadr (n-1) + rownnz (n-1) = nnz`;
every `colind` in `0 .. ncols - 1`; and `colind` strictly increasing within each row.

- `M_*` is the lower-triangular CSR view of the inertia matrix: `n = Nv`, `nnz = Nm`, columns in
  `0 .. Nv - 1`. Row `i` contains exactly the ancestors of dof `i` and `i` itself, in increasing
  order, so it agrees with `Dof_Madr` and `Dof_Parentid`.
- `B_*`: `n = Nbody`, `nnz = Nb`, columns in `0 .. Nv - 1`.
- `D_*`: `n = Nv`, `nnz = Nd`, columns in `0 .. Nv - 1`; `D_Diag (i)` is the position of
  column `i` within row `i`.
- `mapM2M` has length `Nc` and entries in `0 .. Nm - 1` (reduced entry to legacy `M` index).
  `mapM2D` has length `Nd` and entries in `0 .. Nm - 1` (symmetric `D` entry to the lower
  triangular `M` entry holding its value). `mapD2M` has length `Nm` and entries in `0 .. Nd - 1`
  (lower `M` entry to its position in `D`). These are the maps `mj_makeDofDofMaps` builds.
- The two `D` maps are mutually consistent: `mapM2D (mapD2M (i)) = i` for every `i` in
  `0 .. Nm - 1`. Stated as a clause because the sparse kernels in sub-project 3 rely on it;
  sub-project 3 states any finer structural facts it needs as lemmas over these bounds.

### 5.6 Geoms, meshes, heightfields, textures, BVH

- `Geom_Type (G) in 0 .. 8`; `Geom_Condim (G) in {1, 3, 4, 6}`; `Geom_Priority`, `Geom_Contype`,
  and `Geom_Conaffinity` may be any integer (the last two are bitmasks).
- `Geom_Dataid`: for `Hfield`, `0 .. Nhfield - 1`; for `Mesh`, `0 .. Nmesh - 1`; otherwise `-1`.
  C tolerates `-1` for mesh and heightfield geoms but the engine would dereference it, so we
  require a real reference. `Geom_Type = Sdf` is rejected with `Unsupported_Plugins`, because
  an SDF geom always needs a plugin instance; the octree mesh-SDF path of sub-project 8 uses
  `Mesh` geoms with `oct_*` data and is unaffected.
- Mesh tables: `Mesh_Vertadr`/`Mesh_Vertnum`, `Mesh_Normaladr`/`Mesh_Normalnum`,
  `Mesh_Texcoordadr`/`Mesh_Texcoordnum`, `Mesh_Faceadr`/`Mesh_Facenum`, `Mesh_Polyadr`/`Mesh_Polynum`,
  `Mesh_Polyvertadr`/`Mesh_Polyvertnum`, `Mesh_Polymapadr`/`Mesh_Polymapnum` contiguous and in range.
  `Mesh_Face` entries index the mesh's own vertices: `0 .. Mesh_Vertnum - 1` for that mesh.
  `Mesh_Graph` (convex hull graph used by GJK): the graph block for a mesh starts with two
  integers `numvert`, `numface`, followed by `vert_edgeadr (numvert)`, `vert_globalid (numvert)`,
  `edge_localid (numvert + 3*numface)`, `face_globalid (3*numface)`; all sizes and indices are
  checked against the block length `Mesh_Graphadr (next) - Mesh_Graphadr (this)` and the mesh's
  vertex count.
- `Mesh_Polynormal` length `3 * Nmeshpoly`; `Mesh_Polyvert` entries index the mesh's vertices;
  `Mesh_Polymap` entries index the mesh's polygons.
- Heightfields: `Hfield_Nrow (H) >= 1`, `Hfield_Ncol (H) >= 1`, and
  `Hfield_Adr (H) + Nrow * Ncol <= Nhfielddata` computed in `Long_Integer`; `Hfield_Size (H)`
  components positive for the first three, non-negative for the fourth.
- Textures: `Tex_Adr (T) + Nchannel * Height * Width <= Ntexdata` in `Long_Integer`;
  `Tex_Nchannel (T) in 1 .. 4`.
- BVH: `Body_Bvhadr`/`Body_Bvhnum` and `Mesh_Bvhadr`/`Mesh_Bvhnum` contiguous within `0 .. Nbvh - 1`.
  For every node `N`: `Bvh_Child (2N), Bvh_Child (2N+1) in -1 .. Nbvh - 1`, a child is either
  `-1` or greater than `N` and inside the same BVH block; `Bvh_Nodeid (N) = -1` exactly when the
  node has at least one child; for a leaf of a body BVH, `Bvh_Nodeid` is a geom id in
  `0 .. Ngeom - 1` whose `Geom_Bodyid` is that body; for a leaf of a mesh BVH it is a face index
  in `0 .. Mesh_Facenum - 1` of that mesh; `Bvh_Depth (N) in 0 .. Max_Tree_Depth`.
  Octree (`Oct_*`) has the same child and depth rules with eight children per node.
- `Nbvhstatic + Nbvhdynamic = Nbvh`.

### 5.7 Pairs, excludes, equalities, tendons, wraps

- `Pair_Geom1`, `Pair_Geom2` in `0 .. Ngeom - 1`, and
  `Pair_Signature (P) = Geom_Bodyid (Pair_Geom1 (P)) * 2**16 + Geom_Bodyid (Pair_Geom2 (P))`,
  which is how the compiler forms it. `Exclude_Signature (E) = B1 * 2**16 + B2` with `B1` and
  `B2` distinct body ids in `0 .. Nbody - 1`. Both imply `Nbody < 2**16`, which is checked.
- Equalities: object checks exactly as the C checker (`eq_type`, `eq_objtype`, `eq_obj1id`,
  `eq_obj2id` per type); `Eq_Active0 (E) in 0 .. 1`; `Eq_Type (E) /= Distance` (removed type,
  fatal in C) reported as `Invalid_Enum`.
- Tendons: `Tendon_Adr`/`Tendon_Num` contiguous within `0 .. Nwrap - 1`, `Tendon_Num (T) >= 1`;
  `Tendon_Treeid` entries in `-1 .. Ntree - 1`.
- Wraps: `Wrap_Type (W) in 0 .. 5`; `Wrap_Objid` per type as in C (joint, site, geom). A
  spatial tendon (first wrap is a site) alternates site and optional geom wraps and never
  contains joint wraps; a fixed tendon contains only joint wraps. Pulley wraps only in spatial
  tendons.

### 5.8 Actuators and sensors

- `Actuator_Trntype (A) in 0 .. 7`, `Actuator_Dyntype in 0 .. 7`, `Actuator_Gaintype in 0 .. 6`,
  `Actuator_Biastype in 0 .. 5`; `Actuator_Trnid` per type as in C.
- `Actuator_Actadr`/`Actuator_Actnum` contiguous within `0 .. Na - 1` for actuators with
  `Dyntype /= None`, `-1`/`0` otherwise; `Actuator_Ctrladr`/`Actuator_Ctrlnum` and
  `Actuator_Outadr`/`Actuator_Outnum` contiguous within `0 .. Nu - 1` and `0 .. Nout - 1`.
- `Actuator_Actlimited`, `Actuator_Ctrllimited`, `Actuator_Forcelimited` in `0 .. 1`;
  when limited, `range (0) <= range (1)`.
- Sensors: `Sensor_Type (S) in 0 .. 48` and not `Plugin` (plugins are rejected earlier);
  `Sensor_Datatype in 0 .. 3`; `Sensor_Needstage in 0 .. 3`; `Sensor_Dim (S) = Sensor_Size (type, dim)`
  as computed by C's `sensorSize`; `Sensor_Adr` contiguous, `Sensor_Adr (last) + Dim (last) = Nsensordata`;
  `Sensor_Objtype`/`Sensor_Objid` and `Sensor_Reftype`/`Sensor_Refid` checked with C's
  `numObjects` table; the tactile-sensor collision-geom rule from C is kept.

### 5.9 Keys, numerics, text, tuples, names, paths

- `Key_Qpos` length `Nkey * Nq` and every value in `Tier0_Real`; same for `Key_Qvel`, `Key_Act`,
  `Key_Ctrl`, `Key_Mpos` (`3 * Nmocap`), `Key_Mquat` (`4 * Nmocap`, unit quaternions).
- `Numeric_Adr`/`Numeric_Size`, `Text_Adr`/`Text_Size`, `Tuple_Adr`/`Tuple_Size` contiguous and
  in range; `Tuple_Objtype`/`Tuple_Objid` checked with the `numObjects` table.
- `names` begins with the model name and its NUL; then every object contributes its name and a
  NUL, an unnamed object contributing a lone NUL. So every `Name_*adr (I)` is in `0 .. Nnames - 1`
  and a NUL byte exists at or after it inside `names`; the last byte of `names` is NUL.
  `names_map` is loaded but not validated; the name lookup table is rebuilt by `MJ.Name` in
  sub-project 7.
- Every `*_pathadr` is `-1` or inside `paths` at a NUL-terminated string.

### 5.10 Floating-point sanity

Every double in `Model` is finite (guaranteed by the loader) and:

- `Opt.Timestep > 0`, `Opt.Impratio > 0`, tolerances `>= 0`, iteration counts `>= 0`;
  `Opt.Integrator in 0 .. 3`, `Opt.Cone in 0 .. 1`, `Opt.Jacobian in 0 .. 2`, `Opt.Solver in 0 .. 2`.
- Every `mjtNum` array value is in `Tier0_Real` (magnitude at most 1e10).
- `Body_Mass (I) >= 0`, `Body_Subtreemass (I) >= Body_Mass (I)`, `Body_Inertia` components `>= 0`,
  `Body_Invweight0` components `>= 0`; `Body_Quat` and `Body_Iquat` unit quaternions within 1e-6.
- `Jnt_Axis` unit vector within 1e-6 for slide and hinge; `Geom_Size` components `>= 0`;
  `Geom_Quat`, `Site_Quat`, `Cam_Quat`, `Mesh_Quat` unit within 1e-6; `Geom_Rbound >= 0`.
- `Geom_Friction` components `>= 0`; `Geom_Solref`, `Geom_Solimp`, and every other `solref` /
  `solimp`: `solimp (0), solimp (1) in [Min_Imp, Max_Imp]`, `solimp (2) >= 0`, `solimp (3) > 0`,
  `solimp (4) >= 1`; `solref (0)` and `solref (1)` finite (negative values select the direct
  stiffness/damping form, as in C).
- `Dof_Armature >= 0`, `Dof_Damping >= 0`, `Dof_Frictionloss >= 0`, `Dof_Invweight0 >= 0`,
  `Dof_M0 >= 0`; `Tendon_Stiffness >= 0`, `Tendon_Damping >= 0`, `Tendon_Frictionloss >= 0`;
  `Actuator_Acc0 >= 0`.
- `Stat.Meaninertia > 0`, `Stat.Meanmass > 0`, `Stat.Meansize > 0`, `Stat.Extent > 0`.

Every one of these is a fact some downstream proof needs; the list grows only when a later
sub-project needs a new fact, and each addition is recorded in that sub-project's spec.

### 5.11 Capacities

`Validate` computes `M.Caps`, and `Is_Valid` includes the clause that `M.Caps` equals the value
of these formulas:

```
Contact_Cap = clamp (if Options.Contact_Cap > 0 then Options.Contact_Cap
                     elsif S.Nconmax >= 0 then S.Nconmax
                     else 64 + 16 * S.Ngeom,  0, Max_Cap)
Ne_Max      = sum over equalities: Connect 3, Weld 6, Joint 1, Tendon 1   (flex kinds: 0 in v1)
Nf_Max      = count (Dof_Frictionloss > 0) + count (Tendon_Frictionloss > 0)
Nl_Max      = 2 * count (limited slide/hinge joints) + count (limited ball joints)
              + 2 * count (limited tendons)
Efc_Cap     = Ne_Max + Nf_Max + Nl_Max + 10 * Contact_Cap        (10 rows is the pyramidal condim-6 case)
NJ_Cap      = Efc_Cap * Nv                                        (dense bound on Jacobian non-zeros)
NIsland_Cap = Ntree
NIdof_Cap   = Nv
```

All sums are computed in `Long_Integer`; if `Efc_Cap > Max_Cap` or `NJ_Cap > Max_Size` the
result is `Capacity_Overflow`. Sub-project 6 adds the capacities for the `AR` and `Y` matrices
of the dual solver path in its own spec.

### 5.12 Adhesion flag

`Flg_Adhesion` is not stored in `.mjb`. Upstream computes it in `mj_setConst` at compile time and
does not recompute it in `mj_loadModelBuffer`. The validator sets it to `True` when any
`Geom_Adhesion` or `Pair_Adhesion` value is positive, which matches the state of a model compiled
from XML, the state the reference oracle is in.

## 6. Loader: `MJ.MJB`

### 6.1 File format (as written by `mj_saveModel`)

```
int32[5]  header = { 54321, 8, 98, 3012000, 486 }
int64[98] sizes, in MJMODEL_SIZES order
mjOption  (generated size and offsets)
mjVisual  (generated size and offsets)
mjStatistic (generated size and offsets)
mjtBool   flg_gravcomp
mjtBool   flg_surfacevel
arrays    every MJMODEL_POINTERS field in X-macro order, sizeof(type) * nr * nc bytes each, no padding
```

The file must end exactly after the last array; extra bytes are `Trailing_Bytes`.

### 6.2 Layers

- `MJ.MJB.IO` (`SPARK_Mode => Off`): reads a whole file into a heap `Byte_Array`, returning
  `File_Error` on any failure. Also writes a `Byte_Array` to a file (used by tests).
- `MJ.MJB` (SPARK): `procedure Parse (Bytes : Byte_Array; Options : Validate_Options;
  M : out Model; Result : out Load_Result)`. On `OK`, `M` is allocated and validated
  (`Post => (if Result.Status = OK then Valid_Layout (M) and then Is_Valid (M))`).
  On any failure, `M` holds no allocations (`Free` has been called).
- `procedure Load (Path : String; Options; M : out Model; Result : out Load_Result)` composes the two.

### 6.3 Parser

A cursor `Pos : Natural` with the invariant `Pos <= Bytes'Length` walks the buffer. Primitive
readers have preconditions on the remaining length and postconditions on the cursor advance:

```ada
procedure Read_I32 (B : Byte_Array; Pos : in out Natural; V : out Integer)
  with Pre => Pos <= B'Length - 4, Post => Pos = Pos'Old + 4;
procedure Read_I64 (B : Byte_Array; Pos : in out Natural; V : out Long_Integer) ...
procedure Read_F64 (B : Byte_Array; Pos : in out Natural; V : out Real; Finite : out Boolean) ...
procedure Read_F32 ... Read_U8 ...
```

Doubles and floats are assembled from bytes into `Interfaces.Unsigned_64` / `Unsigned_32`,
converted with `Ada.Unchecked_Conversion`, and checked with `'Valid`; a non-finite value returns
`Non_Finite_Value` with the field and index. Little-endian byte order is assumed and asserted at
elaboration against the host's `System.Default_Bit_Order`.

Sizes are read as `Long_Integer` and must be in `0 .. Max_Size`, else `Size_Out_Of_Range`.
`Nbody >= 1` as in `mj_makeModel`. The array phase computes each array's byte length in
`Long_Integer`, checks it against the remaining bytes (`Truncated`), allocates, and fills.
The per-array code is generated (Section 2.8).

### 6.4 After parsing

`Parse` calls `Validate`, which fills `Caps` and `Flg_Adhesion`. The model returned to the caller
is therefore always a `Valid_Model` when the status is `OK`.

## 7. Tools

- `tools/xmacro_dump.c`, `tools/layout_dump.c`: compiled with `C:\msys64\mingw64\bin\gcc.exe`
  against the submodule headers by `tools/check-gen.ps1`. Their outputs `tools/fields.txt` and
  `tools/layout.txt` are checked in.
- `tools/gen.py` (Python 3, installed via winget): emits
  `src/gen/mj-model-groups.ads` (group records, `Sizes`, `Field_Id`, `Valid_Layout`),
  `src/gen/mj-model-fixed.ads` (`Option`, `Visual`, `Statistic` with layout constants),
  `src/gen/mj-model-alloc.adb` (`Allocate`, `Free`), `src/gen/mj-mjb-arrays.adb` (the array
  reading phase), and `src/gen/mj-validate-refs.adb` (the Section 5.2 reference table).
  The generator holds the hand-reviewed exception list for `-1` references.
- `tools/oracle.py`: `python tools/oracle.py compile <xml> <mjb>` and `... corpus <outdir>`
  using the `mujoco==3.12.0` wheel. Reference trajectories are added in sub-project 9.
- `tools/mjinfo.adb`: the command line inspector.

## 8. Tests for this spec

1. **Reader unit tests**: little-endian decoding of int32, int64, float64, float32, byte;
   `Non_Finite_Value` on NaN and both infinities; `Truncated` at every phase boundary.
2. **Header tests**: each of the five header mismatches yields its own status.
3. **Mutation tests**: load a corpus model, corrupt one field, expect the matching status and
   field. One mutation per clause in Section 5, driven by a table.
4. **Corpus test**: `tools/oracle.py corpus` produces `.mjb` for every XML in the corpus; the
   runner loads each and asserts `OK`, `Unsupported_Plugins`, or `Unsupported_Flex` as expected
   from the XML (a plugin or flex element present). The expected list is checked in.
5. **Round trip**: `Parse` then a test-only `Serialize` reproduces the input bytes exactly.
6. **Proof**: `prove.ps1` at level 2, zero unproved checks, no justifications.

## 9. Deliverables

```
alire.toml, sparkling_mujoco.gpr, prove.ps1
src/mj.ads
src/mj-types.ads
src/mj-model.ads / .adb               (hand-written parts: record, Allocate/Free declarations)
src/mj-model-validity.ads             (clause functions, Is_Valid, Valid_Model)
src/mj-validate.ads / .adb
src/mj-mjb.ads / .adb, src/mj-mjb-io.ads / .adb
src/gen/*                             (generated, checked in)
tools/xmacro_dump.c, tools/layout_dump.c, tools/gen.py, tools/check-gen.ps1, tools/oracle.py
tools/mjinfo.adb, tools/tools.gpr
tests/*.adb, tests/tests.gpr, tests/run.ps1, tests/corpus_expected.txt
docs/proof-justifications.md
```

## 10. Risks and mitigations

- **gnatprove float reasoning on large predicates.** The predicate is split into small clause
  functions so each verification condition stays local; provers CVC5, Z3, and Alt-Ergo are all
  enabled; level 2 with a per-check timeout of 60 seconds is the baseline.
- **Generator fidelity.** The table comes from the C preprocessor, not from regex parsing, and
  the round-trip test (Section 8.5) plus the header pointer count (486) catch any drift.
- **Corpus needs Python.** `oracle.py` is the only Python; the `.mjb` files it produces are not
  checked in because they are large, but the expected-status list is.
- **Struct layout assumptions.** Offsets are generated by the C compiler on this machine; the
  wheel is built by upstream with MSVC. Both target x86-64 Windows with the same alignment rules,
  and the round-trip test against wheel-produced files confirms it.
