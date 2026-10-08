#!/usr/bin/env node
'use strict';
// Minimal MCP server (stdio, JSON-RPC 2.0) exposing the GD-Skill-Codex runtime.
// No external SDK dependency: implements initialize, tools/list and tools/call.
const readline = require('node:readline');
const rt = require('../architecture/lib/runtime');

const PROTOCOL = '2024-11-05';
const SERVER = { name: 'gd-skill-codex', version: '1.0.0' };

const tools = [
  {
    name: 'list_skills',
    description: 'List the GD-Skill-Codex game-design skills with formalism and hidden_state key. Call this first to see what is available.',
    inputSchema: { type: 'object', properties: {}, additionalProperties: false },
  },
  {
    name: 'get_skill',
    description: 'Return the SKILL.md protocol, hidden_state key, input schema and a minimal valid example for one skill. Read this before executing or declaring a world model.',
    inputSchema: { type: 'object', required: ['skill_id'], properties: { skill_id: { type: 'string' } }, additionalProperties: false },
  },
  {
    name: 'route_request',
    description: 'Deterministically route a natural-language game-design request to candidate skills. Use as a baseline; the agent may override with reasoning.',
    inputSchema: { type: 'object', required: ['request'], properties: { request: { type: 'string', minLength: 1 } }, additionalProperties: false },
  },
  {
    name: 'validate_world_model',
    description: 'Validate a world model object against the world-model schema and, optionally, the hidden_state slice required by one skill. Returns errors; a missing slice must be declared or answered as INSUFFICIENT_EVIDENCE.',
    inputSchema: {
      type: 'object', required: ['world'],
      properties: { world: { type: 'object' }, skill_id: { type: 'string' } },
      additionalProperties: false,
    },
  },
  {
    name: 'execute_skill',
    description: 'Run one skill executor on a validated world model. Returns a SkillOutput (status, results, metrics, evidence, handoffs). Output is a structural check, not playtest evidence.',
    inputSchema: {
      type: 'object', required: ['skill_id', 'world'],
      properties: { skill_id: { type: 'string' }, world: { type: 'object' } },
      additionalProperties: false,
    },
  },
  {
    name: 'run_pipeline',
    description: 'Route a request and execute the chain of skills it activates, following handoff adapters. Returns the combined trace.',
    inputSchema: {
      type: 'object', required: ['request', 'world'],
      properties: { request: { type: 'string', minLength: 1 }, world: { type: 'object' }, seed: { type: 'integer', minimum: 0 } },
      additionalProperties: false,
    },
  },
];

function callTool(name, a) {
  switch (name) {
    case 'list_skills':
      return rt.listSkills().map(({ id, formalism, domain_role, routing_role, hidden_state_key }) => ({ id, formalism, domain_role, routing_role, hidden_state_key }));
    case 'get_skill':
      return rt.getSkill(a.skill_id);
    case 'route_request':
      return rt.route(a.request);
    case 'validate_world_model':
      return rt.validateWorldModel(a.world, a.skill_id);
    case 'execute_skill': {
      const check = rt.validateWorldModel(a.world, a.skill_id);
      if (!check.valid) return { skill_id: a.skill_id, status: 'blocked', errors: check.errors };
      return rt.executeSkill(a.skill_id, a.world);
    }
    case 'run_pipeline':
      return rt.runPipeline(a.request, a.world, a.seed || 0);
    default:
      throw Object.assign(new Error(`Unknown tool: ${name}`), { code: -32602 });
  }
}

function send(msg) { process.stdout.write(JSON.stringify(msg) + '\n'); }
function reply(id, result) { send({ jsonrpc: '2.0', id, result }); }
function fail(id, code, message) { send({ jsonrpc: '2.0', id, error: { code, message } }); }

function handle(req) {
  const { id, method, params } = req;
  if (id === undefined) return; // notifications (e.g. notifications/initialized) need no reply
  switch (method) {
    case 'initialize':
      return reply(id, { protocolVersion: PROTOCOL, capabilities: { tools: {} }, serverInfo: SERVER });
    case 'ping':
      return reply(id, {});
    case 'tools/list':
      return reply(id, { tools });
    case 'tools/call': {
      try {
        const data = callTool(params.name, params.arguments || {});
        return reply(id, { content: [{ type: 'text', text: JSON.stringify(data, null, 2) }], isError: false });
      } catch (e) {
        if (e.code === -32602) return fail(id, -32602, e.message);
        return reply(id, { content: [{ type: 'text', text: `ERROR: ${e.message}` }], isError: true });
      }
    }
    default:
      return fail(id, -32601, `Method not found: ${method}`);
  }
}

readline.createInterface({ input: process.stdin }).on('line', (line) => {
  if (!line.trim()) return;
  let req;
  try { req = JSON.parse(line); } catch { return fail(null, -32700, 'Parse error'); }
  handle(req);
});
