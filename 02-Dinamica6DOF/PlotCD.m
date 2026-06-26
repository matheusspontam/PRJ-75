function PlotCD(MatrizAed);


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
        

        %Plotando CD
        hold on
        plot(dados.alpha,CD_plot)
        grid on
        title(['Valores de C_D para M=' num2str(dados.mach(i)) ' e ' 'X_C_G=' num2str(dados.XCG)])
        xlabel('\alpha')
        ylabel('C_D')

        
    end
    legend(LEG)
    legend('Location','best')
    
end