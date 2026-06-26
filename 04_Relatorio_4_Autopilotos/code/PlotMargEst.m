%-------------------------------------------------------------------------
% Script PlotMargEst.m
% Plotagem da Margem estática do míssil em função do tempo de voo
%
% Entrada:
%   - D: estrutura com os dados do míssil 
%   - M_aed.mat: arquivo com dados aerodinâmicos do míssil
%
% Saída:
%   - Gráficos da Margem estática
%
% Obs: o programa procura os pontos neutros em torno de alpha = 0, para 
% diversas condições de voo e a partir dele, calcula a margem estática
%--------------------------------------------------------------------------

clear all
close all

D = DadosMissil;
D = DadosCGInercia(D);

Mach = [0.6 0.7 0.8 0.9];
VetTmp = [0 ...
          D.TqB/2 ...
          D.TqB ...
          D.TqB + D.TqS/2 ...
          D.TqB + D.TqS];
      
x_CG = interp1(D.CGMissil(:,1), D.CGMissil(:,2), VetTmp);

figure();
LEG = {};
for i_mach = 1:length(Mach)         % Mach
        
    delta = 0;
    alpha = 0;
    MachNo = Mach(i_mach);
    % Cálculo das derivadas de estabilidade
    [CN,dCN_dM,dCN_da,dCN_dd,CM,dCM_da,dCM_dd,CA,dCA_dM,dCA_da,CD,CL,XCP,CNA,CMA,CMQ] ...
        = calcula_coef(delta,MachNo,alpha);
    
    Cza = -dCN_da;
    Cma0 = dCM_da;
    x_pn = D.CRM(1) - Cma0/Cza*D.DRef;
        
    for i_cg = 1:length(x_CG)               % posição de CG
        MargEst(i_mach,i_cg) = (x_CG(i_cg) - x_pn)/D.DRef;
    end

    plot(VetTmp,MargEst(i_mach,:));
    hold on;
    LEG(i_mach)= {['Mach:' num2str(MachNo)]};
end
grid on
title('Margem Estática para \alpha = 0 e \delta = 0');
xlabel('t (s)');
ylabel('Margem Estática');
legend(LEG);
legend('Location','best')


