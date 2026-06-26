function [Mach,Alpha,CN,CM,CA,CY,CLN,CLL,CL,CD,XCP,CNA,CMA,CYB,CLNB,CLLB,CNQ, CMQ, CAQ, CNAD, CMAD, CYR, CLNR, CLLR, CYP, CLNP ,CLLP, hinge11, hinge12, hinge13, hinge14, hinge21, hinge22, hinge23, hinge24] = DATCOMreader(caso)
    %le arquivo do DATCOM e tira as informacoes uteis
    out = fopen(caso);

    aqui=search('NMACH',out);
    NMach=str2double(aqui.linha(aqui.coluna:aqui.coluna+5));

    aqui=search('NALPHA',out);
    Nalpha=str2double(aqui.linha(aqui.coluna:aqui.coluna+5));

    aqui=search('ALPHA=',out);
    linha_alpha = extractAfter(aqui.linha, 'ALPHA=');
    linha_alpha = regexprep(linha_alpha, '[,$]', ' ');
    Alpha = sscanf(linha_alpha, '%f')';
    Alpha = Alpha(1:Nalpha);

    Mach=zeros(1,NMach);
    for i=1:NMach
        aqui=search('MACH NO',out);
        Mach(i)=str2double(aqui.linha(aqui.coluna:aqui.coluna+11));
        if i>1
            if Mach(i-1)==Mach(i)
                linha=search('MACH NO',out,6,12);
                Mach(i)=str2double(linha(20:26));
            end
        end

        linha=search('ALPHA',out);
        linha=fgetl(out);
        for j=1:Nalpha
            linha=fgetl(out);
            hinge11(j,i)=str2double(linha(9:14))*10^(str2double(linha(16:18)));
            hinge12(j,i)=str2double(linha(19:24))*10^(str2double(linha(26:28)));
            hinge13(j,i)=str2double(linha(29:34))*10^(str2double(linha(36:38)));
            hinge14(j,i)=str2double(linha(39:44))*10^(str2double(linha(46:48)));
        end
        
        linha=search('ALPHA',out);
        linha=fgetl(out);
        for j=1:Nalpha
            linha=fgetl(out);
            hinge21(j,i)=str2double(linha(9:14))*10^(str2double(linha(16:18)));
            hinge22(j,i)=str2double(linha(19:24))*10^(str2double(linha(26:28)));
            hinge23(j,i)=str2double(linha(29:34))*10^(str2double(linha(36:38)));
            hinge24(j,i)=str2double(linha(39:44))*10^(str2double(linha(46:48)));
        end
        
        linha=search('ALPHA',out);
        linha=fgetl(out);
        for j=1:Nalpha
            linha=fgetl(out);
            CN(j,i)=str2double(linha(16:24));
            CM(j,i)=str2double(linha(26:34));
            CA(j,i)=str2double(linha(36:44));
            CY(j,i)=str2double(linha(46:54));
            CLN(j,i)=str2double(linha(56:64));
            CLL(j,i)=str2double(linha(66:74));
        end

        linha=search('ALPHA',out);
        linha=fgetl(out);
        for j=1:Nalpha
            linha=fgetl(out);   %10
            CL(j,i)=str2double(linha(16:24));
            CD(j,i)=str2double(linha(26:34));
            XCP(j,i)=str2double(linha(46:54));
        end

        linha=search('ALPHA',out);
        for j=1:Nalpha
            linha=fgetl(out);   %12
            CNA(j,i)=str2double(linha(15:27));
            CMA(j,i)=str2double(linha(27:39));
            CYB(j,i)=str2double(linha(39:51));
            CLNB(j,i)=str2double(linha(51:63));
            CLLB(j,i)=str2double(linha(63:74));
        end

        linha=search('ALPHA',out);
        for j=1:Nalpha
            linha=fgetl(out);   %11
            CNQ(j,i)=str2double(linha(15:26));
            CMQ(j,i)=str2double(linha(26:37));
            CAQ(j,i)=str2double(linha(37:48));
            CNAD(j,i)=str2double(linha(48:59));
            CMAD(j,i)=str2double(linha(59:69));
        end

        linha=search('ALPHA',out);
        for j=1:Nalpha
            linha=fgetl(out);   %11
            CYR(j,i)=str2double(linha(15:26));
            CLNR(j,i)=str2double(linha(26:37));
            CLLR(j,i)=str2double(linha(37:48));
            CYP(j,i)=str2double(linha(48:59));
            CLNP(j,i)=str2double(linha(59:70));
            CLLP(j,i)=str2double(linha(70:80));
        end
    end
    fclose(out);
end
