#!/usr/bin/env bash

# Operating-system specific setup: Unix

set -e

# Removes OSX config files
	user=$(who am i | awk '{print $1}')

	# Gets rid of .bash_profile
	profile_file="/home/$user/.bash_profile"
	if [ -f "$profile_file" ];
	then
		info "Deleting osx config file .bash_profile"
	        rm $home/../.bash_profile
	        success "Deleted osx config file .bash_profile"
	else
		info ".bash_profile was not found"
	fi

# Sets up correct nano settings
	nanorc_osx_file="/home/$user/.nanorc_osx"
	if [ -f "$nanorc_osx_file" ];
	then
		info "Deleting nano config file .nanorc_osx"
                rm $home/../.nanorc_osx
                success "Deleted osx config file .nanorc_osx"
        else
                info ".nanorc_osx was not found"
        fi

	nanorc_file="/home/$user/.nanorc"
	if [ -f "$nanorc_file" ];
	then
		info ".nanorc is already set"
	else
		info "Symlinking nano configs"
		ln -s /home/$user/.nanorc_unix /home/$user/.nanorc
		success "Symlinked nanorc for unix"
	fi

# Updates & upgrades
	sudo apt-get update -y
	sudo apt-get dist-upgrade -y

# Installs underlying packages
	sudo apt-get install git -y					# Used in general project upkeep
	sudo apt-get install wget -y					# Used in downloading python
	sudo apt-get install checkinstall -y			# Used in checking in python to apt-get
	sudo apt-get install build-essential -y		# Used in compiling python

# Alters SSH port to non-standard

# Installs ufw

# Installs fail2ban
