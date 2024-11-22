package body Ada.Numerics.Generic_Real_Arrays.Extended is
   function Get_Row (Index : Integer; Matrix : Real_Matrix) return Real_Vector
   is
      Row : Real_Vector (Matrix'Range);
      Columns_Range : Integer range <> := Matrix'Range(2);
   begin
      for Column_Index in Columns_Range loop
         Row (Column_Index) := Matrix (Row_Index, Column_Index);
      end loop;
      return Row;
   end Get_Row;
   
   procedure Set_Row (
      Index: Integer; 
      Matrix : out Real_Matrix; 
      Row : Real_Vector
   )
   is
   begin
      for Column_Index in Value'Range loop
         Matrix (Index, Column_Index) := Row (Column_Index);
      end loop;
   end Set_Row;
   
   function To_Column_Vector (Vector : Real_Vector) return Real_Matrix
   is
      Matrix : Real_Matrix (Vector'Range, 1);
   begin
      for Index in Vector'Range loop
         Matrix (Index, 1) := Vector (Index);
      end loop;
      return Matrix;
   end Column_Vector;
   
   function To_Row_Vector (Vector : Real_Vector) return Real_Matrix
   is
      Matrix : Real_Matrix (1, Vector'Range);
   begin
      for Index in Vector'Range loop
         Matrix (1, Index) := Vector (Index);
      end loop;
      return Matrix;
   end Row_Vector;

end Ada.Numerics.Generic_Real_Arrays.Extended;