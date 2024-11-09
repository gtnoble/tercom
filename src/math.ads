generic
  type T is digits <>;
package Math is
  package Precise_Math is new Ada.Numerics.Generic_Elementary_Functions(T);
  use Precise_Math;
  type Precise_Float is digits 12;

end Math;