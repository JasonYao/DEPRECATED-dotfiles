#!/usr/bin/env bash

# Operating-system specific setup: Unix

set -e

# Removes the OSX config file
	info "Deleting osx config file .bash_profile"
	rm $home/../.bash_profile

# Updates & upgrades
	sudo apt-get update -y
	sudo apt-get dist-upgrade -y

# Installs underlying packages
	apt-get install git -y					# Used in general project upkeep
	apt-get install wget -y					# Used in downloading python
	apt-get install checkinstall -y			# Used in checking in python to apt-get
	apt-get install build-essential -y		# Used in compiling python

# Alters SSH port to non-standard

# Installs ufw

# Installs fail2ban
