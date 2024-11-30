with Ada.Numerics.Generic_Elementary_Functions;
with Generic_Real_Linear_Equations;

package body Matrix_Operations is

   function Get_Row (Index : Integer; Matrix : Real_Matrix) return Real_Vector
   is
      Row : Real_Vector (Matrix'Range (2));
   begin
      for Column_Index in Matrix'Range (2) loop
         Row (Column_Index) := Matrix (Index, Column_Index);
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
      for Column_Index in Row'Range loop
         Matrix (Index, Column_Index) := Row (Column_Index);
      end loop;
   end Set_Row;

   function Get_Column (Index : Integer; Matrix : Real_Matrix) return Real_Vector
   is
      Column : Real_Vector (Matrix'Range (1));
   begin
      for Row_Index in Matrix'Range (1) loop
         Column (Row_Index) := Matrix (Row_Index, Index);
      end loop;
      return Column;
   end Get_Column;

   procedure Set_Column (Index : Integer; Matrix : out Real_Matrix; Column : Real_Vector)
   is
   begin
      for Row_Index in Column'Range loop
         Matrix (Row_Index, Index) := Column (Row_Index);
      end loop;
   end Set_Column;
   
   function To_Column_Vector (Vector : Real_Vector) return Real_Matrix
   is
      Matrix : Real_Matrix (Vector'Range, 0 .. 0);
   begin
      for Index in Vector'Range loop
         Matrix (Index, 1) := Vector (Index);
      end loop;
      return Matrix;
   end To_Column_Vector;
   
   function To_Row_Vector (Vector : Real_Vector) return Real_Matrix
   is
      Matrix : Real_Matrix (0 .. 0, Vector'Range);
   begin
      for Index in Vector'Range loop
         Matrix (1, Index) := Vector (Index);
      end loop;
      return Matrix;
   end To_Row_Vector;

   function Cholesky_Decomposition (Matrix : Real_Matrix) return Real_Matrix
   is
      type Integer_Vector is array (Integer  range  <>) of Integer;
      package Linear_Equations is new Generic_Real_Linear_Equations 
         (Real => Real, 
         Real_Arrays => Real_Arrays, 
         Integer_Vector => Integer_Vector);
   begin
      return Linear_Equations.Cholesky_Decomposition  (Matrix);
   end Cholesky_Decomposition;

end Matrix_Operations;