#!/usr/bin/env bash

# Operating-system specific setup: Unix

set -e

: "${username:="jason"}"
: "${isServer:=false}"
: "${dotfilesDirectory:="/home/$username/.dotfiles"}"
: "${defaultShell:="bash"}"

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

# Sets up private bin
if [[ -d "/home/$username/.bin" ]]; then
	success ".bin: Private bin is already set up"
else
	info ".bin: Private bin has not been setup, setting up now"
	mkdir /home/"$username"/.bin
	ln -s "$dotfilesDirectory"/bin/* /home/"$username"/.bin
	success ".bin: Private bin is now set up"
fi

# Sets up dev environments
	"$dotfilesDirectory"/unix/env-setup.sh
	"$dotfilesDirectory"/common/dev-setup.sh

# Setup nice diffing for git
	export PATH="/home/$username/.fancy:$PATH"
	if [[ $(which diff-so-fancy) == "" ]]; then
		info "Fancy Diff: Package was not found, downloading now"
		if git clone https://github.com/so-fancy/diff-so-fancy.git /home/"$username"/.fancy &> /dev/null ; then
			success "Fancy Diff: Package is now installed"
		else
			fail "Fancy Diff: Package failed to install"
		fi
	else
		success "Fancy Diff: Package is already installed, updating now"
		if git -C /home/"$username"/.fancy pull &> /dev/null ; then
			success "Fancy Diff: Package is now updated"
		else
			warn "Fancy Diff: Package failed to update"
		fi
	fi

# Checks all directory ownerships for changes, and resets them if necessary
	check=(.bin/ .dotfiles_cache/ .pyenv/ .rbenv/)
	for directory in "${check[@]}"; do
		if [[ $(ls -ld /home/"$username"/"${directory}" | awk '{print $3}') == "root" ]] || [[ $(ls -ld /home/"$username"/"${directory}" | awk '{print $4}') == "root" ]]; then
			info "Ownership: Directory ${directory} is owned by another user, attempting to change file ownership"
			if chown -R "$username":"$username" /home/"$username"/"${directory}" ; then
				success "Ownership: Directory ${directory}'s ownership is set correctly"
			else
				info "Ownership: Directory ${directory} is owned by an administrator, or this user does not have permisssions, attempting sudo change"
				if sudo chown -R "$username":"$username" /home/"$username"/"${directory}" ; then
					success "Ownership: Directory ${directory}'s ownership is set correctly"
				else
					fail "Ownership: Directory ${directory}'s ownership could not be changed"
				fi
			fi
		else
			success "Ownership: Directory ${directory}'s ownership is already set correctly"
		fi
	done
