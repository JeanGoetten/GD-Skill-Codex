(function () {
  const data = window.CODEX_DATA;
  if (!data) return;
  const wsStatus = document.getElementById('conn-status');

  // --- API (caminhos relativos: mesma origem do server.js) ------------
  async function apiGet(path) {
    const resp = await fetch(path);
    return resp.ok ? await resp.json() : null;
  }
  async function apiPost(path, body) {
    const resp = await fetch(path, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    return resp.ok ? await resp.json() : { error: resp.statusText };
  }

  // --- DOM refs -------------------------------------------------------
  const executorSelect = document.getElementById('executor-select');
  const worldModelSelect = document.getElementById('worldmodel-select');
  const seedInput = document.getElementById('seed-input');
  const repeatsInput = document.getElementById('repeats-input');
  const runBtn = document.getElementById('run-btn');
  const loadBtn = document.getElementById('load-btn');
  const executionFile = document.getElementById('execution-file');
  const executionSummary = document.getElementById('execution-summary');
  const executionDetails = document.getElementById('execution-details');
  const simulationDetails = document.getElementById('simulation-details');
  const executionError = document.getElementById('execution-error');

  const skillList = document.getElementById('skill-list');
  const detailPanel = document.getElementById('detail-panel');
  const search = document.getElementById('search');
  const typeFilter = document.getElementById('type-filter');
  const evidenceFilter = document.getElementById('evidence-filter');
  const resultCount = document.getElementById('result-count');

  // --- state ----------------------------------------------------------
  let loadedReport = null;
  let selectedId = null;
  const byId = new Map(data.skills.map((s) => [s.id, s]));

  // --- helpers --------------------------------------------------------
  function escapeHTML(s) {
    return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  // --- world state ----------------------------------------------------
  document.getElementById('world-fields').innerHTML = data.worldFields
    .map((item) => `<div><code>${escapeHTML(item[0] || item.value?.[0] || item.id)}</code>${escapeHTML(item[1] || item.label || '')}</div>`)
    .join('');

  // --- catálogo --------------------------------------------------------
  function renderDetail(skill) {
    if (!skill) {
      detailPanel.innerHTML = '<p class="eyebrow">DETALHE</p><p class="muted">Nenhum resultado para os filtros atuais.</p>';
      return;
    }
    const lbl = skill.type === 'formal' ? 'MODELO FORMAL' : skill.type === 'design' ? 'DIAGNÓSTICO DE DESIGN' : 'MODELO + DIAGNÓSTICO';
    detailPanel.innerHTML =
      `<p class="eyebrow">${lbl}</p><h3>${escapeHTML(skill.title)}</h3>` +
      `<p class="lens">${escapeHTML(skill.lens)}</p>` +
      `<div class="tag-list">${(skill.concepts || []).map((c) => `<span class="tag">${escapeHTML(c)}</span>`).join('')}</div>` +
      `<h4>Saídas</h4><ul>${(skill.outputs || []).map((o) => `<li>${escapeHTML(o)}</li>`).join('')}</ul>` +
      `<h4>Handoffs downstream</h4><ul>${(skill.downstream || []).map((id) => `<li><a href="#catalog" data-open="${id}">${(byId.get(id) || {}).title || id}</a></li>`).join('')}</ul>` +
      `<h4>Status epistemológico</h4><p class="muted">${(skill.evidence || []).join(' · ')}</p>`;
    detailPanel.querySelectorAll('[data-open]').forEach((link) =>
      link.addEventListener('click', () => selectSkill(link.dataset.open)));
  }

  function renderList() {
    const q = (search.value || '').trim().toLowerCase();
    const skills = data.skills.filter((s) => {
      const matchesType = typeFilter.value === 'all' || s.type === typeFilter.value;
      const matchesEvidence = evidenceFilter.value === 'all' || (s.evidence || []).includes(evidenceFilter.value);
      const matchesQuery = !q ||
        [s.id, s.title, s.lens, ...(s.concepts || []), ...(s.outputs || [])].join(' ').toLowerCase().includes(q);
      return matchesType && matchesEvidence && matchesQuery;
    });
    resultCount.textContent = `${skills.length} de ${data.skills.length} lentes`;
    skillList.innerHTML = skills.length
      ? skills.map((s) =>
          `<article class="skill-card ${s.id === selectedId ? 'selected' : ''}" data-id="${s.id}" tabindex="0" role="button" aria-label="Abrir ${s.title}">` +
          `<div class="card-top"><span class="type-dot ${s.type}"></span><span class="muted">${escapeHTML((s.evidence || [])[0] || '')}</span></div>` +
          `<h3>${escapeHTML(s.title)}</h3><p>${escapeHTML(s.lens)}</p></article>`).join('')
      : '<p class="muted">Nenhuma skill corresponde aos filtros.</p>';
    skillList.querySelectorAll('[data-id]').forEach((card) => {
      card.addEventListener('click', () => selectSkill(card.dataset.id));
      card.addEventListener('keydown', (e) => { if (e.key === 'Enter' || e.key === ' ') selectSkill(card.dataset.id); });
    });
    const current = skills.find((s) => s.id === selectedId) || skills[0] || data.skills[0];
    if (current) renderDetail(current);
  }

  function selectSkill(id) {
    selectedId = id;
    renderList();
  }

  // --- grafo de handoffs ----------------------------------------------
  (function renderGraph() {
    const graph = document.getElementById('graph');
    const positions = new Map();
    data.skills.forEach((skill, index) => {
      positions.set(skill.id, { x: 110 + Math.floor(index / 5) * 260, y: 55 + (index % 5) * 86 });
    });
    const links = data.skills.flatMap((skill) =>
      (skill.downstream || [])
        .filter((target) => positions.has(target))
        .map((target) => {
          const from = positions.get(skill.id);
          const to = positions.get(target);
          return `<line class="graph-link" x1="${from.x}" y1="${from.y}" x2="${to.x}" y2="${to.y}"/>`;
        })).join('');
    const nodes = data.skills.map((skill) => {
      const point = positions.get(skill.id);
      const color = skill.type === 'formal' ? 'var(--info)' : skill.type === 'design' ? '#d2a8ff' : 'var(--warn)';
      const label = skill.title.length > 24 ? skill.title.slice(0, 23) + '…' : skill.title;
      return `<g class="graph-node" data-graph-id="${skill.id}" tabindex="0"><circle cx="${point.x}" cy="${point.y}" r="7" fill="${color}"/><text x="${point.x + 13}" y="${point.y + 4}">${label}</text></g>`;
    }).join('');
    graph.innerHTML = `<g>${links}</g><g>${nodes}</g>`;
    document.getElementById('graph-text').innerHTML =
      `<p><strong>Relações em texto</strong></p><ul>${data.skills.map((skill) =>
        `<li><strong>${escapeHTML(skill.title)}</strong>: ${(skill.downstream || []).map((id) => (byId.get(id) || {}).title || id).join(', ') || 'sem downstream declarado'}</li>`).join('')}</ul>`;
    graph.querySelectorAll('[data-graph-id]').forEach((node) => {
      node.addEventListener('click', () => { selectSkill(node.dataset.graphId); document.getElementById('catalog').scrollIntoView(); });
    });
  })();

  // --- console de execução --------------------------------------------
  function showConn(state, text) {
    wsStatus.className = 'conn ' + state;
    wsStatus.textContent = text;
  }

  async function fetchOptions() {
    const opts = await apiGet('/api/options');
    if (!opts) { showConn('off', '● API offline'); return; }
    showConn('on', '● API local');
    executorSelect.innerHTML = (opts.executors || []).map((id) => `<option value="${id}">${id.replace(/-/g, ' ')}</option>`).join('')
      || '<option value="">nenhum executor</option>';
    executorSelect.value = 'discrete-state-machine-verification';
    worldModelSelect.innerHTML = (opts.worldModels || []).map((w) => {
      const value = w.path || w.id;
      const label = value.replace(/architecture\/examples\//, '').replace('.example.json', '');
      return `<option value="${value}">${label}</option>`;
    }).join('') || '<option value="">nenhum world model</option>';
    if (worldModelSelect.options.length > 1) worldModelSelect.selectedIndex = 1;
  }

  function renderExecution(report) {
    const outputs = Array.isArray(report.outputs) ? report.outputs : [];
    const claims = Array.isArray(report.claims) ? report.claims : [];
    const adapters = Array.isArray(report.handoff_adapters) ? report.handoff_adapters : [];
    const recommendations = Array.isArray(report.recommendations) ? report.recommendations : [];
    const simulation = report.runner === 'architecture/simulation_runner.ps1' ? report : null;
    const statuses = claims.reduce((acc, c) => { acc[c.status] = (acc[c.status] || 0) + 1; return acc; }, {});
    const hash = report.input_hash || report.world_model_hash || 'n/a';
    const seed = report.seed ?? 'n/a';

    executionSummary.textContent =
      `status: ${report.execution_status || 'n/a'} · skills: ${outputs.length} · claims: ${claims.length} · seed: ${seed} · hash: ${hash}`;

    let html = `<p><strong>Claims:</strong> ${claims.length} · <strong>Adapters:</strong> ${adapters.length} · <strong>Recomendações:</strong> ${recommendations.length} · <strong>Status:</strong> ${Object.entries(statuses).map(([k, v]) => k + '=' + v).join(' · ') || 'n/a'}</p>`;
    html += `<ul>${claims.map((c) =>
      `<li><strong>${escapeHTML(c.skill_id || 'skill')}</strong> · ${escapeHTML(c.status || 'unknown')} · confiança ${escapeHTML(c.confidence || 'n/a')}${c.provenance?.source_kind ? ' · ' + escapeHTML(c.provenance.source_kind) : ''}</li>`).join('')}</ul>`;
    html += `<h4>Recomendações</h4><ul>${recommendations.map((r) => `<li><strong>${escapeHTML(r.priority)}</strong> · ${escapeHTML(r.recommendation)}</li>`).join('')}</ul>`;
    executionDetails.innerHTML = html;

    simulationDetails.innerHTML = simulation
      ? `<h4>Simulação</h4><p><strong>Status:</strong> ${escapeHTML(simulation.evidence_status)} · <strong>Runs:</strong> ${simulation.repeats ?? 'n/a'} · <strong>Sucesso:</strong> ${simulation.aggregate?.successful_runs ?? 'n/a'} · <strong>Parcial:</strong> ${simulation.aggregate?.partial_runs ?? 'n/a'} · <strong>Falhas:</strong> ${simulation.aggregate?.failed_runs ?? 'n/a'}</p><p class="muted">Resultados de simulação são derivados e não substituem telemetria ou playtest.</p>`
      : '';
  }

  async function runSimulation() {
    const executor = executorSelect.value || 'discrete-state-machine-verification';
    const worldModel = worldModelSelect.value || 'architecture/examples/state-system.example.json';
    const seed = Number(seedInput.value) || 42;
    const repeats = Math.max(1, Number(repeatsInput.value) || 1);
    executionError.textContent = '';
    executionSummary.textContent = `status: rodando · executor: ${executor} · seed: ${seed}`;
    executionDetails.innerHTML = '<p class="muted">Executando simulação...</p>';
    simulationDetails.innerHTML = '';
    try {
      const report = await apiPost('/api/simulate', { executor, worldModel, seed, repeats });
      if (!report || report.error) throw new Error((report && report.error) || 'resposta vazia');
      loadedReport = report;
      renderExecution(report);
    } catch (err) {
      executionError.textContent = 'Erro ao executar simulação: ' + (err.message || err);
      executionSummary.textContent = 'status: erro';
    }
  }

  runBtn.addEventListener('click', runSimulation);
  loadBtn.addEventListener('click', () => executionFile.click());
  executionFile.addEventListener('change', () => {
    const file = executionFile.files[0];
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      try {
        loadedReport = JSON.parse(reader.result);
        renderExecution(loadedReport);
      } catch (e) {
        executionError.textContent = 'Não foi possível ler o relatório: ' + e.message;
      }
    };
    reader.readAsText(file);
  });

  // --- init -----------------------------------------------------------
  renderList();
  fetchOptions();
  if (window.CODEX_SIMULATION) {
    loadedReport = window.CODEX_SIMULATION;
    renderExecution(loadedReport);
  }
  search.addEventListener('input', renderList);
  typeFilter.addEventListener('input', renderList);
  evidenceFilter.addEventListener('input', renderList);
})();