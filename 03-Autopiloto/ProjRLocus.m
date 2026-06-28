
%-------------------------------------------------------------------------
% Script ProjRLocus.m
% Projeto dos autopilotos de atitude e acelera��o pelo
% m�todo de Root Locus
%
% Entrada:
%   - D: estrutura com os dados do m�ssil 
%
% Sa�da:
%   - Arquivo autopiloto.mat, com as seguintes tabelas:
%       - T_acel_k_ext: ganhos da malha externa de acelera��o
%       - T_at_k_ext:   ganhos da malha externa de atitude
%       - T_at_k_int:   ganhos da malha interna de atitude    
%       - T_acel_k_int: ganhos da malha interna de acelera��o
%       - vet_x_CG:     valores de CG  
%       - vet_altitude: valores de altitude  
%       -vet_Mach:      valores de Mach
%
% Obs: o algoritmo procura pontos not�veis no root-locus para determina��o
% dos ganhos desejados. Dependendo do sistema, estes pontos podem n�o 
% existir (num sistema inst�vel, por exemplo). Neste caso o usu�rio deve
% selecionar a condi��o problem�tica e analisar os resultados com aten��o.
% A vari�vel flag_plot abaixo definida pode ajudar nesta an�lise
%--------------------------------------------------------------------------

clear all
close all

D = DadosMissil;
D = DadosCGInercia(D);

% Flag para plotagem dos diagramas de root locus e respostas do sistema
% usado para debug e an�lise de resultados.
flag_plot = 0;

% Atuador - modelo de segunda ordem
wnat = 100*2*pi;                        % (rad/s) banda passante 
qsiat = sqrt(2)/2;                      % amortecimento
AT.num = wnat^2;                        % Fun��o de transfer�ncia do Atuador
AT.den = [1 (2*wnat*qsiat) wnat^2];

% Centro de Refer�ncia de Momentos 
CRM = D.CRM(1);

% Pontos usados para c�lculo dos ganhos do autopiloto
altitude = [10 100];
Mach = [0.6 0.75 0.9];
VetTmp = [D.TTrav ...
          D.TqB/3 ...
          2*D.TqB/3 ...
          D.TqB ...
          D.TqB + D.TqS/2 ...
          D.TqB + D.TqS];
            

      
vet_I = interp1(D.IMissil(:,1), D.IMissil(:,3), VetTmp);
vet_m = interp1(D.VProp(:,1), D.VProp(:,3), VetTmp) + D.mf;
x_CG = interp1(D.CGMissil(:,1), D.CGMissil(:,2), VetTmp);


% Inicializa tabela de ganhos do Autopiloto de Atitude
% Tabela de ganhos da manha interna
T_at_k_int = zeros(length(x_CG),length(altitude),length(Mach));

% Tabela de ganhos da malha externa
T_at_k_ext = zeros(length(x_CG),length(altitude),length(Mach));

% Inicializa tabela de ganhos do Autopiloto de Acelera��o
% Tabela de ganhos da malha interna
T_ac_k_int = zeros(length(x_CG),length(altitude),length(Mach));

% Tabela de ganhos da malha externa
T_ac_k_ext = zeros(length(x_CG),length(altitude),length(Mach));

% Loops de projeto do autopiloto

for i_cg = 1:length(x_CG)               % posi��o de CG
    for i_alt = 1:length(altitude)      % altitude
        for i_mach = 1:length(Mach)     % Mach
            
            % Grandezas dependentes do tempo de queima e posi��o do CG
            m = vet_m(i_cg);
            Iy = vet_I(i_cg);
            dxcg = (x_CG(i_cg) - CRM)/D.DRef;
            
            % C�lculo das fun��es de transfer�ncia de curto-per�odo
            [Din_acel, Din_theta, Din_alfa, Din_q] = FTransDin(Mach(i_mach), ...
                altitude(i_alt), m, Iy, dxcg, D.DRef, D.SRef);

