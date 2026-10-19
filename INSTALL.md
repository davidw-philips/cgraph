# Installation & Setup

This guide walks through checking your Node.js runtime, installing it if needed, and wiring cgraph into your agent.

## Step 0: Check Node.js Runtime (Important!)

Before installing cgraph, verify your system has a compatible Node.js version (v18+). If you don't have Node.js or need to upgrade, we provide installers.

### Check Your Current Runtime

**Windows (PowerShell):**
```powershell
.\installers\check-node.ps1
```

**macOS/Linux (Bash):**
```bash
bash ./installers/check-node.sh
```

This script will:
- ✅ Report your current Node.js version
- ✅ Confirm compatibility (v18+ required)
- ✅ Suggest next steps if an upgrade is needed

**Example output (compatible):**
```
[OK] Node.js found: v22.5.0
[OK] Version v22.5.0 is compatible (requires v18.0.0+)

✅ Node.js runtime is ready for cgraph
```

### Install Node.js (If Needed)

If the check script indicates Node.js is missing or too old, use the NVM installer:

**Windows (PowerShell - requires Administrator):**
```powershell
.\installers\install-nvm.ps1
```

This will:
1. Install NVM for Windows (nvm-windows)
2. Install Node.js v22.5.0 automatically
3. Activate it for your system

**macOS/Linux (Bash):**
```bash
bash ./installers/install-nvm.sh
```

This will:
1. Install NVM (Node Version Manager)
2. Install Node.js v22.5.0 automatically
3. Source it into your current shell

**Note:** On Windows, you may need to **open a new PowerShell window** after installation for NVM to be available in your PATH.

### Use Project's Node.js Version (.nvmrc)

If you have NVM installed and are contributing to cgraph development, use the project's pinned version:

```bash
# Automatically switch to the version in .nvmrc (22.5.0)
nvm use

# Or explicitly
nvm install 22.5.0
nvm use 22.5.0
```

This ensures your development environment matches the tested Node.js version.

---

## Step 1: Install the Codegraph CLI

Once Node.js v18+ is confirmed, install the main codegraph CLI. Choose the method that matches your system:

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

If you already have Node.js v18+ installed:

```bash
npm install -g @colbymchenry/codegraph
```

Verify installation:

```bash
codegraph --version
```

**Note:** The installer places `codegraph` on your PATH but doesn't reload your shell. Open a **new terminal** before proceeding.

---

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

---

## Step 3: Initialize Your Project

Navigate to any codebase and initialize the graph:

```bash
cd my-project

# Switch to project's Node.js version (if using NVM)
nvm use

# Initialize cgraph
codegraph init
```

This:
1. Creates `.codegraph/` directory
2. Scans your project and indexes all code
3. Enables auto-sync—the graph updates whenever you save files

**Time to completion:** Depends on repo size (30s–2m typical).

Once `codegraph init` completes, your agent can immediately query the graph.

---

## Step 4: Verify in Your Agent

Open your agent (Claude Code, Copilot, etc.) and try a graph query:

```
"Show me all the functions in src/utils that call fetchUser"
```

The agent should use the cgraph tools to search the local index and return results—**without** sending your entire codebase to the LLM.

---

## Agent-Specific Setup

### Claude Code (VS Code)

1. ✅ Check Node.js: `.\installers\check-node.ps1` (Windows) or `bash ./installers/check-node.sh` (macOS/Linux)
2. 📥 Install Node.js if needed: `.\installers\install-nvm.ps1` (Windows) or `bash ./installers/install-nvm.sh` (macOS/Linux)
3. 📦 Install codegraph CLI (Step 1)
4. 🔌 Wire into agent: `codegraph install` (Step 2)
5. 🔄 Restart Claude Code extension
6. 🎯 Initialize project: `cd my-project && nvm use && codegraph init` (Step 3)

The MCP server runs automatically when you use graph queries.

### GitHub Copilot (VS Code)

1. ✅ Check Node.js: `.\installers\check-node.ps1` (Windows) or `bash ./installers/check-node.sh` (macOS/Linux)
2. 📥 Install Node.js if needed: `.\installers\install-nvm.ps1` (Windows) or `bash ./installers/install-nvm.sh` (macOS/Linux)
3. 📦 Install codegraph CLI (Step 1)
4. 🔌 Wire into agent: `codegraph install` and select "GitHub Copilot (VS Code)" (Step 2)
5. 🔄 Restart VS Code
6. 🎯 Initialize project: `cd my-project && nvm use && codegraph init` (Step 3)

Graph queries appear in Copilot's tool suggestions.

### GitHub Copilot CLI

1. ✅ Check Node.js: `.\installers\check-node.ps1` (Windows) or `bash ./installers/check-node.sh` (macOS/Linux)
2. 📥 Install Node.js if needed: `.\installers\install-nvm.ps1` (Windows) or `bash ./installers/install-nvm.sh` (macOS/Linux)
3. 📦 Install codegraph CLI (Step 1)
4. 🔌 Wire into agent: `codegraph install` and select "GitHub Copilot CLI" (Step 2)
5. 🎯 Initialize project: `cd my-project && nvm use && codegraph init` (Step 3)

