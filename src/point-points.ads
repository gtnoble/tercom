with Ada.Numerics.Generic_Real_Arrays;
with Ada.Containers;
with Ada.Containers.Indefinite_Holders;

generic
   type Points_Index_Type is range <>;
package Point.Points is

   type Points_Type is private;
   subtype Point_Index_Type is Integer;
   
   function Make_Points 
      (Points_Start_Index, Points_End_Index : Points_Index_Type) return Points_Type;
      
   function New_Points
     (Fill : Point_Type; Points_Start_Index, Points_End_Index : Points_Index_Type)
      return Points_Type;

   function First (Points : Points_Type) return Points_Index_Type;
   function Last (Points : Points_Type) return Points_Index_Type;
   function Get
     (Points : Points_Type; Index : Points_Index_Type) return Point_Type;
   procedure Set
     (Points : in out Points_Type; Index : Points_Index_Type;
      Value  :        Point_Type);
   function Num_Points (Points : Points_Type) return Positive;

   function Matrix_To_Points (Matrix : Matrix_Type) return Points_Type;


private

   package Point_Holders is new Ada.Containers.Indefinite_Holders (Point_Type);
   use Point_Holders;

   type Points_Array_Type is array (Points_Index_Type range <>) of Point_Holders.Holder;

   package Points_Array_Holders is new Ada.Containers.Indefinite_Holders
     (Points_Array_Type);
   use Points_Array_Holders;

   type Points_Type is record
      Points            : Points_Array_Holders.Holder;
   end record;

end Point.Points;
