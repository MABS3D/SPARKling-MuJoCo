with MJ.Inverse_Kernels;
package body MJ.Inverse_Mass with SPARK_Mode is
   function Model (Pattern : MJ.Ancestor_Rows.Pattern; Mass, Acceleration : Real_Array)
     return Real_Array is
      package AR renames MJ.Ancestor_Rows;
      N : constant Natural := Acceleration'Length;
      Candidate : Real_Array (Acceleration'Range) := [others => 0.0];
      Ok : Boolean;
   begin
      for I in Acceleration'Range loop
         pragma Loop_Invariant (Work (Candidate));
         MJ.Inverse_Kernels.Initialize_Entry
           (Candidate, I, Mass (I * N + I), Acceleration (I));
         for K in reverse 0 .. AR.Length (Pattern, I) - 2 loop
            pragma Loop_Invariant (Work (Candidate));
            declare
               J : constant Natural := AR.Column (Pattern, I, K);
               M : constant Real := Mass (I * N + J);
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
      Value : in out Real_Array; Accepted : out Boolean) is
      package AR renames MJ.Ancestor_Rows;
      N : constant Natural := Acceleration'Length;
      Candidate : Real_Array (Value'Range) := [others => 0.0];
      Ok : Boolean;
   begin
      Accepted := False;
      for I in Acceleration'Range loop
         pragma Loop_Invariant (Work (Candidate));
         MJ.Inverse_Kernels.Initialize_Entry
           (Candidate, I, Mass (I * N + I), Acceleration (I));
         -- mju_mulSymVecSparse: diagonal first, lower columns in reverse,
         -- and scatter each matching upper contribution in increasing row order.
         for K in reverse 0 .. AR.Length (Pattern, I) - 2 loop
            pragma Loop_Invariant (Work (Candidate));
            declare
               J : constant Natural := AR.Column (Pattern, I, K);
               M : constant Real := Mass (I * N + J);
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
