function PlotAP(ap_fname)

load (ap_fname);

NMach = length(vet_Mach);
NAlt = length(vet_altitude);
NCG = length(vet_x_CG);

LEG = {};
for i=1:length(vet_x_CG)
    LEG(i)= {['CG =' num2str(vet_x_CG(i), '%0.2g')]};
end


for imach = 1:NMach
    figure;
    subplot(221)
    for icg = 1:NCG
       plot(vet_altitude, T_at_k_int(icg,:,imach)); grid on; 
       xlabel('alt (m)'); ylabel('Ganho Interno')
       title(['Autopiloto de Atitude - Mach ' num2str(vet_Mach(imach))]);
       hold on
    end
    
    subplot(223)
    for icg = 1:NCG
       plot(vet_altitude, T_at_k_ext(icg,:,imach)); grid on; 
       xlabel('alt (m)'); ylabel('Ganho Externo')
       title(['Autopiloto de Atitude - Mach ' num2str(vet_Mach(imach))]);
       hold on
    end
    subplot(222)
    for icg = 1:NCG
       plot(vet_altitude, T_acel_k_int(icg,:,imach)); grid on; 
       xlabel('alt (m)'); ylabel('Ganho Interno')
       title(['Autopiloto de Aceleração - Mach ' num2str(vet_Mach(imach))]);
       hold on
    end
    
    subplot(224)
    for icg = 1:NCG
       plot(vet_altitude, T_acel_k_ext(icg,:,imach)); grid on; 
       xlabel('alt (m)'); ylabel('Ganho Externo')
       title(['Autopiloto de Aceleração - Mach ' num2str(vet_Mach(imach))]);
       hold on
    end
    
    legend(LEG)
    legend('Location','best')
    
            
end
