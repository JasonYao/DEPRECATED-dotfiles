#!/usr/bin/env bash

# Install script for homebrew on an OSX system

set -e

homebrew_packages=(coreutils wget autoconf automake make nano openssl pyenv pyenv-virtualenv \
					jenv mmv cmake rbenv bash readline diff-so-fancy unrar nmap kubernetes-cli pv)

function check_homebrew_package() {
	if [[ $(brew list | grep $1) == "" ]]; then
		info "Homebrew: Package $1 has not been installed yet, installing now"
		brew tap homebrew/dupes
		if brew install $1 &> /dev/null ; then
			success "Homebrew: Package $1 is now installed"
		else
			fail "Homebrew: Package $1 failed to install"
		fi
	else
		success "Homebrew: Package $1 is already installed"
	fi
}

# Installs homebrew if not installed
	if test ! $(which brew) ; then
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		success "Homebrew: successfully installed"
	fi

# Checks and installs any missing packages
	info "Homebrew: Checking installed packages"
	for package in ${homebrew_packages[@]}; do
		check_homebrew_package ${package}
	done

	success "Homebrew: All packages installed"
