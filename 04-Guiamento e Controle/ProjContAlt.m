%-------------------------------------------------------------------------
% Script ProjContAlt.m
% Projeto do controle de altitude pelo método de Root Locus
%
% Entrada:
%   - D: estrutura com os dados do míssil 
%
% Saída:
%   Gráficos com o root locus da malha de controle de altitude para 
%   duas condições extremas: de maior ganho e menor ganho de instabilização
%
% Obs: o algoritmo procura pontos notáveis no root-locus para determinação
% dos ganhos desejados. Dependendo do sistema, estes pontos podem não 
% existir (num sistema instável, por exemplo). Neste caso o usuário deve
% selecionar a condição problemática e analisar os resultados com atenção.
% A variável flag_plot abaixo definida pode ajudar nesta análise
%--------------------------------------------------------------------------

clear all
close all

load autopiloto0.mat;

D = DadosMissil;
D = DadosCGInercia(D);

% Flag para plotagem dos diagramas de root locus e respostas do sistema
% usado para debug e análise de resultados.
flag_plot = 0;

% Atuador - modelo de segunda ordem
wnat = 100*2*pi;                        % (rad/s) banda passante 
qsiat = sqrt(2)/2;                      % amortecimento
AT.num = wnat^2;                        % Função de transferência do Atuador
AT.den = [1 (2*wnat*qsiat) wnat^2];

% Pontos usados para cálculo dos ganhos do autopiloto
altitude = [500 1000 3000 6000 10000];
Mach = [0.6 0.75 0.9];
VetTmp = [D.TTrav ...
          D.TqB/3 ...
          2*D.TqB/3 ...
          D.TqB ...
          D.TqB + D.TqS/2 ...
          D.TqB + D.TqS];
            
% altitude = 500
% Mach = 0.9
% VetTmp =  D.TqB + D.TqS
       
vet_I = interp1(D.IMissil(:,1), D.IMissil(:,3), VetTmp);
vet_m = interp1(D.VProp(:,1), D.VProp(:,3), VetTmp) + D.mf;
x_CG = interp1(D.CGMissil(:,1), D.CGMissil(:,2), VetTmp);

KMin = inf;
KMax = 0;

for i_cg = 1:length(x_CG)               % posição de CG
    for i_alt = 1:length(altitude)      % altitude
        for i_mach = 1:length(Mach)     % Mac

            % Grandezas dependentes do tempo de queima e posição do CG
            m = vet_m(i_cg);
            Iy = vet_I(i_cg);
            dxcg = (x_CG(i_cg) - D.CRM(1))/D.DRef;
            
            % Cálculo das funções de transferência de curto-período
            [Din_acel, Din_theta, Din_alfa, Din_q] = FTransDin(Mach(i_mach), ...
                altitude(i_alt), m, Iy, dxcg, D.DRef, D.SRef);
            
            
% Define função de transferência do autopiloto de atitude
% Controle de atitude, realimentação com girômetro
%
%            e       ea  ed            dlt           q
%  ref_th --->O-->[ampl]-->O-->[ atuador ]---[ Din_q ]---+-[1/s]-+---> theta
%           - |           -|                             |       |
%             |            +--------------[giro]---------+       |
%             +<-------------------------------------------------+
            

            % Define função e transferência do Atuador
            Ki = interpn(vet_x_CG, vet_altitude, vet_Mach, T_at_k_int, ...
                         x_CG(i_cg), altitude(i_alt), Mach(i_mach));
            num_at = AT.num*Ki;
            den_at = AT.den;
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';

            % Configura malha interna fechada
            Sum_in_mf = sumblk('ed = ea - q');
            
            % Conecta blocos da malha interna
            % Função de transferência ea -> q
            T_in_mf = connect(Din_q,At,Sum_in_mf,'ea','q');
            
            
            % Integrador, função de transferência theta x q (q -> theta)
            num_integ = 1;
            den_integ = [1  0];
            Integ = tf(num_integ,den_integ);
            Integ.InputName = 'q';  Integ.OutputName = 'theta';
            
            % Amplificador
            % Função de transferência ea x e (e -> ea)
            Ke = interpn(vet_x_CG, vet_altitude, vet_Mach, T_at_k_ext, ...
                         x_CG(i_cg), altitude(i_alt), Mach(i_mach));
            num_amp = Ke;
            den_amp = 1;
            Amp = tf(num_amp,den_amp);
            Amp.InputName = 'e';
            Amp.OutputName = 'ea';
            
            % Configura malha externa de atitude como fechada
            Sum_out_mf = sumblk('e = ref_th - theta');
            
            % Conecta blocos da malha externa de atitude
            % Função de transferência theta x ref (ref -> theta)
            AP_Theta = connect(Amp,T_in_mf,Integ,Sum_out_mf,'ref_th','theta');
            
            % Monta função de transferência de controle de altitude
            
