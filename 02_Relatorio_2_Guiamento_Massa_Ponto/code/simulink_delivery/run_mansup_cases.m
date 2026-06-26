clc;
clear;
close all;

baseDir = fileparts(mfilename('fullpath'));
cd(baseDir);
addpath(baseDir);

run_mansup_case(1);
run_mansup_case(2);
