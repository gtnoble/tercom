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

  type Sigma_Points_Matrix is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, State_Vector_Range);
  
  type State_Matrix is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, State_Vector_Range);
  type State_Covariance_Matrix is new Data_Arrays.Real_Matrix (State_Vector_Range, State_Vector_Range);
  type Transition_Matrix is new Data_Arrays.Real_Matrix (State_Vector_Range, State_Vector_Range);

  type Measurement_Matrix is new Data_Arrays.Real_Matrix (Sigma_Points_Vector_Range, Measurement_Vector_Range);
  type Measurement_Covariance_Matrix is new Data_Arrays.Real_Matrix (Measurement_Vector_Range, Measurement_Vector_Range);
  
  type Cross_Covariance_Matrix is new Data_Arrays.Real_Matrix (State_Vector_Range, Measurement_Vector_Range);
  
  type Transition_Function is access function (
    Sigma_Points: Sigma_Points_Matrix
  ) return Sigma_Points_Matrix;
  
  type Measurement_Function is access function (
    Sigma_Points: Sigma_Points_Matrix
  ) return Measurement_Matrix;
  
  type Filter_Estimate is record
    State : State_Vector;
    Covariance : Covariance_Vector;
  end record;

  function Initial_Estimate_Weights (Alpha, Kappa : T) return Estimate_Weights_Vector;
  function Estimate_Weights (Alpha, Kappa : T) return Estimate_Weights_Vector;

  function Initial_Covariance_Weights (Alpha, Beta, Kappa : T) return Covariance_Weights_Vector;
  function Covariance_Weights (Alpha, Kappa : T) return Covariance_Weights_Vector;
  
  procedure Update_Sigma_Points (
    Previous_Sigma_Points : in out Sigma_Points_Matrix; 
    Previous_State_Estimate : State_Vector; 
    Previous_State_Covariance : Covariance_Matrix);

  function Propagate_State (
    Sigma_Points : Sigma_Points_Matrix;
    Transition : Transition_Function
  ) return State_Matrix;
  
  function Predict_State (
    Propagated_State : Sigma_Points_Matrix; 
    Weights : Estimate_Weight
  ) return State_Vector;
  
  function Predict_State_Covariance (
    Propagated_State : State_Matrix;
    Predicted_State : State_Vector;
    Weights : Covariance_Weight;
    Transition_Noise_Covariance : State_Covariance_Matrix
  ) return State_Covariance_Matrix;
  
  function Propagate_Measurements (
    Sigma_Points : Sigma_Points_Matrix;
    Measurement : Measurement_Function
  ) return Measurement_Matrix;
  
  function Predict_Measurement (
    Propagated_Measurements : Measurement_Matrix;
    Weights : Estimate_Weight
  ) return Measurement_Vector;
  
  function Predict_Measurement_Covariance (
    Propagate_Measurements : Measurement_Matrix;
    Predicted_Measurement : Measurement_Vector;
    Weights : Covariance_Weight;
    Observation_Noise_Covariance : Measurement_Covariance_Matrix
  ) return Measurement_Covariance_Matrix;
  
  function State_Measurement_Cross_Covariance (
    Predicted_State : State_Vector;
    Propagated_State : Measurement_Matrix;
    Predicted_Measurement : Measurement_Vector;
    Propagated_Measurements : Measurement_Matrix
  ) return Cross_Covariance_Matrix;
  
  procedure Update_Kalman_Gain (
    Current_Kalman_Gain : Measurement_Covariance_Matrix;
    Cross_Covariance : Cross_Covariance_Matrix;
    Measurement_Covariance : Measurement_Covariance_Matrix
  );
  
  procedure Update_State_Estimate (
    Current_State : in out State_Vector;
    Predicted_State : State_Vector;
    Kalman_Gain : Measurement_Covariance_Matrix;
    Predicted_Measurement : Measurement_Covariance_Matrix;
    Propagated_Measurements : Measurement_Matrix
  );
  
  procedure Update_State_Covariance (
    Current_State_Covariance : in out State_Covariance_Matrix;
    Predicted_Covariance : State_Covariance_Matrix;
    Kalman_Gain : Measurement_Covariance_Matrix;
    Measurement_Covariance_Matrix : Measurement_Covariance_Matrix
  );

end Unscented_Kalman;