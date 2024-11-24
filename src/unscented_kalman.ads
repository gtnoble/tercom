with Ada.Numerics.Generic_Real_Arrays.Extended;
with Ada.Numerics.Generic_Elementary_Functions;
with Ada.Containers; use Ada.Containers;
with Ada.Containers.Vectors;

generic
  type T is digits <>;
package Unscented_Kalman is
   package Math is new Ada.Numerics.Generic_Elementary_Functions (T);

  package Data_Arrays is new Ada.Numerics.Generic_Real_Arrays(T);
  use Data_Arrays;
  package Extended_Matrix is new Data_Arrays.Extended;
  use Extended_Matrix;
  
  subtype Point_Type is Real_Vector;
  subtype Matrix_Type is Real_Matrix;
  
  subtype Covariance_Type is Matrix_Type;
  subtype Cross_Covariance_Type is Matrix_Type;
  subtype Kalman_Gain_Type is Matrix_Type;
  
  subtype State_Point_Type is Point_Type;
  subtype State_Covariance_Type is Covariance_Type;

  subtype Measurement_Point_Type is Point_Type;
  subtype Measurement_Covariance_Type is Covariance_Type;
  
  package Points is new Ada.Containers.Vectors
    (Index_Type   => Integer,
     Element_Type => Point_Type
    );
  
  subtype Points_Type is Points_Vectors.Vector;
   
  type Kalman_Filter_Type (
   Num_Sigma_Points : Positive;
   State_Vector_Dimensionality: Positive
   ) is private;
  type Kalman_Filter_Access is access Kalman_Filter_Type;
  
  type Transition_Function is access function (
   Input : State_Point_Type
  ) return State_Point_Type;
  
  type Measurement_Function is access function (
   Input : State_Point_Type
  ) return Measurement_Point_Type;
  
  type Statistics (Point_Dimensionality : Positive) is record
     Mean : Point_Type (1 .. Point_Dimensionality);
     Covariance : Matrix_Type (1 .. Point_Dimensionality, 1 .. Point_Dimensionality);
  end record;
  
  subtype State_Statistics is Statistics;

  type Sigma_Weight_Parameters is record
   Alpha : T;
   Beta : T;
   Kappa : T;
   end record;
  
  function Kalman_Filter (
   Initial_State : State_Point_Type;
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
    Actual_Measurement           : Measurement_Point_Type;
    Measurement_Noise_Covariance : Measurement_Covariance_Type
  ) return Statistics;

private
   subtype Sigma_Points_Type is Points_Type;
   subtype Measurement_Points_Type is Points_Type;

   subtype Sigma_Point_Weight_Type is Point_Type;
  
  subtype Measurement_Statistics is Statistics;

  subtype Sigma_Measurements_Type is Matrix_Type;

  type Sigma_Point_Weights (Num_Sigma_Points : Positive) is record
    Mean       : Sigma_Point_Weight_Type (1 .. Num_Sigma_Points);
    Covariance : Sigma_Point_Weight_Type (1  .. Num_Sigma_Points);
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
   
  function Get_Weights (
   Alpha, Beta, Kappa : T;
   Num_Sigma_Points : Positive
   ) return Sigma_Point_Weights;
  
  function Predict_Statistics (
    Propagated_Points  : Points_Type;
    Weights            : Sigma_Point_Weights;
    Noise_Covariance   : Covariance_Type
  ) return Statistics;

  function Update_Sigma_Points (
    Sigma_Points   : Sigma_Points_Type;
    State_Estimate : State_Statistics;
    Alpha : T;
    Kappa : T
  ) return Sigma_Points_Type;
  
  function Calculate_Cross_Covariance (X, Y : Point_Type) return Covariance_Type;
  function Calculate_Autocovariance (X : Point_Type) return Covariance_Type;

end Unscented_Kalman;