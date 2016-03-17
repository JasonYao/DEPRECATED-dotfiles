#!/usr/bin/env bash

# Operating-system specific setup: Unix

set -e

# Removes OSX config files
	user=$(who am i | awk '{print $1}')

	# Gets rid of .bash_profile
	profile_file="/home/$user/.bash_profile"
	if [ -f "$profile_file" ];
	then
		rm $home/../.bash_profile
		success "Deleted osx config file .bash_profile"
	else
		info ".bash_profile has already been deleted"
	fi

	# Gets rid of .env
    env_file="/home/$user/.env"
    if [ -f "$env_file" ];
    then
        rm $home/../.env
        success "Deleted osx config file .env"
    else
        info ".env has already been deleted"
    fi

# Sets up correct nano settings
	nanorc_osx_file="/home/$user/.nanorc_osx"
	if [ -f "$nanorc_osx_file" ];
	then
		rm $home/../.nanorc_osx
		success "Deleted osx config file .nanorc_osx"
	else
		success ".nanorc_osx has already been deleted"
	fi

	nanorc_file="/home/$user/.nanorc"
	if [ -f "$nanorc_file" ];
	then
		success ".nanorc has already been set"
	else
		ln -s /home/$user/.nanorc_unix /home/$user/.nanorc
		success "Symlinked nanorc for unix"
	fi

# Sets up correct listing files
	listing_osx_file="/home/$user/.listing_osx"
	if [ -f "$listing_osx_file" ];
	then
		rm $home/../.listing_osx
		success "Deleted osx config file .listing_osx"
	else
		success ".listing_osx has already been deleted"
	fi

info "Unix: installing dependencies"

if source bin/dot-unix > /tmp/dotfiles-dot-unix 2>&1
then
	success "Unix: dependencies installed"
else
	fail "Unix: dependency installation failed"
fi