% Controle de atitude, realimenta��o com gir�metro
%
%            e       ea  ed            dlt             q
%  ref --->O-->[ampl]-->O-->[ atuador ]---[ dinamica ]---[1/s]-+---> theta
%        - |           -|                              |       |
%          |            +--------------[giro]----------+       |
%          +<--------------------------------------------------+
            
            
            % Define fun��o e transfer�ncia do Atuador
            num_at = -AT.num;
            den_at = AT.den;            
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';
       
            % Root locus da malha interna
            
            % Fun��o de transfer�ncia da malha interna
            
            % Configura malha interna aberta
            Sum_in_ma = sumblk('ed = ea');
            
            % Conecta blocos da malha interna
            T_in_ma = connect(Din_q,At,Sum_in_ma,'ea','q');
            
            % Define intervalo de ganhos para c�lculo do root locus
            % Kg: ganho do giro
            Kgmax = 3;
            dKg = Kgmax/3000;
            Kg = 0:dKg:Kgmax;
            
            % Observa��o importante:
            % Algoritmo ir� procurar pontos onde os p�los da malha interna
            % se afastam do eixo real. 
            % Dependendo do sistema, pode ser necess�rio redimensionar o 
            % intervalo de Kg
            
            % Calcula root locus da malha interna
            R_in = rlocus(T_in_ma,Kg);
            
            if flag_plot
                figure;
                rlocusplot(T_in_ma,Kg); grid; axis('equal');
                title('Root locus da malha interna')
            end
            
            % Selecao robusta do ganho da malha interna:
            % ganho que MAXIMIZA o amortecimento do short-period (ponto de
            % breakaway). Para cada ganho, avalia o amortecimento do polo
            % mais proximo da instabilidade entre os polos "lentos"
            % (exclui o atuador rapido, |p|>60 rad/s). Substitui o
            % rastreamento por indice de linha do metodo original (fragil).
            zz = zeros(1,length(Kg));
            for jj = 1:length(Kg)
                p = R_in(:,jj); p = p(imag(p)>=0 & abs(p)>1e-2 & abs(p)<60);
                if isempty(p); zz(jj)=1; else; [~,id]=max(real(p)); zz(jj)=-real(p(id))/abs(p(id)); end
            end
            [~,jb] = max(zz);
            Kat = Kg(jb);

            % Determina ponto da tabela de ganhos da malha interna dos
            % autopilotos de atitude e acelera��o
            T_at_k_int(i_cg,i_alt,i_mach) = Kat;
            T_acel_k_int(i_cg,i_alt,i_mach) = Kat;

            if flag_plot
               str_ganho_in = ['ganho da malha interna: ' num2str(Kat)];
               disp(str_ganho_in);
            end
            
            % Root locus da malha externa do controle de atitude
            
            % Malha interna, controle de atitude/acelera��o
            % Incorpora ganho da malha interna (Kat) no modelo do atuador
            num_at = -AT.num*Kat;
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';
            
            % Configura malha interna fechada
            Sum_in_mf = sumblk('ed = ea-q');
            
            % Conecta blocos da malha interna
            % Fun��o de transfer�ncia q x ea (ea -> q)
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
            
            % Integrador, fun��o de transfer�ncia theta x q (q -> theta)
            num_integ = 1;
            den_integ = [1  0];
            Integ = tf(num_integ,den_integ);
            Integ.InputName = 'q';  Integ.OutputName = 'theta';
            
            % Amplificador
            % Fun��o de transfer�ncia ea x e (e -> ea)
            num_amp = 1;
            den_amp = 1;
            Amp = tf(num_amp,den_amp);
            Amp.InputName = 'e';
            Amp.OutputName = 'ea';
            
            % Configura malha externa como aberta
            Sum_out_ma = sumblk('e = ref');
            
            % Conecta blocos da malha externa aberta
            % Fun��o de transfer�ncia theta x ref (ref -> theta)
            T_out_ma = connect(Amp,T_in_mf,Integ,Sum_out_ma,'ref','theta');
            
            % Root locus da malha externa de atitude
            
            % Define intervalo de ganhos para c�lculo do root locus
            Kmax = 50;
            dK = Kmax/4000;
            K = 0:dK:Kmax;
            
            % Observa��o importante:
            % Algoritmo ir� procurar pontos onde os p�los da malha externa
            % t�m fator de amortecimento de 0,7
            % Dependendo do sistema, pode ser necess�rio redimensionar o 
            % intervalo de K
              
            % Calcula root locus da malha externa de atitude
            T_out_ma = minreal(T_out_ma);   % cancela polo-zero lento (incidencia)
            R_out = rlocus(T_out_ma,K);
            if flag_plot
                figure
                rlocusplot(T_out_ma,K); grid; axis('equal');
                title(['Root locus da malha externa - ' str_ganho_in]);
            end
            
            % Selecao robusta: ganho onde o PAR COMPLEXO de manobra
            % (3..60 rad/s) atinge zeta = 0.5. Usa-se 0.5 (e nao 0.7) porque
            % o zero lento de incidencia faz o ganho de zeta=0.7 resultar em
            % banda passante baixa; zeta=0.5 da banda ~2-3 Hz com bom
            % amortecimento. Avalia por coluna de ganho (sem rastrear linha).
            zz = ones(1,length(K));
            for jj = 1:length(K)
                p = R_out(:,jj); p = p(imag(p)>1e-6 & abs(p)>3 & abs(p)<60);
                if ~isempty(p); [~,id]=max(real(p)); zz(jj)=-real(p(id))/abs(p(id)); end
            end
            i = find(zz < 0.5, 1); if isempty(i); [~,i] = min(zz); end
            KAmp = K(i);
            
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
            
            % Controle de acelera��o, realimenta��o com gir�metro
            %
            %            e       ea  ed            dlt
            %  Aref --->O-->[K/s]-->O-->[ atuador ]------+-->[ din_az]---+-> Az
            %         - |          -|                    |               |
            %           |           |         q          |               |
            %           |           +-[giro]<--[din_q]---+               |
            %           |                                                |
            %           +<----------------------[acelerometro]-----------+
            
            
            % Malha interna: igual � do controle de acelera��o, realocada
            
            % Malha interna, controle de acelera��o
            % Redefine fun��o de transfer�ncia do atuador: ed -> dlt
            num_at = -AT.num*Kat;
            At = tf(num_at,den_at);
            At.InputName = 'ed';  At.OutputName = 'dlt';
            
            % Configura malha interna como fechada
            Sum_ac_in_mf = sumblk('ed = ea-q');
            
            % Conecta blocos da malha interna
            % Fun��o de transfer�ncia ea -> dlt
            T_ac_in_mf = connect(Din_q,At,Sum_ac_in_mf,'ea','dlt');
                        
            % Define fun��o de transfer�ncia do amplificador/integrador 
            % da malha externa: e -> ea
            num_amp = -1;
            den_amp = [1  0];
            Amp = tf(num_amp,den_amp);
            Amp.InputName = 'e';
            Amp.OutputName = 'ea';
            
            % Configura malha externa de acelera��o como aberta
            Sum_ac_out_ma = sumblk('e = Aref');
            
            % Conecta blocos da malha externa de acelera��o, aberta
            % Fun��o de transfer�ncia Aref -> Az          
            T_ac_out_ma = connect(Amp,T_ac_in_mf,Din_acel,Sum_ac_out_ma,'Aref','Az');
            
            % Root locus da malha externa de acelera��o
            
            % Define intervalo de ganhos para c�lculo do root locus
            % K: ganho do integrador da malha externa
            Kmax = 5;
            dK = Kmax/1500;
            K = 0:dK:Kmax;
            
            % Calcula root locus da malha externa de acelera��o
            T_ac_out_ma = minreal(T_ac_out_ma); % cancela curto-periodo (Din_acel em serie)
            R_ac_out = rlocus(T_ac_out_ma,K);
            
            if flag_plot
                figure;
                rlocusplot(T_ac_out_ma,K); grid; axis('equal');
                title(['Root locus da malha externa de acelera��o - ' str_ganho_in]);
            end
            
            % Selecao robusta por AMORTECIMENTO: a aceleracao tem zero de fase
            % nao-minima, que limita o ganho. Escolhe-se o MAIOR ganho em que o
            % par complexo DOMINANTE ainda tem zeta >= zt_alvo (resposta sem
            % overshoot excessivo), limitado por 0.5*ganho de instabilidade
            % (margem de ganho 6 dB). zt_alvo=0.6 -> ~5-10% overshoot.
            zt_alvo = 0.6;
            Kstab = K(end); KAmp = 0;
            for jj = 2:length(K)
                p = R_ac_out(:,jj);
                if any(real(p) > 1e-6); Kstab = K(jj); break; end
                pc = p(imag(p)>1e-6);
                if isempty(pc)
                    KAmp = K(jj);                          % so polos reais: bem amortecido
                else
                    if min(-real(pc)./abs(pc)) >= zt_alvo; KAmp = K(jj); end
                end
            end
            KAmp = min(KAmp, 0.5*Kstab);
            if KAmp <= 0; KAmp = 0.5*Kstab; end
            
            % Define ganho da malha externa de acelera��o
            T_acel_k_ext(i_cg,i_alt,i_mach) = KAmp;
            
            if flag_plot
                str_ganho_ac_out = ['ganho da malha externa de acelera��o: ' num2str(KAmp)];
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
                
                % Conecta malha externa de acelera��o
                % Fun��o de transfer�ncia Az x Aref (Aref -> Az)
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


