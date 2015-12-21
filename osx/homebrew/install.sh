#!/usr/bin/env bash

# Install script for homebrew on an OSX system

set -e

# Installs homebrew if not installed
if test ! $(which brew)
then
	info "Installing Homebrew for you"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"  
fi

# Install homebrew packages
brew install grc coreutils wget autoconf automake make nano openssl

exit 0