% Controle de altitude
%
%               dalt        ref_th              theta       alt
%  ref_alt --->O-->[ContAlt]------>[ AP_Theta ]-------[V/s]-----+---> alt
%            - |                                                |
%              +<-----------------------------------------------+
            
            % Integrador, função de transferência theta -> alt
            [Temp, vsom, pressao, rho] = atmosisa(altitude);
            num_integ2 = Mach(i_mach)*vsom;
            den_integ2 = [1  0];
            Integ2 = tf(num_integ,den_integ);
            Integ2.InputName = 'theta';
            Integ2.OutputName = 'alt';
            
            % Controlador de altitude. Função de transferência ref_alt -> dalt)
            num_GAlt = 1;
            den_GAlt = 1;
            GAlt = tf(num_GAlt,den_GAlt);
            GAlt.InputName = 'dalt';
            GAlt.OutputName = 'ref_th';
            
            % Configura malha externa de controle de altitude como aberta
            Sum_alt_ma = sumblk('dalt = ref_alt');
            
            % Conecta blocos da malha controle de altitude
            % Função de transferência ref_alt -> alt)
            ContAlt_ma = connect(GAlt, AP_Theta, Integ2, Sum_alt_ma,'ref_alt','alt');
            
            if flag_plot
               rlocus(ContAlt_ma); grid on
            end
            
            KAlt = 0:5:200;
            R = rlocus(ContAlt_ma,KAlt);
            % Determina um pólo que tende para o semi-plano direito com o 
            % aumento do ganho
            n = find(real(R(:,length(R))) > 0 );

            % Para este pólo, determina o ganho que instabiliza a malha
            i = find(real( R(n(1),:) > 0 ) );
            KStar = KAlt(i(1)-1);
            K(i_cg,i_alt,i_mach) = KStar;
            
            if KStar > KMax
                KMax = KStar;
                imax_cg = i_cg;
                imax_alt = i_alt;
                imax_mach = i_mach;
                ContAlt_ma_max = ContAlt_ma;
            end
            if KStar < KMin
                KMin = KStar;
                imin_cg = i_cg;
                imin_alt = i_alt;
                imin_mach = i_mach;
                ContAlt_ma_min = ContAlt_ma;
            end

            disp (['i_cg= ' num2str(i_cg) ' - Alt= ' num2str(altitude(i_alt)) ...
                   ' m - Mach= ' num2str(Mach(i_mach))...
                   ' KMax= ' num2str(K(i_cg, i_alt, i_mach))]);
                   
        end
    end
end

figure;
rlocus(ContAlt_ma_min); grid on;
title_str = ['Ganho mínimo: ' num2str(KMin') ...
             ' - Mach ' num2str(Mach(imin_mach)) ...
             ' - Alt ' num2str(altitude(imin_alt))...
             ' - CG '  num2str(x_CG(imin_cg)) ];
title(title_str);

figure;
rlocus(ContAlt_ma_max); grid on;
title_str = ['Ganho máximo: ' num2str(KMax') ...
             ' - Mach ' num2str(Mach(imax_mach)) ...
             ' - Alt ' num2str(altitude(imax_alt))...
             ' - CG '  num2str(x_CG(imax_cg)) ];
title(title_str);

