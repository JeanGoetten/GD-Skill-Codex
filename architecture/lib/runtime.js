'use strict';
// Shared runtime for bin/gd-codex.js and mcp/server.js.
// Thin, dependency-light layer over the reference executors (PowerShell) and AJV.
// NOTE: executors are still PowerShell scripts. On macOS/Linux this requires `pwsh`
// (PowerShell 7+). A Node port of the executors is a separate, not-yet-done task.
const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..', '..');
const arch = path.join(root, 'architecture');
const skillsDir = path.join(root, 'GD-Skill-Codex');

const readJson = (file) => JSON.parse(fs.readFileSync(file, 'utf8').replace(/^\uFEFF/, ''));

function findShell() {
  const candidates = process.platform === 'win32' ? ['powershell.exe', 'pwsh'] : ['pwsh'];
  for (const exe of candidates) {
    const r = spawnSync(exe, ['-NoProfile', '-Command', '$PSVersionTable.PSVersion.ToString()'], { encoding: 'utf8' });
    if (r.status === 0) return exe;
  }
  return null;
}

let cachedShell;
function shell() {
  if (cachedShell === undefined) cachedShell = findShell();
  if (!cachedShell) {
    throw new Error('PowerShell not found. Install PowerShell 7 (pwsh) to run the reference executors, or apply the SKILL.md protocol manually.');
  }
  return cachedShell;
}

function runPs(scriptPath, args, opts = {}) {
  const r = spawnSync(shell(), ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptPath, ...args], {
    encoding: 'utf8', cwd: root, maxBuffer: 64 * 1024 * 1024, timeout: opts.timeoutMs || 120000,
  });
  return { status: r.status, stdout: r.stdout || '', stderr: r.stderr || '' };
}

const manifest = () => readJson(path.join(arch, 'executor-manifest.json')).skills;
const registry = () => readJson(path.join(arch, 'skill-registry.json')).skills;

function assertSkill(id) {
  if (typeof id !== 'string' || !/^[a-z0-9-]+$/.test(id) || !manifest()[id]) {
    throw new Error(`Unknown skill_id: ${String(id).slice(0, 80)}`);
  }
}

function frontMatterDescription(md) {
  const m = md.match(/^description:\s*"([\s\S]*?)"\s*$/m);
  return m ? m[1] : '';
}

function listSkills() {
  const man = manifest();
  return registry().map((s) => {
    const md = fs.readFileSync(path.join(skillsDir, s.id, 'SKILL.md'), 'utf8');
    return {
      id: s.id,
      formalism: s.formalism,
      domain_role: s.domain_role,
      routing_role: s.routing_role,
      description: frontMatterDescription(md),
      hidden_state_key: man[s.id].hidden_state_key,
    };
  });
}

function getSkill(id) {
  assertSkill(id);
  const m = manifest()[id];
  const reg = registry().find((s) => s.id === id);
  return {
    id,
    skill_md: fs.readFileSync(path.join(skillsDir, id, 'SKILL.md'), 'utf8'),
    hidden_state_key: m.hidden_state_key,
    input_schema: readJson(path.join(arch, 'schemas', m.schema)),
    minimal_example: readJson(path.join(arch, 'examples', m.fixture)).hidden_state[m.hidden_state_key],
    registry: reg,
  };
}

let ajvCache;
function ajv() {
  if (ajvCache) return ajvCache;
  const Ajv2020 = require('ajv/dist/2020');
  const addFormats = require('ajv-formats');
  const a = new Ajv2020({ allErrors: true, strict: false });
  addFormats(a);
  const dir = path.join(arch, 'schemas');
  for (const f of fs.readdirSync(dir).filter((n) => n.endsWith('.json'))) a.addSchema(readJson(path.join(dir, f)));
  for (const f of ['calibration.schema.json', 'evidence.schema.json']) a.addSchema(readJson(path.join(arch, f)));
  const world = readJson(path.join(arch, 'world-model.schema.json'));
  a.addSchema(world);
  ajvCache = { a, worldId: world.$id };
  return ajvCache;
}

function validateWorldModel(world, skillId) {
  const { a, worldId } = ajv();
  const errors = [];
  const validateWorld = a.getSchema(worldId);
  if (!validateWorld(world)) errors.push(...validateWorld.errors.map((e) => `world-model ${e.instancePath || '/'} ${e.message}`));
  if (skillId) {
    assertSkill(skillId);
    const m = manifest()[skillId];
    const slice = world && world.hidden_state && world.hidden_state[m.hidden_state_key];
    if (slice === undefined) {
      errors.push(`hidden_state.${m.hidden_state_key} is missing (required by ${skillId}). Declare it or answer INSUFFICIENT_EVIDENCE.`);
    } else {
      const schema = readJson(path.join(arch, 'schemas', m.schema));
      const v = a.getSchema(schema.$id);
      if (!v(slice)) errors.push(...v.errors.map((e) => `${m.hidden_state_key}${e.instancePath} ${e.message}`));
    }
  }
  return { valid: errors.length === 0, errors };
}

function withTempWorld(world, fn) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'gd-codex-'));
  const file = path.join(dir, 'world.json');
  fs.writeFileSync(file, JSON.stringify(world));
  try { return fn(file); } finally { fs.rmSync(dir, { recursive: true, force: true }); }
}

function parseJsonOutput(res, label) {
  if (res.status !== 0) throw new Error(`${label} failed (exit ${res.status}): ${(res.stderr || res.stdout).trim().slice(0, 1500)}`);
  const text = res.stdout.trim();
  const start = text.indexOf('{');
  if (start < 0) throw new Error(`${label} produced no JSON output.`);
  return JSON.parse(text.slice(start));
}

// Executes ONE skill through the wrapper that enforces the SkillOutput contract.
function executeSkill(skillId, world) {
  assertSkill(skillId);
  const exe = path.join(arch, 'executors', `${skillId}.ps1`);
  return withTempWorld(world, (file) =>
    parseJsonOutput(runPs(path.join(arch, 'invoke_skill_executor.ps1'), ['-ExecutorPath', exe, '-WorldModelPath', file]), `executor ${skillId}`));
}

function route(request) {
  if (typeof request !== 'string' || !request.trim()) throw new Error('request must be a non-empty string.');
  return parseJsonOutput(runPs(path.join(arch, 'route_request.ps1'), ['-Request', request]), 'router');
}

// Routing + execution chain with handoff adapters, claims and confidence propagation.
function runPipeline(request, world, seed = 0) {
  if (typeof request !== 'string' || !request.trim()) throw new Error('request must be a non-empty string.');
  return withTempWorld(world, (file) =>
    parseJsonOutput(runPs(path.join(arch, 'execute_skills.ps1'), ['-Request', request, '-WorldModelPath', file, '-Seed', String(seed | 0)], { timeoutMs: 300000 }), 'pipeline'));
}

module.exports = { root, arch, readJson, listSkills, getSkill, validateWorldModel, executeSkill, route, runPipeline, manifest, shell };