Use `gh copilot explain` with graph queries:

```bash
cd my-project
nvm use
gh copilot explain "Show functions that call fetchUser"
```

### Cursor

1. ✅ Check Node.js: `.\installers\check-node.ps1` (Windows) or `bash ./installers/check-node.sh` (macOS/Linux)
2. 📥 Install Node.js if needed: `.\installers\install-nvm.ps1` (Windows) or `bash ./installers/install-nvm.sh` (macOS/Linux)
3. 📦 Install codegraph CLI (Step 1)
4. 🔌 Wire into agent: `codegraph install` and select "Cursor" (Step 2)
5. 🔄 Restart Cursor
6. 🎯 Initialize project: `cd my-project && nvm use && codegraph init` (Step 3)

### Gemini CLI

1. ✅ Check Node.js: `.\installers\check-node.ps1` (Windows) or `bash ./installers/check-node.sh` (macOS/Linux)
2. 📥 Install Node.js if needed: `.\installers\install-nvm.ps1` (Windows) or `bash ./installers/install-nvm.sh` (macOS/Linux)
3. 📦 Install codegraph CLI (Step 1)
4. 🔌 Wire into agent: `codegraph install` and select "Gemini CLI" (Step 2)
5. 🎯 Initialize project: `cd my-project && nvm use && codegraph init` (Step 3)

Query in your Gemini CLI chat:

```bash
cd my-project
nvm use
gem chat --prompt "Find all unused exports in src/utils"
```

### Hermes Agent / OpenCode / Custom Agents

See "Manual Configuration" in [SKILL.md](./SKILL.md) for setting up a custom MCP endpoint.

---

## Using with AI Agents

When you add cgraph to the **all-skills** repo and tell an AI agent to use it:

1. **Agent detects the skill** in the repo
2. **Agent runs the Node.js check script:**
   ```powershell
   # Windows
   .\installers\check-node.ps1
   
   # macOS/Linux
   bash ./installers/check-node.sh
   ```
3. **If compatible:** Agent proceeds with `codegraph install`
4. **If NOT compatible:** Agent runs the installer:
   ```powershell
   # Windows
   .\installers\install-nvm.ps1
   
   # macOS/Linux
   bash ./installers/install-nvm.sh
   ```
5. **After installation:** Agent re-checks and then installs codegraph

This is fully **automated**—no manual intervention required if the scripts are present.

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

### Node.js Check Script Reports Incompatibility

**Windows:**
```powershell
.\installers\install-nvm.ps1
```

**macOS/Linux:**
```bash
bash ./installers/install-nvm.sh
```

The installer will handle everything automatically.

### Command Not Found: `codegraph`

**Windows:** After installing NVM and Node.js, open a **new PowerShell window**.

**macOS/Linux:** After installing NVM, open a **new terminal** or run:

```bash
source $HOME/.nvm/nvm.sh
nvm use
```

Then verify:

```bash
node --version  # Should be v22.5.0 or higher
nvm --version   # Should display NVM version
```

### Agent Doesn't Detect Graph Queries

1. Verify compatible Node.js: Run the check script (see Step 0)
2. Verify codegraph is installed: `codegraph --version`
3. Verify your project is initialized: `ls -la .codegraph/`
4. Check the daemon is running: `codegraph daemon status`
5. Restart your agent application completely
6. Try a simple query to trigger daemon startup

### Graph Is Out of Sync

Rebuild the index (ensures you're using the correct Node.js version):

```bash
cd my-project
nvm use
codegraph reinit
```

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
   nvm use
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

.nvmrc                      # Node version for this project (22.5.0)
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

### .nvmrc

The project includes `.nvmrc` with the tested Node.js version (22.5.0). Use it with NVM:

```bash
nvm use
```

This automatically switches to v22.5.0 when you `cd` into the project.

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
- **Node.js:** v18+ (v22.5.0 recommended, see `.nvmrc`)
- **NVM:** Optional but recommended for version management

---

## Installer Scripts Reference

| Script | OS | Purpose |
|--------|-----|---------|
| `installers/check-node.ps1` | Windows | Check Node.js compatibility |
| `installers/check-node.sh` | macOS/Linux | Check Node.js compatibility |
| `installers/install-nvm.ps1` | Windows | Install NVM + Node.js 22.5.0 |
| `installers/install-nvm.sh` | macOS/Linux | Install NVM + Node.js 22.5.0 |
| `.nvmrc` | All | Pinned Node.js version (22.5.0) |

---

## What's Next?

- Read [SKILL.md](./SKILL.md) for provider-specific configuration details
- Check [README.md](./README.md) for tool reference and usage examples
- Review [colbymchenry/codegraph](https://github.com/colbymchenry/codegraph) for advanced features
