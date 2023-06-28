function C_corr = concalc_rough(orf_d, orf_t, T, M, R0)
    % Calculate the orifice conductance
    % orf_d = orifice diameter
    % orf_t = thickness of orifice plate
    % T = temp
    % M = mean molecular mass of gas passing through orifice
    % R0 = gas number
    
    k = sqrt((R0.*T)/(2 * pi * M)); % constant term
    orf_r = orf_d/2; % orifice radius
    
    C = k * (pi * orf_r^2); % C = k * cross-sectional area
    
    % Correction for the thickness of orifice. Above equation assumes 
    % negligible thickness. This is important when thickness is similar (or
    % larger) than orifice radius.
    leff=(1 + 1 / (3 + 3 * orf_t / (7 * orf_r))) * orf_t; % "effective length" of the orifice
    alpha = 1 / (1 + 3 * leff / (8 * orf_r));
    C_corr = alpha * C;
end