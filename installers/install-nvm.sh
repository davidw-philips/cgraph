#!/bin/bash
# Install NVM (Node Version Manager) for macOS/Linux
# Downloads and installs NVM, then Node.js

NVM_VERSION="0.39.0"
NODE_VERSION="22.5.0"
SKIP_NODE_INSTALL=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-node) SKIP_NODE_INSTALL=true; shift ;;
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

write_status "NVM (Node Version Manager) Installer for macOS/Linux" "INFO"
echo ""

# Detect OS
OS_TYPE="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
    write_status "Detected OS: macOS" "INFO"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
    write_status "Detected OS: Linux" "INFO"
else
    write_status "Unsupported OS: $OSTYPE" "ERROR"
    exit 1
fi

echo ""

# Check if NVM is already installed
if [[ -d "$HOME/.nvm" ]] || [[ -n "$NVM_DIR" ]]; then
    write_status "NVM is already installed" "WARN"
    
    if command -v nvm &> /dev/null; then
        nvm_current=$(nvm --version)
        write_status "NVM version: $nvm_current" "INFO"
    fi
    
    echo ""
    echo -e "${YELLOW}To upgrade NVM, run:${NC}"
    echo -e "${GREEN}  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh | bash${NC}"
    echo ""
    echo -e "${YELLOW}To install Node.js, run:${NC}"
    echo -e "${GREEN}  nvm install $NODE_VERSION${NC}"
    echo -e "${GREEN}  nvm use $NODE_VERSION${NC}"
    exit 0
fi

write_status "Installing NVM v$NVM_VERSION..." "INFO"
echo ""

# Install NVM
echo -e "${BLUE}Downloading NVM installer...${NC}"
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash

if [[ $? -ne 0 ]]; then
    write_status "Failed to install NVM" "ERROR"
    exit 1
fi

write_status "NVM installation completed" "OK"
echo ""

# Source NVM (for current session)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"

# Verify NVM is available
if ! command -v nvm &> /dev/null; then
    write_status "NVM installed, but not yet available in current session" "WARN"
    echo ""
    echo -e "${YELLOW}To use NVM, open a NEW terminal or run:${NC}"
    echo -e "${GREEN}  source \$HOME/.nvm/nvm.sh${NC}"
    echo ""
    echo -e "${YELLOW}Then install Node.js:${NC}"
    echo -e "${GREEN}  nvm install $NODE_VERSION${NC}"
    echo -e "${GREEN}  nvm use $NODE_VERSION${NC}"
    exit 0
fi

write_status "NVM is now available" "OK"
echo ""

# Install Node.js (if not skipping)
if [[ "$SKIP_NODE_INSTALL" != "true" ]]; then
    echo -e "${BLUE}Installing Node.js $NODE_VERSION...${NC}"
    nvm install $NODE_VERSION
    
    if [[ $? -ne 0 ]]; then
        write_status "Failed to install Node.js" "ERROR"
        exit 1
    fi
    
    write_status "Setting Node.js $NODE_VERSION as default" "INFO"
    nvm use $NODE_VERSION
    nvm alias default $NODE_VERSION
    
    echo ""
    write_status "Node.js $NODE_VERSION installed and activated" "OK"
    echo ""
    echo -e "${BLUE}Verify installation:${NC}"
    echo -e "${GREEN}  node --version${NC}"
    echo -e "${GREEN}  npm --version${NC}"
else
    echo -e "${YELLOW}To install Node.js, run:${NC}"
    echo -e "${GREEN}  nvm install $NODE_VERSION${NC}"
    echo -e "${GREEN}  nvm use $NODE_VERSION${NC}"
fi
