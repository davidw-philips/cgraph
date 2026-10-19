# Installation & Setup

This guide walks through installing cgraph and wiring it into your agent of choice.

## Step 1: Install the Codegraph CLI

Choose the installation method that matches your system:

### Option A: No Dependencies (Recommended)

The standalone bundle includes a self-contained Node.js runtime and works everywhere:

**macOS / Linux:**
```bash
curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex
```

### Option B: npm

If you already have Node.js installed:

```bash
npm install -g @colbymchenry/codegraph
```

Verify installation:

```bash
codegraph --version
```

**Note:** The installer places `codegraph` on your PATH but doesn't reload your shell. Open a **new terminal** before proceeding.

## Step 2: Connect to Your Agent

cgraph's `codegraph install` command detects and auto-configures your agents:

```bash
codegraph install
```

This shows you which agents were detected (Claude Code, GitHub Copilot, Cursor, etc.) and asks for confirmation before wiring in the MCP server.

**What it does:**
- Adds cgraph MCP server configuration to your agent
- Injects this skill's tool definitions
- Updates agent permissions (if prompted)
- Does **not** index any code yet

**Supported agents:**
- ✅ Claude Code (VS Code)
- ✅ GitHub Copilot (VS Code, Copilot CLI, JetBrains IDEs)
- ✅ Cursor
- ✅ Codex CLI
- ✅ Gemini CLI
- ✅ OpenCode
- ✅ Hermes Agent
- ✅ AntiGravity IDE
- ✅ Kiro

### Manual Configuration (Advanced)

If auto-detection doesn't find your agent, you can wire the MCP server manually. See provider-specific instructions in [SKILL.md](./SKILL.md).

## Step 3: Initialize Your Project

Navigate to any codebase and initialize the graph:

```bash
cd my-project
codegraph init
```

This:
1. Creates `.codegraph/` directory
2. Scans your project and indexes all code
3. Enables auto-sync—the graph updates whenever you save files

**Time to completion:** Depends on repo size (30s–2m typical).

Once `codegraph init` completes, your agent can immediately query the graph.

## Step 4: Verify in Your Agent

Open your agent (Claude Code, Copilot, etc.) and try a graph query:

```
"Show me all the functions in src/utils that call fetchUser"
```

The agent should use the cgraph tools to search the local index and return results—**without** sending your entire codebase to the LLM.

---

## Agent-Specific Setup

### Claude Code (VS Code)

1. Install cgraph CLI (Step 1)
2. Run `codegraph install` (Step 2)
3. Restart Claude Code extension
4. Initialize your project (Step 3)

The MCP server runs automatically when you use graph queries.

### GitHub Copilot (VS Code)

1. Install cgraph CLI (Step 1)
2. Run `codegraph install` and select "GitHub Copilot (VS Code)"
3. Restart VS Code
4. Initialize your project (Step 3)

Graph queries appear in Copilot's tool suggestions.

### GitHub Copilot CLI

1. Install cgraph CLI (Step 1)
2. Run `codegraph install` and select "GitHub Copilot CLI"
3. Initialize your project (Step 3)

Use `gh copilot explain` with graph queries:

```bash
cd my-project
gh copilot explain "Show functions that call fetchUser"
```

### Cursor

1. Install cgraph CLI (Step 1)
2. Run `codegraph install` and select "Cursor"
3. Restart Cursor
4. Initialize your project (Step 3)

### Gemini CLI

1. Install cgraph CLI (Step 1)
2. Run `codegraph install` and select "Gemini CLI"
3. Initialize your project (Step 3)

Query in your Gemini CLI chat:

```bash
gem chat --prompt "Find all unused exports in src/utils"
```

### Hermes Agent / OpenCode / Custom Agents

See "Manual Configuration" in [SKILL.md](./SKILL.md) for setting up a custom MCP endpoint.

---

## Updating cgraph

Check for updates anytime:

```bash
codegraph upgrade --check
```

To upgrade:

```bash
codegraph upgrade
```

cgraph auto-detects how you installed (bundle, npm, or npx) and updates in place.

To pin a specific version:

```bash
codegraph upgrade v1.2.3
```

---

## Uninstalling

Remove cgraph from all agents and uninstall the CLI:

```bash
codegraph uninstall
```

This:
- Removes MCP server config from all detected agents
- Deletes the CLI
- **Preserves** `.codegraph/` directories (to keep your indexes)

To also remove project indexes:

```bash
cd my-project
codegraph uninit
rm -rf .codegraph/
```

To keep the CLI but remove only agent configurations:

```bash
codegraph uninstall --keep-cli
```

---

## Troubleshooting

### Command Not Found: `codegraph`

**Windows:** The installer doesn't reload your shell. Open a **new PowerShell or Command Prompt** window.

**macOS/Linux:** Reload your shell profile:

```bash
# Bash
source ~/.bashrc

# Zsh
source ~/.zshrc

# Fish
source ~/.config/fish/config.fish
```

Or start a new terminal.

### Agent Doesn't Detect Graph Queries

1. Verify cgraph is installed: `codegraph --version`
2. Verify your project is initialized: `ls -la .codegraph/`
3. Check the daemon is running: `codegraph daemon status`
4. Restart your agent application completely
5. Try a simple query to trigger daemon startup

### Graph Is Out of Sync

Rebuild the index:

```bash
cd my-project
codegraph reinit
```

This rebuilds the graph without losing your `.cgignore` settings.

### High Memory Usage

Large repositories can consume 500MB+. To reduce indexing scope:

1. Create `.cgignore` in your project root:
   ```
   node_modules
   build/
   dist/
   .git/
   vendor/
   ```

2. Reinitialize:
   ```bash
   codegraph reinit
   ```

### Daemon Won't Start

Check daemon logs:

```bash
codegraph daemon logs
```

If the process is stuck:

```bash
codegraph daemon restart
```

---

## Configuration Files

After `codegraph init`, your project has:

```
.codegraph/
├── graph.bin              # Indexed code graph (binary format)
├── metadata.json          # Index metadata, file count, sync status
├── .cgignore              # Patterns to exclude (optional, create if needed)
└── config.json            # Language and tool settings
```

### .cgignore

List patterns to exclude from indexing (one per line):

```
node_modules
build/
dist/
.git/
.venv/
vendor/
*.log
__pycache__/
```

### config.json

Advanced configuration (auto-generated, edit carefully):

```json
{
  "version": 1,
  "languages": ["typescript", "python", "go"],
  "exclude": ["node_modules", "build", "dist"],
  "autoSync": true,
  "daemonPort": 6969
}
```

---

## Environment Variables

Control cgraph behavior with these env vars:

```bash
# Enable verbose debug output
export CODEGRAPH_DEBUG=1

# Custom daemon port (default: 6969)
export CODEGRAPH_PORT=7000

# Custom .codegraph directory
export CODEGRAPH_HOME=$HOME/.config/codegraph

# Auto-sync interval in seconds (default: 1)
export CODEGRAPH_SYNC_INTERVAL=5
```

---

## System Requirements

- **OS:** macOS, Linux, Windows, or BSD
- **Disk:** 1GB free (plus space for indexes)
- **Memory:** 512MB (2GB+ recommended for large repos)
- **Node.js:** None (standalone bundle) or v18+ (if using npm)

---

## What's Next?

- Read [SKILL.md](./SKILL.md) for provider-specific configuration details
- Check [README.md](./README.md) for tool reference and usage examples
- Review [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) for advanced features
