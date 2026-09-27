package body MJ.Data.Jacobians with SPARK_Mode is
   procedure Column
     (Hinge : Boolean; Center, Anchor, Direction : Vector;
      Linear, Angular : out Vector; Ok : out Boolean)
   is
   begin
      if Hinge then
         Angular := Direction;
         Linear := Cross (Direction, Center - Anchor);
      else
         Angular := Zero;
         Linear := Direction;
      end if;
      Ok := Bounded (Linear) and then Bounded (Angular);
   end Column;

   procedure Store_Column
     (Linear, Angular : in out Real_Array; Base : Natural; L, A : Vector)
   is
   begin
      Write_Vector (Linear, Base, L);
      Write_Vector (Angular, Base, A);
   end Store_Column;

   procedure Build
     (Bodies : Body_Parameter_Array; Joints : Joint_Parameter_Array;
      Body_Poses : Body_State_Array; Joint_Poses : Joint_State_Array;
      Linear, Angular : out Real_Array; Ok : out Boolean)
   is
      Nv : constant Natural := Joints'Length;
   begin
      Ok := False;
      Linear := [others => 0.0];
      Angular := [others => 0.0];
      for B in 1 .. Bodies'Last loop
         pragma Loop_Invariant (for all X of Linear => Within_Work (X));
         pragma Loop_Invariant (for all X of Angular => Within_Work (X));
         pragma Loop_Invariant (for all I in Linear'Range => (if I < 3 * Nv then Linear (I) = 0.0 and then Angular (I) = 0.0));
         declare
            Ancestor : Natural := B;
         begin
            while Ancestor > 0 loop
               pragma Loop_Variant (Decreases => Ancestor);
               pragma Loop_Invariant (Ancestor in 1 .. B);
               pragma Loop_Invariant (for all X of Linear => Within_Work (X));
               pragma Loop_Invariant (for all X of Angular => Within_Work (X));
               pragma Loop_Invariant (for all I in Linear'Range => (if I < 3 * Nv then Linear (I) = 0.0 and then Angular (I) = 0.0));
               declare
                  C : constant Body_Parameters := Bodies (Ancestor);
               begin
                  for Offset in 0 .. C.Joint_Count - 1 loop
                     pragma Loop_Invariant (for all X of Linear => Within_Work (X));
                     pragma Loop_Invariant (for all X of Angular => Within_Work (X));
                     pragma Loop_Invariant (for all I in Linear'Range => (if I < 3 * Nv then Linear (I) = 0.0 and then Angular (I) = 0.0));
                     declare
                        J : constant Natural := C.First_Joint + Offset;
                        Base : constant Natural := MJ.Smooth_Kernels.Jacobian_Index
                          (Bodies'Length, Nv, B, Joints (J).Vadr);
                        L, A : Vector;
                        Accepted : Boolean;
                     begin
                        Column (Joints (J).Kind = Hinge_Joint, Body_Poses (B).Center,
                          Joint_Poses (J).Anchor, Joint_Poses (J).Direction, L, A, Accepted);
                        if not Accepted then return; end if;
                        pragma Assert (Static => Base >= 3 * Nv);
                        Store_Column (Linear, Angular, Base, L, A);
                     end;
                  end loop;
                  Ancestor := C.Parent;
               end;
            end loop;
         end;
      end loop;
      Ok := True;
   end Build;
end MJ.Data.Jacobians;
