with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   with package Matrix_Package is new Ada.Numerics.Generic_Real_Arrays (<>);
package Point is
   use Matrix_Package;
   subtype Float_Type is Real;

   subtype Vector_Type is Real_Vector;
   subtype Matrix_Type is Real_Matrix;

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

end Point;
