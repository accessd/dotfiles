#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
config_dir=${XDG_CONFIG_HOME:-$HOME/.config}
state_dir=${XDG_STATE_HOME:-$HOME/.local/state}
backup_dir="$state_dir/dotfiles/backups/$(date +%Y%m%d-%H%M%S)-$$"
install_packages=true
install_plugins=true
change_shell=false

usage() {
  cat <<'EOF'
Usage: ./bootstrap-omarchy.sh [options]
  --skip-packages  Only configure files; do not install Arch packages
  --skip-plugins   Do not download Zsh, tmux or Neovim plugins
  --change-shell   Also make Zsh the login shell (may request a password)
  -h, --help      Show this help

Run as your normal user, not as root. Existing files are moved to
${XDG_STATE_HOME:-~/.local/state}/dotfiles/backups/<timestamp>-<pid>/.
Rerunning keeps existing correct symlinks and plugin checkouts.
EOF
}

for arg in "$@"; do
  case "$arg" in
    --skip-packages) install_packages=false ;;
    --skip-plugins) install_plugins=false ;;
    --change-shell) change_shell=true ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n' "$arg" >&2; usage >&2; exit 1 ;;
  esac
done

if (( EUID == 0 )); then
  echo 'Run this script as your normal user, without sudo.' >&2
  exit 1
fi
if ! command -v omarchy >/dev/null || ! command -v pacman >/dev/null; then
  echo 'This installer requires Omarchy (Arch Linux).' >&2
  exit 1
fi

if "$install_packages"; then
  omarchy pkg add zsh zsh-completions zsh-autosuggestions zsh-syntax-highlighting \
    neovim tmux git git-delta ripgrep fd fzf jq wl-clipboard \
    base-devel cmake curl unzip tree-sitter-cli
fi

# Move whole files/directories, including dangling symlinks, without deleting them.
backup() {
  local target=$1 relative
  [[ -e "$target" || -L "$target" ]] || return 0
  relative=${target#"$HOME"/}
  if [[ "$relative" == "$target" ]]; then
    relative="external/${target#/}"
  fi
  mkdir -p -- "$backup_dir/$(dirname -- "$relative")"
  mv -- "$target" "$backup_dir/$relative"
  printf 'Backup: %s -> %s\n' "$target" "$backup_dir/$relative"
}

link() {
  local source=$1 target=$2
  if [[ -L "$target" && $(readlink -- "$target") == "$source" ]]; then
    return 0
  fi
  backup "$target"
  mkdir -p -- "$(dirname -- "$target")"
  ln -s -- "$source" "$target"
  printf 'Link: %s -> %s\n' "$target" "$source"
}

# LazyVim's old runtime must not leak into this independent Neovim setup.
if [[ ! -L "$config_dir/nvim" || $(readlink -- "$config_dir/nvim") != "$repo_dir/nvim" ]]; then
  backup "${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
  backup "$state_dir/nvim"
  backup "${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
fi
link "$repo_dir/nvim" "$config_dir/nvim"
link "$repo_dir/files/zshrc" "$HOME/.zshrc"
for module in "$repo_dir"/files/zsh/*.zsh; do
  link "$module" "$HOME/.zsh.after/$(basename -- "$module")"
done
link "$repo_dir/files/tmux.conf" "$HOME/.tmux.conf"
link "$repo_dir/files/tmux.conf" "$config_dir/tmux/tmux.conf"
link "$repo_dir/files/tmux-agent-layout" "$HOME/.tmux/tmux-agent-layout"
link "$repo_dir/files/gitconfig" "$HOME/.gitconfig"
link "$repo_dir/files/gitignore" "$HOME/.gitignore"
# Git reads both locations. Keep Omarchy's previous settings in the backup,
# rather than combining two conflicting global configurations.
backup "$config_dir/git/config"
for helper in clip-copy clip-paste tm tmux-gitmux latest-screenshot \
  ai-response-to-editor.sh ai-scroll-to-last-response.sh; do
  link "$repo_dir/files/bin/$helper" "$HOME/bin/$helper"
done

# Omarchy loads these personal overrides after its packaged Hyprland defaults.
link "$repo_dir/files/hypr/input.lua" "$config_dir/hypr/input.lua"
link "$repo_dir/files/hypr/bindings.lua" "$config_dir/hypr/bindings.lua"
if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]] && command -v hyprctl >/dev/null; then
  hyprctl reload
  config_errors=$(hyprctl configerrors)
  if [[ -n "${config_errors//[[:space:]]/}" ]]; then
    printf 'Hyprland configuration errors:\n%s\n' "$config_errors" >&2
    exit 1
  fi
fi

clone_once() {
  local url=$1 target=$2
  if [[ -d "$target/.git" ]]; then
    return 0
  fi
  if [[ -e "$target" || -L "$target" ]]; then
    printf 'Not a Git checkout: %s; move it aside and retry.\n' "$target" >&2
    exit 1
  fi
  mkdir -p -- "$(dirname -- "$target")"
  git clone --depth 1 "$url" "$target"
}

if "$install_plugins"; then
  clone_once https://github.com/agkozak/zsh-z.git "$HOME/.zsh-z"
  clone_once https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"
  # Install plugins on a private tmux server, leaving live sessions alone.
  tmux_socket="dotfiles-install-$$"
  cleanup() { tmux -L "$tmux_socket" kill-server 2>/dev/null || true; }
  trap cleanup EXIT
  tmux -L "$tmux_socket" -f /dev/null new-session -d -s dotfiles-install
  tmux -L "$tmux_socket" source-file "$HOME/.tmux.conf"
  socket_path=$(tmux -L "$tmux_socket" display-message -p '#{socket_path}')
  TMUX="$socket_path,0,0" "$HOME/.tmux/plugins/tpm/bin/install_plugins"
  tmux -L "$tmux_socket" source-file "$HOME/.tmux.conf"
  cleanup
  trap - EXIT
  nvim --headless '+Lazy! sync' +qa
fi

if "$change_shell"; then
  zsh_path=$(command -v zsh)
  current_shell=$(getent passwd "$(id -un)" | cut -d: -f7)
  if [[ "$current_shell" != "$zsh_path" ]]; then
    chsh -s "$zsh_path"
  fi
fi

printf '\nOmarchy dotfiles installed. Backups (if any): %s\n' "$backup_dir"
echo 'Start Zsh: exec zsh'
echo 'To make Zsh the login shell: chsh -s /usr/bin/zsh (then log out and back in).'
echo 'tmux prefix: Ctrl+a. Neovim leader: comma. AI plugins may need authentication.'
