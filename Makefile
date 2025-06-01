install_ansible:
	brew install ansible

install_neovim:
	brew install neovim

restore_homebrew:
	brew bundle --file=Brewfile-backup

configure_vim:
	ansible-playbook vim.yml -i local -vv -e curdir=$(CURDIR)

install_dotfiles:
	# brew install sshrc
	ansible-playbook dotfiles.yml -i local -vv -e curdir=$(CURDIR)

setup: install_ansible install_neovim install_dotfiles

full_setup: install_ansible restore_homebrew install_dotfiles

.PHONY: install_ansible install_neovim restore_homebrew configure_vim install_dotfiles setup full_setup

