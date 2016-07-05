#!/usr/bin/env bash

##
# Operating-system specific setup: OSX
##

set -e

: "${username:="$(whoami)"}"
: "${defaultShell:="bash"}"
: "${dotfilesDirectory:="$HOME/.dotfiles"}"

function install_dotfiles () {
	info 'Installing dotfiles'
	local overwrite_all=false backup_all=false skip_all=false

	for src in $(find -H "$dotfilesDirectory" -maxdepth 3 -name '*.symlink')
	do
		dst="$HOME/.$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done
}

# Symlinks all files
install_dotfiles

# Sets up message of the day tailing
	motd_file="/etc/motd"
	if [ -f "$motd_file" ];
	then
		info "MotD symlink already installed"
	else
		sudo ln -s "$HOME"/.motd /etc/motd
		success "MotD symlink installed"
	fi

# OSX dependency installation
	info "OSX: installing dependencies"

# Sets OSX defaults
	if "$dotfilesDirectory"/osx/set-defaults.sh ; then
		success "OSX: Sane defaults installed"
	else
		fail "OSX: Failed to set sane defaults"
	fi

# Installs/upgrades homebrew
	"$dotfilesDirectory"/osx/homebrew/install.sh

# Sets up development environment
	info "Development environment: Checking environment status"
	if "$dotfilesDirectory"/common/dev-setup.sh; then
		success "Development environment: All environments are installed and ready"
	else
		fail "Development environment: Failed to install all environments correctly"
	fi

# Sets up iTerm environment
	info "Terminal: Setting defaults"
	if "$dotfilesDirectory"/osx/terminal/setup.sh; then
		success "Terminal: Defaults successfully set"
	else
		fail "Terminal: Defaults failed to be set"
	fi
