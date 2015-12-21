#!/usr/bin/env bash

# Sets up basic server settings from scratch

set -e

# Updates & upgrades
    sudo apt-get update -y
    sudo apt-get dist-upgrade -y

# Installs underlying packages
    sudo apt-get install git -y                  # Used in general project upkeep
    sudo apt-get install wget -y                 # Used in downloading python
    sudo apt-get install checkinstall -y         # Used in checking in python to apt-get
    sudo apt-get install build-essential -y      # Used in compiling python

# Alters SSH port to non-standard
	#TODO
# Installs ufw
	#TODO
# Installs fail2ban
	#TODO
