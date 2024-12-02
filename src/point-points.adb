package body Point.Points is
   pragma Assertion_Policy (Check);

   function Make_Points 
      (Points_Start_Index, Points_End_Index : Points_Index_Type) return Points_Type 
   is
      pragma Assert (Points_Start_Index <= Points_End_Index, "Start index must be less than or equal to the end index");

      Points_Array : Points_Array_Type (Points_Start_Index .. Points_End_Index);
   begin
      return (Points            => To_Holder (Points_Array));
   end Make_Points;

   function New_Points
     (Fill                                 : Point_Type;
      Points_Start_Index, Points_End_Index : Points_Index_Type)
      return Points_Type
   is
      pragma Assert (Points_Start_Index <= Points_End_Index, "Start index must be less than or equal to the end index");

      Created_Points : Points_Type;
      Points_Array   :
        Points_Array_Type (Points_Start_Index .. Points_End_Index) :=
        (others => To_Holder (Fill));
   begin
      Created_Points.Points            := To_Holder (Points_Array);
      return Created_Points;
   end New_Points;

   function First (Points : Points_Type) return Points_Index_Type is
   begin
      return Element (Points.Points)'First;
   end First;

   function Last (Points : Points_Type) return Points_Index_Type is
   begin
      return Element (Points.Points)'Last;
   end Last;

   function Get (Points : Points_Type; Index : Points_Index_Type) return Point_Type is
   begin
      return Element (Element (Points.Points) (Index));
   end Get;

   procedure Set
     (Points : in out Points_Type; Index : Points_Index_Type; Value : Point_Type)
   is
      procedure Update_Array (Points_Array : in out Points_Array_Type) is
      begin
         Replace_Element (Points_Array (Index), Value);
      end Update_Array;

   begin
      Update_Element (Points.Points, Update_Array'Access);
   end Set;

   function Num_Points (Points : Points_Type) return Positive is
   begin
      return Element (Points.Points)'Length;
   end Num_Points;
   
   function Matrix_To_Points (Matrix : Matrix_Type) return Points_Type is
      Points : Points_Type := Make_Points
         (Points_Start_Index => Points_Index_Type (Matrix'First(1)), 
         Points_End_Index => Points_Index_Type (Matrix'Last(1)));
   begin
      for Row_Index in Matrix'Range (1) loop
         declare
            Row : Point_Type (Matrix'Range (2));
         begin
            for Column_Index in Matrix'Range (2) loop
               Row (Column_Index) := Matrix (Row_Index, Column_Index);
            end loop;
               Set (Points, Points_Index_Type (Row_Index), Row);
         end;
      end loop;
      return Points;
   end Matrix_To_Points;

end Point.Points;
