#!/usr/bin/env bash

# Configures git settings on the box

set -e

##
# Helper functions
##
info () {printf "  [ \033[00;34m..\033[0m ] $1"}
user () {printf "\r  [ \033[0;33m?\033[0m ] $1 "}
success () {printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"}
fail () {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
  echo ''
  exit
}

info "setting up git environment"

# Sets the name
git config --global user.name "Jason Yao"
success "Git name set to Jason Yao"

# Sets the email
git config --global user.email "jasony.edu@gmail.com"
success "Git email set to jasony.edu@gmail.com"

success "Git environment installed!"
