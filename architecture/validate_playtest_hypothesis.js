const fs = require("fs");
const path = require("path");
const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");

const root = __dirname;
const file = process.argv[2];
if (!file) throw new Error("Uso: node validate_playtest_hypothesis.js <hypothesis.json>");
const schema = JSON.parse(fs.readFileSync(path.join(root, "schemas", "playtest-hypothesis.schema.json"), "utf8").replace(/^\uFEFF/, ""));
const data = JSON.parse(fs.readFileSync(file, "utf8").replace(/^\uFEFF/, ""));
const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
const valid = ajv.compile(schema)(data);
const errors = [];
if (!valid) errors.push(ajv.errorsText(ajv.errors));
if (data.sample_size < 1) errors.push("sample_size deve ser positivo");
if (!data.metric || !data.protocol || !data.success_criterion) errors.push("metric, protocol e success_criterion são obrigatórios");
if (data.observations && data.observations.length > 0) errors.push("observations não pode ser usado como substituto de coleta executada");
if (errors.length) {
  errors.forEach((error) => console.error(error));
  process.exit(1);
}
console.log("OK: hipótese de playtest válida e explicitamente não observada.");
