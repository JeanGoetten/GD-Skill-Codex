# GD Skill Codex

Catálogo de skills conceituais para análise e design de sistemas de jogos.

## Catálogo

| Diretório | Foco |
| --- | --- |
| `frame-based-combat-timing` | timing discreto, frames e cancelamentos |
| `concurrent-gameplay-processes` | concorrência, recursos e redes de Petri |
| `procedural-level-constraint-solving` | CSP, solvabilidade e geração procedural |
| `resource-flow-economy` | fluxos, estoques e equilíbrio de recursos |
| `procedural-expressive-range-analysis` | diversidade e viés de conteúdo procedural |
| `spatial-topology-and-learning-pacing` | topologia, ensino implícito e ritmo |
| `epistemic-holarchic-progression` | grafos de informação e progressão epistêmica |
| `competitive-negative-feedback` | compensação e estabilização competitiva |
| `macroeconomic-resource-conversion` | matrizes de produção e economia virtual |
| `emergent-agency-composition` | composição de verbos e agência emergente |
| `cognitive-schema-disruption` | subversão de expectativas e cognição |
| `committed-risk-reward-actions` | contratos de ações, compromisso e risco espacial |
| `exponential-progression-and-prestige` | famílias de curvas, progressão e prestígio |
| `nested-gameplay-loop-architecture` | loops temporais aninhados |
| `discrete-state-machine-verification` | autômatos, transições e alcançabilidade |

## Convenções

Cada skill está em `DIRETÓRIO/SKILL.md`, começa com front matter YAML contendo `name`, `description`, `domain.primary`, `activation_signals.concepts`, `activation_signals.recognition_references`, `outputs`, `handoffs.downstream` e `exclusions`. `name` usa exatamente o nome do diretório oficial. Todas incluem `Domain`, `Purpose`, `Activation Signals`, `Scope`, `Exclusions`, `Handoff Conditions`, `Handoff Candidates` e `Recognition References`, além do protocolo matemático específico.

### Status matemático e encaminhamento

`Mathematical Status` separa garantias formais, métricas derivadas, heurísticas/julgamentos de design e a simulação ou playtesting obrigatório. As garantias são condicionais ao modelo: por exemplo, AC-3 fornece consistência de arco, não solvabilidade global; entropia descreve distribuição, não qualidade; KL exige o mesmo espaço de eventos; estabilidade não implica justiça; e valor esperado não determina escolha do jogador.

`Handoff Candidates` lista destinos oficiais e o gatilho de encaminhamento. O front matter é a interface legível por ferramentas; as seções narrativas preservam contexto, limitações e evidências para designers.

## Arquitetura de roteamento

Use `discrete-state-machine-verification` como interface de estados, invariantes e alcançabilidade. Encaminhe timing para `frame-based-combat-timing`, concorrência para `concurrent-gameplay-processes`, espaço e ensino para `spatial-topology-and-learning-pacing`, geração para `procedural-level-constraint-solving` ou `procedural-expressive-range-analysis`, economia para `resource-flow-economy` ou `macroeconomic-resource-conversion`, e progressão para `exponential-progression-and-prestige`. Narrativa epistêmica e cognição usam `epistemic-holarchic-progression` e `cognitive-schema-disruption`; agência, risco e competição usam `emergent-agency-composition`, `committed-risk-reward-actions` e `competitive-negative-feedback`. Loops temporais são tratados por `nested-gameplay-loop-architecture`.

## Interfaces oficiais

Toda skill recebe um problema e contexto do sistema; retorna modelo, premissas, métricas, anomalias e recomendações. As interfaces entre skills são: estado (`Q, Σ, δ, q0, F`), grafo espacial (`V, E`), fluxo (`stocks, flows, rates`), curva (`f(t), custo marginal, reset`) e evidência epistêmica (`holons, clues, knowledge state`). O handoff deve citar o diretório oficial de destino e preservar unidades, domínios e invariantes.

Fórmulas são modelos de trabalho: unidades, domínios, estados, contratos de erro e critérios de aceitação devem ser explicitados no projeto que as aplicar. AC-3 é apenas consistência local; verificações globais de trajetória, alcançabilidade e solvabilidade continuam necessárias. Para estados heterogêneos, normalize uma representação comum antes de aplicar norma ou divergência KL.

## Limitações

Os limiares e diagnósticos são riscos condicionais, não garantias universais. Resultados dependem do modelo, dados, implementação, latência, acessibilidade, comportamento do jogador e playtests. A validação textual não substitui testes de execução, simulação ou revisão de design.

## Validação

No PowerShell, execute:

```powershell
.\validate_skills.ps1
```

