with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   type Points_Index_Type is range <>;
package Point.Points is
   
  type Statistics_Type is private;
  
  type Points_Type is private;
  
  type Weight_Function is access function (
   Index : Points_Index_Type
  ) return Float_Type;
  
  function New_Points (
   Points_Start_Index, Points_End_Index : Points_Index_Type
   ) return Points_Type;
  
  function First (Points : Points_Type) return Points_Index_Type;
  function Last (Points : Points_Type) return Points_Index_Type;
  function Get (Points : Points_Type; Index : Points_Index_Type) return Point_Type;
  procedure Set (Points : in out Points_Type; Index : Points_Index_Type; Value : Point_Type);
  function Num_Points (Points : Points_Type) return Natural;
  
  function Point_First (Points : Points_Type) return Point_Index_Type;
  function Point_Last (Points : Points_Type) return Point_Index_Type;
  function Point_Dimension (Points : Points_Type) return Positive;

  function Points_To_Matrix (X : Points_Type) return Matrix_Type;
  function Matrix_To_Points (X : Matrix_Type) return Points_Type;
  
  function Mean (Statistics : Statistics_Type) return Point_Type;
  function Covariance (Statistics : Statistics_Type) return Covariance_Type;
  
  
  function Predict_Statistics (
    Propagated_Points  : Points_Type;
    Mean_Weights       : Weight_Function;
    Covariance_Weights : Weight_Function;
    Noise_Covariance   : Covariance_Type
  ) return Statistics_Type;
   
  function Make_Statistics (Mean : Point_Type; Covariance : Covariance_Type) return Statistics_Type;
private

  type Points_Array_Type is array (Points_Index_Type) of Point_Holder_Type;
  package Points_Array_Holders is new Ada.Containers.Indefinite_Holders (Points_Array_Type);
  use Points_Array_Holders;
  subtype Points_Array_Holder_Type is Points_Array_Holders.Holder;
  
   type Points_Type is record
      Points : Points_Array_Holder_Type;
      Point_Start_Index : Point_Index_Type;
      Point_End_Index : Point_Index_Type;
   end record;

  type Statistics_Type is record
     Mean : Point_Holder_Type;
     Covariance : Covariance_Holder_Type;
  end record;
  
end Point.Points;