---
id: cgraph
name: cgraph
title: Code Knowledge Graph Skill
description: Pre-indexed code knowledge graph for AI agents. Query local code structure with zero token overhead, auto-syncing on file changes.
compatible_with:
  - "Claude Code"
  - "GitHub Copilot"
  - "Cursor"
  - "Gemini CLI"
  - "Codex CLI"
  - "OpenCode"
  - "Hermes Agent"
  - "AntiGravity IDE"
  - "Kiro"
version: 1.0.0
keywords:
  - "code graph"
  - "knowledge graph"
  - "indexing"
  - "semantic search"
  - "code structure"
  - "dependencies"
  - "symbol resolution"
  - "context reduction"
---

# cgraph Skill

**Pre-indexed code knowledge graph for AI agents.** Query your codebase locally without sending entire files to the LLM. Auto-syncs on changes, zero token overhead.

## Overview

cgraph wraps the [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) CLI as a skill, exposing graph query tools to your agent. Instead of asking the LLM to search through raw code, you ask cgraph to search the indexed knowledge graph—**drastically reducing token usage** while improving accuracy.

### Why This Skill?

| Problem | cgraph Solution |
|---------|-----------------|
| Sending entire files to LLM | Query indexed structure; get only relevant code |
| Multiple tool calls per search | Get all related symbols in one graph query |
| Stale code references | Auto-sync updates graph on every file save |
| Slow multi-file searches | Cross-file resolution is pre-computed |

## Installation

See [INSTALL.md](./INSTALL.md) for full setup. Quick version:

```bash
# 1. Install CLI
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# 2. Wire into agent
codegraph install

# 3. Initialize project
cd my-project
codegraph init
```

## Tools Exposed

The skill exposes these tools to your agent:

### `graph_query(text)`

Free-text semantic search across the code graph.

**Example queries:**
- "Functions that authenticate users"
- "Classes implementing PaymentProcessor"
- "All calls to setTimeout"
- "Database schema definitions"
- "Error handling middleware"

**Input:** Natural language search query
**Output:** Matched symbols with file location, signature, and cross-references

---

### `graph_find_functions(pattern, filter_files?)`

Find all functions matching a name pattern.

**Examples:**
```json
{
  "pattern": "fetch*",
  "filter_files": ["src/api", "src/services"]
}
```

**Output:** List of functions with:
- Name and signature
- File and line range
- Call graph (what it calls, what calls it)
- Parameters and return type

---

### `graph_find_classes(pattern, filter_files?)`

Find all classes, interfaces, and types.

**Examples:**
```json
{
  "pattern": "User*",
  "filter_files": ["src/models"]
}
```

**Output:** Class definitions with:
- Hierarchy (extends, implements)
- Methods and properties
- Dependent classes
- File location

---

### `graph_show_dependencies(file_or_symbol)`

Show what a file or symbol imports and what imports it.

**Examples:**
```json
{
  "file_or_symbol": "src/utils.ts"
}
```

**Output:**
- Imports (internal and external)
- Exports
- Modules that import this
- Circular dependency warnings

---

### `graph_list_exports(module_path)`

List all public exports from a module.

**Examples:**
```json
{
  "module_path": "src/auth/index.ts"
}
```

**Output:**
- Named exports with types
- Default export (if any)
- Re-exports
- Usage count (how many internal modules use each)

---

### `graph_find_callers(function_name, recursive?)`

Find all functions that call a specific function.

**Examples:**
```json
{
  "function_name": "authenticateUser",
  "recursive": true
}
```

**Output:**
- Direct callers (immediate)
- Transitive callers (recursive=true)
- Call chain context
- File locations

---

### `graph_find_implementations(interface_or_base_class, recursive?)`

Find all implementations of an interface or subclasses.

**Examples:**
```json
{
  "interface_or_base_class": "PaymentGateway",
  "recursive": true
}
```

**Output:**
- All implementing classes
- Inheritance chain
- Override methods
- File locations

---

## Provider Integration

### Claude Code (VS Code)

**Status:** ✅ Fully Supported

**Auto-configuration:** `codegraph install` handles this.

**Manual setup:**

Add to VS Code's `settings.json` (or `.vscode/settings.json`):

```json
{
  "claude.mcpServers": {
    "cgraph": {
      "command": "node",
      "args": ["<install-path>/codegraph-mcp-server.js"],
      "env": {
        "CODEGRAPH_PORT": "6969"
      }
    }
  }
}
```

Then reload VS Code.

---

### GitHub Copilot (VS Code, Copilot CLI, JetBrains)

**Status:** ✅ Fully Supported

**For VS Code:**

Edit `.vscode/settings.json`:

```json
{
  "github.copilot.advanced": {
    "agentCapabilities": ["tools"],
    "tools": {
      "cgraph": {
        "enabled": true
      }
    }
  }
}
```

**For Copilot CLI:**

```bash
gh copilot config set tools.cgraph.enabled true
```

**For JetBrains IDEs:**

In IDE settings → Tools → GitHub Copilot → MCP Servers, add:

```
Name: cgraph
Type: Executable
Command: <codegraph-installation>/bin/codegraph-mcp-server
```

---

### Cursor

**Status:** ✅ Fully Supported

Edit Cursor settings (Cursor → Preferences → Settings):

```json
{
  "cursor.mcp.servers": {
    "cgraph": {
      "command": "codegraph",
      "args": ["mcp-server"]
    }
  }
}
```

Restart Cursor.

---

### Gemini CLI

**Status:** ✅ Fully Supported

Configure in `~/.config/gem/config.yaml`:

```yaml
tools:
  cgraph:
    type: mcp
    command: codegraph mcp-server
    env:
      CODEGRAPH_PORT: "6969"
```

