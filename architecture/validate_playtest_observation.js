const fs = require("fs");
const path = require("path");
const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");
const file = process.argv[2];
if (!file) throw new Error("Uso: node validate_playtest_observation.js <observation.json>");
const schema = JSON.parse(fs.readFileSync(path.join(__dirname, "schemas", "playtest-observation.schema.json"), "utf8").replace(/^\uFEFF/, ""));
const data = JSON.parse(fs.readFileSync(file, "utf8").replace(/^\uFEFF/, ""));
const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
if (!ajv.compile(schema)(data)) {
  console.error(ajv.errorsText(ajv.errors));
  process.exit(1);
}
console.log("OK: observação de playtest válida.");
