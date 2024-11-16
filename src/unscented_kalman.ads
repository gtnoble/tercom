with Ada.Numerics.Generic_Real_Arrays;

generic
  type T is digits <>;
  type Sigma_Points_Vector_Range is range <>;
  type State_Vector_Range is range <>;
  type Measurement_Vector_Range is range <>;
package Unscented_Kalman is
  package Data_Arrays is new Ada.Numerics.Generic_Real_Arrays (T);

  type State_Vector is new Data_Arrays.Real_Vector (State_Vector_Range);
  type Measurement_Vector is new Data_Arrays.Real_Vector (Measurement_Vector_Range);

  type Estimate_Weights_Vector is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, 1);
  type Covariance_Weights_Vector is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, 1);

  type State_Matrix is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, State_Vector_Range);
  type State_Covariance_Matrix is new Data_Arrays.Real_Matrix (State_Vector_Range, State_Vector_Range);
  type Transition_Matrix is new Data_Arrays.Real_Matrix (State_Vector_Range, State_Vector_Range);

  type Measurement_Matrix is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, Measurement_Vector_Range);
  type Measurement_Covariance_Matrix is new Data_Arrays.Real_Matrix (Measurement_Vector_Range, Measurement_Vector_Range);
  
  type Cross_Covariance_Matrix is new Data_Arrays.Real_Matrix (State_Vector_Range, Measurement_Vector_Range);
  
  type Transition_Function is access function (
    State: State_Vector
  ) return State_Vector;
  
  type State_Covariance is access function (
    State : State_Vector
  ) return State_Covariance_Matrix;
  
  type Measurement_Function is access function (
    Measurement: Measurement_Vector
  ) return State_Vector;
  
  type Measurement_Covariance is access function (
    Measurement : Measurement_Vector
  ) return Measurement_Covariance_Matrix;
  
  type Filter_Estimate is record
    State      : State_Matrix;
    Covariance : State_Covariance_Matrix;
  end record;
  
  function Predict (
    Current_Estimate : Filter_Estimate;
    State_Covariance : State_Covariance
  ) return Filter_Estimate;
  
  procedure Update (
    Current_Estimate : in out Filter_Estimate;
    Measurement_Covariance : Measurement_Covariance
  ) return Filter_Estimate;

private

  function Initial_Estimate_Weights (Alpha, Kappa : T) return Estimate_Weights_Vector;
  function Estimate_Weights (Alpha, Kappa : T) return Estimate_Weights_Vector;

  function Initial_Covariance_Weights (Alpha, Beta, Kappa : T) return Covariance_Weights_Vector;
  function Covariance_Weights (Alpha, Kappa : T) return Covariance_Weights_Vector;

  function Predict_State (
    Propagated_State : State_Matrix; 
    Weights          : Estimate_Weights_Vector
  ) return State_Vector;
  
  function Predict_State_Covariance (
    Propagated_State            : State_Matrix;
    Predicted_State             : State_Vector;
    Weights                     : Covariance_Weights_Vector;
    Transition_Noise_Covariance : State_Covariance_Matrix
  ) return State_Covariance_Matrix;

  function Update_State_Estimate (
    Predicted_State         : State_Vector;
    Kalman_Gain             : Measurement_Covariance_Matrix;
    Predicted_Measurement   : Measurement_Vector;
    Actual_Measurement : Measurement_Vector
  ) return State_Vector;
  
  function Update_State_Covariance (
    Predicted_Covariance          : State_Covariance_Matrix;
    Kalman_Gain                   : Measurement_Covariance_Matrix;
    Measurement_Covariance_Matrix : Measurement_Covariance_Matrix
  ) return State_Covariance_Matrix;
  
  function Update_Sigma_Points (
    Previous_State_Estimate   : State_Vector; 
    Previous_State_Covariance : Covariance_Matrix
  ) return State_Matrix;

  function Propagate_States (
    States : State_Matrix;
    Transition   : Transition_Function
  ) return State_Matrix;
  
  function Propagate_Measurements (
    States : State_Matrix;
    Measurement  : Measurement_Function
  ) return Measurement_Matrix;
  
  function Predict_Measurement (
    Propagated_Measurements : Measurement_Matrix;
    Weights                 : Estimate_Weights_Vector
  ) return Measurement_Vector;
  
  function Predict_Measurement_Covariance (
    Propagated_Measurements      : Measurement_Matrix;
    Predicted_Measurement        : Measurement_Vector;
    Weights                      : Covariance_Weights_Vector;
    Observation_Noise_Covariance : Measurement_Covariance_Matrix
  ) return Measurement_Covariance_Matrix;
  
  function State_Measurement_Cross_Covariance (
    Predicted_State         : State_Vector;
    Propagated_State        : Measurement_Matrix;
    Predicted_Measurement   : Measurement_Vector;
    Propagated_Measurements : Measurement_Matrix
  ) return Cross_Covariance_Matrix;

  function Kalman_Gain (
    Cross_Covariance       : Cross_Covariance_Matrix;
    Measurement_Covariance : Measurement_Covariance_Matrix
  ) return Measurement_Covariance_Matrix;

  function Sum_Columns (Matrix : Data_Arrays.Real_Matrix) return Data_Arrays.Real_Vector;
  function Matrix_Row (Matrix : Data_Arrays.Real_Matrix) return Data_Arrays.Real_Matrix;
  

end Unscented_Kalman;