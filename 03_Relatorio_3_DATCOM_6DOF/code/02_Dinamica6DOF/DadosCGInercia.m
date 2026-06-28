function [D] = DadosCGInercia(D)
% Forwarder para a FONTE UNICA dos dados de CG/inercia.
% NAO edite os dados aqui. Edite: 00_Comum/DadosCGInerciaComum.m
addpath(fullfile(fileparts(mfilename('fullpath')), '..', '..', '..', '00_Comum'));
D = DadosCGInerciaComum(D);
end
