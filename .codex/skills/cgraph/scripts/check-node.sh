#!/bin/bash
# cgraph Node.js Runtime Checker (Bash/Shell)
#
# NOTE: The codegraph CLI/MCP server (the standalone installer) bundles its own
# runtime and needs NO Node.js at all. This script is only relevant if you plan
# to install via `npm i -g @colbymchenry/codegraph` (needs Node) or embed
# CodeGraph's library API in your own app (needs Node 22.5+ for node:sqlite).

MIN_NODE_VERSION="18.0.0"
TARGET_NODE_VERSION="22.5.0"
VERBOSE=false
INSTALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --verbose) VERBOSE=true; shift ;;
        --install) INSTALL=true; shift ;;
        *) shift ;;
    esac
done

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

write_status() {
    local message="$1"
    local status="${2:-INFO}"
    
    case $status in
        OK)    echo -e "${GREEN}[OK]${NC} $message" ;;
        WARN)  echo -e "${YELLOW}[WARN]${NC} $message" ;;
        ERROR) echo -e "${RED}[ERROR]${NC} $message" ;;
        INFO)  echo -e "${BLUE}[INFO]${NC} $message" ;;
        *)     echo "[$status] $message" ;;
    esac
}

compare_versions() {
    # Compare two semantic versions: $1 >= $2 returns 0 (true), else 1 (false)
    printf '%s\n%s' "$2" "$1" | sort -V -C && return 0 || return 1
}

get_node_info() {
    if command -v node &> /dev/null; then
        local node_version=$(node --version 2>&1 | sed 's/^v//')
        local node_path=$(command -v node)
        
        echo "$node_version"
        if [[ "$VERBOSE" == "true" ]]; then
            echo "DEBUG: Node.js found at: $node_path" >&2
        fi
        return 0
    else
        return 1
    fi
}

get_nvm_info() {
    if [[ -d "$HOME/.nvm" ]] || [[ -d "$NVM_DIR" ]]; then
        echo "installed"
        return 0
    else
        echo "not_installed"
        return 1
    fi
}

# Main execution
write_status "Checking Node.js runtime compatibility for cgraph..." "INFO"
echo ""

if node_version=$(get_node_info); then
    write_status "Node.js found: v$node_version" "OK"
    
    if compare_versions "$node_version" "$MIN_NODE_VERSION"; then
        write_status "Version v$node_version is compatible (requires v$MIN_NODE_VERSION+)" "OK"
        echo ""
        write_status "Node.js runtime is ready for npm install / library embedding" "OK"
        exit 0
    else
        write_status "Version v$node_version is TOO OLD (requires v$MIN_NODE_VERSION+)" "WARN"
        write_status "Upgrade with: nvm install $TARGET_NODE_VERSION" "INFO"
        
        if get_nvm_info &> /dev/null; then
            echo ""
            echo -e "${YELLOW}NVM is installed. Run:${NC}"
            echo -e "${GREEN}  nvm install $TARGET_NODE_VERSION${NC}"
            echo -e "${GREEN}  nvm use $TARGET_NODE_VERSION${NC}"
        else
            echo ""
            echo -e "${YELLOW}NVM is NOT installed. Run the installer:${NC}"
            echo -e "${GREEN}  bash ./installers/install-nvm.sh${NC}"
        fi
        exit 1
    fi
else
    write_status "Node.js is NOT installed" "WARN"
    echo ""
    
    if get_nvm_info &> /dev/null; then
        write_status "NVM is already installed" "OK"
        echo ""
        echo -e "${YELLOW}Install Node.js with NVM:${NC}"
        echo -e "${GREEN}  nvm install $TARGET_NODE_VERSION${NC}"
        echo -e "${GREEN}  nvm use $TARGET_NODE_VERSION${NC}"
        exit 1
    else
        write_status "NVM is NOT installed" "WARN"
        
        if [[ "$INSTALL" == "true" ]]; then
            echo ""
            echo -e "${BLUE}Running NVM installer...${NC}"
            bash "$(dirname "$0")/install-nvm.sh"
            exit $?
        else
            echo ""
            echo -e "${YELLOW}To install Node.js, run the NVM installer:${NC}"
            echo -e "${GREEN}  bash ./installers/install-nvm.sh${NC}"
            echo ""
            echo -e "${YELLOW}Then install Node:${NC}"
            echo -e "${GREEN}  nvm install $TARGET_NODE_VERSION${NC}"
            exit 1
        fi
    fi
fi
