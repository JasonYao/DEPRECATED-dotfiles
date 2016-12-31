#!/usr/bin/env bash

# Install script for homebrew on an OSX system

set -e

homebrew_packages=(
	coreutils wget autoconf automake make nano openssl pyenv pyenv-virtualenv
	jenv mmv cmake rbenv bash readline diff-so-fancy unrar nmap kubernetes-cli pv
	grep gnu-tar gnu-sed gawk gzip shellcheck vim node sbt
)

# Any packages that requires flags upon install should be both above and here
declare -A flagged_packages
flagged_packages[grep]=--with-default-names
flagged_packages[gnu-sed]=--with-default-names
flagged_packages[gnu-tar]=--with-default-names

function check_homebrew_package() {
	if [[ $(brew list | grep "$1") == "" ]]; then
		info "Homebrew: Package $1 has not been installed yet, installing now"
		brew tap homebrew/dupes
		if brew install "$1" ${flagged_packages[$1]} &> /dev/null ; then
			success "Homebrew: Package $1 is now installed"
		else
			fail "Homebrew: Package $1 failed to install"
		fi
	else
		success "Homebrew: Package $1 is already installed"
	fi
}

# Installs homebrew if not installed
	if test ! "$(which brew)" ; then
		info "Homebrew: Package manager was not found, installing now"
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
		success "Homebrew: successfully installed"
	fi

# Updates and upgrades brew packages
	info "Homebrew: Updating brews now"
	if brew update; then
		success  "Homebrew: Brews have been updated"
	else
		fail "Homebrew: Brews failed to be updated"
	fi

	info "Homebrew: Upgrading brews now"
	if brew upgrade; then
		success "Homebrew: Brews have been upgraded"
	else
		fail "Homebrew: Brews failed to upgrade"
	fi

# Checks and installs any missing packages
	info "Homebrew: Checking installed packages"
	for package in "${homebrew_packages[@]}"; do
		check_homebrew_package "${package}"
	done

	success "Homebrew: All packages installed"

# Runs the cask script
	info "Homebrew: Checking cask app status"
	if "$dotfilesDirectory"/osx/homebrew/cask.sh; then
		success "Homebrew: Cask apps are successfully installed"
	else
		fail "Homebrew: Cask apps failed to be successfully installed"
	fi
