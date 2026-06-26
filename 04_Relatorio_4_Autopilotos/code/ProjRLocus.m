
%-------------------------------------------------------------------------
% Script ProjRLocus.m
% Projeto dos autopilotos de atitude e aceleração pelo
% método de Root Locus
%
% Entrada:
%   - D: estrutura com os dados do míssil 
%
% Saída:
%   - Arquivo autopiloto.mat, com as seguintes tabelas:
%       - T_acel_k_ext: ganhos da malha externa de aceleração
%       - T_at_k_ext:   ganhos da malha externa de atitude
%       - T_at_k_int:   ganhos da malha interna de atitude    
%       - T_acel_k_int: ganhos da malha interna de aceleração
%       - vet_x_CG:     valores de CG  
%       - vet_altitude: valores de altitude  
%       -vet_Mach:      valores de Mach
%
% Obs: o algoritmo procura pontos notáveis no root-locus para determinação
% dos ganhos desejados. Dependendo do sistema, estes pontos podem não 
% existir (num sistema instável, por exemplo). Neste caso o usuário deve
% selecionar a condição problemática e analisar os resultados com atenção.
% A variável flag_plot abaixo definida pode ajudar nesta análise
%--------------------------------------------------------------------------

clear all
close all

D = DadosMissil;
D = DadosCGInercia(D);

% Flag para plotagem dos diagramas de root locus e respostas do sistema
% usado para debug e análise de resultados.
flag_plot = 1;

% Atuador - modelo de segunda ordem
wnat = 100*2*pi;                        % (rad/s) banda passante 
qsiat = sqrt(2)/2;                      % amortecimento
AT.num = wnat^2;                        % Função de transferência do Atuador
AT.den = [1 (2*wnat*qsiat) wnat^2];

% Centro de Referência de Momentos 
CRM = D.CRM(1);

% Pontos usados para cálculo dos ganhos do autopiloto
altitude = [500 1000 3000 6000 10000];
Mach = [0.6 0.75 0.9];
if D.TTrav < D.TqB/2
    T0 = D.TTrav;
else
    T0 = D.TqB/2 - 0.1;
end
VetTmp = [T0 ...
          D.TqB/2 ...
          D.TqB ...
          D.TqB + D.TqS/2 ...
          D.TqB + D.TqS];
            
altitude = 1000
Mach = 0.8
VetTmp = 3
      
vet_I = interp1(D.IMissil(:,1), D.IMissil(:,3), VetTmp);
vet_m = interp1(D.VProp(:,1), D.VProp(:,3), VetTmp) + D.mf;
x_CG = interp1(D.CGMissil(:,1), D.CGMissil(:,2), VetTmp);


% Inicializa tabela de ganhos do Autopiloto de Atitude
% Tabela de ganhos da manha interna
T_at_k_int = zeros(length(x_CG),length(altitude),length(Mach));

% Tabela de ganhos da malha externa
T_at_k_ext = zeros(length(x_CG),length(altitude),length(Mach));

% Inicializa tabela de ganhos do Autopiloto de Aceleração
% Tabela de ganhos da malha interna
T_ac_k_int = zeros(length(x_CG),length(altitude),length(Mach));

% Tabela de ganhos da malha externa
T_ac_k_ext = zeros(length(x_CG),length(altitude),length(Mach));

% Loops de projeto do autopiloto

for i_cg = 1:length(x_CG)               % posição de CG
    for i_alt = 1:length(altitude)      % altitude
        for i_mach = 1:length(Mach)     % Mach
            
            % Grandezas dependentes do tempo de queima e posição do CG
            m = vet_m(i_cg);
            Iy = vet_I(i_cg);
            dxcg = (x_CG(i_cg) - CRM)/D.DRef;
            
            % Cálculo das funções de transferência de curto-período
            [Din_acel, Din_theta, Din_alfa, Din_q] = FTransDin(Mach(i_mach), ...
                altitude(i_alt), m, Iy, dxcg, D.DRef, D.SRef);

