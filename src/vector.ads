generic 
  type T is digits <>;
package Vector is
  package Vector_Math is new Ada.Numerics.Generic_Elementary_Functions(T);
  use Vector_Math;

  type Index_3D is range 0 .. 2;
  type Index_2D is range 0 .. 1;

  type Vector_3D is array (Index_3D) of T;
  type Vector_2D is array (Index_2D) of T;

  type Matrix_3D is record 
    Is_Transposed : Boolean;
    Elements : array (Index_3D) of Vector_3D;
  end record;

  type Matrix_2D is record 
    Is_Transposed : Boolean;
    Elements : array (Index_2D) of Vector_2D;
  end record;

  function Dot (X, Y : Vector_3D) return Precise_Float;
  
end Vector;