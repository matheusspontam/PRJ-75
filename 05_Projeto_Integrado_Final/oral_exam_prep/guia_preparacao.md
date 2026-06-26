# Guia de preparação para arguição

## 1. Ideia central do projeto

O projeto foi montado em quatro camadas:

1. Dimensionamento preliminar do míssil com propelente sólido.
2. Simulação massa-ponto horizontal para testar lógica de guiamento.
3. Geração de coeficientes aerodinâmicos no DATCOM e preparação de massa/CG/inércia para 6DOF.
4. Projeto dos autopilotos de atitude e aceleração com root-locus.

O ponto mais importante é explicar que os relatórios se complementam, mas ainda não formam uma simulação única totalmente integrada. O guiamento massa-ponto e o modelo 6DOF/autopiloto foram feitos em estruturas diferentes da disciplina.

## 2. Como explicar o Simulink massa-ponto

Se ele apontar para o modelo principal:

- **Atmosfera ISA**: recebe altitude de voo e calcula densidade do ar e velocidade do som. No caso horizontal, a altitude é fixa em 10 m e não é o eixo Z.
- **MachN**: calcula o número de Mach a partir da velocidade do míssil e da velocidade do som.
- **Propulsão**: fornece empuxo e massa ao longo do tempo, conforme a tabela de queima do booster e sustainer.
- **Arrasto**: calcula a força de arrasto usando densidade, velocidade, área de referência e coeficiente aerodinâmico.
- **Controle**: gera o comando lateral/normal usado para curvar o míssil.
- **Forces**: junta empuxo, arrasto, peso e comando de controle para formar as forças resultantes.
- **4th Order Point Mass**: integra as equações de movimento massa-ponto. É o bloco que atualiza posição, velocidade e ângulo de trajetória.
- **Paradas**: interrompem a simulação por condições como velocidade mínima, bater no solo ou chegar perto do alvo.

## 3. Como explicar o bloco Controle

O bloco Controle é o centro do Relatório 2.

- Ele recebe posição do míssil, posição do alvo, velocidade e ângulo de trajetória.
- Calcula a linha de visada até o alvo.
- Antes do modo terminal, usa uma lei pré-programada para colocar o alvo dentro do cone do autodiretor.
- Depois da comutação, usa a lei terminal.
- No caso 1, a comutação ocorre quando a distância ao alvo chega a 20 km.
- No caso 2, o autodiretor está ligado desde o lançamento, mas o modo terminal só entra quando o alvo está dentro do cone de 40 graus.

Frase útil: o autodiretor ligado significa que o sensor está disponível; modo terminal significa que a geometria já permite usar a informação do sensor para guiar.

## 4. Hipóteses que precisam estar claras

- O míssil foi tratado como equivalente ao Exocet/MM40 em escala e missão, sem usar dados públicos como verdade exata.
- A propulsão foi assumida totalmente sólida, com booster e sustainer.
- O sustainer foi dimensionado para equilibrar aproximadamente o arrasto em cruzeiro.
- No Relatório 2, o movimento foi no plano horizontal XZ. O eixo Z representa deslocamento lateral, não altitude.
- A altitude de 10 m entrou apenas no cálculo atmosférico.
- O alvo foi considerado parado.
- O DATCOM foi usado para gerar coeficientes aerodinâmicos da geometria equivalente.
- O CG e as inércias foram estimados por seções internas.
- O projeto de autopiloto foi feito em pontos representativos, não em todo o envelope de voo.

## 5. Pontos técnicos que podem virar pergunta

- Por que separar autodiretor ligado de modo terminal.
- Por que o caso 2 precisa de curva pré-programada.
- Por que usar o mesmo \(X_{ref}=2.700\) m no DATCOM e no 6DOF.
- Como interpretar o \(X_{CP}\) do DATCOM.
- Por que \(X_{CP}=-0.677\) não é deslocamento em metros.
- Por que o integrador aparece na malha de aceleração.
- O que significa atender \(5g\) e \(0.5\) Hz.
- Por que a malha de aceleração foi o caso limitante.
- O que o root-locus ajudou a escolher.
- Qual a limitação principal do trabalho.

## 6. Resposta curta para quando não souber um detalhe

Se a pergunta for muito específica de uma constante ou arquivo:

"Esse valor entra como hipótese/entrada do estágio correspondente. O ponto de consistência que verificamos foi manter a mesma geometria, referência de momento, massa/CG/inércia e matriz aerodinâmica ao passar do DATCOM para o 6DOF e depois para os autopilotos."

Se ele perguntar por que algo não está integrado:

"Porque partimos dos modelos-base da disciplina, que estavam separados por finalidade: massa-ponto para guiamento e 6DOF para dinâmica/controle. A integração completa seria o próximo passo, mas os dados físicos usados em cada etapa foram mantidos coerentes."