% Controle de atitude, realimentação com girômetro
%
%            e       ea  ed            dlt             q
%  ref --->O-->[ampl]-->O-->[ atuador ]---[ dinamica ]---[1/s]-+---> theta
%        - |           -|                              |       |
%          |            +--------------[giro]----------+       |
%          +<--------------------------------------------------+
            
            
            % Define função e transferência do Atuador
            num_at = AT.num;
            den_at = AT.den;            
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';
       
            % Root locus da malha interna
            
            % Função de transferência da malha interna
            
            % Configura malha interna aberta
            Sum_in_ma = sumblk('ed = ea');
            
            % Conecta blocos da malha interna
            T_in_ma = connect(Din_q,At,Sum_in_ma,'ea','q');
            
            % Define intervalo de ganhos para cálculo do root locus
            % Kg: ganho do giro
            Kgmax = 1;
            dKg = Kgmax/1000;
            Kg = 0:dKg:Kgmax;
            
            % Observação importante:
            % Algoritmo irá procurar pontos onde os pólos da malha interna
            % se afastam do eixo real. 
            % Dependendo do sistema, pode ser necessário redimensionar o 
            % intervalo de Kg
            
            % Calcula root locus da malha interna
            R_in = rlocus(T_in_ma,Kg);
            
            if flag_plot
                figure;
                rlocusplot(T_in_ma,Kg); grid; axis('equal');
                title('Root locus da malha interna')
            end
            
            % Localiza ganho da malha interna onde pólos passam a ter 
            % parte imaginária não-nula.
            
            % Determina qual o pólo converge para eixo real (dominante):
            n = find(imag(R_in(:,length(R_in))) == 0);
            
            % Determina ganho onde pólo dominante chega ao eixo real
            i = find(imag(R_in(n(1),:))==0);

            Kat = Kg(i(1));         % Valor nominal do método
            Kat = 2*Kg(i(1));       % Fator empírico (fator 2 determinado
                                    % por tentativa e erro);

            % Determina ponto da tabela de ganhos da malha interna dos
            % autopilotos de atitude e aceleração
            T_at_k_int(i_cg,i_alt,i_mach) = Kat;
            T_acel_k_int(i_cg,i_alt,i_mach) = Kat;

            if flag_plot
               str_ganho_in = ['ganho da malha interna: ' num2str(Kat)];
               disp(str_ganho_in);
            end
            
            % Root locus da malha externa do controle de atitude
            
            % Malha interna, controle de atitude/aceleração
            % Incorpora ganho da malha interna (Kat) no modelo do atuador
            num_at = AT.num*Kat;
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';
            
            % Configura malha interna fechada
            Sum_in_mf = sumblk('ed = ea-q');
            
            % Conecta blocos da malha interna
            % Função de transferência q x ea (ea -> q)
            T_in_mf = connect(Din_q,At,Sum_in_mf,'ea','q');
            
            % Resposta degrau da malha interna
            if flag_plot
                t = 0:0.1:4;
                u = ones(size(t));
                y = lsim(T_in_mf,u,t);
                figure
                plot(t,y); grid; xlabel('t (s)'); ylabel('q (rad/s)');
                title(['Resposta degrau da malha interna, ' str_ganho_in]);
            end
            
            % Malha externa, controle de atitude
            
            % Integrador, função de transferência theta x q (q -> theta)
            num_integ = 1;
            den_integ = [1  0];
            Integ = tf(num_integ,den_integ);
            Integ.InputName = 'q';  Integ.OutputName = 'theta';
            
            % Amplificador
            % Função de transferência ea x e (e -> ea)
            num_amp = 1;
            den_amp = 1;
            Amp = tf(num_amp,den_amp);
            Amp.InputName = 'e';
            Amp.OutputName = 'ea';
            
            % Configura malha externa como aberta
            Sum_out_ma = sumblk('e = ref');
            
            % Conecta blocos da malha externa aberta
            % Função de transferência theta x ref (ref -> theta)
            T_out_ma = connect(Amp,T_in_mf,Integ,Sum_out_ma,'ref','theta');
            
            % Root locus da malha externa de atitude
            
            % Define intervalo de ganhos para cálculo do root locus
            % Kg: ganho do giro
            Kmax = 1000;
            dK = Kmax/10000;
            K = 0:dK:Kmax;
            
            % Observação importante:
            % Algoritmo irá procurar pontos onde os pólos da malha externa
            % têm fator de amortecimento de 0,7
            % Dependendo do sistema, pode ser necessário redimensionar o 
            % intervalo de K
              
            % Calcula root locus da malha externa de atitude
            R_out = rlocus(T_out_ma,K);
            if flag_plot
                figure
                rlocusplot(T_out_ma,K); grid; axis('equal');
                title(['Root locus da malha externa - ' str_ganho_in]);
            end
            
            % Determina qual pólo tende para o semi-plano direito com o 
            % aumento do ganho
            n = find(real(R_out(:,length(R_out))) > 0 );
            
            % Para este pólo, determina o ganho para o qual o fator de
            % amortecimento associado a este pólo tem valor 0,7
            Qsi_at = abs(-real(R_out(n(1),:))) ./ ...
                     sqrt(real(R_out(n(1),:)).^2 + imag(R_out(n(1),:)).^2);
            i = find(Qsi_at < 0.7);
            KAmp = K(i(1));
            
            % Determina ponto da tabela da malha externa de atitude
            T_at_k_ext(i_cg,i_alt,i_mach) = KAmp;
            
            if flag_plot
                str_ganho_out = ['ganho da malha externa de atitude: ' num2str(KAmp)];
                disp(str_ganho_out);
            end
            
            % Resposta degrau de malha fechada
            if flag_plot
                
                % Incorpora ganho determinado no modelo do amplificador
                num_amp = KAmp;
                den_amp = 1;
                Amp = tf(num_amp,den_amp);
                Amp.InputName = 'e';
                Amp.OutputName = 'ea';
                
                % Configura malha externa de atitude como fechada
                Sum_out_mf = sumblk('e = ref-theta');
                
                % Conecta blocos da malha externa de atitude
                T_out_mf = connect(Amp,T_in_mf,Integ,Sum_out_mf,'ref','theta');
                
                % Resposta degrau
                t = 0:0.01:1;
                u = ones(size(t));
                y = lsim(T_out_mf,u,t);
                figure
                plot(t,y); grid; xlabel('t (s)'); ylabel('Theta (rad)');
                title(['Resposta degrau malha externa, ' str_ganho_out]);
            end
            
            % Controle de aceleração, realimentação com girômetro
            %
            %            e       ea  ed            dlt
            %  Aref --->O-->[K/s]-->O-->[ atuador ]------+-->[ din_az]---+-> Az
            %         - |          -|                    |               |
            %           |           |         q          |               |
            %           |           +-[giro]<--[din_q]---+               |
            %           |                                                |
            %           +<----------------------[acelerometro]-----------+
            
            
            % Malha interna: igual à do controle de aceleração, realocada
            
            % Malha interna, controle de aceleração
            % Redefine função de transferência do atuador: ed -> dlt
            num_at = AT.num*Kat;
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';
            
            % Configura malha interna como fechada
            Sum_ac_in_mf = sumblk('ed = ea-q');
            
            % Conecta blocos da malha interna
            % Função de transferência ea -> dlt
            T_ac_in_mf = connect(Din_q,At,Sum_ac_in_mf,'ea','dlt');
                        
            % Define função de transferência do amplificador/integrador 
            % da malha externa: e -> ea
            num_amp = -1;
            den_amp = [1  0];
            Amp = tf(num_amp,den_amp);
            Amp.InputName = 'e';
            Amp.OutputName = 'ea';
            
            % Configura malha externa de aceleração como aberta
            Sum_ac_out_ma = sumblk('e = Aref');
            
            % Conecta blocos da malha externa de aceleração, aberta
            % Função de transferência Aref -> Az          
            T_ac_out_ma = connect(Amp,T_ac_in_mf,Din_acel,Sum_ac_out_ma,'Aref','Az');
            
            % Root locus da malha externa de aceleração
            
            % Define intervalo de ganhos para cálculo do root locus
            % K: ganho do integrador da malha externa
            Kmax = 20;
            dK = Kmax/10000;
            K = 0:dK:Kmax;
            
            % Calcula root locus da malha externa de aceleração
            R_ac_out = rlocus(T_ac_out_ma,K);
            
            if flag_plot
                figure;
                rlocusplot(T_ac_out_ma,K); grid; axis('equal');
                title(['Root locus da malha externa de aceleração - ' str_ganho_in]);
            end
            
            % Determina qual pólo tende para o semi-plano direito com o 
            % aumento do ganho            
            n = find(real(R_ac_out(:,length(R_ac_out))) > 0 );
            n = n(1);
            
            % Para este pólo, determina o ganho para o qual o fator de
            % amortecimento associado a este pólo tem valor 0,7
            Qsi_ac = abs(real(R_ac_out(n,:))) ./ ...
                     sqrt(real(R_ac_out(n,:)).^2 + imag(R_ac_out(n,:)).^2);
            i = find(Qsi_ac < 0.7);
            KAmp = K(i(1));
            
            % Define ganho da malha externa de aceleração
            T_acel_k_ext(i_cg,i_alt,i_mach) = KAmp;
            
            if flag_plot
                str_ganho_ac_out = ['ganho da malha externa de aceleração: ' num2str(KAmp)];
                disp(str_ganho_ac_out);
                
                % Resposta degrau de malha fechada
                % Incorpora ganho determinado no modelo do integrador
                num_amp = -KAmp;
                den_amp = [1  0];
                Amp = tf(num_amp,den_amp);
                Amp.InputName = 'e';
                Amp.OutputName = 'ea';
                
                % Configura malha externa como fechada
                Sum_ac_out_mf = sumblk('e = Aref-Az');
                
                % Conecta malha externa de aceleração
                % Função de transferência Az x Aref (Aref -> Az)
                T_ac_out_mf = connect(Amp,T_ac_in_mf,Din_acel,Sum_ac_out_mf,'Aref','Az');
                
                % Resposta degrau
                t = 0:0.1:4;
                u = ones(size(t));
                y = lsim(T_ac_out_mf,u,t);
                figure
                plot(t,y); grid; xlabel('t (s)'); ylabel('Az (m/s2)');
                title(['Resposta degrau malha externa, ' str_ganho_ac_out]);
            end
            
            % Imprime novo ponto calculado
            disp (['i_cg= ' num2str(i_cg) ' - Alt= ' num2str(altitude(i_alt)) ...
                   ' m - Mach= ' num2str(Mach(i_mach))...
                   ' Ki= ' num2str(T_at_k_int(i_cg, i_alt, i_mach)) ...
                   ' Ke_at= ' num2str(T_at_k_ext(i_cg, i_alt, i_mach)), ... 
                   ' Ke_ac= ' num2str(T_acel_k_ext(i_cg, i_alt, i_mach))]);
               if flag_plot
                   disp('Pressione qualquer tecla');
                   pause;
               end
        end
    end
end

% Salva tabela de ganhos em autopiloto.mat
vet_x_CG = x_CG;
vet_altitude = altitude;
vet_Mach = Mach;
save autopiloto.mat T_acel_k_ext T_at_k_ext T_at_k_int T_acel_k_int ...
      vet_x_CG vet_altitude vet_Mach;

if flag_plot
   PlotAP('autopiloto.mat');
end


