--  Copyright 2025 DeepMind Technologies Limited.
--  Apache-2.0; see LICENSE. Modified: Ada/SPARK translation and bounded storage.
with MJ.Types; use MJ.Types;
with MJ.Sleep_Kernels;
with MJ.Sleep_Cycles;
package MJ.Sleep_Manager with SPARK_Mode is
   package K renames MJ.Sleep_Kernels;
   use type K.Object_State;
   Max_Trees : constant := MJ.Sleep_Cycles.Max_Trees;
   Max_Bodies : constant := 4096;
   Max_Dofs : constant := 4096;
   subtype Tree_Count is Natural range 0 .. Max_Trees;
   subtype Body_Count is Positive range 1 .. Max_Bodies;
   subtype Dof_Count is Natural range 0 .. Max_Dofs;
   subtype Tree_Value is MJ.Sleep_Cycles.Tree_Value;
   subtype Policy is Integer range 0 .. 5; -- AUTO/AUTO_NEVER/AUTO_ALLOWED/NEVER/ALLOWED/INIT
   subtype Tree_Array is MJ.Sleep_Cycles.Tree_Array;
   use type Tree_Array;
   type Flags is array (Integer range <>) of Boolean;
   type Indices is array (Integer range <>) of Integer;
   type States is array (Integer range <>) of K.Object_State;
   type Tree_Parameters is record
      Body_First : Natural := 0;
      Bodies : Natural := 0;
      Dof_First : Natural := 0;
      Dofs : Natural := 0;
      Sleep_Policy : Policy := 0;
   end record;
   type Tree_Parameters_Array is array (Integer range <>) of Tree_Parameters;
   type Body_Parameters is record
      Tree : Integer := -1;
      Parent : Natural := 0;
      Mocap_Root : Boolean := False;
   end record;
   type Body_Parameters_Array is array (Integer range <>) of Body_Parameters;
   subtype Tree_Last is Integer range -1 .. Max_Trees-1;
   subtype Body_Last is Integer range 0 .. Max_Bodies-1;
   subtype Dof_Last is Integer range -1 .. Max_Dofs-1;
   type Topology (Last_Tree : Tree_Last; Last_Body : Body_Last; Last_Dof : Dof_Last) is record
      Nt : Tree_Count := Last_Tree+1;
      Nb : Body_Count := Last_Body+1;
      Nv : Dof_Count := Last_Dof+1;
      Trees : Tree_Parameters_Array (0 .. Last_Tree);
      Bodies : Body_Parameters_Array (0 .. Last_Body);
      Dof_Body : Indices (0 .. Last_Dof) := (others => 0);
      Length : K.Weights (0 .. Last_Dof) := (others => 0.0);
   end record;
   function Valid (M : Topology) return Boolean is
     (M.Nt = M.Trees'Length and then M.Nb = M.Bodies'Length and then M.Nv = M.Dof_Body'Length
      and then (for all T of M.Trees => T.Body_First <= M.Nb and then T.Bodies <= M.Nb - T.Body_First
         and then T.Dof_First <= M.Nv and then T.Dofs <= M.Nv - T.Dof_First)
      and then (for all B in M.Bodies'Range => M.Bodies (B).Tree in -1 .. Integer (M.Nt) - 1
         and then M.Bodies (B).Parent in M.Bodies'Range
         and then (if B > 0 then M.Bodies (B).Parent < B))
      and then (for all B of M.Dof_Body => B in M.Bodies'Range));
   type State (Last_Tree : Tree_Last; Last_Body : Body_Last; Last_Dof : Dof_Last) is record
      Nt : Tree_Count := Last_Tree+1;
      Nb : Body_Count := Last_Body+1;
      Nv : Dof_Count := Last_Dof+1;
      Tree_Asleep : Tree_Array (0 .. Last_Tree) := (others => K.Fully_Awake);
      Tree_Awake : Flags (0 .. Last_Tree) := (others => True);
      Body_Awake : States (0 .. Last_Body) := (others => K.Awake);
      Body_Index : Indices (0 .. Last_Body) := (others => -1);
      Parent_Index : Indices (0 .. Last_Body) := (others => -1);
      Dof_Index : Indices (0 .. Last_Dof) := (others => -1);
      Trees_Awake : Tree_Count := Last_Tree+1;
      Bodies_Awake : Natural := 0;
      Parents_Awake : Natural := 0;
      Dofs_Awake : Dof_Count := 0;
   end record;
   type Result is (Success, Invalid_Cycle, Invalid_Connection);
   function Same_Shape (M : Topology; S : State) return Boolean is
     (M.Nt = S.Nt and then M.Nb = S.Nb and then M.Nv = S.Nv
      and then S.Nt = S.Tree_Asleep'Length and then S.Nb = S.Body_Awake'Length and then S.Nv = S.Dof_Index'Length);
   --  Caller-owned CSR island lists: complete tree permutation, including the
   --  unconstrained suffix. Build once per island topology, not per tree scan.
   type Islands (Last_Tree : Tree_Last; Last_Island : Tree_Last) is record
      Nt : Tree_Count := Last_Tree+1;
      Count : Tree_Count := Last_Island+1;
      First : Indices (0 .. Last_Island) := (others => 0);
      Size : Indices (0 .. Last_Island) := (others => 0);
      Tree : Indices (0 .. Last_Tree) := (others => 0);
   end record;
   function Valid_Islands (I : Islands) return Boolean is
     (I.Nt = I.Tree'Length and then I.Count = I.First'Length and then I.Count <= I.Nt and then (for all X of I.Tree => X in 0 .. Integer (I.Nt) - 1)
      and then (for all A in I.Tree'Range =>
        (for all B in I.Tree'First .. A - 1 => I.Tree (A) /= I.Tree (B)))
      and then (for all J in I.First'Range => I.First (J) >= 0 and then I.Size (J) > 0
        and then I.First (J) <= Integer (I.Nt) - I.Size (J)
        and then (if J = 0 then I.First (J) = 0
                  else I.First (J) = I.First (J-1) + I.Size (J-1))));
   --  Exact bounded traversal, shared with the independently proved unit.
   function Sleep_Cycle (T : Tree_Array; Start : Integer) return Integer
     renames MJ.Sleep_Cycles.Sleep_Cycle;
   --  Validate before changing a cycle: unlike C's fatal-error path, rejection
   --  preserves the full input. Awake counters retain C's min(old,requested).
   procedure Wake_Island (T : in out Tree_Array; Start : Integer; Value : K.Counter;
     Woke : out Natural; Status : out Result) with Global => null,
     Pre => T'First = 0 and then T'Last in -1 .. Max_Trees-1,
     Post => Woke <= T'Length
       and then (if Status /= Success then T = T'Old and Woke = 0)
       and then (if Status = Success then Start in T'Range
         and then (if T'Old (Start) < 0 then Woke = 0
           and then (for all J in T'Range => T (J) =
             (if J = Start then K.Wake_Value (T'Old (J), Value) else T'Old (J)))
         else (for all J in T'Range =>
           (T (J) = T'Old (J) or T (J) = Value)
           and then (if T'Old (J) < 0 then T (J) = T'Old (J)))));
   procedure Update (M : Topology; S : in out State; Static_Awake : Boolean := False) with
     Global => null, Pre => Valid (M) and then Same_Shape (M, S),
     Post => S.Tree_Asleep = S.Tree_Asleep'Old
       and then (for all T in S.Tree_Awake'Range => S.Tree_Awake (T) = (S.Tree_Asleep (T) < 0))
       and then (for all I in M.Bodies'Range =>
         S.Body_Awake (I) = K.Body_State (M.Bodies (I).Tree,
           (if M.Bodies (I).Tree >= 0 then S.Tree_Awake (M.Bodies (I).Tree) else False),
           M.Bodies (I).Mocap_Root, Static_Awake))
       and then S.Trees_Awake <= S.Nt and then S.Bodies_Awake <= S.Nb
       and then S.Parents_Awake <= S.Nb and then S.Dofs_Awake <= S.Nv;
   function Can_Sleep (M : Topology; Tree : Natural; Qvel, Applied, External : K.Samples;
     Tol : Nonneg_Tier0) return Boolean with Global => null,
     Pre => Valid (M) and then Tree < M.Nt and then Qvel'First = 0 and then Qvel'Length = M.Nv
       and then Applied'First = 0 and then Applied'Length = M.Nv
       and then External'First = 0 and then External'Length = 6 * M.Nb;
   procedure Wake_Perturbations (M : Topology; S : in out State; Enabled : Boolean;
     Pose_Changed : Flags; Qvel, Applied, External : K.Samples;
     Woke : out Natural; Status : out Result) with Global => null,
     Pre => Valid (M) and then Same_Shape (M, S)
       and then Pose_Changed'First = 0 and then Pose_Changed'Length = M.Nt
       and then Qvel'First = 0 and then Qvel'Length = M.Nv
       and then Applied'First = 0 and then Applied'Length = M.Nv
       and then External'First = 0 and then External'Length = 6 * M.Nb;
   type Body_Pair is record A, B : Integer := -1; end record;
   type Pairs is array (Integer range <>) of Body_Pair;
   --  Resolve geom/site/joint/flex contact IDs to body IDs before this boundary.
   --  Body -1 denotes a missing equality endpoint (STATIC), never a contact.
   procedure Wake_Connections (M : Topology; S : in out State; Edges : Pairs;
     Equality, Enabled : Boolean; Woke : out Natural; Status : out Result) with
     Global => null, Pre => Valid (M) and then Same_Shape (M, S)
       and then (for all E of Edges => E.A in -1 .. Integer (M.Nb)-1 and E.B in -1 .. Integer (M.Nb)-1);
   --  Multi-tree groups are pre-resolved CSR tree lists. Active is the exact
   --  upstream predicate (limit/metric for tendons, eq_active for flex).
   type Group is record First, Size : Natural := 0; Active : Boolean := False; end record;
   type Groups is array (Integer range <>) of Group;
   procedure Wake_Groups (S : in out State; Lists : Groups; Trees : Indices;
     Flex_Equality, Enabled : Boolean; Woke : out Natural; Status : out Result) with
     Global => null, Pre => Trees'First = 0
       and then (for all T of Trees => T in S.Tree_Asleep'Range)
       and then (for all G of Lists => G.First <= Trees'Length and then G.Size <= Trees'Length-G.First);
   procedure Sleep (M : Topology; S : in out State; I : Islands;
     Enabled, Has_Constraints : Boolean; Tol : Nonneg_Tier0;
     Qvel, Qacc : in out K.Samples; Applied, External : K.Samples;
     Slept : out Natural; Status : out Result) with Global => null,
     Pre => Valid (M) and then Same_Shape (M, S) and then I.Nt = M.Nt and then Valid_Islands (I)
       and then Qvel'First = 0 and then Qvel'Length = M.Nv
       and then Qacc'First = 0 and then Qacc'Length = M.Nv
       and then Applied'First = 0 and then Applied'Length = M.Nv
       and then External'First = 0 and then External'Length = 6 * M.Nb;
end MJ.Sleep_Manager;
