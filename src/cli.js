#!/usr/bin/env node

/**
 * cgraph CLI Wrapper
 * 
 * This is the entry point that:
 * 1. Exposes --help with tool descriptions
 * 2. Manages the codegraph daemon lifecycle
 * 3. Provides progressive tool definition exposure
 * 4. Integrates with MCP servers for agents
 */

import { spawnSync, spawn } from 'child_process';
import { resolve } from 'path';
import { existsSync, readFileSync } from 'fs';

const version = '1.0.0';
const toolDefinitions = {
  graph_query: {
    name: 'graph_query',
    description: 'Free-text semantic search across the indexed code knowledge graph',
    inputSchema: {
      type: 'object',
      properties: {
        text: {
          type: 'string',
          description: 'Natural language search query (e.g., "functions that fetch data")'
        },
        limit: {
          type: 'number',
          description: 'Maximum results to return (default: 10)',
          default: 10
        },
        context: {
          type: 'boolean',
          description: 'Include surrounding code context (default: true)',
          default: true
        }
      },
      required: ['text']
    }
  },
  graph_find_functions: {
    name: 'graph_find_functions',
    description: 'Find all functions matching a name pattern or filter criteria',
    inputSchema: {
      type: 'object',
      properties: {
        pattern: {
          type: 'string',
          description: 'Function name pattern (* is wildcard)'
        },
        filter_files: {
          type: 'array',
          items: { type: 'string' },
          description: 'Optional: limit search to specific file paths'
        }
      },
      required: ['pattern']
    }
  },
  graph_find_classes: {
    name: 'graph_find_classes',
    description: 'Find class, interface, or type definitions with inheritance hierarchy',
    inputSchema: {
      type: 'object',
      properties: {
        pattern: {
          type: 'string',
          description: 'Class name pattern (* is wildcard)'
        },
        filter_files: {
          type: 'array',
          items: { type: 'string' },
          description: 'Optional: limit search to specific file paths'
        }
      },
      required: ['pattern']
    }
  },
  graph_show_dependencies: {
    name: 'graph_show_dependencies',
    description: 'Show import/export relationships and dependency graph for a file or symbol',
    inputSchema: {
      type: 'object',
      properties: {
        file_or_symbol: {
          type: 'string',
          description: 'File path or symbol name to analyze'
        },
        recursive: {
          type: 'boolean',
          description: 'Include transitive dependencies (default: false)',
          default: false
        }
      },
      required: ['file_or_symbol']
    }
  },
  graph_list_exports: {
    name: 'graph_list_exports',
    description: 'List all public exports from a module',
    inputSchema: {
      type: 'object',
      properties: {
        module_path: {
          type: 'string',
          description: 'File path to the module'
        }
      },
      required: ['module_path']
    }
  },
  graph_find_callers: {
    name: 'graph_find_callers',
    description: 'Find all functions that call a specific function',
    inputSchema: {
      type: 'object',
      properties: {
        function_name: {
          type: 'string',
          description: 'Name of the function to find callers for'
        },
        recursive: {
          type: 'boolean',
          description: 'Include transitive callers (default: false)',
          default: false
        }
      },
      required: ['function_name']
    }
  },
  graph_find_implementations: {
    name: 'graph_find_implementations',
    description: 'Find all implementations of an interface or subclasses of a base class',
    inputSchema: {
      type: 'object',
      properties: {
        interface_or_base_class: {
          type: 'string',
          description: 'Name of the interface or base class'
        },
        recursive: {
          type: 'boolean',
          description: 'Include transitive implementations (default: true)',
          default: true
        }
      },
      required: ['interface_or_base_class']
    }
  }
};

