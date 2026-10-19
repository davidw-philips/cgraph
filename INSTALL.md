# Installation & Setup

This guide covers installing the `codegraph` CLI, wiring it into your agent, and — only if you need it — checking and installing a compatible Node.js runtime.

## Which Install Option Do You Need?

| You want to... | Node.js required? | Use |
|---|---|---|
| Use `codegraph` as a CLI / MCP server for your agent (the common case) | **No** — the standalone installer bundles its own runtime | Option A below |
| Install via `npm i -g` instead of the standalone script | Yes, to run `npm` itself | Option B below |
| Embed CodeGraph's library API (`import CodeGraph from '@colbymchenry/codegraph'`) in your own Node app | **Yes, Node 22.5+** (uses the built-in `node:sqlite`) | Check/install Node first (see below), then Option B |

If you only need the CLI/MCP server (the normal agent use case), skip straight to **Step 1, Option A** — no Node.js setup needed at all.

## Step 0: Check Node.js Runtime (Only for Option B or Library Embedding)

If you're installing via npm, or embedding CodeGraph's library API, verify your Node.js version first. The library API specifically requires **Node 22.5+** for its built-in `node:sqlite` support.

### Check Your Current Runtime

**Windows (PowerShell):**
```powershell
.\installers\check-node.ps1
```

**macOS/Linux (Bash):**
```bash
bash ./installers/check-node.sh
```

This script reports your current Node.js version and whether it meets the minimum (v18+ to run the CLI via npm; v22.5+ if embedding the library API).

**Example output (compatible):**
```
[OK] Node.js found: v22.5.0
[OK] Version v22.5.0 is compatible (requires v18.0.0+)

Node.js runtime is ready for cgraph
```

### Install Node.js (If Needed)

If the check script indicates Node.js is missing or too old, use the NVM installer:

**Windows (PowerShell — requires Administrator):**
```powershell
.\installers\install-nvm.ps1
```

**macOS/Linux (Bash):**
```bash
bash ./installers/install-nvm.sh
```

Both scripts install NVM, then Node.js v22.5.0 (satisfying both the npm-install path and the library-embedding requirement), and activate it for your session.

**Note:** On Windows, you may need to **open a new PowerShell window** after installation for NVM to be available in your PATH.

### Use This Repo's Pinned Version (.nvmrc)

If you're developing against this skill bundle (e.g. running its tests, or CodeGraph's own library API) and have NVM installed:

```bash
nvm use
```

This switches to the version pinned in [.nvmrc](./.nvmrc) (22.5.0), keeping your environment consistent.

---

## Step 1: Install the CodeGraph CLI

### Option A: Standalone Bundle (Recommended — No Node.js Required)

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
```

CodeGraph bundles its own Node runtime — nothing to compile, no native build, works the same everywhere.

### Option B: npm

```bash
npm install -g @colbymchenry/codegraph
```

Verify installation:

```bash
codegraph version
```

**Note:** The installer places `codegraph` on your PATH but doesn't reload your current shell. Open a **new terminal** before proceeding.

---

## Step 2: Connect to Your Agent

```bash
codegraph install
```

(Shortcut: `npx @colbymchenry/codegraph` downloads and runs this in one go.)

This auto-detects and wires the CodeGraph MCP server into each supported agent it finds, after asking for confirmation. It does **not** index any code yet — that's Step 3.

**Supported agents** (auto-detected):
- Claude Code
- Cursor
- Codex CLI
- opencode
- Hermes Agent
- Gemini CLI
- Antigravity IDE
- Kiro
- GitHub Copilot — Copilot Chat in VS Code, the Copilot CLI, and the Copilot plugin in JetBrains IDEs

If your agent supports MCP but isn't auto-detected, re-run `codegraph install` after updating the CLI (`codegraph upgrade`) — new agent support ships frequently.

---

## Step 3: Initialize Your Project

```bash
cd my-project
codegraph init
```

This creates `.codegraph/codegraph.db` (a local SQLite graph) and builds the full index in one step. A background watcher then keeps it in sync as you edit — there is nothing to re-run after this.

**Time to completion:** Depends on repo size (seconds to a couple of minutes for very large repos).

---

## Step 4: Verify

Open your agent and ask a structural question about the codebase, e.g.:

```
"How does a request reach the database in this project?"
```

Your agent calls `codegraph_explore` itself — it receives usage guidance automatically from the MCP server, so there's nothing to configure. You should see it answer without first grepping or reading files one by one.

To verify from the CLI directly:

```bash
codegraph status
codegraph explore "how does X work"
```

---

## Updating

```bash
codegraph upgrade --check   # see if an update is available
codegraph upgrade           # update in place
codegraph upgrade v1.2.3    # pin a specific version
```

`codegraph upgrade` detects how you installed (standalone bundle, npm, or npx) and updates accordingly.

---

## Uninstalling

```bash
codegraph uninstall             # Remove from all agents AND uninstall the CLI
codegraph uninstall --keep-cli  # Remove only agent configurations, keep the CLI
```

This leaves each project's `.codegraph/` index untouched. Remove a project's index with:

```bash
cd my-project
codegraph uninit
```

---

## Troubleshooting

**"CodeGraph not initialized"** — Run `codegraph init` in your project directory first.

**Indexing is slow** — Check that `node_modules` and other large directories are excluded (they are, by default). Use `codegraph index --quiet` to reduce output overhead.

**MCP server not connecting** — Your agent starts the server itself; you don't launch it by hand. Make sure the project is initialized and indexed (`codegraph status`) and that the path in your MCP config is correct. If it still won't connect, re-run `codegraph install` to rewrite the config.

**MCP hits `database is locked`** — Current builds use Node's built-in `node:sqlite` in WAL mode, where concurrent reads don't block on a writer, so this shouldn't occur. If it does:
- You may be on a pre-0.9 install — reinstall to get the bundled runtime (see Step 1).
- `codegraph status` showing a `Journal:` other than `wal` means WAL couldn't be enabled on this filesystem (common on network shares and WSL2 `/mnt` paths) — move the project onto a local disk.

**Missing symbols after an edit** — The watcher auto-syncs on save (wait a couple of seconds). Run `codegraph sync` manually if needed. Confirm the file's language is supported and isn't inside a `.gitignore`'d or default-excluded directory.

**Sharing one checkout between Windows and WSL** — Don't point both at the same `.codegraph/`. Set `CODEGRAPH_DIR=.codegraph-wsl` on the WSL side and run `codegraph init` there so each OS keeps its own index.

**Windows: `codegraph` command not found after install** — Open a **new PowerShell window**; the installer does not reload your current shell's PATH.

**macOS/Linux: `codegraph` command not found after install** — Start a new terminal, or reload your shell profile (`source ~/.bashrc`, `~/.zshrc`, etc.).

See the full, authoritative [Troubleshooting section](https://github.com/colbymchenry/codegraph#troubleshooting) upstream for more (very large repos, WAL file sizing, concurrent daemon conflicts, and more).

---

## Configuration Reference

```
.codegraph/
└── codegraph.db        # Local SQLite graph (symbols, edges, files, FTS5 full-text search)

