#!/usr/bin/env bash

##
# Installs cask applications
##

set -e

homebrew_packages=(
	google-chrome atom qbittorrent skype synergy filezilla
	flux vlc mactex texmaker torguard jetbrains-toolbox smcfancontrol
)

function check_homebrew_cask_package() {
	if [[ $(brew cask list | grep "$1") == "" ]]; then
		info "Homebrew-Cask: Package $1 has not been installed yet, installing now"
		brew tap homebrew/dupes
		if brew cask install "$1" ${flagged_packages[$1]} &> /dev/null ; then
			success "Homebrew-Cask: Package $1 is now installed"
		else
			fail "Homebrew-Cask: Package $1 failed to install"
		fi
	else
		success "Homebrew-Cask: Package $1 is already installed"
	fi
}

# Updates and upgrades brew packages
	info "Homebrew-Cask: Updating brews now"
	if brew cask update; then
		success  "Homebrew-Cask: Brews have been updated"
	else
		fail "Homebrew-Cask: Brews failed to be updated"
	fi

# Checks and installs any missing packages
	info "Homebrew-Cask: Checking installed packages"
	for package in "${homebrew_packages[@]}"; do
		check_homebrew_cask_package "${package}"
	done

	success "Homebrew-Cask: All packages installed"
