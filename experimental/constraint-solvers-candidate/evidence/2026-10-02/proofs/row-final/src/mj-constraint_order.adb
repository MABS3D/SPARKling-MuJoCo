package body MJ.Constraint_Order with SPARK_Mode is
   procedure Next (Seed : in out Unsigned_64; Value : out Unsigned_32) is
      Old : constant Unsigned_64 := Seed;
      X : Unsigned_32;
      Rot : Natural;
   begin
      Seed := Old * 6_364_136_223_846_793_005 + 1;
      X := Unsigned_32
        (Shift_Right (Shift_Right (Old, 18) xor Old, 27) and 16#FFFF_FFFF#);
      Rot := Natural (Shift_Right (Old, 59));
      Value := Rotate_Right (X, Rot);
   end Next;
end MJ.Constraint_Order;
