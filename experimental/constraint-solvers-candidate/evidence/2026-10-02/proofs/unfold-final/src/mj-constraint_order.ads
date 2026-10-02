with Interfaces; use Interfaces;
package MJ.Constraint_Order with SPARK_Mode, Pure is
   --  Fixed-increment PCG32 used by MuJoCo's PGS shuffle. Arithmetic wraps
   --  in the declared modular types; this is the specified RNG operation.
   procedure Next (Seed : in out Unsigned_64; Value : out Unsigned_32)
   with Post => Seed = Seed'Old * 6_364_136_223_846_793_005 + 1
     and Value = Rotate_Right
       (Unsigned_32 (Shift_Right (Shift_Right (Seed'Old, 18) xor Seed'Old, 27)
          and 16#FFFF_FFFF#), Natural (Shift_Right (Seed'Old, 59)));
end MJ.Constraint_Order;
