package body Ada.Numerics.Generic_Real_Arrays.Extended is
   package Math is new Ada.Numerics.Generic_Elementary_Functions (Real);

   function Get_Row (Index : Integer; Matrix : Real_Matrix) return Real_Vector
   is
      Columns_Range : Integer range <> := Matrix'Range(2);
      Row : Real_Vector (Columns_Range);
   begin
      for Column_Index in Columns_Range loop
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
      Rows_Range : Integer range <> := Matrix'Range(1);
      Column : Real_Vector (Rows_Range);
   begin
      for Row_Index in Rows_Range loop
         Column (Column_Index) := Matrix (Row_Index, Index);
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

   procedure Cholesky_Decomposition (Matrix : Real_Matrix) return Real_Matrix
   is
      subtype Row_Indices is Matrix'Range(1);
      subtype Column_Indices is Matrix'Range(2);
      Decomposed_Matrix : Real_Matrix (Row_Indices, Column_Indices);
      
      Conventional_Last_Row_Index : Integer := Row_Indices'Last - Row_Indices'First;
   begin
      for I in 0 .. Conventional_Last_Row_Index loop
         for J in 0 .. I loop
            declare
               Column_I : Integer := I + Column_Indices'First;
               Column_J : Integer := J + Column_Indices'First;
               Row_I    : Integer := I + Row_Indices'First;
               Row_J    : Integer := J + Row_Indices'First;
               Sum      : Real := 0.0;
            begin
               for K in 0 .. J - 1 loop
                  declare
                     Column_K : Integer := K + Column_Indices'First;
                  begin
                     Sum := Sum + Decomposed_Matrix (Row_I, Column_K) * 
                                  Decomposed_Matrix (Row_J, Column_K);
                  end;
               end loop;
               if I = J then
                  Decomposed_Matrix (Row_I, Column_J) = 
                     Math.Sqrt (Matrix (Row_I, Column_I) - Sum);
               else
                  Decomposed_Matrix (Row_I, Column_J) = 
                     1.0 / Decomposed_Matrix (Row_J, Column_J) * 
                     (Matrix (Row_I, Column_J) - Sum)
               end if;
            end;
         end loop;
      end loop;
      return Decomposed_Matrix;
   end Cholesky_Decomposition;

end Ada.Numerics.Generic_Real_Arrays.Extended;