codegraph.json           # Optional, project root — exclude/include/deprioritize/extensions
.nvmrc                    # This repo's pinned Node.js version (22.5.0), for Option B / library use
```

### codegraph.json (optional)

```json
{
  "exclude": ["static/", "**/vendor/**"],
  "include": ["Tools/"],
  "deprioritize": ["scripts/"],
  "extensions": { ".tpl": "php" }
}
```

### Relevant Environment Variables

```bash
CODEGRAPH_TELEMETRY=0        # Disable anonymous usage telemetry (or: codegraph telemetry off, DO_NOT_TRACK=1)
CODEGRAPH_MCP_TOOLS=explore,node,search,callers   # Re-enable hidden MCP tools beyond codegraph_explore
CODEGRAPH_DIR=.codegraph-wsl # Use a different index directory name (e.g. to separate Windows/WSL indexes)
CODEGRAPH_NO_DAEMON=1        # Skip the shared background daemon; each MCP session runs in its own process
```

---

## Installer Scripts Reference (This Repo)

These scripts exist only to support **Option B (npm)** and **library embedding** — the standalone CLI/MCP install (Option A) needs none of them.

| Script | OS | Purpose |
|--------|-----|---------|
| `installers/check-node.ps1` | Windows | Check Node.js compatibility |
| `installers/check-node.sh` | macOS/Linux | Check Node.js compatibility |
| `installers/install-nvm.ps1` | Windows | Install NVM + Node.js 22.5.0 |
| `installers/install-nvm.sh` | macOS/Linux | Install NVM + Node.js 22.5.0 |
| `.nvmrc` | All | Pinned Node.js version (22.5.0) for this repo |

---

## Using With AI Agents (Automated Flow)

When an agent is told to use the `cgraph` skill and `codegraph` isn't yet on PATH, it can bootstrap itself:

1. Pre-flight check: `command -v codegraph || Get-Command codegraph`
2. If missing, run **Option A** (Step 1) — no Node.js check needed for this path.
3. Run `codegraph install` (Step 2), then `codegraph init` (Step 3) in the active project.
4. Start answering structural questions — the agent calls `codegraph_explore` itself.

Only fall back to the Node.js check/install scripts in `installers/` if the agent specifically needs the npm path or library embedding (Option B).

---

## What's Next?

- See the skill bundles in [.agents/skills/cgraph/](.agents/skills/cgraph), [.claude/skills/cgraph/](.claude/skills/cgraph), [.codex/skills/cgraph/](.codex/skills/cgraph), and [.github/skills/cgraph/](.github/skills/cgraph) for the condensed, agent-facing workflow.
- Check [README.md](./README.md) for the CLI/MCP reference and configuration summary.
- Review [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) — the upstream project and single source of truth for all commands and tools.
