const fs = require("fs");
const path = require("path");
const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");

const file = process.argv[2];
if (!file) throw new Error("Uso: node validate_evidence_store.js <evidence.jsonl>");
const schema = JSON.parse(fs.readFileSync(path.join(__dirname, "evidence.schema.json"), "utf8").replace(/^\uFEFF/, ""));
const lines = fs.readFileSync(file, "utf8").split(/\r?\n/).filter((line) => line.trim());
const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
const validate = ajv.compile(schema);
const failures = [];
lines.forEach((rawLine, index) => {
  const line = rawLine.replace(/^\uFEFF/, "");
  let record;
  try {
    record = JSON.parse(line);
  } catch (error) {
    failures.push(`linha ${index + 1}: JSON inválido: ${error.message}`);
    return;
  }
  if (!validate(record)) failures.push(`linha ${index + 1}: ${ajv.errorsText(validate.errors)}`);
});
if (failures.length) {
  failures.forEach((failure) => console.error(failure));
  process.exit(1);
}
console.log(`OK: ${lines.length} registros de evidência válidos.`);
