'use strict';
// The skeleton in architecture/world-model-extraction.md must validate against the world-model
// schema, and the guide must name every required top-level key. Run:
//   node --test architecture/tests/extraction_guide.test.js
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const rt = require('../lib/runtime');

const guide = fs.readFileSync(path.join(__dirname, '..', 'world-model-extraction.md'), 'utf8');
const schema = rt.readJson(path.join(__dirname, '..', 'world-model.schema.json'));
const skeleton = JSON.parse(guide.match(/```json\n([\s\S]*?)\n```/)[1]);

test('guide: names every required top-level key of the schema', () => {
  for (const key of schema.required) {
    assert.ok(guide.includes('`' + key + '`'), `guide does not mention required key ${key}`);
  }
});

test('guide: skeleton has exactly the required keys', () => {
  assert.deepStrictEqual(Object.keys(skeleton).sort(), [...schema.required].sort());
});

test('guide: skeleton validates against the world-model schema', () => {
  const res = rt.validateWorldModel(skeleton);
  assert.ok(res.valid, 'skeleton is invalid:\n' + res.errors.join('\n'));
});