O script verifica front matter, `name == diretório` e headings obrigatórios sem instalar dependências.

## Arquitetura incorporada do feedback

As recomendações do documento de feedback agora estão implementadas em
[`architecture/`](architecture/):

- [`world-model.schema.json`](architecture/world-model.schema.json) define a
  ontologia compartilhada (`entities`, `resources`, `spatial`, `temporal`,
  `rules`, `knowledge`, `progression`, `economy`, `actors`, `actions`, `goals`
  e `hidden_state`);
- [`orchestrator.md`](architecture/orchestrator.md) define o pipeline de
  decomposição, seleção de modelo, composição, estatuto epistemológico e
  validação cruzada;
- [`handoffs.json`](architecture/handoffs.json) transforma encaminhamentos em
  contratos com gatilho, entrada, saída, retorno e limite de iteração;
- [`skill-registry.json`](architecture/skill-registry.json) centraliza
  `domain_role` (natureza) e `routing_role` (papel no roteamento), além de sinais semânticos,
  estruturais e anti-sinais;
- [`route_request.ps1`](architecture/route_request.ps1) implementa um roteador
  determinístico de referência;
- [`calibration.schema.json`](architecture/calibration.schema.json) registra
  confiança, amostra e status epistemológico de parâmetros;
- [`calibration.defaults.json`](architecture/calibration.defaults.json) marca
  defaults de repetição e duração como heurísticas de baixa confiança;
- [`validate_cross_skill.ps1`](architecture/validate_cross_skill.ps1) verifica
  registry, complementos, arquivos das skills e ciclos de handoff;
- [`validate_architecture.ps1`](architecture/validate_architecture.ps1) verifica
  que o schema, registry e contratos estão completos.

Execute `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\architecture\validate_architecture.ps1`
para validar essa camada.

