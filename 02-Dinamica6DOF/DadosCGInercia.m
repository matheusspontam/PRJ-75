function [D] = DadosCGInercia(D)
% Forwarder -> 00_Comum/DadosCGInerciaComum.m (fonte unica)
addpath(fullfile(fileparts(mfilename('fullpath')), '..', '00_Comum'));
D = DadosCGInerciaComum(D);
end
