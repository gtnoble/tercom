pragma Assertion_Policy (Check);
package body Point is

   function Calculate_Cross_Covariance
     (X, Y : Displacement_Type) return Covariance_Type
   is
      First_Row_Index : constant Integer := Integer (X'First);
      Last_Row_Index : constant Integer := Integer (X'Last);
      First_Column_Index : constant Integer := Integer (Y'First);
      Last_Column_Index : constant Integer := Integer (Y'Last);

      Column_Vector    : Real_Matrix 
         (First_Row_Index .. Last_Row_Index, 
         First_Column_Index .. First_Column_Index);
      Row_Vector : Real_Matrix 
         (First_Row_Index .. First_Row_Index, 
         First_Column_Index .. Last_Column_Index);
   begin
      for Column in First_Column_Index .. Last_Column_Index loop
         Row_Vector (Column, First_Row_Index) := X (Point_Index_Type (Column));
      end loop;

      for Row in First_Row_Index .. Last_Row_Index loop
         Column_Vector (First_Column_Index, Row) := Y (Point_Index_Type (Row));
      end loop;

      return Covariance_Type (To_Matrix_Type (Column_Vector * Row_Vector));
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

   function "-" (X, Y : Vector_Type) return Displacement_Type is
   begin
      return Vector_Type (X) - Vector_Type (Y);
   end "-";

   function "-" (X, Y : Matrix_Type) return Matrix_Type is
   begin
      return To_Matrix_Type (To_Real_Matrix (X) - To_Real_Matrix (Y));
   end "-";

   function "*" (X : Float_Type; Y : Matrix_Type) return Matrix_Type is
   begin
      return To_Matrix_Type (X * To_Real_Matrix (Y));
   end "*";

   function "+" (X, Y : Matrix_Type) return Matrix_Type is
   begin
      return To_Matrix_Type (To_Real_Matrix (X) + To_Real_Matrix (Y));
   end "+";

   function "+" (X, Y : Vector_Type) return Vector_Type is
   begin
      return To_Vector_Type (To_Real_Vector(X) + To_Real_Vector(Y));
   end "+";

   function Inverse (X : Matrix_Type) return Matrix_Type is
   begin
      return To_Matrix_Type (Inverse (To_Real_Matrix (X)));
   end Inverse;

   function "*"
     (X,Y : Matrix_Type) return Matrix_Type
   is
   begin
      return To_Matrix_Type (To_Real_Matrix (X) * To_Real_Matrix (Y));
   end "*";

   function "*"
     (X : Matrix_Type; Y : Vector_Type) return Vector_Type is
   begin
      return To_Vector_Type (To_Real_Matrix (X) * To_Real_Vector (Y));
   end "*";

   function "*" (X : Float_Type; Y : Vector_Type) return Vector_Type is
   begin
      return To_Vector_Type (X * To_Real_Vector (Y));
   end "*";

   function "*" (X : Vector_Type; Y : Float_Type) return Vector_Type is
   begin
      return To_Vector_Type (Y * To_Real_Vector (X));
   end "*";

   function Transpose (X : Matrix_Type) return Matrix_Type is
   begin
      return To_Matrix_Type (Transpose (To_Real_Matrix (X)));
   end Transpose;
   
   function To_Matrix_Type (X : Real_Matrix) return Matrix_Type is
      
      Returned_Matrix : Matrix_Type 
         (Point_Index_Type (X'First (1)) .. Point_Index_Type (X'Last (1)),
         Point_Index_Type (X'First (2)) .. Point_Index_Type (X'Last (2)));
   begin
      for Row_Index in Returned_Matrix'Range(1) loop
         for Column_Index in Returned_Matrix'Range(2) loop
            Returned_Matrix (Row_Index, Column_Index) := X (Integer (Row_Index), Integer (Column_Index));
         end loop;
      end loop;
      return Returned_Matrix;
   end To_Matrix_Type;
   
   function To_Vector_Type (X : Real_Vector) return Vector_Type is
      Returned_Vector : Vector_Type (Point_Index_Type (X'First) .. Point_Index_Type (X'Last));
   begin
      for Index in Returned_Vector'Range loop
         Returned_Vector (Index) := X (Integer (Index));
      end loop;
      return Returned_Vector;
   end To_Vector_Type;
   
   function To_Real_Matrix (X : Matrix_Type) return Real_Matrix is
      Returned_Real_Matrix : Real_Matrix 
         (Integer (X'First (1)) .. Integer (X'Last (1)), 
            Integer (X'First (2)) .. Integer (X'Last(2)));
   begin
      for Row_Index in Returned_Real_Matrix'Range(1) loop
         for Column_Index in Returned_Real_Matrix'Range(2) loop
            Returned_Real_Matrix (Row_Index, Column_Index) := X 
               (Point_Index_Type (Row_Index), Point_Index_Type (Column_Index));
         end loop;
      end loop;
      return Returned_Real_Matrix;
   end To_Real_Matrix;
   
   function To_Real_Vector (X : Vector_Type) return Real_Vector is
      Returned_Vector : Real_Vector (Integer (X'First) .. Integer (X'Last));
   begin
      for Index in Returned_Vector'Range loop
         Returned_Vector (Index) := X (Point_Index_Type (Index));
      end loop;
      return Returned_Vector;
   end To_Real_Vector;

end Point;
