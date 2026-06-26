# Respostas modelo para as 40 perguntas

## Relatório 1: dimensionamento

1. O objetivo foi obter uma primeira configuração física do míssil: massa, diâmetro, comprimento, massas de propelente, empuxo, tempo de queima e alcance. Esse resultado serviu como base para os relatórios seguintes.

2. Porque as funções são diferentes. O booster fornece grande empuxo em pouco tempo para acelerar o míssil. O sustainer fornece empuxo menor e mais longo para manter o cruzeiro.

3. O booster aumenta rapidamente a velocidade do míssil até a região de cruzeiro. Fisicamente, ele vence a inércia inicial e leva o míssil até próximo de Mach 0,9.

4. O sustainer mantém a velocidade de cruzeiro. Em primeira aproximação, seu empuxo compensa o arrasto aerodinâmico.

5. Em voo de cruzeiro quase estacionário, a aceleração longitudinal é pequena. Assim, a soma de forças na direção do movimento fica aproximadamente nula, então empuxo e arrasto ficam próximos.

6. As principais hipóteses foram: Mach 0,9, alcance de 70 km, diâmetro de 0,35 m, booster e sustainer sólidos, alvo de baixa altitude e sustainer equilibrando o arrasto em cruzeiro.

7. O alcance definiu o tempo necessário de cruzeiro. Depois de estimar a distância percorrida durante o booster, o restante do alcance foi dividido pela velocidade de cruzeiro para obter o tempo de queima do sustainer.

8. O gráfico mostrou se o míssil atingia e mantinha velocidade próxima de cruzeiro e se a distância final ultrapassava 70 km. O resultado ficou em cerca de 71,09 km.

9. O sustainer precisaria de maior empuxo e maior massa de propelente. Isso aumentaria massa total ou exigiria redistribuição de massa e volume interno.

10. É um dimensionamento preliminar. O arrasto, a estrutura e os volumes internos foram estimados, e ainda não há otimização estrutural ou simulação 6DOF completa acoplada à propulsão.

## Relatório 2: massa-ponto, guiamento e Simulink

11. No Relatório 2, o plano XZ representa o plano horizontal. O eixo X é avanço na direção principal e o eixo Z é deslocamento lateral.

12. Não. A altitude foi mantida como dado separado para atmosfera. O Z do modelo foi usado como coordenada lateral no plano horizontal.

13. O bloco de atmosfera calcula propriedades como densidade do ar e velocidade do som. Esses valores entram no arrasto e no cálculo de Mach.

14. O MachN calcula o número de Mach a partir da velocidade do míssil e da velocidade do som local. Ele ajuda a selecionar ou interpretar coeficientes aerodinâmicos.

15. O bloco Propulsão fornece empuxo e massa ao longo do tempo. Ele representa a queima do booster e do sustainer.

16. O bloco Arrasto calcula a força resistente aerodinâmica. Ele depende de densidade, velocidade, área de referência e coeficiente de arrasto.

17. O bloco Controle gera o comando lateral usado para alterar a trajetória. Nele ficaram as principais mudanças: guiamento pré-programado e lógica de comutação para terminal.

18. O bloco Forces combina as forças atuantes, como empuxo, arrasto, peso e comando de controle, antes de enviar para a dinâmica massa-ponto.

19. O 4th Order Point Mass integra as equações de movimento. Ele atualiza posição, velocidade e ângulo de trajetória do míssil.

20. Porque o alvo começa a 90 graus da direção de lançamento. O autodiretor tem limite de 40 graus, então o míssil precisa curvar antes de usar o guiamento terminal.

21. Autodiretor ligado significa que o sensor está ativo. Modo terminal significa que a informação do sensor já pode ser usada para guiar, o que exige alvo dentro do cone de rastreio.

22. No caso 1, o míssil é lançado na direção do alvo. A comutação para terminal foi feita quando a distância ao alvo chegou a 20 km.

23. No caso 2, o autodiretor começa ligado, mas o terminal só entra quando o alvo entra no cone de 40 graus. Antes disso, a trajetória é pré-programada.

24. É o limite angular de visada do autodiretor. Se o alvo estiver fora desse ângulo em relação ao eixo do míssil, ele não pode ser rastreado adequadamente.

25. O guiamento terminal receberia uma geometria inválida, pois o alvo estaria fora do campo de visão. A tendência seria comando inadequado, perda de rastreio ou trajetória incompatível com o problema.

## Relatório 3: DATCOM, CG, inércia e 6DOF

26. Usamos DATCOM para transformar a geometria equivalente em um banco de coeficientes aerodinâmicos. Esses coeficientes alimentam a simulação 6DOF e o projeto de controle.

27. O for005.dat é o arquivo de entrada do DATCOM. Ele contém geometria, condições de Mach, ângulos e deflexões para as quais os coeficientes serão calculados.

28. O RunDatcom2 processa o arquivo de entrada e gera os coeficientes aerodinâmicos, normalmente em um arquivo como coeficientes.dat.

29. O Coef2Mat converte os coeficientes do DATCOM para uma matriz MATLAB, como M_aed.mat, que pode ser usada pelos scripts de dinâmica e controle.

30. Para a análise longitudinal, os mais importantes foram \(C_N\), \(C_M\), suas derivadas com \(\alpha\), e os efeitos de deflexão de controle. Eles indicam força normal, momento de arfagem e estabilidade.

31. Porque os momentos aerodinâmicos dependem do ponto de referência. Se DATCOM e 6DOF usarem referências diferentes, os momentos e a estabilidade ficam incoerentes.

32. Ele é adimensional e está em calibres em relação à referência de momento. A conversão correta foi \(X_{CP}=2.700-(-0.677)(0.350)=2.937\) m.

33. Porque um CP à frente do CG tenderia a indicar instabilidade longitudinal. O relatório corrigido mostra o CP atrás do CG inicial, coerente com \(C_{M\alpha}<0\).

34. O míssil foi dividido em seções: controle/autodiretor, cabeça de guerra, booster, sustainer e tubeira. A partir de massas e posições estimadas, foram calculados CG e inércias.

35. Ele mostra a resposta aerodinâmica/dinâmica ao comando de superfície. Ajuda a verificar se a deflexão gera ângulo de ataque coerente e se a base 6DOF está conectada corretamente.

## Relatório 4: autopilotos

36. O autopiloto de atitude controla o ângulo de atitude do míssil. Ele usa uma malha interna de velocidade angular \(q\) e uma malha externa de atitude.

37. O autopiloto de aceleração controla a aceleração lateral/normal comandada. Ele é importante para manobras e guiamento terminal.

38. A malha interna de \(q\) aumenta amortecimento e melhora a resposta rotacional. Ela deixa a planta mais controlável para a malha externa.

39. O root-locus ajudou a escolher ganhos observando estabilidade, amortecimento e velocidade dos polos. Ele foi usado para as malhas internas e externas.

40. Sim. A capacidade de aceleração ficou acima de 5g, cerca de 13,52g. A banda de atitude ficou em 1,652 Hz e a de aceleração em 0,537 Hz, ambas acima de 0,5 Hz.

