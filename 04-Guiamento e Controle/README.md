# Guiamento e Controle — Engajamento antinavio (Exocet)

Simulação 6DOF do **engajamento guiado completo** do míssil antinavio (equivalente
ao Exocet MM40) contra um navio, usando o modelo `GuiamentoControle.slx`
(navegação proporcional + hold de altitude sea-skimming + autopiloto +
condições de fim de voo).

> Esta pasta foi adaptada do exemplo anti-UAV da disciplina. Os dados do míssil
> (`DadosMissil.m`, `DadosCGInercia.m`, `M_aed.mat`) e os ganhos
> (`autopiloto.mat`) são os do Exocet antinavio; os blocos do modelo
> (`GuiamentoControle.slx`) e as funções de apoio foram mantidos do curso.

## Requisitos

- MATLAB R2024a (testado)
- Simulink + Aerospace Blockset (bloco *Custom Variable Mass 6DOF*)

## Como rodar

### 1) Voo único — ver o míssil acertando o navio
No MATLAB, com esta pasta como diretório atual:

```matlab
VooUnico6DOF
```

O script:
1. carrega as condições de lançamento (`CondLanc6DOF`), os dados do míssil
   (`DadosMissil` + `DadosCGInercia` + `DadosControle`), a aerodinâmica
   (`M_aed.mat`) e os ganhos do autopiloto (`autopiloto.mat`);
2. roda `GuiamentoControle.slx`;
3. imprime o resultado do voo:
   - **`Bingo`** → o míssil atingiu o alvo (passou dentro do raio de espoleta);
   - `Velocidade mínima` / `Fuga do alvo` / `Impacto com Solo` → falhas;
4. plota a trajetória e as variáveis de voo (`plot6DOF`).

### 2) Envelope de acerto — várias distâncias/ângulos
```matlab
Envelope6DOF
```
Varre condições de lançamento e monta a matriz `Resultado` (1 = acerto) e a
figura do envelope horizontal.

### 3) (Opcional) Reprojetar os ganhos do autopiloto
Os ganhos são projetados na pasta do relatório
(`../04_Relatorio_4_Autopilotos/code/ProjRLocus_antiship.m`), que gera
`autopiloto.mat` / `autopiloto_antiship.mat`. Copie o `.mat` gerado para esta
pasta se reprojetar.

## Condições do engajamento (em `CondLanc6DOF.m`)

| Grandeza | Valor |
|---|---|
| Alvo (navio), posição | X=60000 m, Y=15000 m, Z=20 m (parado) |
| Míssil, posição inicial | X=0, Y=0, Z=10 m |
| Míssil, velocidade inicial | 40 m/s (eixo X) |
| Atitude inicial (φ, θ, ψ) | 0°, 10°, 0° |
| Altitude de cruzeiro | 30 m (sea-skimming) |
| Instante de ativação do sensor | 10 s |
| Tempo máximo de simulação | 300 s |

Distância de engajamento ≈ √(60000² + 15000²) ≈ **61,85 km**.

## Resultado esperado

- **`Bingo` = acerto**: distância mínima ao alvo ≈ **17,3 m** (< 20 m do raio de
  espoleta `D.REspoleta`).
- Voo sea-skimming a ~28 m de altitude, Mach de cruzeiro ~1,0, tempo de voo
  ~178 s.

## Arquivos principais

| Arquivo | Função |
|---|---|
| `VooUnico6DOF.m` | roda 1 engajamento e plota (ponto de entrada) |
| `Envelope6DOF.m` | roda o envelope de acerto |
| `GuiamentoControle.slx` | modelo 6DOF guiado (navegação + autopiloto + dinâmica) |
| `DadosMissil.m` | dados do míssil (Exocet MM40) |
| `DadosCGInercia.m` | CG e inércia (booster na traseira; x medido negativo do nariz) |
| `DadosControle.m` | parâmetros do autopiloto |
| `CondLanc6DOF.m` | condições de lançamento/engajamento |
| `M_aed.mat` | tabela aerodinâmica (DATCOM) do Exocet |
| `autopiloto.mat` | tabelas de ganhos do autopiloto (agendados por CG/altitude/Mach) |

## Notas de modelagem (correções aplicadas)

- **Ordem dos motores**: o booster fica **atrás** do sustentador (como no Exocet
  real), de modo que o CG **anda para frente** conforme o propelente queima.
- **Convenção de sinal do CG**: `x` é medido negativo do nariz para a cauda,
  coerente com o `CRM` (= −XCG do DATCOM); assim a distância normalizada
  `dxcg = (x_CG − CRM)/DRef` fica da ordem de ±0,5 calibre (e não ~16).
- **Estabilidade**: CG à frente do centro de pressão em todo o voo (margem
  cresce conforme o propelente queima).
