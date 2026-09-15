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

const worldSchema = readJson(path.join(root, "world-model.schema.json"));
ajv.addSchema(worldSchema);
const validateWorld = ajv.getSchema(worldSchema.$id);
if (!validateWorld) throw new Error("world-model schema não foi compilado.");

const exampleDir = path.join(root, "examples");
const examples = fs.readdirSync(exampleDir).filter((name) => name.endsWith(".example.json"));
const failures = [];
let validated = 0;
for (const file of examples) {
  const data = readJson(path.join(exampleDir, file));
  if (!data.hidden_state || !Object.prototype.hasOwnProperty.call(data, "entities")) continue;
  validated += 1;
  if (!validateWorld(data)) failures.push(`${file}: ${ajv.errorsText(validateWorld.errors)}`);
}

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
console.log(`OK: AJV validou ${validated} world models e ${examples.length} fixtures foram inspecionadas.`);
