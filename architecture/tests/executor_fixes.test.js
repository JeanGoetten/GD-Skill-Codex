'use strict';
// Regression tests for spec <-> executor divergences found in the design review.
// Run: node --test architecture/tests/
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..', '..');
const ps = process.platform === 'win32' ? 'powershell.exe' : 'pwsh';

function runExecutor(skillId, fixtureName, mutate) {
  const world = JSON.parse(fs.readFileSync(path.join(root, 'architecture', 'examples', fixtureName), 'utf8').replace(/^\uFEFF/, ''));
  if (mutate) mutate(world.hidden_state);
  const tmp = path.join(fs.mkdtempSync(path.join(os.tmpdir(), 'gd-codex-')), 'world.json');
  fs.writeFileSync(tmp, JSON.stringify(world));
  const exe = path.join(root, 'architecture', 'executors', `${skillId}.ps1`);
  const r = spawnSync(ps, ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', exe, '-WorldModelPath', tmp], { encoding: 'utf8' });
  assert.strictEqual(r.status, 0, r.stderr);
  return JSON.parse(r.stdout);
}

const LOOPS = 'nested-gameplay-loop-architecture';
const LOOPS_FIXTURE = 'nested-gameplay-loop-architecture.example.json';
const RISK = 'committed-risk-reward-actions';
const RISK_FIXTURE = 'risk-reward-actions.example.json';

function alignAt120(h, intentional) {
  const m = h.nested_gameplay_loop_architecture;
  m.loops[0].completion_times_seconds = [120];
  m.loops[1].completion_times_seconds = [120];
  if (intentional) {
    m.loops[0].intentional_completion_times_seconds = [120];
    m.loops[1].intentional_completion_times_seconds = [120];
  }
}

test('loops: unplanned alignment is flagged', () => {
  const out = runExecutor(LOOPS, LOOPS_FIXTURE, (h) => alignAt120(h, false));
  assert.ok(out.results.diagnoses.some((d) => d.code === 'ALIGNED_EXIT_POINTS'));
  assert.strictEqual(out.results.temporal_interleaving.intentional_synchronizations.length, 0);
});

test('loops: declared intentional alignment is reported, not flagged', () => {
  const out = runExecutor(LOOPS, LOOPS_FIXTURE, (h) => alignAt120(h, true));
  assert.ok(!out.results.diagnoses.some((d) => d.code === 'ALIGNED_EXIT_POINTS'));
  assert.strictEqual(out.results.temporal_interleaving.intentional_synchronizations.length, 1);
});

test('loops: partially declared alignment still counts as unplanned', () => {
  const out = runExecutor(LOOPS, LOOPS_FIXTURE, (h) => {
    alignAt120(h, true);
    delete h.nested_gameplay_loop_architecture.loops[1].intentional_completion_times_seconds;
  });
  const d = out.results.diagnoses.find((x) => x.code === 'ALIGNED_EXIT_POINTS');
  assert.ok(d, 'expected ALIGNED_EXIT_POINTS');
  assert.deepStrictEqual(d.points[0].undeclared_loops, ['meso-upgrade']);
});

test('loops: drought threshold follows the SKILL.md band (>= 900 s) and is declarable', () => {
  const run = (mutate) => runExecutor(LOOPS, LOOPS_FIXTURE, (h) => {
    const meso = h.nested_gameplay_loop_architecture.loops[1];
    meso.duration_seconds = 900;
    delete meso.intermediate_rewards;
    if (mutate) mutate(h.nested_gameplay_loop_architecture);
  });
  assert.ok(run().results.diagnoses.some((d) => d.code === 'FEEDBACK_DROUGHT'));
  assert.ok(!run((m) => { m.drought_threshold_seconds = 1800; }).results.diagnoses.some((d) => d.code === 'FEEDBACK_DROUGHT'));
});

test('loops: pressure is a normalized sum over OPEN loops only', () => {
  // open: micro (w .5, p .75) and macro (w 1.5, p .3); meso completed (p 1) must drop out.
  const out = runExecutor(LOOPS, LOOPS_FIXTURE, (h) => { h.nested_gameplay_loop_architecture.loops[1].progress = 1; });
  const expected = (0.5 * 0.75 + 1.5 * 0.3) / (0.5 + 1.5);
  assert.ok(Math.abs(out.results.retention_curve.pressure_index - expected) < 1e-9);
  assert.strictEqual(out.results.retention_curve.open_loop_count, 2);
});

test('loops: thresholds are labelled as heuristics', () => {
  const out = runExecutor(LOOPS, LOOPS_FIXTURE);
  for (const t of Object.values(out.results.thresholds)) assert.strictEqual(t.epistemic_status, 'heuristic');
});

test('risk: punish window is computed from declared recovery and opponent startup', () => {
  const out = runExecutor(RISK, RISK_FIXTURE);
  const slam = out.results.punish_windows.find((w) => w.action_id === 'heavy_slam');
  const jab = out.results.punish_windows.find((w) => w.action_id === 'safe_jab');
  assert.strictEqual(slam.margin_frames, 5 - 8);
  assert.strictEqual(slam.punishable_under_declared_model, false);
  assert.strictEqual(jab.margin_frames, 12 - 8);
  assert.strictEqual(jab.punishable_under_declared_model, true);
  assert.strictEqual(jab.expected_punish_damage, 25 * 1.2);
});

test('risk: undeclared reaction baseline is no longer a silent false negative', () => {
  const out = runExecutor(RISK, RISK_FIXTURE, (h) => { delete h.risk_reward_actions.reaction_min_frames; });
  assert.strictEqual(out.status, 'partial');
  assert.ok(out.results.undeclared_inputs.reaction_min_frames.includes('heavy_slam'));
  assert.ok(!out.results.diagnoses.some((d) => d.code === 'RISKLESS_DOMINANCE'));
});

test('risk: dominance ratio is declarable and recorded as heuristic', () => {
  const strict = runExecutor(RISK, RISK_FIXTURE, (h) => { h.risk_reward_actions.dominance_damage_ratio = 5; });
  assert.ok(!strict.results.diagnoses.some((d) => d.code === 'RISKLESS_DOMINANCE'));
  assert.strictEqual(strict.results.thresholds.dominance_damage_ratio.declared_in_model, true);
  assert.strictEqual(strict.results.thresholds.dominance_damage_ratio.epistemic_status, 'heuristic');
});
