function [T, a, P, rho] = atmosisa(h)
T0 = 288.15;
P0 = 101325;
L = 0.0065;
R = 287.05;
gamma = 1.4;
g = 9.80665;

T = T0 - L*h;
P = P0*(T/T0)^(g/(R*L));
rho = P/(R*T);
a = sqrt(gamma*R*T);
end
