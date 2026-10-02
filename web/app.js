(function () {
  const data = window.CODEX_DATA;
  if (!data) return;

  const escapeHTML = (value) => String(value ?? '')
    .replace(/&/g, '&amp;').replace(/</g, '&lt;')
    .replace(/>/g, '&gt;').replace(/"/g, '&quot;');

  const byId = new Map(data.skills.map((skill) => [skill.id, skill]));
  const list = document.getElementById('skill-list');
  const detail = document.getElementById('detail-panel');
  const search = document.getElementById('search');
  const typeFilter = document.getElementById('type-filter');
  const evidenceFilter = document.getElementById('evidence-filter');
  const resultCount = document.getElementById('result-count');

  function renderDetail(skill) {
    if (!skill) {
      detail.innerHTML = '<p class="muted">No skills match the current filters.</p>';
      return;
    }
    const label = skill.type === 'formal' ? 'FORMAL MODEL'
      : skill.type === 'design' ? 'DIAGNÓSTICO DE DESIGN' : 'MODEL + DESIGN';
    detail.innerHTML =
      '<p class="kicker">' + label + '</p>' +
      '<h3>' + escapeHTML(skill.title) + '</h3>' +
      '<p class="lens">' + escapeHTML(skill.lens) + '</p>' +
      '<div class="tag-list">' + (skill.concepts || []).map((c) =>
        '<span class="tag">' + escapeHTML(c) + '</span>').join('') + '</div>' +
      '<h4>Outputs</h4><ul>' + (skill.outputs || []).map((o) =>
        '<li>' + escapeHTML(o) + '</li>').join('') + '</ul>' +
      '<h4>Downstream handoffs</h4><ul>' + (skill.downstream || []).map((id) =>
        '<li><a href="#explorer" data-open="' + escapeHTML(id) + '">' +
        escapeHTML((byId.get(id) || {}).title || id) + '</a></li>').join('') + '</ul>' +
      '<h4>Epistemic status</h4><p class="muted">' +
      (skill.evidence || []).map(escapeHTML).join(' · ') + '</p>';

    detail.querySelectorAll('[data-open]').forEach((link) => {
      link.addEventListener('click', () => {
        renderList(link.dataset.open);
        document.getElementById('explorer').scrollIntoView({ behavior: 'smooth' });
      });
    });
  }

  function renderList(selectedId) {
    const q = (search.value || '').trim().toLowerCase();
    const skills = data.skills.filter((skill) => {
      const typeOK = typeFilter.value === 'all' || skill.type === typeFilter.value;
      const evidenceOK = evidenceFilter.value === 'all' ||
        (skill.evidence || []).includes(evidenceFilter.value);
      const text = [skill.id, skill.title, skill.lens, ...(skill.concepts || []),
        ...(skill.outputs || [])].join(' ').toLowerCase();
      return typeOK && evidenceOK && (!q || text.includes(q));
    });

    resultCount.textContent = skills.length + ' of ' + data.skills.length + ' skills';
    list.innerHTML = skills.length ? skills.map((skill) =>
      '<article class="skill-card" data-id="' + escapeHTML(skill.id) + '" tabindex="0">' +
      '<div class="card-top"><span class="type-dot ' + escapeHTML(skill.type) +
      '"></span><span class="muted">' + escapeHTML((skill.evidence || [])[0] || '') +
      '</span></div><h3>' + escapeHTML(skill.title) + '</h3><p>' +
      escapeHTML(skill.lens) + '</p></article>').join('') :
      '<p class="muted">No skills match the current filters.</p>';

    list.querySelectorAll('[data-id]').forEach((card) => {
      card.addEventListener('click', () => renderList(card.dataset.id));
      card.addEventListener('keydown', (event) => {
        if (event.key === 'Enter' || event.key === ' ') renderList(card.dataset.id);
      });
    });

    const current = skills.find((skill) => skill.id === selectedId) || skills[0];
    renderDetail(current);
  }

  function renderGraph() {
    const graph = document.getElementById('graph');
    if (!graph) return;
    const positions = new Map();
    data.skills.forEach((skill, index) => {
      positions.set(skill.id, {
        x: 55 + Math.floor(index / 5) * 270,
        y: 45 + (index % 5) * 82
      });
    });

    const links = data.skills.flatMap((skill) => (skill.downstream || [])
      .filter((target) => positions.has(target))
      .map((target) => {
        const from = positions.get(skill.id), to = positions.get(target);
        return '<line class="graph-link" x1="' + from.x + '" y1="' + from.y +
          '" x2="' + to.x + '" y2="' + to.y + '"/>';
      })).join('');

    const nodes = data.skills.map((skill) => {
      const point = positions.get(skill.id);
      const label = skill.title.length > 26 ? skill.title.slice(0, 25) + '…' : skill.title;
      return '<g class="graph-node" data-graph-id="' + escapeHTML(skill.id) +
        '" tabindex="0"><circle cx="' + point.x + '" cy="' + point.y +
        '" r="7"/><text x="' + (point.x + 13) + '" y="' + (point.y + 4) +
        '">' + escapeHTML(label) + '</text></g>';
    }).join('');

    graph.innerHTML = '<g>' + links + '</g><g>' + nodes + '</g>';
    graph.querySelectorAll('[data-graph-id]').forEach((node) => {
      node.addEventListener('click', () => {
        renderList(node.dataset.graphId);
        document.getElementById('explorer').scrollIntoView({ behavior: 'smooth' });
      });
    });
  }

  search.addEventListener('input', () => renderList());
  typeFilter.addEventListener('change', () => renderList());
  evidenceFilter.addEventListener('change', () => renderList());

  renderList();
  renderGraph();
})();