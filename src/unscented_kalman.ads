with Ada.Numerics.Generic_Real_Arrays.Extended;

generic
  type T is digits <>;
  type Sigma_Points_Index is range <>;
  type State_Vector_Index_Type is range <>;
  type Measurement_Vector_Index_Type is range <>;
package Unscented_Kalman is
  package Data_Arrays is new Ada.Numerics.Generic_Real_Arrays(T);
  use Data_Arrays;
  package Extended_Matrix is new Data_Arrays.Extended;
  use Extended_Matrix;
  
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
  
  subtype Weights is Real_Vector (Sigma_Points_Index_Range);
  subtype Sigma_Point_States is Real_Matrix (Sigma_Points_Index_Range, State_Vector_Index_Range);

  subtype State is Real_Vector (State_Vector_Index_Range);
  subtype State_Covariance is Real_Matrix (State_Vector_Index_Range, State_Vector_Index_Range);

  subtype Measurement is Real_Vector (Measurement_Vector_Index_Range);
  subtype Measurement_Covariance is Real_Matrix (Measurement_Vector_Index_Range, Measurement_Vector_Index_Range);
  
  type Transition_Function is access function (
    Current_State : State
  ) return State;
  
  type Measurement_Function is access function (
    Measurement: State
  ) return Measurement;
  
  type Statistics (First : Integer; Last : Integer) is record
     Mean : Real_Vector (First .. Last);
     Covariance : Real_Matrix (First .. Last, First .. Last);
  end record;
  
  subtype State_Statistics is Statistics (State'First, State'Last);
  subtype Measurement_Statistics is Statistics (Measurement'First, Measurement'Last);
  
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
    Actual_Measurement           : Measurement;
    Sigma_Points                 : in out Sigma_Point_States;
    State_To_Measurement_Map     : Measurement_Function;
    Measurement_Noise_Covariance : Measurement_Covariance;
    Weights                      : Sigma_Point_Weights
  ) return State_Statistics;

  function Get_Weights (Alpha, Beta, Kappa : T) return Sigma_Point_Weights;

private
  subtype Cross_Covariance_Matrix is Real_Matrix (State_Vector_Index_Range, Measurement_Vector_Index_Range);
  subtype Sigma_Point_Measurements is Real_Matrix (Sigma_Points_Index_Range, Measurement_Vector_Index_Range);

  function Predict_Statistics (
    Propagated_Points  : Real_Matrix;
    Weights            : Sigma_Point_Weights;
    Noise_Covariance   : Real_Matrix
  ) return Statistics;

  function Update_Sigma_Points (
    Sigma_Points   : in out Sigma_Point_States;
    State_Estimate : State_Statistics
  ) return Sigma_Point_States;

end Unscented_Kalman;