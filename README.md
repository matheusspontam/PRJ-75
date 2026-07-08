# PRJ-75 - Projeto de Míssil Antinavio

Este repositório reúne os relatórios, códigos, modelos e resultados gerados ao longo do projeto de PRJ-75. A organização foi feita por etapa de trabalho, mantendo separados os relatórios, os códigos usados e as figuras/resultados.

## 📄 Relatório final

O **relatório integrado final** (em inglês, projeto 6DOF em malha fechada) está em:

> **[`05_Projeto_Integrado_Final/1_report/Relatorio_PRJ75_Exame.pdf`](05_Projeto_Integrado_Final/1_report/Relatorio_PRJ75_Exame.pdf)**

Fontes LaTeX na mesma pasta: `main.tex` + `sections/` (13 seções) + `figures/`.
Para recompilar: `pdflatex main.tex` (2×).

## Estrutura

```text
01_Relatorio_1_Dimensionamento_Propulsao_Solida/
02_Relatorio_2_Guiamento_Massa_Ponto/
03_Relatorio_3_DATCOM_6DOF/
04_Relatorio_4_Autopilotos/
05_Projeto_Integrado_Final/
```

## 01 - Dimensionamento e Propulsão Sólida

Objetivo: dimensionar preliminarmente um míssil antinavio equivalente à classe Exocet/MM40, com alcance de 70 km, Mach 0,9 e propulsão apenas sólida.

Conteúdo:

- `report/`: relatório em LaTeX e PDF.
- `code/`: script MATLAB de dimensionamento e modelo `SimX.mdl`.
- `results/`: gráfico de distância e velocidade.

Arquivos principais:

- `code/dimensionamento_exocet.m`
- `code/SimX.mdl`
- `report/main.pdf`

## 02 - Guiamento Massa-Ponto Horizontal

Objetivo: simular dois casos horizontais do MANSUP no plano X-Z:

- alvo a 65 km, lançamento na direção do alvo, autodiretor ligado a 20 km;
- alvo a 15 km, lançamento com marcação de 90 graus, autodiretor ligado desde o lançamento e curva pré-programada até o alvo entrar no cone.

Conteúdo:

- `report/`: relatório em LaTeX e PDF.
- `code/simulink_delivery/`: modelo Simulink e scripts MATLAB usados na simulação.
- `results/figures_simulink/`: trajetórias, históricos e prints do Simulink.

Arquivos principais:

- `code/simulink_delivery/MassaPontoMANSUP_2018b.mdl`
- `code/simulink_delivery/run_mansup_cases.m`
- `code/simulink_delivery/run_mansup_case.m`
- `code/simulink_delivery/CondLanc.m`
- `report/main.pdf`

## 03 - DATCOM, CG/Inércia e Dinâmica 6DOF

Objetivo: gerar o banco aerodinâmico do míssil, estimar CG/inércia e rodar uma simulação 6DOF inicial.

Conteúdo:

- `report/`: relatório em LaTeX e PDF.
- `code/01_Aerodinamica_RunDatcom2/`: arquivos de aerodinâmica, DATCOM, `for005.dat`, `coeficientes.dat` e conversão para `M_Aed.mat`.
- `code/02_Dinamica6DOF/`: scripts/modelos para dinâmica 6DOF.
- `results/figures/`: coeficientes, resposta 6DOF, massa, CG e inércia.

Arquivos principais:

- `code/01_Aerodinamica_RunDatcom2/for005.dat`
- `code/01_Aerodinamica_RunDatcom2/Coef2Mat.m`
- `code/01_Aerodinamica_RunDatcom2/M_aed.mat`
- `code/02_Dinamica6DOF/DadosMissil.m`
- `code/02_Dinamica6DOF/DadosCGInercia.m`
- `code/02_Dinamica6DOF/VooUnico.m`
- `report/main.pdf`

Observação: `Misdat.exe` foi mantido porque faz parte do fluxo local usado para rodar DATCOM.

## 04 - Autopilotos de Atitude e Aceleração

Objetivo: projetar autopilotos de atitude e aceleração usando os dados aerodinâmicos, CG e inércia do relatório anterior.

Conteúdo:

- `report/`: relatório em LaTeX e PDF.
- `code/`: scripts MATLAB, modelo `Autopiloto.slx`, funções de transferência e matriz aerodinâmica.
- `results/figures/`: root-locus, curvas de ganho e respostas ao degrau.

Arquivos principais:

- `code/ProjRLocus_antiship.m`
- `code/ExportAntishipAutopilotFigures.m`
- `code/FTransDin.m`
- `code/DadosMissil.m`
- `code/DadosCGInercia.m`
- `code/DadosControle.m`
- `code/Autopiloto.slx`
- `code/M_aed.mat`
- `report/main.pdf`

## 05 - Projeto Integrado Final

Objetivo: consolidar todos os relatórios em uma visão única do projeto e preparar uma apresentação oral.

Conteúdo:

- `1_report/`: relatório integrado final completo em inglês (LaTeX + PDF).
- apresentação Beamer em `../Apresentacao/apresentacao.tex` e HTML em `../Dominio_Codigo_Missil_Antinavio.html`.

Arquivos principais:

- **`1_report/Relatorio_PRJ75_Exame.pdf`** — relatório final (PDF).
- `1_report/main.tex` + `1_report/sections/` — fontes LaTeX.
- `1_report/figures/` — figuras (plots de resultado + modelo Simulink).

## Fluxo de reprodução

Ordem recomendada:

1. Rodar o dimensionamento do Relatório 1 e validar alcance/velocidade no `SimX.mdl`.
2. Rodar os dois casos massa-ponto do Relatório 2 pelo `run_mansup_cases.m`.
3. Gerar `for005.dat`, rodar DATCOM e converter os coeficientes para `M_Aed.mat` no Relatório 3.
4. Rodar a simulação 6DOF com os dados de massa, CG e inércia.
5. Rodar `ProjRLocus_antiship.m` no Relatório 4 para gerar ganhos, root-locus e respostas ao degrau.
6. Consultar o relatório integrado e a apresentação final.

## Observações

- Os relatórios foram mantidos com seus PDFs finais e fontes LaTeX.
- Os códigos foram preservados junto aos modelos MATLAB/Simulink usados.
- Arquivos temporários de compilação LaTeX e caches Simulink foram removidos.
- O projeto integrado não substitui os relatórios parciais; ele consolida os resultados.

