#!/bin/bash
# Chezmoi Complete Setup Script
# This script helps set up chezmoi on Windows, Mac, or Linux
# It detects the OS, installs chezmoi if needed, and guides through configuration

set -e

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
NC="\033[0m" # No Color

# Function to print styled messages
print_message() {
    local style=$1
    local message=$2
    echo -e "${style}${message}${NC}"
}

# Function to print section headers
print_header() {
    local message=$1
    echo ""
    print_message "${BOLD}${BLUE}=== $message ===${NC}" ""
    echo ""
}

# Function to get user input with a default value
get_input() {
    local prompt=$1
    local default=$2
    local input
    
    if [ -n "$default" ]; then
        read -p "${prompt} [${default}]: " input
        echo "${input:-$default}"
    else
        read -p "${prompt}: " input
        echo "$input"
    fi
}

# Function to get yes/no input
get_yes_no() {
    local prompt=$1
    local default=$2
    local input
    
    while true; do
        if [ "$default" = "Y" ]; then
            read -p "${prompt} [Y/n]: " input
            input=${input:-Y}
        elif [ "$default" = "N" ]; then
            read -p "${prompt} [y/N]: " input
            input=${input:-N}
        else
            read -p "${prompt} [y/n]: " input
        fi
        
        case $input in
            [Yy]*)
                echo "Y"
                return
                ;;
            [Nn]*)
                echo "N"
                return
                ;;
            *)
                print_message "${YELLOW}" "Please answer Y or N"
                ;;
        esac
    done
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect the operating system
detect_os() {
    if [ -z "$OSTYPE" ]; then
        # OSTYPE not set, try alternative detection
        if command_exists uname; then
            case "$(uname -s)" in
                Linux*)     echo "linux";;
                Darwin*)    echo "darwin";;
                CYGWIN*|MINGW*|MSYS*) echo "windows";;
                *)          echo "unknown";;
            esac
        else
            # Final fallback for Windows without uname
            if [ -n "$SYSTEMROOT" ] && [ -d "$SYSTEMROOT" ]; then
                echo "windows"
            else
                echo "unknown"
            fi
        fi
    else
        case "$OSTYPE" in
            linux*)     echo "linux";;
            darwin*)    echo "darwin";;
            cygwin*|msys*|mingw*) echo "windows";;
            *)          echo "unknown";;
        esac
    fi
}

# Function to install chezmoi if not already installed
install_chezmoi() {
    local os=$1
    
    if command_exists chezmoi; then
        print_message "${GREEN}" "Chezmoi is already installed!"
        return
    fi
    
    print_header "Installing Chezmoi"
    
    case "$os" in
        darwin)
            if command_exists brew; then
                print_message "${GREEN}" "Installing chezmoi using Homebrew..."
                brew install chezmoi
            else
                print_message "${YELLOW}" "Homebrew not found. Installing chezmoi using the install script..."
                sh -c "$(curl -fsLS get.chezmoi.io)"
            fi
            ;;
        linux)
            if command_exists apt; then
                print_message "${GREEN}" "Installing chezmoi using apt..."
                sudo apt update && sudo apt install -y chezmoi
            elif command_exists dnf; then
                print_message "${GREEN}" "Installing chezmoi using dnf..."
                sudo dnf install -y chezmoi
            elif command_exists pacman; then
                print_message "${GREEN}" "Installing chezmoi using pacman..."
                sudo pacman -S chezmoi
            elif command_exists snap; then
                print_message "${GREEN}" "Installing chezmoi using snap..."
                sudo snap install chezmoi --classic
            else
                print_message "${YELLOW}" "No package manager detected. Installing chezmoi using the install script..."
                sh -c "$(curl -fsLS get.chezmoi.io)"
            fi
            ;;
        windows)
            if command_exists scoop; then
                print_message "${GREEN}" "Installing chezmoi using Scoop..."
                scoop install chezmoi
            elif command_exists choco; then
                print_message "${GREEN}" "Installing chezmoi using Chocolatey..."
                choco install chezmoi
            elif command_exists winget; then
                print_message "${GREEN}" "Installing chezmoi using Winget..."
                winget install twpayne.chezmoi
            else
                print_message "${YELLOW}" "No package manager detected. Downloading directly..."
                if command_exists powershell; then
                    powershell -Command "Invoke-WebRequest -UseBasicParsing -OutFile $env:TEMP\install.ps1 https://git.io/chezmoi-install.ps1 ; &$env:TEMP\install.ps1"
                else
                    print_message "${RED}" "PowerShell not found. Please install chezmoi manually from https://www.chezmoi.io/"
                    exit 1
                fi
            fi
            ;;
        *)
            print_message "${RED}" "Unsupported operating system. Please install chezmoi manually from https://www.chezmoi.io/"
            exit 1
            ;;
    esac
    
    # Verify installation
    if ! command_exists chezmoi; then
        print_message "${RED}" "Failed to install chezmoi. Please install it manually from https://www.chezmoi.io/"
        exit 1
    fi
    
    print_message "${GREEN}" "Chezmoi installed successfully!"
}

