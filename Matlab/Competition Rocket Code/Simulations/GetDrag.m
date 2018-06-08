function [drag] = GetDrag (v,h,t)
% Calculates total drag for the sustainer and booster; carries to
% sustainer then to recovery.

% Both fin sets are accounted for.

% NB ! When v is + ve (up) drag should be + ve (down)

% ~ AETHER6 ~

pi = 3.14;
mu = 1.79e-5;
rho = 1.217*exp(-h/8500);
kv = mu/rho;

if v >= 0
    
    % FULL ROCKET
    if t <= 2.3
        l = 1.25; % length of full rocket (m)
    
        % ~ SKIN FRICTION DRAG ~
        D = .0574;   % (m) Diameter of Nosecone
        r = D/2;
        Re = (v*l)/kv;
        Rs = 60e-6; % roughness
        Rcrit = 51*(Rs/l)^-1.039;
        
        if Re < 1.0e4
            CDsf = 1.48e-2;
        elseif Re > 1.0e4 && Re < Rcrit
            CDsf = 1/(1.50*log(Re) - 5.6)^2;
        elseif Re > Rcrit
            CDsf = 0.032*(Rs/l)^0.2;
            
        end
        
        fb = l/D; % fineness ratio
        
        % BOOSTER FINS
        t_b = 0.003; % booster fin thickness
        c_b = 0.056; % booster fin aerodynamic cord length
        finbase_booster = 0.056;
        finheight_booster = 0.126;
        finarea_sfb = 0.5*finbase_booster*finheight_booster;
        fin_totalarea_sfb = finarea_sfb*6; % booster fin area
        % SUSTAINER FINS
        t_s = 0.003; % sust fin thickness
        c_s = 0.056; % sust fin aerodynamic cord length
        finbase_sust = 0.056;
        finheight_sust = 0.126;
        finarea_sfs = 0.5*finbase_sust*finheight_sust;
        fin_totalarea_sfs = finarea_sfs*6; % sust fin area
        % BODY TUBE
        bodytube_area = 2*pi*r*l;   % surface area
        crosssection_area = pi*r^2; % cross-sectional area
        % EFFECTIVE AREA
        ref_area_sf = fin_totalarea_sfb + fin_totalarea_sfs + bodytube_area;
        
        % Compressibility Effects
        a = 343; %m/s
        M = v/a;
        if M < 0.9
            Cfc = CDsf*(1 - 0.1*M^2);
        elseif M >= 0.9
            Cfc = CDsf/((1 + 0.15*M^2)^0.58);
        end
        
        CDsf = Cfc*((1 + 1/(2*fb))*(bodytube_area) + (1 + (2*t_b)/c_b)*fin_totalarea_sfb + (1 + (2*t_s)/c_s)*fin_totalarea_sfs)/ref_area_sf;
        
        Fdrag_sf = CDsf*(1/2)*rho*v^2*(ref_area_sf); % force of skin friction drag
        
        % ~ PRESSURE DRAG ~
        % Nose Cone Pressure Drag
        % if M is less than 0.9...
        % CDpd_nc = 0.05; % ogive nose cone
        CDpd_nc = 0;
        Fpd_nosecone = CDpd_nc*(1/2)*rho*v^2*(crosssection_area);
        
        % Fin Pressure Drag
        
        % BOOSTER FINS
        LEAb = 61.2; % leading edge angle
        if M < 0.9
            CDpd_finsb = ((1 - M^2)^(-0.417) - 1)*cosd(LEAb)^2;
        elseif M > 0.9 && M < 1
            CDpd_finsb = (1 - 1.785*(M - 0.9))*cosd(LEAb)^2;
        elseif M > 1.0
            CDpd_finsb = (1.214 - 0.502/(M^2) + 0.1095/(M^4))*cosd(LEAb)^2;
        end
        
        Fpd_finsb = CDpd_finsb*(1/2)*rho*v^2*(finbase_booster*t_b);
        
        Fpd_fins_totalb = Fpd_finsb*3;
        
        % SUSTAINER FINS
        LEAs = 61.2; % leading edge angle
        if M < 0.9
            CDpd_finss = ((1 - M^2)^(-0.417) - 1)*cosd(LEAs)^2;
        elseif M > 0.9 && M < 1
            CDpd_finss = (1 - 1.785*(M - 0.9))*cosd(LEAs)^2;
        elseif M > 1.0
            CDpd_finss = (1.214 - 0.502/(M^2) + 0.1095/(M^4))*cosd(LEAs)^2;
        end
        
        Fpd_finss = CDpd_finss*(1/2)*rho*v^2*(finbase_sust*t_s);
        
        Fpd_fins_totals = Fpd_finss*3;
        
        Fdrag_pd = Fpd_nosecone + Fpd_fins_totalb + Fpd_fins_totals; % force of pressure drag
        
        % ~ BASE DRAG ~
        
        if M < 1
            CDbd = 0.12 + 0.13*M^2 ;
        elseif M > 1
            CDbd = 0.25/M;
        end
        
        Fdrag_bd = CDbd*(1/2)*rho*v^2*(crosssection_area); % force of base drag
        
        % ~ TOTAL DRAG ~
        drag = Fdrag_sf + Fdrag_pd + Fdrag_bd; % total force of drag
    
    
        
    % SUSTAINER STAGE ONLY
    elseif t > 2.3
        l = 0.80; % length of sustainer body tube (m)
        
        % ~ SKIN FRICTION DRAG ~
        D = .0574;   % (m) Diameter of Nosecone
        r = D/2;
        Re = (v*l)/kv;
        Rs = 60e-6; % roughness
        Rcrit = 51*(Rs/l)^-1.039;
        
        if Re < 1.0e4
            CDsf = 1.48e-2;
        elseif Re > 1.0e4 && Re < Rcrit
            CDsf = 1/(1.50*log(Re) - 5.6)^2;
        elseif Re > Rcrit
            CDsf = 0.032*(Rs/l)^0.2;
            
        end
        
        fb = l/D; % fineness ratio
        
        % SUSTAINER FINS
        t_s = 0.003; % sust fin thickness
        c_s = 0.056; % sust fin aerodynamic cord length
        finbase_sust = 0.056;
        finheight_sust = 0.126;
        finarea_sfs = 0.5*finbase_sust*finheight_sust;
        fin_totalarea_sfs = finarea_sfs*6; % sust fin area
        % BODY TUBE
        bodytube_area = 2*pi*r*l;   % surface area
        crosssection_area = pi*r^2; % cross-sectional area
        % EFFECTIVE AREA
        ref_area_sf = fin_totalarea_sfs + bodytube_area;
        
        % Compressibility Effects
        a = 343; %m/s
        M = v/a;
        if M < 0.9
            Cfc = CDsf*(1 - 0.1*M^2);
        elseif M >= 0.9
            Cfc = CDsf/((1 + 0.15*M^2)^0.58);
        end
        
        CDsf = Cfc*((1 + 1/(2*fb))*(bodytube_area) + (1 + (2*t_s)/c_s)*fin_totalarea_sfs)/ref_area_sf;
        
        Fdrag_sf = CDsf*(1/2)*rho*v^2*(ref_area_sf); % force of skin friction drag
        
        % ~ PRESSURE DRAG ~
        % Nose Cone Pressure Drag
        % if M is less than 0.9...
        % CDpd_nc = 0.05; % ogive nose cone
        CDpd_nc = 0;
        Fpd_nosecone = CDpd_nc*(1/2)*rho*v^2*(crosssection_area);
        
        % Fin Pressure Drag
        
        % SUSTAINER FINS
        LEAs = 61.2; % leading edge angle
        if M < 0.9
            CDpd_finss = ((1 - M^2)^(-0.417) - 1)*cosd(LEAs)^2;
        elseif M > 0.9 && M < 1
            CDpd_finss = (1 - 1.785*(M - 0.9))*cosd(LEAs)^2;
        elseif M > 1.0
            CDpd_finss = (1.214 - 0.502/(M^2) + 0.1095/(M^4))*cosd(LEAs)^2;
        end
        
        Fpd_finss = CDpd_finss*(1/2)*rho*v^2*(finbase_sust*t_s);
        
        Fpd_fins_totals = Fpd_finss*3;
        
        Fdrag_pd = Fpd_nosecone + Fpd_fins_totals; % force of pressure drag
        
        % ~ BASE DRAG ~
        
        if M < 1
            CDbd = 0.12 + 0.13*M^2 ;
        elseif M > 1
            CDbd = 0.25/M;
        end
        
        Fdrag_bd = CDbd*(1/2)*rho*v^2*(crosssection_area); % force of base drag
        
        % ~ TOTAL DRAG ~
        drag = Fdrag_sf + Fdrag_pd + Fdrag_bd; % total force of drag
    
    end
        
    
% ~ RECOVERY ~
elseif v < 0
    D = 0.30; % diameter of parachute (m)
    k = 1.0;
    drag = -k * 0.5 * rho * v^2 * pi/4 * D^2;

    if h < 90
        D = 0.75;
        k = 1.0;
        drag = -k * 0.5 * rho * v^2 * pi/4 * D^2;
        
    end
    
end

end      
        
           