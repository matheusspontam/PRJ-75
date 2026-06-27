%-----------------------------------------------------
% Função plot6DOF.m
% Função de plotagem dos resultados do míssil anti-UAV
% Entrada:
%   - S: estrutura com dados de simulação
%-----------------------------------------------------

function plot6DOF(S)

cte_grav = 9.8;
D2R = pi/180;
R2D = 180/pi;
menusubsys = 2;
while (menusubsys ~= 1)
    menusubsys = menu('Escolha','Fim','Dinamica 6DOF','Autopiloto','Autodiretor','Atuador');
    close;
    switch menusubsys
        case 2  % Dinamica 6DOF
            imenu = 2;
            while (imenu ~= 1)
                imenu = menu('Escolha','Fim','Trajetória','Aceleração',...
                    'Velocidade','Propulsão','alfa x delta','p q r',...
                    'Euler','Forças Aerodinâmicas', 'Momentos');
                close;
                switch (imenu)
                    case 2      % Trajetória
                        
                        subplot(221)
                        plot(S.Xe.Time,S.Xe.Data(:,1),S.Xa.Time,S.Xa.Data(:,1));
                        xlabel(' t (s)'); ylabel('Xm (m)'); grid
                        legend('Missil','Alvo');
                        
                        Na = length(S.Xa.Time);
                        subplot(222)
                        plot(S.Xe.Data(:,1),S.Xe.Data(:,2), S.Xa.Data(:,1),S.Xa.Data(:,2),...
                             S.Xa.Data(Na,1),S.Xa.Data(Na,2),'*');
                        xlabel(' Xm (m)'); ylabel('Ym (m)'); grid
                        legend('Missil','Alvo');
                        axis('equal');
                        
                        subplot(223)
                        plot(S.Xe.Data(:,1),-S.Xe.Data(:,3), S.Xa.Data(:,1),-S.Xa.Data(:,3),...
                             S.Xa.Data(Na,1),-S.Xa.Data(Na,3),'*');
                        xlabel(' Xm (m)'); ylabel('Zm (m)'); grid
                        legend('Missil','Alvo');
                        axis('equal');

                        subplot(224)
                        plot(S.Xe.Data(:,2),-S.Xe.Data(:,3), S.Xa.Data(:,2),-S.Xa.Data(:,3),...
                             S.Xa.Data(Na,2),-S.Xa.Data(Na,3),'*');
                        xlabel(' Ym (m)'); ylabel('Zm (m)'); grid
                        legend('Missil','Alvo');
                        axis('equal');

                    case 3      % Aceleração
                        subplot(221)
                        plot(S.Ab.Time,S.Ab.Data(:,1)/cte_grav);
                        xlabel(' t (s)'); ylabel('Ax (g)'); grid
                        
                        subplot(222)
                        plot(S.Ab.Time,S.Ab.Data(:,2)/cte_grav);
                        xlabel(' t (s)'); ylabel('Ay (g)'); grid
                        
                        subplot(223)
                        plot(S.Ab.Time,S.Ab.Data(:,3)/cte_grav);
                        xlabel(' t (s)'); ylabel('Az (g)'); grid

                        ANormal = sqrt(S.Ab.Data(:,2).^2 + S.Ab.Data(:,3).^2);
                        subplot(224)
                        plot(S.Ab.Time,ANormal/cte_grav);
                        xlabel(' t (s)'); ylabel('An (g)'); grid

                    case 4      % Velocidade
                        subplot(221)
                        plot(S.Vb.Time,S.Vb.Data(:,1));
                        xlabel(' t (s)'); ylabel('Vxb (m/s)'); grid
                        
                        subplot(222)
                        plot(S.Vb.Time,S.Vb.Data(:,2));
                        xlabel(' t (s)'); ylabel('Vyb (m/s)'); grid
                        
                        subplot(223)
                        plot(S.Vb.Time,S.Vb.Data(:,3));
                        xlabel(' t (s)'); ylabel('Vzb (m/s)'); grid
                        
                        subplot(224)
                        plot(S.V.Time,S.V.Data);
                        xlabel(' t (s)'); ylabel('V (m/s)'); grid
                                                
                                                
                    case 5      % Propulsão
                        subplot(221)
                        plot(S.FProp.Time,S.FProp.Data(:,1));
                        xlabel(' t (s)'); ylabel('Empuxo (N)'); grid
                        
                        subplot(222)
                        plot(S.m.Time,S.m.Data);
                        xlabel(' t (s)'); ylabel('Massa (kg)'); grid
                        
                        subplot(223)
                        plot(S.XCG.Time,S.XCG.Data(:,1));
                        xlabel(' t (s)'); ylabel('XCG'); grid
                        
                        subplot(224)
                        plot(S.Ixx.Time,S.Ixx.Data*100,'k',S.Iyy.Time,S.Iyy.Data,'b');
                        legend('100*Ixx','Iyy');
                        xlabel(' t (s)'); ylabel('Inercia (kg.m2)'); grid on
                        
                    case 6      % alfa x delta
                        subplot(221)
                        plot(S.Alfa.Time,S.Alfa.Data*R2D);
                        xlabel(' t (s)'); ylabel('Alfa (graus)'); grid
                        
                        subplot(222)
                        plot(S.Beta.Time,S.Beta.Data*R2D);
                        xlabel(' t (s)'); ylabel('Beta (graus)'); grid
                        
                        subplot(223)
                        plot(S.DeltaZ.Time,S.DeltaZ.Data*R2D);
                        xlabel(' t (s)'); ylabel('Delta Z (graus)'); grid

                        subplot(224)
                        plot(S.DeltaY.Time,S.DeltaY.Data*R2D);
                        xlabel(' t (s)'); ylabel('Delta Y (graus)'); grid

                    case 7      % Velocidade angular
                        subplot(221)
                        plot(S.wb.Time,S.wb.Data(:,1)*R2D);
                        xlabel(' t (s)'); ylabel('p (graus/s)'); grid
                        
                        subplot(222)
                        plot(S.wb.Time,S.wb.Data(:,2)*R2D);
                        xlabel(' t (s)'); ylabel('q (graus/s)'); grid
                        
                        subplot(223)
                        plot(S.wb.Time,S.wb.Data(:,3)*R2D);
                        xlabel(' t (s)'); ylabel('r (graus/s)'); grid
                        
                    case 8      % Euler
                        subplot(221)
                        plot(S.Euler.Time,S.Euler.Data(:,1)*R2D);
                        xlabel(' t (s)'); ylabel('phi (graus)'); grid
                        
                        subplot(222)
                        plot(S.Euler.Time,S.Euler.Data(:,2)*R2D);
                        xlabel(' t (s)'); ylabel('teta (graus)'); grid
                        
                        subplot(223)
                        plot(S.Euler.Time,S.Euler.Data(:,3)*R2D);
                        xlabel(' t (s)'); ylabel('psi (graus)'); grid
                                              
                    case 9      % Forças Aerodinâmicas
                        subplot(221)
                        plot(S.FAer.Time,S.FAer.Data(:,1));
                        xlabel(' t (s)'); ylabel('FAerXm (N)'); grid
                        
                        subplot(222)
                        plot(S.FAer.Time,S.FAer.Data(:,2));
                        xlabel(' t (s)'); ylabel('FAerYm (N)'); grid
                        
                        subplot(223)
                        plot(S.FAer.Time,S.FAer.Data(:,3));
                        xlabel(' t (s)'); ylabel('FAerZm (N)'); grid
                                              
                    case 10      % Momentos Aerodinâmicos
                        subplot(221)
                        plot(S.MAer.Time,S.MAer.Data(:,1));
                        xlabel(' t (s)'); ylabel('MAerXm (Nm)'); grid
                        
                        subplot(222)
                        plot(S.MAer.Time,S.MAer.Data(:,2));
                        xlabel(' t (s)'); ylabel('MAerYm (Nm)'); grid
                        
                        subplot(223)
                        plot(S.MAer.Time,S.MAer.Data(:,3));
                        xlabel(' t (s)'); ylabel('MAerZm (Nm)'); grid
                                              
                end
            end
            close all
        case 3  % Autopiloto
            subplot(221)
            plot(S.Theta_Ref.Time, S.Theta_Ref.Data*R2D, S.Euler.Time, S.Euler.Data(:,2)*R2D);
            legend('Comandado','Executado');
            xlabel(' t (s)'); ylabel('Theta'); grid
            
            subplot(222)
            plot(S.Psi_Ref.Time, S.Psi_Ref.Data*R2D, S.Euler.Time, S.Euler.Data(:,3)*R2D);
            legend('Comandado','Executado');
            xlabel(' t (s)'); ylabel('Psi'); grid

            subplot(223)
            plot(S.Acel_y_ref.Time, S.Acel_y_ref.Data/cte_grav, S.Acel.Time, S.Acel.Data(:,2)/cte_grav);
            legend('Comandado','Executado');
            xlabel(' t (s)'); ylabel('Aceleração Y (g)'); grid
            
            subplot(224)
            plot(S.Acel_z_ref.Time, S.Acel_z_ref.Data/cte_grav, S.Acel.Time, S.Acel.Data(:,3)/cte_grav);
            legend('Comandado','Executado');
            xlabel(' t (s)'); ylabel('Aceleração Z (g)'); grid
            
        case 4  % Autodiretor
            subplot(221)
            plot(S.PsiADIdeal.Time, S.PsiADIdeal.Data*R2D, ...
                 S.RastreioIdeal.Time, S.RastreioIdeal.Data*10);
             legend('PsiAD','Rastreio');
             xlabel(' t (s)'); ylabel('PsiAD'); grid
            
            subplot(222)
            plot(S.ThetaADIdeal.Time, S.ThetaADIdeal.Data*R2D, ...
                 S.RastreioIdeal.Time, S.RastreioIdeal.Data*10);
             legend('PsiAD','Rastreio');
            xlabel(' t (s)'); ylabel('ThetaAD'); grid

            subplot(223)
            plot(S.OmegaZIdeal.Time, S.OmegaZIdeal.Data*R2D);
            xlabel(' t (s)'); ylabel('OmegaZ'); grid
            
            subplot(224)
            plot(S.OmegaYIdeal.Time, S.OmegaYIdeal.Data*R2D);
            xlabel(' t (s)'); ylabel('OmegaY'); grid
            
            
        case 5  % Atuador
            
    end
end

end
            