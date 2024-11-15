package body Models is
  function Predict_Particle_State (Previous_State : Particle_State) return Particle_State
  is
    Next_State : Particle_State := Previous_State;
  begin
    declare
      Velocity_X_Distribution : Gaussian_Distribution := 
        (Mean               => Previous_State.Velocity (0),
         Standard_Deviation => Velocity_Component_Standard_Deviation);
      Velocity_Y_Distribution : Gaussian_Distribution := 
        (Mean               => Previous_State.Velocity (1),
         Standard_Deviation => Velocity_Component_Standard_Deviation);
      Velocity_Z_Distribution : Gaussian_Distribution := 
        (Mean               => Previous_State.Velocity (2),
         Standard_Deviation => Velocity_Component_Standard_Deviation);

      Atmospheric_Temperature_Distribution : Gaussian_Distribution :=
        (Mean => Previous_State.Atmospheric_Temperature,
         Standard_Deviation => Atmospheric_Temperature_Standard_Deviation);
    begin
    end;
    Next_State.Location := Position.Shifted_Location(
      Current_Location => Previous_State.Location,
      Displacement => Previous_State.Velocity
    );
  end Predict_Particle_State;
  
  
end Models;