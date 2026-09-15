const fs = require("fs");
const path = require("path");
const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");

const root = __dirname;
const readJson = (file) => JSON.parse(fs.readFileSync(file, "utf8").replace(/^\uFEFF/, ""));
const schema = readJson(path.join(root, "schemas", "simulation-report.schema.json"));
const reportPath = process.argv[2];
if (!reportPath) throw new Error("Uso: node validate_simulation_report.js <report.json>");
const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
const valid = ajv.compile(schema)(readJson(reportPath));
if (!valid) {
  console.error(ajv.errorsText(ajv.errors));
  process.exit(1);
}
console.log("OK: relatório de simulação válido.");
