with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   with package Matrix_Package is new Ada.Numerics.Generic_Real_Arrays (<>);
package Point is
   use Matrix_Package;
   subtype Float_Type is Real;

   subtype Point_Index_Type is Integer; 

   subtype Vector_Type is Real_Vector;
   subtype Matrix_Type is Real_Matrix;

   type Covariance_Type is new Matrix_Type;
   type Point_Type is new Vector_Type;

   type Displacement_Type is new Vector_Type;

   type Inverse_Covariance_Type is new Matrix_Type;
   type Kalman_Gain_Type is new Matrix_Type;
   type Covariance_Difference_Type is new Matrix_Type;

   function Calculate_Cross_Covariance
     (X, Y : Displacement_Type) return Covariance_Type;
   function Calculate_Autocovariance
     (X : Displacement_Type) return Covariance_Type;

   function "=" (X, Y : Point_Type) return Boolean;

   function "-" (X, Y : Point_Type) return Displacement_Type;
   function "-" (X, Y : Covariance_Type) return Covariance_Type;
   function "-" (X : Point_Type; Y : Displacement_Type) return Point_Type;

   function "+" (X, Y : Covariance_Type) return Covariance_Type;
   function "+" (X : Point_Type; Y : Displacement_Type) return Point_Type;

   function Inverse (X : Covariance_Type) return Inverse_Covariance_Type;
   function Transpose (X : Kalman_Gain_Type) return Kalman_Gain_Type;

   function "*" (X : Float_Type; Y : Covariance_Type) return Covariance_Type;
   function "*"
     (X : Covariance_Type; Y : Inverse_Covariance_Type)
      return Kalman_Gain_Type;
   function "*"
     (X : Kalman_Gain_Type; Y : Displacement_Type) return Displacement_Type;
   function "*"
     (X : Kalman_Gain_Type; Y : Covariance_Type) return Covariance_Type;
   function "*"
     (X : Covariance_Type; Y : Kalman_Gain_Type) return Covariance_Type;

end Point;