# Function to set up dotfiles repository
setup_dotfiles_repo() {
    print_header "Dotfiles Repository Setup"
    
    local use_existing=$(get_yes_no "Do you already have a dotfiles repository?" "N")
    
    if [ "$use_existing" = "Y" ]; then
        local repo_url=$(get_input "Enter your dotfiles repository URL (e.g., https://github.com/username/dotfiles)")
        
        # Check if the URL is provided
        if [ -z "$repo_url" ]; then
            print_message "${RED}" "Repository URL cannot be empty!"
            setup_dotfiles_repo  # Recursively call the function to try again
            return
        fi
        
        local apply_immediately=$(get_yes_no "Do you want to apply the dotfiles immediately after initialization?" "Y")
        
        print_message "${BLUE}" "Initializing chezmoi with your repository..."
        if [ "$apply_immediately" = "Y" ]; then
            chezmoi init --apply "$repo_url"
        else
            chezmoi init "$repo_url"
        fi
    else
        print_message "${BLUE}" "Setting up a new dotfiles repository..."
        
        # Initialize a new chezmoi configuration
        chezmoi init
        
        print_message "${YELLOW}" "Now let's add some common configuration files to manage with chezmoi."
        
        # Common files to add based on OS
        local os=$(detect_os)
        local files_to_add=()
        
        case "$os" in
            darwin|linux)
                # Ask about common Unix/Linux dotfiles
                if [ -f "$HOME/.bashrc" ] && [ "$(get_yes_no "Add .bashrc?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/.bashrc")
                fi
                
                if [ -f "$HOME/.zshrc" ] && [ "$(get_yes_no "Add .zshrc?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/.zshrc")
                fi
                
                if [ -f "$HOME/.vimrc" ] && [ "$(get_yes_no "Add .vimrc?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/.vimrc")
                fi
                
                if [ -d "$HOME/.config" ] && [ "$(get_yes_no "Add .config directory?" "N")" = "Y" ]; then
                    # Ask which specific configs to add
                    if [ -d "$HOME/.config/nvim" ] && [ "$(get_yes_no "Add Neovim config?" "Y")" = "Y" ]; then
                        files_to_add+=("$HOME/.config/nvim")
                    fi
                    
                    if [ -d "$HOME/.config/alacritty" ] && [ "$(get_yes_no "Add Alacritty config?" "Y")" = "Y" ]; then
                        files_to_add+=("$HOME/.config/alacritty")
                    fi
                    
                    if [ -d "$HOME/.config/tmux" ] && [ "$(get_yes_no "Add Tmux config?" "Y")" = "Y" ]; then
                        files_to_add+=("$HOME/.config/tmux")
                    fi
                fi
                
                if [ -f "$HOME/.tmux.conf" ] && [ "$(get_yes_no "Add .tmux.conf?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/.tmux.conf")
                fi
                
                if [ -f "$HOME/.gitconfig" ] && [ "$(get_yes_no "Add .gitconfig?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/.gitconfig")
                fi
                ;;
            windows)
                # Windows-specific configurations
                if [ -d "$HOME/AppData/Local/nvim" ] && [ "$(get_yes_no "Add Neovim config?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/AppData/Local/nvim")
                fi
                
                if [ -f "$HOME/.gitconfig" ] && [ "$(get_yes_no "Add .gitconfig?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/.gitconfig")
                fi
                
                if [ -d "$HOME/Documents/PowerShell" ] && [ "$(get_yes_no "Add PowerShell profile?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/Documents/PowerShell")
                fi
                
                if [ -d "$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState" ] && [ "$(get_yes_no "Add Windows Terminal settings?" "Y")" = "Y" ]; then
                    files_to_add+=("$HOME/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json")
                fi
                ;;
        esac
        
        # Add any custom files the user wants to manage
        local add_custom=$(get_yes_no "Would you like to add any other files/directories?" "Y")
        if [ "$add_custom" = "Y" ]; then
            while true; do
                local custom_path=$(get_input "Enter path to add (or leave empty to finish)")
                if [ -z "$custom_path" ]; then
                    break
                elif [ -e "$custom_path" ]; then
                    files_to_add+=("$custom_path")
                    print_message "${GREEN}" "Added $custom_path to the list"
                else
                    print_message "${RED}" "Path does not exist: $custom_path"
                fi
            done
        fi
        
        # Add the files to chezmoi
        if [ ${#files_to_add[@]} -gt 0 ]; then
            print_message "${BLUE}" "Adding selected files to chezmoi..."
            for file in "${files_to_add[@]}"; do
                print_message "${GREEN}" "Adding $file..."
                chezmoi add "$file"
            done
        fi
        
        # Ask about remote repository setup
        local setup_remote=$(get_yes_no "Would you like to set up a remote Git repository for your dotfiles?" "Y")
        if [ "$setup_remote" = "Y" ]; then
            local git_provider=$(get_input "Enter git provider (github, gitlab, bitbucket, etc.)" "github")
            local git_username=$(get_input "Enter your $git_provider username")
            local repo_name=$(get_input "Enter repository name" "dotfiles")
            
            print_message "${YELLOW}" "To set up your remote repository, follow these steps:"
            print_message "${BLUE}" "1. Create a new repository named '$repo_name' on $git_provider"
            print_message "${BLUE}" "2. Run the following commands:"
            print_message "${NC}" "   cd $(chezmoi source-path)"
            print_message "${NC}" "   git init"
            print_message "${NC}" "   git add ."
            print_message "${NC}" "   git commit -m \"Initial commit\""
            print_message "${NC}" "   git branch -M main"
            print_message "${NC}" "   git remote add origin https://$git_provider.com/$git_username/$repo_name.git"
            print_message "${NC}" "   git push -u origin main"
            
            local init_git_now=$(get_yes_no "Would you like this script to initialize the Git repository now?" "Y")
            if [ "$init_git_now" = "Y" ]; then
                (
                    cd "$(chezmoi source-path)" && \
                    git init && \
                    git add . && \
                    git commit -m "Initial commit" && \
                    git branch -M main && \
                    git remote add origin "https://$git_provider.com/$git_username/$repo_name.git"
                    
                    print_message "${GREEN}" "Git repository initialized locally!"
                    print_message "${YELLOW}" "Remember to create the repository on $git_provider and then push with 'git push -u origin main'"
                )
            fi
        fi
    fi
}

# Function to configure chezmoi
configure_chezmoi() {
    print_header "Chezmoi Configuration"
    
    # Create chezmoi.toml if needed
    local config_dir="$HOME/.config/chezmoi"
    local config_file="$config_dir/chezmoi.toml"
    
    if [ ! -d "$config_dir" ]; then
        mkdir -p "$config_dir"
    fi
    
    if [ ! -f "$config_file" ]; then
        # Basic configuration setup
        print_message "${BLUE}" "Setting up basic configuration..."
        local full_name=$(get_input "Enter your full name" "$(git config --get user.name 2>/dev/null || echo "")")
        local email=$(get_input "Enter your email" "$(git config --get user.email 2>/dev/null || echo "")")
        
        # Create basic config file
        cat > "$config_file" << EOF
# chezmoi configuration file
# https://www.chezmoi.io/reference/configuration-file/

[data]
    name = "$full_name"
    email = "$email"

[diff]
    pager = "less"
EOF
        
        print_message "${GREEN}" "Created basic configuration at $config_file"
    else
        print_message "${GREEN}" "Configuration file already exists at $config_file"
    fi
    
    # Advanced configuration options
    local configure_advanced=$(get_yes_no "Would you like to configure advanced options?" "N")
    if [ "$configure_advanced" = "Y" ]; then
        # Editor configuration
        local editor=$(get_input "Enter your preferred editor (e.g., vim, nano, vscode)" "vim")
        
        # Password manager integration
        local use_password_manager=$(get_yes_no "Do you use a password manager for secrets?" "N")
        local password_manager=""
        
        if [ "$use_password_manager" = "Y" ]; then
            echo "Select your password manager:"
            echo "1) Bitwarden"
            echo "2) 1Password"
            echo "3) LastPass"
            echo "4) pass"
            echo "5) KeePassXC"
            echo "6) Vault"
            echo "7) gopass"
            echo "8) Other/None"
            
            local pm_choice
            read -p "Enter choice [1-8]: " pm_choice
            
            case $pm_choice in
                1) password_manager="bitwarden";;
                2) password_manager="onepassword";;
                3) password_manager="lastpass";;
                4) password_manager="pass";;
                5) password_manager="keepassxc";;
                6) password_manager="vault";;
                7) password_manager="gopass";;
                *) password_manager="";;
            esac
            
            if [ -n "$password_manager" ]; then
                # Add password manager to config
                cat >> "$config_file" << EOF

[${password_manager}]
    command = "${password_manager}"
EOF
            fi
        fi
        
        # Add editor to config
        cat >> "$config_file" << EOF

[edit]
    command = "${editor}"
EOF
        
        print_message "${GREEN}" "Advanced configuration updated!"
    fi
    
    # Show the final config
    print_message "${BLUE}" "Your chezmoi configuration:"
    cat "$config_file"
}

