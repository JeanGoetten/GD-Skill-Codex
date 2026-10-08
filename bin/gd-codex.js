#!/usr/bin/env node
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const rt = require('../architecture/lib/runtime');

const USAGE = `gd-codex - GD-Skill-Codex runtime for humans and AI agents

Commands:
  list                                   List the 15 skills (id, formalism, hidden_state key)
  skill <id>                             Print SKILL.md path, hidden_state key, schema and minimal example
  route "<request>"                      Deterministic routing baseline (JSON)
  validate --world <file> [--skill <id>] Validate a world model (and one skill's hidden_state slice)
  execute <id> --world <file>            Run ONE executor through the SkillOutput contract
  pipeline "<request>" --world <file>    Route + execute chain with handoffs [--seed N]

Exit codes: 0 ok | 1 validation/execution problem | 2 usage error
Executors need PowerShell (Windows) or pwsh 7+ (macOS/Linux).`;

function flag(args, name) {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : undefined;
}
function loadWorld(file) {
  if (!file) { console.error('Missing --world <file>'); process.exit(2); }
  return rt.readJson(path.resolve(file));
}
const out = (o) => console.log(JSON.stringify(o, null, 2));

function main() {
  const [cmd, ...rest] = process.argv.slice(2);
  try {
    switch (cmd) {
      case 'list': return out(rt.listSkills().map(({ id, formalism, hidden_state_key }) => ({ id, formalism, hidden_state_key })));
      case 'skill': {
        if (!rest[0]) { console.error(USAGE); process.exit(2); }
        const s = rt.getSkill(rest[0]);
        return out({ id: s.id, skill_md: path.join('GD-Skill-Codex', s.id, 'SKILL.md'), hidden_state_key: s.hidden_state_key, input_schema: s.input_schema, minimal_example: s.minimal_example });
      }
      case 'route': {
        if (!rest[0]) { console.error(USAGE); process.exit(2); }
        return out(rt.route(rest[0]));
      }
      case 'validate': {
        const res = rt.validateWorldModel(loadWorld(flag(rest, '--world')), flag(rest, '--skill'));
        out(res);
        process.exit(res.valid ? 0 : 1);
        break;
      }
      case 'execute': {
        if (!rest[0]) { console.error(USAGE); process.exit(2); }
        const world = loadWorld(flag(rest, '--world'));
        const check = rt.validateWorldModel(world, rest[0]);
        if (!check.valid) { out({ skill_id: rest[0], status: 'blocked', errors: check.errors }); process.exit(1); }
        const res = rt.executeSkill(rest[0], world);
        out(res);
        process.exit(['failed'].includes(res.status) ? 1 : 0);
        break;
      }
      case 'pipeline': {
        if (!rest[0]) { console.error(USAGE); process.exit(2); }
        return out(rt.runPipeline(rest[0], loadWorld(flag(rest, '--world')), Number(flag(rest, '--seed') || 0)));
      }
      case undefined: case '-h': case '--help': console.log(USAGE); return;
      default: console.error(`Unknown command: ${cmd}\n\n${USAGE}`); process.exit(2);
    }
  } catch (e) {
    console.error(`ERROR: ${e.message}`);
    process.exit(1);
  }
}
main();
