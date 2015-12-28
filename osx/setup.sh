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
	info "Deleting unix config file .bashrc"
	rm $home/../.bashrc
	success "Successfully deleted unix config file .bashrc"
else
	fail "OSX dependency installation failed"
fi

# Removes unix config files
	user=$(who am i | awk '{print $1}')

	# Gets rid of .bash_profile
	profile_file="/Users/$user/.bashrc"
	if [ -f "$profile_file" ];
	then
		info "Deleting unix config file .bashrc"
		rm $home/../.bash_profile
		success "Deleted unix config file .bashrc"
	else
		success ".bashrc was not found"
	fi

# Sets up correct nano settings
	nanorc_unix_file="/home/$user/.nanorc_unix"
	if [ -f "$nanorc_unix_file" ];
	then
		info "Deleting nano config file .nanorc_unix"
                rm $home/../.nanorc_unix
                success "Deleted osx config file .nanorc_unix"
        else
                info ".nanorc_unix was not found"
        fi

	nanorc_file="/home/$user/.nanorc"
	if [ -f "$nanorc_file" ];
	then
		info ".nanorc is already set"
	else
		info "Symlinking nano configs"
		ln -s /Users/$user/.nanorc_unix /Users/$user/.nanorc
		success "Symlinked nanorc for unix"
	fi
