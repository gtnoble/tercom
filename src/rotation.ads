generic
  type T is digits <>;
package Rotation is

  package Rotation_Vector is new Vector (T);
  package Translation_Vector is new Vector (T);

  type Rotation_3D is new Rotation_Vector.Matrix_3D;

  type Degrees is new T;
  type Degrees_Wrapped is new T range -180 .. 180;
  type Radians is new T;

  function To_Radians (Angle : Degrees) return Radians;
  function To_Degrees (Angle : Radians) return Degrees;
  

  function Rotate_Yaw (Rotation_Angle : Rotation_Math.Degrees) return Rotation_3D;
  function Rotate_Pitch (Rotation_Angle : Rotation_Math.Degrees) return Rotation_3D;
  function Rotate_Roll (Rotation_Angle : Rotation_Math.Degrees) return Rotation_3D;
  
  function Apply_Rotation (Vector: Translation_Vector; Rotation : Rotation_3D) return Vector_3D;
  function Compose_Rotations (First_Rotation, Second_Rotation : Rotation_3D) return Rotation_3D;
  
end Rotation;