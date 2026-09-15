const http = require("http");
const fs = require("fs");
const path = require("path");
const { execFileSync } = require("child_process");

const WEB_DIR = __dirname;
const REPO_ROOT = path.resolve(__dirname, "..");
const EXAMPLES_DIR = path.join(REPO_ROOT, "architecture", "examples");
const EXECUTORS_DIR = path.join(REPO_ROOT, "architecture", "executors");
const SIM_RUNNER = path.join(REPO_ROOT, "architecture", "simulation_runner.ps1");
const PORT = process.env.PORT || 3000;

const MIME = {
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
};

function listJsonDir(dir, prefix) {
  if (!fs.existsSync(dir)) return [];
  return fs
    .readdirSync(dir)
    .filter((f) => f.endsWith(".json") && f.includes(".example."))
    .map((f) => ({ id: f, path: prefix + "/" + f }));
}

function listExecutors() {
  if (!fs.existsSync(EXECUTORS_DIR)) return [];
  return fs
    .readdirSync(EXECUTORS_DIR)
    .filter((f) => f.endsWith(".ps1"))
    .map((f) => f.replace(/\.ps1$/, ""));
}

function serveStatic(req, res, urlPath) {
  let rel = urlPath === "/" ? "index.html" : urlPath.replace(/^\/+/, "");
  const target = path.normalize(path.join(WEB_DIR, rel));
  if (!target.startsWith(WEB_DIR)) {
    res.writeHead(403);
    res.end("Forbidden");
    return;
  }
  fs.readFile(target, (err, data) => {
    if (err) {
      res.writeHead(404);
      res.end("Not found");
      return;
    }
    res.writeHead(200, { "Content-Type": MIME[path.extname(target)] || "text/plain" });
    res.end(data);
  });
}

function runSimulation({ worldModel, executor, seed, repeats }) {
  const worldAbs = worldModel && !path.isAbsolute(worldModel)
    ? path.join(REPO_ROOT, worldModel.replace(/^\/+/, ""))
    : worldModel || path.join(EXAMPLES_DIR, "state-system.example.json");
  const execId = executor || "discrete-state-machine-verification";
  const s = Number.isFinite(seed) ? seed : 42;
  const r = Number.isInteger(repeats) && repeats > 0 ? repeats : 3;
  const args = [
    "-NoProfile",
    "-ExecutionPolicy",
    "Bypass",
    "-File",
    SIM_RUNNER,
    "-WorldModelPath",
    worldAbs,
    "-ExecutorId",
    execId,
    "-Seed",
    String(s),
    "-Repeats",
    String(r),
  ];
  const stdout = execFileSync("powershell.exe", args, {
    encoding: "utf8",
    maxBuffer: 64 * 1024 * 1024,
    windowsHide: true,
  });
  return JSON.parse(stdout.replace(/^\uFEFF/, "").trim());
}

function readBody(req) {
  return new Promise((resolve) => {
    let raw = "";
    req.on("data", (chunk) => (raw += chunk));
    req.on("end", () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch {
        resolve({});
      }
    });
  });
}

const server = http.createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${PORT}`);
  if (req.method === "GET" && url.pathname === "/api/options") {
    const payload = {
      worldModels: listJsonDir(EXAMPLES_DIR, "architecture/examples"),
      executors: listExecutors(),
      simRunner: "architecture/simulation_runner.ps1",
    };
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(payload));
    return;
  }
  if (req.method === "POST" && url.pathname === "/api/simulate") {
    try {
      const body = await readBody(req);
      const report = runSimulation(body);
      res.writeHead(200, { "Content-Type": "application/json" });
      res.end(JSON.stringify(report));
    } catch (err) {
      res.writeHead(500, { "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: String(err.message || err) }));
    }
    return;
  }
  if (req.method === "GET") {
    serveStatic(req, res, url.pathname);
    return;
  }
  res.writeHead(405);
  res.end("Method not allowed");
});

server.listen(PORT, () => {
  console.log("Server rodando em http://localhost:" + PORT);
});