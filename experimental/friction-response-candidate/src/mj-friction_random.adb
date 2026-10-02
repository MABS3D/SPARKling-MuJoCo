package body MJ.Friction_Random with SPARK_Mode is
   procedure Next (G : in out Generator; Value : out Unsigned_32) is
      Old_State : constant Unsigned_64 := G.State;
      X : constant Unsigned_32 := Unsigned_32
        (Shift_Right (Shift_Right (Old_State, 18) xor Old_State, 27) and 16#FFFF_FFFF#);
      R : constant Natural := Natural (Shift_Right (Old_State, 59));
   begin
      G.State := Old_State * 6_364_136_223_846_793_005 + (G.Increment or 1);
      Value := Shift_Right (X, R) or Shift_Left (X, (32 - R) mod 32);
   end Next;
end MJ.Friction_Random;
