with Ada.Unchecked_Deallocation;
with MJ.Tendon_Vectors; use MJ.Tendon_Vectors;
with MJ.Tendon_Geometry;
with MJ.Smooth_Math;

package body MJ.Spatial_Tendon_Models with SPARK_Mode is
   procedure Release is new Ada.Unchecked_Deallocation (Description, Description_Access);
   procedure Free (T : in out Description_Access) is
   begin
      Release (T);
   end Free;

   --  Keep the 487-array model validator outside the copying proof. The
   --  worker needs only these four groups, established by Valid_Layout.
   procedure Load_Valid (M : MJ.Models.Model; T : in out Description_Access;
                         Accepted : out Boolean) with
     Global => null,
     Pre => T = null and then M.S.Nbody in 1 .. Max_Objects
       and then M.S.Ntendon in 1 .. Max_Objects
       and then M.S.Nsite in 0 .. Max_Objects
       and then M.S.Ngeom in 0 .. Max_Objects
       and then M.S.Nwrap in 0 .. Max_Objects
       and then MJ.Models.Site_Layout_OK (M.S, M.Sites)
       and then MJ.Models.Geom_Layout_OK (M.S, M.Geoms)
       and then MJ.Models.Tendon_Layout_OK (M.S, M.Tendons)
       and then MJ.Models.Wrap_Layout_OK (M.S, M.Wraps),
     Post => (if Accepted then Ready (T, M.S.Nbody) and then Count (T) = M.S.Ntendon
              else T = null);

   procedure Load_Valid (M : MJ.Models.Model; T : in out Description_Access;
                         Accepted : out Boolean) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Ready);
      Q : MJ.Smooth_Math.Quaternion;
      R : MJ.Smooth_Math.Matrix;
      OK : Boolean;
      Obj : Integer;
   begin
      Accepted := False;
      --  Armature needs Jdot and the effective metric. The existing engine
      --  rejects tendon transmissions and enabled constraints separately.
      for I in 0 .. M.S.Ntendon - 1 loop
         if M.Tendons.Tendon_Armature (I) /= 0.0 then return; end if;
      end loop;
      T := new Description (M.S.Ntendon, M.S.Nsite, M.S.Ngeom, M.S.Nwrap);
      T.Nb := M.S.Nbody;
      for I in 0 .. T.Ns - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         if M.Sites.Site_Bodyid (I) not in 0 .. M.S.Nbody - 1 then Free (T); return; end if;
         T.Sites (I + 1) := (Position => (M.Sites.Site_Pos (3 * I),
           M.Sites.Site_Pos (3 * I + 1), M.Sites.Site_Pos (3 * I + 2)),
           Body_Id => M.Sites.Site_Bodyid (I));
      end loop;
      for I in 0 .. T.Ng - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         if M.Geoms.Geom_Bodyid (I) not in 0 .. M.S.Nbody - 1 then Free (T); return; end if;
         --  Non-wrapping geometries are retained only for stable object ids.
         T.Geometries (I + 1).Body_Id := M.Geoms.Geom_Bodyid (I);
         if M.Geoms.Geom_Type (I) in 2 | 5 then
            for K in Q'Range loop Q (K) := M.Geoms.Geom_Quat (4 * I + K); end loop;
            MJ.Smooth_Math.Normalize (Q, OK);
            if not OK then Free (T); return; end if;
            R := MJ.Smooth_Math.Rotation (Q);
            for A in 1 .. 3 loop
               T.Geometries (I + 1).Position (A) := M.Geoms.Geom_Pos (3 * I + A - 1);
               for B in 1 .. 3 loop T.Geometries (I + 1).Orientation (A, B) := R (A - 1, B - 1); end loop;
            end loop;
            T.Geometries (I + 1).Kind := (if M.Geoms.Geom_Type (I) = 2
              then MJ.Tendon_Geometry.Sphere else MJ.Tendon_Geometry.Cylinder);
            T.Geometries (I + 1).Radius := M.Geoms.Geom_Size (3 * I);
         end if;
      end loop;
      for I in 0 .. T.Nw - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         Obj := M.Wraps.Wrap_Objid (I);
         case M.Wraps.Wrap_Type (I) is
            when 2 => T.Nodes (I + 1) := (Kind => Pulley_Node, Divisor => M.Wraps.Wrap_Prm (I), others => <>);
            when 3 =>
               if Obj not in 0 .. T.Ns - 1 then Free (T); return; end if;
               T.Nodes (I + 1) := (Kind => Site_Node, Object_Id => Obj, others => <>);
            when 4 | 5 =>
               if Obj not in 0 .. T.Ng - 1
                 or else M.Geoms.Geom_Type (Obj) /= (if M.Wraps.Wrap_Type (I) = 4 then 2 else 5)
                 or else M.Wraps.Wrap_Prm (I) < -1.0
                 or else M.Wraps.Wrap_Prm (I) > Real (Max_Objects)
               then Free (T); return; end if;
               if Real (Integer (M.Wraps.Wrap_Prm (I))) /= M.Wraps.Wrap_Prm (I) then Free (T); return; end if;
               T.Nodes (I + 1) := (Kind => Geometry_Node, Object_Id => Obj,
                 Side_Id => Integer (M.Wraps.Wrap_Prm (I)), others => <>);
            when others => Free (T); return;
         end case;
      end loop;
      for I in 0 .. T.Nt - 1 loop
         pragma Loop_Invariant (T /= null and then T.Nb = M.S.Nbody
           and then T.Nt = M.S.Ntendon and then T.Ns = M.S.Nsite
           and then T.Ng = M.S.Ngeom and then T.Nw = M.S.Nwrap);
         if M.Tendons.Tendon_Num (I) not in 2 .. T.Nw
           or else M.Tendons.Tendon_Adr (I) not in 0 .. T.Nw - M.Tendons.Tendon_Num (I)
         then Free (T); return; end if;
         T.Tendons (I + 1) := (First => M.Tendons.Tendon_Adr (I), Count => M.Tendons.Tendon_Num (I),
           Lower => M.Tendons.Tendon_Lengthspring (2 * I), Upper => M.Tendons.Tendon_Lengthspring (2 * I + 1),
           Stiffness => M.Tendons.Tendon_Stiffness (I), Damping => M.Tendons.Tendon_Damping (I),
           Spring_Linear => M.Tendons.Tendon_Stiffnesspoly (2 * I),
           Spring_Quadratic => M.Tendons.Tendon_Stiffnesspoly (2 * I + 1),
           Damper_Linear => M.Tendons.Tendon_Dampingpoly (2 * I),
           Damper_Quadratic => M.Tendons.Tendon_Dampingpoly (2 * I + 1));
         declare
            P : constant Parameters := T.Tendons (I + 1);
            Ns : constant Natural := T.Ns;
            Ng : constant Natural := T.Ng;
            Sites : constant Site_Array (0 .. Ns - 1) := T.Sites;
            Geometries : constant Geometry_Array (0 .. Ng - 1) := T.Geometries;
            Route : constant Route_Array (0 .. P.Count - 1) := T.Nodes (P.First + 1 .. P.First + P.Count);
         begin
            if not Valid_Path (Route, Sites, Geometries) then Free (T); return; end if;
         end;
      end loop;
      if not Ready (T, M.S.Nbody) then Free (T); return; end if;
      Accepted := True;
   end Load_Valid;

   procedure Load (M : MJ.Models.Model; T : in out Description_Access;
                   Accepted : out Boolean) is
   begin
      Accepted := False;
      if not MJ.Models.Valid_Layout (M) then return; end if;
      if M.S.Ntendon = 0 then Accepted := True; return; end if;
      --  The active tendon adapter currently uses scalar qpos/qvel columns.
      --  Quaternion joints are supported by a separate engine path, not here.
      if M.S.Nq /= M.S.Nv then return; end if;
      if M.S.Nbody not in 1 .. Max_Objects
        or else M.S.Ntendon not in 1 .. Max_Objects
        or else M.S.Nsite not in 0 .. Max_Objects
        or else M.S.Ngeom not in 0 .. Max_Objects
        or else M.S.Nwrap not in 0 .. Max_Objects then return; end if;
      Load_Valid (M, T, Accepted);
   end Load;

   procedure Spring_Damper (P : Parameters; Length, Velocity : Real;
                            Spring_Enabled, Damper_Enabled : Boolean;
                            Spring, Damper : out Real) is
      pragma Annotate (GNATprove, Hide_Info, "Expression_Function_Body", Polynomial);
      X : Displacement_Real;
   begin
      Spring := 0.0; Damper := 0.0;
      if Spring_Enabled then
         X := Displacement (Length, P.Lower, P.Upper);
         Spring := -X * Polynomial (P.Stiffness, P.Spring_Linear, P.Spring_Quadratic, X, False);
      end if;
      if Damper_Enabled then
         Damper := -Velocity * Polynomial (P.Damping, P.Damper_Linear, P.Damper_Quadratic, Velocity, True);
      end if;
   end Spring_Damper;
end MJ.Spatial_Tendon_Models;
