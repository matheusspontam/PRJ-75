%-------------------------------------------------------------------------
% Função FTransDin.m
% Função de cálculo das funções de transferência do míssil anti-UAV
% Entrada:
%   - Mach
%   - Alt: altitude
%   - m: massa instantânea
%   - Iy: momento de inércia longitudinal
%   - dxcg: distância normalizada do CG ao CRM
%   - c: comprimento de referência
%   - S: superfícies de referência
% Saída:
%   - Din_acel: função de transferência Acln x dlt
%   - Din_theta: função de transferência theta x dlt
%   - Din_alfa: função de transferência alfa x dlt
%   - Din_q: função de transferência q x dlt
%-------------------------------------------------------------------------

function [Din_acel, Din_theta, Din_alfa, Din_q] = ...
          FTransDin(Mach, alt, m, Iy, dxcg, c, S)

% Definição do ponto de equilíbrio para cálculo das derivadas de
% estabilidade
Theta0 = 0;             % Ângulo de Atitude
alpha = 0;              % Ângulo de Ataque
delta = 0;              % Ângulo da superfície de controle

% Parâmetros atmosféricos
[~,a,~,rho] = atmosisa(alt);
U = Mach*a;

% Cálculo das derivadas de estabilidade
[CN,dCN_dM,dCN_da,dCN_dd,CM,dCM_da,dCM_dd,CA,dCA_dM,dCA_da,CD,CL,XCP,CNA,CMA,CMQ] ...
    = calcula_coef(delta,Mach,alpha);

% Pressão dinâmica
q = 1/2*rho*U^2;

% Renomenclatura das derivadas de estabilidade conforme apostila (seção 5.2)
Czap = 0;
Cza = -dCN_da;
Czq = 0;
Cmap = 0;
%Cma = CMA + dxcg*Cza;
Cma = dCM_da + dxcg*Cza;
Cmq = CMQ;
CI = Iy/(S*q*c);
Cu = m*U/(S*q);
C2u = c/(2*U);
Czd = -dCN_dd;
Cmd = dCM_dd + dxcg*Czd;

% Definição das equações de transferência de curto período 
% (item 5.3 da apostila)

AA = Iy/(S*q*c)*m*U/(S*q);
BB = -c/(2*U)*Cmq*m*U/(S*q) - Iy/(S*q*c)*Cza - c/(2*U)*Cmap*m*U/(S*q);
CC = c/(2*U)*Cmq*Cza - m*U/(S*q)*Cma;

% Função de Transferência q x dlt (dlt -> q)
num_q_cp = [(m*U/(S*q)*Cmd + c/(2*U)*Cmap*Czd)  (Cma*Czd - Cmd*Cza)];
den_q_cp = [AA BB CC];

Din_q = tf(num_q_cp,den_q_cp);
Din_q.InputName = 'dlt';  
Din_q.OutputName = 'q';

% Função de transferência Acln x dlt (dlt -> acln
aa = CI*Czd;
bb = Cu*Cmd - C2u*Cmq*Czd;
cc = Cu*Cmd + C2u*Cmap*Czd;
dd = Cma*Czd - Cmd*Cza;

num_acln_cp = U*[aa (bb - cc)  -dd];
den_acln_cp = [AA  BB  CC];
Din_acel = tf(num_acln_cp,den_acln_cp);
Din_acel.InputName = 'dlt';  
Din_acel.OutputName = 'Az';

% Função de transferência alfa x dlt (dlt -> alfa)
num_alfa_cp = [Iy*Czd/(S*q*c)  (-c/(2*U)*Cmq*Czd + m*U/(S*q)*Cmd)];
den_alfa_cp = [AA BB CC];
Din_alfa = tf(num_alfa_cp, den_alfa_cp);
Din_alfa.InputName = 'dlt'; 
Din_alfa.OutputName = 'alfa';

% Função de transferência theta x dlt (dlt -> theta)
num_theta_cp = [(m*U/(S*q)*Cmd + c/(2*U)*Cmap*Czd)  (Cma*Czd - Cmd*Cza)];
den_theta_cp = [AA BB CC 0];
Din_theta = tf(num_theta_cp, den_theta_cp);
Din_theta.InputName = 'dlt'; 
Din_theta.OutputName = 'theta';

end


            

