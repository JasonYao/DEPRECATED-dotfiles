#!/usr/bin/env bash

# Sets reasonable OS X defaults

set -e

firewall="/usr/libexec/ApplicationFirewall/socketfilterfw"

# Usage: checkAndSetFirewall "--getblockall" "DISABLED" "--setblockall on" "default to deny incoming traffic" "Default to deny incoming traffic"
function checkAndSetFirewall ()
{
	if [[ $($firewall $1 | grep "$2") != "" ]]; then
		if sudo $firewall $3 > /dev/null ; then
			success "Firewall: Successfully set $4"
		else
			fail "Firewall: Failed to set $4"
		fi
	else
		success "Firewall: $5 has already been set"
	fi
}

# Disable press-and-hold for keys in favor of key repeat
	defaults write -g ApplePressAndHoldEnabled -bool false

# Set a really fast key repeat
	defaults write NSGlobalDomain KeyRepeat -int 0

# Set the Finder prefs for showing a few different volumes on the Desktop
	defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
	defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# Sets the firewall rules
	checkAndSetFirewall "--getblockall" "DISABLED" "--setblockall on" "default to deny incoming traffic" "Default to deny incoming traffic"
	checkAndSetFirewall "--getstealthmode" "disabled" "--setstealthmode on" "default to activate stealth mode" "Stealth mode"
	checkAndSetFirewall "--getloggingmode" "off" "--setloggingmode on" "default to log traffic" "Traffic logging"
	checkAndSetFirewall "--getglobalstate" "disabled" "--setglobalstate on" "firewall to on" "Firewall"
	checkAndSetFirewall "--getallowsigned" "DISABLED" "--setallowsigned on" "default to allow signed binaries" "Allowing signed binaries"
