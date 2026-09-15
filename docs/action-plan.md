# Plano de ação do GD Skill Codex

## Objetivo

Transformar o GD Skill Codex de uma especificação arquitetural bem organizada
em um framework operacional de análise de game design, sem ampliar o catálogo
de 15 skills antes de consolidar:

1. um world model semântico e versionado;
2. interfaces realmente tipadas entre skills;
3. roteamento, execução e iteração separados;
4. validação semântica e consistência entre fontes;
5. evidência, incerteza e reprodutibilidade rastreáveis;
6. uma ponte explícita entre análise, simulação e playtest.

Este documento é um roadmap de implementação. Ele não substitui
[`architecture/orchestrator.md`](../architecture/orchestrator.md), que descreve
o comportamento arquitetural atual.

## Diagnóstico de partida

### Já existe

- 15 skills com front matter e protocolos próprios;
- registry, handoffs, calibração e validações estruturais;
- um world model compartilhado, ainda superficial;
- roteador heurístico determinístico;
- dashboard web estático para catálogo e visualização;
- distinção conceitual entre `formal`, `derived`, `heuristic` e `empirical`.

### Ainda não existe

- uma ontologia verificável por entidade, relação, unidade e versão;
- compatibilidade de schemas entre saída e entrada de handoffs;
- um executor de skills e de ciclos de retorno;
- um evidence store ou formato universal de claims;
- validação de unidades, semântica e dependências;
- execução reproduzível de simulações e geração procedural;
- uma ligação entre orchestrator e dashboard;
- uma fonte derivada única para registry, grafo e dados web.

### Princípios de decisão

1. **Evidência antes de recomendação:** ausência de dados pode produzir
   `INSUFFICIENT_EVIDENCE`, não uma conclusão inventada.
2. **Modelo antes de métrica:** toda métrica deve declarar domínio, unidade,
   assumptions, método e limitações.
3. **Projeções, não ontologia forçada:** uma entidade pode ser projetada como
   ator, recurso, estado ou capacidade conforme a análise.
4. **Hard constraint separado de preferência:** invariantes, restrições,
   heurísticas e hipóteses empíricas não devem compartilhar o mesmo status.
5. **Uma fonte de verdade:** artefatos derivados não devem ser editados
   manualmente.
6. **Aproximações declaradas:** modelos contínuos, probabilísticos ou físicos
   simplificados precisam declarar quando são aproximações.
7. **Sem pontuação global não definida:** o sistema deve preferir um vetor de
   resultados e incertezas a uma nota única de “saúde”.

## Registro de execução

### 2026-09-14 — início da Fase 0

**Status:** em andamento, com baseline e decisões de governança registrados.

**Evidências verificadas**

| Área | Estado observado | Fonte atual | Decisão de trabalho |
| --- | --- | --- | --- |
| Skills | 15 diretórios com `SKILL.md` | `GD-Skill-Codex/` | Não adicionar skills até concluir Fases 1–5 |
| Registry | `role` mistura natureza e roteamento | `architecture/skill-registry.json` | Separar `domain_role` e `routing_role` na Fase 2 |
| Handoffs | 7 contratos com nomes de campos, sem schemas | `architecture/handoffs.json` | Migrar para `input_schema`/`output_schema` na Fase 2 |
| World model | Campos principais são arrays/objetos permissivos | `architecture/world-model.schema.json` | Decompor em sub-schemas na Fase 1 |
| Routing | Ranking heurístico determinístico | `architecture/route_request.ps1` | Manter como fallback até a Fase 3 |
| Validation | Predominantemente estrutural | `architecture/validate_*.ps1` | Criar validação semântica e entrypoint na Fase 4 |
| Web | Catálogo estático baseado em `web/data.js` | `web/` | Não apresentar como engine; derivar dados na Fase 4 |
| Evidência | Status existem, mas não há evidence store | `architecture/` e front matter | Criar modelo universal na Fase 5 |

**Decisões registradas**

- O estado atual será descrito como **especificação arquitetural +
  implementação de referência**, não como engine operacional.
- `web/data.js` é um artefato de apresentação e não uma fonte de verdade.
- `INSUFFICIENT_EVIDENCE` será um resultado válido e explícito.
- Não será criada uma pontuação global de saúde/confiança sem função,
  dados e método definidos.
- O primeiro vertical slice será
  `world model -> sistema de estados -> handoff validado -> claim rastreável`.

**Pendências da Fase 0**

- completar a matriz de rastreabilidade entre claims públicos, status
  epistemológico e evidências;
- rotular números demonstrativos existentes na camada web;
- registrar a política de versionamento em schemas executáveis;
- converter este baseline em validações automáticas na Fase 4.

### 2026-09-14 — primeira fatia das Fases 1–5

**Status:** fundamentos implementados; integração operacional e calibração
continuam em andamento.

**Entregas concluídas**

- criado `architecture/schemas/` com 22 schemas composáveis para world model,
  interfaces, métricas, assumptions, evidências, recomendações e testes;
- `world-model.schema.json` passou a referenciar entidades, atores, recursos,
  ações, regras, objetivos, espaço, tempo, conhecimento, progressão e economia;
- `handoffs.json` recebeu `schema_version`, `input_schema` e `output_schema`;
- criado `validate_schema_interfaces.ps1` para verificar a presença e o
  encadeamento dos contratos;
- criado `evidence.schema.json` e `evidence.example.json`;
- `validate_all.ps1` passou a executar arquitetura, cross-skill, web e
  interfaces;
- `validate_web_data.ps1` detecta skills/downstreams ausentes na apresentação;
- `route_request.ps1` agora diferencia pesos de sinais, aplica bloqueio por
  anti-signal sem evidência positiva, escolhe secundárias por limiar relativo
  e expõe a política de roteamento no resultado;
- corrigidas formalizações de sistema de estados, aleatoriedade, invariantes,
  vetor de risco-recompensa, alcance físico de CSP e equações discretas de
  economia.

**Validação executada**

```text
OK: todas as skills passaram na validação
OK: world model e handoffs passaram na validação
OK: registry e consistência cross-skill verificados
OK: web/data.js sincronizado com skills/downstreams
OK: schemas composáveis/interfaces e contratos compatíveis
```

