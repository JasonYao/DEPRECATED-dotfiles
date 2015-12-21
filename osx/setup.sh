#!/usr/bin/env bash

# Operating-system specific setup: OSX

set -e

##
# Dependency setup
##

info "OSX: installing dependencies"

if source bin/dot > /tmp/dotfiles-dot 2>&1
then
	success "OSX dependencies installed"
	info "Deleting unix config file .bashrc"
	rm $home/../.bashrc
	success "Successfully deleted unix config file .bashrc"
else
	fail "OSX dependency installation failed"
fi
