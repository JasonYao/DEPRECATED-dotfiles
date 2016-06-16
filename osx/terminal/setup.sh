#!/usr/bin/env bash

# Sets sane iTerm preferences

set -e

iterm_info_plist="/Applications/iTerm.app/Contents/Info.plist"
iterm_download_link="https://iterm2.com/downloads/beta/iTerm2-3_0_1-preview.zip"

# Sets up fonts
	if [[ $(ls /Users/Jason/Library/Fonts/ | grep FreeMono) == "" ]]; then
		info "Font: FreeMono is not installed yet, installing now"
		cp $dotfilesDirectory/osx/terminal/font/FreeMono.ttf /Users/$(whoami)/Library/Fonts/
		success "Font: FreeMono is now installed"
	else
		success "Font: FreeMono is already installed"
	fi

# Sets up iTerm application
	if [[ -d "/Applications/iTerm.app" ]]; then
		success "iTerm: Application has been already installed"
	else
		info "iTerm: Application has not been installed, installing now"
		wget $iterm_download_link -O $HOME/Desktop/iTerm.zip -q --show-progress
		# Since unzip didn't end up decompressing correctly (application image was not there), we'll use the system's Archive Utility.app instead
		open -a /System/Library/CoreServices/Applications/Archive\ Utility.app/ $HOME/Desktop/iTerm.zip
		mv ~/Desktop/iTerm.app /Applications
		success "iTerm: Application is now installed"
	fi

# Disable warning when quitting
	if [[ $(defaults read com.googlecode.iterm2 PromptOnQuit) == 0 ]]; then
		success "iTerm: Warning when quitting is already disabled"
	else
		info "iTerm: Warning when quitting is not disabled, disabling now"
		defaults write com.googlecode.iterm2 PromptOnQuit -bool false
		success "iTerm: Warning when quitting is now disabled"
	fi

# Sets up preference loading
	if [[ $(defaults read com.googlecode.iterm2 | grep Peppermint) == "" ]]; then
		info "iTerm: Preference loading is disabled, enabling now"
		defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$dotfilesDirectory/osx/terminal/"
		defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
		success "iTerm: Preference loading is now enabled"
	else
		success "iTerm: Preference loading is already enabled"
	fi

# Runs iTerm as a process in the background
	if [[ $(tail $iterm_info_plist | grep "</plist>" -B 3 | grep "LSUIElement") != "" ]]; then
		success "iTerm: Application is already backgrounded"
	else
		info "iTerm: Application is not backgrounded yet, backgrounding now"
		perl -i -0pe 's/<\/dict>\n<\/plist>/\t<key>LSUIElement<\/key>\n\t<true\/>\n<\/dict>\n<\/plist>/' $iterm_info_plist
		success "iTerm: Application is now backgrounded"
	fi
