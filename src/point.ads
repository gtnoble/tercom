with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   type Float_Type is digits <>;
   type Point_Index_Type is range <>;
 package Point is 
    package Matrix_Package is new Ada.Numerics.Generic_Real_Arrays (Float_Type);
    
   subtype Vector_Type is Matrix_Package.Real_Vector;
   subtype Matrix_Type is Matrix_Package.Real_Matrix;

   type Covariance_Type is array (Point_Index_Type range <>, Point_Index_Type range <>) of Float_Type;
   package Covariance_Holders is new Ada.Containers.Indefinite_Holders (Covariance_Type);
   use Covariance_Holders;
   subtype Covariance_Holder_Type is Covariance_Holders.Holder;

   type Point_Type is array (Point_Index_Type range <>) of Float_Type;
   package Point_Holders is new Ada.Containers.Indefinite_Holders (Point_Type);
   use Point_Holders;
   subtype Point_Holder_Type is Point_Holders.Holder;

   type Point_Access is access Point_Type;
   type Displacement_Type is new Vector_Type;
   
   type Inverse_Covariance_Type is new Matrix_Type;
   type Kalman_Gain_Type is new Matrix_Type;
   type Covariance_Difference_Type is new Matrix_Type;

  function Calculate_Cross_Covariance (X, Y : Displacement_Type) return Covariance_Type;
  function Calculate_Autocovariance (X : Displacement_Type) return Covariance_Type;
  
  function Point (X : Vector_Type) return Point_Type;
  
  function "=" (X, Y : Point_Type) return Boolean;

  function "-" (X, Y : Point_Type) return Displacement_Type;
  function "-" (X, Y : Covariance_Type) return Covariance_Type;
  function "-" (X : Point_Type; Y : Displacement_Type) return Point_Type;


  function "+" (X, Y : Covariance_Type) return Covariance_Type;
  function "+" (X : Point_Type; Y : Displacement_Type) return Point_Type;

  function Inverse (X : Covariance_Type) return Inverse_Covariance_Type;
  function Transpose (X : Kalman_Gain_Type) return Kalman_Gain_Type;
  
  function "*" (X : Float_Type; Y : Covariance_Type) return Covariance_Type;
  function "*" (X : Covariance_Type; Y : Inverse_Covariance_Type) return Kalman_Gain_Type;
  function "*" (X : Kalman_Gain_Type; Y : Displacement_Type) return Displacement_Type;
  function "*" (X : Kalman_Gain_Type; Y : Covariance_Type) return Covariance_Type;
  function "*" (X : Covariance_Type; Y : Kalman_Gain_Type) return Covariance_Type;
  
  end Point;