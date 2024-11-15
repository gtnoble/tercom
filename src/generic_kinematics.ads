with Vector;

generic
  type T is digits <>;
package Generic_Kinematics is

  package Rotation_Vector is new Vector (T);

  type Direction is new Rotation_Vector.Vector_3D;
  type Velocity is new Direction;
  type Displacement is new Direction;
  type Acceleration is new Direction;

  type Rotation is new Rotation_Vector.Matrix_3D;
  type Rotation_Rate is new Rotation_Vector.Matrix_3D;


  type Degrees is new T;
  type Degrees_Wrapped is new T range -180 .. 180;
  type Radians is new T;

  function To_Radians (Angle : Degrees) return Radians;
  function To_Degrees (Angle : Radians) return Degrees;
  

  function Rotate_Yaw (Rotation_Angle : Degrees) return Rotation;
  function Rotate_Pitch (Rotation_Angle : Degrees) return Rotation;
  function Rotate_Roll (Rotation_Angle : Degrees) return Rotation;
  
  function Apply_Rotation (Vector: Direction; Rotation : Rotation) return Direction;
  function Compose_Rotations (First_Rotation, Second_Rotation : Rotation) return Rotation;
  function Rotate_3D (Yaw, Pitch, Roll : Degrees) return Rotation;
  
end Rotation;