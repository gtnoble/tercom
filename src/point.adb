pragma Assertion_Policy (Check);
package body Point is

   function Calculate_Cross_Covariance
     (X, Y : Displacement_Type) return Covariance_Type
   is
      First_Row_Index : constant Integer := X'First;
      First_Column_Index : constant Integer := Y'First;

      Column_Vector    : Real_Matrix 
         (X'Range, First_Column_Index .. First_Column_Index);
      Row_Vector : Real_Matrix 
         (First_Row_Index .. First_Row_Index, Y'Range);
   begin
      for Row in X'Range loop
         Column_Vector (Row, First_Row_Index) := X (Row);
      end loop;

      for Column in Y'Range loop
         Row_Vector (First_Column_Index, Column) := Y (Column);
      end loop;

      return Covariance_Type (Column_Vector * Row_Vector);
   end Calculate_Cross_Covariance;

   function Calculate_Autocovariance
     (X : Displacement_Type) return Covariance_Type
   is
   begin
      return Calculate_Cross_Covariance (X, X);
   end Calculate_Autocovariance;

   function "=" (X, Y : Vector_Type) return Boolean is
      Is_Equal : Boolean := True;
   begin
      for Index in X'Range loop
         Is_Equal := Is_Equal and then (X (Index) = Y (Index));
      end loop;
      return Is_Equal;
   end "=";

end Point;
