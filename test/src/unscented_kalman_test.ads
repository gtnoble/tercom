with Aunit; use Aunit;
with Aunit.Test_Fixtures;
with Unscented_Kalman;

package Unscented_Kalman_Test is
  subtype Sigma_Points_Index_Type is Integer range 1..2;
  subtype State_Vector_Index_Type is Integer range 1..2;
  subtype Measurement_Vector_Index_Type is Integer range 1..2;
  
  type Unscented_Kalman_Fixture is new Aunit.Test_Fixtures.Test_Fixture with null record;
  
  package Test_Kalman_Filter is new Unscented_Kalman (
    T => Float,
    Sigma_Points_Index => Sigma_Points_Index_Type,
    State_Vector_Index_Type => State_Vector_Index_Type,
    Measurement_Vector_Index_Type => Measurement_Vector_Index_Type
  );
  
   procedure Set_Up (T : in out Unscented_Kalman_Fixture);
  
  function Name (T : Unscented_Kalman_Fixture) return Message_String;
  
  procedure Test_Get_Weights (T : in out Unscented_Kalman_Fixture);
  --procedure Test_Predict (T : in out Test_Cases.Test_Case'Class);
  --procedure Test_Update (T : in out Test_Cases.Test_Case'Class);

end Unscented_Kalman_Test;