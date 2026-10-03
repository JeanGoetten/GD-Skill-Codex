const fs = require("fs");
const path = require("path");
const Ajv2020 = require("ajv/dist/2020");
const addFormats = require("ajv-formats");

const root = __dirname;
const schemaDir = path.join(root, "schemas");
const readJson = (file) => JSON.parse(fs.readFileSync(file, "utf8").replace(/^\uFEFF/, ""));
const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);

for (const file of fs.readdirSync(schemaDir).filter((name) => name.endsWith(".json"))) {
  const schema = readJson(path.join(schemaDir, file));
  ajv.addSchema(schema);
}
for (const file of ["calibration.schema.json", "evidence.schema.json"]) {
  ajv.addSchema(readJson(path.join(root, file)));
}

const worldSchema = readJson(path.join(root, "world-model.schema.json"));
ajv.addSchema(worldSchema);
const validateWorld = ajv.getSchema(worldSchema.$id);
if (!validateWorld) throw new Error("world-model schema não foi compilado.");

const exampleDir = path.join(root, "examples");
const examples = fs.readdirSync(exampleDir).filter((name) => name.endsWith(".example.json"));
const failures = [];
let validated = 0;
function validateDocument(label, data, schemaId) {
  const validate = ajv.getSchema(schemaId);
  if (!validate) throw new Error(`schema não compilado: ${schemaId}`);
  if (!validate(data)) failures.push(`${label}: ${ajv.errorsText(validate.errors)}`);
}
for (const file of examples) {
  const data = readJson(path.join(exampleDir, file));
  if (!data.hidden_state || !Object.prototype.hasOwnProperty.call(data, "entities")) continue;
  validated += 1;
  if (!validateWorld(data)) failures.push(`${file}: ${ajv.errorsText(validateWorld.errors)}`);
}

validateDocument("skill-registry.json", readJson(path.join(root, "skill-registry.json")), "https://gd-skill-codex.local/schemas/skill-registry.schema.json");
validateDocument("handoffs.json", readJson(path.join(root, "handoffs.json")), "https://gd-skill-codex.local/schemas/handoffs.schema.json");
validateDocument("handoff-adapters.json", readJson(path.join(root, "handoff-adapters.json")), "https://gd-skill-codex.local/schemas/handoff-adapters.schema.json");
for (const [index, record] of readJson(path.join(root, "calibration.defaults.json")).entries()) {
  validateDocument(`calibration.defaults.json[${index}]`, record, "https://gd-skill-codex.local/calibration.schema.json");
}
validateDocument("evidence.example.json", readJson(path.join(root, "evidence.example.json")), "https://gd-skill-codex.local/evidence.schema.json");
validateDocument("playtest-hypothesis.example.json", readJson(path.join(exampleDir, "playtest-hypothesis.example.json")), "https://gd-skill-codex.local/schemas/playtest-hypothesis.schema.json");
validateDocument("playtest-observation.example.json", readJson(path.join(exampleDir, "playtest-observation.example.json")), "https://gd-skill-codex.local/schemas/playtest-observation.schema.json");

for (const file of examples) {
  const data = readJson(path.join(exampleDir, file));
  if (!data.runner || data.runner !== "architecture/simulation_runner.ps1") continue;
  const simulationSchema = readJson(path.join(schemaDir, "simulation-report.schema.json"));
  const validateSimulation = ajv.compile(simulationSchema);
  if (!validateSimulation(data)) failures.push(`${file}: ${ajv.errorsText(validateSimulation.errors)}`);
}

if (failures.length) {
  for (const failure of failures) console.error(failure);
  process.exit(1);
}
console.log(`OK: AJV validou ${validated} world models, ${examples.length} fixtures e os contratos centrais.`);
