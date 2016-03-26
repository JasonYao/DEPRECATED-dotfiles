#!/usr/bin/env bash

##
# Operating-system specific setup: OSX
##

set -e

user=$(who am i | awk '{print $1}')

##
# Sets up message of the day tailing
##
	motd_file="/etc/motd"
	if [ -f "$motd_file" ];
	then
		info "MotD symlink already installed"
	else
		sudo ln -s /Users/$user/.motd /etc/motd
		success "MotD symlink installed"
	fi

##
# Removes unix config files
##
	# Gets rid of .bashrc
	profile_file="/Users/$user/.bashrc"
	if [ -f "$profile_file" ];
	then
		rm $home/../.bashrc
		success "Deleted unix config file .bashrc"
	else
		success ".bashrc was not found"
	fi

# Sets up correct nano settings
	nanorc_unix_file="/Users/$user/.nanorc_unix"
	if [ -f "$nanorc_unix_file" ];
	then
		rm $home/../.nanorc_unix
		success "Deleted unix config file .nanorc_unix"
	else
		info ".nanorc_unix was not found"
	fi

	nanorc_file="/Users/$user/.nanorc"
	if [ -f "$nanorc_file" ];
	then
		info ".nanorc is already set"
	else
		ln -s /Users/$user/.nanorc_osx /Users/$user/.nanorc
		success "Symlinked .nanorc for osx"
	fi

# Sets up correct listing settings
	listing_unix_file="/Users/$user/.listing_unix"
	if [ -f "$listing_unix_file" ];
	then
		rm $home/../.listing_unix
		success "Deleted unix config file .listing_unix"
	else
		info ".listing_unix is already removed"
	fi

##
# OSX dependency installation
##
info "OSX: installing dependencies"

# Sets OSX defaults
$home/osx/set-defaults.sh
success "OSX: Sane defaults installed"

# Upgrade homebrew if not installed
if test ! $(which brew); then
	# No homebrew found: installs homebrew packages
	info "Homebrew: Installing fresh brew"
	$home/osx/homebrew/install.sh
else
	# Homebrew found: updates and upgrades
	info "Homebrew: Already installed, updating & upgrading"
	brew update
	brew upgrade
	success "Homebrew: Successfully have the freshest brew"
fi
