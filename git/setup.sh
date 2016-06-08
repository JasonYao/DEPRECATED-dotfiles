#!/usr/bin/env bash

# Configures git settings on the box

set -e

: ${git_editor:="nano"}
: ${git_username:="Jason Yao"}
: ${git_email:="jasony.edu@gmail.com"}

##
# Helper functions
##
function info () {
	printf "  [ \033[00;34m..\033[0m ] $1\n"
}
function user () {
	printf "\r  [ \033[0;33m?\033[0m ] $1\n"
}
function success () {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}
function fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}
function git_set() {
	if [[ $(git config -l | grep $1 | grep $2) == "" ]]; then
		git config --global $1 $2
		success "Git: Set $1 to $2"
	else
		info "Git: $1 has already been set to $2"
	fi
}

info "Git: Checking current environment"
git_set user.name $git_username
git_set user.email $git_email
git_set push.default simple
git_set color.ui auto
git_set core.editor $git_editor
success "Git: Environment installed!"
