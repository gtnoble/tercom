with AUnit.Assertions; use AUnit.Assertions;

package body Unscented_Kalman_Test is

   function Name (T : Unscented_Kalman_Fixture) return Message_String
   is
   begin
      return Format ("Unscented Kalman Filter Tests");
   end Name;
   
   procedure Set_Up (T : in out Unscented_Kalman_Fixture)
   is
   begin
      null;
   end Set_Up;
   
  function Transition_Function (State : State_Point_Type) return State_Point_Type
  is
   begin
      return (State (1) + State (2), State(2));
   end Transition_Function;

  function Measurement_Function (State : State_Point_Type) return Measurement_Point_Type
  is
  begin
     return (1 => State (1));
  end Measurement_Function;
   
   procedure Test_Make_Kalman_Filter (T : in out Unscented_Kalman_Fixture)
   is
      Kalman_Filter : Unscented_Kalman_Instance.Kalman_Filter_Type;
   begin
      Kalman_Filter := Unscented_Kalman_Instance.Make_Kalman_Filter(
         Initial_State => Test_Initial_State,
         Initial_Covariance => Test_Initial_Covariance,
         State_Transition => Transition_Function'Access,
         Measurement_Transformation => Measurement_Function'Access,
         Weight_Parameters => Weight_Parameters
      );

   end Test_Make_Kalman_Filter;

end Unscented_Kalman_Test;