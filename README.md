## Accessd dotfiles


### How to install

    git clone git@github.com:accessd/dotfiles.git
    make setup

### Requrements

* macOS
* zsh
* git
* homebrew

### hal9000

The hal9000 profile installs Codex CLI, Claude Code, Docker Desktop, Chrome,
Karabiner Elements, WezTerm, Kubernetes tools, OpenVPN, and the shared terminal
environment. It skips yabai, skhd, and SketchyBar.

    git clone https://github.com/accessd/dotfiles.git ~/dotfiles
    cd ~/dotfiles
    make setup_hal9000

After bootstrap:

1. Open Docker Desktop and Karabiner Elements once to finish their macOS setup.
2. Run `codex login`.
3. Run `claude` and complete browser authentication.
4. Start agents manually in tmux.
