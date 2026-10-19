---
name: cgraph
description: Pre-indexed local code knowledge graph for navigating and understanding a codebase's structure (symbols, call paths, dependencies, blast radius) without a grep/read loop. Use when answering "how does X work", "what calls Y", or surveying an unfamiliar part of the active repository. Do not use for external/public repositories not yet indexed locally, or a repository with no `.codegraph/` index — run `codegraph init` there first, or use the deepwiki skill for public repos instead.
---

# CodeGraph (`codegraph`)

`codegraph` builds and maintains a local, auto-syncing knowledge graph (SQLite) of every symbol, call edge, and dependency in a codebase. Once initialized, your agent answers structural questions directly from the graph via the `codegraph_explore` MCP tool — in one call, with zero file reads — instead of a grep/read loop.

## When to Use

- "How does X work?", "How does X reach Y?", or surveying an unfamiliar area of the **active** repository.
- Finding callers/callees of a function, tracing a call path, or scoping the blast radius of a change.
- Any question you'd otherwise answer by grepping or reading several files to rebuild structure by hand.

Do NOT use it for a repository with no `.codegraph/` index yet (run `codegraph init` first) or for external/public repos you haven't indexed locally — prefer the `deepwiki` skill for those.

## Pre-flight Check

```bash
command -v codegraph || Get-Command codegraph
```

If missing, see [INSTALL.md](INSTALL.md), or install with:

```bash
# macOS / Linux — no Node.js required, bundles its own runtime
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell) — no Node.js required
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
```

## Workflow

1. Wire CodeGraph into this agent, once per machine (confirms before changing anything):

```bash
codegraph install
```

2. Build the graph for the active project, once per project (creates `.codegraph/codegraph.db`; a background watcher keeps it synced afterward — no re-running needed):

```bash
codegraph init
```

3. Answer structural questions directly — your agent calls the `codegraph_explore` MCP tool itself once wired in (it receives usage guidance automatically from the MCP server). The same capability is available from a shell:

```bash
codegraph explore "how does X reach Y"
codegraph callers someFunction
codegraph callees someFunction
codegraph impact someSymbol
```

## Rules

- Trust the graph's results — it stays in sync via a file watcher (2-second debounce after a save); don't re-verify with grep.
- Treat `codegraph_explore`'s returned source as already read; don't re-open the same file with the Read tool.
- Only query a project that has a `.codegraph/` index. A path with none returns clean guidance to use built-in tools instead — indexing stays a deliberate decision, not automatic.
- Prefer `codegraph_explore` (or `codegraph explore` from the CLI) over the narrower hidden tools (`codegraph_node`, `codegraph_search`, `codegraph_callers`, `codegraph_callees`, `codegraph_impact`, `codegraph_files`, `codegraph_status`) — everything they return already arrives inline on `codegraph_explore`.

See [INSTALL.md](INSTALL.md) for installation options, including the Node.js checker needed only for the npm install path or library embedding.
