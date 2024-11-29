with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   type Points_Index_Type is range <>;
package Point.Points is

   type Points_Type is private;

   function New_Points
     (Points_Start_Index, Points_End_Index : Points_Index_Type)
      return Points_Type;

   function First (Points : Points_Type) return Points_Index_Type;
   function Last (Points : Points_Type) return Points_Index_Type;
   function Get
     (Points : Points_Type; Index : Points_Index_Type) return Point_Type;
   procedure Set
     (Points : in out Points_Type; Index : Points_Index_Type;
      Value  :        Point_Type);
   function Num_Points (Points : Points_Type) return Natural;

   function Point_First (Points : Points_Type) return Point_Index_Type;
   function Point_Last (Points : Points_Type) return Point_Index_Type;
   function Point_Dimension (Points : Points_Type) return Positive;

   function Points_To_Matrix (X : Points_Type) return Matrix_Type;
   function Matrix_To_Points (X : Matrix_Type) return Points_Type;

private

   package Point_Holders is new Ada.Containers.Indefinite_Holders (Point_Type);
   use type Point_Holders.Holder;
   use type Point_Holders.Reference_Type;

   type Points_Array_Type is array (Points_Index_Type) of Point_Holders.Holder;

   package Points_Array_Holders is new Ada.Containers.Indefinite_Holders
     (Points_Array_Type);
   use type Points_Array_Holders.Holder;
   use type Points_Array_Holders.Reference_Type;

   type Points_Type is record
      Points            : Points_Array_Holders.Holder;
      Point_Start_Index : Point_Index_Type;
      Point_End_Index   : Point_Index_Type;
   end record;

end Point.Points;
