#!/bin/bash

# Development tools installation script for multiple Linux distributions
# Installs essential coding tools: git, node.js, python, docker, etc.

echo "Detecting operating system..."

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si)
    VER=$(lsb_release -sr)
else
    echo "Cannot detect OS. Please install git manually."
    exit 1
fi

echo "Detected OS: $OS"

case $OS in
    *"Ubuntu"*|*"Debian"*)
        echo "Installing development tools on Ubuntu/Debian..."
        apt update
        
        # Essential tools
        apt install -y git curl wget build-essential
        
        # Python and pip
        apt install -y python3 python3-pip python3-venv
        
        # Python dependencies for pyenv
        apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev
        
        # Install pyenv
        if [ ! -d "$HOME/.pyenv" ]; then
            echo "Installing pyenv..."
            curl https://pyenv.run | bash
            
            # Add pyenv to bashrc
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
            echo 'eval "$(pyenv init -)"' >> ~/.bashrc
            
            # Also add to current session
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"
        else
            echo "pyenv already installed"
        fi
        
        # Docker
        apt install -y ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt update
        apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        systemctl enable docker
        usermod -aG docker $SUDO_USER
        
        # VS Code
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
        apt update
        apt install -y code
        
        
        # Additional useful tools
        apt install -y vim nano tree jq htop unzip zip ripgrep
        ;;
    *)
        echo "This script is optimized for Ubuntu. For other systems, install manually."
        exit 1
        ;;
esac

echo "Verifying installations..."

# Check git
if command -v git >/dev/null 2>&1; then
    echo "✓ Git installed: $(git --version)"
else
    echo "✗ Git installation failed"
fi


# Check pip3
if command -v pip3 >/dev/null 2>&1; then
    echo "✓ pip3 installed: $(pip3 --version)"
else
    echo "✗ pip3 installation failed"
fi

# Check Docker
if command -v docker >/dev/null 2>&1; then
    echo "✓ Docker installed: $(docker --version)"
else
    echo "✗ Docker installation failed"
fi

# Check VS Code
if command -v code >/dev/null 2>&1; then
    echo "✓ VS Code installed: $(code --version | head -1)"
else
    echo "✗ VS Code installation failed"
fi

# Check pyenv
if [ -d "$HOME/.pyenv" ]; then
    echo "✓ pyenv installed (restart shell and run 'pyenv --version' to verify)"
    echo "  To install Python 3.12: pyenv install 3.12.0 && pyenv global 3.12.0"
else
    echo "✗ pyenv installation failed"
fi

echo ""
echo "Reloading shell configuration..."
source ~/.bashrc

echo ""
echo "Installation complete!"
echo "To install Python 3.12 run: pyenv install 3.12.0 && pyenv global 3.12.0"
