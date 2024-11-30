with Ada.Numerics.Generic_Real_Arrays;

generic
   with package Real_Arrays is new Ada.Numerics.Generic_Real_Arrays (<>);
package Matrix_Operations is
   use Real_Arrays;

   function Get_Row (Index : Integer; Matrix : Real_Matrix) return Real_Vector;
   procedure Set_Row (Index : Integer; Matrix : out Real_Matrix; Row : Real_Vector);
   
   function Get_Column (Index : Integer; Matrix : Real_Matrix) return Real_Vector;
   procedure Set_Column (Index : Integer; Matrix : out Real_Matrix; Column : Real_Vector);
   
   function To_Column_Vector (Vector : Real_Vector) return Real_Matrix;
   function To_Row_Vector (Vector : Real_Vector) return Real_Matrix;
   
   function Cholesky_Decomposition (Matrix : Real_Matrix) return Real_Matrix;

end Matrix_Operations;