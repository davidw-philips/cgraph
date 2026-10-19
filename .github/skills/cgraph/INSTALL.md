# Install `codegraph`

```bash
# macOS / Linux — no Node.js required, bundles its own runtime
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell) — no Node.js required
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex

codegraph install   # wire into your agent (one-time, per machine)
codegraph init       # build the graph for the current project (one-time, per project)
```

Alternative (npm, requires Node.js):

```bash
npm i -g @colbymchenry/codegraph
```

## Node.js Prerequisite (npm install or library embedding only)

The CLI/MCP server above needs **no Node.js at all** — skip this section unless you chose the npm install, or you're embedding CodeGraph's library API (`import CodeGraph from '@colbymchenry/codegraph'`, which requires **Node 22.5+** for its built-in `node:sqlite`).

Check your current runtime:

```powershell
# Windows
irm https://raw.githubusercontent.com/davidw-philips/cgraph/main/installers/check-node.ps1 | iex
```

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/davidw-philips/cgraph/main/installers/check-node.sh | bash
```

Install/upgrade Node.js via NVM if the check reports it's missing or too old:

```powershell
# Windows (run as Administrator)
irm https://raw.githubusercontent.com/davidw-philips/cgraph/main/installers/install-nvm.ps1 | iex
```

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/davidw-philips/cgraph/main/installers/install-nvm.sh | bash
```

Both install NVM, then Node.js v22.5.0.

See the full [INSTALL.md](https://github.com/davidw-philips/cgraph/blob/main/INSTALL.md) in the `cgraph` skill bundle repo for the complete guide, troubleshooting, and configuration reference.
