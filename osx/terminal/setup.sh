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
		# Needs a wait since mv command doesn't wait for archive utility to unzip, only waits for it to open
		sleep 3
		mv ~/Desktop/iTerm.app /Applications
		success "iTerm: Application is now installed"
	fi

# Checks if application preferences have been installed
	if [[ -f $HOME/Library/Preferences/com.googlecode.iterm2.plist ]]; then
		success "iTerm: Preferences have already been linked"
	else
		info "iTerm: Preferences have not been linked, linking now"
		ln -s $dotfilesDirectory/osx/terminal/com.googlecode.iterm2.plist $HOME/Library/Preferences/com.googlecode.iterm2.plist
		success "iTerm: Preferences have now been linked"
		warn "iTerm: Warning, good preferences have been set, but requires a logout or restart to be enabled"
	fi

# Runs iTerm as a process in the background
	if [[ $(tail $iterm_info_plist | grep "</plist>" -B 3 | grep "LSUIElement") != "" ]]; then
		success "iTerm: Application is already backgrounded"
	else
		info "iTerm: Application is not backgrounded yet, backgrounding now"
		perl -i -0pe 's/<\/dict>\n<\/plist>/\t<key>LSUIElement<\/key>\n\t<true\/>\n<\/dict>\n<\/plist>/' $iterm_info_plist
		success "iTerm: Application is now backgrounded"
	fi
