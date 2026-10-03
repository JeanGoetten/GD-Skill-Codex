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
const HOST = process.env.HOST || "127.0.0.1";
const MAX_BODY_BYTES = 1024 * 1024;
const MAX_REPEATS = 50;
const SECURITY_HEADERS = {
  "Content-Security-Policy": "default-src 'self'; style-src 'self' 'unsafe-inline'; script-src 'self'; img-src 'self' data:; base-uri 'none'; frame-ancestors 'none'",
  "Referrer-Policy": "no-referrer",
  "X-Content-Type-Options": "nosniff",
  "X-Frame-Options": "DENY",
};

class RequestError extends Error {}

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
  const relative = path.relative(WEB_DIR, target);
  if (relative.startsWith("..") || path.isAbsolute(relative)) {
    res.writeHead(403, SECURITY_HEADERS);
    res.end("Forbidden");
    return;
  }
  fs.readFile(target, (err, data) => {
    if (err) {
      res.writeHead(404, SECURITY_HEADERS);
      res.end("Not found");
      return;
    }
    res.writeHead(200, { ...SECURITY_HEADERS, "Content-Type": MIME[path.extname(target)] || "text/plain" });
    res.end(data);
  });
}

function runSimulation(input) {
  if (!input || typeof input !== "object" || Array.isArray(input)) {
    throw new RequestError("request body must be a JSON object");
  }
  const allowedKeys = new Set(["worldModel", "executor", "seed", "repeats"]);
  const unknownKeys = Object.keys(input).filter((key) => !allowedKeys.has(key));
  if (unknownKeys.length) throw new RequestError(`unknown request fields: ${unknownKeys.join(", ")}`);
  const { worldModel, executor, seed, repeats } = input;
  if (worldModel !== undefined && typeof worldModel !== "string") {
    throw new RequestError("worldModel must be a string");
  }
  if (executor !== undefined && typeof executor !== "string") {
    throw new RequestError("executor must be a string");
  }
  if (seed !== undefined && !Number.isSafeInteger(seed)) {
    throw new RequestError("seed must be a safe integer");
  }
  const allowedModels = new Set(listJsonDir(EXAMPLES_DIR, "architecture/examples").map((item) => item.path));
  const selectedModel = worldModel || "architecture/examples/state-system.example.json";
  if (path.isAbsolute(selectedModel) || !allowedModels.has(selectedModel)) {
    throw new RequestError("worldModel must be one of the listed architecture/examples fixtures");
  }
  const worldAbs = path.join(REPO_ROOT, selectedModel);
  const execId = executor || "discrete-state-machine-verification";
  if (!listExecutors().includes(execId)) throw new RequestError("executor is not in the local allowlist");
  const s = seed === undefined ? 42 : seed;
  if (repeats !== undefined && (!Number.isInteger(repeats) || repeats < 1 || repeats > MAX_REPEATS)) {
    throw new RequestError(`repeats must be an integer between 1 and ${MAX_REPEATS}`);
  }
  const r = repeats === undefined ? 3 : repeats;
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
    timeout: 30000,
  });
  return JSON.parse(stdout.replace(/^\uFEFF/, "").trim());
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = "";
    let size = 0;
    req.on("data", (chunk) => {
      size += chunk.length;
      if (size > MAX_BODY_BYTES) {
        reject(new RequestError("request body exceeds 1 MiB"));
        req.destroy();
        return;
      }
      raw += chunk;
    });
    req.on("end", () => {
      try {
        resolve(raw ? JSON.parse(raw) : {});
      } catch {
        reject(new RequestError("invalid JSON body"));
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
    res.writeHead(200, { ...SECURITY_HEADERS, "Content-Type": "application/json" });
    res.end(JSON.stringify(payload));
    return;
  }
  if (req.method === "POST" && url.pathname === "/api/simulate") {
    try {
      const body = await readBody(req);
      const report = runSimulation(body);
      res.writeHead(200, { ...SECURITY_HEADERS, "Content-Type": "application/json" });
      res.end(JSON.stringify(report));
    } catch (err) {
      res.writeHead(err instanceof RequestError ? 400 : 500, { ...SECURITY_HEADERS, "Content-Type": "application/json" });
      res.end(JSON.stringify({ error: String(err.message || err) }));
    }
    return;
  }
  if (req.method === "GET") {
    serveStatic(req, res, url.pathname);
    return;
  }
  res.writeHead(405, SECURITY_HEADERS);
  res.end("Method not allowed");
});

server.listen(PORT, HOST, () => {
  console.log(`Server rodando em http://${HOST}:${PORT}`);
});
