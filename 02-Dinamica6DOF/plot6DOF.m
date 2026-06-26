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
    menusubsys = menu('Escolha','Fim','Dinamica 6DOF','Autopiloto','Guiamento','Atuador')
    switch menusubsys
        case 2  % Dinamica 6DOF
            imenu = 2'
            while (imenu ~= 1)
                imenu = menu('Escolha','Fim','Trajetória','Aceleração',...
                    'Velocidade','Propulsão','alfa x delta','p q r',...
                    'Euler','Forças Aerodinâmicas', 'Momentos');
                close;
                switch (imenu)
                    case 2      % Trajetória
                        
%                         subplot(221)
%                         N = length(S.Xm.Data);
%                         if S.Bingo(length(S.Bingo))
%                             plot(S.Xm.Data,S.Zm.Data,'k',S.XTgt.Data,S.ZTgt.Data,'b.',...
%                                 S.Xm.Data(N),S.Zm.Data(N),'r*');
%                         else
%                             plot(S.Xm.Data,S.Zm.Data,'k',S.XTgt.Data,S.ZTgt.Data,'b.',...
%                                 S.Xm.Data(N),S.Zm.Data(N),'bo');
%                         end
%                         xlabel(' x (m)'); ylabel('z (m)'); grid
%                         legend('Míssil','Alvo','Bingo','Location','southeast');
%                         
%                         subplot(222)
%                         plot(S.Vm.Time,S.Vm.Data);
%                         xlabel(' t (s)'); ylabel('Vm (m/s)'); grid
%                         
%                         subplot(223)
%                         plot(S.Gama.Time,S.Gama.Data/D2R);
%                         xlabel(' t (s)'); ylabel('Gama (graus)'); grid
%                         
%                         subplot(224)
%                         plot(S.MachN.Time,S.MachN.Data);
%                         xlabel(' t (s)'); ylabel('Mach'); grid
                        subplot(221)
                        plot(S.Xe.Time,S.Xe.Data(:,1));
                        xlabel(' t (s)'); ylabel('Xm (m)'); grid
                        
                        subplot(222)
                        plot(S.Xe.Data(:,1),S.Xe.Data(:,2));
                        xlabel(' Xm (m)'); ylabel('Ym (m)'); grid
                        axis('equal');
                        
                        subplot(223)
                        plot(S.Xe.Data(:,1),-S.Xe.Data(:,3));
                        xlabel(' Xm (m)'); ylabel('Zm (m)'); grid
                        axis('equal');

                        subplot(224)
                        plot(S.Xe.Data(:,2),-S.Xe.Data(:,3));
                        xlabel(' Ym (m)'); ylabel('Zm (m)'); grid
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
                        plot(S.Ixx.Time,S.Ixx.Data*10,'k',S.Iyy.Time,S.Iyy.Data,'b');
                        legend('10*Ixx','Iyy');
                        xlabel(' t (s)'); ylabel('Inercia (kg.m2)'); grid on
                        
                    case 6      % alfa x delta
                        subplot(221)
                        plot(S.Alfa.Time,S.Alfa.Data*R2D);
                        xlabel(' t (s)'); ylabel('Alfa (graus)'); grid
                        
                        subplot(222)
                        plot(S.Beta.Time,S.Beta.Data*R2D);
                        xlabel(' t (s)'); ylabel('Beta (graus)'); grid
                        
                        subplot(223)
                        plot(S.DeltaY.Time,S.DeltaY.Data*R2D);
                        xlabel(' t (s)'); ylabel('Delta Y (graus)'); grid

                        subplot(224)
                        plot(S.DeltaZ.Time,S.DeltaZ.Data*R2D);
                        xlabel(' t (s)'); ylabel('Delta Z (graus)'); grid

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
            
        case 4  % Guiamento
            
        case 5  % Atuador
            
    end
end

end
            