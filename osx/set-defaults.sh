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

# Set show battery defaults
	defaults write com.apple.menuextra.battery ShowPercent -bool true

# Removes iCloud as the default save location
	defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# Disables indexing and searching of the bootcamp volume if it's named bootcamp (case insensitive)
if [[ $(diskutil list | grep -i bootcamp) != "" ]]; then
	if [[ $(sudo mdutil -s /Volumes/$(diskutil list | grep -io bootcamp) | grep disabled) == "" ]]; then
		sudo mdutil -i off -d /Volumes/$(diskutil list | grep -io bootcamp)
		success "Spotlight: Disabled indexing & searching of bootcamp partition"
	else
		info "Spotlight: Indexing & searching of bootcamp partition already disabled"
	fi
else
	info "Spotlight: No bootcamp partition detected"
fi

# Disables "natural" scrolling
if [[ $(defaults read -g com.apple.swipescrolldirection) == 0 ]]; then
     info "Trackpad: Natural scrolling is already disabled"
else
	defaults write -g com.apple.swipescrolldirection -bool FALSE
	success "Trackpad: Natural scrolling is now disabled"
fi

# Disables .DS_Store files on network volumes
	defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Sets the firewall rules
	checkAndSetFirewall "--getblockall" "DISABLED" "--setblockall on" "default to deny incoming traffic" "Default to deny incoming traffic"
	checkAndSetFirewall "--getstealthmode" "disabled" "--setstealthmode on" "default to activate stealth mode" "Stealth mode"
	checkAndSetFirewall "--getloggingmode" "off" "--setloggingmode on" "default to log traffic" "Traffic logging"
	checkAndSetFirewall "--getglobalstate" "disabled" "--setglobalstate on" "firewall to on" "Firewall"
	checkAndSetFirewall "--getallowsigned" "DISABLED" "--setallowsigned on" "default to allow signed binaries" "Allowing signed binaries"
