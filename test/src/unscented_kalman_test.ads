with Aunit; use Aunit;
with Aunit.Test_Fixtures;
with Unscented_Kalman;
with Ada.Numerics.Generic_Real_Arrays;
with Point;

package Unscented_Kalman_Test is
   
   subtype Float_Type is Float;
  package Matrix is new Ada.Numerics.Generic_Real_Arrays (Float_Type);
  
  type Unscented_Kalman_Fixture is new Aunit.Test_Fixtures.Test_Fixture with null record;
  
  package Unscented_Kalman_Instance is new Unscented_Kalman (
   Float
   );
  use Unscented_Kalman_Instance;

   procedure Set_Up (T : in out Unscented_Kalman_Fixture);
  
  function Name (T : Unscented_Kalman_Fixture) return Message_String;
  
  function Transition_Function (State : State_Point_Type) return State_Point_Type;
  function Measurement_Function (State : State_Point_Type) return Measurement_Point_Type;
  
  procedure Test_Make_Kalman_Filter (T : in out Unscented_Kalman_Fixture);
  --procedure Test_Predict (T : in out Test_Cases.Test_Case'Class);
  --procedure Test_Update (T : in out Test_Cases.Test_Case'Class);
private
   Weight_Parameters : Unscented_Kalman_Instance.Sigma_Weight_Parameters := (
      Alpha => 1.0,
      Beta => 2.0,
      Kappa => 3.0
   );
   
   Test_Initial_State : State_Point_Type := 
      (0.0, 0.0);
   Test_Initial_Covariance : State_Covariance_Type := 
      (
         (0.0, 0.0), 
         (0.0, 0.0)
      );
   Test_Num_Sigma_Points : Positive := 4;

end Unscented_Kalman_Test;