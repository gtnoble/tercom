
 package body Point is 

  function Calculate_Cross_Covariance (X, Y : Displacement_Type) return Covariance_Type
   is
      Row_Matrix : Matrix_Type (X'Range, 1);
      Column_Matrix : Matrix_Type (1, Y'Range);
   begin
      for Row in X'Range loop
         Row_Matrix (Row, 1) := X (Row);
      end loop;

      for Column in Y'Range loop
         Column_Matrix (1, Column) := Y (Column);
      end loop;
      
      return Row_Matrix * Column_Matrix;
   end Calculate_Cross_Covariance;
   
   function Calculate_Autocovariance (X : Displacement_Type) return Covariance_Type
      is
      begin
         return Calculate_Cross_Covariance (X, X);
      end Calculate_Autocovariance;
      
   function "=" (X, Y: Point_Type) return Boolean
   is
      Is_Equal : Boolean := True;
   begin
      for Index in X'Range loop
         Is_Equal := Is_Equal and then (X (Index) = Y (Index));
      end loop;
      return Is_Equal;
   end "=";
   

   function "-" (X, Y: Point_Type) return Displacement_Type
   is
   begin
      return Displacement_Type (Vector_Type (X) - Vector_Type (Y));
   end "-";
   
   function "*" (X : Float_Type; Y : Covariance_Type) return Covariance_Type
   is
   begin
      return Covariance_Type (X * Real_Matrix (Covariance_Type));
   end "*";
   
   function "+" (X, Y : Covariance_Type) return Covariance_Type
      is
      begin
         return Covariance_Type (Real_Matrix (X) + Real_Matrix (Y));
      end "+";
      
   function Inverse (X : Covariance_Type) return Inverse_Covariance_Type
      is
      begin
         return Inverse_Covariance_Type (Real_Matrix.Inverse (Real_Matrix (X)));
      end Inverse;
      
   function "*" (X : Covariance_Type; Y : Inverse_Covariance_Type) return Kalman_Gain_Type
      is
      begin
         return Kalman_Gain_Type (Real_Matrix (X) * Real_Matrix (Y));
      end "*";
      
   function "*" (X : Kalman_Gain_Type; Y : Covariance_Type) return Covariance_Type
   is
   begin
      return Covariance_Type (Real_Matrix (X) * Real_Matrix (Y));
   end "*";
  

  end Point;