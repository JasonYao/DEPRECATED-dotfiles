#!/usr/bin/env bash

# Sets up basic server settings from scratch
# NOTE: run before installing dotfiles
set -e

###
# Helper functions
##
function info () {
	printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}
function user () {
	printf "\r  [ \033[0;33m??\033[0m ] %s " "$1"
}
function success () {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}
function warn () {
	printf "\r\033[2K  [\033[0;31mWARN\033[0m] %s\n" "$1"
}
function fail () {
	printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
	echo ''
	exit 1
}

function checkAndInstallPackage () {
	info "Checking for $1"
	if dpkg -s "$1" > /dev/null 2>&1 ; then
		success "$1 is already installed"
	else
		info "$1 not found, installing now"
		if sudo apt-get install "$1" -y > /dev/null ; then
			success "$1 successfully installed"
		else
			fail "$1 failed to install"
		fi
	fi
}

function updateAndUpgrade () {
	# Updates & upgrades
	info "Updating packages"
	if sudo apt-get update -y > /dev/null ; then
		success "Packages were updated"
	else
		fail "Packages were unable to be updated"
	fi

	info "Upgrading packages"
	if sudo apt-get dist-upgrade -y > /dev/null ; then
		success "Packages were upgraded"
	else
		fail "Packages were unable to be upgraded"
	fi
}

function autoRemove () {
	# Auto removes any unnecessary packages
	info "Auto removing any unnecessary packages"
	if sudo apt-get autoremove -y > /dev/null ; then
		success "All unnecessary packages removed"
	else
		fail "Unable to remove unnecessary packages"
	fi
}

# Does first-time initial setup if the user has root/sudo privileges
if [[ $(groups | grep 'root\|admin\|sudo') != "" ]]; then
	# Does server setup
	updateAndUpgrade

	# Checks for dependency packages
	checkAndInstallPackage wget				# Used in general downloading
	checkAndInstallPackage git				# Used in general project upkeep
	checkAndInstallPackage unzip			# Used with dealing with cached dotfile files
	checkAndInstallPackage build-essential	# Used in pre-compiling rbenv

	# Checks for pyenv dependencies
	checkAndInstallPackage make
	checkAndInstallPackage libssl-dev
	checkAndInstallPackage zlib1g-dev
	checkAndInstallPackage libbz2-dev
	checkAndInstallPackage libreadline-dev
	checkAndInstallPackage libsqlite3-dev
	checkAndInstallPackage curl
	checkAndInstallPackage llvm
	checkAndInstallPackage libncurses5-dev
	checkAndInstallPackage xz-utils
	autoRemove
fi
