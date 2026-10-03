with MJ.Integration_Kernels;
with MJ.Fluid_Geometry; with MJ.Data.Pipeline; with MJ.Integration_Duals; with MJ.Fluid_Kernels;
package body MJ.Data.Integration_Fluid with SPARK_Mode is
   package A renames MJ.Integration_Duals; use A;
   package F renames MJ.Fluid_Kernels;
   function Force (D : Simulation; E : F.Element; Linear, Angular : Triple; Drag_Only : Boolean) return Triple is
      Speed, Inv_Speed, PN, IPN, PD, Area, Cosine, Drag : Dual;
      V, P, Normal, Added, Magnus, Circ, Kutta : Triple;
      C0 : F.Ellipsoid_Cache renames E.Ellipsoid_Data;
      P0 : F.Ellipsoid_Parameters renames E.Parameters;
   begin
      if not E.Is_Ellipsoid then
         for I in 0 .. 2 loop
            P (I) := C (E.Box_Data.Linear_Viscous)*Linear (I)
              - C (E.Box_Data.Linear_Drag (I)) * (if Linear (I).Value >= 0.0 then Linear (I) else C (0.0)-Linear (I)) * Linear (I);
         end loop;
         return P;
      end if;
      Speed := Norm (Linear); Inv_Speed := Inv (Speed);
      for I in 0 .. 2 loop V (I) := Inv_Speed*Linear (I); end loop;
      PN := (C (C0.Surface (0))*V (0)*V (0)+C (C0.Surface (1))*V (1)*V (1))+C (C0.Surface (2))*V (2)*V (2);
      IPN := Inv (PN);
      for I in 0 .. 2 loop P (I) := C (C0.Surface (I))*IPN; Normal (I) := P (I)*V (I); end loop;
      PD := (P (0)*P (0)*V (0)*V (0)+P (1)*P (1)*V (1)*V (1))+P (2)*P (2)*V (2)*V (2);
      Area := C (MJ.Fluid_Geometry.Pi*C0.Dmax*C0.Dmax)*Root (PN*PD); Cosine := Inv (PD);
      Drag := C (D.Fluid.Viscosity*C0.Lin_Visc) + C (D.Fluid.Density)*Speed
        * (Area*C (P0.Blunt)+C (P0.Slender)*(C (C0.Amax)-Area));
      Added := [others => C (0.0)]; Magnus := Added; Kutta := Added;
      if not Drag_Only then
         for I in 0 .. 2 loop P (I) := C (D.Fluid.Density*P0.Virtual_Mass (I))*Linear (I); end loop;
         Added := Cross (P,Angular);
         Magnus := Cross (Angular,Linear);
         Circ := Cross (Normal,Linear);
         for I in 0 .. 2 loop Circ (I) := C (P0.Kutta*D.Fluid.Density)*Cosine*Area*Circ (I); end loop;
         Kutta := Cross (Circ,Linear);
      end if;
      for I in 0 .. 2 loop
         V (I) := (Added (I)+(C (P0.Magnus*D.Fluid.Density*C0.Volume)*Magnus (I)+Kutta (I)-Drag*Linear (I)))*C (P0.Interaction);
      end loop;
      return V;
   end Force;
   function Torque (D : Simulation; E : F.Element; Linear, Angular : Triple; Drag_Only : Boolean) return Triple is
      Mom, LM, AM, Added, P, V : Triple; Drag : Dual;
      C0 : F.Ellipsoid_Cache renames E.Ellipsoid_Data;
      P0 : F.Ellipsoid_Parameters renames E.Parameters;
   begin
      if not E.Is_Ellipsoid then
         for I in 0 .. 2 loop
            V (I) := C (E.Box_Data.Angular_Viscous)*Angular (I)
              - C (E.Box_Data.Angular_Drag (I)/64.0)*(if Angular (I).Value >= 0.0 then Angular (I) else C (0.0)-Angular (I))*Angular (I);
         end loop; return V;
      end if;
      for I in 0 .. 2 loop Mom (I) := Angular (I)*C (C0.Angular_Moment (I)); end loop;
      Drag := C (D.Fluid.Viscosity*C0.Ang_Visc)+C (D.Fluid.Density)*Norm (Mom);
      Added := [others => C (0.0)];
      if not Drag_Only then
         for I in 0 .. 2 loop
            LM (I) := C (D.Fluid.Density*P0.Virtual_Mass (I))*Linear (I);
            AM (I) := C (D.Fluid.Density*P0.Virtual_Inertia (I))*Angular (I);
         end loop;
         Added := Cross (LM,Linear); P := Cross (AM,Angular);
         for I in 0 .. 2 loop Added (I) := Added (I)+P (I); end loop;
      end if;
      for I in 0 .. 2 loop V (I) := (Added (I)-Drag*Angular (I))*C (P0.Interaction); end loop;
      return V;
   end Torque;
   function Root_Of (D : Simulation; Body_Id : Natural) return Natural is
      B : Natural := Body_Id;
   begin
      while D.Body_Config (B).Parent > 0 loop B := D.Body_Config (B).Parent; end loop;
      return B;
   end Root_Of;
   function Free_Rigid_Subtree (D : Simulation; Body_Id : Natural) return Boolean is
      Root : constant Natural := Root_Of (D, Body_Id);
      First : constant Integer := D.Body_Config (Root).First_Joint;
   begin
      if D.Body_Config (Root).Joint_Count /= 6 or else First < 0
        or else D.Joint_Config (First).Group_Type /= 0 then return False; end if;
      for P of D.Joint_Config.all loop
         if Root_Of (D, P.Body_Id) = Root and then P.Body_Id /= Root then return False; end if;
      end loop;
      return True;
   end Free_Rigid_Subtree;

   procedure Add (D : in out Simulation; Drag_Only, Symmetrize_Nonfree : Boolean;
                  Deriv : in out Real_Array; Result : out Status) is
      N : constant Natural := D.Nv;
      type Rows is array (Natural range <>) of Vector;
      JL, JW : Rows (0 .. Integer (N)-1);
      Offset, Base_L, Base_W, Wind : Vector;
      R : Matrix; LV, WV, VF, VT : Triple;
      Value, Product : Real;
      type Local_Matrix is array (Natural range 0 .. 5, Natural range 0 .. 5) of Real;
      Local_Derivative : Local_Matrix;
      type Local_Vector is array (Natural range 0 .. 5) of Real;
      Row_Jacobian, Column_Jacobian, Intermediate : Local_Vector;
   begin
      Result := Success;
      if D.Fluid_Elements = null then return; end if;
      Pipeline.Ensure_Jacobians (D, Result); if Result /= Success then return; end if;
      for E of D.Fluid_Elements.all loop
         declare B : constant Natural := E.Body_Id; BR : constant Matrix := D.Kinematic.Bodies (B).Rotation;
         begin
            Offset := D.Kinematic.Bodies (B).Position+Apply (BR,E.Position)-D.Kinematic.Bodies (B).Center;
            if E.Is_Ellipsoid then
               for I in Axis loop for J in Axis loop R (I,J) := (BR (I,0)*E.Rotation (0,J)+BR (I,1)*E.Rotation (1,J))+BR (I,2)*E.Rotation (2,J); end loop; end loop;
            else R := D.Kinematic.Bodies (B).Inertial_Rotation; end if;
            Base_L := Zero; Base_W := Zero; Wind := Apply_Transpose (R,D.Fluid.Wind);
            for C0 in 0 .. N-1 loop
               JW (C0) := Read_Vector (D.Kinematic.Angular_Jacobian.all,3*(B*N+C0));
               JL (C0) := Read_Vector (D.Kinematic.Linear_Jacobian.all,3*(B*N+C0))+Cross (JW (C0),Offset);
               Base_L := Base_L+D.State.Qvel (C0)*JL (C0); Base_W := Base_W+D.State.Qvel (C0)*JW (C0);
               JL (C0) := Apply_Transpose (R,JL (C0)); JW (C0) := Apply_Transpose (R,JW (C0));
            end loop;
            Base_L := Apply_Transpose (R,Base_L)-Wind; Base_W := Apply_Transpose (R,Base_W);
            -- C first symmetrizes the six-dimensional local fluid derivative,
            -- then projects it through the native body/geom Jacobian.
            for Column in 0 .. 5 loop
               for I in Axis loop
                  LV (I) := (Base_L (I), (if Column = I + 3 then 1.0 else 0.0));
                  WV (I) := (Base_W (I), (if Column = I then 1.0 else 0.0));
               end loop;
               VF := Force (D,E,LV,WV,Drag_Only); VT := Torque (D,E,LV,WV,Drag_Only);
               for I in Axis loop
                  Local_Derivative (I,Column) := VT (I).Rate;
                  Local_Derivative (I+3,Column) := VF (I).Rate;
               end loop;
            end loop;
            if Drag_Only or else (Symmetrize_Nonfree and then not Free_Rigid_Subtree (D,B)) then
               for I in 0 .. 5 loop
                  for J in I+1 .. 5 loop
                     if Local_Derivative (I,J) not in MJ.Integration_Kernels.Operand
                       or else Local_Derivative (J,I) not in MJ.Integration_Kernels.Operand then
                        Result := Numeric_Limit; return;
                     end if;
                     Value := MJ.Integration_Kernels.Symmetric_Entry
                       (Local_Derivative (I,J), Local_Derivative (J,I));
                     Local_Derivative (I,J) := Value; Local_Derivative (J,I) := Value;
                  end loop;
               end loop;
            end if;
            for Column in 0 .. N-1 loop
               for I in Axis loop
                  Column_Jacobian (I) := JW (Column)(I);
                  Column_Jacobian (I+3) := JL (Column)(I);
               end loop;
               for I in 0 .. 5 loop
                  Product := 0.0;
                  for J in 0 .. 5 loop
                     Product := Product + Local_Derivative (I,J)*Column_Jacobian (J);
                  end loop;
                  Intermediate (I) := Product;
               end loop;
               for Row in 0 .. N-1 loop
                  for I in Axis loop
                     Row_Jacobian (I) := JW (Row)(I); Row_Jacobian (I+3) := JL (Row)(I);
                  end loop;
                  Value := 0.0;
                  for I in 0 .. 5 loop Value := Value + Row_Jacobian (I)*Intermediate (I); end loop;
                  if Value not in -1.0e60 .. 1.0e60 then Result := Numeric_Limit; return; end if;
                  Deriv (Row*N+Column) := Deriv (Row*N+Column)+Value;
               end loop;
            end loop;
         end;
      end loop;
   end Add;
end MJ.Data.Integration_Fluid;
