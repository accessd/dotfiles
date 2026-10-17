## Accessd dotfiles


### How to install

    git clone git@github.com:accessd/dotfiles.git
    make setup

### Requirements (macOS)

* macOS
* zsh
* git
* homebrew

### Omarchy

Installs Neovim, tmux, Zsh and Git configs, Arch dependencies, zsh-z, TPM and
editor plugins. Run as your normal user; package installation uses Omarchy's
privilege handling.

```bash
cd ~/dotfiles
make setup_omarchy
# Optional: also change the login shell (requests your password)
./bootstrap-omarchy.sh --change-shell
```

Configs are symlinked to this checkout. Existing configs and the previous Neovim
runtime are moved to `~/.local/state/dotfiles/backups/<timestamp>-<pid>/` (respects
XDG directories). Repeated runs keep correct links and existing plugin clones.
The previous `~/.config/git/config` is backed up so it cannot override this Git
setup; machine-specific Git settings belong in `~/.gitconfig.user`.

Use `--skip-packages` or `--skip-plugins` to install configs without those steps.
Start with `exec zsh`; tmux uses **Ctrl+a**, Neovim uses **comma** as leader.
Existing tmux sessions are left running; new servers load the config. AI plugins
require their own authentication; language tools are installed by Mason on first use.

The Omarchy installer also links `files/hypr/input.lua` and
`files/hypr/bindings.lua` into `~/.config/hypr/`, backing up previous files:

- **Caps Lock** acts as **Ctrl**.
- Layouts: **English (US)** and **Russian**.
- **Left Alt** and **Left Super** are swapped: physical Left Alt runs Super shortcuts.
- Tap **Super** (physical **Left Alt**) for English; tap **Right Alt** for Russian (on release).

The remaining Hyprland configuration stays managed by Omarchy. When installing
inside a running Hyprland session, the script reloads and checks its configuration.

### Copy projects from another machine

Run `./sync-projects.sh` to copy `macbook.local:~/projects/` into local
`~/projects/` over SSH, or pass another SSH host. Requires rsync on both
machines (modern rsync on the receiving machine). Use `--dry-run` to preview.
Includes hidden files, `.git`, dependencies and build outputs. Local files are
never deleted; replaced files are backed up under
`${XDG_STATE_HOME:-~/.local/state}/projects-sync/<timestamp>-<pid>/`.
Rerun after an interrupted transfer to continue. This copies files; dependencies
and binaries built on macOS may need rebuilding on Linux.

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
