with Ada.Numerics.Generic_Real_Arrays;

generic 
  type T is digits <>;
package Vector is
  package Vector_Math is new Ada.Numerics.Generic_Elementary_Functions(T);
  use Vector_Math;

  package Vector_Arrays is new Ada.Numerics.Generic_Real_Arrays (T);
  use Vector_Arrays;

  type Index_3D is range 0 .. 2;
  type Vector_3D is new Real_Vector (Index_3D);
  type Matrix_3D is new Real_Matrix (Index_3D, Index_3D);

  type Index_2D is range 0 .. 1;
  type Vector_2D is new Real_Vector (Index_2D);
  type Matrix_2D is new Real_Matrix (Index_2D, Index_2D);
  
end Vector;