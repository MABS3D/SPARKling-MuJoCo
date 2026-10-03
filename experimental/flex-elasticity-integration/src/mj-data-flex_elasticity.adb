with Ada.Unchecked_Deallocation;
with Ada.Numerics.Long_Elementary_Functions;
with MJ.Models.Validity;
with MJ.Data.Forward;
with MJ.Data.Pipeline;
with MJ.Data.Inertia_Phase;
with MJ.Manifold_Math;
with MJ.Smooth_Dynamics;
with Interfaces;
with MJ.Validation;
with MJ.Fields;
with MJ.Equality_Flex;

package body MJ.Data.Flex_Elasticity with SPARK_Mode is
   use type MJ.Models.Sizes;
   use type Interfaces.Unsigned_8;
   procedure Release is new Ada.Unchecked_Deallocation (Storage, Storage_Access);
   procedure Release_Int is new Ada.Unchecked_Deallocation (Int_Array, Int_Array_Access);
   function Ready (Model : Force_Model) return Boolean is (Model.S /= null);
   function Ready (E : Engine) return Boolean is (E.S /= null and then Is_Ready (E.D));
   function State (E : Engine) return Real_Array is (State_Values (E.D));
   function Complete_State (E : Engine) return Real_Array is (Complete_State_Values (E.D));
   function Acceleration (E : Engine) return Real_Array is
     (if Ready (E) then E.D.Dynamics.Acceleration.all else [0 .. -1 => 0.0]);
   function Passive (E : Engine) return Real_Array is
     (if Ready (E) then E.D.Dynamics.Passive.all else [0 .. -1 => 0.0]);
   function Diagnostics (E : Engine) return Trace is
   begin
      if E.S = null then
         return (Nv => 0, Npos => 0, Nedge => 0, Valid => False, others => [others => 0.0]);
      end if;
      declare
         T : Trace (E.S.Nv, 3 * E.S.Nvert, E.S.Nedge);
      begin
         T.Position := [others => 0.0];
         T.Valid := E.S.Valid;
         T.Spring := E.S.Spring; T.Damper := E.S.Damper;
         T.Length := [for K in T.Length'Range => Real (E.S.Length (K-1))];
         T.Velocity := E.S.Velocity;
         for V in E.S.Positions'Range loop
            for A in Axis loop T.Position (3 * V + A + 1) := E.S.Positions (V) (A); end loop;
         end loop;
         return T;
      end;
   end Diagnostics;

   function Jacobian_Trace (S : Storage) return Edge_Jacobian_Trace is
      T : Edge_Jacobian_Trace (S.Nedge, S.Edge_J'Length);
   begin
      T.Valid := S.Valid;
      for I in S.Edges'Range loop
         T.Rowadr (I+1) := S.Edges (I).Rowadr;
         T.Rownnz (I+1) := S.Edges (I).Rownnz;
      end loop;
      T.Columns := S.Edge_Columns;
      --  Use the declared target range also for a zero-slot cache. The
      --  iterated component aggregate otherwise attempts an invalid null
      --  bound when the compiled model has no DOFs.
      T.Values := [for K in T.Values'Range => Real (S.Edge_J (K-1))];
      return T;
   end Jacobian_Trace;

   function Edge_Jacobians (Model : Force_Model) return Edge_Jacobian_Trace is
   begin
      if Model.S = null then
         return (Nedge => 0, Slots => 0, Valid => False,
                 Rowadr | Rownnz | Columns => [others => 0], Values => [others => 0.0]);
      end if;
      return Jacobian_Trace (Model.S.all);
   end Edge_Jacobians;

   function Edge_Jacobians (E : Engine) return Edge_Jacobian_Trace is
   begin
      if E.S = null then
         return (Nedge => 0, Slots => 0, Valid => False,
                 Rowadr | Rownnz | Columns => [others => 0], Values => [others => 0.0]);
      end if;
      return Jacobian_Trace (E.S.all);
   end Edge_Jacobians;

   procedure Copy_Edge_Columns
     (Source : Int_Array; Target : in out Int_Array; Nv : Natural;
      Result : out Status) with
     Pre => (Static => Source'First = 0 and then Target'First = 0
       and then Source'Length = Target'Length and then Nv <= Max_Dofs),
     Post => (Static => (if Result = Success then Target = Source
       and then (for all Column of Target => Column in 0 .. Nv-1))) is
   begin
      Result := Invalid_Model;
      for I in Target'Range loop
         if Source (I) not in 0 .. Nv-1 then return; end if;
         Target (I) := Source (I);
         pragma Loop_Invariant (for all K in Target'First .. I =>
           Target (K) = Source (K) and then Target (K) in 0 .. Nv-1);
      end loop;
      Result := Success;
   end Copy_Edge_Columns;

   procedure Copy_Flex_Edge_Ranges
     (Address, Count : Int_Array; Target : in out Flex_Array;
      Nedge : Natural; Result : out Status) with
     Pre => (Static => Address'First = 0 and then Count'First = 0
       and then Target'First = 0 and then Address'Length = Target'Length
       and then Count'Length = Target'Length and then Nedge <= Max_Edges),
     Post => (Static => (if Result = Success then
       (for all F in Target'Range => Target (F).First_Edge <= Nedge
         and then Target (F).Nedge <= Nedge-Target (F).First_Edge
         and then Target (F).First_Edge = Address (F)
         and then Target (F).Nedge = Count (F)))) is
   begin
      Result := Invalid_Model;
      for F in Target'Range loop
         if Address (F) not in 0 .. Nedge
           or else Count (F) not in 0 .. Nedge-Address (F) then return; end if;
         Target (F).First_Edge := Address (F); Target (F).Nedge := Count (F);
         pragma Loop_Invariant (for all K in Target'First .. F =>
           Target (K).First_Edge <= Nedge
           and then Target (K).Nedge <= Nedge-Target (K).First_Edge
           and then Target (K).First_Edge = Address (K)
           and then Target (K).Nedge = Count (K));
      end loop;
      Result := Success;
   end Copy_Flex_Edge_Ranges;

   procedure Copy_Edge_Rows
     (Address, Width : Int_Array; Target : in out Edge_Array;
      Nv, Slots : Natural; Result : out Status) with
     Pre => (Static => Address'First = 0 and then Width'First = 0
       and then Target'First = 0 and then Address'Length = Target'Length
       and then Width'Length = Target'Length and then Nv <= Max_Dofs
       and then Slots <= Max_Edge_Entries),
     Post => (Static => (if Result = Success then
       (for all I in Target'Range => Target (I).Rownnz <= Nv
         and then Target (I).Rowadr <= Slots
         and then Target (I).Rownnz <= Slots-Target (I).Rowadr
         and then Target (I).Rowadr = Address (I)
         and then Target (I).Rownnz = Width (I)))) is
   begin
      Result := Invalid_Model;
      for I in Target'Range loop
         if Address (I) not in 0 .. Slots
           or else Width (I) not in 0 .. Nv
           or else Width (I) > Slots-Address (I) then return; end if;
         Target (I).Rowadr := Address (I); Target (I).Rownnz := Width (I);
         pragma Loop_Invariant (for all K in Target'First .. I =>
           Target (K).Rownnz <= Nv and then Target (K).Rowadr <= Slots
           and then Target (K).Rownnz <= Slots-Target (K).Rowadr
           and then Target (K).Rowadr = Address (K)
           and then Target (K).Rownnz = Width (K));
      end loop;
      Result := Success;
   end Copy_Edge_Rows;

   --  Admission only: copy the compiled CSR topology once, before any frame
   --  can consume it. The force/equality paths share this owned cache.
   procedure Load_Edge_Layout
     (Columns, Flex_Address, Flex_Count, Row_Address, Row_Width : Int_Array;
      S : in out Storage; Result : out Status) with
     Pre => (Static => Edge_Layout_Shape (S)
       and then Columns'First = 0 and then Columns'Length = S.Edge_Columns'Length
       and then Flex_Address'First = 0 and then Flex_Address'Length = S.Flexes'Length
       and then Flex_Count'First = 0 and then Flex_Count'Length = S.Flexes'Length
       and then Row_Address'First = 0 and then Row_Address'Length = S.Edges'Length
       and then Row_Width'First = 0 and then Row_Width'Length = S.Edges'Length),
     Post => (Static => (if Result = Success then Edge_Layout_Valid (S)
       and then S.Edge_Columns = Columns
       and then (for all F in S.Flexes'Range =>
         S.Flexes (F).First_Edge = Flex_Address (F)
         and then S.Flexes (F).Nedge = Flex_Count (F))
       and then (for all I in S.Edges'Range =>
         S.Edges (I).Rowadr = Row_Address (I)
         and then S.Edges (I).Rownnz = Row_Width (I)))) is
   begin
      Copy_Edge_Columns (Columns, S.Edge_Columns, S.Nv, Result);
      if Result /= Success then return; end if;
      Copy_Flex_Edge_Ranges (Flex_Address, Flex_Count, S.Flexes, S.Nedge, Result);
      if Result /= Success then return; end if;
      Copy_Edge_Rows (Row_Address, Row_Width, S.Edges, S.Nv, S.Edge_Columns'Length, Result);
   end Load_Edge_Layout;

   procedure Load (M : MJ.Models.Model; S : in out Storage_Access; Result : out Status)
     with Post => (Static => (if Result = Success then
       S /= null and then Edge_Layout_Valid (S.all))) is
      G : MJ.Models.Flex_Arrays renames M.Flexes;
      VA, EA, TA, N, Dim, KA, BA, IA, EleA, EdA, P, V : Integer;
      Next_Vertex, Next_Edge, Next_Element : Natural := 0;
      Chain_Result : MJ.Flex_Ancestors.Status;
      use type MJ.Flex_Ancestors.Status;
   begin
      Result := Invalid_Model;
      if not MJ.Models.Valid_Layout (M) then return; end if;
      -- The rigid submodel is validated by Create before this loader runs.
      -- The existing full validator explicitly excludes flex models.
      if M.S.Nflex > Max_Flexes or else M.S.Nflexvert > Max_Vertices
        or else M.S.Nflexedge > Max_Edges or else M.S.Nflexelem > Max_Elements
        or else M.S.Nv > Max_Dofs or else M.S.NJfe > Max_Edge_Entries
      then Result := Capacity_Exceeded; return; end if;
      -- All constraints remain explicitly disabled by the smooth entry.
      -- Interpolated finite elements have a different state/rotation producer.
      for F in 0 .. M.S.Nflex - 1 loop
         if G.Flex_Interp (F) /= 0 then Result := Unsupported_Feature; return; end if;
         if G.Flex_Dim (F) not in 1 .. 3 then return; end if;
      end loop;
      S := new Storage (M.S.Nflex - 1, M.S.Nflexvert - 1, M.S.Nflexedge - 1,
                        M.S.Nflexelem - 1, M.S.Nv - 1, M.S.NJfe - 1);
      S.Nb := M.S.Nbody;
      Load_Edge_Layout (G.Flexedge_J_Colind.all, G.Flex_Edgeadr.all,
        G.Flex_Edgenum.all, G.Flexedge_J_Rowadr.all, G.Flexedge_J_Rownnz.all, S.all, Result);
      if Result /= Success then return; end if;
      Result := Invalid_Model;
      for F in 0 .. M.S.Nflex - 1 loop
         VA := G.Flex_Vertadr (F); EA := G.Flex_Edgeadr (F); TA := G.Flex_Elemadr (F);
         N := G.Flex_Vertnum (F); Dim := G.Flex_Dim (F);
         KA := G.Flex_Stiffnessadr (F); BA := G.Flex_Bendingadr (F);
         -- Compiled flex blocks own disjoint contiguous ranges. Reject gaps
         -- and overlaps before any frame can observe default topology.
         if VA /= Next_Vertex or else EA /= Next_Edge or else TA /= Next_Element then return; end if;
         if VA < 0 or else N < 0 or else VA > M.S.Nflexvert - N
           or else EA < 0 or else G.Flex_Edgenum (F) < 0 or else EA > M.S.Nflexedge - G.Flex_Edgenum (F)
           or else TA < 0 or else G.Flex_Elemnum (F) < 0 or else TA > M.S.Nflexelem - G.Flex_Elemnum (F)
           or else G.Flex_Damping (F) not in Nonneg_Tier0
           or else G.Flex_Edgestiffness (F) not in Nonneg_Tier0
           or else G.Flex_Edgedamping (F) not in Nonneg_Tier0 then return; end if;
         if G.Flex_Edgeequality (F) not in 0 .. 2 then return; end if;
         Next_Vertex := VA + N; Next_Edge := EA + G.Flex_Edgenum (F);
         Next_Element := TA + G.Flex_Elemnum (F);
         if KA < -1 or else BA < -1 then return; end if;
         if KA >= 0 and then (Dim = 1 or else KA > M.S.Nflexstiffness - 21 * G.Flex_Elemnum (F)) then return; end if;
         if BA >= 0 and then (Dim /= 2 or else BA > M.S.Nflexbending - 17 * G.Flex_Edgenum (F)) then return; end if;
         S.Flexes (F) := (Dim => Dim, First_Vertex => VA, Nvert => N,
           First_Edge => EA, Nedge => G.Flex_Edgenum (F), First_Element => TA, Nelem => G.Flex_Elemnum (F),
           Rigid => G.Flex_Rigid (F) /= 0,
           Edge_Equality => G.Flex_Edgeequality (F),
           Stretch => KA >= 0 and then G.Flex_Elemnum (F) > 0 and then G.Flex_Stiffness (KA) /= 0.0,
           Damping => G.Flex_Damping (F), Edge_Stiffness => G.Flex_Edgestiffness (F), Edge_Damping => G.Flex_Edgedamping (F));
         for I in VA .. VA + N - 1 loop
            declare
               B : constant Integer := G.Flex_Vertbodyid (I);
               Target : constant access Storage := S;
               C : Vertex renames Target.Vertices (I);
            begin
               if B not in 0 .. M.S.Nbody - 1 then return; end if;
               C.Body_Id := B; C.Dofnum := M.Bodies.Body_Dofnum (B);
               C.Dofadr := (if C.Dofnum = 0 then 0 else M.Bodies.Body_Dofadr (B));
               C.Simple := M.Bodies.Body_Simple (B) = 2;
               if C.Simple and then C.Dofnum /= 3 then return; end if;
               C.Offset := (if G.Flex_Centered (F) /= 0 then Zero else Read_Vector (G.Flex_Vert.all, 3 * I));
               if not Bounded (C.Offset, Max_Val) then return; end if;
               MJ.Flex_Ancestors.Build (M.Bodies.Body_Weldid.all,
                 M.Bodies.Body_Dofadr.all, M.Bodies.Body_Dofnum.all,
                 M.Dofs.Dof_Parentid.all, B, 0, C.Ancestors, Chain_Result);
               if Chain_Result /= MJ.Flex_Ancestors.Success then return; end if;
            end;
         end loop;
         for I in EA .. EA + G.Flex_Edgenum (F) - 1 loop
            declare
               Target : constant access Storage := S;
               C : Edge renames Target.Edges (I);
               V1 : constant Integer := G.Flex_Edge (2 * I);
               V2 : constant Integer := G.Flex_Edge (2 * I + 1);
            begin
               if V1 not in 0 .. N - 1 or else V2 not in 0 .. N - 1 then return; end if;
               if G.Flexedge_Length0 (I) not in Nonneg_Tier0
                 or else G.Flexedge_Invweight0 (I) not in Nonneg_Tier0
               then return; end if;
               C.Vert (0) := VA + V1; C.Vert (1) := VA + V2;
               C.Rest := G.Flexedge_Length0 (I); C.Rigid := G.Flexedge_Rigid (I) /= 0;
               C.Weight := G.Flexedge_Invweight0 (I);
               MJ.Flex_Ancestors.Build (M.Bodies.Body_Weldid.all,
                 M.Bodies.Body_Dofadr.all, M.Bodies.Body_Dofnum.all,
                 M.Dofs.Dof_Parentid.all, Target.Vertices (VA + V1).Body_Id,
                 Target.Vertices (VA + V2).Body_Id, C.Ancestors, Chain_Result);
               if Chain_Result /= MJ.Flex_Ancestors.Success then return; end if;
               if not Target.Flexes (F).Rigid
                 and then (Target.Flexes (F).Edge_Equality /= 0
                   or else Target.Flexes (F).Edge_Stiffness /= 0.0
                   or else Target.Flexes (F).Edge_Damping /= 0.0
                   or else Target.Flexes (F).Damping /= 0.0)
                 and then C.Rownnz /= C.Ancestors.Count then return; end if;
               if BA >= 0 then
                  for J in 0 .. 1 loop
                     V := G.Flex_Edgeflap (2 * I + J);
                     if V not in -1 .. N - 1 then return; end if;
                     C.Vert (J + 2) := (if V = -1 then -1 else VA + V);
                  end loop;
                  C.Bending := C.Vert (3) >= 0;
                  if C.Bending and then C.Vert (2) < 0 then return; end if;
                  for J in C.B'Range loop C.B (J) := G.Flex_Bending (BA + 17 * (I - EA) + J); end loop;
               end if;
            end;
         end loop;
         IA := G.Flex_Elemdataadr (F); EleA := G.Flex_Elemedgeadr (F);
         if Dim > 1 then
            EdA := (if Dim = 2 then 3 else 6);
            if IA < 0 or else IA > M.S.Nflexelemdata - (Dim + 1) * G.Flex_Elemnum (F)
              or else EleA < 0 or else EleA > M.S.Nflexelemedge - EdA * G.Flex_Elemnum (F) then return; end if;
            for I in TA .. TA + G.Flex_Elemnum (F) - 1 loop
               declare
                  Target : constant access Storage := S;
                  C : Element renames Target.Elements (I);
               begin
                  for J in 0 .. Dim loop
                     V := G.Flex_Elem (IA + (Dim + 1) * (I - TA) + J);
                     if V not in 0 .. N - 1 then return; end if;
                     C.Vert (J) := VA + V;
                  end loop;
                  for J in 0 .. EdA - 1 loop
                     V := G.Flex_Elemedge (EleA + EdA * (I - TA) + J);
                     if V not in 0 .. G.Flex_Edgenum (F) - 1 then return; end if;
                     C.Edges (J) := EA + V;
                  end loop;
                  if KA >= 0 then
                     P := 0;
                     for R in 0 .. EdA - 1 loop
                        for C2 in R .. EdA - 1 loop
                           C.M (R, C2) := G.Flex_Stiffness (KA + 21 * (I - TA) + P);
                           C.M (C2, R) := C.M (R, C2); P := P + 1;
                        end loop;
                     end loop;
                  end if;
               end;
            end loop;
         end if;
      end loop;
      if Next_Vertex /= M.S.Nflexvert or else Next_Edge /= M.S.Nflexedge
        or else Next_Element /= M.S.Nflexelem then return; end if;
      Result := Success;
   exception
      when Constraint_Error => Result := Invalid_Model;
   end Load;

   procedure Create_Forces (M : MJ.Models.Model; Model : in out Force_Model;
                            Result : out Status) is
   begin
      if Model.S /= null then Result := Already_Allocated; return; end if;
      Load (M, Model.S, Result);
      if Result /= Success then Release (Model.S); end if;
   exception
      when others => Release (Model.S); raise;
   end Create_Forces;

   procedure Free_Forces (Model : in out Force_Model) is
   begin
      Release (Model.S);
   end Free_Forces;

   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
      Saved_Sizes : constant MJ.Models.Sizes := M.S;
      Saved_Flex : MJ.Models.Flex_Arrays;
      Saved_Names : Int_Array_Access := null;
      Saved_Caps : constant Capacities := M.Caps;
      Saved_Adhesion : constant Boolean := M.Flg_Adhesion;
      Empty : MJ.Models.Flex_Arrays;
      Empty_Sizes : MJ.Models.Sizes;
      Empty_Names : Int_Array_Access := null;
      Detached : Boolean := False;
      procedure Restore is
      begin
         if Detached then
            Empty := M.Flexes;
            Empty_Names := M.Names.Name_Flexadr;
            M.S := Saved_Sizes; M.Flexes := Saved_Flex; M.Names.Name_Flexadr := Saved_Names;
            Saved_Flex := (others => <>); Saved_Names := null;
            M.Caps := Saved_Caps; M.Flg_Adhesion := Saved_Adhesion;
         end if;
         Detached := False;
      end Restore;
   begin
      if E.S /= null or else not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      Result := Invalid_Model;
      if not MJ.Models.Valid_Layout (M) then return; end if;
      MJ.Models.Allocate_Flex (Empty_Sizes, Empty);
      Empty_Names := new Int_Array'(0 .. -1 => 0);
      -- Exclusive temporary detachment, not a second owning Model. All compiled
      -- flex arrays retain their sole owner. Restore every borrowed pointer
      -- and size before freeing the temporary zero-length arrays.
      Saved_Flex := M.Flexes; Saved_Names := M.Names.Name_Flexadr;
      M.Flexes := Empty; M.Names.Name_Flexadr := Empty_Names;
      Empty := (others => <>); Empty_Names := null;
      Detached := True;
      M.S.Nflex := 0; M.S.Nflexnode := 0; M.S.Nflexvert := 0; M.S.Nflexedge := 0;
      M.S.Nflexelem := 0; M.S.Nflexelemdata := 0; M.S.Nflexstiffness := 0;
      M.S.Nflexbending := 0; M.S.Nflexelemedge := 0; M.S.Nflexshelldata := 0;
      M.S.Nflexevpair := 0; M.S.Nflextexcoord := 0; M.S.NJfe := 0; M.S.NJfv := 0;
      M.S.Nefm0dof := 0; M.S.Nefm0L := 0;
      declare
         VR : MJ.Fields.Load_Result;
         use type MJ.Types.Load_Status;
      begin
         MJ.Validation.Validate (M, (Contact_Cap => 0), VR);
         if VR.Status = OK then MJ.Data.Create (M, E.D, Result); end if;
      end;
      Restore;
      MJ.Models.Free_Flex (Empty); Release_Int (Empty_Names);
      if Result = Success then Load (M, E.S, Result); end if;
      if Result /= Success then MJ.Data.Free (E.D); Release (E.S); end if;
   exception
      when others =>
         Restore; MJ.Models.Free_Flex (Empty); Release_Int (Empty_Names);
         MJ.Data.Free (E.D); Release (E.S); raise;
   end Create;
   procedure Free (E : in out Engine; Result : out Status) is
   begin
      MJ.Data.Free (E.D); Release (E.S); Result := Success;
   end Free;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector; New_Time : Nonneg_Tier0; Result : out Status) is
   begin
      MJ.Data.Set_State (E.D, Qpos, Qvel, New_Time, Result);
      if E.S /= null then E.S.Valid := False; end if;
   end Set_State;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin
      MJ.Data.Set_Activation (E.D, Values, Result); if E.S /= null then E.S.Valid := False; end if;
   end Set_Activation;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Control (E.D, Index, Value, Result); if E.S /= null then E.S.Valid := False; end if;
   end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Applied_Force (E.D, Index, Value, Result); if E.S /= null then E.S.Valid := False; end if;
   end Set_Applied_Force;

   function Point_Jacobian (D : Simulation; S : Storage; Vertex_Id, Dof : Natural) return Vector is
      V : Vertex renames S.Vertices (Vertex_Id);
      P : constant Natural := 3 * (V.Body_Id * D.Nv + Dof);
      Offset : constant Vector := S.Offsets (Vertex_Id);
      L : Vector := Read_Vector (D.Kinematic.Linear_Jacobian.all, P);
      W : constant Vector := Read_Vector (D.Kinematic.Angular_Jacobian.all, P);
   begin
      for A in Axis loop
         L (A) := K.Jacobian_Component (L (A), W ((A + 1) mod 3), W ((A + 2) mod 3),
           Offset ((A + 1) mod 3), Offset ((A + 2) mod 3));
      end loop;
      return L;
   end Point_Jacobian;
   procedure Geometry (D : Simulation; S : in out Storage; Result : out Status) is
      Diff, Dir : Vector;
      L, Val : Real;
      Lanes : array (Natural range 0 .. 3) of Real;
      Blocks : Natural;
      function Product (C : Edge; P : Natural) return Real is
         Slot : constant Natural := C.Rowadr + P;
      begin
         return S.Edge_J (Slot) * D.State.Qvel (S.Edge_Columns (Slot));
      end Product;
   begin
      Result := Numeric_Limit;
      for I in S.Vertices'Range loop
         declare
            V : Vertex renames S.Vertices (I);
            Body_Id : constant Natural := V.Body_Id;
            B : Body_State renames D.Kinematic.Bodies (Body_Id);
         begin
            S.Positions (I) := B.Position + Apply (B.Rotation, V.Offset);
            if not Bounded (S.Positions (I), Max_Val) then return; end if;
            S.Offsets (I) := S.Positions (I) - B.Center;
            if not Bounded (S.Offsets (I), Max_Val) then return; end if;
         end;
      end loop;
      --  As mj_flex, clear the CSR value buffer once, then produce each edge
      --  Jacobian once. The passive and equality producers share this cache.
      S.Edge_J := [others => 0.0];
      S.Length := [others => 0.0]; S.Velocity := [others => 0.0];
      for F of S.Flexes loop
         if not F.Rigid then
         for I in F.First_Edge .. F.First_Edge + F.Nedge - 1 loop
         declare C : Edge renames S.Edges (I); begin
            Diff := S.Positions (C.Vert (1)) - S.Positions (C.Vert (0));
            L := Ada.Numerics.Long_Elementary_Functions.Sqrt ((Diff (0) * Diff (0) + Diff (1) * Diff (1)) + Diff (2) * Diff (2));
            if L not in Nonneg_Tier0 then return; end if;
            Dir := (if L < Min_Val then [1.0, 0.0, 0.0] else (1.0 / L) * Diff);
            S.Length (I) := L;
            if F.Edge_Equality = 1 or else F.Edge_Stiffness /= 0.0
              or else F.Edge_Damping /= 0.0 or else F.Damping /= 0.0
            then
               for P in 0 .. C.Rownnz - 1 loop
                  declare
                     Column : constant Natural := C.Ancestors.Col (P);
                     Delta_J : constant Vector := Point_Jacobian (D, S, C.Vert (1), Column)
                       - Point_Jacobian (D, S, C.Vert (0), Column);
                  begin
                     S.Edge_J (C.Rowadr + P) := MJ.Equality_Flex.Edge_Projection
                       (Delta_J (0), Delta_J (1), Delta_J (2), Dir (0), Dir (1), Dir (2));
                  end;
               end loop;
            end if;
         end;
         end loop;
         end if;
      end loop;
      --  mj_fwdVelocity consumes the completed cache after all edge rows have
      --  been produced; do not interleave reads with potentially shared slots.
      for F of S.Flexes loop
         if not F.Rigid then
         for I in F.First_Edge .. F.First_Edge + F.Nedge - 1 loop
         declare C : Edge renames S.Edges (I); begin
            Lanes := [others => 0.0];
            Blocks := C.Rownnz / 4;
            if Blocks > 0 then
               --  The ordinary x86 C SIMD path starts with the first products.
               for Lane in 0 .. 3 loop Lanes (Lane) := Product (C, Lane); end loop;
            end if;
            for P in 1 .. Blocks - 1 loop
               for Lane in 0 .. 3 loop
                  Lanes (Lane) := Lanes (Lane) + Product (C, 4 * P + Lane);
               end loop;
            end loop;
            Val := (Lanes (0) + Lanes (2)) + (Lanes (1) + Lanes (3));
            for P in 4 * Blocks .. C.Rownnz - 1 loop Val := Val + Product (C, P); end loop;
            if Val not in Tier0_Real then return; end if;
            S.Velocity (I) := Val;
         end;
         end loop;
         end if;
      end loop;
      Result := Success;
   end Geometry;

   procedure Project_Vertex (D : Simulation; S : in out Storage; I : Natural; Spring, Damper : Vector) is
      V : Vertex renames S.Vertices (I);
      J, Local_Spring, Local_Damper : Vector;
      A, B : Real;
   begin
      if V.Simple then
         Local_Spring := Apply_Transpose (D.Kinematic.Bodies (V.Body_Id).Rotation, Spring);
         Local_Damper := Apply_Transpose (D.Kinematic.Bodies (V.Body_Id).Rotation, Damper);
         for X in 0 .. V.Dofnum - 1 loop
            S.Spring (V.Dofadr + X) := S.Spring (V.Dofadr + X) + Local_Spring (X);
            S.Damper (V.Dofadr + X) := S.Damper (V.Dofadr + X) + Local_Damper (X);
         end loop;
      else
         for P in 0 .. V.Ancestors.Count - 1 loop
            J := Point_Jacobian (D, S, I, V.Ancestors.Col (P));
            A := K.Project (Spring (0), Spring (1), Spring (2), J (0), J (1), J (2));
            B := K.Project (Damper (0), Damper (1), Damper (2), J (0), J (1), J (2));
            S.Spring (V.Ancestors.Col (P)) := K.Accumulate (S.Spring (V.Ancestors.Col (P)), A);
            S.Damper (V.Ancestors.Col (P)) := K.Accumulate (S.Damper (V.Ancestors.Col (P)), B);
         end loop;
      end if;
   end Project_Vertex;

   procedure Bending_Forces (D : Simulation; S : in out Storage; F : Flex) is
      Ed : array (Natural range 0 .. 2) of Vector;
      Norm : array (Natural range 0 .. 3) of Vector := [others => Zero];
      Spring, Damper, Sl, Dl : Vector;
      X, Vel : K.Four;
      Coef : K.Four_Coefficients;
   begin
      if F.Dim /= 2 then return; end if;
      for P in F.First_Edge .. F.First_Edge + F.Nedge - 1 loop
         declare C : Edge renames S.Edges (P); begin
            if C.Bending then
               for I in 0 .. 2 loop Ed (I) := S.Positions (C.Vert (I + 1)) - S.Positions (C.Vert (0)); end loop;
               Norm (1) := Cross (Ed (1), Ed (2)); Norm (2) := Cross (Ed (2), Ed (0)); Norm (3) := Cross (Ed (0), Ed (1));
               Norm (0) := -(Norm (1) + Norm (2) + Norm (3));
               for I in 0 .. 3 loop
                  for J in 0 .. 3 loop Coef (J) := C.B (4 * I + J); end loop;
                  Spring := Zero; Damper := Zero;
                  for A in Axis loop
                     for J in 0 .. 3 loop
                        X (J) := S.Positions (C.Vert (J)) (A);
                        declare
                           Vertex_Id : constant Integer := C.Vert (J);
                           V : Vertex renames S.Vertices (Vertex_Id);
                        begin
                           Vel (J) := (if V.Dofnum = 3 then D.State.Qvel (V.Dofadr + A) else 0.0);
                        end;
                     end loop;
                     if D.Spring_Enabled then Spring (A) := K.Curved_Row (K.Bending_Row (Coef, X), C.B (16), Norm (I) (A)); end if;
                     if D.Damper_Enabled then Damper (A) := K.Bending_Row (Coef, Vel); end if;
                  end loop;
                  declare
                     Vertex_Id : constant Integer := C.Vert (I);
                     V : Vertex renames S.Vertices (Vertex_Id);
                  begin
                     if V.Dofnum = 3 then
                        Sl := Apply_Transpose (D.Kinematic.Bodies (V.Body_Id).Rotation, Spring);
                        Dl := Apply_Transpose (D.Kinematic.Bodies (V.Body_Id).Rotation, Damper);
                        for A in Axis loop
                           S.Spring (V.Dofadr + A) := S.Spring (V.Dofadr + A) - Sl (A);
                           S.Damper (V.Dofadr + A) := S.Damper (V.Dofadr + A) - Dl (A) * F.Damping;
                        end loop;
                     end if;
                  end;
               end loop;
            end if;
         end;
      end loop;
   end Bending_Forces;

   procedure Stretch_Forces (D : Simulation; S : in out Storage; F : Flex) is
      type Pair is array (Natural range 0 .. 1) of Natural;
      Tri : constant array (Natural range 0 .. 2) of Pair := [[1, 2], [2, 0], [0, 1]];
      Tet : constant array (Natural range 0 .. 5) of Pair := [[0, 1], [1, 2], [2, 0], [2, 3], [0, 3], [1, 3]];
      Es, Ed : K.Six := [others => 0.0];
      Gradient : array (Natural range 0 .. 5, Natural range 0 .. 1) of Vector := [others => [others => Zero]];
      N : constant Positive := (if F.Dim = 2 then 3 else 6);
      Id : Natural;
      T, Value : Real;
   begin
      if F.Dim = 1 or else not F.Stretch then return; end if;
      for I in F.First_Vertex .. F.First_Vertex + F.Nvert - 1 loop
         S.Spring_Vertex (I) := Zero; S.Damper_Vertex (I) := Zero;
      end loop;
      for P in F.First_Element .. F.First_Element + F.Nelem - 1 loop
         declare C : Element renames S.Elements (P); begin
            for I in 0 .. N - 1 loop
               declare B : constant Pair := (if F.Dim = 2 then Tri (I) else Tet (I)); begin
                  Gradient (I, 0) := S.Positions (C.Vert (B (0))) - S.Positions (C.Vert (B (1)));
                  Gradient (I, 1) := S.Positions (C.Vert (B (1))) - S.Positions (C.Vert (B (0)));
               end;
               Id := C.Edges (I);
               Es (I) := (if D.Spring_Enabled then K.Elongation (S.Length (Id), S.Edges (Id).Rest) else 0.0);
               Ed (I) := (if D.Damper_Enabled then K.Damping_Elongation
                 (S.Length (Id), S.Velocity (Id), D.Timestep, F.Damping) else 0.0);
            end loop;
            for Kind in Boolean loop
               if (Kind and then D.Spring_Enabled) or else (not Kind and then D.Damper_Enabled and then F.Damping /= 0.0) then
                  for I in 0 .. N - 1 loop
                     T := K.Tension ((if Kind then Es else Ed), C.M, N, I);
                     declare B : constant Pair := (if F.Dim = 2 then Tri (I) else Tet (I)); begin
                        for J in 0 .. 1 loop
                           Id := C.Vert (B (J));
                           for A in Axis loop
                              Value := K.Stretch_Update ((if Kind then S.Spring_Vertex (Id) (A) else S.Damper_Vertex (Id) (A)), T, Gradient (I, J) (A));
                              if Value not in K.Force_Value then raise Constraint_Error with "flex force domain"; end if;
                              if Kind then S.Spring_Vertex (Id) (A) := Value; else S.Damper_Vertex (Id) (A) := Value; end if;
                           end loop;
                        end loop;
                     end;
                  end loop;
               end if;
            end loop;
         end;
      end loop;
      for I in F.First_Vertex .. F.First_Vertex + F.Nvert - 1 loop
         declare
            Spring : constant Vector := S.Spring_Vertex (I);
            Damper : constant Vector := S.Damper_Vertex (I);
         begin
            Project_Vertex (D, S, I, Spring, Damper);
         end;
      end loop;
   end Stretch_Forces;

   procedure Edge_Forces (D : Simulation; S : in out Storage; F : Flex) is
      Fs, Fd, L, Jv : Real;
      Column : Natural;
   begin
      if F.Edge_Stiffness = 0.0 and then F.Edge_Damping = 0.0 then return; end if;
      for P in F.First_Edge .. F.First_Edge + F.Nedge - 1 loop
         declare C : Edge renames S.Edges (P); begin
            if not C.Rigid then
               L := S.Length (P);
               Fs := (if D.Spring_Enabled then F.Edge_Stiffness * (C.Rest - L) else 0.0);
               Fd := (if D.Damper_Enabled then -F.Edge_Damping * S.Velocity (P) else 0.0);
               for I in C.Rowadr .. C.Rowadr + C.Rownnz - 1 loop
                  Column := S.Edge_Columns (I); Jv := S.Edge_J (I);
                  S.Spring (Column) := S.Spring (Column) + Jv * Fs;
                  S.Damper (Column) := S.Damper (Column) + Jv * Fd;
               end loop;
            end if;
         end;
      end loop;
   end Edge_Forces;

   procedure Evaluate_Model
     (D : in out Simulation; S : in out Storage; Result : out Status;
      External : MJ.External_Forces.Wrench_Array) is
   begin
      if not Is_Ready (D) then Result := Not_Allocated; return; end if;
      if D.Nv /= S.Nv or else D.Nb /= S.Nb then Result := Invalid_Size; return; end if;
      S.Valid := False;
      -- Rebuild the base passive contribution so repeated Evaluate never
      -- adds elastic forces twice; positions/mass/transmissions remain cached.
      D.Cache.Passive_Valid := False; D.Cache.Force_Valid := False;
      MJ.Data.Forward.Evaluate (D, Result, External);
      if Result /= Success then return; end if;
      Pipeline.Ensure_Jacobians (D, Result);
      if Result /= Success then return; end if;
      Geometry (D, S, Result);
      if Result /= Success then return; end if;
      S.Spring := [others => 0.0]; S.Damper := [others => 0.0];
      for F of S.Flexes loop
         declare Metadata : constant Flex := F; begin
            if not Metadata.Rigid then
               Bending_Forces (D, S, Metadata);
               Stretch_Forces (D, S, Metadata);
            end if;
         end;
      end loop;
      for F of S.Flexes loop
         declare Metadata : constant Flex := F; begin
            if not Metadata.Rigid then Edge_Forces (D, S, Metadata); end if;
         end;
      end loop;
      declare
         Nv : constant Natural := D.Nv;
         P : Real_Array (0 .. Nv - 1);
      begin
         for I in P'Range loop P (I) := D.Dynamics.Passive (I) + (S.Spring (I) + S.Damper (I)); end loop;
         if not MJ.Smooth_Dynamics.Work_Array (P) then Result := Numeric_Limit; return; end if;
         D.Dynamics.Passive.all := P;
      end;
      D.Cache.Force_Valid := False;
      Inertia_Phase.Solve_Acceleration (D, Result, External);
      S.Valid := Result = Success;
   exception
      when Constraint_Error => S.Valid := False; D.Cache.Force_Valid := False; Result := Numeric_Limit;
   end Evaluate_Model;
   procedure Evaluate_Forces
     (D : in out Simulation; Model : in out Force_Model; Result : out Status;
      External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      if Model.S = null then Result := Not_Allocated; return; end if;
      Evaluate_Model (D, Model.S.all, Result, External);
   end Evaluate_Forces;

   procedure Evaluate (E : in out Engine; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      if not Ready (E) then Result := Not_Allocated; return; end if;
      Evaluate_Model (E.D, E.S.all, Result, External);
   end Evaluate;
   procedure Advance (E : in out Engine; Result : out Status) is
      Next_Time, Value : Real;
      Q : Quaternion;
   begin
      Result := Numeric_Limit;
      if not E.D.Activation_Can_Advance then return; end if;
      -- Keep the flex force already included in Dynamics.Total. Re-entering
      -- Euler.Step would recompute the rigid passive force and discard it.
      Inertia_Phase.Solve_Euler (E.D, Result);
      if Result /= Success then return; end if;
      Result := Numeric_Limit;
      Next_Time := E.D.Clock + E.D.Timestep;
      if Next_Time not in Nonneg_Tier0 then return; end if;
      for V in 0 .. E.D.Nv - 1 loop
         Value := E.D.State.Qvel (V) + E.D.Timestep * E.D.Scratch.Solution (V);
         if Value not in Tier0_Real then return; end if;
         E.D.Scratch.Next_Qvel (V) := Value;
      end loop;
      E.D.Scratch.Next_Qpos.all := E.D.State.Qpos.all;
      for P of E.D.Joint_Config.all loop
         if P.Group_Type in 2 .. 3 or else (P.Group_Type = 0 and then P.Component < 3) then
            Value := E.D.State.Qpos (P.Qadr) + E.D.Timestep * E.D.Scratch.Next_Qvel (P.Vadr);
            if Value not in Tier0_Real then return; end if;
            E.D.Scratch.Next_Qpos (P.Qadr) := Value;
         elsif (P.Group_Type = 1 and then P.Component = 0)
           or else (P.Group_Type = 0 and then P.Component = 3) then
            Q := MJ.Manifold_Math.Integrated (Read_Quaternion (E.D.State.Qpos.all, P.Qadr),
              Read_Vector (E.D.Scratch.Next_Qvel.all, P.Vadr), E.D.Timestep);
            for A in 0 .. 3 loop
               if Q (A) not in Tier0_Real then return; end if;
               E.D.Scratch.Next_Qpos (P.Qadr + A) := Q (A);
            end loop;
         end if;
      end loop;
      -- Matching owned-buffer bounds make these assignments total. All
      -- numeric checks and activation staging precede publication.
      E.D.State.Qpos.all := E.D.Scratch.Next_Qpos.all;
      E.D.State.Qvel.all := E.D.Scratch.Next_Qvel.all;
      E.D.Activation (0 .. Integer (E.D.Nactivation) - 1) :=
        E.D.Next_Activation (0 .. Integer (E.D.Nactivation) - 1);
      E.D.Clock := Next_Time;
      Invalidate (E.D.Cache);
      Result := Success;
   end Advance;
   procedure Step (E : in out Engine; Result : out Status;
     External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate (E, Result, External);
      if Result = Success then Advance (E, Result); end if;
      if Result /= Success and then E.S /= null then E.S.Valid := False; end if;
   exception
      when Constraint_Error =>
         if E.S /= null then E.S.Valid := False; end if;
         Result := Numeric_Limit;
   end Step;
end MJ.Data.Flex_Elasticity;
