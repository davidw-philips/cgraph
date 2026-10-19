# cgraph

**Pre-indexed code knowledge graph skill for AI agents.** cgraph wraps [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) as a copilot skill, providing local, auto-syncing code indexing for Claude Code, GitHub Copilot, Cursor, Gemini, and other AI agents.

## Why cgraph?

- **Fewer tokens**: Query indexed code structure instead of sending raw files to the LLM
- **Fewer tool calls**: Get all related code in one request (cross-file resolution, dependencies, class hierarchies)
- **100% local**: No cloud indexing, no API calls, no privacy concerns
- **Auto-sync**: The graph updates automatically when you save files—zero manual refresh

## Quick Start

### 1. Install

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell)
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex

# or via npm
npm i -g @colbymchenry/codegraph
```

See [INSTALL.md](./INSTALL.md) for detailed setup and agent integration.

### 2. Initialize in Your Project

```bash
cd your-project
codegraph init
```

This creates `.codegraph/` with the full code graph for your repository. Auto-sync watches for changes.

### 3. Query the Graph

Once the skill is active in your agent, use:

```
Graph Query: Find all functions that call fetchUser
Graph Query: Show the class hierarchy for MyController
Graph Query: List unused exports in src/utils.ts
```

## Supported Agents

- Claude Code (VS Code)
- GitHub Copilot (VS Code, Copilot CLI, JetBrains)
- Cursor
- Gemini CLI / Codex CLI
- OpenCode
- Hermes Agent
- AntiGravity IDE
- Kiro

## How It Works

1. **Daemon**: cgraph runs as a lightweight daemon on your machine
2. **Indexing**: Initial `codegraph init` builds the graph; file watcher syncs on changes
3. **Skill Integration**: This skill exposes graph query tools to your agent
4. **Context Injection**: Use tool calls to inject relevant code sections without token waste

## File Structure

```
.codegraph/
├── graph.bin          # The indexed knowledge graph (binary)
├── metadata.json      # Language support, file count, last sync
└── .cgignore          # Patterns to exclude from indexing
```

## Providers & Compatibility

| Provider | Status | Notes |
|----------|--------|-------|
| Claude Code | ✅ | Full MCP server integration |
| GitHub Copilot | ✅ | VS Code, Copilot CLI, JetBrains |
| Cursor | ✅ | Native MCP support |
| Gemini CLI | ✅ | Custom tool wrapper |
| Hermes Agent | ✅ | Tool endpoint integration |
| OpenCode | ✅ | REST API wrapper available |

See [SKILL.md](./SKILL.md) for provider-specific configuration.

## Supported Languages

Full structural extraction and cross-file resolution for:

- TypeScript / JavaScript
- Python
- Go
- Rust
- Java / Kotlin
- C / C++
- C#
- Ruby
- PHP
- Swift
- Objective-C
- And more—see `codegraph --help`

## Configuration

### Exclude Paths

Create `.cgignore` in your project root:

```
node_modules
.git
build/
dist/
vendor/
```

### Environment Variables

```bash
# Enable debug logging
CODEGRAPH_DEBUG=1

# Custom daemon port (default: 6969)
CODEGRAPH_PORT=7000

# Custom .codegraph directory location
CODEGRAPH_HOME=/custom/path
```

## Process Management

The skill automatically:
- Starts the codegraph daemon on first query (if not running)
- Keeps it alive while the agent session is active
- Gracefully stops it when no queries have been issued for 10 minutes

For manual control:

```bash
# Start daemon explicitly
codegraph daemon start

# Stop daemon
codegraph daemon stop

# Check status
codegraph daemon status
```

## Tools Exposed

| Tool | Purpose |
|------|---------|
| `graph_query` | Free-text search across the code graph |
| `graph_find_functions` | Find all functions by name or pattern |
| `graph_find_classes` | Find class/interface definitions and hierarchy |
| `graph_show_dependencies` | Show import dependencies for a file or symbol |
| `graph_list_exports` | List all public exports from a module |
| `graph_find_callers` | Find all functions that call a specific function |
| `graph_find_implementations` | Find all implementations of an interface/base class |

## Performance

- **First index**: 30s–2m depending on repo size
- **Incremental updates**: <100ms per file change
- **Query latency**: <50ms average
- **Memory footprint**: ~100MB–500MB depending on code size

## Troubleshooting

### Index Is Out of Sync

```bash
codegraph reinit
```

This rebuilds the graph from scratch while preserving `.cgignore` settings.

### Daemon Won't Start

```bash
# Check logs
codegraph daemon logs

# Try restarting
codegraph daemon restart
```

### Too Many Files Being Indexed

Update `.cgignore` or set `exclude` patterns in `.codegraph/config.json`.

## License

cgraph wraps [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph), which is published under its own license. This skill packaging is public domain.

## See Also

- [INSTALL.md](./INSTALL.md) — Agent-specific setup instructions
- [SKILL.md](./SKILL.md) — Provider integration details
- [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) — Original project
