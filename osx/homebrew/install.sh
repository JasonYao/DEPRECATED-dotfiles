#!/usr/bin/env bash

# Install script for homebrew on an OSX system

set -e

# Installs homebrew if not installed
if test ! $(which brew)
then
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	success "Homebrew: successfully installed"
fi

# Install homebrew packages
info "Homebrew: Installing common packages"
brew tap homebrew/dupes
brew install coreutils wget autoconf automake make nano openssl pyenv pyenv-virtualenv jenv mmv cmake rbenv
success "Homebrew: All packages installed"
