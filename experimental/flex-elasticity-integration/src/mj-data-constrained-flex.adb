with Ada.Unchecked_Deallocation;
with Interfaces;
with MJ.Contact_Geometry;
with MJ.Validation;
with MJ.Fields;
with MJ.Flex_Contact_Weights;
with MJ.SDF_Kernels;
with MJ.Data.Constrained.Equalities;
with MJ.Data.Constrained.Tendons;
with MJ.Data.Flex_Elasticity.Equalities;

package body MJ.Data.Constrained.Flex with SPARK_Mode is
   use type FS.Status;
   use type RG.Status;
   use type Interfaces.Unsigned_32;
   use type Interfaces.Unsigned_8;
   procedure Release_Int is new Ada.Unchecked_Deallocation (Int_Array, Int_Array_Access);
   function Ready (E : Engine) return Boolean is
     (Constrained.Ready (E.Base) and then FE.Ready (E.Elastic) and then FS.Ready (E.Scene));
   function State (E : Engine) return Real_Array is (Constrained.State (E.Base));
   function Complete_State (E : Engine) return Real_Array is (Constrained.Complete_State (E.Base));
   function Diagnostics (E : Engine) return Trace is (Constrained.Diagnostics (E.Base));
   function Passive (E : Engine) return Real_Array is
     (if Ready (E) then E.Base.D.Dynamics.Passive.all else [0 .. -1 => 0.0]);
   function Contacts (E : Engine) return FS.Contact_Array is (E.Pending.Items (1 .. E.Pending.Length));
   function Equality_Count (E : Engine) return Natural is (Constrained.Equality_Count (E.Base));
   function Equality_Active (E : Engine; Index : Natural) return Boolean is
     (Constrained.Equality_Active (E.Base, Index));
   procedure Set_Equality_Active
     (E : in out Engine; Index : Natural; Active : Boolean; Result : out Status) is
   begin
      Constrained.Set_Equality_Active (E.Base, Index, Active, Result);
   end Set_Equality_Active;
   function Convert (S : FS.Status) return Status is
     (case S is when FS.Success => Success,
       when FS.Capacity_Limit => Capacity_Exceeded,
       when FS.Unsupported_Feature => Unsupported_Feature,
       when FS.Numeric_Limit => Numeric_Limit, when others => Invalid_Model);
   procedure Free (E : in out Engine; Result : out Status) is
   begin
      Constrained.Free (E.Base, Result); FE.Free_Forces (E.Elastic); FS.Free (E.Scene);
      E.Pending.Length := 0; E.Nf := 0; E.Nv := 0;
   end Free;
   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
      Saved_Sizes : constant MJ.Models.Sizes := M.S;
      Saved_Caps : constant Capacities := M.Caps;
      Saved_Adhesion : constant Boolean := M.Flg_Adhesion;
      Saved_Flex, Empty : MJ.Models.Flex_Arrays;
      Saved_Equalities, Empty_Equalities : MJ.Models.Equality_Arrays;
      Saved_Names, Empty_Names : Int_Array_Access := null;
      Saved_Eq_Names, Empty_Eq_Names : Int_Array_Access := null;
      Empty_Sizes : MJ.Models.Sizes;
      Detached : Boolean := False;
      S : FS.Status;
      Types, Dataids : Int_Array (0 .. Max_G-1) := [others => 0];
      Sizes : Real_Array (0 .. 3*Max_G-1) := [others => 0.0];
      Changed : Natural := 0;
      procedure Restore is
      begin
         for G in 0 .. Integer (Changed)-1 loop
            M.Geoms.Geom_Type (G) := Types (G); M.Geoms.Geom_Dataid (G) := Dataids (G);
            for K in 0 .. 2 loop M.Geoms.Geom_Size (3*G+K) := Sizes (3*G+K); end loop;
         end loop;
         Changed := 0;
         if Detached then
            Empty := M.Flexes; Empty_Names := M.Names.Name_Flexadr;
            Empty_Equalities := M.Equalities; Empty_Eq_Names := M.Names.Name_Eqadr;
            M.S := Saved_Sizes; M.Flexes := Saved_Flex; M.Names.Name_Flexadr := Saved_Names;
            M.Equalities := Saved_Equalities; M.Names.Name_Eqadr := Saved_Eq_Names;
            Saved_Flex := (others => <>); Saved_Names := null;
            Saved_Equalities := (others => <>); Saved_Eq_Names := null;
            M.Caps := Saved_Caps; M.Flg_Adhesion := Saved_Adhesion;
         end if;
         Detached := False;
      end Restore;
   begin
      if Constrained.Ready (E.Base) or else FE.Ready (E.Elastic) or else FS.Ready (E.Scene) then
         Result := Already_Allocated; return;
      end if;
      Result := Invalid_Model;
      if not MJ.Models.Valid_Layout (M) then return; end if;
      -- Rigid geom pairs use the shared rigid scene and compiled assets. Flex element contact
      -- response uses ordered body weights; interpolation remains unsupported.
      if M.S.Nflex > FE.Max_Flexes or else M.S.Nflexvert > FE.Max_Vertices
        or else M.S.Ngeom > Max_G then
         Result := Capacity_Exceeded; return;
      end if;
      for G in 0 .. M.S.Ngeom - 1 loop
         if M.Geoms.Geom_Type (G) not in 0 .. 8 then Result := Unsupported_Feature; return; end if;
      end loop;
      for F in 0 .. M.S.Nflex - 1 loop
         if M.Flexes.Flex_Interp (F) /= 0 then Result := Unsupported_Feature; return; end if;
      end loop;
      --  Edge equality rows have an owned producer below. Interpolated vertex
      --  and strain equalities still require their own geometry/admission.
      for Id in 0 .. M.S.Neq-1 loop
         if M.Equalities.Eq_Type (Id) not in 0 .. 4 then
            Result := Unsupported_Feature; return;
         end if;
      end loop;
      FE.Create_Forces (M, E.Elastic, Result);
      if Result /= Success then return; end if;
      FS.Create (M, E.Scene, S); Result := Convert (S);
      if Result /= Success then FE.Free_Forces (E.Elastic); return; end if;
      E.Nf := M.S.Nflex; E.Nv := M.S.Nflexvert;
      for F in 0 .. E.Nf - 1 loop
         E.Address (F) := M.Flexes.Flex_Vertadr (F);
         E.Count (F) := M.Flexes.Flex_Vertnum (F);
         E.Sort_Flex (F) := M.Flexes.Flex_Bvhadr (F) >= 0;
      end loop;
      for G in 0 .. M.S.Ngeom-1 loop
         E.Sort_Geom (G) := M.Bodies.Body_Bvhadr (M.Geoms.Geom_Bodyid (G)) >= 0;
      end loop;
      for V in 0 .. E.Nv - 1 loop E.Bodies (V) := M.Flexes.Flex_Vertbodyid (V); end loop;
      --  The shared rigid state needs the poses/inertias only. FS owns the
      --  actual sampled scene; these proxies never generate SDF contacts.
      for G in 0 .. M.S.Ngeom-1 loop
         Types (G) := M.Geoms.Geom_Type (G); Dataids (G) := M.Geoms.Geom_Dataid (G);
         for K in 0 .. 2 loop Sizes (3*G+K) := M.Geoms.Geom_Size (3*G+K); end loop;
         Changed := G+1;
         if Types (G) = 8 then
            M.Geoms.Geom_Type (G) := 6; M.Geoms.Geom_Dataid (G) := -1;
            for K in 0 .. 2 loop
               M.Geoms.Geom_Size (3*G+K) := MJ.SDF_Kernels.Proxy_Extent
                 (M.Geoms.Geom_Aabb (6*G+K), M.Geoms.Geom_Aabb (6*G+3+K));
            end loop;
         end if;
      end loop;
      MJ.Models.Allocate_Flex (Empty_Sizes, Empty);
      MJ.Models.Allocate_Equality (Empty_Sizes, Empty_Equalities);
      Empty_Names := new Int_Array'(0 .. -1 => 0);
      Empty_Eq_Names := new Int_Array'(0 .. -1 => 0);
      Saved_Flex := M.Flexes; Saved_Names := M.Names.Name_Flexadr;
      Saved_Equalities := M.Equalities; Saved_Eq_Names := M.Names.Name_Eqadr;
      M.Flexes := Empty; M.Names.Name_Flexadr := Empty_Names;
      M.Equalities := Empty_Equalities; M.Names.Name_Eqadr := Empty_Eq_Names;
      Empty := (others => <>); Empty_Names := null; Detached := True;
      Empty_Equalities := (others => <>); Empty_Eq_Names := null; M.S.Neq := 0;
      M.S.Nflex := 0; M.S.Nflexnode := 0; M.S.Nflexvert := 0; M.S.Nflexedge := 0;
      M.S.Nflexelem := 0; M.S.Nflexelemdata := 0; M.S.Nflexstiffness := 0;
      M.S.Nflexbending := 0; M.S.Nflexelemedge := 0; M.S.Nflexshelldata := 0;
      M.S.Nflexevpair := 0; M.S.Nflextexcoord := 0; M.S.NJfe := 0; M.S.NJfv := 0;
      M.S.Nefm0dof := 0; M.S.Nefm0L := 0;
      declare VR : MJ.Fields.Load_Result; begin
         MJ.Validation.Validate (M, (Contact_Cap => Max_C), VR);
         if VR.Status = OK then Constrained.Create (M, E.Base, Result);
         else Result := Invalid_Model; end if;
      end;
      Restore; MJ.Models.Free_Flex (Empty); Release_Int (Empty_Names);
      MJ.Models.Free_Equality (Empty_Equalities); Release_Int (Empty_Eq_Names);
      if Result = Success then
         --  Recover tendon requirements and all equality metadata from the
         --  original model after the specialized factory restores ownership.
         MJ.Data.Constrained.Tendons.Initialize (M, E.Base, Result);
         if Result = Success then
            MJ.Data.Constrained.Equalities.Initialize (M, E.Base, Result, Allow_Flex => True);
         end if;
      end if;
      if Result /= Success then
         declare Failure : constant Status := Result; begin Free (E, Result); Result := Failure; end;
      end if;
   exception
      when others =>
         Restore; MJ.Models.Free_Flex (Empty); Release_Int (Empty_Names);
         MJ.Models.Free_Equality (Empty_Equalities); Release_Int (Empty_Eq_Names);
         Free (E, Result); raise;
   end Create;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status) is
   begin Constrained.Set_State (E.Base, Qpos, Qvel, New_Time, Result); end Set_State;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin Constrained.Set_Activation (E.Base, Values, Result); end Set_Activation;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin Constrained.Set_Control (E.Base, Index, Value, Result); end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin Constrained.Set_Applied_Force (E.Base, Index, Value, Result); end Set_Applied_Force;
   procedure Flex_Side (S : FS.State; F, Element, Vertex, Opposite : Integer;
                        Point : RG.Vec; Side : out Weighted_Side; Result : out Status) is
      package CW renames MJ.Flex_Contact_Weights;
      Raw : CW.Weights := [others => 0.0];
      Remove : Natural := 0;
      Normalized : Boolean;
   begin
      Side := (others => <>); Result := Invalid_Index;
      if F not in 0 .. Integer (FS.Flex_Count (S))-1 then return; end if;
      if Vertex >= 0 then
         if Vertex >= FS.Vertex_Count (S,F) then return; end if;
         Side.Items (1) := (FS.Vertex_Body (S,F,Vertex), 1.0);
         Result := Success; return;
      end if;
      if Element not in 0 .. Integer (FS.Element_Count (S,F))-1 then return; end if;
      Side.Count := FS.Dimension (S,F)+1;
      for K in 1 .. Side.Count loop
         declare V : constant Natural := FS.Element_Vertex (S,F,Element,K-1); begin
            if V >= FS.Vertex_Count (S,F) then return; end if;
            Side.Items (K).Body_Id := FS.Vertex_Body (S,F,V);
            Raw (K) := CW.Inverse_Distance (CW.Point (Point),CW.Point (FS.Position (S,F,V)));
            if V = Opposite then Remove := K; end if;
         end;
      end loop;
      -- Match mj_elemBodyWeight: remove only the last matching opposite
      -- vertex, shift remaining entries, then normalize in retained order.
      if Remove > 0 then
         for K in Remove .. Side.Count-1 loop
            Side.Items (K) := Side.Items (K+1); Raw (K) := Raw (K+1);
         end loop;
         Side.Count := Side.Count-1;
      end if;
      CW.Normalize (Raw, Side.Count, Normalized);
      if not Normalized then Result := Numeric_Limit; return; end if;
      for K in 1 .. Side.Count loop Side.Items (K).Weight := Raw (K); end loop;
      Result := Success;
   end Flex_Side;
   procedure Assemble_Flex (E : in out Engine; Result : out Status) is
      package EQ renames MJ.Data.Constrained.Equalities;
      package FX renames MJ.Data.Flex_Elasticity.Equalities;
   begin
      Begin_Assembly (E.Base, Result);
      if Result /= Success then return; end if;
      if not Disabled (E.Base.Flags, Dsbl_Constraint)
        and then not Disabled (E.Base.Flags, Dsbl_Equality) then
         EQ.Prepare (E.Base, Result);
         if Result /= Success then return; end if;
         --  Keep the original mixed equality order and IDs. The force pass
         --  has already updated flex lengths and the shared edge CSR cache.
         for Id in 0 .. E.Base.Ne-1 loop
            if E.Base.Equalities (Id).Active then
               if E.Base.Equalities (Id).Kind = 4 then
                  declare First : constant Positive := E.Base.Rows.Rows+1; begin
                     FX.Append_Edges (E.Elastic, E.Base.Equalities (Id).Object0, Id,
                       E.Base.Rows, E.Equality_Responses, Result, E.Base.Settings.Sparse);
                     if Result /= Success then return; end if;
                     for R in First .. E.Base.Rows.Rows loop
                        E.Base.Equality_Weights (R) := E.Equality_Responses (R).Weight;
                     end loop;
                  end;
               else
                  EQ.Assemble_One (E.Base, Id, Result);
                  if Result /= Success then return; end if;
               end if;
            end if;
         end loop;
      end if;
      Finish_Assembly (E.Base, Result);
   end Assemble_Flex;
   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
      Nb : constant Natural := E.Base.D.Nb;
      Ng : constant Natural := E.Base.Ng;
      Bodies : RG.Pose_Array (0 .. Integer (Nb) - 1);
      Geoms : RG.Pose_Array (0 .. Integer (Ng) - 1);
      S : FS.Status;
      R : RG.Status;
      M : MJ.Contact_Geometry.Manifold;
      Full : MJ.Full_Contacts.Full_Manifold;
      Rigid_Count : Natural;
      type Keys is array (Natural range 0 .. Max_C-1) of Natural;
      First_Key, Second_Key : Keys := [others => 0];
      Object0_Key, Object1_Key : Keys := [others => 0];
   begin
      E.Base.T.Valid := False; E.Base.T.Ncontact := 0; E.Pending.Length := 0;
      if not Ready (E) then Result := Not_Allocated; return; end if;
      FE.Evaluate_Forces (E.Base.D, E.Elastic, Result, External);
      if Result /= Success then return; end if;
      if Disabled (E.Base.Flags, Dsbl_Constraint) then
         Assemble_Flex (E, Result);
         if Result = Success then Prepare_And_Solve (E.Base, Result); end if;
         return;
      end if;
      Generate_Geom_Poses (E.Base, Geoms, Result);
      if Result /= Success then return; end if;
      if FS.Has_SDF (E.Scene) then
         FS.Generate_Rigid_Contacts (E.Scene,Geoms,E.Base.Contacts,E.Base.T.Ncontact,S);
         if S /= FS.Success then Result := Convert (S); return; end if;
      else
         MJ.Collision_Scene.Generate (E.Base.Scene,Geoms,
        E.Base.Assets.Vertices.all,E.Base.Assets.Facets.all,
        E.Base.Assets.Elevations.all,E.Base.Assets.Graphs.all,
        E.Base.Contacts,E.Base.T.Ncontact,R,E.Base.Assets.Incidence);
      if R /= RG.Success then Result := Numeric_Limit; return; end if;
      end if;
      Set_Rigid_Contact_Endpoints (E.Base,Result);
      if Result /= Success then return; end if;
      Rigid_Count := E.Base.T.Ncontact;
      for Id in 0 .. Integer (Rigid_Count)-1 loop
         First_Key (Id) := Natural'Min (E.Base.Endpoints (Id).Body0,E.Base.Endpoints (Id).Body1);
         Second_Key (Id) := Natural'Max (E.Base.Endpoints (Id).Body0,E.Base.Endpoints (Id).Body1);
      end loop;
      for B in Bodies'Range loop
         Bodies (B).Position := RG.Vec (E.Base.D.Kinematic.Bodies (B).Position);
         for I in RG.Axis loop
            for J in RG.Axis loop
               Bodies (B).Rotation (3 * I + J) := E.Base.D.Kinematic.Bodies (B).Rotation (I, J);
            end loop;
         end loop;
      end loop;
      FS.Update (E.Scene, Bodies, S, Geoms);
      if S /= FS.Success then Result := Convert (S); return; end if;
      FS.Detect (E.Scene, E.Pending, S);
      if S /= FS.Success then Result := Convert (S); return; end if;
      if E.Pending.Length > Max_C-Rigid_Count then Result := Capacity_Exceeded; return; end if;
      E.Base.T.Ncontact := Rigid_Count+E.Pending.Length;
      for Offset in 0 .. Integer (E.Pending.Length) - 1 loop
         declare
            Id : constant Natural := Rigid_Count+Offset;
            C : constant FS.Contact := E.Pending.Items (Offset+1);
            Side0, Side1 : Weighted_Side;
         begin
            if C.Geom >= 0 then
               if C.Geom >= Ng then Result := Invalid_Index; return; end if;
               Side0 := (Count => 1,Items => [1 => (E.Base.Geoms (C.Geom).Body_Id,1.0),others => <>]);
            else
               Flex_Side (E.Scene,C.Flex_First,C.Elem_First,C.Vert_First,C.Vert_Second,
                 C.Geometry.Position,Side0,Result);
               if Result /= Success then return; end if;
            end if;
            Flex_Side (E.Scene,C.Flex_Second,C.Elem_Second,C.Vert_Second,C.Vert_First,
              C.Geometry.Position,Side1,Result);
            if Result /= Success then return; end if;
            M.Length := 1; M.Items (0) := C.Geometry;
            -- Geoms is legacy rigid diagnostic metadata. Endpoints below
            -- supply the actual body and optional geom identities to response.
            MJ.Full_Contacts.Finalize (M, C.Parameters, (Natural'Max (0,C.Geom), Natural'Max (0,C.Geom)), Full, R);
            if R /= RG.Success then Result := Numeric_Limit; return; end if;
            E.Base.Contacts (Id) := Full.Items (0);
            if (C.Geom >= 0 or else C.Vert_First >= 0) and then C.Vert_Second >= 0 then
               Set_Contact_Endpoints (E.Base, Id, Side0.Items (1).Body_Id,
                 Side1.Items (1).Body_Id, C.Geom, -1, Result);
            else
               Set_Weighted_Contact_Endpoints (E.Base,Id,Side0,Side1,C.Geom,-1,Result);
            end if;
            if Result /= Success then return; end if;
            if C.Geom = -1 and then C.Flex_First = C.Flex_Second then
               -- C emits all self contacts after all body/flex pair contacts.
               First_Key (Id) := Nb+E.Nf; Second_Key (Id) := C.Flex_First;
            else
               First_Key (Id) := (if C.Geom >= 0 then E.Base.Geoms (C.Geom).Body_Id else Nb+C.Flex_First);
               Second_Key (Id) := Nb+C.Flex_Second;
               -- C sorts the midphase batch by geom/element/vertex IDs after
               -- traversal and contact filtering, retaining order within an
               -- object pair. Linear and self collision batches are unsorted.
               if not Disabled (E.Base.Flags, Dsbl_Midphase)
                 and then E.Sort_Flex (C.Flex_Second)
                 and then (if C.Geom >= 0 then E.Sort_Geom (C.Geom)
                           else E.Sort_Flex (C.Flex_First))
               then
                  Object0_Key (Id) := (if C.Geom >= 0 then C.Geom
                    elsif C.Elem_First >= 0 then C.Elem_First else C.Vert_First);
                  Object1_Key (Id) := (if C.Elem_Second >= 0 then C.Elem_Second else C.Vert_Second);
               end if;
            end if;
         end;
      end loop;
      -- C orders the combined body/flex pairs lexicographically. Stable
      -- insertion then applies C's optional object-ID sort within that pair.
      -- All per-contact metadata must move with the contact itself.
      for I in 1 .. Integer (E.Base.T.Ncontact)-1 loop
         declare
            Contact : constant MJ.Full_Contacts.Full_Contact := E.Base.Contacts (I);
            Endpoints : constant Contact_Endpoints := E.Base.Endpoints (I);
            Weights : constant Weighted_Contact := E.Base.Contact_Weights (I);
            K0 : constant Natural := First_Key (I);
            K1 : constant Natural := Second_Key (I);
            K2 : constant Natural := Object0_Key (I);
            K3 : constant Natural := Object1_Key (I);
            J : Natural := I;
         begin
            while J > 0 and then (First_Key (J-1) > K0 or else
              (First_Key (J-1) = K0 and then (Second_Key (J-1) > K1 or else
                (Second_Key (J-1) = K1 and then (Object0_Key (J-1) > K2 or else
                  (Object0_Key (J-1) = K2 and then Object1_Key (J-1) > K3)))))) loop
               E.Base.Contacts (J) := E.Base.Contacts (J-1);
               E.Base.Endpoints (J) := E.Base.Endpoints (J-1);
               E.Base.Contact_Weights (J) := E.Base.Contact_Weights (J-1);
               First_Key (J) := First_Key (J-1); Second_Key (J) := Second_Key (J-1);
               Object0_Key (J) := Object0_Key (J-1); Object1_Key (J) := Object1_Key (J-1);
               J := J-1;
            end loop;
            E.Base.Contacts (J) := Contact; E.Base.Endpoints (J) := Endpoints;
            E.Base.Contact_Weights (J) := Weights;
            First_Key (J) := K0; Second_Key (J) := K1;
            Object0_Key (J) := K2; Object1_Key (J) := K3;
         end;
      end loop;
      Assemble_Flex (E, Result);
      if Result = Success then Prepare_And_Solve (E.Base, Result); end if;
   exception
      when Constraint_Error => E.Base.T.Valid := False; Result := Numeric_Limit;
   end Evaluate;
   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate (E, Result, External);
      if Result = Success then Advance (E.Base, Result); end if;
   end Step;
end MJ.Data.Constrained.Flex;
