with MJ.Rigid_Math; use MJ.Rigid_Math;
package body MJ.Contact_Inflation with SPARK_Mode is
   procedure Inflate (First, Second : Vec; Margin1, Margin2 : Real;
                      First_Out, Second_Out : out Vec) is
      N : constant Vec := Unit (Sub (Second, First));
   begin
      First_Out := First; Second_Out := Second;
      if Margin1 /= 0.0 then First_Out := Add (First, Scale (N, Margin1)); end if;
      if Margin2 /= 0.0 then Second_Out := Sub (Second, Scale (N, Margin2)); end if;
   end Inflate;
end MJ.Contact_Inflation;
