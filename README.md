# Jason Yao's Dotfiles

## Description

My personal dotfiles, created in order to unify the experience across all OSX and *nix systems.

This based on a few select things from [Holman's repo](https://github.com/holman/dotfiles), so props to him for doing the legwork.

## Install

Run this:

```sh
git clone --recursive https://github.com/JasonYao/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --remote
./start.sh
```

This will symlink the appropriate files in `.dotfiles` to the home directory.
Everything is configured and tweaked within `~/.dotfiles`.

[dot](bin/dot) is a simple script that installs some dependencies, sets sane OS X
defaults, and so on.

[dot-unix](bin/dot-unix) is the linux specific version of dot (tested on ubuntu 14.04 & 15.10)

## License
License file for this repo is located [here](LICENSE.md)
