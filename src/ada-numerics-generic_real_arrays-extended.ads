generic
package Ada.Numerics.Generic_Real_Arrays.Extended is

   function Get_Row (Index : Integer; Matrix : Real_Matrix) return Real_Vector;
   procedure Set_Row (Index : Integer; Matrix : out Real_Matrix; Row : Real_Vector);
   
   function To_Column_Vector (Vector : Real_Vector) return Real_Matrix;
   function To_Row_Vector (Vector : Real_Vector) return Real_Matrix;
   

end Ada.Numerics.Generic_Real_Arrays.Extended;