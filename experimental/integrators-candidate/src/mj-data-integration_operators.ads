private package MJ.Data.Integration_Operators with SPARK_Mode is
   procedure Build (D : in out Simulation; Full_Bias, Discrete, Use_Couplings : Boolean;
      Deriv, Addition, Shift, Backbone, Gyro : out Real_Array;
      Has_Couplings : out Boolean; Result : out Status)
      with Global => null, Pre => Is_Ready (D);
   function Standalone_Free (D : Simulation; Row : Natural) return Boolean
      with Global => null, Pre => Is_Ready (D) and then Row < D.Nv;
end MJ.Data.Integration_Operators;
