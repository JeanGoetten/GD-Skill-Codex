'use strict';
// Threshold sync: the defaults applied by executors must equal architecture/threshold-provenance.json,
// every entry must be labelled heuristic, and every entry that claims a spec source must still
// find that text in the SKILL.md. Run: node --test architecture/tests/threshold_sync.test.js
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..', '..');
const readJson = (f) => JSON.parse(fs.readFileSync(f, 'utf8').replace(/^\uFEFF/, ''));
const calib = readJson(path.join(root, 'architecture', 'threshold-provenance.json'));
const ps = process.platform === 'win32' ? 'powershell.exe' : 'pwsh';

// Strip the declared thresholds so the executor applies its own defaults.
function runWithoutDeclarations(skillId, fixture, key, declaredKeys) {
  const world = readJson(path.join(root, 'architecture', 'examples', fixture));
  for (const k of declaredKeys) delete world.hidden_state[key][k];
  const tmp = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'gd-thr-')), 'world.json');
  fs.writeFileSync(tmp, JSON.stringify(world));
  const r = spawnSync(ps, ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File',
    path.join(root, 'architecture', 'executors', `${skillId}.ps1`), '-WorldModelPath', tmp], { encoding: 'utf8' });
  assert.strictEqual(r.status, 0, r.stderr);
  return JSON.parse(r.stdout.slice(r.stdout.indexOf('{')));
}

const cases = [
  { skill: 'nested-gameplay-loop-architecture', fixture: 'nested-gameplay-loop-architecture.example.json', key: 'nested_gameplay_loop_architecture',
    declared: ['drought_threshold_seconds', 'excessive_retention_threshold', 'retention_pressure_target'] },
  { skill: 'committed-risk-reward-actions', fixture: 'risk-reward-actions.example.json', key: 'risk_reward_actions',
    declared: ['dominance_damage_ratio', 'hurtbox_exposure_ratio'] },
];

for (const c of cases) {
  test(`thresholds: ${c.skill} executor defaults match threshold-provenance.json`, () => {
    const out = runWithoutDeclarations(c.skill, c.fixture, c.key, c.declared);
    const expected = calib.thresholds[c.skill];
    for (const [name, entry] of Object.entries(expected)) {
      const actual = out.results.thresholds[name];
      assert.ok(actual, `executor does not report threshold ${name}`);
      assert.strictEqual(actual.value, entry.value, `${name}: executor default ${actual.value} != calibration ${entry.value}`);
      assert.strictEqual(actual.declared_in_model, false, `${name} should be undeclared in this run`);
      assert.strictEqual(actual.epistemic_status, 'heuristic', `${name} must be labelled heuristic`);
    }
  });
}

test('thresholds: every spec_source still appears in its SKILL.md', () => {
  for (const [skill, entries] of Object.entries(calib.thresholds)) {
    const md = fs.readFileSync(path.join(root, 'GD-Skill-Codex', skill, 'SKILL.md'), 'utf8');
    for (const [name, entry] of Object.entries(entries)) {
      if (entry.spec_source === null) continue;
      assert.ok(md.includes(entry.spec_source.contains),
        `${skill}.${name}: SKILL.md no longer contains "${entry.spec_source.contains}" (spec drift)`);
    }
  }
});

test('thresholds: drought default equals the upper bound of the meso band in minutes', () => {
  const md = fs.readFileSync(path.join(root, 'GD-Skill-Codex', 'nested-gameplay-loop-architecture', 'SKILL.md'), 'utf8');
  const band = md.match(/T_\{\\text\{meso\}\} \\in \[(\d+)\\text\{min\}, (\d+)\\text\{min\}\]/);
  assert.ok(band, 'meso band not found in SKILL.md');
  assert.strictEqual(Number(band[2]) * 60, calib.thresholds['nested-gameplay-loop-architecture'].drought_threshold_seconds.value);
});
