clc;
clear;
close all;

xcg = 2.700;
delta = -20:2:20;

write_exocet_for005(0, xcg);

out = fopen('coeficientes.dat', 'w');
fprintf(out, '%.6f ', xcg);
fprintf(out, '%d ', numel(delta));
fprintf(out, '%.8e ', delta);

for k = 1:numel(delta)
    fprintf('Delta: %.0f deg\n', delta(k));
    write_exocet_for005(delta(k), xcg);
    status = system('Misdat.exe');
    if status ~= 0
        error('Misdat.exe failed for delta = %.0f deg.', delta(k));
    end

    [mach, alpha, CN, CM, CA, CY, CLN, CLL, CL, CD, XCP, CNA, CMA, CYB, ...
        CLNB, CLLB, CNQ, CMQ, CAQ, CNAD, CMAD, CYR, CLNR, CLLR, CYP, ...
        CLNP, CLLP, hinge11, hinge12, hinge13, hinge14, hinge21, hinge22, ...
        hinge23, hinge24] = DATCOMreader('for006.dat');

    if k == 1
        fprintf(out, '%d ', numel(mach));
        fprintf(out, '%.8e ', mach);
        fprintf(out, '%d ', numel(alpha));
        fprintf(out, '%.8e ', alpha);
    end

    for im = 1:numel(mach)
        for ia = 1:numel(alpha)
            fprintf(out, ['%.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e ' ...
                '%.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e ' ...
                '%.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e %.8e ' ...
                '%.8e %.8e %.8e %.8e %.8e %.8e '], ...
                hinge11(ia,im), hinge12(ia,im), hinge13(ia,im), hinge14(ia,im), ...
                hinge21(ia,im), hinge22(ia,im), hinge23(ia,im), hinge24(ia,im), ...
                CN(ia,im), CM(ia,im), CA(ia,im), CY(ia,im), CLN(ia,im), CLL(ia,im), ...
                CL(ia,im), CD(ia,im), 0, XCP(ia,im), CNA(ia,im), CMA(ia,im), ...
                CYB(ia,im), CLNB(ia,im), CLLB(ia,im), CNQ(ia,im), CMQ(ia,im), ...
                CAQ(ia,im), CNAD(ia,im), CMAD(ia,im), CYR(ia,im), CLNR(ia,im), ...
                CLLR(ia,im), CYP(ia,im), CLNP(ia,im), CLLP(ia,im));
        end
    end
end
fclose(out);

Coef2Mat('coeficientes.dat');
