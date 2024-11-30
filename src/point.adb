package body Point is

   function Calculate_Cross_Covariance
     (X, Y : Displacement_Type) return Covariance_Type
   is
      Row_Matrix    : Matrix_Type (X'Range, 0 .. 0);
      Column_Matrix : Matrix_Type (0 .. 0, Y'Range);
   begin
      for Row in X'Range loop
         Row_Matrix (Row, 0) := X (Row);
      end loop;

      for Column in Y'Range loop
         Column_Matrix (0, Column) := Y (Column);
      end loop;

      return Covariance_Type (Row_Matrix * Column_Matrix);
   end Calculate_Cross_Covariance;

   function Calculate_Autocovariance
     (X : Displacement_Type) return Covariance_Type
   is
   begin
      return Calculate_Cross_Covariance (X, X);
   end Calculate_Autocovariance;

   function "=" (X, Y : Point_Type) return Boolean is
      Is_Equal : Boolean := True;
   begin
      for Index in X'Range loop
         Is_Equal := Is_Equal and then (X (Index) = Y (Index));
      end loop;
      return Is_Equal;
   end "=";

   function "-" (X, Y : Point_Type) return Displacement_Type is
   begin
      return Displacement_Type (Vector_Type (X) - Vector_Type (Y));
   end "-";

   function "-" (X, Y : Covariance_Type) return Covariance_Type is
   begin
      return Covariance_Type (X - Y);
   end "-";

   function "-" (X : Point_Type; Y : Displacement_Type) return Point_Type is
   begin
      return Point_Type (X - Y);
   end "-";

   function "*" (X : Float_Type; Y : Covariance_Type) return Covariance_Type is
   begin
      return Covariance_Type (X * Real_Matrix (Y));
   end "*";

   function "+" (X, Y : Covariance_Type) return Covariance_Type is
   begin
      return Covariance_Type (Real_Matrix (X) + Real_Matrix (Y));
   end "+";

   function "+" (X : Point_Type; Y : Displacement_Type) return Point_Type is
   begin
      return Point_Type (X + Y);
   end "+";

   function Inverse (X : Covariance_Type) return Inverse_Covariance_Type is
   begin
      return Inverse_Covariance_Type (Inverse (Real_Matrix (X)));
   end Inverse;

   function "*"
     (X : Covariance_Type; Y : Inverse_Covariance_Type) return Kalman_Gain_Type
   is
   begin
      return Kalman_Gain_Type (Real_Matrix (X) * Real_Matrix (Y));
   end "*";

   function "*"
     (X : Kalman_Gain_Type; Y : Covariance_Type) return Covariance_Type
   is
   begin
      return Covariance_Type (Real_Matrix (X) * Real_Matrix (Y));
   end "*";

   function "*"
     (X : Kalman_Gain_Type; Y : Displacement_Type) return Displacement_Type is
   begin
      return Displacement_Type (X * Y);
   end "*";

   function "*"
     (X : Covariance_Type; Y : Kalman_Gain_Type) return Covariance_Type is
   begin
      return Covariance_Type (X * Y);
   end "*";

   function Transpose (X : Kalman_Gain_Type) return Kalman_Gain_Type is
   begin
      return Kalman_Gain_Type (Transpose (X));
   end Transpose;

end Point;
