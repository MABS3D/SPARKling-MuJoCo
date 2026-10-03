-- Uses already prepared current rows, without rerunning the forward solver.
package MJ.Data.Constrained.Inverse with SPARK_Mode is
   procedure Current
     (E : Engine; Qacc : State_Vector; Required_Force, Row_Force : in out Real_Array;
      Result : out Status)
     with Global => null,
       Post => (if Result /= Success then
         Required_Force = Required_Force'Old and Row_Force = Row_Force'Old);
end MJ.Data.Constrained.Inverse;
