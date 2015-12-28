#!/usr/bin/env bash

# Operating-system specific setup: OSX

set -e

##
# Dependency setup
##

info "OSX: installing dependencies"

if source bin/dot > /tmp/dotfiles-dot 2>&1
then
	success "OSX dependencies installed"
else
	fail "OSX dependency installation failed"
fi

# Removes unix config files
	user=$(who am i | awk '{print $1}')

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
		success ".nanorc is already set"
	else
		ln -s /Users/$user/.nanorc_osx /Users/$user/.nanorc
		success "Symlinked nanorc for unix"
	fi

# Sets up correct listing settings
	listing_unix_file="/Users/$user/.listing_unix"
	if [ -f "$listing_unix_file" ];
	then
		rm $home/../.listing_unix
		success "Deleted unix config file .listing_unix"
	else
		success ".listing_unix is already removed"
	fi
