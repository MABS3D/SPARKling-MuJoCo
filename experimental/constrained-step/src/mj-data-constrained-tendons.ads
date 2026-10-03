--  Owned metadata and Jacobian adapter for the opt-in constrained step.
--  Composition proof with the existing smooth/geometry producers remains open.
private package MJ.Data.Constrained.Tendons with SPARK_Mode is
   procedure Initialize (M : MJ.Models.Model; E : in out Engine; Result : out Status);
   procedure Update (E : in out Engine; Result : out Status);
   procedure Add_Friction (E : in out Engine; Result : out Status);
   procedure Add_Limits (E : in out Engine; Result : out Status);
end MJ.Data.Constrained.Tendons;