# Function to create a template example
create_template_example() {
    print_header "Template Examples"
    
    local create_example=$(get_yes_no "Would you like to create a template example file?" "Y")
    if [ "$create_example" = "Y" ]; then
        local template_file="$(chezmoi source-path)/dot_template_example"
        
        cat > "$template_file" << 'EOF'
# This is an example template file for chezmoi
# It demonstrates various template features

# Basic information from your config
Name: {{ .name }}
Email: {{ .email }}

# OS-specific configurations
{{ if eq .chezmoi.os "darwin" -}}
# macOS specific settings
alias ls='ls -G'
export PATH=$HOME/Library/Python/3.9/bin:$PATH
{{- else if eq .chezmoi.os "linux" -}}
# Linux specific settings
alias ls='ls --color=auto'
export PATH=$HOME/.local/bin:$PATH
{{- else if eq .chezmoi.os "windows" -}}
# Windows specific settings
alias ls='ls --color=auto'
{{- end }}

# Hostname-specific configurations
{{ if eq .chezmoi.hostname "work-laptop" -}}
# Work-specific settings
export http_proxy=http://proxy.work.com:8080
{{- else -}}
# Personal settings
# No proxy needed
{{- end }}

# Executable commands
Current date: {{ output "date" }}

# You can also include other files
# {{ include "/path/to/file" }}

# This is how you can use encrypted secrets (requires proper setup)
# DB_PASSWORD={{ (onepassword "Database").password }}
EOF
        
        print_message "${GREEN}" "Created template example at $template_file"
        print_message "${BLUE}" "To apply this template, run:"
        print_message "${NC}" "chezmoi add --template $template_file"
        print_message "${NC}" "chezmoi apply --verbose"
    fi
}

