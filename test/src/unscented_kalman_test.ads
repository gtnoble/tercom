with Aunit; use Aunit;
with Aunit.Test_Fixtures;
with Unscented_Kalman;
with Ada.Numerics.Generic_Real_Arrays;
with Point;

package Unscented_Kalman_Test is

   subtype Float_Type is Float;
   package Matrix is new Ada.Numerics.Generic_Real_Arrays (Float_Type);
   use Matrix;

   type Unscented_Kalman_Fixture is
   new Aunit.Test_Fixtures.Test_Fixture with null record;

   package Unscented_Kalman_Instance is new Unscented_Kalman (Matrix);
   use Unscented_Kalman_Instance;

   procedure Set_Up (T : in out Unscented_Kalman_Fixture);

   function Name (T : Unscented_Kalman_Fixture) return Message_String;

   function Transition_Function
     (State : State_Point_Type) return State_Point_Type;
   function Measurement_Function
     (State : State_Point_Type) return Measurement_Point_Type;

   procedure Test_Make_Kalman_Filter (T : in out Unscented_Kalman_Fixture);

   procedure Test_Predict (T : in out Unscented_Kalman_Fixture);
private
   Weight_Parameters : Unscented_Kalman_Instance.Sigma_Weight_Parameters :=
     (Alpha => 1.0, Beta => 2.0, Kappa => 3.0);

   Test_Initial_State      : State_Point_Type (0 .. 1) := (0.0, 1.0); 
   Test_Initial_Covariance : State_Covariance_Type (0 .. 1, 0 .. 1) := ((1.0, 0.0), (0.0, 1.0));
   
   Expected_Predicted_State : State_Point_Type (0 .. 1) := (1.0, 1.0);

end Unscented_Kalman_Test;