**Pendências imediatas**

- ligar `validate_all.ps1` aos critérios de aceite documentados;
- substituir objetos permissivos restantes por propriedades semânticas
  versionadas em progressão/economia;
- completar geração automática de `web/data.js`;
- implementar executor de skills, evidence store persistente e simulação;
- continuar a correção matemática das skills restantes e adicionar casos-limite.

### 2026-09-14 — reference runner e estado atual

Foi criado [`architecture/run_analysis.ps1`](../architecture/run_analysis.ps1).
Ele aceita um pedido, executa o roteamento ponderado, registra ordem de
execução, seed, versão do world model e um claim derivado. Como ainda não há
executor de skills nem simulation runner, o relatório retorna
`INSUFFICIENT_EVIDENCE` explicitamente. Essa é a primeira execução reproduzível
do pipeline sem transformar um plano em diagnóstico.

**Estado das fases**

| Fase | Estado | Evidência |
| --- | --- | --- |
| 0 — baseline/governança | concluída com pendências de rotulagem | registro e decisões acima |
| 1 — world model/unidades/versionamento | núcleo implementado; semântica de progressão/economia ainda parcial | `architecture/schemas/`, `world-model.schema.json` |
| 2 — interfaces/handoffs | contratos e schemas implementados; compatibilidade específica por skill ainda pendente | `handoffs.json`, `validate_schema_interfaces.ps1` |
| 3 — orchestrator | reference runner implementado; executor real ainda pendente | `run_analysis.ps1`, `route_request.ps1` |
| 4 — validação/artefatos | validação agregada implementada; geração automática web ainda pendente | `validate_all.ps1`, `validate_web_data.ps1` |
| 5 — evidência/reprodutibilidade | schema, exemplo e store JSONL append-only implementados; propagação de confiança pendente | `evidence.schema.json`, `evidence.example.json`, `run_analysis.ps1` |
| 6 — modelos matemáticos | correções prioritárias parciais | skills de estado, risco, CSP e economia |
| 7 — simulação/web operacional | acessibilidade textual e rótulo de catálogo adicionados; simulation bridge pendente | `web/index.html`, `web/app.js` |

**Verificações finais desta execução**

- `architecture/validate_all.ps1`: passou;
- `validate_skills.ps1`: passou;
- `node --check web/app.js`: passou;
- `run_analysis.ps1` com `-Seed 42`: produziu plano determinístico e
  `INSUFFICIENT_EVIDENCE`;
- persistência JSONL de claims: testada com hash, versão e seed;
- nenhum executor de skill ou simulation runner foi fingido como concluído.

### 2026-09-14 — geração derivada e confiança mínima

**Entregas desta etapa**

- criado `architecture/generate_web_data.ps1`;
- `web/data.js` agora é gerado a partir de `skill-registry.json`,
  `handoffs.json` e `SKILL.md`, com downstreams derivados dos handoffs;
- `validate_all.ps1` executa a geração antes das validações, reduzindo drift
  entre arquitetura e dashboard;
- o runner calcula e registra confiança mínima propagada:
  `low` sem world model, `medium` com contexto parcial e `high` apenas com
  múltiplas evidências e sinal forte;
- README e orchestrator passaram a declarar o gerador e a natureza derivada
  do artefato web.

**Verificação**

- geração concluída para 15 skills;
- `node --check web/app.js` passou;
- downstreams gerados passaram em `validate_web_data.ps1`;
- a confiança do runner foi testada com e sem world model;
- a limitação permanece explícita: confiança é uma política inicial, não
  validação empírica.
- após a primeira execução do gerador, o validador web foi ajustado para
  aceitar a sintaxe JavaScript/JSON produzida; a regressão foi reproduzida e
  corrigida antes da validação final.

### 2026-09-14 — ponte de execução de skills

Foi criado [`architecture/execute_skills.ps1`](../architecture/execute_skills.ps1).
Esta primeira implementação:

- exige e valida os campos obrigatórios do world model;
- executa o roteamento existente;
- materializa uma saída por skill na ordem de execução;
- registra `skill_id`, versão, hash de entrada, seed e versão do world model;
- retorna `status: blocked` e `INSUFFICIENT_EVIDENCE` quando não existe
  executor operacional para a skill;
- pode persistir um claim por skill no evidence store JSONL.

Isso fecha a interface de execução sem mascarar a ausência de implementações
das skills. A pendência foi reduzida de “não há ponte de execução” para
“adicionar executors versionados para as skills e um simulation runner”.

### 2026-09-14 — primeiro executor e simulation runner

**Entregas**

- criado `architecture/schemas/state-system.schema.json`;
- criado `architecture/executors/discrete-state-machine-verification.ps1`;
- o executor aplica BFS no sistema declarado, reportando estados alcançáveis,
  terminais alcançáveis, órfãos, deadlocks, não-determinismo e métricas
  derivadas;
- `execute_skills.ps1` passou a despachar para executors versionados quando
  eles existem, mantendo `blocked` para skills sem implementação;
- criado `architecture/simulate_state_system.ps1`, com seed, limite de passos,
  seleção determinística/ponderada e trace reproduzível;
- criado o exemplo
  `architecture/examples/state-system.example.json`.

**Verificação**

- sistema de exemplo produziu `partial`, alcançou `start, victory` e detectou
  `orphan`;
- simulation runner alcançou o terminal `victory` em trace limitado;
- execução sem executor continua explicitamente bloqueada;
- a limitação permanece: este executor prova propriedades do grafo declarado,
  não a implementação runtime nem a experiência do jogador.

### 2026-09-14 — cobertura formal ampliada

**Entregas**

- criado `csp-system.schema.json` e integrado ao validador de interfaces;
- criado `executors/procedural-level-constraint-solving.ps1`, com validação
  de referências, propagação AC-3 e detecção de domínios vazios;
- criado `examples/csp-system.example.json`;
- criado `executors/resource-flow-economy.ps1` por executor especializado,
  com schema e fixture próprios;
- o executor de recursos calcula a equação discreta
  `Q(t+1) = Q(t) + sources - sinks`, classifica recursos como
  `inflationary`, `deficit` ou `balanced` e registra evidência derivada;
