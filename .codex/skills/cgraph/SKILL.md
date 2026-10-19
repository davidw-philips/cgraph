---
name: cgraph
description: 'Pre-indexed local code knowledge graph for navigating and understanding codebase structure (symbols, call paths, dependencies, blast radius) without a grep/read loop. Use when answering "how does X work", "what calls Y", managing CodeGraph daemons/indexes across Git branches or worktrees, or surveying an unfamiliar part of the active repository. Do not use for external/public repositories not yet indexed locally, or a repository with no .codegraph/ index — run codegraph init there first, or use deepwiki for public repos instead.'
compatibility: Standard CLI/MCP install needs no runtime (bundled Node). Node.js 18+ (22.5+ for library embedding) only if installing via npm instead.
---

# CodeGraph (`codegraph`)

`codegraph` builds and maintains a local, auto-syncing knowledge graph (SQLite) of every symbol, call edge, and dependency in a codebase. Once initialized, your agent answers structural questions directly from the graph via the `codegraph_explore` MCP tool — in one call, with zero file reads — instead of a grep/read loop.

## When to Use

- Answering "How does X work?", "How does X reach Y?", or surveying an unfamiliar area of the **active** repository.
- Finding callers/callees of a function, tracing call paths, or scoping the blast radius of a change.
- Starting up, managing, or stopping CodeGraph background daemons and environment processes.
- Navigating and maintaining graph indexes across Git branches, rebases, and Git worktrees.
- Any question you'd otherwise answer by grepping or reading several files to rebuild structure by hand.

Do NOT use it for a repository with no `.codegraph/` index yet (run `codegraph init` first) or for external/public repos you haven't indexed locally — prefer the `deepwiki` skill for those.

## Pre-flight Check

```bash
command -v codegraph || Get-Command codegraph
```

If missing, see [INSTALL.md](INSTALL.md), or install directly with:

```bash
# macOS / Linux — no Node.js required, bundles its own runtime
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh

# Windows (PowerShell) — no Node.js required
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
```

This is all most environments need — skip straight to **Workflow & Starting Up** below. Only use the bundled `scripts/` (see [INSTALL.md](INSTALL.md)) if you specifically need the npm install path or CodeGraph's Node library API.

## Workflow & Starting Up

### 1. One-Time Setup per Machine
Wire CodeGraph into this agent (confirms before changing anything):

```bash
codegraph install
```

### 2. First-Time Setup per Project
Build the graph for the active project (creates `.codegraph/codegraph.db`; runs full initial index):

```bash
cd your-project
codegraph init
```

### 3. Day-to-Day Startup (When Starting to Work)
You do **not** need to manually launch a daemon or background service before working:
- **Agent Sessions (MCP)**: Your AI host (VS Code Copilot, Claude Code, etc.) starts the MCP server automatically via `codegraph serve --mcp`. The server connects to or spawns a background daemon on demand, complete with an OS filesystem watcher.
- **Check Health**: Run `codegraph status` to verify index health, symbol/edge counts, and pending sync items.
- **Catch-up Sync**: If files changed while the agent was closed (e.g. pulled commits), run `codegraph sync` for an immediate fast incremental update.

### 4. Querying Structure
Your agent calls the `codegraph_explore` MCP tool itself once wired in. The same capability is available from a shell:

```bash
codegraph explore "how does X reach Y"
codegraph callers someFunction
codegraph callees someFunction
codegraph impact someSymbol
```

## Environment & Daemon Lifecycle

CodeGraph runs a background daemon (`daemon mode`) by default so multiple client sessions share a single watcher, cache, and SQLite handle.

### Turning Off Daemons
- **Interactive Stop**: Run `codegraph daemon` (or `codegraph daemons`). Select the project daemon (floats to top) or choose to stop all daemons.
- **Scripted / Non-Interactive Stop**: Daemons record their PID in `<project_root>/.codegraph/daemon.pid`. Terminate that process ID directly (or inspect `~/.codegraph/daemons/<hash>.json`).
- **Clearing Stale Locks**: If a process crashes or is terminated abruptly, clear stale locks and orphan daemon artifacts with:
  ```bash
  codegraph unlock
  ```

