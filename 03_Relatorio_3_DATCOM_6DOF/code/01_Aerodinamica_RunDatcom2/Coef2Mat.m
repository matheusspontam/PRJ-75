function Coef2Mat(FileName)
% Script para transformar saída do programa RunDatcom.exe em .mat
%
% Entrada: arquivo ASCII: Coeficientes.dat
%
% Saída: arquivo M_aed.mat


C = load(FileName);

i = 1;
XCG = C(i); i = i+1;

NDelta = C(i); i = i+1;
for iDelta = 1:NDelta
    VDelta(iDelta) = C(i); i = i+1;
end

NMach = C(i); i = i+1;
for iMach = 1:NMach
    VMach(iMach) = C(i); i = i+1;
end


NAlpha = C(i); i = i+1;
for iAlpha = 1:NAlpha
    VAlpha(iAlpha) = C(i); i = i+1;
end

for iDelta = 1:NDelta
    for iMach = 1:NMach
        for iAlpha = 1:NAlpha
            M_Hinge11(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_Hinge12(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_Hinge13(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_Hinge14(iDelta,iMach,iAlpha) = C(i); i = i+1;

            M_Hinge21(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_Hinge22(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_Hinge23(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_Hinge24(iDelta,iMach,iAlpha) = C(i); i = i+1;

            M_CN(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CM(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CA(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CY(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLN(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLL(iDelta,iMach,iAlpha) = C(i); i = i+1;

            M_CL(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CD(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CD_CD(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_XCP(iDelta,iMach,iAlpha) = C(i); i = i+1;
            
            M_CNA(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CMA(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CYB(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLNB(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLLB(iDelta,iMach,iAlpha) = C(i); i = i+1;

            M_CNQ(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CMQ(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CAQ(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CNAD(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CMAD(iDelta,iMach,iAlpha) = C(i); i = i+1;

            M_CYR(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLNR(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLLR(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CYP(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLNP(iDelta,iMach,iAlpha) = C(i); i = i+1;
            M_CLLP(iDelta,iMach,iAlpha) = C(i); i = i+1;
        end
    end
end

dados.XCG = XCG;
dados.delta = VDelta;
dados.mach = VMach;
dados.alpha = VAlpha;
save('M_aed.mat','M_CN','M_CM','M_CA','M_CD','M_CL','M_XCP','M_CNA','M_CMA','M_CMQ','M_CLLP','dados');

end