- `execute_skills.ps1` agora pode despachar três skills formais:
  estados, CSP e fluxo de recursos.

**Verificação**

- fixture CSP: `success`, `locally_consistent`, sem domínios vazios;
- fixture de recursos: `success`, estado `mixed`, com inflação e déficit
  detectados separadamente;
- ambos foram executados pelo pipeline, não apenas chamados diretamente;
- AC-3 continua explicitamente limitado a consistência local;
- o balanço econômico continua condicional ao modelo discreto fornecido.

### 2026-09-14 — executor de processos concorrentes

**Entregas**

- criado `petri-net.schema.json` e registrado no `hidden-state.schema.json`;
- criado `executors/concurrent-gameplay-processes.ps1`;
- criado `examples/petri-net.example.json`;
- o executor valida places, tokens e arcos, executa uma trajetória limitada,
  registra marcações, transições disparadas, progresso observado e deadlock;
- `execute_skills.ps1` passou a despachar quatro executors formais:
  estados, CSP, fluxo de recursos e processos concorrentes.

**Verificação**

- fixture Petri Net disparou `craft` de forma determinística;
- a marcação final foi `raw_material=0, product=1`;
- o deadlock foi reportado explicitamente após o consumo do único token;
- execução pelo pipeline roteou para `concurrent-gameplay-processes`;
- a limitação está registrada: uma trajetória limitada não prova vivacidade
  global nem ausência de deadlocks em todos os estados.

### 2026-09-14 — executor de timing baseado em frames

**Entregas**

- criado `frame-timing.schema.json` e integrado ao `hidden-state` e à
  validação de interfaces;
- criado `executors/frame-based-combat-timing.ps1`;
- criado `examples/frame-timing.example.json`;
- o executor calcula duração total, segundos por tick, hit advantage e block
  advantage para ações com startup/active/recovery declarados;
- candidatos a loop exigem simultaneamente vantagem suficiente, repetibilidade,
  contato, recurso e ausência declarada de escape;
- limitações de geometria, spacing, input buffer e estados de escape são
  incluídas no resultado, em vez de serem inferidas.

**Verificação**

- fixture produziu `success`, 33 frames totais, `+3` hit advantage e `-7`
  block advantage;
- nenhum loop foi classificado como garantido;
- execução pelo pipeline roteou para `frame-based-combat-timing`;
- validação permanece condicional aos parâmetros declarados.

### 2026-09-14 — executor ERA e cobertura de validator

**Entregas**

- criado `procedural-expressive-range-analysis.schema.json` e integrado ao
  `hidden_state` e ao validador de interfaces;
- criado `executors/procedural-expressive-range-analysis.ps1`;
- criado `examples/procedural-expressive-range-analysis.example.json`;
- o executor exige `solvability_status` e amostras não vazias;
- calcula contagem de amostras, amostras classificadas, bins ocupados,
  `bin_occupancy_coverage` e `distribution_bias`;
- separa explicitamente ocupação de bins de cobertura geométrica/área;
- `execute_skills.ps1` agora pode despachar o validator ERA quando roteado.

**Verificação**

- fixture produziu `success` com 4 amostras;
- 3 de 9 bins foram ocupados (`0.3333`);
- o bin de maior concentração representou `0.5` das amostras classificadas;
- execução pelo pipeline roteou para ERA;
- não foi inferida qualidade, diversidade geométrica ou solvabilidade global.

## Sequenciamento por fases

As fases são ordenadas por dependência. Uma fase pode começar em paralelo
quando seus pré-requisitos estiverem concluídos, mas não deve declarar
estabilidade antes dos critérios de aceite da fase anterior.

### Fase 0 — Baseline e governança

**Objetivo:** congelar o contrato de evolução e tornar o estado atual
observável antes das mudanças.

**Entregas**

- inventário das fontes de verdade e dos campos duplicados;
- matriz de rastreabilidade entre audit item, arquivo, decisão e teste;
- política de versionamento para schemas, skills e análises;
- definição dos status epistemológicos canônicos:
  `formal`, `derived`, `heuristic`, `empirical`, `observed`, `assumed`,
  `unknown`, `contradicted`, `validated`;
- registro explícito de `INSUFFICIENT_EVIDENCE`;
- decisão documentada de que o dashboard atual é catálogo estático.

**Critérios de aceite**

- cada claim público relevante possui uma classificação epistemológica;
- nenhum número demonstrativo do dashboard é apresentado como execução real;
- o README descreve o projeto como especificação + implementação de referência.

**Prioridade:** P0.

### Fase 1 — World model, unidades e versionamento

**Objetivo:** substituir o schema permissivo por uma ontologia composta,
sem impor uma única classificação para todas as entidades.

**Entregas**

- decomposição de `world-model.schema.json` em sub-schemas para entidades,
  atores, recursos, ações, regras, objetivos, espaço, tempo, conhecimento e
  estado oculto;
- identificadores estáveis, `type`, `source`, `version`, `timestamp`,
  ownership, relações e estado epistemológico;
- vocabulário de unidades e conversões explícitas entre segundos, frames,
  ticks, ciclos, distância, velocidade, dano e taxas;
- separação entre entidade, recurso, variável de estado, moeda, capacidade,
  conhecimento e população;
- `world_model_version`, `analysis_version`, `skill_version` e `input_hash`;
- validação de referências internas e relações entre objetos.

**Critérios de aceite**

- exemplos válidos e inválidos cobrem cada sub-schema;
- referências para entidades inexistentes falham;
- unidades incompatíveis falham antes de qualquer cálculo;
- duas projeções diferentes podem apontar para a mesma entidade sem duplicá-la.

**Prioridade:** P0. **Dependência:** Fase 0.

### Fase 2 — Contratos de interface e handoffs

**Objetivo:** transformar nomes de campos em contratos verificáveis.

**Entregas**

- schemas para `SkillInput`, `SkillOutput`, `HandoffContract`, `Metric`,
  `Assumption`, `Evidence`, `Recommendation` e `TestPlan`;
- `input_schema`, `output_schema`, `version`, campos obrigatórios, unidades e
  compatibilidade no `handoffs.json`;
- distinção entre `model`, `assumptions`, `analysis`, `results`, `evidence`,
  `uncertainty`, `recommendation` e `test`;