---

### Codex CLI

**Status:** ✅ Fully Supported

Add to `~/.codex/config.json`:

```json
{
  "tools": {
    "cgraph": {
      "endpoint": "http://localhost:6969",
      "auth": "local"
    }
  }
}
```

---

### OpenCode

**Status:** ✅ REST API Wrapper

cgraph exposes a REST API on port 6969. Configure OpenCode to call:

```
POST http://localhost:6969/api/query
{
  "type": "graph_query",
  "input": { "text": "..." }
}
```

**Example integration:**

```javascript
const cgraphAPI = {
  async query(text) {
    const res = await fetch('http://localhost:6969/api/query', {
      method: 'POST',
      body: JSON.stringify({ type: 'graph_query', input: { text } })
    });
    return res.json();
  }
};
```

---

### Hermes Agent / Custom Agents

**Status:** ✅ Tool Endpoint Integration

Run the cgraph daemon:

```bash
codegraph daemon start --expose-rest
```

Then configure your agent to call the REST endpoint:

```yaml
tools:
  - name: "graph_query"
    type: "http"
    endpoint: "http://localhost:6969/api/query"
    method: "POST"
    schema:
      type: "object"
      properties:
        text:
          type: "string"
          description: "Search query"
```

---

### AntiGravity IDE

**Status:** ✅ MCP Server

In AntiGravity settings, add MCP server:

```json
{
  "mcp_servers": [
    {
      "name": "cgraph",
      "command": "codegraph",
      "args": ["mcp-server", "--port", "6969"]
    }
  ]
}
```

---

## Process Management

The skill manages the codegraph daemon automatically:

### Auto-Start

When you use a graph query, cgraph checks if the daemon is running. If not, it starts automatically.

### Background Daemon

The daemon runs on port 6969 (customizable via `CODEGRAPH_PORT` env var).

### Idle Shutdown

The daemon automatically stops after 10 minutes of inactivity. This prevents resource leaks while keeping startup fast.

### Manual Control

```bash
# Start daemon explicitly
codegraph daemon start

# Stop daemon
codegraph daemon stop

# Check status
codegraph daemon status

# View logs
codegraph daemon logs

# Restart
codegraph daemon restart
```

---

## Configuration

### .cgignore

Create `.cgignore` in your project root to exclude paths from indexing:

```
node_modules
build/
dist/
.git/
vendor/
__pycache__/
.venv/
*.log
```

### .codegraph/config.json

Auto-generated. Key settings:

```json
{
  "version": 1,
  "languages": ["typescript", "python", "go"],
  "exclude": ["node_modules", "build"],
  "autoSync": true,
  "daemonPort": 6969,
  "indexTimeout": 300000,
  "cacheSize": "512MB"
}
```

### Environment Variables

```bash
# Enable debug logging
export CODEGRAPH_DEBUG=1

# Custom daemon port
export CODEGRAPH_PORT=7000

# Custom index directory
export CODEGRAPH_HOME=$HOME/.local/cgraph

# Auto-sync interval (seconds)
export CODEGRAPH_SYNC_INTERVAL=2
```

---

## Supported Languages

Full structural extraction and cross-file resolution:

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
- Groovy
- Scala
- Clojure

---

## Performance

| Operation | Time |
|-----------|------|
| Initial index (small repo) | 30s–1m |
| Initial index (large repo) | 1–5m |
| Incremental sync (per file) | <100ms |
| Query latency | <50ms |
| Memory footprint | 100–500MB |

---

## Troubleshooting

### Daemon Won't Start

```bash
codegraph daemon logs
```

Check for port conflicts or permission issues.

### Index Is Out of Sync

```bash
cd my-project
codegraph reinit
```

### High Memory Usage

Update `.cgignore` to exclude large directories (e.g., `node_modules`, `build/`), then reinit:

```bash
codegraph reinit
```

### Agent Doesn't Recognize Graph Queries

1. Verify daemon is running: `codegraph daemon status`
2. Verify project is initialized: `ls -la .codegraph/`
3. Restart your agent application completely
4. Check agent logs for MCP server connection errors

### Cross-File References Missing

Ensure all files are being indexed:

```bash
cd my-project
codegraph inspect
```

This shows indexing stats. If file count seems low, check `.cgignore`.

---

## Examples

### Find All Database Calls

```
"Show me every function that queries the database, using the graph"
```

cgraph finds:
- Functions named `query*`, `fetch*`, `select*`
- Functions using the database client
- All callers of these functions

### Build Dependency Map

```
"Which modules import UserService, and what do they import from it?"
```

cgraph returns:
- All modules importing `UserService`
- Specific exports they use
- Transitive dependencies

### Refactor Safely

```
"Show me everywhere setTimeout is used and what it's inside"
```

cgraph finds:
- Every `setTimeout` call
- The enclosing function/class
- Whether it's caught/cleaned up

---

## Limitations

- **Real-time collaboration:** If multiple developers edit simultaneously, auto-sync is eventual-consistent (seconds)
- **Monorepos:** Works best with one `.codegraph/` per repo; complex setups may need custom config
- **Private modules:** Index is local; no remote sync (this is a feature!)
- **IDE integration:** Some IDEs (e.g., older VS Code versions) may not support MCP servers natively

---

## License

cgraph wraps [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph). See that project's license for terms. This skill is public domain.

## Support

- Issues: [GitHub Discussions](https://github.com/colbymchenry/codegraph/discussions)
- Docs: [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph)
- This skill: See [INSTALL.md](./INSTALL.md) for setup help

---

## See Also

- [README.md](./README.md) — Overview and quick start
- [INSTALL.md](./INSTALL.md) — Detailed installation guide
- [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) — Original project and advanced features
