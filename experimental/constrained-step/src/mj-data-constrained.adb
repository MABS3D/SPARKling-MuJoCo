with Interfaces;
with MJ.Data.Constrained.Body_Adhesion;
with MJ.Models.Validity;
with MJ.Data.Forward;
with MJ.Data.Pipeline;
with MJ.Data.Inertia_Phase;
with MJ.Owned_Step_Publication;
with MJ.Contact_Geometry;
with MJ.Contact_Parameters;
with MJ.Heightfield_Contacts;
with MJ.Joint_Limits;
with MJ.Joint_Limit_Math;
with MJ.Constrained_Kernels;
with MJ.Constraint_Solvers.Native_Inertia;
with MJ.Data.Constrained.Tendons;
with MJ.Data.Constrained.Equalities;
with MJ.Elliptic_Response;

package body MJ.Data.Constrained with SPARK_Mode is
   package Scene renames MJ.Collision_Scene;
   package CG renames MJ.Contact_Geometry;
   package CP renames MJ.Contact_Parameters;
   package JL renames MJ.Joint_Limits;
   package NI renames MJ.Constraint_Solvers.Native_Inertia;
   package CK renames MJ.Constrained_Kernels;
   package Step_Publication renames MJ.Owned_Step_Publication;
   package SV renames MJ.Surface_Velocity;
   use type RG.Status, CA.Result, CA.Constraint_Kind, CA.Cone_Kind, CS.Status, CS.Method, JL.Status;
   use type Interfaces.Unsigned_32, Interfaces.Unsigned_8;

   function Disabled (Flags, Flag : Integer) return Boolean is
     (Flags >= 0 and then (Flags / Flag) mod 2 = 1);
   function Ready (E : Engine) return Boolean is
     (E.Initialized and then Is_Ready (E.D) and then MJ.Constrained_Assets.Loaded (E.Assets));
   function State (E : Engine) return Real_Array is (State_Values (E.D));
   function Complete_State (E : Engine) return Real_Array is (Complete_State_Values (E.D));
   function Activation_Count (E : Engine) return Natural is (MJ.Data.Activation_Count (E.D));
   function Activation_Values (E : Engine) return Real_Array is (MJ.Data.Activation_Values (E.D));
   function Activation_Rates (E : Engine) return Real_Array is (MJ.Data.Activation_Rates (E.D));
   function Diagnostics (E : Engine) return Trace is (E.T);
   function Adhesion_Moment (E : Engine; Index : Natural) return Real_Array is
     (if Index < E.D.Na and then E.D.Actuator_Config (Index).Body_Transmission then
        [for V in 0 .. E.D.Nv - 1 => E.Body_Moments (Index+1, V+1)]
      else [0 .. E.D.Nv - 1 => 0.0]);
   function Actuator_Forces (E : Engine) return Real_Array is (E.D.Actuators.Force.all);
   function Actuator_Velocities (E : Engine) return Real_Array is (E.D.Actuators.Velocity.all);
   function Equality_Count (E : Engine) return Natural is (E.Ne);
   function Equality_Active (E : Engine; Index : Natural) return Boolean is
     (E.Equalities (Index).Active);
   procedure Set_Equality_Active
     (E : in out Engine; Index : Natural; Active : Boolean; Result : out Status) is
   begin
      if not Ready (E) then Result := Not_Allocated;
      elsif Index >= E.Ne then Result := Invalid_Index;
      else
         E.Equalities (Index).Active := Active;
         E.T.Valid := False; Result := Success;
      end if;
   end Set_Equality_Active;

   function Asset_Status (S : MJ.Constrained_Assets.Status) return Status is
     (case S is
        when MJ.Constrained_Assets.Success => Success,
        when MJ.Constrained_Assets.Invalid_Model => Invalid_Model,
        when MJ.Constrained_Assets.Capacity_Exceeded => Capacity_Exceeded,
        when MJ.Constrained_Assets.Unsupported_Feature => Unsupported_Feature);

   function Parameters (Ref, Imp : Real_Array; Id : Natural) return LR.Parameters is
   begin
      return (Ref (2 * Id), Ref (2 * Id + 1), Imp (5 * Id), Imp (5 * Id + 1),
        Imp (5 * Id + 2), Imp (5 * Id + 3), Imp (5 * Id + 4));
   end Parameters;

   procedure Create (M : in out MJ.Models.Model; E : in out Engine; Result : out Status) is
   begin
      Create_Core (M, E, Result, Dynamics_Only => False);
   end Create;

   procedure Create_Core (M : in out MJ.Models.Model; E : in out Engine;
                          Result : out Status; Dynamics_Only : Boolean) is
      Original_Flags : constant Integer := M.Opt.Disableflags;
      Original_Adhesion : constant Boolean := M.Flg_Adhesion;
      Shapes : Scene.Geometry_Array (0 .. Max_G - 1);
      Empty_Pairs : Scene.Declared_Array (1 .. 0);
      Empty_Exclusions : RG.Exclusion_Array (1 .. 0);
      S : RG.Status;
      Asset_Result : MJ.Constrained_Assets.Status;
   begin
      if not Is_Empty (E.D) then Result := Already_Allocated; return; end if;
      E.Ne := 0;
      MJ.Constrained_Assets.Release (E.Assets);
      Result := Invalid_Model;
      if not MJ.Models.Validity.Is_Valid (M) then return; end if;
      Result := Unsupported_Feature;
      --  Explicit first integrated domain; never discard an enabled feature.
      if M.S.Nv not in 1 .. Max_V or else M.S.Ngeom > Max_G
        or else M.S.Njnt > Max_V or else M.S.Nbody > Max_Bodies then Result := Capacity_Exceeded; return; end if;
      if M.S.Nflex /= 0
        or else M.S.Nplugin /= 0 or else M.S.Nhistory /= 0 or else M.S.Npair /= 0
        or else M.S.Nexclude /= 0
        or else M.Opt.Integrator /= 0
        or else M.Opt.Cone not in 0 .. 1 or else M.Opt.Noslip_Iterations /= 0
        or else M.Opt.Enableflags /= 0
        or else not Disabled (M.Opt.Disableflags, Dsbl_Warmstart)
        or else not Disabled (M.Opt.Disableflags, Dsbl_Island)
        or else M.Opt.Solver not in 0 .. 2
        or else M.Opt.Iterations not in 0 .. 100_000
        or else M.Opt.Ls_Iterations not in 1 .. 1_000
        or else M.Opt.Impratio not in 1.0e-10 .. 1.0e10
        or else M.Stat.Meaninertia <= 0.0
        or else (M.S.Nsensor > 0 and then not Disabled (M.Opt.Disableflags, Dsbl_Sensor))
      then return; end if;
      MJ.Data.Constrained.Tendons.Initialize (M, E, Result);
      if Result /= Success then return; end if;
      E.Flags := M.Opt.Disableflags;
      E.Has_Surface_Velocity := M.Flg_Surfacevel;
      E.Cone := CA.Cone_Kind'Val (M.Opt.Cone);
      E.Impratio := M.Opt.Impratio;
      E.Settings := (Algorithm => CS.Method'Val (M.Opt.Solver),
        Sparse => M.Opt.Jacobian = 1 or else (M.Opt.Jacobian = 2 and then M.S.Nv >= 60),
        Iterations => M.Opt.Iterations, LS_Iterations => M.Opt.Ls_Iterations,
        Tolerance => M.Opt.Tolerance, LS_Tolerance => M.Opt.Ls_Tolerance,
        Scale => 1.0 / (M.Stat.Meaninertia * Real (M.S.Nv)));
      E.Ng := M.S.Ngeom; E.Nj := M.S.Njnt;
      MJ.Constrained_Assets.Load (M, E.Assets, Asset_Result);
      Result := Asset_Status (Asset_Result);
      if Result /= Success then return; end if;
      for B in 0 .. M.S.Nbody - 1 loop
         E.Bodies (B) := (Leaf => (if M.Bodies.Body_Dofnum (B) > 0
           then M.Bodies.Body_Dofadr (B) + M.Bodies.Body_Dofnum (B) - 1
           elsif B = 0 then -1 else E.Bodies (M.Bodies.Body_Parentid (B)).Leaf),
           Translation => M.Bodies.Body_Invweight0 (2 * B),
           Rotation => M.Bodies.Body_Invweight0 (2 * B + 1));
      end loop;
      for I in 0 .. M.S.Nv - 1 loop
         E.Dofs (I) := (M.Dofs.Dof_Parentid (I), M.Dofs.Dof_Frictionloss (I),
           M.Dofs.Dof_Invweight0 (I), Parameters (M.Dofs.Dof_Solref.all, M.Dofs.Dof_Solimp.all, I));
      end loop;
      for I in 0 .. E.Nj - 1 loop
         E.Joints (I) := (Kind => Joint_Kind'Val (M.Joints.Jnt_Type (I)),
           Qadr => M.Joints.Jnt_Qposadr (I), Vadr => M.Joints.Jnt_Dofadr (I),
           Is_Limited => M.Joints.Jnt_Limited (I) /= 0,
           Low => M.Joints.Jnt_Range (2 * I), High => M.Joints.Jnt_Range (2 * I + 1),
           Margin => M.Joints.Jnt_Margin (I),
           Params => Parameters (M.Joints.Jnt_Solref.all, M.Joints.Jnt_Solimp.all, I));
      end loop;
      for G in 0 .. E.Ng - 1 loop
         declare
            B : constant Natural := M.Geoms.Geom_Bodyid (G);
            W : constant Natural := M.Bodies.Body_Weldid (B);
            K : constant Integer := M.Geoms.Geom_Type (G);
            Q : constant Quaternion := Read_Quaternion (M.Geoms.Geom_Quat.all, 4 * G);
         begin
            if K not in 0 .. 7 then
               MJ.Constrained_Assets.Release (E.Assets);
               Result := Unsupported_Feature; return;
            end if;
            E.Geoms (G) := (Body_Id => B,
              Position => Read_Vector (M.Geoms.Geom_Pos.all, 3 * G), Orientation => Q,
              Same_Frame => Natural (M.Geoms.Geom_Sameframe (G)),
              Surface => [for K in 0 .. 5 => M.Geoms.Geom_Surfacevel (6 * G + K)],
              others => <>);
            Shapes (G).Solid.Rigid :=
              (Kind => RG.Shape_Kind'Val ((if K = 0 then 0 elsif K in 1 | 7 then 5 else K - 1)),
               Size => RG.Vec (Read_Vector (M.Geoms.Geom_Size.all, 3 * G)),
               Body_Id => B, Weld => W,
               Weld_Parent => M.Bodies.Body_Weldid (M.Bodies.Body_Parentid (W)),
               Dynamic => W /= 0,
               Contype => Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Contype (G)),
               Conaffinity => Interfaces.Unsigned_32'Mod (M.Geoms.Geom_Conaffinity (G)),
               Margin => M.Geoms.Geom_Margin (G), Gap => M.Geoms.Geom_Gap (G));
            Shapes (G).Surface := (Priority => M.Geoms.Geom_Priority (G),
              Dim => M.Geoms.Geom_Condim (G), Mix => M.Geoms.Geom_Solmix (G),
              Ref => [for I in 0 .. 1 => M.Geoms.Geom_Solref (2 * G + I)],
              Imp => [for I in 0 .. 4 => M.Geoms.Geom_Solimp (5 * G + I)],
              Fri => [for I in 0 .. 2 => M.Geoms.Geom_Friction (3 * G + I)],
              Adhesion => 0.0);
            if not CP.Valid (Shapes (G).Surface) then
               MJ.Constrained_Assets.Release (E.Assets);
               Result := Invalid_Model; return;
            end if;
            MJ.Constrained_Assets.Configure (M, G, E.Assets, Shapes (G), Asset_Result);
            Result := Asset_Status (Asset_Result);
            if Result /= Success then MJ.Constrained_Assets.Release (E.Assets); return; end if;
            declare
               P : constant LR.Parameters := Parameters (M.Geoms.Geom_Solref.all, M.Geoms.Geom_Solimp.all, G);
            begin null; end;
         end;
      end loop;
      MJ.Data.Constrained.Equalities.Initialize (M, E, Result);
      if Result /= Success then MJ.Constrained_Assets.Release (E.Assets); return; end if;
      Scene.Initialize (E.Scene, Shapes (0 .. E.Ng - 1), E.Assets.Vertices.all,
        E.Assets.Elevations.all, E.Assets.Graphs.all,
        Empty_Pairs, Empty_Exclusions,
        (Filter_Parent => not Disabled (E.Flags, Dsbl_Filterparent),
         Enabled => not Disabled (E.Flags, Dsbl_Contact) and then not Disabled (E.Flags, Dsbl_Constraint),
         Sleep_Filter => False, Tolerance => M.Opt.Ccd_Tolerance,
         Iterations => M.Opt.Ccd_Iterations), (others => <>), S);
      if S /= RG.Success then
         MJ.Constrained_Assets.Release (E.Assets); Result := Invalid_Model; return;
      end if;
      --  Exclusive in-out borrow during initialization. The smooth subengine
      --  handles free dynamics; this wrapper owns all admitted constraints.
      --  Restore the caller's flags on every exit, without aliasing model
      --  ownership through a shallow copy of its access-valued fields.
      if not Disabled (M.Opt.Disableflags, Dsbl_Constraint) then
         M.Opt.Disableflags := M.Opt.Disableflags + Dsbl_Constraint;
      end if;
      -- This entry owns the contact-dependent transmission; restore the
      -- exclusively borrowed feature flag on every exit.
      M.Flg_Adhesion := False;
      if Dynamics_Only then
         MJ.Data.Create_Dynamics (M, E.D, Result);
      else
         MJ.Data.Create (M, E.D, Result);
      end if;
      M.Flg_Adhesion := Original_Adhesion;
      E.Has_Adhesion := False;
      if Result = Success then
         for C of E.D.Actuator_Config.all loop
            E.Has_Adhesion := E.Has_Adhesion or else C.Body_Transmission;
         end loop;
      end if;
      M.Opt.Disableflags := Original_Flags;
      E.Initialized := Result = Success;
      E.T.Valid := False;
      if Result /= Success then MJ.Constrained_Assets.Release (E.Assets); end if;
   exception
      when Constraint_Error =>
         M.Flg_Adhesion := Original_Adhesion;
         M.Opt.Disableflags := Original_Flags;
         MJ.Constrained_Assets.Release (E.Assets);
         MJ.Data.Free (E.D); E.Initialized := False; Result := Unsupported_Feature;
      when others =>
         M.Flg_Adhesion := Original_Adhesion;
         M.Opt.Disableflags := Original_Flags;
         MJ.Constrained_Assets.Release (E.Assets); raise;
   end Create_Core;

   procedure Free (E : in out Engine; Result : out Status) is
   begin
      MJ.Constrained_Assets.Release (E.Assets);
      E.Ne := 0;
      MJ.Data.Free (E.D); E.Initialized := False; E.T.Valid := False; Result := Success;
   end Free;
   procedure Set_State (E : in out Engine; Qpos, Qvel : State_Vector;
                        New_Time : Nonneg_Tier0; Result : out Status) is
   begin
      MJ.Data.Set_State (E.D, Qpos, Qvel, New_Time, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_State;
   procedure Set_Activation (E : in out Engine; Values : State_Vector; Result : out Status) is
   begin
      MJ.Data.Set_Activation (E.D, Values, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_Activation;
   function Mocap_Count (E : Engine) return Natural is (MJ.Data.Mocap_Count (E.D));
   function Mocap_Values (E : Engine) return Real_Array is (MJ.Data.Mocap_Values (E.D));
   procedure Set_Mocap (E : in out Engine; Index : Natural;
                        Position, Quaternion : State_Vector; Result : out Status) is
   begin
      MJ.Data.Set_Mocap (E.D, Index, Position, Quaternion, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_Mocap;
   procedure Set_Control (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Control (E.D, Index, Value, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_Control;
   procedure Set_Applied_Force (E : in out Engine; Index : Natural; Value : Tier0_Real; Result : out Status) is
   begin
      MJ.Data.Set_Applied_Force (E.D, Index, Value, Result);
      if Result = Success then E.T.Valid := False; end if;
   end Set_Applied_Force;

   procedure Generate_Geom_Poses
     (E : in out Engine; Poses : out RG.Pose_Array; Result : out Status) is
   begin
      Result := Invalid_Size;
      if Poses'First /= 0 or else Poses'Length /= E.Ng then return; end if;
      for G in Poses'Range loop
         declare
            B : constant Body_State := E.D.Kinematic.Bodies (E.Geoms (G).Body_Id);
            Local_Geom : constant Geom_Description := E.Geoms (G);
            World_Rotation : Matrix;
         begin
            --  Preserve mj_local2Global's floating-point order and frame
            --  shortcuts. Multiplying two rotation matrices changes clipping
            --  decisions even when their entries differ by only a few ULPs.
            case Local_Geom.Same_Frame is
               when 1 => Poses (G).Position := RG.Vec (B.Position);
               when 2 => Poses (G).Position := RG.Vec (B.Center);
               when others =>
                  Poses (G).Position := RG.Vec (Apply (B.Rotation, Local_Geom.Position) + B.Position);
            end case;
            case Local_Geom.Same_Frame is
               when 0 =>
                  declare
                     Q : constant Quaternion := Multiply (B.Orientation, Local_Geom.Orientation);
                  begin
                     if not Unit_Quaternion (Q) then Result := Numeric_Limit; return; end if;
                     World_Rotation := Rotation (Q);
                  end;
               when 1 | 3 => World_Rotation := B.Rotation;
               when 2 | 4 => World_Rotation := B.Inertial_Rotation;
            end case;
            for I in 0 .. 2 loop
               for J in 0 .. 2 loop
                  Poses (G).Rotation (3 * I + J) := World_Rotation (I, J);
               end loop;
            end loop;
            if E.Has_Surface_Velocity and then SV.Active (E.Geoms (G).Surface) then
               E.Geoms (G).Surface_Pose :=
                 (SV.Vector (Poses (G).Position), [for I in 0 .. 8 => Poses (G).Rotation (I)]);
            end if;
         end;
      end loop;
      Result := Success;
   end Generate_Geom_Poses;

   procedure Set_Contact_Endpoints
     (E : in out Engine; Id, Body0, Body1 : Natural;
      Geom0, Geom1 : Integer; Result : out Status) is
   begin
      Result := Invalid_Index;
      if Id >= E.T.Ncontact or else Id >= Max_C or else Body0 >= E.D.Nb
        or else Body1 >= E.D.Nb or else Body0 not in E.Bodies'Range
        or else Body1 not in E.Bodies'Range
        or else Geom0 not in -1 .. Max_G - 1 or else Geom1 not in -1 .. Max_G - 1
        or else Geom0 not in -1 .. Integer (E.Ng) - 1
        or else Geom1 not in -1 .. Integer (E.Ng) - 1 then return; end if;
      if (Geom0 >= 0 and then E.Geoms (Geom0).Body_Id /= Body0)
        or else (Geom1 >= 0 and then E.Geoms (Geom1).Body_Id /= Body1) then return; end if;
      E.Endpoints (Id) := (Body0, Body1, Geom0, Geom1);
      E.Contact_Weights (Id).Active := False;
      Result := Success;
   end Set_Contact_Endpoints;

   procedure Set_Weighted_Contact_Endpoints
     (E : in out Engine; Id : Natural; Side0, Side1 : Weighted_Side;
      Geom0, Geom1 : Integer; Result : out Status) is
      function Valid_Side (Side : Weighted_Side; Geom : Integer) return Boolean is
      begin
         if Side.Count not in 1 .. 4 or else Geom not in -1 .. Max_G - 1
           or else Geom not in -1 .. Integer (E.Ng) - 1 then return False; end if;
         for K in 1 .. Side.Count loop
            if Side.Items (K).Body_Id >= E.D.Nb
              or else Side.Items (K).Body_Id not in E.Bodies'Range
              or else Side.Items (K).Weight not in 0.0 .. 2.0
              or else Side.Items (K).Weight = 0.0 then return False; end if;
         end loop;
         return Geom = -1 or else (Side.Count = 1 and then Side.Items (1).Weight = 1.0
           and then E.Geoms (Geom).Body_Id = Side.Items (1).Body_Id);
      end Valid_Side;
   begin
      Result := Invalid_Index;
      if Id >= E.T.Ncontact or else Id >= Max_C
        or else not Valid_Side (Side0, Geom0) or else not Valid_Side (Side1, Geom1) then return; end if;
      Set_Contact_Endpoints (E, Id, Side0.Items (1).Body_Id, Side1.Items (1).Body_Id,
        Geom0, Geom1, Result);
      if Result = Success then E.Contact_Weights (Id) := (True, Side0, Side1); end if;
   end Set_Weighted_Contact_Endpoints;

   procedure Set_Rigid_Contact_Endpoints (E : in out Engine; Result : out Status) is
   begin
      Result := Invalid_Index;
      if E.T.Ncontact > Max_C then return; end if;
      for Id in 0 .. Integer (E.T.Ncontact) - 1 loop
         declare
            G0 : constant Natural := E.Contacts (Id).Geoms.First;
            G1 : constant Natural := E.Contacts (Id).Geoms.Second;
         begin
            if G0 >= E.Ng or else G1 >= E.Ng then return; end if;
            Set_Contact_Endpoints (E, Id, E.Geoms (G0).Body_Id,
              E.Geoms (G1).Body_Id, G0, G1, Result);
            if Result /= Success then return; end if;
         end;
      end loop;
      Result := Success;
   end Set_Rigid_Contact_Endpoints;

   procedure Generate_Contacts (E : in out Engine; Result : out Status) is
      Ng : constant Natural := E.Ng;
      Poses : RG.Pose_Array (0 .. Ng - 1);
      S : RG.Status;
   begin
      Generate_Geom_Poses (E, Poses, Result);
      if Result /= Success then return; end if;
      Scene.Generate (E.Scene, Poses, E.Assets.Vertices.all, E.Assets.Facets.all,
        E.Assets.Elevations.all, E.Assets.Graphs.all,
        E.Contacts, E.T.Ncontact, S, E.Assets.Incidence);
      Result := (case S is when RG.Success => Success,
        when RG.Capacity_Limit => Capacity_Exceeded, when others => Numeric_Limit);
      if Result = Success then Set_Rigid_Contact_Endpoints (E, Result); end if;
   end Generate_Contacts;

   -- Sparse mj_jacSum: preserve body order, retain common ancestors and
   -- duplicate bodies, then project the completed world Jacobian into frame.
   procedure Weighted_Contact_Jacobian
     (E : Engine; Id : Natural; Chain : out CA.Column_Array;
      J : out CA.Matrix; N : out Natural) is
      C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
      Seen : array (Natural range 0 .. Max_V - 1) of Boolean := [others => False];
      World : CA.Matrix (1 .. 6, 1 .. Max_V) := [others => [others => 0.0]];
      procedure Accumulate (Side : Weighted_Side; Sign : Real) is
      begin
         for K in 1 .. Side.Count loop
            declare
               Body_Id : constant Natural := Side.Items (K).Body_Id;
               Weight : constant Real := Sign * Side.Items (K).Weight;
               V : Integer := E.Bodies (Body_Id).Leaf;
               Offset : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (Body_Id).Center;
            begin
               while V >= 0 loop
                  declare
                     O : constant Natural := Jacobian_Offset (E.D, Body_Id, V);
                     Angular : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O);
                     Linear : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O);
                     Point : Vector;
                  begin
                     for X in 0 .. 2 loop
                        Point (X) := CK.Point_Component (Linear (X), Angular ((X+1) mod 3),
                          Angular ((X+2) mod 3), Offset ((X+1) mod 3), Offset ((X+2) mod 3));
                        if Seen (V) then
                           World (X+1, V+1) := World (X+1, V+1) + Weight * Point (X);
                           World (X+4, V+1) := World (X+4, V+1) + Weight * Angular (X);
                        else
                           World (X+1, V+1) := Weight * Point (X);
                           World (X+4, V+1) := Weight * Angular (X);
                        end if;
                     end loop;
                     Seen (V) := True;
                  end;
                  V := E.Dofs (V).Parent;
               end loop;
            end;
         end loop;
      end Accumulate;
   begin
      Chain := [others => 0]; J := [others => [others => 0.0]]; N := 0;
      Accumulate (E.Contact_Weights (Id).Side0, -1.0);
      Accumulate (E.Contact_Weights (Id).Side1, 1.0);
      for V in 0 .. E.D.Nv - 1 loop
         if Seen (V) then
            N := N + 1; Chain (N) := V;
            for R in 1 .. C.Dim loop
               declare
                  X : constant Natural := (R - 1) mod 3;
                  Base : constant Natural := (if R <= 3 then 1 else 4);
               begin
                  J (R, N) := CK.Frame_Component (World (Base, V+1), World (Base+1, V+1),
                    World (Base+2, V+1), C.Frame (3*X), C.Frame (3*X+1), C.Frame (3*X+2));
               end;
            end loop;
         end if;
      end loop;
   end Weighted_Contact_Jacobian;

   function Contact_Inverse_Weight (E : Engine; Id : Natural; Rotational : Boolean) return Real is
      Sum : Real := 0.0;
      procedure Accumulate (Side : Weighted_Side) is
      begin
         for K in 1 .. Side.Count loop
            declare
               B : constant Natural := Side.Items (K).Body_Id;
               W : constant Real := (if Rotational then E.Bodies (B).Rotation else E.Bodies (B).Translation);
            begin Sum := Sum + W * Side.Items (K).Weight; end;
         end loop;
      end Accumulate;
   begin
      if E.Contact_Weights (Id).Active then
         Accumulate (E.Contact_Weights (Id).Side0);
         Accumulate (E.Contact_Weights (Id).Side1);
         return Sum;
      elsif Rotational then
         return E.Bodies (E.Endpoints (Id).Body0).Rotation + E.Bodies (E.Endpoints (Id).Body1).Rotation;
      else
         return E.Bodies (E.Endpoints (Id).Body0).Translation + E.Bodies (E.Endpoints (Id).Body1).Translation;
      end if;
   end Contact_Inverse_Weight;

   procedure Begin_Assembly (E : in out Engine; Result : out Status) is
   begin
      CA.Reset (E.Rows, E.D.Nv);
      Result := Success;
      if Disabled (E.Flags, Dsbl_Constraint) then return; end if;
      MJ.Data.Constrained.Tendons.Update (E, Result);
   end Begin_Assembly;

   procedure Assemble (E : in out Engine; Result : out Status) is
   begin
      Begin_Assembly (E, Result);
      if Result /= Success then return; end if;
      MJ.Data.Constrained.Equalities.Assemble (E, Result);
      if Result /= Success then return; end if;
      Finish_Assembly (E, Result);
   end Assemble;

   procedure Finish_Assembly (E : in out Engine; Result : out Status) is
      S : CA.Result;
   begin
      Result := Success;
      if Disabled (E.Flags, Dsbl_Constraint) then return; end if;
      if not Disabled (E.Flags, Dsbl_Frictionloss) then
         for V in 0 .. E.D.Nv - 1 loop
            CA.Add_Dof_Friction (E.Rows, V, E.Dofs (V).Loss, S);
            if S = CA.Capacity_Limit then Result := Capacity_Exceeded; return; end if;
         end loop;
      end if;
      MJ.Data.Constrained.Tendons.Add_Friction (E, Result);
      if Result /= Success then return; end if;
      if not Disabled (E.Flags, Dsbl_Limit) then
         for I in 0 .. E.Nj - 1 loop
            declare
               P : constant Joint_Description := E.Joints (I);
               Q : constant JL.Quaternion := (if P.Kind = Ball then
                 JL.Quaternion (Read_Quaternion (E.D.State.Qpos.all, P.Qadr)) else [1.0, 0.0, 0.0, 0.0]);
               B : constant JL.Batch := JL.Build (P.Kind, I, P.Vadr, E.D.State.Qpos (P.Qadr),
                 Q, P.Low, P.High, P.Margin, P.Is_Limited);
            begin
               if B.Result /= JL.Success then Result := Numeric_Limit; return; end if;
               for R in 1 .. B.Count loop
                  declare
                     C : CA.Column_Array (1 .. B.Rows (R).Width);
                     J : CA.Matrix (1 .. 1, C'Range);
                  begin
                     for K in C'Range loop
                        C (K) := P.Vadr + K - 1; J (1, K) := B.Rows (R).Jacobian (K - 1);
                     end loop;
                     CA.Append (E.Rows, CA.Limit_Joint, I, C, J,
                       [1 => (B.Rows (R).Position, P.Margin)], 0.0, S);
                     if S /= CA.Success then Result := Capacity_Exceeded; return; end if;
                  end;
               end loop;
            end;
         end loop;
      end if;
      MJ.Data.Constrained.Tendons.Add_Limits (E, Result);
      if Result /= Success then return; end if;
      for Id in 0 .. E.T.Ncontact - 1 loop
         declare
            C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
            B1 : constant Natural := E.Endpoints (Id).Body0;
            B2 : constant Natural := E.Endpoints (Id).Body1;
            A : Integer := E.Bodies (B1).Leaf;
            B : Integer := E.Bodies (B2).Leaf;
            Chain, Reverse_Chain : CA.Column_Array (1 .. Max_V);
            N : Natural := 0;
            Dim : constant CP.Dimension := C.Dim;
            J : CA.Matrix (1 .. Dim, 1 .. Max_V);
         begin
            if not C.Excluded then
               if E.Contact_Weights (Id).Active then
                  Weighted_Contact_Jacobian (E, Id, Chain, J, N);
               else
               --  Merge both parent chains until their common ancestor: no
               --  structural zeros from shared ancestors enter the rows.
               while A /= B loop
                  N := N + 1;
                  if A > B then Reverse_Chain (N) := A; A := E.Dofs (A).Parent;
                  else Reverse_Chain (N) := B; B := E.Dofs (B).Parent; end if;
               end loop;
               for K in 1 .. N loop
                  Chain (K) := Reverse_Chain (N - K + 1);
                  declare
                     V : constant Natural := Chain (K);
                     O1 : constant Natural := Jacobian_Offset (E.D, B1, V);
                     O2 : constant Natural := Jacobian_Offset (E.D, B2, V);
                     W1 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O1);
                     W2 : constant Vector := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O2);
                     R1 : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (B1).Center;
                     R2 : constant Vector := Vector (C.Position) - E.D.Kinematic.Bodies (B2).Center;
                     L1 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O1);
                     L2 : constant Vector := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O2);
                     Linear, Angular : Vector;
                  begin
                     for X in 0 .. 2 loop
                        Linear (X) := CK.Point_Component (L2 (X), W2 ((X+1) mod 3), W2 ((X+2) mod 3),
                          R2 ((X+1) mod 3), R2 ((X+2) mod 3))
                          - CK.Point_Component (L1 (X), W1 ((X+1) mod 3), W1 ((X+2) mod 3),
                          R1 ((X+1) mod 3), R1 ((X+2) mod 3));
                        Angular (X) := W2 (X) - W1 (X);
                     end loop;
                     for R in 1 .. C.Dim loop
                        declare
                           X : constant Natural := (R - 1) mod 3;
                           Z : constant Vector := (if R <= 3 then Linear else Angular);
                        begin
                           J (R, K) := CK.Frame_Component (Z (0), Z (1), Z (2),
                             C.Frame (3 * X), C.Frame (3 * X + 1), C.Frame (3 * X + 2));
                        end;
                     end loop;
                  end;
               end loop;
               end if;
               declare
                  Width : constant Natural := N;
                  Compact : CA.Matrix (1 .. Dim, 1 .. Width);
               begin
                  for R in 1 .. C.Dim loop
                     for K in 1 .. N loop Compact (R, K) := J (R, K); end loop;
                  end loop;
                  C.Efc_Address := (if N = 0 then -1 else E.Rows.Rows);
                  CA.Add_Contact (E.Rows, Id, C.Dim, E.Cone, Chain (1 .. N), Compact,
                    [for K in 1 .. 5 => C.Param.Fri (K - 1)], C.Distance, C.Param.Include_Margin, S);
                  if S = CA.Capacity_Limit then Result := Capacity_Exceeded; return; end if;
                  if S = CA.Success and then N > 0 and then E.Has_Surface_Velocity then
                     declare
                        G0 : constant Integer := E.Endpoints (Id).Geom0;
                        G1 : constant Integer := E.Endpoints (Id).Geom1;
                        Relative : SV.Motion := [others => 0.0];
                     begin
                        if (G0 >= 0 and then SV.Active (E.Geoms (G0).Surface))
                          or else (G1 >= 0 and then SV.Active (E.Geoms (G1).Surface))
                        then
                           Relative := SV.Contact
                             ((if G0 >= 0 then SV.Geometry (E.Geoms (G0).Surface,
                                E.Geoms (G0).Surface_Pose, SV.Vector (C.Position))
                               else SV.Motion'[others => 0.0]),
                              (if G1 >= 0 then SV.Geometry (E.Geoms (G1).Surface,
                                E.Geoms (G1).Surface_Pose, SV.Vector (C.Position))
                               else SV.Motion'[others => 0.0]),
                              [for I in 0 .. 8 => C.Frame (I)]);
                        end if;
                        for Edge in 0 .. SV.Row_Count (C.Dim, E.Cone = CA.Pyramidal) - 1 loop
                           E.Surface_Rows (C.Efc_Address + Edge + 1) := SV.Row_Value
                             (Relative, SV.Friction (C.Param.Fri), C.Dim, Edge,
                              E.Cone = CA.Pyramidal);
                        end loop;
                     end;
                  end if;
               end;
            end if;
         end;
      end loop;
   end Finish_Assembly;

   procedure Prepare_And_Solve (E : in out Engine; Result : out Status) is
      Nv : constant Natural := E.D.Nv;
      Nr : constant Natural := E.Rows.Rows;
      Mass : CS.Matrix (1 .. Nv, 1 .. Nv);
      J : CS.Matrix (1 .. Nr, 1 .. Nv) := [others => [others => 0.0]];
      Ordered_J : CS.Sparse_Jacobian (Nr, E.Rows.Used);
      A, A_Free, Original_Smooth : CS.Vector (1 .. Nv);
      Use_Native : constant Boolean := E.D.Solver_Policy = Compatible;
      Native_Factor : CS.Sparse_Jacobian
        ((if Use_Native then Nv else 0),
         (if Use_Native then MJ.Ancestor_Rows.Count (E.D.Ancestors) else 0));
      Native_Inverse : CS.Vector (1 .. (if Use_Native then Nv else 0));
      Generalized_Force : CS.Vector (1 .. Nv) := [others => 0.0];
      Aref, Force : CS.Vector (1 .. Nr) := [others => 0.0];
      Hessian_Pattern : CS.Structural_Matrix (1 .. Nv, 1 .. Nv) := [others => [others => False]];
   begin
      Result := Numeric_Limit;
      E.T.Nv := Nv; E.T.Nrow := Nr;
      if Nr = 0 then
         --  As mj_fwdConstraint: no rows means the already validated smooth
         --  acceleration is final. Do not factor the same mass a second time.
         --  The standalone assembled solver retains its own input checks.
         for V in 1 .. Nv loop
            E.T.A_Free (V) := E.D.Dynamics.Acceleration (V - 1);
            E.T.Acceleration (V) := E.T.A_Free (V);
            E.T.Constraint_Force (V) := 0.0;
         end loop;
         E.T.Report := (Outcome => CS.Converged, others => <>);
         E.T.Valid := True;
         Result := Success;
         return;
      end if;
      --  Solve_Acceleration has just factored the undamped mass in Ada.
      --  Reuse that factor, including structural zeros, as C reuses qLD.
      if Use_Native then
         for V in 1 .. Nv loop
            declare
               First : constant Natural := MJ.Ancestor_Rows.Start (E.D.Ancestors, V-1);
               Width : constant Positive := MJ.Ancestor_Rows.Length (E.D.Ancestors, V-1);
               Diagonal : constant Real := E.D.Scratch.Ancestor_Factor (First+Width-1);
            begin
               if Diagonal not in 1.0e-15 .. 1.0e60 then return; end if;
               Native_Factor.Offsets (V) := First;
               Native_Factor.Widths (V) := Width-1;
               Native_Inverse (V) := NI.Reciprocal (Diagonal);
               for K in 0 .. Width-1 loop
                  Native_Factor.Columns (First+K+1) := MJ.Ancestor_Rows.Column (E.D.Ancestors, V-1, K)+1;
                  Native_Factor.Values (First+K+1) := E.D.Scratch.Ancestor_Factor (First+K);
               end loop;
            end;
         end loop;
      end if;
      for V in 1 .. Nv loop
         A_Free (V) := E.D.Dynamics.Acceleration (V - 1);
         Original_Smooth (V) := E.D.Dynamics.Total (V - 1);
         A (V) := A_Free (V); E.T.A_Free (V) := A_Free (V);
         for W in 1 .. Nv loop Mass (V, W) := E.D.Dynamics.Mass ((V - 1) * Nv + W - 1); end loop;
         if E.Settings.Sparse and then E.Settings.Algorithm = CS.Newton then
            for K in 0 .. MJ.Ancestor_Rows.Length (E.D.Ancestors, V-1)-1 loop
               Hessian_Pattern (MJ.Ancestor_Rows.Column (E.D.Ancestors, V-1, K)+1, V) := True;
            end loop;
         end if;
         E.T.Constraint_Force (V) := 0.0;
      end loop;
      for R in 1 .. Nr loop
         declare
            Row : CA.Row renames E.Rows.Descriptors (R);
            P : LR.Parameters;
            Diag : Real;
            Friction : constant Boolean := Row.Kind in CA.Friction_Dof | CA.Friction_Tendon;
            Elliptic : constant Boolean := Row.Kind = CA.Contact_Elliptic;
            Tangent : Boolean := False;
            Contact_Dim : Natural := 1;
            Impedance_Position : Real := Row.Param.Position;
            Impedance_Margin : Real := Row.Param.Margin;
            Velocity : Real := 0.0;
         begin
            Ordered_J.Offsets (R) := Row.Offset;
            Ordered_J.Widths (R) := Row.Nonzeros;
            for K in Row.Offset + 1 .. Row.Offset + Row.Nonzeros loop
               J (R, E.Rows.Columns (K) + 1) := E.Rows.Values (K);
               Ordered_J.Columns (K) := E.Rows.Columns (K)+1;
               Ordered_J.Values (K) := E.Rows.Values (K);
               if E.Settings.Sparse and then E.Settings.Algorithm = CS.Newton then
                  for Q in K .. Row.Offset + Row.Nonzeros loop
                     Hessian_Pattern (E.Rows.Columns (K)+1, E.Rows.Columns (Q)+1) := True;
                  end loop;
               end if;
            end loop;
            -- mj_mulJacVec: preserve the dense/sparse four-lane reduction.
            declare
               L : array (Natural range 0 .. 3) of Real := [others => 0.0];
               Count : constant Natural := (if E.Settings.Sparse then Row.Nonzeros else Nv);
               Offset : Natural := 0;
               function Term (Index : Natural) return Real is
                 (if E.Settings.Sparse then E.Rows.Values (Row.Offset+Index+1)
                    * E.D.State.Qvel (E.Rows.Columns (Row.Offset+Index+1))
                  else J (R, Index+1) * E.D.State.Qvel (Index));
            begin
               if Count >= 4 then
                  for Lane in 0 .. 3 loop L (Lane) := Term (Lane); end loop;
                  Offset := 4;
               end if;
               while Offset + 4 <= Count loop
                  for Lane in 0 .. 3 loop L (Lane) := L (Lane) + Term (Offset+Lane); end loop;
                  Offset := Offset + 4;
                  pragma Loop_Variant (Increases => Offset);
               end loop;
               Velocity := (L (0) + L (2)) + (L (1) + L (3));
               if E.Settings.Sparse then
                  while Offset < Count loop
                     Velocity := Velocity + Term (Offset); Offset := Offset+1;
                     pragma Loop_Variant (Increases => Offset);
                  end loop;
               else
                  case Count-Offset is
                     when 3 => Velocity := Velocity + ((Term (Offset) + Term (Offset+1)) + Term (Offset+2));
                     when 2 => Velocity := Velocity + (Term (Offset) + Term (Offset+1));
                     when 1 => Velocity := Velocity + Term (Offset);
                     when others => null;
                  end case;
               end if;
            end;
            --  C adds surface velocity after J*qvel, before computing aref.
            --  Only contact rows read the cache; no full row-buffer scan.
            if E.Has_Surface_Velocity
              and then Row.Kind in CA.Contact_Frictionless | CA.Contact_Pyramidal | CA.Contact_Elliptic
            then Velocity := Velocity + E.Surface_Rows (R); end if;
            if Row.Kind = CA.Equality then
               declare
                  Eq : Equality_Description renames E.Equalities (Row.Id);
               begin
                  P := Eq.Params;
                  Diag := (if Eq.Kind >= 4 then E.Equality_Weights (R)
                    elsif Eq.Kind in 2 .. 3 then Eq.Scalar_Weight
                    elsif R-Eq.First_Row < 3
                    then E.Bodies (Eq.Body0).Translation + E.Bodies (Eq.Body1).Translation
                    else E.Bodies (Eq.Body0).Rotation + E.Bodies (Eq.Body1).Rotation);
                  Impedance_Position :=
                    (if Eq.Kind >= 4 then Row.Param.Position else Eq.Position_Norm);
               end;
            elsif Row.Kind = CA.Friction_Tendon then
               P := E.Tendons (Row.Id).Friction_Params; Diag := E.Tendons (Row.Id).Weight;
            elsif Row.Kind = CA.Limit_Tendon then
               P := E.Tendons (Row.Id).Limit_Params; Diag := E.Tendons (Row.Id).Weight;
            elsif Friction then P := E.Dofs (Row.Id).Params; Diag := E.Dofs (Row.Id).Weight;
            elsif Row.Kind = CA.Limit_Joint then
               P := E.Joints (Row.Id).Params; Diag := E.Dofs (E.Joints (Row.Id).Vadr).Weight;
            else
               declare
                  Contact_Id : constant Natural := Row.Id;
                  C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Contact_Id);
                  Tran : constant Real := Contact_Inverse_Weight (E, Contact_Id, False);
                  Rot : constant Real := Contact_Inverse_Weight (E, Contact_Id, True);
               begin
                  P := Parameters (Real_Array (C.Param.Ref), Real_Array (C.Param.Imp), 0);
                  if Elliptic then
                     -- C computes one impedance from the normal distance for
                     -- the whole cone, even though tangential positions are zero.
                     Impedance_Position := C.Distance;
                     Impedance_Margin := C.Param.Include_Margin;
                     Tangent := R > C.Efc_Address + 1;
                     Contact_Dim := (if Tangent then 0 else C.Dim);
                     Diag := (if R - (C.Efc_Address + 1) < 3 then Tran else Rot);
                     -- Mixed friction references fall back to the normal
                     -- reference, exactly as getsolparam in the C engine.
                     if Tangent and then
                       (C.Param.Ref_Friction (0) /= 0.0 or else C.Param.Ref_Friction (1) /= 0.0)
                       and then (C.Param.Ref_Friction (0) > 0.0) = (C.Param.Ref_Friction (1) > 0.0)
                     then
                        P.Ref0 := C.Param.Ref_Friction (0);
                        P.Ref1 := C.Param.Ref_Friction (1);
                     end if;
                  else
                     Diag := (if C.Dim = 1 then Tran else Tran + (C.Param.Fri (0) * C.Param.Fri (0)) * Tran);
                  end if;
               end;
            end if;
            declare
               EP : constant LR.Effective_Parameters := LR.Sanitize (P, E.D.Timestep, not Disabled (E.Flags, Dsbl_Refsafe));
               Imp : constant Real := LR.Impedance (EP, Impedance_Position, Impedance_Margin);
               K : constant Real := (if Friction or else Tangent then 0.0 else LR.Stiffness (EP));
               B : constant Real := LR.Damping (EP);
               Reg : Real;
            begin
               if Imp = 0.0 then return; end if;
               Reg := Real'Max (Min_Val, ((1.0 - Imp) * Diag) / Imp);
               if Row.Kind = CA.Contact_Pyramidal then
                  declare
                     Mu : constant Real := E.Contacts (Row.Id).Param.Fri (0)
                       * MJ.Joint_Limit_Math.Sqrt ((Reg / Real'Max (Min_Val, E.Impratio)) / Reg);
                  begin Reg := ((2.0 * Mu) * Mu) * Reg; end;
               end if;
               Aref (R) := (-B * Velocity) - ((K * Imp) * (Row.Param.Position - Row.Param.Margin));
               if Row.Kind = CA.Equality and then E.Equalities (Row.Id).Kind < 4 then
                  Aref (R) := Aref (R)-E.Equalities (Row.Id).Jdot_V (R-E.Equalities (Row.Id).First_Row+1);
               end if;
               E.Solver_Rows (R) := (Form => (if Row.Kind = CA.Equality then CS.Equality
                   elsif Elliptic then CS.Elliptic
                   elsif Friction then CS.Friction else CS.Unilateral),
                 Dimension => Contact_Dim,
                 R => Reg, D => 1.0 / Reg, Bound => Row.Loss,
                 Friction => (if Elliptic then
                   [for F in 1 .. 5 => E.Contacts (Row.Id).Param.Fri (F - 1)] else [others => 1.0]),
                 others => <>);
               E.T.Aref (R) := Aref (R); E.T.R (R) := Reg;
               for V in 1 .. Nv loop E.T.J (R, V) := J (R, V); end loop;
            end;
         end;
      end loop;
      -- C's second impedance pass couples the tangential weights and sets
      -- the master mu. Preserve its binary64 multiplication/division order.
      if E.Cone = CA.Elliptic then
      for Id in 0 .. E.T.Ncontact - 1 loop
         declare
            C : MJ.Full_Contacts.Full_Contact renames E.Contacts (Id);
         begin
            if C.Dim > 1
              and then not C.Excluded and then C.Efc_Address >= 0
            then
               declare
                  First : constant Positive := C.Efc_Address + 1;
                  Normal_R : constant Real := E.Solver_Rows (First).R;
                  Tangential_R, Root, Mu : Real;
               begin
                  if Normal_R not in Min_Val .. 1.0e30
                    or else (for some F of C.Param.Fri => F not in 1.0e-5 .. 1.0e10)
                  then return; end if;
                  Tangential_R := MJ.Elliptic_Response.First_Tangent (Normal_R, E.Impratio);
                  Root := MJ.Joint_Limit_Math.Sqrt (Tangential_R / Normal_R);
                  if Root not in 0.0 .. 1.0e10 then return; end if;
                  Mu := C.Param.Fri (0) * Root;
                  C.Mu := Mu;
                  E.Solver_Rows (First).Mu := Mu;
                  for F in 1 .. C.Dim - 1 loop
                     declare
                        R : constant Positive := First + F;
                        Reg : constant Real := (if F = 1 then Tangential_R else
                          MJ.Elliptic_Response.Other_Tangent
                            (Tangential_R, C.Param.Fri (0), C.Param.Fri (F - 1)));
                     begin
                        E.Solver_Rows (R).R := Reg;
                        E.Solver_Rows (R).D := 1.0 / Reg;
                        E.T.R (R) := Reg;
                     end;
                  end loop;
               end;
            end if;
         end;
      end loop;
      end if;
      if E.Settings.Sparse then
         CS.Solve_With_Force (Mass, J, A_Free, Aref, E.Solver_Rows (1 .. Nr), E.Settings,
                   A, Force, Generalized_Force, E.T.Report,
                   Hessian_Pattern, Ordered_J, Original_Smooth, Native_Factor, Native_Inverse);
      else
         CS.Solve_With_Force (Mass, J, A_Free, Aref, E.Solver_Rows (1 .. Nr), E.Settings,
                   A, Force, Generalized_Force, E.T.Report,
                   Hessian_Pattern, Smooth_Force => Original_Smooth,
                   Native_Factor => Native_Factor, Native_Inverse => Native_Inverse);
      end if;
      --  C's primal solver publishes its current iterate when alpha=0 (no
      --  improvement), as well as at the iteration budget. The candidate
      --  exposes those exits explicitly; keep that diagnostic without turning
      --  a valid stopped solve into a failed simulation step.
      if not Step_Publication.Has_Iterate (E.T.Report.Outcome) then return; end if;
      for R in 1 .. Nr loop
         E.T.Force (R) := Force (R);
      end loop;
      for V in 1 .. Nv loop E.T.Constraint_Force (V) := Generalized_Force (V); end loop;
      --  Admission before publication: no partial output acceleration/force.
      for V in 1 .. Nv loop
         if A (V) not in Tier0_Real or else
           E.D.Dynamics.Total (V-1) + E.T.Constraint_Force (V) not in Tier0_Real then return; end if;
      end loop;
      for V in 1 .. Nv loop
         E.D.Dynamics.Acceleration (V-1) := A (V);
         E.D.Dynamics.Total (V-1) := E.D.Dynamics.Total (V-1) + E.T.Constraint_Force (V);
         E.T.Acceleration (V) := A (V);
      end loop;
      E.T.Valid := True; Result := Success;
   end Prepare_And_Solve;

   procedure Evaluate (E : in out Engine; Result : out Status;
                       External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      E.T.Valid := False;
      Result := Not_Allocated;
      if not Ready (E) then return; end if;
      if E.Has_Adhesion then
         E.D.Cache.Actuation_Valid := False; E.D.Cache.Force_Valid := False;
      end if;
      MJ.Data.Forward.Evaluate (E.D, Result, External);
      if Result /= Success then return; end if;
      Generate_Contacts (E, Result);
      if Result /= Success then return; end if;
      if E.T.Ncontact > 0 then
         Pipeline.Ensure_Jacobians (E.D, Result);
         if Result /= Success then return; end if;
      end if;
      Assemble (E, Result);
      if Result /= Success then return; end if;
      if E.Has_Adhesion then
         Body_Adhesion.Apply (E, Result, External);
         if Result /= Success then return; end if;
      end if;
      Prepare_And_Solve (E, Result);
   exception
      when Constraint_Error => E.T.Valid := False; Result := Numeric_Limit;
   end Evaluate;

   procedure Advance (E : in out Engine; Result : out Status) is
      Next_Time, Value : Real;
      Q : Quaternion;
   begin
      --  Forward stages the activation update, including actearly/clamping.
      --  Admit it before publishing any position, velocity or time change.
      if not E.D.Activation_Can_Advance then
         E.T.Valid := False; Result := Numeric_Limit; return;
      end if;
      --  As mj_EulerSkip: solve (M+h*damping)*rate = smooth_force+J'*force.
      --  With no damping, copy the solver's constrained acceleration instead.
      Inertia_Phase.Solve_Euler (E.D, Result);
      if Result /= Success then E.T.Valid := False; return; end if;
      Result := Numeric_Limit;
      Next_Time := E.D.Clock + E.D.Timestep;
      if Next_Time not in Nonneg_Tier0 then return; end if;
      for V in 0 .. E.D.Nv - 1 loop
         Value := CK.Velocity_Update (E.D.State.Qvel (V), E.D.Scratch.Solution (V), E.D.Timestep);
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
            for K in 0 .. 3 loop
               if Q (K) not in Tier0_Real then return; end if;
               E.D.Scratch.Next_Qpos (P.Qadr + K) := Q (K);
            end loop;
         end if;
      end loop;
      Step_Publication.Publish
        (E.D.State.Qpos.all, E.D.State.Qvel.all,
         E.D.Activation (0 .. Integer (E.D.Nactivation) - 1), E.D.Clock,
         E.D.Scratch.Next_Qpos.all, E.D.Scratch.Next_Qvel.all,
         E.D.Next_Activation (0 .. Integer (E.D.Nactivation) - 1), Next_Time);
      Invalidate (E.D.Cache);
      Result := Success;
   exception
      when Constraint_Error => E.T.Valid := False; Result := Numeric_Limit;
   end Advance;

   procedure Step (E : in out Engine; Result : out Status;
                   External : MJ.External_Forces.Wrench_Array := MJ.External_Forces.No_Loads) is
   begin
      Evaluate (E, Result, External);
      if Result = Success then Advance (E, Result); end if;
   end Step;
end MJ.Data.Constrained;
