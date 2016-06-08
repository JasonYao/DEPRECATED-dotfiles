#!/usr/bin/env bash

# Operating-system specific setup: Unix

set -e

: ${username:="jason"}
: ${isServer:=false}
: ${dotfilesDirectory:="/home/$username/.dotfiles"}
: ${defaultShell:="bash"}

function rmSymlink ()
{
	symlinkToBeDeleted="/home/$username/$1"
    if [ -f "$symlinkToBeDeleted" ];
    then
        rm /home/$username/$1
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
	rmSymlink .bash_profile
	rmSymlink .env
	rmSymlink .nanorc_osx
	rmSymlink .listing_osx

# Sets the user's default shell to bash if it hasn't been done already
if [[ $(env | grep SHELL | grep $(which $defaultShell)) == "" ]]; then
    info "Setting user's default shell to $defaultShell"
    if [[ $(groups | grep -E 'root|sudo') != "" ]]; then
		# User has sudo or root, sets up the default shell
		if usermod -s $(which $defaultShell) $username ; then
			success "User's default shell has been set to $defaultShell"
		else
			fail "User's default shell has been set to $defaultShell"
		fi
	else
		info "Setting shell to $defaultShell"
		if [[ $(cat $home/.profile | grep "setenv SHELL") == ""  ]]; then
			echo "export SHELL=$(which bash)" >> $home/.profile
		else
			info "Shell is already set to $defaultShell"
		fi
		success "User's default shell has been set to $defaultShell"
	fi
fi

# Sets up correct nano settings
	nanorc_file="/home/$username/.nanorc"
	if [ -f "$nanorc_file" ];
	then
		success ".nanorc has already been set"
	else
		ln -s /home/$username/.nanorc_unix /home/$username/.nanorc
		chown -R "$username:$username" /home/$username/.nanorc
		success "Symlinked nanorc for unix"
	fi

if [ "$isServer" == "true" ]; then
	# Sets up correct motd settings
    if [[ $(ls -l /etc/update-motd.d | grep "00-header" | grep "\-rw\-r\-\-r\-\-") == "" ]]; then
        chmod -x /etc/update-motd.d/00-header
        success "MotD: Disabled header text"
    fi

    if [[ $(ls -l /etc/update-motd.d | grep "10-help-text" | grep "\-rw\-r\-\-r\-\-") == "" ]]; then
        chmod -x /etc/update-motd.d/10-help-text
        success "MotD: Disabled help text"
    fi

    if [[ $(ls -l /etc | grep "legal.backup") == "" ]]; then
        mv /etc/legal /etc/legal.backup
        success "MotD: Disabled legal notice"
    fi

	# Sets up unix dependencies if on a server environment
	info "Unix: installing dependencies"
	$dotfilesDirectory/bin/dot-unix
fi

# Sets up private bin
if [[ -d "/home/$username/.bin" ]]; then
	success ".bin: Private bin is already set up"
else
	info ".bin: Private bin has not been setup, setting up now"
	mkdir /home/$username/.bin
	ln -s $dotfilesDirectory/bin/* /home/$username/.bin
	success ".bin: Private bin is now set up"
fi
