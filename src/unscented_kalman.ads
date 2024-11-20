with Ada.Numerics.Generic_Real_Arrays;

generic
  type T is digits <>;
  type Sigma_Points_Index is range <>;
  type State_Vector_Index_Type is range <>;
  type Measurement_Vector_Index_Type is range <>;
package Unscented_Kalman is
  package Data_Arrays is new Ada.Numerics.Generic_Real_Arrays (T);
  use Data_Arrays;
  
  subtype Sigma_Points_Index_Range is Integer 
   range 
      Integer (Sigma_Points_Index'First) .. 
      Integer (Sigma_Points_Index'Last);
  subtype State_Vector_Index_Range is Integer 
   range 
      Integer (State_Vector_Index_Type'First) .. 
      Integer (State_Vector_Index_Type'Last);
  subtype Measurement_Vector_Index_Range is Integer 
   range 
      Integer (Measurement_Vector_Index_Type'First) .. 
      Integer (Measurement_Vector_Index_Type'Last);
  
  type Weights is new Real_Vector (Sigma_Points_Index_Range);
  type Sigma_Point_States is new Real_Matrix (Sigma_Points_Index_Range, State_Vector_Index_Range);

  type State is new Real_Vector (State_Vector_Index_Range);
  type State_Covariance is new Real_Matrix (State_Vector_Index_Range, State_Vector_Index_Range);

  type Measurement is new Real_Vector (Measurement_Vector_Index_Range);
  type Measurement_Covariance is new Real_Matrix (Measurement_Vector_Index_Range, Measurement_Vector_Index_Range);
  
  type Transition_Function is access function (
    Current_State : State
  ) return State;
  
  type Measurement_Function is access function (
    Measurement: State
  ) return Measurement;
  
  type State_Statistics is record
    Mean       : State;
    Covariance : State_Covariance;
  end record;
  
  type Measurement_Statistics is record
    Mean       : Measurement;
    Covariance : Measurement_Covariance;
  end record;
  
  type Sigma_Point_Weights is record
    Mean       : Weights;
    Covariance : Weights;
  end record;
  
  function Predict (
    Previous_Update             : State_Statistics;
    Sigma_Points                : Sigma_Point_States;
    State_To_Next_Map           : Transition_Function;
    Transition_Noise_Covariance : State_Covariance;
    Weights                     : Sigma_Point_Weights
  ) return State_Statistics;
  
  function Update (
    Previous_Prediction          : State_Statistics;
    Sigma_Points                 : in out Sigma_Point_States;
    State_To_Measurement_Map     : Measurement_Function;
    Measurement_Noise_Covariance : Measurement_Covariance;
    Weights                      : Sigma_Point_Weights
  ) return State_Statistics;

  function Get_Weights (Alpha, Beta, Kappa : T) return Sigma_Point_Weights;

private
  type Cross_Covariance_Matrix is new Real_Matrix (State_Vector_Index_Range, Measurement_Vector_Index_Range);
  type Sigma_Point_Measurements is new Real_Matrix (Sigma_Points_Index_Range, Measurement_Vector_Index_Range);

  generic
    type Propagated_Point_Type (<>) is new Real_Vector;
    type Propagated_Points_Type (<>) is new Real_Matrix;
    type Covariance_Type (<>) is new Real_Matrix;
    
    type Prediction_Type is private;
  function Predict_Statistics_Generic (
    Propagated_Points  : Propagated_Points_Type;
    Weights            : Sigma_Point_Weights;
    Noise_Covariance   : Covariance_Type
  ) return Prediction_Type;

  function Predict_State_Statistics is new Predict_Statistics_Generic (
    Propagated_Points_Type => Sigma_Point_States,
    Propagated_Point_Type => State,
    Covariance_Type => State_Covariance,
    Prediction_Type => State_Statistics
    );

  function Predict_Measurement_Statistics is new Predict_Statistics_Generic (
    Propagated_Points_Type => Sigma_Point_Measurements,
    Propagated_Point_Type => Measurement,
    Covariance_Type => Measurement_Covariance,
    Prediction_Type => Measurement_Statistics
  );

  function Update_Sigma_Points (
    Sigma_Points   : in out Sigma_Point_States;
    State_Estimate : State_Statistics
  ) return Sigma_Point_States;

end Unscented_Kalman;