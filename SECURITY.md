# Security policy

The static GitHub Pages site has no server-side execution. `web/server.js` is a
local development utility and binds to `127.0.0.1` by default.

Do not expose the local execution server to an untrusted network. It launches
PowerShell analysis processes and is designed only for trusted fixtures and
executors included in this repository.

Please report suspected vulnerabilities privately to the repository owner
before publishing exploit details. Include the affected commit, reproduction
steps, impact, and any proposed mitigation.
