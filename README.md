# Jason Yao's Dotfiles

## Dotfiles

My personal dotfiles, created in order to unify the experience across all OSX and *nix systems.

This based on a few select things from [Holman's repo](https://github.com/holman/dotfiles), so props to him for doing the leg work.

## Install

Run this:

```sh
git clone https://github.com/JasonYao/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./start.sh
```

This will symlink the appropriate files in `.dotfiles` to the home directory.
Everything is configured and tweaked within `~/.dotfiles`.

[dot](bin/dot) is a simple script that installs some dependencies, sets sane OS X
defaults, and so on.

TODO set up a cron job every 90 days to remind about running `dot` to keep the environment environment fresh and synced up.
You can find this script in [bin](bin).

## License
License file for this repo is located [here](LICENSE.md)