- contrato de iteração com payload de retorno, merge strategy, estado
  preservado, condição de parada e métrica computável;
- taxonomia separada para `domain_role` (`formal`, `design`, `hybrid`) e
  `routing_role` (`primary_candidate`, `secondary`, `validator`);
- validação de que cada input de destino existe no output compatível da origem.

**Critérios de aceite**

- um handoff incompatível falha com erro localizado;
- `return_to` só aceita skills e etapas existentes;
- `max_cycles` é inteiro positivo;
- toda `convergence_metric` possui definição, limiar e método de avaliação;
- registry, handoffs e front matter podem ser comparados automaticamente.

**Prioridade:** P0. **Dependência:** Fase 1.

### Fase 3 — Orchestrator executável

**Objetivo:** separar roteamento, execução, validação e iteração.

**Entregas**

- pipeline: request, decomposição, extração do world model,
  assumptions/unknowns, projeção ontológica, routing, seleção mínima,
  execução, validação e relatório;
- `route_request.ps1` explicitamente mantido como fallback heurístico;
- pesos distintos para sinais explícitos, semânticos e estruturais;
- bloqueios reais para anti-signals e conflitos;
- seleção de secondary skills baseada em dependências, não em `First 3`;
- seleção de validators pelo contrato e pelo tipo de risco;
- grafo de dependências e ordem de execução;
- `evidence sufficiency` antes de qualquer recomendação;
- logs de execução, falhas explícitas e resultados parciais identificados.

**Critérios de aceite**

- a mesma entrada produz o mesmo plano de execução quando a seed é fixa;
- um anti-signal bloqueia ou exige revisão conforme a política declarada;
- nenhuma skill é executada sem inputs compatíveis;
- ciclos encerram por convergência, limite ou erro reportado;
- `UNKNOWN` e `INSUFFICIENT_EVIDENCE` são resultados válidos.

**Prioridade:** P0. **Dependência:** Fases 1 e 2.

### Fase 4 — Validação semântica e geração de artefatos

**Objetivo:** substituir validações de presença por validações de coerência.

**Entregas**

- `validate_schema.ps1`;
- `validate_registry.ps1`;
- `validate_handoffs.ps1`;
- `validate_interfaces.ps1`;
- `validate_units.ps1`;
- `validate_routing.ps1`;
- `validate_examples.ps1`;
- `validate_web_data.ps1`;
- `validate_all.ps1` como entrypoint;
- gerador de `web/data.js`, tabelas documentais e grafo a partir do registry e
  dos handoffs;
- checagem de cobertura do grafo, ciclos legítimos, referências e drift.

**Critérios de aceite**

- `validate_all.ps1` cobre todos os validadores e retorna erros acionáveis;
- o grafo web é derivado de `handoffs.json`;
- alterações no registry são detectadas nos artefatos gerados;
- nenhum dado demonstrativo contém timestamp ou confiança que pareça execução
  real sem o rótulo `DEMO`, `EXAMPLE` ou `SIMULATED`.

**Prioridade:** P1. **Dependência:** Fases 1–3.

### Fase 5 — Evidence engine e reprodutibilidade

**Objetivo:** fazer a camada epistemológica ser imposta pela arquitetura.

**Entregas**

- evidence store com `claim`, `status`, `source`, `calculation`,
  `assumptions`, `confidence`, `validation` e limitações;
- vínculo entre claim, input hash, versão do world model, skill e execução;
- registro de seed, parâmetros, amostra, timestamp e ambiente;
- propagação de confiança e orçamento de incerteza;
- distinção entre modelo, dado observado, resultado derivado e recomendação;
- relatório de conflitos e dependência de hipóteses;
- vetor de estado do sistema no lugar de `health score` não definido.

**Critérios de aceite**

- toda recomendação aponta para pelo menos um claim;
- todo claim derivado aponta para dados e cálculo reproduzíveis;
- resultados sem evidência suficiente são marcados sem fallback silencioso;
- uma execução PCG/simulação pode ser repetida com a mesma seed e parâmetros.

**Prioridade:** P0. **Dependência:** Fases 1–3.

### 2026-09-14 — executors de progressão e macroeconomia

**Status:** cobertura formal ampliada; os dois modelos executáveis foram
integrados ao `hidden_state` e ao pipeline de execução.

**Entregas concluídas**

- criado `progression-analysis.schema.json` com parâmetros versionados para
  crescimento discreto, classificação de regime, prestígio e limites de
  overflow;
- criado o executor `exponential-progression-and-prestige.ps1`, que valida
  parâmetros, calcula crescimento finito e pontos/multiplicadores de prestígio
  e bloqueia entradas ausentes ou blow-up não representável;
- criado `macroeconomic-conversion.schema.json` para recursos, produtos,
  conversões, eficiência e fluxo monetário;
- criado o executor `macroeconomic-resource-conversion.ps1`, com matriz
  input-output discreta, consumo ajustado por eficiência, balanço de fontes e
  sinks monetários e projeção de preço explicitamente aproximada;
- adicionadas fixtures reproduzíveis em `architecture/examples/`;
- ambos os schemas foram registrados em `hidden-state.schema.json` e em
  `validate_schema_interfaces.ps1`.

**Limites preservados**

- crescimento calculado não é previsão de retenção ou de comportamento;
- balanço monetário não prova inflação/deflação sem séries temporais, demanda,
  velocidade e observação;
- a projeção de preço é uma aproximação bounded, não uma previsão de mercado;
- resultados continuam condicionais aos coeficientes, eficiência e hipóteses
  declarados no world model.

**Validação executada**

```text
progression-analysis.example.json: executor concluído
macroeconomic-conversion.example.json: executor concluído
macro pelo execute_skills.ps1: primary roteada e executor despachado
casos ausentes/blow-up de progressão: bloqueio/guard validados pelo executor
```

### 2026-09-14 — executor seletivo de risco-recompensa

**Status:** uma lente de design com entradas observáveis foi integrada ao
pipeline, sem promover heurísticas estruturais a evidência de playtest.

**Entregas concluídas**

- criado `risk-reward-action.schema.json` para contratos de ação, custo de
  stamina, recuperação, dano, reação, áreas hitbox/hurtbox e custo de evasão;
