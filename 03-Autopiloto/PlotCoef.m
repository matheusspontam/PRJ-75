function PlotCoef(MatrizAed);



%% Plotando coeficientes aerodinâmicos

load(MatrizAed);
LEG = {};
for i=1:length(dados.delta)
    LEG(i)= {['\delta=' num2str(dados.delta(i))]};
end

for i=1:length(dados.mach) %Para cada mach
    figure()
    for j=1:length(dados.delta) %Para cada delta
        hold on
        CN_plot=zeros(1,length(M_CN(j,i,:)));
        CN_plot(:)=M_CN(j,i,:);
        CM_plot=zeros(1,length(M_CM(j,i,:)));
        CM_plot(:)=M_CM(j,i,:);
        CA_plot=zeros(1,length(M_CA(j,i,:)));
        CA_plot(:)=M_CA(j,i,:);
        CD_plot=zeros(1,length(M_CD(j,i,:)));
        CD_plot(:)=M_CD(j,i,:);
        CL_plot=zeros(1,length(M_CL(j,i,:)));
        CL_plot(:)=M_CL(j,i,:);
        XCP_plot=zeros(1,length(M_XCP(j,i,:)));
        XCP_plot(:)=M_XCP(j,i,:);
        CNA_plot=zeros(1,length(M_CNA(j,i,:)));
        CNA_plot(:)=M_CNA(j,i,:);
        CMA_plot=zeros(1,length(M_CMA(j,i,:)));
        CMA_plot(:)=M_CMA(j,i,:);
        CMQ_plot=zeros(1,length(M_CMQ(j,i,:)));
        CMQ_plot(:)=M_CMQ(j,i,:);
        CLLP_plot=zeros(1,length(M_CLLP(j,i,:)));
        CLLP_plot(:)=M_CLLP(j,i,:);
        
        %Plotando CN
%         subplot(4,2,1)
%         hold on
%         plot(dados.alpha,CN_plot)
%         grid on
%         title(['Valores de C_N para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
%         xlabel('\alpha')
%         ylabel('C_N')

%         %Plotando CMQ
%         subplot(4,2,1)
%         hold on
%         plot(dados.alpha,CMQ_plot)
%         grid on
%         title(['Valores de C_MQ para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
%         xlabel('\alpha')
%         ylabel('C_{MQ}')

        %Plotando CM
        subplot(3,2,1)
        hold on
        plot(dados.alpha,CM_plot)
        grid on
        title(['Valores de C_M para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_M')
%         %Plotando CA
%         subplot(4,2,2)
%         hold on
%         plot(dados.alpha,CA_plot)
%         grid on
%         title(['Valores de C_A para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
%         xlabel('\alpha')
%         ylabel('C_A')
%         %Plotando CLLP
%         subplot(4,2,2)
%         hold on
%         plot(dados.alpha,CLLP_plot)
%         grid on
%         title(['Valores de C_{LLP} para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
%         xlabel('\alpha')
%         ylabel('C_{LLP}')
        %Plotando CD
        subplot(3,2,6)
        hold on
        plot(dados.alpha,CD_plot)
        grid on
        title(['Valores de C_D para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_D')
        %Plotando CL
        subplot(3,2,5)
        hold on
        plot(dados.alpha,CL_plot)
        grid on
        title(['Valores de C_L para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_L')
 
%         %Plotando XCP
%         subplot(3,2,2)
%         hold on
%         plot(dados.alpha,XCP_plot)
%         grid on
%         ylim([-4 +4])
%         title(['Valores de X_C_P para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
%         xlabel('\alpha')
%         ylabel('X_C_P')
        %Plotando CMQ
        subplot(3,2,2)
        hold on
        plot(dados.alpha,CMQ_plot)
        grid on
        title(['Valores de C_MQ para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_{MQ}')
        
        %Plotando CNA
        subplot(3,2,3)
        hold on
        plot(dados.alpha,CNA_plot)
        grid on
        title(['Valores de C_N_A para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_N_A')
        %Plotando CMA
        subplot(3,2,4)
        hold on
        plot(dados.alpha,CMA_plot)
        grid on
        title(['Valores de C_M_A para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_M_A')
    end
    legend(LEG)
    legend('Location','best')
    
end