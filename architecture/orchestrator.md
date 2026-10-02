# Problem Orchestrator

Camada de controle do GD Skill Codex. Ela compõe as skills existentes; não substitui
nenhuma delas.

## Pipeline obrigatório

```text
user request
  -> problem decomposition
  -> world-model extraction
  -> assumptions and unknowns
  -> ontological projection
  -> skill routing
  -> formal model selection
  -> interface validation
  -> domain skill composition
  -> evidence sufficiency
  -> conflict and uncertainty report
  -> design options
  -> simulation/playtest plan
  -> recommendation
```

### 1. Decomposição

Extrair entidades, atores, ações, recursos, objetivos, restrições, escalas
temporais, relações espaciais e evidências disponíveis. Registrar premissas
ausentes como perguntas ou hipóteses; não inventar valores.

### 2. Classificação ontológica

Escolher uma ou mais projeções sobre `architecture/world-model.schema.json`:

| Sinal dominante | Modelo primário |
| --- | --- |
| estados sequenciais, invariantes, alcançabilidade | `discrete-state-machine-verification` |
| processos paralelos, sincronização, recurso compartilhado | `concurrent-gameplay-processes` |
| domínios, restrições e geração | `procedural-level-constraint-solving` |
| timeline, startup/active/recovery, frames | `frame-based-combat-timing` |
| estoques, fontes, sinks e taxas | `resource-flow-economy` |
| conversão em múltiplos estágios | `macroeconomic-resource-conversion` |

Regra: concorrência com controle sequencial usa um modelo híbrido FSM + Petri
Net; não ampliar uma FSM para representar simultaneidade complexa.

### 3. Seleção e composição

O registry central em `architecture/skill-registry.json` está em migração para
separar duas dimensões:

- **domain role**: natureza da skill (`formal`, `design`, `hybrid`);
- **routing role**: função contextual (`primary_candidate`, `secondary`,
  `validator`).

A migração de `role` foi concluída. `domain_role` e `routing_role` são as únicas dimensões válidas para novos contratos; qualquer ocorrência de `role` no registry é erro de arquitetura.
O roteador usa perfis de problema antes dos sinais genéricos. A pontuação combina
perfis semânticos, sinais `explicit`, `semantic` e `structural`, com penalização
por `anti_signals`. Candidatos próximos são preservados como secundários em vez
de serem descartados por uma escolha arbitrária. O registry não possui mais
`role` legado; somente `domain_role` e `routing_role` são válidos.
Use `architecture/route_request.ps1` como implementação de referência.

Skills complementares trabalham em paralelo ou em ciclos; `downstream` indica
dependência de dados, não apenas uma sugestão de leitura. O runner materializa
contexto de entrada, adapters tipados e pacotes de retorno. Cada ciclo tem
`return_to`, `max_cycles` e uma impressão digital de claims/adapters para
detectar estabilidade; igualdade de status ou de rota isoladamente não é mais
considerada convergência.

### 4. Estatuto epistemológico

Toda conclusão deve ser classificada:

- **formal**: garantia condicional ao modelo e às premissas;
- **derived**: métrica calculada a partir dos dados;
- **heuristic**: parâmetro ou julgamento de design calibrável;
- **empirical**: afirmação que exige simulação, playtest ou observação.

Constantes do sistema, parâmetros de design, métricas derivadas e hipóteses
empíricas não podem ser apresentados como a mesma coisa. Referências de obras
são apenas âncoras semânticas: não autorizam imitação de estilo nem inferência
de cânone.

### 5. Validação cruzada

Antes da recomendação final, verificar:

1. **ontologia**: entidades, recursos e estados significam a mesma coisa;
2. **tempo**: segundos, frames e ciclos têm conversão explícita;
3. **causalidade**: dependências não formam contradições;
4. **economia**: fontes, sinks e conversões preservam unidades;
5. **agência**: uma projeção não remove uma escolha criada por outra;
6. **solvabilidade**: cobertura, estabilidade ou entropia não são confundidas
   com qualidade ou diversão.
7. **evidência**: toda recomendação aponta para claims, assumptions e
   limitações; sem dados suficientes, retornar `INSUFFICIENT_EVIDENCE`.

Conflitos devem ser reportados como bloqueios ou hipóteses pendentes, nunca
silenciosamente resolvidos.

## Calibração empírica

`architecture/calibration.schema.json` registra a diferença entre constante do
sistema, parâmetro de design, métrica derivada, heurística, observação e valor
validado. Defaults como `N_repetitions = 3` devem ser registrados como
`heuristic`, com confiança e necessidade de validação, nunca como garantia
universal.

## Validação e proveniência

`architecture/validate_all.ps1` executa as validações estruturais,
cross-skill e de sincronização da camada web. O schema
`architecture/evidence.schema.json` define a unidade mínima de proveniência
para claims, incluindo status epistemológico, evidências, assumptions,
limitações, versões, hash de entrada e seed quando aplicável.

`architecture/run_analysis.ps1` é o reference runner atual: ele executa o
roteamento e produz um plano versionado com proveniência, mas declara
`INSUFFICIENT_EVIDENCE` até existir executor de skills ou simulação. Isso evita
apresentar um plano de execução como se fosse um diagnóstico concluído.
Quando recebe `-EvidenceStorePath`, também persiste os claims como JSONL
append-only, preservando hash de entrada, versões, seed e timestamp.

`architecture/execute_skills.ps1` implementa a ponte inicial de execução:
valida o world model, materializa um `SkillInput` por skill roteada e gera um
`SkillOutput` `blocked` quando não existe executor operacional. Bloquear é
intencional; o script não interpreta Markdown como código nem fabrica
resultados.

O primeiro executor concreto é
`architecture/executors/discrete-state-machine-verification.ps1`. Ele aplica
BFS ao `hidden_state.state_system` e reporta estados alcançáveis, órfãos,
deadlocks e não-determinismo. A simulação limitada correspondente está em
`architecture/simulate_state_system.ps1`; ela exige seed e limite de passos.

`architecture/generate_web_data.ps1` gera o artefato da visualização a partir
do registry, dos handoffs e do front matter/conteúdo das skills. A camada web
é uma projeção do sistema, não uma fonte independente de relações.
