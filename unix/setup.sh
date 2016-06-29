#!/usr/bin/env bash

# Operating-system specific setup: Unix

set -e

: "${username:="jason"}"
: "${isServer:=false}"
: "${dotfilesDirectory:="/home/$username/.dotfiles"}"
: "${defaultShell:="bash"}"

function rmSymlink ()
{
	symlinkToBeDeleted="/home/$username/$1"
    if [ -f "$symlinkToBeDeleted" ];
    then
        rm /home/"$username"/"$1"
        success "Deleted osx config file $1"
    else
        info "$1 has already been deleted"
    fi
}

function install_dotfiles () {
  info 'Installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false

  for src in $(find -H "$dotfilesDirectory" -maxdepth 3 -name '*.symlink')
  do
    dst="$dotfilesDirectory/../.$(basename "${src%.*}")"
    link_file "$src" "$dst"
  done
}

# Symlinks all files
	install_dotfiles

# Removes OSX config files
	rmSymlink .env

# Sets the user's default shell to bash if it hasn't been done already
if [[ $(env | grep SHELL | grep "$(which "$defaultShell")") == "" ]]; then
    info "Setting user's default shell to $defaultShell"
    if [[ $(groups | grep -E 'root|sudo') != "" ]]; then
		# User has sudo or root, sets up the default shell
		if usermod -s "$(which "$defaultShell")" "$username" ; then
			success "User's default shell has been set to $defaultShell"
		else
			fail "User's default shell has been set to $defaultShell"
		fi
	else
		info "Setting shell to $defaultShell"
		if [[ $(grep "setenv SHELL" "/home/$username/.profile") == "" ]]; then
			echo "export SHELL=$(which bash)" >> /home/"$username"/.profile
		else
			info "Shell is already set to $defaultShell"
		fi
		success "User's default shell has been set to $defaultShell"
	fi
fi

if [ "$isServer" == "true" ]; then
	# Sets up correct motd settings
    if [[ $(echo /etc/update-motd.d/* | grep "00-header" | grep "\-rw\-r\-\-r\-\-") == "" ]]; then
        chmod -x /etc/update-motd.d/00-header
        success "MotD: Disabled header text"
    fi

    if [[ $(echo /etc/update-motd.d/* | grep "10-help-text" | grep "\-rw\-r\-\-r\-\-") == "" ]]; then
        chmod -x /etc/update-motd.d/10-help-text
        success "MotD: Disabled help text"
    fi

    if [[ $(echo /etc/* | grep "legal.backup") == "" ]]; then
        mv /etc/legal /etc/legal.backup
        success "MotD: Disabled legal notice"
    fi
fi

# Sets up private bin
if [[ -d "/home/$username/.bin" ]]; then
	success ".bin: Private bin is already set up"
else
	info ".bin: Private bin has not been setup, setting up now"
	mkdir /home/"$username"/.bin
	ln -s "$dotfilesDirectory"/bin/* /home/"$username"/.bin
	success ".bin: Private bin is now set up"
fi
