#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  echo "Finish the Xcode Command Line Tools installation, then rerun this script."
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

brew tap arl/arl
brew trust --formula arl/arl/gitmux
brew tap jesseduffield/lazydocker
brew trust --formula jesseduffield/lazydocker/lazydocker
brew bundle --file="$repo_dir/Brewfile.hal9000"
ansible-playbook "$repo_dir/dotfiles.yml" \
  -i "$repo_dir/inventories/hal9000" \
  -e "curdir=$repo_dir"
mise install

if [[ ! -s "$HOME/.ssh/authorized_keys" ]]; then
  echo "Refusing to disable SSH passwords: ~/.ssh/authorized_keys is empty."
  exit 1
fi

sudo -v
sudo scutil --set ComputerName hal9000
sudo scutil --set LocalHostName hal9000
sudo scutil --set HostName hal9000
sudo systemsetup -setremotelogin on
sudo install -m 0644 "$repo_dir/files/ssh/99-hal9000.conf" /etc/ssh/sshd_config.d/99-hal9000.conf
if ! sudo /usr/sbin/sshd -t; then
  sudo rm -f /etc/ssh/sshd_config.d/99-hal9000.conf
  echo "Invalid SSH configuration removed."
  exit 1
fi
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /usr/libexec/sshd-keygen-wrapper
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp /usr/libexec/sshd-keygen-wrapper
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
sudo pmset -c sleep 0

echo "hal9000 bootstrap complete."
echo "Next: open Docker and Karabiner once, then run 'codex login' and 'claude'."
