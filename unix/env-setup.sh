#!/usr/bin/env bash

# Makes sure required development environments (pyenv, rbenv) are installed

set -e

# Pyenv
if [[ $(which pyenv) == "" ]]; then
	info "Developing Environments: Pyenv is not installed, installing now"

	# Checks for cache directory
	if [[ ! -d /home/"$username"/.dotfiles_cache ]]; then
		mkdir /home/"$username"/.dotfiles_cache
	fi

	# Checks for pyenv in the cache
	if [[ -f /home/$username/.dotfiles_cache/pyenv.zip ]]; then
		success "Developing Environments: Pyenv is in the cache"
	else
		info "Developing Environments: Pyenv was not found in the cache, downloading now"

		if wget https://github.com/yyuu/pyenv/archive/master.zip -O /home/"$username"/.dotfiles_cache/pyenv.zip -q --show-progress ; then
			success "Developing Environments: Pyenv is now downloaded and cached"
		else
			fail "Developing Environments: Pyenv failed to download"
		fi
	fi

	# Checks for pyenv directory
	info "Developing Environments: Checking pyenv directory"
	if [[ -d /home/$username/.pyenv ]]; then
		success "Developing Environments: Pyenv directory is already enabled, updating now"
		if git -C /home/"$username"/.pyenv pull &> /dev/null; then
			success "Developing Environments: Pyenv is fully updated"
		else
			fail "Developing Environments: Pyenv failed to update"
		fi
	else
		info "Developing Environments: Pyenv directory has not been extracted yet, extracting now"
		if unzip -q /home/"$username"/.dotfiles_cache/pyenv.zip -d /home/"$username" && mv /home/"$username"/pyenv-master /home/"$username"/.pyenv ; then
			success "Developing Environments: Pyenv directory is now extracted"
		else
			fail "Developing Environments: Pyenv failed to be extracted"
		fi
	fi
else
	success "Pyenv: Environment is already installed"
fi

# Pyenv-virtualenv
if [[ -d /home/$username/.pyenv/plugins/pyenv-virtualenv ]]; then
	success "Pyenv-virtualenv: Plugin is already installed, updating now"
	if git -C /home/"$username"/.pyenv/plugins/pyenv-virtualenv pull &> /dev/null ; then
		success "Pyenv-virtualenv: Plugin is now updated"
	else
		fail "Pyenv-virtualenv: Plugin failed to update"
	fi
else
	info "Pyenv-virtualenv: Plugin is not yet installed, installing now"
	if git clone https://github.com/yyuu/pyenv-virtualenv.git /home/"$username"/.pyenv/plugins/pyenv-virtualenv &> /dev/null ; then
		success "Pyenv-virtualenv: Plugin is now installed"
	else
		fail "Pyenv-virtualenv: Plugin failed to be installed"
	fi
fi

# Rbenv
if [[ $(which rbenv) == "" ]]; then
	info "Developing Environments: Rbenv is not installed, installing now"

	# Checks for rbenv in the cache
	if [[ -f /home/$username/.dotfiles_cache/rbenv.zip ]]; then
		success "Developing Environments: Rbenv is in the cache"
	else
		info "Developing Environments: Rbenv was not found in the cache, downloading now"

		if wget https://github.com/rbenv/rbenv/archive/master.zip -O /home/"$username"/.dotfiles_cache/rbenv.zip -q --show-progress ; then
			success "Developing Environments: Rbenv is now downloaded and cached"
		else
			fail "Developing Environments: Rbenv failed to download"
		fi
	fi

	# Checks for rbenv directory
	info "Developing Environments: Checking rbenv directory"
	if [[ -d /home/$username/.rbenv ]]; then
		success "Developing Environments: Rbenv directory is already enabled, updating now"
		if git -C /home/"$username"/.rbenv pull &> /dev/null; then
			success "Developing Environments: Rbenv is fully updated"
		else
			fail "Developing Environments: Rbenv failed to update"
		fi
	else
		info "Developing Environments: Rbenv directory has not been extracted yet, extracting now"
		if unzip -q /home/"$username"/.dotfiles_cache/rbenv.zip -d /home/"$username" && mv /home/"$username"/rbenv-master /home/"$username"/.rbenv ; then
			success "Developing Environments: Rbenv directory is now extracted"
		else
			fail "Developing Environments: Rbenv failed to be extracted"
		fi
	fi

	# Optional step: Compiles dynamic bash extension to speed up rbenv
	info "Developing Environments: [Optional] Checking rbenv pre-compilation status (speed increase)"
	if [[ -f /home/$username/.rbenv/src/realpath.o ]]; then
		success "Developing Environments: [Optional] Rbenv pre-compilation is already complete"
	else
		info "Developing Environments: [Optional] Rbenv pre-compilation is not complete, compiling now"
		if /home/"$username"/.rbenv/src/configure && make -C /home/"$username"/.rbenv/src > /dev/null ; then
			success "Developing Environments: [Optional] Rbenv pre-compilation is now complete"
		else
			warn "Developing Environments: [Optional] Rbenv pre-compilation failed, but rbenv command should still work"
		fi
	fi

	# Rbenv install setup
	export PATH="/home/$username/.rbenv/bin:$PATH"
	export RBENV_ROOT=/home/$username/.rbenv

	if which rbenv > /dev/null; then
		eval "$(rbenv init -)"
	fi

	if [[ $(rbenv install &> /home/"$username"/.dotfiles_cache/rbenv_install_test; grep "no such command" "/home/$username/.dotfiles_cache/rbenv_install_test") == "" ]]; then
		success "Developing Environments: Rbenv install plugin is already installed, updating now"
		if git pull -C /home/"$username"/.rbenv/plugins/ruby-build ; then
			success "Developing Environments: Rbenv install plugin is now updated"
		else
			warn "Developing Environments: Rbenv failed to update"
		fi
	else
		info "Developing Environments: Rbenv install plugin is not installed, downloading now"
		if git clone https://github.com/rbenv/ruby-build.git /home/"$username"/.rbenv/plugins/ruby-build &> /dev/null ; then
			success "Developing Environments: Rbenv install plugin is now installed"
		else
			fail "Developing Environments: Rbenv install plugin failed to install"
		fi
	fi
else
	success "Rbenv: Environment is already installed"
fi
