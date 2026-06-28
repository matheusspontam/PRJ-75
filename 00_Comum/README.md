# 00_Comum — Fonte única dos dados do míssil

Estes são os arquivos **universais** do míssil antinavio (Exocet MM40),
usados por todos os códigos do projeto. Edite o míssil **só aqui**.

| Arquivo | Conteúdo |
|---|---|
| `DadosMissilComum.m`    | dados gerais do míssil (massa, propulsão, controle) |
| `DadosCGInerciaComum.m` | CG e inércia (booster atrás; x negativo do nariz) |
| `M_aed.mat`             | tabela aerodinâmica (DATCOM) |

## Como funciona

Cada pasta de código (04-Guiamento e Controle, 04_Relatorio_4_Autopilotos,
03_Relatorio_3_DATCOM_6DOF/.../02_Dinamica6DOF, 02-Dinamica6DOF) tem um
**forwarder** `DadosMissil.m` / `DadosCGInercia.m` que apenas faz
`addpath` desta pasta e chama a versão `...Comum`. Assim:

- Os scripts continuam chamando `DadosMissil` / `DadosCGInercia` normalmente.
- Os dados ficam num lugar só — não há mais cópias para manter sincronizadas.

## Observação sobre o M_aed.mat

O `addpath` feito pelos forwarders também deixa este `M_aed.mat` no caminho,
então `load('M_aed.mat')` o encontra **desde que `DadosMissil`/`DadosCGInercia`
seja chamado antes do load**. As pastas 02-Dinamica6DOF e
03/.../02_Dinamica6DOF ainda mantêm um `M_aed.mat` local porque alguns scripts
(ex.: `PlotGMax.m`) carregam o `M_aed` antes de chamar `DadosMissil`.
