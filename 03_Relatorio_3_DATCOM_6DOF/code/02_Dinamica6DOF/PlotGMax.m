addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '00_Comum'));  % fonte comum (00_Comum)
% Script para avaliar a manobra máxima em uma dada condição de voo
% M_aed.mat: Coeficientes aerodinâmicos
% D = DadosMissil: dados do míssil

clear all
close all

%Height = input('Altura de voo: ');
Height = 10;

[T,VSom,P,rho,nu,mu] = atmosisa(Height);

Aer = load('M_aed.mat');
[DeltaX, iDeltaX] = max(Aer.dados.delta);

NMach = length(Aer.dados.mach);
NAlpha = length(Aer.dados.alpha);
Alpha = Aer.dados.alpha;

CRM = -Aer.dados.XCG;

D = DadosMissil;
D = DadosCGInercia(D);
NCG = length(D.CGMissil(:,1));
for iCG = 1:NCG
    XCG = D.CGMissil(iCG,2);
    t = D.CGMissil(iCG,1);
    m = interp1(D.VProp(:,1), D.VProp(:,3),t) + D.Mf;
    for iMach = 1:NMach
        Mach = Aer.dados.mach(iMach);
        V = Mach*VSom;
        Q = 0.5*rho*V^2;

        % Procura ponto onde CM troca de sinal
        Cm0(:) = Aer.M_CM(iDeltaX,iMach,:);
        CN(:) =  Aer.M_CN(iDeltaX,iMach,:);
        Cm(:) = Cm0(:) - (XCG - CRM)/D.DRef*CN(:);
        sinal = 1;
        k = 1;
        while sinal > 0 && k < NAlpha
            sinal = sign(Cm(k)).*sign(Cm(k+1));
            k = k + 1;
        end
        if (k == NAlpha)
            disp('Não achou ponto de equilibrio')
        else
            AlphaEq(iMach,iCG) = interp1([Cm(k-1)  Cm(k)], [Alpha(k-1) Alpha(k)],0 );
            CN(:) = Aer.M_CN(iDeltaX,iMach,:);
            CNX(iMach,iCG) = interp1([Alpha(k-1) Alpha(k)], [CN(k-1)  CN(k)], AlphaEq(iMach,iCG));
            MatGMax(iMach,iCG) = abs(Q*D.SRef*CNX(iMach,iCG)/m/9.8);
        end
    end
end

figure;
title('Manobra Máxima')
for iCG = 1:NCG
    plot(Aer.dados.mach, MatGMax(:,iCG));
    xlabel('Mach');
    ylabel('G Max');
    grid on
    hold on
end
title('Manobra Máxima')

LEG = {};
for i=1:length(D.CGMissil(:,1))
    LEG(i)= {[ 'CG= ' num2str(abs(D.CGMissil(i,2)), '%4.2f' )  ...
               ' m - t= ' num2str(round(D.CGMissil(i,1)), '%3.0f') ' s']};
end
legend(LEG);
legend('Location','best')