`architecture\validate_all.ps1` executa também a validação cross-skill e a
verificação de sincronização dos dados web. O contrato mínimo de proveniência
está em [`architecture/evidence.schema.json`](architecture/evidence.schema.json)
e um exemplo está em
[`architecture/evidence.example.json`](architecture/evidence.example.json).
O runner de referência
[`architecture/run_analysis.ps1`](architecture/run_analysis.ps1) gera um plano
de análise reproduzível e marca explicitamente a insuficiência de evidência
enquanto a execução das skills ainda não estiver implementada.
[`architecture/execute_skills.ps1`](architecture/execute_skills.ps1) é o dispatcher operacional: valida o world model, executa as skills na ordem de roteamento e, quando existe um adapter compatível, executa o adapter **antes** da skill seguinte. O resultado do adapter é injetado no world model temporário da skill seguinte em `hidden_state.handoff_context` e preservado também como `input_context` no `SkillOutput`. Assim, handoffs são entradas efetivas da execução, e não apenas relatórios produzidos depois dela.
O primeiro executor versionado analisa sistemas de estados em
[`architecture/executors/discrete-state-machine-verification.ps1`](architecture/executors/discrete-state-machine-verification.ps1);
o formato mínimo está exemplificado em
[`architecture/examples/state-system.example.json`](architecture/examples/state-system.example.json).
Também há executors para CSP e fluxo de recursos em
[`architecture/executors/`](architecture/executors), com fixtures em
[`architecture/examples/`](architecture/examples). Eles distinguem
consistência local, balanço discreto e evidência suficiente; não apresentam
essas métricas como prova global de solvabilidade, economia saudável ou
qualidade de design.
O executor de processos concorrentes usa
[`petri-net.schema.json`](architecture/schemas/petri-net.schema.json) e
reporta disparos observados e deadlocks na execução limitada; vivacidade global
continua exigindo análise adicional.
O executor de timing usa
[`frame-timing.schema.json`](architecture/schemas/frame-timing.schema.json) e
separa janelas de startup/active/recovery, vantagens calculadas e condições
necessárias para um candidato a loop. Não classifica punição ou loop como
garantidos sem dados espaciais e de escape.
O executor ERA usa
[`procedural-expressive-range-analysis.schema.json`](architecture/schemas/procedural-expressive-range-analysis.schema.json)
e reporta ocupação de bins, amostras classificadas e viés declarado. Ocupação
de bins não é tratada como cobertura de área; solvabilidade deve ser fornecida
antes da análise.
Os executors de progressão e macroeconomia usam,
respectivamente, [`progression-analysis.schema.json`](architecture/schemas/progression-analysis.schema.json)
e [`macroeconomic-conversion.schema.json`](architecture/schemas/macroeconomic-conversion.schema.json).
O primeiro calcula trajetórias discretas, regimes de crescimento e prestígio
com guardas contra blow-up; o segundo calcula conversões input-output,
eficiência, balanço monetário e uma projeção de preço explicitamente
aproximada. Nenhum dos dois transforma cálculo condicional em evidência
empírica de retenção, inflação ou comportamento de mercado.
O executor [`committed-risk-reward-actions.ps1`](architecture/executors/committed-risk-reward-actions.ps1)
analisa contratos de ação declarados, detectando combinações estruturais como
dominância sem risco, armadilha de stamina e incoerência entre exposição e
alcance. Esses alertas dependem dos parâmetros fornecidos e devem ser
confirmados por timing, geometria e playtest; não são diagnósticos empíricos.
O executor [`epistemic-holarchic-progression.ps1`](architecture/executors/epistemic-holarchic-progression.ps1)
verifica grafos de holons e pistas, ilhas informacionais, pseudo-holons
bloqueados por inventário, grafos estritamente lineares e cobertura declarada
de predecessores terminais. A capacidade de inferência é uma métrica de
cobertura do grafo, não uma probabilidade de compreensão do jogador.
O executor [`cognitive-schema-disruption.ps1`](architecture/executors/cognitive-schema-disruption.ps1)
verifica consolidação de convenções, coerência retrospectiva, preservação de
agência e mudança de variável estratégica. Ele sinaliza rupturas prematuras,
dissonância arbitrária, ruptura punitiva e quebras sem efeito estratégico,
sem alegar medir surpresa, confusão ou acomodação cognitiva.
O executor [`competitive-negative-feedback.ps1`](architecture/executors/competitive-negative-feedback.ps1)
calcula desvios relativos, gap entre líder e última posição e verifica riscos
de rubber-banding extremo, oscilação elástica e incentivo a sandbagging.
Estabilidade matemática não é tratada como prova de justiça percebida;
comportamento estratégico exige simulação ou telemetria.
O executor [`spatial-topology-and-learning-pacing.ps1`](architecture/executors/spatial-topology-and-learning-pacing.ps1)
verifica alcançabilidade declarada, introdução isolada de mecânicas, picos de
carga cognitiva, platôs de tensão e salas de descompressão. Grafo alcançável
não prova solvabilidade física, descoberta ou aprendizagem; essas propriedades
exigem simulação de rotas e testes com jogadores.
Também estão disponíveis executors para composição de agência e loops aninhados,
além de [`simulation_runner.ps1`](architecture/simulation_runner.ps1),
[`regression_tests.ps1`](architecture/regression_tests.ps1) e
[`validate_handoff_compatibility.ps1`](architecture/validate_handoff_compatibility.ps1).
O schema [`playtest-hypothesis.schema.json`](architecture/schemas/playtest-hypothesis.schema.json)
separa hipóteses e observações futuras dos cálculos derivados. O dashboard
permite carregar um relatório JSON local e exibe status, seed, hash, claims,
confiança, proveniência e adapters; sem relatório, o estado permanece
`not executed`.
O registry agora separa `domain_role` de `routing_role` sem manter o campo legado
`role`. [`iterate_handoffs.ps1`](architecture/iterate_handoffs.ps1) executa ciclos
limitados com critério de convergência, reutilizando o contexto retornado pela
cadeia em vez de simplesmente repetir a mesma análise sem entrada intermediária. Schemas de conhecimento, progressão,
economia e espaço exigem IDs, relações, unidades ou status epistemológicos
quando esses objetos são fornecidos.
Os adapters declarativos em [`handoff-adapters.json`](architecture/handoff-adapters.json)
podem ser executados por [`execute_handoff_adapter.ps1`](architecture/execute_handoff_adapter.ps1).
Campos não deriváveis permanecem em `external_required` e não são fabricados.
Quando duas skills compatíveis aparecem na ordem de execução, o dispatcher
executa o adapter entre as duas execuções. O adapter pode produzir `ready`,
`partial` ou `requires_external_evidence`; campos não deriváveis permanecem
explícitos em `external_required` e `warnings`. O contexto recebido pela skill
destino é registrado em `input_context` e em `hidden_state.handoff_context`,
enquanto `handoff_adapters` preserva a proveniência da transformação.
A validação JSON Schema agora usa AJV 8 e `ajv-formats`, executada por
[`validate_json_schema.js`](architecture/validate_json_schema.js) ou
`npm run validate:schema`.
[`validate_adapter_dimensions.ps1`](architecture/validate_adapter_dimensions.ps1)
verifica versão, schemas e unidades declaradas dos adapters.
[`query_evidence_store.ps1`](architecture/query_evidence_store.ps1) permite
consultar claims persistidos por skill, status e confiança.
[`generate_recommendations.ps1`](architecture/generate_recommendations.ps1)
gera recomendações rastreáveis e bloqueia ações quando o claim está em
`INSUFFICIENT_EVIDENCE` ou com baixa confiança.
`validate_recommendations.ps1` verifica os vínculos entre recomendações e
claims. O simulation runner também pode persistir sua proveniência diretamente
no evidence store, e o dashboard oferece filtros de claims por confiança e
estado epistemológico.
`validate_report.ps1` valida um relatório completo, incluindo proveniência
compatível com o hash de entrada e recomendações não órfãs. O índice do
evidence store é atualizado automaticamente tanto pelo dispatcher quanto pelo
simulation runner.
Relatórios do `simulation_runner.ps1` seguem
[`simulation-report.schema.json`](architecture/schemas/simulation-report.schema.json)
e podem ser verificados diretamente com
`node architecture/validate_simulation_report.js <report.json>`.
O fixture de simulação também é gerado e validado automaticamente por
[`validate_all.ps1`](architecture/validate_all.ps1). Hipóteses de playtest
podem ser verificadas por
[`validate_playtest_hypothesis.ps1`](architecture/validate_playtest_hypothesis.ps1);
o validador mantém observações executadas separadas de hipóteses futuras.
Observações válidas podem ser registradas no evidence store por
[`record_playtest_observation.ps1`](architecture/record_playtest_observation.ps1);
o registro preserva hipótese, métrica, amostra, limitações e proveniência
empírica sem converter coleta parcial em conclusão.
[`validate_evidence_store.js`](architecture/validate_evidence_store.js) valida
cada linha JSONL persistida contra `evidence.schema.json`; essa checagem é
executada para stores de playtest e simulação no pipeline agregado.
O arquivo [`web/data.js`](web/data.js) é gerado por
[`architecture/generate_web_data.ps1`](architecture/generate_web_data.ps1) a
partir do registry, dos handoffs e dos `SKILL.md`; não deve ser editado como
fonte primária.

