# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.


## Architecture Overview

This is a macOS dotfiles repository using Ansible for configuration management. The structure is:

### Core Components
- **Ansible Playbooks**: `dotfiles.yml` handles symlinking configuration files to their proper locations
- **Files Directory**: Contains all configuration files that get symlinked to home directory
- **Neovim**: Custom configuration based on kickstart.nvim with additional plugins in `custom/`

### Key Configuration Areas

#### Window Management (Yabai + SKHD)
- `files/yabairc` - Binary space partitioning window manager with 9 labeled spaces
- `files/skhdrc` - Hotkey daemon for window management keybindings
- Apps are automatically assigned to specific spaces (code, web, mail, notes, etc.)

#### Status Bar (SketchyBar)
- `files/sketchybar/` - Lua-based status bar configuration
- Custom event providers in C for CPU/network monitoring
- Modular widget system (battery, wifi, volume, VPN status)
- Requires building native components with makefiles

#### Terminal & Shell
- `files/zshrc` - Main zsh configuration
- `files/zsh/` - Additional zsh modules (aliases, fzf integration)
- `files/tmux.conf` - Terminal multiplexer configuration with TPM plugin manager
- `files/wezterm.lua` - Terminal emulator configuration

#### Development Tools
- `files/gitconfig` and `files/gitignore` - Git configuration
- `nvim/` - Neovim configuration with LSP, treesitter, telescope, and AI plugins
- `files/bin/` - Custom utility scripts

### Neovim Structure
- Based on kickstart.nvim framework
- Leader key: `,` (comma)
- Custom plugins in `lua/custom/plugins/`
- AI integration via `custom/plugins/ai.lua`
- Custom search functionality in `custom/select_and_search.lua`

### Installation Flow
1. Ansible installs tmux plugin manager and plugins
2. Creates necessary directories (.zsh.after, ~/bin, ~/.config)
3. Symlinks all configuration files from `files/` to appropriate locations
4. Sets up Neovim config symlink
5. Configures Karabiner for keyboard remapping

## Important Notes

- All configuration files are symlinked, not copied
- SketchyBar requires manual compilation of event providers
- Yabai requires SIP modifications for full functionality
- The setup assumes macOS with Homebrew installed
- TPM (tmux plugin manager) is automatically installed and configured
