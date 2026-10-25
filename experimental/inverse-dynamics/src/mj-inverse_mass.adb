with MJ.Inverse_Kernels;
package body MJ.Inverse_Mass with SPARK_Mode is
   function Coefficient
     (Pattern : MJ.Ancestor_Rows.Pattern; Mass : Real_Array;
      Row, A : Natural; Is_Compact : Boolean) return Real is
     (if Is_Compact then Mass (MJ.Ancestor_Rows.Start (Pattern, Row) + A)
      else Mass (Row * MJ.Ancestor_Rows.Size (Pattern) + MJ.Ancestor_Rows.Column (Pattern, Row, A)));

   function Model (Pattern : MJ.Ancestor_Rows.Pattern; Mass, Acceleration : Real_Array;
                   Is_Compact : Boolean := False)
     return Real_Array is
      package AR renames MJ.Ancestor_Rows;
      N : constant Natural := Acceleration'Length;
      Candidate : Real_Array (Acceleration'Range) := [others => 0.0];
      Ok : Boolean;
   begin
      for I in Acceleration'Range loop
         pragma Loop_Invariant (Work (Candidate));
         MJ.Inverse_Kernels.Initialize_Entry
           (Candidate, I, Coefficient (Pattern, Mass, I, AR.Length (Pattern, I) - 1, Is_Compact), Acceleration (I));
         for K in reverse 0 .. AR.Length (Pattern, I) - 2 loop
            pragma Loop_Invariant (Work (Candidate));
            declare
               J : constant Natural := AR.Column (Pattern, I, K);
               M : constant Real := Coefficient (Pattern, Mass, I, K, Is_Compact);
            begin
               MJ.Inverse_Kernels.Scatter (Candidate, I, M, Acceleration (J), Ok);
               if not Ok then return Candidate; end if;
               MJ.Inverse_Kernels.Scatter (Candidate, J, M, Acceleration (I), Ok);
               if not Ok then return Candidate; end if;
            end;
         end loop;
      end loop;
      return Candidate;
   end Model;

   procedure Multiply
     (Pattern : MJ.Ancestor_Rows.Pattern; Mass, Acceleration : Real_Array;
      Value : in out Real_Array; Accepted : out Boolean; Is_Compact : Boolean := False) is
      package AR renames MJ.Ancestor_Rows;
      N : constant Natural := Acceleration'Length;
      Candidate : Real_Array (Value'Range) := [others => 0.0];
      Ok : Boolean;
   begin
      Accepted := False;
      for I in Acceleration'Range loop
         pragma Loop_Invariant (Work (Candidate));
         MJ.Inverse_Kernels.Initialize_Entry
           (Candidate, I, Coefficient (Pattern, Mass, I, AR.Length (Pattern, I) - 1, Is_Compact), Acceleration (I));
         -- mju_mulSymVecSparse: diagonal first, lower columns in reverse,
         -- and scatter each matching upper contribution in increasing row order.
         for K in reverse 0 .. AR.Length (Pattern, I) - 2 loop
            pragma Loop_Invariant (Work (Candidate));
            declare
               J : constant Natural := AR.Column (Pattern, I, K);
               M : constant Real := Coefficient (Pattern, Mass, I, K, Is_Compact);
            begin
               MJ.Inverse_Kernels.Scatter (Candidate, I, M, Acceleration (J), Ok);
               if not Ok then return; end if;
               MJ.Inverse_Kernels.Scatter (Candidate, J, M, Acceleration (I), Ok);
               if not Ok then return; end if;
            end;
         end loop;
      end loop;
      Value := Candidate;
      Accepted := True;
   end Multiply;
end MJ.Inverse_Mass;
