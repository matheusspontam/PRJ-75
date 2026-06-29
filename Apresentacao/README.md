# Apresentação (slides) — Míssil Antinavio MANSUP

Slides em **Beamer** (`apresentacao.tex`) com o design e os resultados do míssil.

## Como compilar

```bash
pdflatex apresentacao.tex
pdflatex apresentacao.tex   # 2x (sumário/referências)
```

ou `latexmk -pdf apresentacao.tex`.

## Dependência das figuras

O `.tex` usa `\graphicspath{{../Plots_Relevantes/}}`, então ele puxa os
gráficos da pasta `Plots_Relevantes/` do repositório. Para compilar:

- **Local (MiKTeX/TeXLive)**: compile a partir desta pasta dentro do repo —
  o caminho relativo `../Plots_Relevantes/` funciona direto.
- **Overleaf**: faça upload mantendo a estrutura (a pasta `Plots_Relevantes/`
  junto), ou copie os PNGs usados para dentro do projeto e ajuste o
  `\graphicspath`.

Figuras usadas: `01_Gmax`, `02_coef_aerodinamicos`, `03_ganhos_autopiloto`,
`04_degrau_autopiloto`, `05_rootlocus`, `06_guiamento_trajetoria`,
`07_guiamento_series`, `08_degrau_5g`, `09_envelope_antinavio`,
`alphaxdelta`, `autoPiloto`.

## Pacotes

Apenas pacotes padrão e estáveis: `babel(brazil)`, `graphicx`, `booktabs`,
`amsmath`, `amssymb`, `xcolor` + tema `Madrid`/`whale`. Sem `siunitx` (para
evitar incompatibilidade v2/v3); unidades escritas inline.

> Edite a linha `\author{...}` com os nomes dos integrantes do grupo.
