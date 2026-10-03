const fs = require("fs");
const path = require("path");
const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");

const root = __dirname;
const schemaDir = path.join(root, "schemas");
const readJson = (file) => JSON.parse(fs.readFileSync(file, "utf8").replace(/^\uFEFF/, ""));
const inputPath = process.argv[2];

if (!inputPath) {
  console.error("Uso: node architecture/validate_skill_output.js <skill-output.json>");
  process.exit(2);
}

const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
for (const file of fs.readdirSync(schemaDir).filter((name) => name.endsWith(".json"))) {
  ajv.addSchema(readJson(path.join(schemaDir, file)));
}

const schema = readJson(path.join(schemaDir, "skill-output.schema.json"));
const validate = ajv.getSchema(schema.$id) || ajv.compile(schema);
const output = readJson(path.resolve(inputPath));
if (!validate(output)) {
  console.error(ajv.errorsText(validate.errors, { separator: "\n" }));
  process.exit(1);
}
console.log(`OK: SkillOutput válido para ${output.skill_id}.`);
