'use strict';
// Single cross-platform entry point for the full gate. Stops at the first failing step.
// Steps that need PowerShell are skipped with a warning when no shell is available,
// so the Node-only checks still run on Linux/macOS. CI on Windows runs all of them.
const { spawnSync } = require('node:child_process');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const hasPwsh = (() => {
  for (const exe of process.platform === 'win32' ? ['powershell.exe', 'pwsh'] : ['pwsh']) {
    if (spawnSync(exe, ['-NoProfile', '-Command', 'exit 0']).status === 0) return exe;
  }
  return null;
})();

const steps = [
  { name: 'schemas + fixtures (AJV)', cmd: process.execPath, args: ['architecture/validate_json_schema.js'] },
  { name: 'How to Execute sections in sync', cmd: process.execPath, args: ['architecture/sync_skill_runtime.js', '--check'] },
  { name: 'executor regression tests', cmd: process.execPath, args: ['--test', 'architecture/tests/executor_fixes.test.js'] },
  { name: 'MCP server smoke test', cmd: process.execPath, args: ['architecture/tests/mcp_smoke.test.js'] },
  { name: 'skill front matter / headings', shell: true, needsPs: true, ps: './validate_skills.ps1' },
  { name: 'architecture aggregate (fixtures, cross-skill, playtest)', shell: true, needsPs: true, ps: './architecture/validate_all.ps1' },
];

let failed = 0;
for (const step of steps) {
  if (step.needsPs && !hasPwsh) {
    console.log(`SKIP: ${step.name} (no PowerShell on this machine)`);
    continue;
  }
  let r;
  if (step.needsPs) {
    r = spawnSync(hasPwsh, ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', path.join(root, step.ps)], { cwd: root, encoding: 'utf8', stdio: 'inherit' });
  } else {
    r = spawnSync(step.cmd, step.args, { cwd: root, encoding: 'utf8', stdio: 'inherit' });
  }
  if (r.status !== 0) {
    console.error(`FAIL: ${step.name} (exit ${r.status})`);
    failed++;
    break;
  }
  console.log(`PASS: ${step.name}`);
}
process.exit(failed ? 1 : 0);