## Página pública

O repositório inclui uma apresentação pública em GitHub Pages, com design light e foco em leitura rápida da arquitetura, tecnologias, finalidade, catálogo, handoffs, exemplos e tutorial para iniciantes.

O deploy é automático pelo workflow [`.github/workflows/pages.yml`](.github/workflows/pages.yml): cada push em `master` publica o conteúdo de [`web/`](web/) como site estático.

A página está organizada em:
- **Projeto:** síntese do problema que o Codex resolve e dos seus princípios;
- **Arquitetura:** World Model, typed handoffs, executors, JSON Schema, evidence store e simulation;
- **Explorer:** catálogo das 15 skills e mapa de relações downstream;
- **Exemplos:** links diretos para fixtures JSON em `architecture/examples/`;
- **Tutorial:** introdução visual em três passos para usuários sem conhecimento técnico.

A execução de PowerShell permanece separada da página pública: GitHub Pages fornece a documentação e exploração estática; a execução local continua disponível no ambiente do repositório.

## Visualização web

O painel está em [`web/`](web/) e funciona como uma página estática, sem dependências ou build:

1. Abra [`web/index.html`](web/index.html) no navegador; ou
2. sirva a raiz do repositório com qualquer servidor HTTP estático.

Ele apresenta o `world_state` compartilhado, filtros por tipo e status epistemológico, fichas de cada skill e um mapa navegável dos handoffs downstream. Os dados de apresentação ficam em [`web/data.js`](web/data.js), mantendo o catálogo utilizável offline.

### Planejamento e mockup

O mockup visual preservado do worktree auxiliar está em
[`docs/web-dashboard-mockup.svg`](docs/web-dashboard-mockup.svg). A
implementação atual prioriza o catálogo de skills, o world model, os handoffs e
o roteamento; extensões futuras podem adicionar entrada estruturada do usuário,
nome provisório determinístico, séries temporais, Sankey, radar e tabelas
acessíveis equivalentes aos gráficos. Dados ausentes devem permanecer explícitos
e nunca ser inventados.

O plano de evolução da arquitetura está em
[`docs/action-plan.md`](docs/action-plan.md). Ele organiza as correções da
auditoria em fases, backlog, critérios de aceite e um primeiro vertical slice,
priorizando world model, contratos tipados, orchestrator, evidência,
reprodutibilidade e validação antes de novas skills.

## Arquivo consolidado do projeto

[`GD-Skill-Codex.txt`](GD-Skill-Codex.txt) é a distribuição textual única do
projeto. Ele contém o conteúdo integral de todos os demais arquivos textuais,
organizado por caminho relativo e delimitado por marcadores. O arquivo é
regenerado quando qualquer arquivo do projeto muda; o próprio consolidado não
é incluído como entrada para evitar recursão.
