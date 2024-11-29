package body Point.Points is

   function New_Points
     (Fill                                 : Point_Type;
      Points_Start_Index, Points_End_Index : Points_Index_Type)
      return Points_Type
   is
      Created_Points : Points_Type;
      Points_Array   :
        Points_Array_Type (Points_Start_Index .. Points_End_Index) :=
        (others => To_Holder (Fill));
   begin
      Created_Points.Point_Start_Index := Fill.First;
      Created_Points.Point_End_Index   := Fill.Last;
      Created_Points.Points            := To_Holder (Points_Array);
      return Created_Points;
   end New_Points;

   function First (Points : Points_Type) return Integer is
   begin
      return Element (Points.Points)'First;
   end First;

   function Last (Points : Points_Type) return Integer is
   begin
      return Element (Points.Points)'Last;
   end Last;

   function Get (Points : Points_Type; Index : Positive) return Point_Type is
   begin
      return Element (Element (Points.Points) (Index));
   end Get;

   procedure Set
     (Points : in out Points_Type; Index : Positive; Value : Point_Type)
   is
      Point_Element_Container : Point_Holders.Holder :=
        Element (Points.Points) (Index);
   begin
      Replace_Element (Point_Element_Container, Value);
   end Set;

   function Point_First (Points : Points_Type) return Positive is
   begin
      return Points.Point_Start_Index;
   end Point_First;

   function Point_Last (Points : Points_Type) return Positive is
   begin
      return Points.Point_End_Index;
   end Point_Last;

   function Num_Points (Points : Points_Type) is
   begin
      return Element (Points.Points)'Length;
   end Num_Points;

   function Point_Dimension (Points : Points_Type) return Positive is
   begin
      return Points.Point_End_Index - Points.Point_Start_Index + 1;
   end Point_Dimension;

end Point.Points;
