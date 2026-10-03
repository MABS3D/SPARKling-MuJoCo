package body MJ.Flex_Response_Kernels with SPARK_Mode is
   function Scale (Value : Jacobian_Value; Weight : Body_Weight) return Product_Value is
     (Weight * Value);
   function Add (Previous : Work; Term : Product_Value) return Real is (Previous + Term);

   function Advance (A : Accumulator; C : Contribution; Visited : Prefix)
     return Accumulator is
   begin
      if not C.Present then return A; end if;
      declare
         Term : constant Product_Value := Scale (C.Value, C.Weight);
      begin
         if A.Present then return (True, Add (A.Value, Term));
         else return (True, Term); end if;
      end;
   end Advance;

   function Fold (Terms : Contributions; Count : Prefix; Seed_Present : Boolean)
     return Accumulator is
   begin
      if Count = 0 then return (Seed_Present, 0.0);
      else
         return Advance (Fold (Terms, Count - 1, Seed_Present), Terms (Count - 1), Count - 1);
      end if;
   end Fold;

   procedure Combine (Terms : Contributions; Count : Prefix; Seed_Present : Boolean;
     Value : out Accumulator) is
   begin
      Value := (Seed_Present, 0.0);
      for I in 0 .. Integer (Count) - 1 loop
         Value := Advance (Value, Terms (I), I);
         pragma Loop_Invariant (Static => Bounded (Value, I + 1));
         pragma Loop_Invariant (Static => Value = Fold (Terms, I + 1, Seed_Present));
      end loop;
   end Combine;

   function Frame_Step (Previous : Real; Value : Work; Weight : Frame_Value) return Real is
     (if Weight = 0.0 then Previous else Previous + Weight * Value);
   function Project (X, Y, Z : Work; A, B, C : Frame_Value) return Real is
     (Frame_Step (Frame_Step (Frame_Step (0.0, X, A), Y, B), Z, C));
end MJ.Flex_Response_Kernels;
