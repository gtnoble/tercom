with Ada.Numerics.Generic_Real_Arrays.Extended;
with Ada.Numerics.Generic_Elementary_Functions;
with Point;
with Point.Points;
with Point.Statistics;

generic
   type Float_Type is digits <>;
package Unscented_Kalman is

   subtype Sigma_Point_Index_Type is Integer;
   package Data_Point is new Point (Float_Type, Integer);
   package Data_Points is new Data_Point.Points (Sigma_Point_Index_Type);
   package Data_Statistics is new Data_Point.Statistics (Data_Points);

   subtype State_Point_Type is Data_Point.Point_Type;
   subtype Measurement_Point_Type is Data_Point.Point_Type;

   subtype State_Covariance_Type is Data_Point.Covariance_Type;
   subtype Measurement_Covariance_Type is Data_Point.Covariance_Type;

   package Math is new Ada.Numerics.Generic_Elementary_Functions (Float_Type);

   subtype State_Points_Type is Data_Points.Points_Type;
   subtype State_Statistics_Type is Data_Statistics.Statistics_Type;

   subtype Measurement_Points_Type is Data_Points.Points_Type;

   subtype Cross_Covariance_Type is Data_Point.Covariance_Type;

   type Kalman_Filter_Type is private;

   type Transition_Function is
     access function (Input : State_Point_Type) return State_Point_Type;

   type Measurement_Function is
     access function (Input : State_Point_Type) return Measurement_Point_Type;

   type Sigma_Weight_Parameters is record
      Alpha : Float_Type;
      Beta  : Float_Type;
      Kappa : Float_Type;
   end record;

   function Make_Kalman_Filter
     (Initial_State              : State_Point_Type;
      Initial_Covariance         : State_Covariance_Type;
      State_Transition           : Transition_Function;
      Measurement_Transformation : Measurement_Function;
      Num_Sigma_Points : Positive; Weight_Parameters : Sigma_Weight_Parameters)
      return Kalman_Filter_Type;

   function Predict
     (Filter                      : in out Kalman_Filter_Type;
      Transition_Noise_Covariance :        State_Covariance_Type)
      return State_Statistics_Type;

   function Update
     (Filter                       : in out Kalman_Filter_Type;
      Actual_Measurement           :        Measurement_Point_Type;
      Measurement_Noise_Covariance :        Measurement_Covariance_Type)
      return State_Statistics_Type;

private

   type Kalman_Filter_Type is record
      Current_Statistics         : State_Statistics_Type;
      Sigma_Points               : State_Points_Type;
      State_Transition           : Transition_Function;
      Measurement_Transformation : Measurement_Function;
      Weight_Parameters          : Sigma_Weight_Parameters;
   end record;

   procedure Update_Sigma_Points
     (Sigma_Points   : in out Data_Points.Points_Type;
      State_Estimate :        Data_Statistics.Statistics_Type;
      Center_Weight  :        Float_Type);

   function Mean_Weight_Function
     (Index                    : Sigma_Point_Index_Type;
      Weight_Parameters        : Sigma_Weight_Parameters;
      Sigma_Points_Index_Start : Sigma_Point_Index_Type;
      Sigma_Points_Index_End   : Sigma_Point_Index_Type) return Float_Type;

   function Covariance_Weight_Function
     (Index                    : Sigma_Point_Index_Type;
      Weight_Parameters        : Sigma_Weight_Parameters;
      Sigma_Points_Index_Start : Sigma_Point_Index_Type;
      Sigma_Points_Index_End   : Sigma_Point_Index_Type) return Float_Type;

end Unscented_Kalman;
