%-------------------------------------------------------------------------
% Função calcula_coef.m
% Função de cálculo das derivadas de estabilidade do míssil anti-UAV.
% Esta função usa os coeficientes aerodinâmicos do arquivo M_aed.mat
% Entrada:
%   - delta: deflexão da superfície de controle
%   - Mach
%   - alfa: ângulo de ataque
% Saída:
%   - Derivadas de estabilidade
%-------------------------------------------------------------------------

function [CN,dCN_dM,dCN_da,dCN_dd,CM,dCM_da,dCM_dd,CA,dCA_dM,dCA_da,CD,CL,XCP,CNA,CMA,CMQ]...
    =calcula_coef(delta,M,alpha)

%Importa matriz de dados aerodinâmicos
load('M_aed.mat');

dM = 1e-2;
da = 1;
dd = 0.1;
CN = interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta,M,alpha);
dCN_da = (interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta,M,alpha+da) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta,M,alpha))/(da*pi/180);
dCN_dM = (interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta,M+dM,alpha) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta,M,alpha))/dM;
dCN_dd = (interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta+dd,M,alpha) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CN,delta,M,alpha))/(dd*pi/180);
CM = interpn(dados.delta,dados.mach,dados.alpha,M_CM,delta,M,alpha);
dCM_da = (interpn(dados.delta,dados.mach,dados.alpha,M_CM,delta,M,alpha+da) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CM,delta,M,alpha))/(da*pi/180);
dCM_dd = (interpn(dados.delta,dados.mach,dados.alpha,M_CM,delta+dd,M,alpha) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CM,delta,M,alpha))/(dd*pi/180);
CA = interpn(dados.delta,dados.mach,dados.alpha,M_CA,delta,M,alpha);
dCA_dM = (interpn(dados.delta,dados.mach,dados.alpha,M_CA,delta,M+dM,alpha) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CA,delta,M,alpha))/dM;
dCA_da = (interpn(dados.delta,dados.mach,dados.alpha,M_CA,delta,M,alpha+da) ...
-interpn(dados.delta,dados.mach,dados.alpha,M_CA,delta,M,alpha))/(da*pi/180);
CD = interpn(dados.delta,dados.mach,dados.alpha,M_CD,delta,M,alpha);
CL = interpn(dados.delta,dados.mach,dados.alpha,M_CL,delta,M,alpha);
XCP = interpn(dados.delta,dados.mach,dados.alpha,M_XCP,delta,M,alpha);
CNA = interpn(dados.delta,dados.mach,dados.alpha,M_CNA,delta,M,alpha);
CMA = interpn(dados.delta,dados.mach,dados.alpha,M_CMA,delta,M,alpha);
CMQ = interpn(dados.delta,dados.mach,dados.alpha,M_CMQ,delta,M,alpha);
end

