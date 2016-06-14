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
		success "$3"
	else
		defaults write $1 $4
		success "$5"
	fi
}

# $1 = preference_name
# $2 = target_value
# $3 = not_enabled_info_message
# $4 = target_type_and_value
# $5 = message_success
# $6 = message_alread_complete
function check_and_set_dock() {
	if [[ $(defaults read com.apple.Dock | grep "$1 = $2") == "" ]]; then
		info "$3"
		defaults write com.apple.Dock $1 $4
		killall Dock
		success "$5"
	else
		success "$6"
	fi
}

# $1 = app_name
function check_and_manage_dock_apps() {
	if [[ $(defaults read com.apple.Dock persistent-apps | grep "$1") == "" ]]; then
		info "Dock: $1 is not set on the dock, setting now"
		defaults write com.apple.dock persistent-apps -array-add \
			"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/$1.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
		success "Dock: $1 is now set on the dock"
	else
		success "Dock: $1 is already set on the dock"
	fi
}

function repopulate_all_dock_apps() {
	check_and_manage_dock_apps "Launchpad"
	check_and_manage_dock_apps "Notes"
	check_and_manage_dock_apps "iTunes"
	check_and_manage_dock_apps "App Store"
	check_and_manage_dock_apps "System Preferences"
	check_and_manage_dock_apps "Firefox"
	killall Dock
}

# Does this once instead of doing all over each time
valid_apps=("launchpad" "Notes" "iTunes" "appstore" "systempreferences" "firefox")
invert_string="grep -v"
is_first=0

for app in ${valid_apps[@]}; do
    invert_string+=" -e \"${app}\""
done

function check_and_remove_bad_dock_apps() {
	if [[ $(defaults read com.apple.Dock persistent-apps | grep "bundle-identifier" | eval $invert_string) != "" ]]; then
		info "Dock: Contains non-default applications, killing off now"
		defaults delete com.apple.Dock persistent-apps
		killall Dock
		success "Dock: All non-default applications sanitised"
	else
		success "Dock: All non-default applications already sanitised"
	fi
	info "Dock: Checking for all default app existences"
	repopulate_all_dock_apps
	success "Dock: All default apps are in place"
}

