function [mass] = GetMass (t,x,Aether)

% ~ AETHER4 ~

BT = .330;  % 330 grams per meter for Body Tube
CP = .322;  % 322 grams per meter for Coupler Body Tube
ET = .168;  % 168 grams per meter for Engine Tube
PL = 4.882; % 4882 grams per square meter for Plate Parts

Mnosecone                = .250;  % Estimate
Mshoulder                = x(2)*BT;
Msustcoupler                    = x(3) * CP;  % Whole E-Bay, Must find Value
Msustbodytube            = x(3)*BT;
Mforwardfins             = PL * .5*x(8)*x(9)*x(10);
Mstagingcoupler          = x(11) * CP;    
Mboosterbodytube         = x(5) * BT;
Maftfins                 = PL * .5*x(13)*x(15); 
Msustcasingtuberetainer  = .120 + ET*.3;            % Mass of the Engine Casing, Engine Tube and Retainer
Mboostcasingtuberetainer = .120 + ET*.3;            % Mass of the Engine Casing, Engine Tube and Retainer
Mboostinit               = .294;                    % Initial mass of booster
Msustinit                = .349;                    % Initial mass of sustainer 
Mboostprop               = .139;                    % Mass of propellant 
Msustprop                = .184;                    % Mass of propellant

Mdrogueparachute         = .030; % Guesses, but good enough.
Mmainparachute           = .070;
Mboosterparachute        = .040; 

initialMass = Mboostinit + Msustinit + Mnosecone + Mshoulder + Msustcoupler + Msustbodytube + Mforwardfins + Msustcasingtuberetainer...
    + Mstagingcoupler + Mboosterbodytube + Mboostcasingtuberetainer + Maftfins +...
    Mdrogueparachute + Mmainparachute + Mboosterparachute;

initialSustMass = Msustinit + Mnosecone + Mshoulder + Msustcoupler + Msustbodytube + Msustcasingtuberetainer...
    + Mforwardfins + Mdrogueparachute + Mmainparachute;

startTimeSust = Aether.BoosterMotor.burnTime+x(4);          % sec

if (t>=0 && t<Aether.BoosterMotor.burnTime)    %Launch to boost eject
    mass = initialMass - Mboostprop *(t/Aether.BoosterMotor.burnTime);
elseif (t>=Aether.BoosterMotor.burnTime && t<startTimeSust) %Coast
    mass = initialMass - Mboostprop;
elseif (t>=startTimeSust && t< startTimeSust + Aether.SustainerMotor.burnTime)    %Sust ignition to Sustainer Cutoff
    mass = initialSustMass - Msustprop * (t/(Aether.SustainerMotor.burnTime + startTimeSust));
elseif (t>startTimeSust+Aether.SustainerMotor.burnTime)    % Final Coast to Apogee
    mass = initialSustMass - Msustprop;
else
    mass = initialMass;
    
end

end