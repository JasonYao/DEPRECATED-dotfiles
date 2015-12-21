#!/usr/bin/env bash

# Configures git settings on the box

set -e

info "setting up git environment"

# Sets the name
git config --global user.name "Jason Yao"
success "Git name set to Jason Yao"

# Sets the email
git config --global user.email "jasony.edu@gmail.com"
success "Git email set to jasony.edu@gmail.com"

success "Git environment installed!"