- criado `committed-risk-reward-actions.ps1`, com verificações de:
  `RISKLESS_DOMINANCE`, `STAMINA_LOCK_TRAP` e
  `REACH_EXPOSURE_INCOHERENCE`;
- adicionada fixture reproduzível em
  `architecture/examples/risk-reward-actions.example.json`;
- integrado `hidden_state.risk_reward_actions` ao schema compartilhado;
- registrado o novo schema na validação de interfaces;
- incluídos handoffs explícitos para timing e composição de ações.

**Limites preservados**

- os alertas são derivados de parâmetros declarados, não observações de
  jogadores;
- áreas geométricas são proxies e não substituem hitboxes, espaçamento ou
  simulação de escapes;
- nenhum flag afirma sozinho dominância, injustiça ou frustração.

**Validação executada**

```text
risk-reward-actions.example.json: executor success, 2 flags estruturais
execute_skills.ps1: roteamento para committed-risk-reward-actions e dispatch concluídos
validate_schema_interfaces.ps1: 31 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — executor seletivo de progressão epistêmica

**Status:** segunda lente de design com dados observáveis integrada ao
pipeline, mantendo a distinção entre topologia de conhecimento e evidência
empírica de compreensão.

**Entregas concluídas**

- criado `epistemic-progression.schema.json` para holons, pistas, terminais,
  acessibilidade física declarada e conjunto de conhecimento conhecido;
- criado `epistemic-holarchic-progression.ps1`, com verificações de:
  `INFORMATIONAL_ISLAND`, `PSEUDO_HOLON` e `FALSE_HOLARCHY`;
- calculada a cobertura de predecessores obrigatórios de cada holon terminal;
- adicionada fixture reproduzível em
  `architecture/examples/epistemic-progression.example.json`;
- integrado `hidden_state.epistemic_progression` ao schema compartilhado e à
  validação de interfaces;
- incluídos handoffs explícitos para cognição e pacing espacial.

**Limites preservados**

- cobertura do grafo não é probabilidade de inferência ou acessibilidade
  cognitiva;
- acessibilidade física declarada ainda exige validação de trajetória,
  hazards e regras de interação;
- o executor não infere diversão, clareza ou frustração.

**Validação executada**

```text
epistemic-progression.example.json: executor success, capacidade terminal 0,5
execute_skills.ps1: roteamento para epistemic-holarchic-progression e dispatch concluídos
validate_schema_interfaces.ps1: 32 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — executor seletivo de disrupção de schema cognitivo

**Status:** terceira lente de design observável integrada, com hipóteses
estruturais separadas de efeitos cognitivos que exigem playtest.

**Entregas concluídas**

- criado `cognitive-schema-disruption.schema.json` para convenções,
  repetições, saliência, rupturas, limiares e coerência oculta;
- criado `cognitive-schema-disruption.ps1`, com verificações de:
  `PREMATURE_DISRUPTION`, `ARBITRARY_DISSONANCE`,
  `PUNITIVE_DISRUPTION` e `NON_STRATEGIC_BREAK`;
- adicionada fixture reproduzível em
  `architecture/examples/cognitive-schema-disruption.example.json`;
- integrado `hidden_state.cognitive_schema_disruption` ao schema compartilhado
  e à validação de interfaces;
- incluídos handoffs explícitos para progressão epistêmica e análise de range.

**Limites preservados**

- magnitude e limiar são proxies declarados em espaço de features;
- coerência oculta não prova descoberta ou aceitação pelo jogador;
- surpresa, confusão e acomodação exigem observação ou playtest.

**Validação executada**

```text
cognitive-schema-disruption.example.json: executor success, 0 flags
execute_skills.ps1: roteamento e dispatch concluídos
validate_schema_interfaces.ps1: 33 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — executor seletivo de feedback competitivo

**Status:** quarta lente de design observável integrada, com separação entre
propriedades matemáticas do feedback e hipóteses de justiça/comportamento.

**Entregas concluídas**

- criado `competitive-feedback.schema.json` para posições, scores, arrasto do
  líder, efeito de compensação, histórico e valor esperado por ranking;
- criado `competitive-negative-feedback.ps1`, com verificações de:
  `EXTREME_RUBBER_BANDING`, `DESTRUCTIVE_ELASTIC_OSCILLATION` e
  `SANDBAGGING_INCENTIVE`;
- adicionada fixture reproduzível em
  `architecture/examples/competitive-feedback.example.json`;
- integrado `hidden_state.competitive_feedback` ao schema compartilhado e à
  validação de interfaces;
- incluídos handoffs explícitos para economia de recursos e progressão.

**Limites preservados**

- estabilidade matemática não prova justiça percebida ou diversão;
- sandbagging requer agentes estratégicos, simulação ou telemetria;
- uma amostra pontual de posições não demonstra dinâmica temporal.

**Validação executada**

```text
competitive-feedback.example.json: executor success, 2 hipóteses estruturais
execute_skills.ps1: roteamento e dispatch concluídos
validate_schema_interfaces.ps1: 34 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — executor seletivo de topologia espacial e pacing

**Status:** quinta lente de design observável integrada ao pipeline.

**Entregas concluídas**

- criado `spatial-pacing.schema.json` para nós, arestas, mecânicas, fases,
  tensão, risco de morte e salas de descompressão;
- criado `spatial-topology-and-learning-pacing.ps1`, com verificações de:
  `COGNITIVE_LOAD_SPIKE`, `TENSION_PLATEAU`,
  `TOPOLOGICAL_PREREQUISITE_BREAK` e `UNREACHABLE_SPACE`;
- adicionada fixture reproduzível em
  `architecture/examples/spatial-pacing.example.json`;
- integrado `hidden_state.spatial_pacing` ao schema compartilhado e à
  validação de interfaces;
- incluídos handoffs explícitos para solvabilidade procedural e progressão
  epistêmica.

**Limites preservados**

- alcançabilidade do grafo não prova solvabilidade física ou acessibilidade;
- tensão e fases são proxies declarados;
- qualidade pedagógica exige traces de rota, teste com novatos e revisão de
  acessibilidade.

**Validação executada**

