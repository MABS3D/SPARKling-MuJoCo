with MJ.Data.Forces_Phase;

package body MJ.Data.Forces with SPARK_Mode is
   procedure Compute (D : in out Simulation; Result : out Status) is
   begin
      if not Is_Ready (D) then
         Result := Not_Allocated;
         return;
      end if;
      Forces_Phase.Compute (D, Result);
   end Compute;
end MJ.Data.Forces;