function showHelp() {
  console.log(`
cgraph v${version} - Code Knowledge Graph Skill for AI Agents

USAGE
  cgraph [COMMAND] [OPTIONS]

COMMANDS
  install              Wire cgraph into detected agents (Claude Code, Copilot, Cursor, etc.)
  uninstall            Remove cgraph from all agents
  init                 Initialize cgraph for current project
  reinit               Rebuild the code graph from scratch
  daemon               Manage the cgraph daemon process
  tools                Show available graph query tools
  help, --help, -h     Show this help message
  version, --version   Show version

GLOBAL OPTIONS
  --debug              Enable debug logging
  --port PORT          Custom daemon port (default: 6969)
  --home PATH          Custom .codegraph directory location

EXAMPLES
  # Set up cgraph in your agents
  $ cgraph install

  # Initialize a project
  $ cd my-project && cgraph init

  # View available graph query tools
  $ cgraph tools

  # Check daemon status
  $ cgraph daemon status

DAEMON COMMANDS (use 'cgraph daemon <cmd>')
  start                Start the cgraph daemon
  stop                 Stop the daemon
  restart              Restart the daemon
  status               Check daemon status
  logs                 View daemon logs

TOOLS EXPOSED

  The following tools are exposed to your agent for querying the code graph:

${Object.values(toolDefinitions).map(tool => `
  • ${tool.name}
    ${tool.description}
`).join('\n')}

  Use 'cgraph tools' for full input schemas.

CONFIGURATION

  Environment Variables:
    CODEGRAPH_DEBUG=1        Enable verbose debug output
    CODEGRAPH_PORT=7000      Custom daemon port
    CODEGRAPH_HOME=/path     Custom index directory

  Project Files:
    .cgignore               Patterns to exclude from indexing
    .codegraph/config.json  Advanced settings

DOCUMENTATION
  README.md   Overview and quick start
  INSTALL.md  Detailed setup guide per agent
  SKILL.md    Provider integration details

SUPPORT
  Issues & Discussions: https://github.com/davidw-philips/cgraph
  Original Project:     https://github.com/colbymchenry/codegraph
`);
}

function showTools() {
  console.log(`
Available Graph Query Tools
=============================

${Object.values(toolDefinitions).map((tool, idx) => `
${idx + 1}. ${tool.name}
   Description: ${tool.description}
   
   Input Schema:
${JSON.stringify(tool.inputSchema, null, 4).split('\n').map(line => '   ' + line).join('\n')}
`).join('\n')}

These tools are automatically available to your agent once cgraph is installed
and your project is initialized with 'cgraph init'.

Each tool queries the local, indexed code graph with <50ms latency and zero
token overhead—faster and cheaper than sending code to the LLM.
`);
}

function handleCommand(args) {
  const [cmd, ...rest] = args;

  switch (cmd) {
    case 'help':
    case '--help':
    case '-h':
      showHelp();
      process.exit(0);

    case 'version':
    case '--version':
    case '-v':
      console.log(`cgraph v${version}`);
      process.exit(0);

    case 'tools':
      showTools();
      process.exit(0);

    case 'install':
      console.log('Installing cgraph into detected agents...');
      console.log('This requires the codegraph CLI to be installed first.');
      console.log('Run: curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh');
      console.log('');
      console.log('Then run: codegraph install');
      process.exit(0);

    case 'daemon':
      handleDaemon(rest);
      break;

    case 'init':
    case 'reinit':
    case 'uninstall':
      console.log(`Running: codegraph ${cmd} ${rest.join(' ')}`);
      const result = spawnSync('codegraph', [cmd, ...rest], { stdio: 'inherit' });
      process.exit(result.status || 0);

    default:
      if (cmd && !cmd.startsWith('-')) {
        console.error(`Unknown command: ${cmd}`);
        console.error('Run "cgraph help" for usage information.');
        process.exit(1);
      }
      showHelp();
      process.exit(0);
  }
}

function handleDaemon(args) {
  const [subcmd] = args;
  console.log(`Daemon management: ${subcmd || 'status'}`);
  
  if (subcmd === 'start') {
    console.log('Starting cgraph daemon on port 6969...');
    spawn('codegraph', ['daemon', 'start'], { stdio: 'inherit', detached: true }).unref();
  } else if (subcmd === 'stop') {
    console.log('Stopping cgraph daemon...');
    spawnSync('codegraph', ['daemon', 'stop'], { stdio: 'inherit' });
  } else if (subcmd === 'status') {
    spawnSync('codegraph', ['daemon', 'status'], { stdio: 'inherit' });
  } else if (subcmd === 'logs') {
    spawnSync('codegraph', ['daemon', 'logs'], { stdio: 'inherit' });
  } else {
    console.error(`Unknown daemon subcommand: ${subcmd}`);
    console.error('Use: cgraph daemon [start|stop|status|logs|restart]');
    process.exit(1);
  }
}

// Main entry point
const args = process.argv.slice(2);
if (args.length === 0) {
  showHelp();
} else {
  handleCommand(args);
}