```text
spatial-pacing.example.json: executor success, reachable ratio 1
execute_skills.ps1: roteamento e dispatch concluídos
validate_schema_interfaces.ps1: 35 schemas compatíveis
validate_all.ps1: validação agregada concluída
```

### 2026-09-14 — execução do bloco de pendências 1–7

**Status:** cobertura de executors e infraestrutura transversal ampliadas;
contratos e resultados continuam distinguindo cálculo derivado de evidência
empírica.

**Entregas concluídas**

- implementados executors de `emergent-agency-composition` e
  `nested-gameplay-loop-architecture`, com schemas, fixtures, métricas,
  diagnósticos e handoffs;
- criada `validate_handoff_compatibility.ps1`, verificando origem, destino,
  campos declarados, versão e adapters necessários;
- criado `regression_tests.ps1`, que executa as fixtures de todos os
  executors e rejeita status inválidos;
- criado `simulation_runner.ps1`, com repetição, seed, hash do world model,
  status por execução e classificação `derived_from_simulation` ou
  `INSUFFICIENT_EVIDENCE`;
- criado `playtest-hypothesis.schema.json` e fixture para separar hipótese,
  população, métrica, protocolo, amostra e critério de sucesso;
- corrigido `execute_skills.ps1` para registrar claims derivados quando há
  output real, manter confiança baixa/média e usar `partial` corretamente;
- dashboard passou a aceitar relatório JSON local e exibir status, skills,
  seed e hash, mantendo `not executed` por padrão;
- `validate_all.ps1` passou a incluir compatibilidade de handoffs.

**Pendências ainda abertas**

- validação JSON Schema com engine completa;
- propagação de confiança por dependências e conflitos em múltiplos claims;
- adapters executáveis entre handoffs, além da detecção de necessidade;
- simulation runner com agentes estratégicos e séries temporais específicas;
- integração automática do evidence store e carregamento de execuções pelo
  dashboard;
- separação definitiva entre `domain_role` e `routing_role`;
- ontologia completa do world model e calibragem empírica.

**Validação executada**

```text
2 novos executors: fixtures e dispatch validados
16 fixtures executadas sem status inválido
validate_handoff_compatibility.ps1: concluído com warnings de adapters explícitos
validate_all.ps1: validação agregada concluída
node --check web/app.js: concluído
```

### 2026-09-14 — fechamento explícito das pendências 1–7

**Status:** os sete primeiros itens do backlog foram executados em sua forma
de referência; adapters e calibração empírica continuam como limitações
declaradas.

**Entregas adicionais**

- criada a migração persistente de `skill-registry.json` para
  `domain_role`/`routing_role`, com roteador e validação atualizados;
- criados `iterate_handoffs.ps1` e critérios de convergência/limite de ciclos;
- criado `provenance.schema.json` com source kind, dependências, conflitos,
  hashes e versões;
- fortalecidos schemas de `knowledge`, `progression`, `economy` e `spatial`
  com IDs, relações, unidades, estoque, gates e status epistemológico;
- evidence store do dispatcher passou a registrar claims derivados quando há
  output real, mantendo `INSUFFICIENT_EVIDENCE` apenas para bloqueios;
- compatibilidade de handoffs agora diferencia contratos válidos de campos que
  ainda exigem adapters explícitos.

**Validação final do bloco**

```text
39 schemas composáveis/interfaces compatíveis
7 handoffs verificados; 5 adapters explicitamente advertidos
16 fixtures executadas sem status inválido
iteration contract: 2 ciclos, convergência detectada
registry: 15 skills com domain_role/routing_role
validate_all.ps1: concluído
```

### 2026-09-14 — adapters executáveis de handoff

**Status:** os cinco avisos de compatibilidade de campos foram convertidos em
contratos declarativos e um executor de adapter, preservando dados externos
como requisito explícito.

**Entregas concluídas**

- criado `handoff-adapters.json` com mapeamentos, campos derivados e
  `external_required`;
- criado `execute_handoff_adapter.ps1`, que materializa campos mapeados,
  registra expressões derivadas pendentes e não fabrica dados ausentes;
- `validate_handoff_compatibility.ps1` agora exige adapter para campos não
  compatíveis e valida que cada campo possui mapeamento, derivação ou requisito
  externo;
- fixture Petri Net foi adaptada para fluxo de recursos e produziu campos
  `places` e `transition_rates`, com warning explícito para `resource_list`
  ausente na saída.

**Validação**

```text
7 handoffs verificados com adapters declarados
adapter concurrent-gameplay-processes -> resource-flow-economy executado
Node disponível; a engine AJV foi instalada e integrada à validação agregada
```

### 2026-09-14 — instalação e integração do AJV

**Status:** validação JSON Schema completa integrada à validação agregada.

**Entregas concluídas**

- instalado `ajv` 8.20.0 e `ajv-formats` 3.0.1 como dependências de
  desenvolvimento;
- criado `architecture/validate_json_schema.js`, com carregamento dos schemas
  composáveis, resolução de `$ref`, suporte a formatos e tolerância a BOM;
- `validate_all.ps1` passou a executar a validação AJV;
- `package.json` recebeu `test` e `validate:schema`;
- 15 world models e 16 fixtures foram validados pelo AJV.

**Validação**

```text
npm run validate:schema: passou
validate_all.ps1: passou
AJV: 15 world models válidos; 16 fixtures inspecionadas
```

### 2026-09-14 — adapters integrados ao dispatcher

**Status:** o fluxo de execução agora materializa automaticamente adapters
declarados entre skills consecutivas.

**Entregas concluídas**

- `execute_skills.ps1` passou a identificar pares consecutivos com contrato em
  `handoff-adapters.json`;
- cada adapter é executado via `execute_handoff_adapter.ps1` e seu resultado
  é incluído no campo `handoff_adapters` do relatório;
- campos derivados, warnings e requisitos externos permanecem rastreáveis;
- falhas de adapter interrompem a execução explicitamente, sem fallback
  silencioso.

**Validação**

```text
request Petri Net + resource flow: 1 adapter automático executado
execution_status: blocked por skill downstream sem executor, não por adapter
adapter warnings: 1 campo externo ausente, preservado explicitamente
validate_all.ps1: passou
```

