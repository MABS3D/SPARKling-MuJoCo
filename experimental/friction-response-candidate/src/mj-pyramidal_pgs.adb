with Interfaces; use Interfaces;
with MJ.Friction_Random;
package body MJ.Pyramidal_PGS with SPARK_Mode is
   type Work_Vector is array (Positive range <>) of Force_Value;
   type Inverses is array (Positive range <>) of Inverse_Diagonal;

   Step_Bound : constant Real := 2.0 ** 138;
   subtype Term_Value is Real range -1.0e41 .. 1.0e41;
   subtype Lane_Value is Real range -1.0e44 .. 1.0e44;
   function Product (A, B : Force_Value) return Term_Value
   with Post => (Static => Product'Result = A * B)
   is
   begin return A * B; end Product;

   function Accumulate (Acc : Lane_Value; Term : Term_Value; Count : Natural)
     return Lane_Value
   with Pre => Count < Max_Rows and then abs Acc <= Real (Count) * Step_Bound,
     Post => (Static => Accumulate'Result = Acc + Term
       and then abs Accumulate'Result <= Real (Count + 1) * Step_Bound)
   is
   begin return Acc + Term; end Accumulate;

   subtype Positive_Diagonal is Real range 1.0e-20 .. 1.0e20;
   function Reciprocal (D : Positive_Diagonal) return Inverse_Diagonal
   with Post => (Static => Reciprocal'Result = 1.0 / D)
   is
   begin return 1.0 / D; end Reciprocal;

   subtype Fraction is Real range 0.0 .. 1.0;
   function Momentum_Factor (K : Iteration_Count) return Fraction
   with Post => (Static => Momentum_Factor'Result =
     (if K > 1 then Real (K - 1) / Real (K + 2) else 0.0))
   is
   begin return (if K > 1 then Real (K - 1) / Real (K + 2) else 0.0); end Momentum_Factor;

   function Shuffle_Position (Value : Unsigned_32; Count : Positive) return Positive
   with Pre => Count <= Max_Rows,
     Post => (Static => Shuffle_Position'Result in 1 .. Count
       and then Int64 (Shuffle_Position'Result) = (Int64 (Value) mod Int64 (Count)) + 1)
   is
   begin return Natural (Int64 (Value) mod Int64 (Count)) + 1; end Shuffle_Position;

   Improvement_Bound : constant Real := 2.0 ** 302;
   subtype Improvement_Value is Real range -1.0e94 .. 1.0e94;
   function Accumulate_Improvement (Acc : Improvement_Value; Change : Cost_Value; Count : Natural)
     return Improvement_Value
   with Pre => Count < Max_Rows and then abs Acc <= Real (Count) * Improvement_Bound,
     Post => (Static => Accumulate_Improvement'Result = Acc - Change
       and then abs Accumulate_Improvement'Result <= Real (Count + 1) * Improvement_Bound)
   is
   begin return Acc - Change; end Accumulate_Improvement;

   function Extrapolate (Kind : Row_Kind; Current, Previous : Force_Value;
                         Beta : Fraction; Bound : Bound_Value) return Step_Result
   with Post => (Static =>
     (declare Proposed : constant Raw_Value := MJ.Friction_Kernels.Model.Projected
        (Kind, Current + Beta * (Current - Previous), Bound);
      begin Extrapolate'Result.Accepted = (Proposed in Force_Value)
        and then Extrapolate'Result.Change = 0.0
        and then Extrapolate'Result.Force = (if Proposed in Force_Value then Proposed else Current))
     and then (if Feasible (Kind, Current, Bound) then Feasible (Kind, Extrapolate'Result.Force, Bound)))
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Feasible);
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", MJ.Friction_Kernels.Model.Projected);
      Proposed : constant Raw_Value := Project (Kind, Current + Beta * (Current - Previous), Bound);
   begin
      if Proposed not in Force_Value then return (False, Current, 0.0); end if;
      return (True, Proposed, 0.0);
   end Extrapolate;

   --  Feasibility depends on numeric comparisons, so it is preserved by
   --  floating equality even if a subtype conversion changes the sign of zero.
   procedure Transfer_Feasible (Kind : Row_Kind; A : Force_Value; B : Real; Bound : Bound_Value)
   with Ghost => Static,
     Pre => Feasible (Kind, A, Bound) and then A = B,
     Post => Feasible (Kind, B, Bound)
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Feasible);
   begin null; end Transfer_Feasible;

   procedure Transfer_Vector (Kind : Kinds; Loss : Bounds; F : Work_Vector; Output : Vector)
   with Ghost => Static,
     Pre => F'First = 1 and then Output'First = 1 and then F'Length = Output'Length
       and then Kind'First = 1 and then Kind'Length = F'Length
       and then Loss'First = 1 and then Loss'Length = F'Length
       and then (for all I in F'Range => Feasible (Kind (I), F (I), Loss (I)))
       and then (for all I in F'Range => Output (I) = F (I)),
     Post => (for all I in Output'Range => Feasible (Kind (I), Output (I), Loss (I)))
   is
   begin
      for I in F'Range loop
         Transfer_Feasible (Kind (I), F (I), Output (I), Loss (I));
         pragma Loop_Invariant
           (for all J in F'First .. I => Feasible (Kind (J), Output (J), Loss (J)));
      end loop;
   end Transfer_Vector;

   procedure Transfer_Frame
     (Kind : Kinds; Loss : Bounds; Before, After : Work_Vector; Changed : Positive)
   with Ghost => Static,
     Pre => Before'First = 1 and then After'First = 1
       and then Before'Length = After'Length and then Changed in After'Range
       and then Kind'First = 1 and then Kind'Length = After'Length
       and then Loss'First = 1 and then Loss'Length = After'Length
       and then (for all J in Before'Range => Feasible (Kind (J), Before (J), Loss (J)))
       and then Feasible (Kind (Changed), After (Changed), Loss (Changed))
       and then (for all J in After'Range => (if J /= Changed then After (J) = Before (J))),
     Post => (for all J in After'Range => Feasible (Kind (J), After (J), Loss (J)))
   is
   begin
      for J in After'Range loop
         if J /= Changed then
            Transfer_Feasible (Kind (J), Before (J), After (J), Loss (J));
         end if;
         pragma Loop_Invariant
           (for all X in After'First .. J => Feasible (Kind (X), After (X), Loss (X)));
      end loop;
   end Transfer_Frame;

   function Bounded_Row (AR : Matrix; Row : Positive) return Boolean is
     (for all J in AR'Range (2) => AR (Row, J) in Force_Value)
   with Pre => Row in AR'Range (1),
     Annotate => (GNATprove, Hide_Info, "Expression_Function_Body");

   function Residual (AR : Matrix; B : Vector; F : Work_Vector; Row : Positive)
     return Residual_Value
   with Pre => F'First = 1 and then F'Length in 1 .. Max_Rows
       and then AR'First (1) = 1 and then AR'First (2) = 1
       and then AR'Length (1) = F'Length and then AR'Length (2) = F'Length
       and then B'First = 1 and then B'Length = F'Length and then Row in F'Range
       and then B (Row) in -1.0e20 .. 1.0e20
       and then Bounded_Row (AR, Row)
   is
      pragma Annotate (GNATprove, Unhide_Info, "Expression_Function_Body", Bounded_Row);
      B_Row : constant Force_Value := B (Row);
      S0, S1, S2, S3 : Lane_Value := 0.0;
      Sum : Real range -5.0e44 .. 5.0e44;
      Tail : Real range -5.0e41 .. 5.0e41;
      N : constant Positive range 1 .. Max_Rows := F'Length;
      Blocks : constant Natural := N / 4;
      I : Positive;
   begin
      --  Four lanes and grouped remainder, in C's binary64 evaluation order.
      --  Count times a power of two is exact; the allowance exceeds each term.
      for Block in 0 .. Blocks - 1 loop
         I := 4 * Block + 1;
         S0 := Accumulate (S0, Product (AR (Row, I), F (I)), Block);
         S1 := Accumulate (S1, Product (AR (Row, I + 1), F (I + 1)), Block);
         S2 := Accumulate (S2, Product (AR (Row, I + 2), F (I + 2)), Block);
         S3 := Accumulate (S3, Product (AR (Row, I + 3), F (I + 3)), Block);
         pragma Loop_Invariant (Static => abs S0 <= Real (Block + 1) * Step_Bound
           and abs S1 <= Real (Block + 1) * Step_Bound
           and abs S2 <= Real (Block + 1) * Step_Bound
           and abs S3 <= Real (Block + 1) * Step_Bound);
      end loop;
      Sum := (S0 + S2) + (S1 + S3);
      I := 4 * Blocks + 1;
      case N mod 4 is
         when 3 => Tail :=
           ((Product (AR (Row, I), F (I)) + Product (AR (Row, I + 1), F (I + 1)))
            + Product (AR (Row, I + 2), F (I + 2)));
         when 2 => Tail := (Product (AR (Row, I), F (I)) + Product (AR (Row, I + 1), F (I + 1)));
         when 1 => Tail := Product (AR (Row, I), F (I));
         when others => return B_Row + Sum;
      end case;
      return B_Row + (Sum + Tail);
   end Residual;

   procedure Solve (AR : Matrix; B : Vector; Kind : Kinds; Loss : Bounds;
                    Settings : Options; Force : in out Vector; Result : out Report) is
      N : constant Natural := Force'Length;
   begin
      Result := (others => <>);
      if N > Max_Rows or Force'First /= 1 or B'First /= 1
        or B'Length /= N or Kind'First /= 1 or Kind'Length /= N
        or Loss'First /= 1 or Loss'Length /= N
        or AR'First (1) /= 1 or AR'First (2) /= 1
        or AR'Length (1) /= N or AR'Length (2) /= N
      then return; end if;
      for I in 1 .. N loop
         if B (I) not in -1.0e20 .. 1.0e20
           or else not Feasible (Kind (I), Force (I), Loss (I))
           or else AR (I, I) not in 1.0e-20 .. 1.0e20
         then return; end if;
         if not Bounded_Row (AR, I) then return; end if;
         pragma Loop_Invariant (Static =>
           (for all Checked in 1 .. I =>
             B (Checked) in -1.0e20 .. 1.0e20
             and Feasible (Kind (Checked), Force (Checked), Loss (Checked))
             and AR (Checked, Checked) in 1.0e-20 .. 1.0e20
             and Bounded_Row (AR, Checked)));
      end loop;
      if N = 0 then Result.Outcome := Converged; return; end if;
      declare
         F : Work_Vector (1 .. N) := (for I in 1 .. N => Force_Value (Force (I)));
         Prev, Momentum : Work_Vector (1 .. N) := F;
         Before : Work_Vector (1 .. N) with Ghost => Static;
         Inv : Inverses (1 .. N) := (for I in 1 .. N => Reciprocal (AR (I, I)));
         subtype Local_Index is Positive range 1 .. N;
         type Indices is array (Positive range <>) of Local_Index;
         Order : Indices (1 .. N) := (for I in 1 .. N => I);
         G : MJ.Friction_Random.Generator := (State => 1, Increment => 1);
         Random : Unsigned_32;
         K : Iteration_Count := 0;
         Improvement : Real range -1.0e94 .. 1.0e94;
         Dot_Restart : Real range -1.0e44 .. 1.0e44;
         Beta : Real range 0.0 .. 1.0;
         S : Step_Result;
         procedure Swap (I, J : Local_Index)
         with Global => (Proof_In => N, In_Out => Order),
           Post => (Static => (for all X in Order'Range => Order (X) =
             (if X = I then Order'Old (J) elsif X = J then Order'Old (I) else Order'Old (X))))
         is
            Temp : constant Local_Index := Order (I);
         begin
            Order (I) := Order (J); Order (J) := Temp;
         end Swap;
      begin
         --  State after C primes state=0, increment=1 with one discarded output.
         Result.Outcome := Iteration_Limit;
         for Iter in 1 .. Settings.Iterations loop
            pragma Loop_Invariant (Static => Result.Outcome = Iteration_Limit and K <= Iter - 1
              and Result.Restarts <= Iter - 1
              and (for all I in 1 .. N => Feasible (Kind (I), F (I), Loss (I)))
              and (for all I in 1 .. N => Order (I) in 1 .. N));
            if Settings.Nesterov then
               Beta := Momentum_Factor (K);
               for I in 1 .. N loop
                  Before := F;
                  if Beta > 0.0 then
                     S := Extrapolate (Kind (I), F (I), Prev (I), Beta, Loss (I));
                     if not S.Accepted then
                        Result.Outcome := Numeric_Limit; return;
                     end if;
                     Prev (I) := F (I);
                     F (I) := S.Force;
                     Transfer_Feasible (Kind (I), S.Force, F (I), Loss (I));
                  else Prev (I) := F (I); end if;
                  Momentum (I) := F (I);
                  Transfer_Frame (Kind, Loss, Before, F, I);
                  pragma Loop_Invariant (Static =>
                    (for all J in 1 .. N => Feasible (Kind (J), F (J), Loss (J))));
               end loop;
            end if;
            for I in reverse 2 .. N loop
               MJ.Friction_Random.Next (G, Random);
               Swap (I, Shuffle_Position (Random, I));
               pragma Loop_Invariant (Static =>
                 (for all J in 1 .. N => Order (J) in 1 .. N));
            end loop;
            Improvement := 0.0;
            for Visit in 1 .. N loop
               declare I : constant Positive := Order (Visit); begin
                  S := Step (Kind (I), F (I), Residual (AR, B, F, I), Inv (I), Loss (I));
                  if not S.Accepted then Result.Outcome := Numeric_Limit; return; end if;
                  F (I) := S.Force;
                  Improvement := Accumulate_Improvement (Improvement, S.Change, Visit - 1);
               end;
               pragma Loop_Invariant (Static =>
                 (for all I in 1 .. N => Feasible (Kind (I), F (I), Loss (I)))
                 and abs Improvement <= Real (Visit) * Improvement_Bound);
            end loop;
            Result.Improvement := Improvement * Settings.Scale;
            if Settings.Nesterov then
               Dot_Restart := 0.0;
               if Iter > 1 then
                  for I in 1 .. N loop
                     Dot_Restart := Accumulate (Dot_Restart,
                       (F (I) - Momentum (I)) * (Momentum (I) - Prev (I)), I - 1);
                     pragma Loop_Invariant (Static => abs Dot_Restart <= Real (I) * Step_Bound);
                  end loop;
               end if;
               if Dot_Restart < 0.0 then
                  K := 0; Result.Restarts := Result.Restarts + 1;
               else K := K + 1; end if;
            end if;
            Result.Iterations := Iter;
            if Result.Improvement < Settings.Tolerance then
               Result.Outcome := Converged; exit;
            end if;
         end loop;
         Force := (for I in 1 .. N => Real (F (I)));
         Transfer_Vector (Kind, Loss, F, Force);
      end;
   end Solve;
end MJ.Pyramidal_PGS;
