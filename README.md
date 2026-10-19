# cgraph: CodeGraph Agent Skill Bundle

`cgraph` packages [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) — a pre-built, local code knowledge graph — as portable agent skill bundles for **GitHub Copilot**, **Claude Code**, **OpenAI Codex**, and generic agents, plus a cross-platform Node.js bootstrap for the optional npm install path.

CodeGraph parses your project with a native Rust/tree-sitter kernel into a local SQLite graph of every symbol, call edge, and dependency, then watches the filesystem to keep it in sync. Agents query it through a single MCP tool, `codegraph_explore`, and get back verbatim source, call paths, and blast-radius — in one call, with zero file reads — instead of a grep/read loop.

- **Zero cloud dependency:** everything runs and stays on your machine (local SQLite index).
- **Self-contained runtime:** the standalone installer needs **no Node.js at all** — it bundles its own runtime.
- **Auto-sync:** a background watcher (native OS file events) keeps the graph current as you edit; no manual re-indexing.
- **One strong MCP tool:** `codegraph_explore` answers almost any structural question in a single call; narrower tools (`codegraph_node`, `codegraph_search`, `codegraph_callers`, `codegraph_callees`, `codegraph_impact`, `codegraph_files`, `codegraph_status`) exist but are unlisted by default.

## Installation

### Option A — Standalone bundle (recommended, no Node.js required)

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
```

### Option B — npm (requires Node.js, any supported version for the CLI itself)

```bash
npm i -g @colbymchenry/codegraph
```

See [INSTALL.md](./INSTALL.md) for the full guide, including the Node.js compatibility checker and installer scripts in [installers/](./installers) — only needed if you choose Option B, or want to embed CodeGraph's library API (`import CodeGraph from '@colbymchenry/codegraph'`), which requires **Node 22.5+** for its built-in `node:sqlite` usage.

## Usage

```bash
# 1. Wire CodeGraph into your detected agents (one-time, machine-wide)
codegraph install

# 2. Build the graph for a project (creates .codegraph/, one step)
cd your-project
codegraph init

# 3. Ask your agent a structural question — it calls codegraph_explore itself
#    "How does a request reach the database?"
#    "What calls authenticateUser, and what does it call?"
```

Your agent starts the MCP server itself and receives `codegraph_explore` usage guidance automatically in the MCP `initialize` response — there is nothing to prompt-engineer.

## CLI Reference (selected)

```bash
codegraph install                 # Run installer (explicit)
codegraph uninstall               # Remove CodeGraph from your agents AND the CLI (--keep-cli for configs only)
codegraph init [path]             # Initialize a project + build its graph (one step)
codegraph uninit [path]           # Remove CodeGraph from a project (--force to skip prompt)
codegraph index [path]            # Full index (--force to re-index, --quiet for less output)
codegraph sync [path]             # Incremental update
codegraph status [path]           # Show statistics
codegraph query <search>          # Search symbols (--kind, --limit, --json)
codegraph explore <query>         # Same output as the codegraph_explore MCP tool, from the CLI
codegraph callers <symbol>        # Find what calls a function/method
codegraph callees <symbol>        # Find what a function/method calls
codegraph impact <symbol>         # Analyze what code is affected by changing a symbol
codegraph affected [files...]     # Find test files affected by changed source files
codegraph daemon                  # Manage background daemons — pick one to stop
codegraph upgrade [version]       # Update to the latest release (--check, --force)
codegraph help [command]          # Show help, optionally for one command
```

Run `codegraph help` or `codegraph --help` for the complete, current list — it is the single source of truth, not this file.

## MCP Tools

| Tool | Default | Purpose |
|------|---------|---------|
| `codegraph_explore` | ✅ listed | Answer almost any structural question in one call: verbatim source grouped by file, call paths between symbols (including dynamic-dispatch hops), and a blast-radius summary. |
| `codegraph_node`, `codegraph_search`, `codegraph_callers`, `codegraph_callees`, `codegraph_impact`, `codegraph_files`, `codegraph_status` | hidden | Fully functional but unlisted — everything they return already arrives inline on `codegraph_explore`. Re-enable with `CODEGRAPH_MCP_TOOLS=explore,node,search,callers,...`, or use their CLI equivalents (`codegraph node` / `query` / `callers` / `callees` / `impact` / `files` / `status`). |

## Supported Agents

Auto-detected and configured by `codegraph install`:

- Claude Code
- Cursor
- Codex CLI
- opencode
- Hermes Agent
- Gemini CLI
- Antigravity IDE
- Kiro
- GitHub Copilot — Copilot Chat in VS Code, the Copilot CLI, and the Copilot plugin in JetBrains IDEs

## Configuration

CodeGraph is zero-config by default. It automatically skips dependency/build/cache directories (`node_modules`, `dist`, `build`, `.venv`, etc.), honors your `.gitignore`, and skips files over 1MB. To customize further, add an optional `codegraph.json` at your project root:

```json
{
  "exclude": ["static/", "**/vendor/**"],
  "include": ["Tools/"],
  "deprioritize": ["scripts/"],
  "extensions": { ".tpl": "php" }
}
```

See the [upstream Configuration docs](https://github.com/colbymchenry/codegraph#configuration) for full details on `exclude`, `include`, `deprioritize`, and custom `extensions`.

## Storage

```
.codegraph/
└── codegraph.db        # Local SQLite graph (symbols, edges, files, FTS5 full-text search)
```

## Agent Skills

This repository includes portable skill bundles that document the pre-flight check, install path, and query workflow for each agent surface:

- GitHub Copilot: [.github/skills/cgraph/](.github/skills/cgraph)
- Claude Code: [.claude/skills/cgraph/](.claude/skills/cgraph)
- OpenAI Codex: [.codex/skills/cgraph/](.codex/skills/cgraph)
- Generic agents: [.agents/skills/cgraph/](.agents/skills/cgraph)

## Troubleshooting

See [INSTALL.md](./INSTALL.md#troubleshooting) and the upstream [Troubleshooting section](https://github.com/colbymchenry/codegraph#troubleshooting) for the authoritative list (daemon/lock issues, WSL2 paths, slow indexing, etc).

## Links

- Repository: [davidw-philips/cgraph](https://github.com/davidw-philips/cgraph) (this skill bundle)
- Upstream project: [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)
- Upstream documentation: [colbymchenry.github.io/codegraph](https://colbymchenry.github.io/codegraph/)

## License

This skill packaging is MIT. CodeGraph itself is published under its own license — see [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) for terms.