### Fase 6 — Correção dos modelos e calibração

**Objetivo:** corrigir formalizações que podem contaminar diagnósticos.

**Ordem recomendada**

1. sistema de transição discreto, distinguindo conjunto finito, sistema
   discreto, não-determinismo e distribuição probabilística;
2. invariantes como `Valid = {q | Phi(q)}` e alcançabilidade como subconjunto;
3. timing com condições de contato, repetição, recursos, escape e geometria;
4. ações risco-recompensa com estado, dano, posição e velocidade separados;
5. feedback competitivo em diferença de performance, não apenas ranking;
6. economia com equações discretas quando o sistema for event-driven,
   preços bounded e hipóteses explícitas para fontes, sinks e demanda;
7. progressão como positive-feedback growth, incluindo casos exponencial,
   sublinear e blow-up;
8. bandas temporais canônicas configuráveis para loops;
9. progressão epistêmica com modos `pure_epistemic`, `hybrid` e `physical`;
10. divergência cognitiva como `design-space divergence` até existir
    observação empírica;
11. ERA com tamanho de amostra adaptativo e métricas distintas de occupancy,
    density e valid-space coverage;
12. CSP com `Reachability(agent_model)` e separação entre generator,
    verifier e quality evaluator.

**Critérios de aceite**

- cada fórmula declara domínio, unidade, hipótese e status epistemológico;
- exemplos não concluem mais do que os dados permitem;
- defaults arbitrários são marcados como heurísticos calibráveis;
- testes de regressão cobrem casos-limite: zero, negativo, infinito,
  domínio vazio, ciclos e dados insuficientes.

**Prioridade:** P1. **Dependência:** Fases 1, 2 e 5.

### Fase 7 — Ponte de simulação, playtest e web

**Objetivo:** conectar análise executável, evidência e apresentação.

**Entregas**

- interface de simulation runner;
- interface de playtest hypothesis e coleta de observações;
- armazenamento de execuções e séries temporais;
- dashboard alimentado por resultados reais quando disponíveis;
- estado “not executed” explícito;
- representação textual acessível para o grafo;
- visualização de claims, evidências, incertezas e conflitos;
- fluxo futuro `request -> router -> execution -> result -> dashboard`.

**Critérios de aceite**

- a UI diferencia catálogo, análise executada e demonstração;
- o grafo e os números exibidos derivam de artefatos versionados;
- usuários de tecnologias assistivas conseguem consultar as relações sem
  depender apenas do SVG;
- uma execução pode ser aberta a partir do dashboard com sua proveniência.

**Prioridade:** P2. **Dependência:** Fases 4 e 5.

### 2026-09-14 — fechamento operacional do bloco 1–7

**Status:** concluído e validado.

- a ontologia recebeu validação semântica cross-skill para IDs, referências,
  unidades, dependências, ciclos e deadlocks;
- `role` foi removido do registry; `domain_role` e `routing_role` são as
  dimensões oficiais;
- adapters passaram a declarar versão, schemas de origem/destino e unidades;
- `iterate_handoffs.ps1` registra `return_to`, conflitos e convergência;
- claims e evidence records agora carregam `skill_id`, confiança propagada,
  proveniência, dependências e conflitos;
- o evidence store JSONL gera um índice consultável `.index.json`;
- o simulation runner registra snapshots, eventos, séries temporais e agentes
  declarados, sem transformar repetição de executor em evidência empírica;
- regressões cobrem ausência, IDs duplicados, referências inválidas, zero,
  negativos, overflow, ciclos, deadlocks, partial e adapters incompletos;
- o dashboard exibe claims, confiança, estatuto epistemológico e adapters ao
  carregar um relatório.

**Validação executada:** `npm test`, `npm run validate:schema`,
`architecture/regression_tests.ps1` e `architecture/validate_all.ps1`.

**Limitações preservadas:** séries temporais ainda são snapshots de executor,
agentes usam apenas estratégias declaradas no world model e a confiança não é
calibrada empiricamente. Nenhuma recomendação é liberada quando o claim está
em `INSUFFICIENT_EVIDENCE`.

### 2026-09-14 — quatro tarefas operacionais selecionadas

Foram executadas quatro tarefas do backlog:

1. **Compatibilidade dimensional de adapters:** criado
   `validate_adapter_dimensions.ps1`, com verificação de versão, schemas,
   unidades e campos dimensionais.
2. **Evidence store consultável:** criado `query_evidence_store.ps1`, com
   filtros por `skill_id`, `status` e `confidence`.
3. **Recomendações rastreáveis:** criado `generate_recommendations.ps1` e
   integrado o campo `recommendations` ao relatório; claims insuficientes ou
   de baixa confiança produzem recomendações `blocked`.
4. **Simulação agregada:** `simulation_runner.ps1` passou a registrar contagem
   de sucessos/parciais/falhas e nomes de métricas, mantendo snapshots,
   eventos, seeds e a distinção entre derivação e evidência empírica.

Validação adicional: quatro adapters dimensionais válidos, evidence query
retornando registros filtrados, recomendação bloqueada para claim insuficiente,
AJV, regressões e `validate_all.ps1` aprovados.

### 2026-09-14 — integração de evidência de simulação e dashboard

- `simulation_runner.ps1` aceita `EvidenceStorePath` e persiste um claim de
  simulação com seed, hash, status epistemológico, limitações e proveniência;
- `validate_recommendations.ps1` verifica que cada recomendação aponta para um
  claim existente, possui evidência e permanece bloqueada quando necessário;
- o dashboard permite filtrar claims carregados por bloqueio, baixa confiança
  ou estado condicional;
- o fluxo continua distinguindo `derived_from_simulation` de evidência
  observacional e não promove runs parciais a conclusões.

### 2026-09-14 — validação de relatório e índice incremental

- criado `validate_report.ps1`, que verifica claims, hashes de proveniência e
  recomendações rastreáveis em um relatório completo;
- criado `refresh_evidence_index.ps1`; o índice agora é regenerado após cada
  execução do dispatcher ou persistência de simulação;
- a suíte de regressão ganhou casos de relatório válido e inválido, incluindo
  recomendação órfã, recomendação não bloqueada e hash divergente;
