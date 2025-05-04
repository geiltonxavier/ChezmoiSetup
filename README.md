# Chezmoi Setup Script Documentation

This documentation covers the usage and features of the `bootstrap.sh` script, designed to automate the installation and configuration of [chezmoi](https://www.chezmoi.io/) across different operating systems.

## Overview

The Chezmoi Setup Script provides an interactive and guided approach to setting up chezmoi for dotfile management on Windows, macOS, and Linux. It handles installation, repository setup, file management, and configuration in a user-friendly way.

# ![chezmoi logo](assets/images/logo-144px.png) chezmoi

## Features

- **Cross-platform Support**: Automatically detects and supports Windows, macOS, and Linux
- **Intelligent Installation**: Uses the appropriate package manager for your system
- **Interactive Configuration**: Guides you through the setup process with clear prompts
- **Repository Management**: Options for using existing repositories or creating new ones
- **OS-specific Configuration**: Suggests relevant dotfiles based on your operating system
- **Template Creation**: Helps you create example templates to learn chezmoi's templating features
- **Password Manager Integration**: Optional setup for various password managers
- **Git Repository Setup**: Assistance with setting up a remote Git repository
- **Comprehensive Documentation**: Built-in usage instructions and examples

## Prerequisites

- Bash shell environment
- Internet connection (for installation)
- Basic knowledge of terminal usage
- Git (optional, for repository management)

## Installation

1. Download the script:

```bash
curl -o bootstrap.sh https://raw.githubusercontent.com/geiltonxavier/ChezmoiSetup/main/bootstrap.sh
```

2. Make it executable:

```bash
chmod +x bootstrap.sh
```

3. Run the script:

```bash
./bootstrap.sh
```

## Usage Guide

### Step 1: OS Detection & Installation

The script will:
1. Detect your operating system
2. Check if chezmoi is already installed
3. Install chezmoi using the appropriate method for your OS

Examples of installation methods:
- macOS: Homebrew or direct installation
- Linux: apt, dnf, pacman, snap, or direct installation
- Windows: Scoop, Chocolatey, Winget, or direct installation

### Step 2: Dotfiles Repository Setup

You'll be prompted to:
1. Use an existing dotfiles repository OR set up a new one
2. If using existing: provide the repository URL
3. If creating new: select which files to manage with chezmoi

For new repositories, the script will guide you through:
- Adding common configuration files (based on your OS)
- Adding custom files or directories
- Setting up a remote Git repository (optional)

### Step 3: Chezmoi Configuration

The script will help you create a `chezmoi.toml` configuration file with:
1. Basic user information (name, email)
2. Editor preferences
3. Password manager integration (optional)
4. Additional configuration options

Example configuration:

```toml
# chezmoi configuration file
[data]
    name = "Your Name"
    email = "your.email@example.com"

[diff]
    pager = "less"

[edit]
    command = "vim"
```

### Step 4: Template Examples

The script offers to create an example template file demonstrating:
- Variable substitution
- OS-specific configurations
- Hostname-specific settings
- Command output inclusion
- External file inclusion
- Secret management

This helps you learn chezmoi's powerful templating capabilities.

### Step 5: Usage Instructions

The script concludes by providing usage instructions for common chezmoi commands:
- Adding files
- Editing managed files
- Viewing and applying changes
- Working with templates and encrypted files

## Command Reference

After setup, you can use these common chezmoi commands:

| Command | Description |
|---------|-------------|
| `chezmoi add ~/.bashrc` | Add a file to chezmoi management |
| `chezmoi edit ~/.bashrc` | Edit a managed file |
| `chezmoi diff` | See what changes would be made |
| `chezmoi apply` | Apply changes to your home directory |
| `chezmoi update` | Pull and apply the latest changes from your repo |
| `chezmoi add --template ~/.config/file` | Add a file as a template |
| `chezmoi add --encrypt ~/.ssh/id_rsa` | Add an encrypted file |

## Troubleshooting

### Common Issues

1. **Script execution errors**:
   - Ensure the script has execute permissions (`chmod +x bootstrap.sh`)
   - Use bash explicitly if needed (`bash bootstrap.sh`)

2. **Installation failures**:
   - Check your internet connection
   - Try running the installation command manually
   - Ensure you have appropriate permissions (use sudo when needed)

3. **Repository access issues**:
   - Verify your Git credentials are configured
   - Check repository URL for typos
   - Ensure you have access permissions to the repository

4. **Template errors**:
   - Verify your template syntax
   - Use `chezmoi execute-template` to test templates
   - Check the chezmoi documentation for correct template usage

### Getting Help

If you encounter problems:
1. Check the [chezmoi documentation](https://www.chezmoi.io/docs/overview/)
2. Visit the [chezmoi GitHub repository](https://github.com/twpayne/chezmoi)
3. Open an issue in the repository where you found this script

## Advanced Configuration

### Custom Password Manager Integration

For password manager integration, the script supports:
- Bitwarden
- 1Password
- LastPass
- pass
- KeePassXC
- Vault
- gopass

You can configure these manually by editing `~/.config/chezmoi/chezmoi.toml`.

### Multiple Machine Setup

To use your chezmoi configuration on a new machine:

1. Install this script on the new machine
2. Choose "Use existing repository" when prompted
3. Enter your repository URL
4. Select "Apply immediately" to set up all your dotfiles at once

### Template Customization

Edit the template example at `$(chezmoi source-path)/dot_template_example` to:
- Add more OS-specific configurations
- Include role-based settings (work, personal, server, etc.)
- Configure application-specific settings
- Add more complex logic with template functions

## Contributing

Contributions to improve this script are welcome:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

This script is available under the MIT License.

## Acknowledgements

- [Chezmoi](https://www.chezmoi.io/) - The excellent dotfile manager
- [Tom Payne](https://github.com/twpayne) - Creator of chezmoi# ChezmoiSetup
