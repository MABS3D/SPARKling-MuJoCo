private package MJ.Data.Constrained.Equalities with SPARK_Mode is
   procedure Initialize
     (M : MJ.Models.Model; E : in out Engine; Result : out Status;
      Allow_Flex : Boolean := False);
   procedure Prepare (E : in out Engine; Result : out Status);
   procedure Assemble_One (E : in out Engine; Id : Natural; Result : out Status);
   procedure Assemble (E : in out Engine; Result : out Status);
end MJ.Data.Constrained.Equalities;
