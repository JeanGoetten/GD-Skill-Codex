'use strict';
// Smoke test for mcp/server.js over stdio: handshake, tool listing, one successful call,
// one blocked call, and an unknown method. Run: node --test architecture/tests/mcp_smoke.test.js
const test = require('node:test');
const assert = require('node:assert');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const server = path.resolve(__dirname, '..', '..', 'mcp', 'server.js');
const send = (lines) => spawnSync(process.execPath, [server], { input: lines.join('\n') + '\n', encoding: 'utf8' }).stdout
  .trim().split('\n').map((l) => JSON.parse(l));

const req = (id, method, params) => JSON.stringify({ jsonrpc: '2.0', id, method, params: params || {} });

test('mcp: handshake and tool listing', () => {
  const [init, list] = send([req(1, 'initialize'), req(2, 'tools/list')]);
  assert.strictEqual(init.result.serverInfo.name, 'gd-skill-codex');
  assert.ok(init.result.capabilities.tools);
  const names = list.result.tools.map((t) => t.name);
  for (const n of ['list_skills', 'get_skill', 'route_request', 'validate_world_model', 'execute_skill', 'run_pipeline']) {
    assert.ok(names.includes(n), `missing tool ${n}`);
  }
});

test('mcp: list_skills returns the 15 registered skills', () => {
  const [res] = send([req(1, 'tools/call', { name: 'list_skills', arguments: {} })]);
  assert.strictEqual(JSON.parse(res.result.content[0].text).length, 15);
});

test('mcp: execute_skill blocks an invalid world model instead of running it', () => {
  const [res] = send([req(1, 'tools/call', { name: 'execute_skill', arguments: { skill_id: 'nested-gameplay-loop-architecture', world: { version: '1.0.0' } } })]);
  const body = JSON.parse(res.result.content[0].text);
  assert.strictEqual(body.status, 'blocked');
  assert.ok(body.errors.length > 0);
});

test('mcp: unknown method returns JSON-RPC method-not-found', () => {
  const [res] = send([req(1, 'nope')]);
  assert.strictEqual(res.error.code, -32601);
});
