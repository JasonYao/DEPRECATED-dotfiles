#!/usr/bin/env bash

##
# Operating-system specific setup: OSX
##

set -e

: ${username:="$(whoami)"}
: ${defaultShell:="bash"}
: ${dotfilesDirectory:="$HOME/.dotfiles"}
home="$dotfilesDirectory/.."

function install_dotfiles () {
	info 'Installing dotfiles'
	local overwrite_all=false backup_all=false skip_all=false

	for src in $(find -H "$dotfilesDirectory" -maxdepth 3 -name '*.symlink')
	do
		dst="$home/.$(basename "${src%.*}")"
		link_file "$src" "$dst"
	done
}

function rmSymlink () {
    symlinkToBeDeleted="$home/$1"
    if [ -f "$symlinkToBeDeleted" ];
    then
        rm $home/$1
        success "Deleted unix config file $1"
    else
        info "$1 has already been deleted"
    fi
}

# Symlinks all files
install_dotfiles

# Sets up message of the day tailing
	motd_file="/etc/motd"
	if [ -f "$motd_file" ];
	then
		info "MotD symlink already installed"
	else
		sudo ln -s $home/.motd /etc/motd
		success "MotD symlink installed"
	fi

# Removes unix config files
	rmSymlink .bashrc
	rmSymlink .nanorc_unix
	rmSymlink .listing_unix

# Sets up correct nano settings
	nanorc_file="$home/.nanorc"
	if [ -f "$nanorc_file" ];
	then
		info ".nanorc is already set"
	else
		ln -s $home/.nanorc_osx $home/.nanorc
		success "Symlinked .nanorc for osx"
	fi

# OSX dependency installation
info "OSX: installing dependencies"

# Sets OSX defaults
if $dotfilesDirectory/osx/set-defaults.sh ; then
	success "OSX: Sane defaults installed"
else
	fail: "OSX: Failed to set sane defaults"
fi

# Upgrade homebrew if not installed
if test ! $(which brew); then
	# No homebrew found: installs homebrew packages
	info "Homebrew: Installing fresh brew"
	$dotfilesDirectory/osx/homebrew/install.sh
else
	# Homebrew found: updates and upgrades
	info "Homebrew: Already installed, updating & upgrading"

	if brew update &> /dev/null ; then
		success "Homebrew: Successfully updated to the latest brew"
	else
		fail "Homebrew: Failed to update to the latest brew"
	fi

	if brew upgrade &> /dev/null ; then
		success "Homebrew: Successfully upgraded to the latest brew"
	else
		fail "Homebrew: Failed to upgrade to the latest brew"
	fi
fi

# Sets up development environment
	info "Development environment: Checking environment status"
	if $dotfilesDirectory/osx/dev-setup.sh; then
		success "Development environment: All environments are installed and ready"
	else
		fail "Development environment: Failed to install all environments correctly"
	fi

# Sets up iTerm environment
info "Terminal: Setting defaults"
if $dotfilesDirectory/osx/terminal/setup.sh; then
	success "Terminal: Defaults successfully set"
else
	fail "Terminal: Defaults failed to be set"
fi