### Environment Toggles (Daemon & Watcher)
- **Direct Mode (No Daemon)**: Set `CODEGRAPH_NO_DAEMON=1` to force each MCP and CLI session to run as an independent, self-contained process rather than connecting to a shared daemon.
- **Disable File Watcher**: Set `CODEGRAPH_NO_WATCH=1` (or use `--no-watch` flag) to disable the live filesystem watcher. Recommended on slow filesystems (WSL2 `/mnt/` drives, network mounts) or battery-constrained setups.

### Decommissioning / Uninitializing
- **Remove from Project**: Run `codegraph uninit` to delete the `.codegraph/` index and remove Git sync hooks (`--force` skips prompt).
- **Remove from Machine**: Run `codegraph uninstall` (or `codegraph uninstall --keep-cli` to keep the CLI binary).

## Working with Git Branches & Worktrees

### Git Branch Switching (Single Working Tree)
- **Filesystem-Based Sync**: CodeGraph tracks file paths and content hashes in SQLite, not `git status`. Switching branches (`git switch <branch>` or `git checkout <branch>`) modifies files on disk; the file watcher automatically detects changes and incrementally syncs the index within ~2 seconds.
- **Manual Sync**: If the watcher was disabled or inactive during checkout, run `codegraph sync` for a fast incremental catch-up.
- **Major Rebases / Rebuilds**: After a massive rebase or branch merge with heavy conflicts, force a clean index rebuild with:
  ```bash
  codegraph index --force
  ```
- **Git Sync Hooks (When Watcher is Off)**: If `CODEGRAPH_NO_WATCH=1` is set, CodeGraph can install `post-commit`, `post-merge`, and `post-checkout` hooks that invoke background `codegraph sync` automatically after branch switches.

### Git Worktrees & The "Borrowed Index" Hazard
- **Index Discovery**: CodeGraph discovers `.codegraph/` by walking up parent directories from the current working directory.
- **The Hazard**: When using Git worktrees (e.g. `git worktree add ../feature-worktree feature`), if the worktree lacks its own `.codegraph/` directory, CodeGraph walks up and binds to the main checkout's `.codegraph/` index. Queries in the worktree will return symbols and source from the **main checkout's branch**, missing worktree-specific changes!
- **Mismatch Detection**: CodeGraph checks `detectWorktreeIndexMismatch` by comparing `git rev-parse --show-toplevel` against `indexRoot` via `git rev-parse --git-common-dir`. When a worktree borrows the main index, CodeGraph issues warnings in `codegraph status` and MCP query tools.
- **The Golden Rule for Worktrees**: **Always run `codegraph init` (or `codegraph init -i`) inside each worktree directory**. Each worktree must have its own dedicated `.codegraph/` directory to index its branch independently.
- **Custom Directory Isolation**: Set `CODEGRAPH_DIR` (e.g. `export CODEGRAPH_DIR=.codegraph-worktree`) if custom index folder naming or isolation is required (e.g. separating Windows and WSL2 checkouts).

## Rules

- Trust the graph's results — it stays in sync via a file watcher (2-second debounce after a save); don't re-verify with grep.
- Treat `codegraph_explore`'s returned source as already read; don't re-open the same file with the Read tool.
- Only query a project that has a `.codegraph/` index. A path with none returns clean guidance to use built-in tools instead — indexing stays a deliberate decision, not automatic.
- In Git worktrees, verify with `codegraph status` that the worktree has its own local index rather than borrowing the main tree's index.
- Prefer `codegraph_explore` (or `codegraph explore` from the CLI) over the narrower hidden tools (`codegraph_node`, `codegraph_search`, `codegraph_callers`, `codegraph_callees`, `codegraph_impact`, `codegraph_files`, `codegraph_status`) — everything they return already arrives inline on `codegraph_explore`.

See [INSTALL.md](INSTALL.md) for installation options, including the bundled Node.js checker/installer scripts in `scripts/`, needed only for the npm install path or library embedding.
