#!/usr/bin/env bash

# Sets reasonable OS X defaults

set -e

firewall="/usr/libexec/ApplicationFirewall/socketfilterfw"

# Usage: checkAndSetFirewall "--getblockall" "DISABLED" "--setblockall on" "default to deny incoming traffic" "Default to deny incoming traffic"
function checkAndSetFirewall () {
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

# $1 = plist_source
# $2 = target_value
# $3 = message_already_complete
# $4 = target_type_and_value
# $5 = message_success
function check_and_set_default() {
	if [[ $(defaults read $1) == $2 ]]; then
		info "$3"
	else
		defaults write $1 $4
		success "$5"
	fi
}

# Disable press-and-hold for keys in favor of key repeat
	check_and_set_default "-g ApplePressAndHoldEnabled" 0 "Keyboard: Press & hold has already been disabled" "-bool false" "Keyboard: Press & hold has been disabled"

# Sets a really fast key repeat
	check_and_set_default "NSGlobalDomain KeyRepeat" 0 "Keyboard: 0-delay key repeat has already been enabled" "-int 0" "Keyboard: 0-delay key repeat has been enabled"

# Sets the Finder prefs for showing a few different volumes on the Desktop
	check_and_set_default "com.apple.finder ShowHardDrivesOnDesktop" 1 "Finder: Show hard drives on desktop is already enabled" "-bool true" "Finder: Show hard drives on desktop is now enabled"
	check_and_set_default "com.apple.finder ShowExternalHardDrivesOnDesktop" 1 "Finder: Show external hard drives on desktop is already enabled" "-bool true" \
		"Finder: Show external hard drives on desktop is now enabled"
	check_and_set_default "com.apple.finder ShowRemovableMediaOnDesktop" 1 "Finder: Show removable media on desktop is already been enabled" "-bool true" \
		"Finder: Show removable media on desktop is now enabled"

# Sets battery percentage to be shown
	check_and_set_default "com.apple.menuextra.battery ShowPercent" 1 "Battery: Show percent battery remaining is already enabled" "-bool true" "Battery: Show percent battery is now enabled"

# Sets the trackpad speed to max (to set to another value, set between 0 ~ 3, to disable set to -1)
	check_and_set_default "-g com.apple.trackpad.scaling" 3.0 "Trackpad: Tracking speed is already max" "3.0" "Trackpad: Tracking speed is now set to max"

# Disables "natural" scrolling
    check_and_set_default "-g com.apple.swipescrolldirection" 0 "Trackpad: Natural scrolling is already disabled" "-bool FALSE" "Trackpad: Natural scrolling is now disabled"

# Sets up app expose gesture
	check_and_set_default "com.apple.Dock showAppExposeGestureEnabled" 1 "Trackpad: Show app expose gesture is already enabled" "-bool true" "Trackpad: Show app expose gesture is now enabled"

# Removes iCloud as the default save location
	check_and_set_default "NSGlobalDomain NSDocumentSaveNewDocumentsToCloud" 0 "iCloud: Default save location is already set to local drive" "-bool false" \
		"iCloud: Default save location is now set to the local drive"

# Disables .DS_Store files on network volumes
    check_and_set_default "com.apple.desktopservices DSDontWriteNetworkStores" 1 "iCloud: .DS_Store file writing is already disabled on network drives" "-bool true" \
		"iCloud: .DS_Store file writing is now disabled on network drives"

# Enables recent applications stack in dock
	if [[ $(defaults read com.apple.dock persistent-others | grep recents-tile) == "" ]]; then
		info "Dock: Recent applications stack is not installed, installing now"
		defaults write com.apple.dock persistent-others -array-add '{"tile-data" = {"list-type" = 1;}; "tile-type" = "recents-tile";}'; killall Dock
		success "Dock: Recent applications stack is now installed"
	else
		info "Dock: Recent applications stack is already installed"
	fi

# Sets up normal dock experience
	check_and_set_default "com.apple.Dock autohide" 1 "Dock: Autohiding is already enabled" "-bool true; killall Dock" "Dock: Autohiding is now enabled"
	check_and_set_default "com.apple.Dock magnification" 1 "Dock: Magnification is already enabled" "-bool true; killall Dock" "Dock: Magnification is now enabled"

# Sets the size of icons (largesize == under magnification)
	check_and_set_default "com.apple.Dock tilesize" 52 "Dock: Normal tile size is already set" "52" "Dock: Normal tile size is now set"
	check_and_set_default "com.apple.Dock largesize" 76 "Dock: Magnification size is already set" "76" "Dock: Magnification size is now set"

# Disables bluetooth if enabled
	check_and_set_default "/Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState" 0 "Bluetooth: BT is already disabled" "-bool false" \
		"Bluetooth: BT is now disabled"

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

# Sets the firewall rules
	checkAndSetFirewall "--getblockall" "DISABLED" "--setblockall on" "default to deny incoming traffic" "Default to deny incoming traffic"
	checkAndSetFirewall "--getstealthmode" "disabled" "--setstealthmode on" "default to activate stealth mode" "Stealth mode"
	checkAndSetFirewall "--getloggingmode" "off" "--setloggingmode on" "default to log traffic" "Traffic logging"
	checkAndSetFirewall "--getglobalstate" "disabled" "--setglobalstate on" "firewall to on" "Firewall"
	checkAndSetFirewall "--getallowsigned" "DISABLED" "--setallowsigned on" "default to allow signed binaries" "Allowing signed binaries"
