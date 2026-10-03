with MJ.Constrained_Kernels;
package body MJ.Data.Constrained.Signed_Contacts with SPARK_Mode is
   package CK renames MJ.Constrained_Kernels;
   type Support is array (Natural range 0 .. Max_V-1) of Boolean;
   type Accumulators is array (Positive range 1 .. 6, Natural range 0 .. Max_V-1) of RK.Accumulator;
   function Storage_Valid (E : Engine) return Boolean is
     (E.D.Nv in 1 .. Max_V and then E.D.Nb in 1 .. E.Bodies'Length
      and then E.D.Cache.Jacobian_Valid and then E.D.Kinematic.Bodies /= null
      and then E.D.Kinematic.Linear_Jacobian /= null and then E.D.Kinematic.Angular_Jacobian /= null
      and then E.D.Kinematic.Bodies'First = 0 and then E.D.Kinematic.Bodies'Last = E.D.Nb-1
      and then E.D.Kinematic.Linear_Jacobian'First = 0
      and then E.D.Kinematic.Linear_Jacobian'Last = 3 * E.D.Nb * E.D.Nv-1
      and then E.D.Kinematic.Angular_Jacobian'First = 0
      and then E.D.Kinematic.Angular_Jacobian'Last = 3 * E.D.Nb * E.D.Nv-1);

   procedure Diagonal (E : Engine; A, B : SW.Endpoint;
     Translation, Rotation : out RK.Work; Result : out Status)
     with Global => null,
       Pre => Valid_Endpoint (A, E.Bodies'Length) and then Valid_Endpoint (B, E.Bodies'Length)
   is
      T, R : RK.Accumulator := (True, 0.0);
      Visited : RK.Prefix := 0;
      procedure Add_Diagonal (Side : SW.Endpoint) is
      begin
         for K in 0 .. Integer (Side.Count)-1 loop
            declare Id : constant Natural := Side.Items (K).Body_Id; begin
               if Id not in E.Bodies'Range or else Side.Items (K).Weight not in RK.Body_Weight then return; end if;
               if E.Bodies (Id).Translation not in RK.Jacobian_Value
                 or else E.Bodies (Id).Rotation not in RK.Jacobian_Value then return; end if;
               if Visited = RK.Max_Terms or else not RK.Bounded (T, Visited)
                 or else not RK.Bounded (R, Visited) then return; end if;
               T := RK.Advance (T, (True, E.Bodies (Id).Translation, Side.Items (K).Weight), Visited);
               R := RK.Advance (R, (True, E.Bodies (Id).Rotation, Side.Items (K).Weight), Visited);
               Visited := Visited + 1;
            end;
         end loop;
      end Add_Diagonal;
   begin
      Translation := 0.0; Rotation := 0.0; Result := Numeric_Limit;
      Add_Diagonal (A); Add_Diagonal (B);
      if Visited /= A.Count + B.Count then return; end if;
      Translation := T.Value; Rotation := R.Value; Result := Success;
   end Diagonal;

   procedure Build (E : Engine; Contact : MJ.Full_Contacts.Full_Contact;
     Weights : Input; Value : out Response; Result : out Status) is
      Candidate : Response;
      World : Accumulators := [others => [others => (False, 0.0)]];
      Seen : Support := [others => False];
      Visited : RK.Prefix := 0;
      Good : Boolean := True;
      procedure Add_Jacobian (Side : SW.Endpoint)
        with Pre => Storage_Valid (E) and then Valid_Endpoint (Side, E.D.Nb)
          and then (for all X of Contact.Position => X in CK.Small);
      procedure Add_Jacobian (Side : SW.Endpoint) is
         Mask : Support;
      begin
         for K in 0 .. Integer (Side.Count)-1 loop
            declare
               Id : constant Natural := Side.Items (K).Body_Id;
               V : Integer := E.Bodies (Id).Leaf;
               Offset : Vector;
            begin
               if Visited = RK.Max_Terms then Good := False; return; end if;
               Mask := [others => False];
               if (for some X of E.D.Kinematic.Bodies (Id).Center => X not in CK.Small) then
                  Good := False; return;
               end if;
               Offset := [for X in 0 .. 2 => Contact.Position (X) - E.D.Kinematic.Bodies (Id).Center (X)];
               if (for some X of Offset => X not in CK.Small) then Good := False; return; end if;
               while V >= 0 loop
                  if V >= E.D.Nv or else V >= Max_V then Good := False; return; end if;
                  Mask (V) := True;
                  if E.Dofs (V).Parent >= V then Good := False; return; end if;
                  V := E.Dofs (V).Parent;
                  pragma Loop_Variant (Decreases => V);
               end loop;
               for Column in 0 .. E.D.Nv-1 loop
                  if Mask (Column) or else not E.Settings.Sparse then
                     declare
                        Linear, Angular : Vector := [others => 0.0];
                        Point : Real;
                     begin
                        if Mask (Column) then
                           declare O : constant Natural := Jacobian_Offset (E.D, Id, Column); begin
                              Linear := Read_Vector (E.D.Kinematic.Linear_Jacobian.all, O);
                              Angular := Read_Vector (E.D.Kinematic.Angular_Jacobian.all, O);
                           end;
                           if (for some X of Linear => X not in CK.Small)
                             or else (for some X of Angular => X not in CK.Small) then Good := False; return; end if;
                        end if;
                        pragma Assert (Static => (for all X of Angular => X in RK.Jacobian_Value));
                        for X in 0 .. 2 loop
                           Point := (if Mask (Column) then CK.Point_Component
                             (Linear (X), Angular ((X+1) mod 3), Angular ((X+2) mod 3),
                              Offset ((X+1) mod 3), Offset ((X+2) mod 3)) else 0.0);
                           if Point not in RK.Jacobian_Value then Good := False; return; end if;
                           if Visited = RK.Max_Terms or else not RK.Bounded (World (X+1, Column), Visited)
                             or else not RK.Bounded (World (X+4, Column), Visited) then Good := False; return; end if;
                           World (X+1, Column) := RK.Advance (World (X+1, Column),
                             (True, Point, Side.Items (K).Weight), Visited);
                           World (X+4, Column) := RK.Advance (World (X+4, Column),
                             (True, Angular (X), Side.Items (K).Weight), Visited);
                        end loop;
                        Seen (Column) := True;
                     end;
                  end if;
               end loop;
               Visited := Visited + 1;
            end;
         end loop;
      end Add_Jacobian;
   begin
      Value := (others => <>); Result := Not_Allocated;
      if not Ready (E) then return; end if;
      Result := Invalid_Index;
      if not Storage_Valid (E) then return; end if;
      if Weights.Jacobian0.Count + Weights.Jacobian1.Count = 0
        or else not Valid_Endpoint (Weights.Jacobian0, E.D.Nb)
        or else not Valid_Endpoint (Weights.Jacobian1, E.D.Nb)
        or else not Valid_Endpoint (Weights.Diagonal0, E.D.Nb)
        or else not Valid_Endpoint (Weights.Diagonal1, E.D.Nb) then return; end if;
      Result := Numeric_Limit;
      if (for some X of Contact.Position => X not in CK.Small)
        or else (for some X of Contact.Frame => X not in RK.Frame_Value) then return; end if;
      Add_Jacobian (Weights.Jacobian0); if not Good then return; end if;
      Add_Jacobian (Weights.Jacobian1); if not Good then return; end if;
      for V in 0 .. E.D.Nv-1 loop
         pragma Loop_Invariant (Static => Candidate.Width <= V);
         pragma Loop_Invariant (Static =>
           (for all K in 1 .. Candidate.Width => Candidate.Columns (K) < Max_V));
         if Seen (V) then
            Candidate.Width := Candidate.Width + 1;
            Candidate.Columns (Candidate.Width) := V;
            for R in 1 .. Contact.Dim loop
               declare
                  X : constant Natural := (R-1) mod 3;
                  Base : constant Positive := (if R <= 3 then 1 else 4);
                  Projected : Real;
               begin
                  Projected := RK.Project
                    (World (Base,V).Value, World (Base+1,V).Value, World (Base+2,V).Value,
                     Contact.Frame (3*X), Contact.Frame (3*X+1), Contact.Frame (3*X+2));
                  if Projected not in Tier2_Real then return; end if;
                  Candidate.J (R, Candidate.Width) := Projected;
               end;
            end loop;
         end if;
      end loop;
      Diagonal (E, Weights.Diagonal0, Weights.Diagonal1,
        Candidate.Translation, Candidate.Rotation, Result);
      if Result /= Success then return; end if;
      Value := Candidate;
   end Build;
end MJ.Data.Constrained.Signed_Contacts;
