set -euo pipefail  # Exit on error, undefined variables, and pipe failures
IFS=

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

cleanup_downloads() {
    log_info "Cleaning up downloaded .deb files..."
    rm -f ./*.deb
}

# Trap to ensure cleanup happens
trap cleanup_downloads EXIT

section_system_update() {
    log_info "Updating system packages..."
    sudo apt update && sudo apt full-upgrade -y
    log_success "System updated successfully"
}

section_credentials() {
    log_info "Installing credential management tools..."
    
    sudo apt install -y \
        keepassxc \
        git
    
    log_success "Credential tools installed"
}

section_terminal() {
    log_info "Installing terminal emulator and shell tools..."
    
    sudo apt install -y \
        alacritty \
        zsh \
        zsh-autosuggestions \
        zsh-syntax-highlighting
    
    log_success "Terminal tools installed"
    
    log_info "Installing Oh My Zsh..."
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended
        log_success "Oh My Zsh installed"
    else
        log_warning "Oh My Zsh already installed, skipping..."
    fi
    
    log_info "Installing Powerlevel10k theme..."
    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
        git clone https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
        log_success "Powerlevel10k installed"
    else
        log_warning "Powerlevel10k already installed, skipping..."
    fi
    
    log_info "Configuring .zshrc..."
    if [ -f "$HOME/.zshrc" ]; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
        sed -i 's/^plugins=.*/plugins=(git)/' "$HOME/.zshrc"
        log_success ".zshrc configured"
    else
        log_warning ".zshrc not found, please configure manually"
    fi
    
    log_warning "To complete zsh setup, run: chsh -s \$(which zsh) and restart your terminal"
}

section_development() {
    log_info "Installing development tools..."
    
    log_info "Installing .NET 9..."
    sudo apt install -y dotnet9
    
    log_info "Installing JetBrains Rider..."
    sudo snap install rider --classic
    
    log_info "Installing Visual Studio Code..."
    wget -q -O code.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
    sudo apt install -y ./code.deb
    
    log_success "Development IDEs installed"
}

section_docker() {
    log_info "Installing Docker..."
    
    sudo apt install -y ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    sudo apt update
    sudo apt install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
    
    log_info "Installing Docker Desktop..."
    wget -q -O docker-desktop.deb https://desktop.docker.com/linux/main/amd64/docker-desktop-amd64.deb
    sudo apt install -y ./docker-desktop.deb
    
    log_success "Docker installed successfully"
}

section_nodejs() {
    log_info "Installing Node.js via NVM..."
    
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    
    # Load NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    nvm install 24
    nvm use 24
    
    log_info "Enabling pnpm..."
    corepack enable pnpm
    pnpm -v
        
    log_success "Node.js ecosystem configured"
}

section_communication() {
    log_info "Installing communication applications..."
    
    log_info "Installing Discord..."
    wget -q -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
    sudo apt install -y ./discord.deb
    
    log_info "Installing Telegram..."
    sudo snap install telegram-desktop
    
    log_info "Installing Zoom..."
    wget -q -O zoom.deb "https://cdn.zoom.us/prod/6.6.0.4410/zoom_amd64.deb"
    sudo apt install -y ./zoom.deb

    log_success "Communication apps installed"
}

section_gaming() {
    log_info "Installing gaming applications..."
    
    log_info "Installing Steam..."
    wget -q -O steam.deb https://cdn.fastly.steamstatic.com/client/installer/steam.deb
    sudo apt install -y ./steam.deb
    
    log_info "Installing NBFC(Notebook FanControl) for fan control..."
    wget -q -O nbfc-linux.deb https://github.com/nbfc-linux/nbfc-linux/releases/download/0.3.19/nbfc-linux_0.3.19_amd64.deb
    sudo apt install -y ./nbfc-linux.deb
    
    wget -q -O nbfc-qt.deb https://github.com/nbfc-linux/nbfc-qt/releases/download/0.4.3/nbfc-qt_0.4.3_amd64.deb
    sudo apt install -y ./nbfc-qt.deb
    
    log_info "Configuring NBFC..."
    sudo nbfc update
    sudo nbfc config --set auto
    sudo nbfc restart
    sudo nbfc set --auto
    sudo systemctl enable nbfc_service
    
    log_success "Gaming tools installed and configured"
}

section_media() {
    log_info "Installing media applications..."
    
    log_info "Installing Deezer..."
    wget -q -O deezer.deb https://github.com/aunetx/deezer-linux/releases/download/v7.0.170/deezer-desktop_7.0.170_amd64.deb
    sudo apt install -y ./deezer.deb
    
    log_info "Installing VLC..."
    sudo apt install -y vlc
    
    log_success "Media applications installed"
}

section_cleanup() {
    log_info "Removing unwanted applications..."
    
    sudo apt remove --purge -y \
        gedit \
        gedit-common
    
    sudo apt autoremove -y
    sudo apt autoclean
    
    log_success "System cleanup completed"
}

main() {
    echo "=================================================="
    echo "  Environment Setup"
    echo "=================================================="
    echo ""
    
    section_system_update
    echo ""
    
    section_credentials
    echo ""
    
    section_terminal
    echo ""
    
    section_development
    echo ""
    
    section_docker
    echo ""
    
    section_nodejs
    echo ""
    
    section_communication
    echo ""
    
    section_gaming
    echo ""
    
    section_media
    echo ""
    
    section_cleanup
    echo ""
    
    log_success "Setup completed successfully!"
    echo ""
    log_warning "Please restart your terminal or run 'source ~/.zshrc' to apply shell changes"
    log_warning "To set zsh as default shell, run: chsh -s \$(which zsh)"
}

main "$@"