- validações finais: AJV, `validate_all.ps1`, `regression_tests.ps1` e fluxo
  ponta a ponta com dois registros no evidence store.

### 2026-09-14 — contrato de simulação e apresentação operacional

- criado `simulation-report.schema.json`, cobrindo runs, snapshots, eventos,
  agentes, estado epistemológico e agregados;
- criado `validate_simulation_report.js` e integrado o schema à inspeção AJV;
- o dashboard agora identifica relatórios de simulação e exibe runs,
  sucessos, parciais e falhas, mantendo explícito que simulação derivada não
  equivale a telemetria ou playtest;
- um relatório gerado com duas execuções foi validado pelo contrato dedicado,
  além de `npm test`, `validate_all.ps1` e `regression_tests.ps1`.

### 2026-09-14 — validação automática de simulação e playtest

- `validate_all.ps1` passou a gerar uma execução de referência e validar seu
  relatório com `validate_simulation_report.js`;
- criado `validate_playtest_hypothesis.js`/`.ps1`, que valida a fixture de
  hipótese, exige amostra/protocolo/critério e rejeita observações declaradas
  como se fossem hipótese;
- `regression_tests.ps1` recebeu caso inválido de playtest;
- validações executadas com sucesso: AJV, `validate_all.ps1`,
  `regression_tests.ps1` e a fixture oficial de playtest.

### 2026-09-14 — registro de observações de playtest

- criado `playtest-observation.schema.json` com contrato para métrica, amostra,
  timestamp, status e limitações;
- criado `validate_playtest_observation.js` e
  `record_playtest_observation.ps1`, que vinculam a observação à hipótese,
  conferem métrica/amostra e persistem um claim empírico no evidence store;
- `validate_all.ps1` executa a fixture de observação e verifica a atualização
  do índice; regressões cobrem observação estrutural inválida.

### 2026-09-14 — validação AJV do evidence store

- criado `validate_evidence_store.js`, que valida cada registro JSONL contra
  `evidence.schema.json` e identifica JSON inválido, status ou confiança fora
  do contrato e proveniência incompleta;
- `validate_all.ps1` valida stores gerados por playtest e simulação antes de
  removê-los como artefatos temporários;
- regressões cobrem um registro de evidência inválido.

## Backlog rastreável

| ID | Tema | Fase | Prioridade | Resultado esperado |
| --- | --- | --- | --- | --- |
| B-01 | Ontologia e sub-schemas | 1 | P0 | World model semântico e validável |
| B-02 | Unidades e domínios | 1 | P0 | Compatibilidade dimensional verificável |
| B-03 | Versionamento e hashes | 1 | P0 | Análises antigas reproduzíveis |
| B-04 | Contratos de input/output | 2 | P0 | Handoffs tipados por schema |
| B-05 | Taxonomia de papéis | 2 | P0 | Natureza e papel de roteamento separados |
| B-06 | Iteration contract | 2 | P0 | Retornos e convergência computáveis |
| B-07 | Pipeline do orchestrator | 3 | P0 | Routing, execução e validação separados |
| B-08 | Evidence sufficiency | 3/5 | P0 | Recomendações bloqueadas sem evidência |
| B-09 | Validadores semânticos | 4 | P1 | Coerência entre interfaces e fontes |
| B-10 | Fonte única e geração web | 4 | P1 | Eliminação de drift |
| B-11 | Evidence store | 5 | P0 | Claims rastreáveis |
| B-12 | Incerteza e confiança | 5 | P0 | Incerteza propagada e explícita |
| B-13 | Reprodutibilidade | 5 | P0 | Seed, parâmetros e hashes registrados |
| B-14 | Correção FSM/timing/economia | 6 | P1 | Formalizações dimensionalmente coerentes |
| B-15 | Correção ERA/CSP/cognição | 6 | P1 | Métricas e alcance corretamente limitados |
| B-16 | Simulation/playtest bridge | 7 | P2 | Evidência executável |
| B-17 | Dashboard operacional | 7 | P2 | UI conectada a execuções |

## Critérios de pronto do framework

O Codex só deve ser descrito como framework operacional quando todos os itens
abaixo forem verdadeiros:

- [ ] schemas do world model e das interfaces possuem validação executável;
- [ ] handoffs têm compatibilidade verificável de entrada, saída e unidade;
- [ ] routing, execução, iteração e validação são componentes distintos;
- [ ] existe um resultado válido para evidência insuficiente;
- [ ] claims têm proveniência, assumptions e status epistemológico;
- [ ] execuções são reproduzíveis por versão, hash, seed e parâmetros;
- [ ] validação semântica e validação estrutural são separadas;
- [ ] registry, handoffs, README e web são sincronizados por geração;
- [ ] modelos matemáticos corrigidos têm casos-limite cobertos;
- [ ] dashboard não apresenta dados simulados como fatos;
- [ ] pelo menos uma skill formal, uma de design e uma validator percorrem
  o pipeline completo;
- [ ] existe uma simulação ou experimento de referência com resultado
  rastreável até a recomendação.

## Fora de escopo imediato

- adicionar novas skills;
- criar uma pontuação global de “qualidade” ou “saúde”;
- substituir todos os modelos por simulações físicas completas;
- tratar heurísticas de retenção como objetivo universal;
- inferir impacto cognitivo, diversão ou justiça sem dados observacionais;
- transformar o dashboard em produto de produção antes da camada de evidência.

## Sequência de execução recomendada

1. Fase 0 e inventário de drift.
2. Fase 1, começando por IDs, unidades e versões.
3. Fase 2 e migração de um handoff-piloto.
4. Fase 3 com uma execução ponta a ponta de referência.
5. Fase 4 para impedir regressões e gerar artefatos.
6. Fase 5 para tornar claims e evidências persistentes.
7. Fase 6, priorizando modelos que já participam do handoff-piloto.
8. Fase 7 somente após dados reais poderem alimentar a apresentação.

O primeiro vertical slice recomendado é:

```text
world model versionado
  -> discrete state system
  -> interface validada
  -> cross-skill validator
  -> claim com evidência e incerteza
  -> relatório reproduzível
```

Esse slice testa o fundamento do framework sem exigir a implementação
simultânea das 15 skills.