# Function to provide usage instructions
provide_instructions() {
    print_header "Usage Instructions"
    
    print_message "${BOLD}${GREEN}" "Chezmoi is now set up on your system!"
    print_message "${BLUE}" "Here are some common commands to get you started:"
    
    echo "• Add a file to chezmoi:"
    echo "  chezmoi add ~/.bashrc"
    echo ""
    echo "• Edit a managed file:"
    echo "  chezmoi edit ~/.bashrc"
    echo ""
    echo "• See what changes would be made:"
    echo "  chezmoi diff"
    echo ""
    echo "• Apply changes:"
    echo "  chezmoi apply"
    echo ""
    echo "• Update from your repo and apply changes:"
    echo "  chezmoi update"
    echo ""
    echo "• Add a template file:"
    echo "  chezmoi add --template ~/.config/some-config"
    echo ""
    echo "• Add an encrypted file:"
    echo "  chezmoi add --encrypt ~/.ssh/id_rsa"
    echo ""
    
    print_message "${BOLD}${BLUE}" "For more information, visit: https://www.chezmoi.io/user-guide/command-overview/"
}

# Main function
main() {
    print_header "Chezmoi Setup Script"
    print_message "${BOLD}" "This script will help you set up and configure chezmoi for dotfile management."
    
    # Detect OS
    local os=$(detect_os)
    print_message "${GREEN}" "Detected operating system: $os"
    
    # Install chezmoi if needed
    install_chezmoi "$os"
    
    # Set up dotfiles repository
    setup_dotfiles_repo
    
    # Configure chezmoi
    configure_chezmoi
    
    # Create template example
    create_template_example
    
    # Provide usage instructions
    provide_instructions
    
    print_header "Setup Complete"
    print_message "${BOLD}${GREEN}" "Your chezmoi configuration is now ready!"
}

# Run the main function
main