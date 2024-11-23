with Ada.Numerics.Generic_Real_Arrays.Extended;
with Ada.Numerics.Generic_Elementary_Functions;

generic
  type T is digits <>;
package Unscented_Kalman is
   package Math is new Ada.Numerics.Generic_Elementary_Functions (T);

  package Data_Arrays is new Ada.Numerics.Generic_Real_Arrays(T);
  use Data_Arrays;
  package Extended_Matrix is new Data_Arrays.Extended;
  use Extended_Matrix;
  
  type State_Vector_Type is array (Positive range <>) of T;
  type State_Covariance_Type is array (Positive range <>, Positive range <>) of T;

  type Measurement_Vector_Type is array (Positive range <>) of T;
  type Measurement_Covariance_Type is array (Positive range <>, Positive range <>) of T;
   
  type Kalman_Filter_Type (
   Num_Sigma_Points : Positive;
   State_Vector_Dimensionality: Positive
   ) is private;
  type Kalman_Filter_Access is access Kalman_Filter_Type;
  
  type Transition_Function is access function (
   Input : State_Vector_Type
  ) return State_Vector_Type;
  
  type Measurement_Function is access function (
   Input : State_Vector_Type
  ) return Measurement_Vector_Type;
  
  type Statistics (Point_Dimensionality : Positive) is record
     Mean : Real_Vector (1 .. Point_Dimensionality);
     Covariance : Real_Matrix (1 .. Point_Dimensionality, 1 .. Point_Dimensionality);
  end record;
  
  type State_Statistics is new Statistics;

  type Sigma_Weight_Parameters is record
   Alpha : T;
   Beta : T;
   Kappa : T;
   end record;
  
  function Kalman_Filter (
   Initial_State : State_Vector_Type;
   Initial_Covariance : State_Covariance_Type;
   State_Transition : Transition_Function;
   Measurement_Transformation : Measurement_Function;
   Weight_Parameters : Sigma_Weight_Parameters;
   Num_Sigma_Points : Positive
  ) return Kalman_Filter_Access;
  
  function Predict (
   Filter : in out Kalman_Filter_Access;
   Transition_Noise_Covariance : State_Covariance_Type
  ) return Statistics;
  
  function Update (
   Filter : in out Kalman_Filter_Access;
    Actual_Measurement           : Measurement_Vector_Type;
    Measurement_Noise_Covariance : Measurement_Covariance_Type
  ) return Statistics;

private
   type Sigma_Points_Type is new Real_Matrix;
  
  type Measurement_Statistics is new Statistics;

  type Sigma_Measurements_Type is new Real_Matrix;

  type Sigma_Point_Weights (Num_Sigma_Points : Positive) is record
    Mean       : Real_Vector (1 .. Num_Sigma_Points);
    Covariance : Real_Vector (1  .. Num_Sigma_Points);
  end record;
  
   type Kalman_Filter_Type (
      Num_Sigma_Points : Positive; 
      State_Vector_Dimensionality : Positive) 
   is record
      Current_Statistics : State_Statistics (State_Vector_Dimensionality);
      Sigma_Points : Sigma_Points_Type (1 .. Num_Sigma_Points, 1 .. State_Vector_Dimensionality);
      State_Transition : Transition_Function;
      Measurement_Transformation : Measurement_Function;
      Weight_Parameters : Sigma_Weight_Parameters;
      Weights : Sigma_Point_Weights (Num_Sigma_Points);
   end record;
   
  function Get_Weights (Alpha, Beta, Kappa : T) return Sigma_Point_Weights;
  
  function Predict_Statistics (
    Propagated_Points  : Real_Matrix;
    Weights            : Sigma_Point_Weights;
    Noise_Covariance   : Real_Matrix
  ) return Statistics;

  function Update_Sigma_Points (
    Sigma_Points   : Sigma_Points_Type;
    State_Estimate : State_Statistics;
    Alpha : T;
    Kappa : T
  ) return Sigma_Points_Type;

end Unscented_Kalman;