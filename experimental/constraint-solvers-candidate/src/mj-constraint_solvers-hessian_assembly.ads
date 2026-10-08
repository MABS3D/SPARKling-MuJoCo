--  Row-buffer sparse Gram assembly, mju_sqrMatTDSparseNumeric 3.15.0.
--  Copyright 2021 DeepMind Technologies. SPDX-License-Identifier: Apache-2.0
with MJ.Constraint_Solvers.Cone_Kernels;
with MJ.Constraint_Solvers.Packed_Cholesky;
package MJ.Constraint_Solvers.Hessian_Assembly with SPARK_Mode is
   package Cone renames MJ.Constraint_Solvers.Cone_Kernels;
   package Flat renames MJ.Constraint_Solvers.Packed_Cholesky;
   type Pattern (N : Positive; Rows, Stored : Natural) is record
      Width, Address : Entry_Counts (1 .. Rows);
      Column : Column_Indices (1 .. Stored);
      T_Width, T_Address : Entry_Counts (1 .. N);
      T_Row : Column_Indices (1 .. Stored);
      T_Source : Entry_Counts (1 .. Stored);
   end record;

   function CSR_Valid (P : Pattern) return Boolean is
     (P.N <= Max_Dofs and then P.Rows <= Max_Rows and then P.Stored <= Max_Jacobian_Entries
       and then (if P.Rows = 0 then P.Stored = 0 else P.Address (1) = 0)
       and then (for all R in 1 .. P.Rows => P.Address (R) <= P.Stored
         and then P.Width (R) <= P.Stored-P.Address (R))
       and then (for all R in 2 .. P.Rows => P.Address (R) = P.Address (R-1)+P.Width (R-1))
       and then (if P.Rows > 0 then P.Address (P.Rows)+P.Width (P.Rows) = P.Stored)
       and then (for all C of P.Column => C <= P.N)) with Ghost => Static, Global => null;

   function Sorted (P : Pattern) return Boolean is
     (for all R in 1 .. P.Rows => (for all K in 2 .. P.Width (R) =>
       P.Column (P.Address (R)+K-1) <= P.Column (P.Address (R)+K)))
     with Ghost => Static, Global => null, Pre => CSR_Valid (P);

   function Transpose_Valid (P : Pattern) return Boolean is
     (CSR_Valid (P) and then P.T_Address (1) = 0
       and then (for all C in 1 .. P.N => P.T_Address (C) <= P.Stored
         and then P.T_Width (C) <= P.Stored-P.T_Address (C))
       and then (for all C in 2 .. P.N => P.T_Address (C) = P.T_Address (C-1)+P.T_Width (C-1))
       and then P.T_Address (P.N)+P.T_Width (P.N) = P.Stored
       and then (for all C in 1 .. P.N =>
         (for all S in P.T_Address (C)+1 .. P.T_Address (C)+P.T_Width (C) =>
           P.T_Row (S) <= P.Rows
           and then P.T_Source (S) in P.Address (P.T_Row (S))+1 ..
             P.Address (P.T_Row (S))+P.Width (P.T_Row (S))
           and then P.Column (P.T_Source (S)) = C))) with Ghost => Static, Global => null;

   function Before (P : Pattern; C, R : Positive; Count : Natural) return Natural with
     Ghost => Static, Global => null,
     Pre => CSR_Valid (P) and then C <= P.N and then R <= P.Rows and then Count <= P.Width (R),
     Post => Before'Result <= P.Address (R)+Count;

   procedure Build_Transpose (P : in out Pattern) with Global => null,
     Pre => (Static => CSR_Valid (P)),
     Post => (Static => Transpose_Valid (P)
       and then P.Width = P.Width'Old and then P.Address = P.Address'Old and then P.Column = P.Column'Old
       and then (for all R in 1 .. P.Rows => (for all K in 1 .. P.Width (R) =>
         P.T_Address (P.Column (P.Address (R)+K))+Before (P, P.Column (P.Address (R)+K), R, K-1)+1
           in P.T_Source'Range
         and then P.T_Row (P.T_Address (P.Column (P.Address (R)+K))+
           Before (P, P.Column (P.Address (R)+K), R, K-1)+1) = R
         and then P.T_Source (P.T_Address (P.Column (P.Address (R)+K))+
           Before (P, P.Column (P.Address (R)+K), R, K-1)+1) = P.Address (R)+K)));

   function Values_Valid (P : Pattern; Values, Weight : Vector) return Boolean is
     (Values'First = 1 and then Values'Length = P.Stored and then Weight'First = 1
       and then Weight'Length = P.Rows and then (for all V of Values => V in Cone.Folded_Value)
       and then (for all W of Weight => W in 0.0 .. 1.0e15)) with Ghost => Static, Global => null;

   --  Failure freezes the model trace at the rejected finite value. An
   --  accepted result therefore specifies every rounded update in order.
   type Trace is record
      Value : Real := 0.0;
      Accepted : Boolean := True;
   end record;
   function Trace_Valid (T : Trace) return Boolean is
     (T.Value in -2.0e280 .. 2.0e280 and then (if T.Accepted then T.Value in Flat.Operand))
     with Ghost => Static, Global => null;
   function Trace_Step (T : Trace; Scale, Right : Real) return Trace with
     Ghost => Static, Global => null,
     Pre => Trace_Valid (T) and then Scale in -3.0e147 .. 3.0e147 and then Right in Cone.Folded_Value,
     Post => Trace_Valid (Trace_Step'Result)
       and then (if T.Accepted then Trace_Step'Result.Value = Cone.Gram_Scaled (T.Value, Scale, Right)
         and then Trace_Step'Result.Accepted = (Trace_Step'Result.Value in Flat.Operand)
         else Trace_Step'Result = T);

   function Term_Value (P : Pattern; Values : Vector; Initial : Trace;
                        R, Q : Positive; Scale : Real; Count : Natural) return Trace with
     Ghost => Static, Global => null,
     Pre => CSR_Valid (P) and then Values'First = 1 and then Values'Length = P.Stored
       and then (for all V of Values => V in Cone.Folded_Value) and then Trace_Valid (Initial)
       and then R <= P.Rows and then Q <= P.N and then Count <= P.Width (R)
       and then Scale in -3.0e147 .. 3.0e147,
     Post => Trace_Valid (Term_Value'Result);

   function Row_Value (P : Pattern; Values, Weight : Vector;
                       R, Q : Positive; Count : Natural) return Trace with
     Ghost => Static, Global => null,
     Pre => Transpose_Valid (P) and then Values_Valid (P, Values, Weight)
       and then R <= P.N and then Q <= R and then Count <= P.T_Width (R),
     Post => Trace_Valid (Row_Value'Result);

   --  Every row clique must be present in factor support, including numerical
   --  zeros. The caller's symbolic construction provides this obligation.
   function Covers (P : Pattern; F : Flat.Flat_Pattern) return Boolean is
     (for all R in 1 .. P.Rows => (for all I in 1 .. P.Width (R) =>
       (for all J in 1 .. P.Width (R) =>
         (if P.Column (P.Address (R)+J) <= P.Column (P.Address (R)+I) then
           Flat.Row_Selected (F, P.Column (P.Address (R)+I), P.Column (P.Address (R)+J),
             F.Length (P.Column (P.Address (R)+I)))))))
     with Ghost => Static, Global => null,
     Pre => CSR_Valid (P) and then Flat.Valid_Flat (F) and then P.N = F.N;

   procedure Scatter_Row (Scratch : in out Vector; F : Flat.Flat_Pattern;
                          R : Positive; H : in out Vector) with
     Global => null, Inline_Always,
     Pre => (Static => Flat.Valid_Flat (F) and then R <= F.N
       and then Scratch'First = 1 and then Scratch'Length = F.N and then Flat.Bounded (Scratch)
       and then H'First = 1 and then H'Length = F.Stored and then Flat.Bounded (H)),
     Post => (Static => Flat.Bounded (H) and then Flat.Bounded (Scratch)
       and then (for all K in 1 .. F.Length (R) =>
         H (F.Address (R)+K) = Scratch'Old (F.Column (F.Address (R)+K))
         and then Scratch (F.Column (F.Address (R)+K)) = 0.0)
       and then (for all S in H'Range => (if S <= F.Address (R) or else S > F.Address (R)+F.Length (R)
         then H (S) = H'Old (S)))
       and then (for all C in Scratch'Range => (if not Flat.Row_Selected (F, R, C, F.Length (R))
         then Scratch (C) = Scratch'Old (C))));

   procedure Build_Gram (P : Pattern; Values, Weight : Vector; F : Flat.Flat_Pattern;
                         H : out Vector; Accepted : out Boolean) with
     Global => null,
     Pre => (Static => Transpose_Valid (P) and then Sorted (P) and then Values_Valid (P, Values, Weight)
       and then Flat.Valid_Flat (F) and then P.N = F.N and then Covers (P, F)
       and then H'First = 1 and then H'Length = F.Stored),
     Post => (Static => Flat.Bounded (H) and then (if Accepted then
       (for all R in 1 .. F.N => (for all K in 1 .. F.Length (R) =>
         Row_Value (P, Values, Weight, R, F.Column (F.Address (R)+K), P.T_Width (R)).Accepted
         and then H (F.Address (R)+K) =
           Row_Value (P, Values, Weight, R, F.Column (F.Address (R)+K), P.T_Width (R)).Value))));
end MJ.Constraint_Solvers.Hessian_Assembly;
