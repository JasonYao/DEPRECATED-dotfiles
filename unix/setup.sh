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
		success ".bash_profile has already been deleted"
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
