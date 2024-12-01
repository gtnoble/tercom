with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   with package Matrix_Package is new Ada.Numerics.Generic_Real_Arrays (<>);
   type Point_Index_Type is range <>;
package Point is
   use Matrix_Package;
   subtype Float_Type is Real;

   type Vector_Type is array (Point_Index_Type range <>) of Float_Type;
   type Matrix_Type is array (Point_Index_Type range <>, Point_Index_Type range <>) of Float_Type;

   subtype Covariance_Type is Matrix_Type;
   subtype Point_Type is Vector_Type;

   subtype Displacement_Type is Vector_Type;

   subtype Inverse_Covariance_Type is Matrix_Type;
   subtype Kalman_Gain_Type is Matrix_Type;
   subtype Covariance_Difference_Type is Matrix_Type;

   function Calculate_Cross_Covariance
     (X, Y : Displacement_Type) return Covariance_Type;
   function Calculate_Autocovariance
     (X : Displacement_Type) return Covariance_Type;

   function "=" (X, Y : Vector_Type) return Boolean;

   function "-" (X, Y : Vector_Type) return Vector_Type;
   function "-" (X, Y : Matrix_Type) return Matrix_Type;

   function "+" (X, Y : Matrix_Type) return Matrix_Type;
   function "+" (X, Y : Vector_Type) return Vector_Type;

   function Inverse (X : Matrix_Type) return Matrix_Type;
   function Transpose (X : Matrix_Type) return Matrix_Type;

   function "*" (X : Float_Type; Y : Matrix_Type) return Matrix_Type;
   function "*" (X, Y : Matrix_Type) return Matrix_Type;
   function "*" (X : Float_Type; Y : Vector_Type) return Vector_Type;
   function "*" (X : Vector_Type; Y : Float_Type) return Vector_Type;
   function "*" (X : Matrix_Type; Y : Vector_Type) return Vector_Type;
   
   function To_Matrix_Type (X : Real_Matrix) return Matrix_Type;
   function To_Real_Matrix (X : Matrix_Type) return Real_Matrix;
   function To_Vector_Type (X : Real_Vector) return Vector_Type;
   function To_Real_Vector (X : Vector_Type) return Real_Vector;

end Point;
