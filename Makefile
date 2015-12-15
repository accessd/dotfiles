install_ansible:
	brew install ansible

configure_vim:
	ansible-playbook vim.yml -i local -vv -e curdir=$(CURDIR)

install_dotfiles:
	brew install sshrc
	ansible-playbook dotfiles.yml -i local -vv -e curdir=$(CURDIR)

