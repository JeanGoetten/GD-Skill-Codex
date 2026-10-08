'use strict';
// Generates / refreshes the "How to Execute" section in each SKILL.md from
// architecture/executor-manifest.json. Idempotent: replaces only the block between markers.
//   node architecture/sync_skill_runtime.js          -> write
//   node architecture/sync_skill_runtime.js --check  -> exit 1 if any SKILL.md is out of date
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..');
const manifest = JSON.parse(fs.readFileSync(path.join(__dirname, 'executor-manifest.json'), 'utf8').replace(/^\uFEFF/, '')).skills;
const checkOnly = process.argv.includes('--check');
const START = '<!-- gd-codex:how-to-execute:start -->';
const END = '<!-- gd-codex:how-to-execute:end -->';

function block(id, m) {
  return [
    START,
    '## How to Execute',
    '',
    'This skill has a deterministic reference executor. Use it for the structural checks; the reasoning in the sections above still applies to interpreting the results.',
    '',
    '1. Read this file and check `hidden_state.' + m.hidden_state_key + '` against the input schema: `architecture/schemas/' + m.schema + '`.',
    '2. Validate: `node bin/gd-codex.js validate --world <world.json> --skill ' + id + '`.',
    '3. Run: `node bin/gd-codex.js execute ' + id + ' --world <world.json>`, or the MCP tool `execute_skill`.',
    '4. If the slice is missing, do not invent values. Declare the unknowns or answer `INSUFFICIENT_EVIDENCE`.',
    '',
    'Minimal valid example: `architecture/examples/' + m.fixture + '`.',
    END,
    '',
  ].join('\n');
}

let stale = 0;
for (const [id, m] of Object.entries(manifest)) {
  const file = path.join(root, 'GD-Skill-Codex', id, 'SKILL.md');
  const original = fs.readFileSync(file, 'utf8');
  const section = block(id, m);
  let next;
  const s = original.indexOf(START);
  const e = original.indexOf(END);
  if (s >= 0 && e > s) {
    next = original.slice(0, s) + section.trimEnd() + original.slice(e + END.length);
  } else {
    next = original.replace(/\s*$/, '\n\n') + section;
  }
  if (next !== original) {
    stale++;
    if (checkOnly) console.error(`STALE: ${id}/SKILL.md`);
    else fs.writeFileSync(file, next, 'utf8');
  }
}

if (checkOnly) {
  if (stale) { console.error(`${stale} SKILL.md out of sync. Run: node architecture/sync_skill_runtime.js`); process.exit(1); }
  console.log(`OK: How to Execute sections in sync for ${Object.keys(manifest).length} skills.`);
} else {
  console.log(`OK: updated ${stale} SKILL.md file(s).`);
}
