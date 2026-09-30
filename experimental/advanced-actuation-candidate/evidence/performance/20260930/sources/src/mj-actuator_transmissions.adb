with MJ.Actuator_Geometry; use MJ.Actuator_Geometry;
package body MJ.Actuator_Transmissions with SPARK_Mode is
   function Common_Ancestors (Parents : Parent_Array; First, Second : Integer) return Mask is
      R : Mask (Parents'Range) := (others => False);
      A : Integer := First;
      B : Integer := Second;
   begin
      while A>=0 and then B>=0 and then A/=B loop
         pragma Loop_Variant (Decreases => A, Decreases => B);
         if A<B then B := Parents (B); else A := Parents (A); end if;
      end loop;
      if A=B then
         while A>=0 loop
            pragma Loop_Variant (Decreases => A);
            R (A) := True; A := Parents (A);
         end loop;
      end if;
      return R;
   end Common_Ancestors;
   function Joint (Kind : Joint_Kind; NV : Count; Start : Dof; Position : Input;
                   Orientation : Quaternion; Gear : Gear_Vector; In_Parent : Boolean := False;
                   SO3 : Boolean := False) return Result is
      R : Result;
      Q : Quaternion;
      Axis, G : Vector;
   begin
      R.Nout := (if SO3 then 3 else 1);
      if Kind=Hinge or else Kind=Slide then
         R.Length (0) := Position*Gear (0);
         R.Moments (0).N := 1; R.Moments (0).Col (0) := Start; R.Moments (0).Val (0) := Gear (0);
      else
         Q := Identity;
         if Kind=Ball or else In_Parent then Q := Normalize (Orientation); end if;
         if Kind=Ball then
            Axis := Log (Q);
            if not Bounded (Axis,1.0e60) then return (others => <>); end if;
            if SO3 then
               R.Length := Axis;
               for K in 0 .. 2 loop
                  R.Moments (K).N := 1; R.Moments (K).Col (0) := Start+K; R.Moments (K).Val (0) := 1.0;
               end loop;
            else
               G := (Gear (0),Gear (1),Gear (2));
               if In_Parent then G := Rotate (G,Conjugate (Q)); end if;
               if not Bounded (G,1.0e11) then return (others => <>); end if;
               R.Length (0) := Dot (Axis,G);
               R.Moments (0).N := 3;
               for K in 0 .. 2 loop R.Moments (0).Col (K) := Start+K; R.Moments (0).Val (K) := G (K); end loop;
            end if;
         else
            G := (Gear (3),Gear (4),Gear (5));
            if In_Parent then G := Rotate (G,Conjugate (Q)); end if;
            if not Bounded (G,1.0e70) then return (others => <>); end if;
            R.Moments (0).N := 6;
            for K in 0 .. 2 loop
               R.Moments (0).Col (K) := Start+K; R.Moments (0).Val (K) := Gear (K);
               R.Moments (0).Col (K+3) := Start+K+3; R.Moments (0).Val (K+3) := G (K);
            end loop;
         end if;
      end if;
      R.Accepted := True; return R;
   end Joint;
   function Tendon (Length : Input; Moment : Row; Gear : Input) return Result is
      R : Result;
   begin
      R.Nout := 1; R.Length (0) := Length*Gear;
      Scale_Tendon (Moment,Gear,R.Moments (0)); R.Accepted := True; return R;
   end Tendon;
   function Site (Position, Reference_Position : Vector; Orientation, Reference_Orientation : Matrix;
                  World_Quaternion, Reference_Quaternion : Quaternion;
                  JP, JR, RP, RR : Jacobian; Common : Mask; Gear : Gear_Vector;
                  Has_Reference : Boolean := False; SO3 : Boolean := False) return Result is
      R : Result;
      Dense : Dense_Row (0 .. JP'Length (2)-1) := (others => 0.0);
      F, T, P, Rotation, A : Vector := Zero;
      Translate : constant Boolean := Gear (0)/=0.0 or else Gear (1)/=0.0 or else Gear (2)/=0.0;
      Rotate_Gear : constant Boolean := Gear (3)/=0.0 or else Gear (4)/=0.0 or else Gear (5)/=0.0;
   begin
      R.Nout := (if SO3 then 3 else 1);
      if Has_Reference then
         if Translate and then not SO3 then
            P := (Position (0)-Reference_Position (0),Position (1)-Reference_Position (1),Position (2)-Reference_Position (2));
            -- General matrix-vector helper has Tier0 vector inputs; keep wider displacement explicit.
            for I in 0 .. 2 loop
               A (I) := (Reference_Orientation (0,I)*P (0)+Reference_Orientation (1,I)*P (1))+Reference_Orientation (2,I)*P (2);
            end loop;
            R.Length (0) := Dot (A,(Gear (0),Gear (1),Gear (2)));
         end if;
         if Rotate_Gear or else SO3 then
            Rotation := Difference (World_Quaternion,Reference_Quaternion);
            if not Bounded (Rotation,1.0e60) then return (others => <>); end if;
            if SO3 then R.Length := Rotation;
            else R.Length (0) := R.Length (0)+Dot (Rotation,(Gear (3),Gear (4),Gear (5))); end if;
         end if;
         F := Mat_Vector (Reference_Orientation,(Gear (0),Gear (1),Gear (2)));
         T := Mat_Vector (Reference_Orientation,(Gear (3),Gear (4),Gear (5)));
      else
         F := Mat_Vector (Orientation,(Gear (0),Gear (1),Gear (2)));
         T := Mat_Vector (Orientation,(Gear (3),Gear (4),Gear (5)));
      end if;
      for K in 0 .. R.Nout-1 loop
         for J in Dense'Range loop
            if SO3 then
               A := (Orientation (0,K),Orientation (1,K),Orientation (2,K));
               Dense (J) := (if Common (J) then 0.0 else Dot ((JR (0,J)-RR (0,J),JR (1,J)-RR (1,J),JR (2,J)-RR (2,J)),A));
            elsif Has_Reference then
               Dense (J) := Reference_Column ((JP (0,J),JP (1,J),JP (2,J)),(JR (0,J),JR (1,J),JR (2,J)),
                 (RP (0,J),RP (1,J),RP (2,J)),(RR (0,J),RR (1,J),RR (2,J)),F,T,Common (J),Translate,Rotate_Gear);
            else
               Dense (J) := Site_Column ((JP (0,J),JP (1,J),JP (2,J)),(JR (0,J),JR (1,J),JR (2,J)),F,T);
            end if;
         end loop;
         Compress (Dense,1.0,R.Moments (K));
      end loop;
      R.Accepted := True; return R;
   end Site;
   function Slidercrank (Axis, Displacement : Vector; Axis_Jacobian, Displacement_Jacobian : Jacobian;
                         Rod, Gear : Input) return Result is
      S : constant Slider_Result := Slider (Axis,Displacement,Rod);
      R : Result;
      Dense : Dense_Row (0 .. Axis_Jacobian'Length (2)-1);
   begin
      if not Bounded (S.DA,1.0e49) or else not Bounded (S.DV,1.0e49) then return R; end if;
      R.Nout := 1; R.Length (0) := S.Length*Gear;
      for J in Dense'Range loop
         Dense (J) := Slider_Column (S.DA,S.DV,(Axis_Jacobian (0,J),Axis_Jacobian (1,J),Axis_Jacobian (2,J)),
                                   (Displacement_Jacobian (0,J),Displacement_Jacobian (1,J),Displacement_Jacobian (2,J)));
      end loop;
      if (for some X of Dense => X not in -1.0e60 .. 1.0e60) then return (others => <>); end if;
      Compress (Dense,Gear,R.Moments (0)); R.Accepted := True; return R;
   end Slidercrank;
   function Body_Adhesion (Active, Gap : Dense_Row; Contacts : Count) return Result is
      R : Result;
      Dense : Dense_Row (Active'Range);
   begin
      R.Nout := 1;
      for J in Dense'Range loop Dense (J) := Adhesion_Column (Active (J),Gap (J),Contacts); end loop;
      if (for some X of Dense => X not in -1.0e60 .. 1.0e60) then return (others => <>); end if;
      Compress (Dense,1.0,R.Moments (0)); R.Accepted := True; return R;
   end Body_Adhesion;
end MJ.Actuator_Transmissions;
