# 00_Comum — Fonte unica dos dados do missil (MANSUP / Exocet MM40)

Edite o missil **so aqui**. Cada pasta de codigo tem um *forwarder*
`DadosMissil.m` / `DadosCGInercia.m` que faz `addpath` desta pasta e chama
`DadosMissilComum` / `DadosCGInerciaComum`.

| Arquivo | Conteudo |
|---|---|
| `DadosMissilComum.m`    | massa, propulsao, controle/guiamento |
| `DadosCGInerciaComum.m` | secoes, CG, inercia (x negativo do nariz) |
| `M_aed.mat`             | tabela aerodinamica DATCOM (geometria Exocet, XCG=2.607) |

Dimensionamento (resumo): M0~917 kg, L=5.79 m, D=0.35 m, Mach 0.9, 70 km.
Sustainer EmpS=3.32 kN dimensionado p/ o ARRASTO DE CRUZEIRO COM SUSTENTACAO
(nao desacelera). xcg0=-2.75 m (margem ~0.8 cal, Gmax limpo). KAlt=1, espoleta=20.
