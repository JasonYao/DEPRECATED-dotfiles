#!/usr/bin/env bash

# Startup script to bootstrap calling the correct dotfile setup script

set -e

###
# Helper functions
##
function info () {
	printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

function user () {
	printf "\r  [ \033[0;33m?\033[0m ] $1 "
}

function success () {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

function warn () {
  printf "\r\033[2K  [\033[0;31mWARNING\033[0m] $1\n"
}

function fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

function checkAndInstallPackage () {
    info "Checking for $1"
    if dpkg -s $1 > /dev/null 2>&1 ; then
        success "$1 is already installed"
    else
        info "$1 not found, installing now"
        if sudo apt-get install $1 -y &> /dev/null ; then
            success "$1 successfully installed"
        else
            fail "$1 failed to install"
        fi
    fi
}

function link_file () {
  local src=$1 dst=$2

  local overwrite= backup= skip=
  local action=

  if [ -f "$dst" -o -d "$dst" -o -L "$dst" ]
  then

    if [ "$overwrite_all" == "false" ] && [ "$backup_all" == "false" ] && [ "$skip_all" == "false" ]
    then

      local currentSrc="$(readlink $dst)"

      if [ "$currentSrc" == "$src" ]
      then

        skip=true;

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -n 1 action

        case "$action" in
          o )
            overwrite=true;;
          O )
            overwrite_all=true;;
          b )
            backup=true;;
          B )
            backup_all=true;;
          s )
            skip=true;;
          S )
            skip_all=true;;
          * )
            ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [ "$overwrite" == "true" ]
    then
      rm -rf "$dst"
      success "Removed $dst"
    fi

    if [ "$backup" == "true" ]
    then
      mv "$dst" "${dst}.backup"
      success "Moved $dst to ${dst}.backup"
    fi

    if [ "$skip" == "true" ]
    then
      success "Skipped $src"
    fi
  fi

  if [ "$skip" != "true" ]  # "false" or empty
  then
    ln -s "$1" "$2"
	if [ "$(uname -s)" == "Linux" ]; then
		chown -R "$username:$username" "$2"
	fi

    success "Linked $1 to $2"
  fi
}

: ${username:="$(whoami)"}
: ${password:=""}
: ${isServer:=false}
: ${defaultShell:="bash"}
: ${dotfilesDirectory:="$HOME/.dotfiles"}
: ${sshPublicKey:="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGEB2lB73L2NmzRIfFuQCRvfSyi1Imy8KK/b5mjus44O Jason@Jasons-MacBook-Pro.local"}
home="$dotfilesDirectory/.."

if [[ "$dotfilesDirectory" == "/root/.dotfiles" ]]; then
	dotfilesDirectory="/home/$username/.dotfiles"
	home="$dotfilesDirectory/.."
fi

# Exports functions and var for all following script calls
export -f info
export -f user
export -f success
export -f fail
export -f warn
export -f link_file
export -f checkAndInstallPackage

export username
export isServer
export defaultShell
export dotfilesDirectory
export home

if [[ ! -d "$dotfilesDirectory" ]]; then
	# No dotfiles found, download now
	if [ "$(uname -s)" == "Darwin" ]; then
		# OSX: Downloads dotfiles
		if git clone --recursive https://github.com/JasonYao/dotfiles.git $dotfilesDirectory &> /dev/null; then
			success "Downloaded dotfiles successfully"
		else
			fail "Failed to download dotfiles"
		fi
		info "OS detected was: OSX, running OSX setup script now"
		bash $dotfilesDirectory/osx/setup.sh 2>&1
	else
		# Unix: Downloads dotfiles
		info "Downloading init script"
		wget https://raw.githubusercontent.com/JasonYao/dotfiles/master/unix/init.sh > /dev/null 2>&1 && \
		username=$username password=$password isServer=$isServer defaultShell=$defaultShell dotfilesDirectory=$dotfilesDirectory sshPublicKey=$sshPublicKey \
		bash init.sh; rm -rf init.sh
		chown -R $username:$username $dotfilesDirectory
		info "OS detected was: Unix, running unix setup script now"
		$dotfilesDirectory/unix/setup.sh 2>&1
	fi
else
	# Dotfiles have been found, updates
	info "Dotfiles already downloaded, updating now"
	if  git -C $dotfilesDirectory pull --quiet &&  git -C $dotfilesDirectory submodule update --remote &> /dev/null; then
		success "Dotfiles: Successfully updated dotfiles"
	else
		fail "Dotfiles: Unable to update dotfiles"
	fi
	if [ "$(uname -s)" == "Darwin" ]; then
		$dotfilesDirectory/osx/setup.sh 2>&1
	else
		$dotfilesDirectory/unix/setup.sh 2>&1
	fi
fi
