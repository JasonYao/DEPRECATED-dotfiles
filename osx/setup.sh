#!/usr/bin/env bash

##
# Operating-system specific setup: OSX
##

set -e

: "${username:="$(whoami)"}"
: "${defaultShell:="bash"}"
: "${dotfilesDirectory:="$HOME/.dotfiles"}"
number_of_spaces=3

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
	# Checks to make sure that the latest GNU bash is used, 
	# since associative arrays are only in bash 4+
	if [[ $(which brew) == "" ]]; then
		echo "\r" | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	fi

	if [[ $(which bash) == "/bin/bash" ]]; then
		brew install bash
	fi

	/usr/local/bin/bash "$dotfilesDirectory"/osx/homebrew/install.sh

# Sets up development environment
	info "Development environment: Checking environment status"
	if /usr/local/bin/bash "$dotfilesDirectory"/common/dev-setup.sh; then
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

# Sets up designated spaces
	warn "Spaces: This setup is broken on macOS Sierra, please wait for a patch to fix this issue"
#	info "Spaces: Checking for $number_of_spaces spaces"
#	if [[ $(defaults read com.apple.spaces | grep name | wc -l) < $number_of_spaces ]]; then
#		info "Spaces: Currently only $(defaults read com.apple.spaces | grep name | wc -l) spaces are set up, adding now"
#		while [[ $(defaults read com.apple.spaces | grep name | wc -l) < $number_of_spaces ]]; do
#			if osascript $HOME/.dotfiles/osx/scripts/add_space &> /dev/null; then
#				success "Spaces: $(defaults read com.apple.spaces | grep name | wc -l) spaces now setup"
#			else
#				fail "Spaces: Failed to setup spaces, please check accessability to see if iTerm has control permissions"
#			fi
#		done
#	else
#		success "Spaces: $number_of_spaces spaces are already set up"
#	fi

# Sets up background images
	info "Background Image: Checking background image"
	# Note the enclosing single quotes around bash variables when trying to use them in applescripts
	if osascript -e 'tell application "System Events" to set picture of every desktop to ("'$dotfilesDirectory'/img/background1.png" as POSIX file as alias)' ; then
		success "Background: Desktop image is now correctly set"
	else
		fail "Background: Desktop image failed to be set"
	fi