function check_and_manage_dock_folders() {
	if [[ $(defaults read com.apple.Dock persistent-others | grep "$1;") == "" ]]; then
		info "Dock: $1 folder is not set on the dock, setting now"
		defaults write com.apple.dock persistent-others -array-add \
			"<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$1</string><key>_CFURLStringType</key><integer>0</integer></dict></dict><key>tile-type</key><string>directory-tile</string></dict>"
		success "Dock: $1 folder is now set on the dock"
	else
		success "Dock: $1 folder is already set on the dock"
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
	if [[ $(defaults read com.apple.Dock persistent-others | grep recents-tile) == "" ]]; then
		info "Dock: Recent applications stack is not installed, installing now"
		defaults write com.apple.dock persistent-others -array-add '{"tile-data" = {"list-type" = 1;}; "tile-type" = "recents-tile";}'; killall Dock
		success "Dock: Recent applications stack is now installed"
	else
		success "Dock: Recent applications stack is already installed"
	fi

# Sets up normal dock experience
	check_and_set_dock "autohide" "1" "Dock: Autohiding is not enabled, enabling now" "-bool true" "Dock: Autohiding is now enabled" "Dock: Autohiding is already enabled"
	check_and_set_dock "magnification" "1" "Dock: Magnification is not enabled, enabling now" "-bool true" "Dock: Magnification is now enabled" \
		"Dock: Magnification is already enabled"

	# Sets the size of icons (largesize == under magnification)
	check_and_set_dock "tilesize" "52" "Dock: Tilesize is not correctly set" "52" "Dock: Tilesize is now correctly set" "Dock: Tilesize is already correctly set"
	check_and_set_dock "largesize" "76" "Dock: Magnification tilesize is not correctly set" "-float 76" "Dock: Magnification tilesize is now correctly set" \
		"Dock: Magnification tilesize is already correctly set"

	# Enables recent applications stack in dock
	if [[ $(defaults read com.apple.Dock persistent-others | grep recents-tile) == "" ]]; then
		info "Dock: Recent applications stack is not installed, installing now"
		defaults write com.apple.dock persistent-others -array-add '{"tile-data" = {"list-type" = 1;}; "tile-type" = "recents-tile";}'
		killall Dock
		success "Dock: Recent applications stack is now installed"
	else
		success "Dock: Recent applications stack is already installed"
	fi

	# Minimises the apps in the dock to those useful
	check_and_remove_bad_dock_apps

	# Checks for applications folder existence in dock
	if [[ $(defaults read com.apple.dock persistent-others | grep "\"file-label\" = Applications;") == "" ]]; then
		info "Dock: Application folder not found, adding now"
		check_and_manage_dock_folders "Applications"
		killall Dock
	else
		success "Dock: Application folder is already on the dock"
	fi

	# Sets up app expose gesture
	check_and_set_dock "showAppExposeGestureEnabled" "1" "Trackpad: Show app expose gesture is not enabled" "1" "Trackpad: Show app expose gesture is now enabled" \
		"Trackpad: Show app expose gesture is already enabled"

# Disables bluetooth if enabled
	if [[ $(defaults read /Library/Preferences/com.apple.Bluetooth.plist | grep "BRPairedDevices") == "" ]]; then
		check_and_set_default "/Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState" 0 "Bluetooth: BT is already disabled" "-bool false" \
			"Bluetooth: BT is now disabled"
	fi

# Disables guest accounts if enabled
	check_and_set_default "/Library/Preferences/com.apple.loginwindow.plist GuestEnabled" 0 "User: Guest account is already disabled" "-bool false" \
		"User: Guest account is now disabled"

# Sets input languages
	# Checks for traditional chinese pinyin
	if [[ $(defaults read com.apple.HIToolbox.plist AppleEnabledInputSources | grep TCIM.Pinyin) == "" ]]; then
		info "Languages: Traditional Chinese input via pinyin is not installed, installing now"
		defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
			'<dict><key>Bundle ID</key><string>com.apple.inputmethod.TCIM</string><key>"Input Mode"</key><string>com.apple.inputmethod.TCIM.Pinyin</string> \
			<key>InputSourceKind</key><string>Input Mode</string></dict>'
		success "Languages: Traditional Chinese input via pinyin is now installed"
	else
		success "Languages: Traditional Chinese input via pinyin is already installed"
	fi

	if [[ $(defaults read com.apple.HIToolbox.plist AppleEnabledInputSources | grep .TCIM\" -A 1| grep "Keyboard Input Method") == "" ]]; then
		defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
			'<dict><key>Bundle ID</key><string>com.apple.inputmethod.TCIM</string><key>InputSourceKind</key><string>Keyboard Input Method</string></dict>'
	fi

	# Checks for traditional chinese hand writing
	if [[ $(defaults read com.apple.HIToolbox.plist AppleEnabledInputSources | grep ChineseHandwriting) == "" ]]; then
		info "Languages: Traditional Chinese input via hand writing is not installed, installing now"
		defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
			'<dict><key>Bundle ID</key><string>com.apple.inputmethod.ChineseHandwriting</string><key>InputSourceKind</key><string>Non Keyboard Input Method</string></dict>'
		success "Languages: Traditional Chinese input via hand writing is now installed"
	else
		success "Languages: Traditional Chinese input via hand writing is already installed"
	fi

# Disables indexing and searching of the bootcamp volume if it's named bootcamp (case insensitive)
	if [[ $(diskutil list | grep -i bootcamp) != "" ]]; then
		if [[ $(sudo mdutil -s /Volumes/$(diskutil list | grep -io bootcamp) | grep disabled) == "" ]]; then
			sudo mdutil -i off -d /Volumes/$(diskutil list | grep -io bootcamp)
			success "Spotlight: Disabled indexing & searching of bootcamp partition"
		else
			success "Spotlight: Indexing & searching of bootcamp partition already disabled"
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
