function write_exocet_for005(delta, xcg)
fid = fopen('for005.dat', 'w');

fprintf(fid, 'DIM M\n');
fprintf(fid, 'DERIV RAD\n');
fprintf(fid, 'DAMP\n');
fprintf(fid, '$REFQ     BLAYER=TURB,\n');
fprintf(fid, '          XCG=%.3f,\n', xcg);
fprintf(fid, '          SCALE=1.0,$\n');
fprintf(fid, '$AXIBOD   TNOSE=OGIVE,\n');
fprintf(fid, '          LNOSE=0.700,\n');
fprintf(fid, '          DNOSE=0.350,\n');
fprintf(fid, '          BNOSE=0.175,\n');
fprintf(fid, '          LCENTR=5.090,\n');
fprintf(fid, '          DEXIT=0.,$\n');
fprintf(fid, '$FINSET1  SSPAN=0.175,0.370,\n');
fprintf(fid, '          CHORD=0.450,0.200,\n');
fprintf(fid, '          CFOC=1.,1.,1.,1.\n');
fprintf(fid, '          XLE=0.750,0.950,\n');
fprintf(fid, '          NPANEL=4.,\n');
fprintf(fid, '          PHIF=0.,90.,180.,270.,$\n');
fprintf(fid, '$FINSET2  SSPAN=0.175,0.330,0.450,0.565,\n');
fprintf(fid, '          CHORD=1.150,0.950,0.650,0.350,\n');
fprintf(fid, '          CFOC=0.,0.,0.,0.,\n');
fprintf(fid, '          XLE=3.800,3.950,4.250,4.650,\n');
fprintf(fid, '          NPANEL=4.,\n');
fprintf(fid, '          PHIF=0.,90.,180.,270.,$\n');
fprintf(fid, '$DEFLCT   DELTA1=0.,%.6f,0.,%.6f\n', delta, -delta);
fprintf(fid, '          XHINGE=0.975,$\n');
fprintf(fid, '$FLTCON   NALPHA=13.,\n');
fprintf(fid, '          ALPHA=-20.,-16.,-12.,-8.,-4.,-2.,0.,2.,4.,8.,12.,16.,20.,\n');
fprintf(fid, '          NMACH=5.,\n');
fprintf(fid, '          MACH=0.6,0.7,0.8,0.9,1.0,\n');
fprintf(fid, '          ALT=0.,0.,0.,0.,0.,$\n');
fprintf(fid, 'PRINT AERO HINGE\n');
fprintf(fid, 'SAVE\n');
fprintf(fid, 'NEXT CASE\n');
fclose(fid);
end
