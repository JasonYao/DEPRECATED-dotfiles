# Lazy Dotfiles: Why do work when you can be lazy
By [Jason Yao](https://github.com/JasonYao/)

## Description
The following are my personal dotfiles,
created in order to unify the experience
across all `OSX` and `*nix` systems.

These dotfiles are [midot](https://github.com/JasonYao/midot)
compliant, allowing for easy install, uninstall,
and upgrading.

## Supported Platforms
- Ubuntu 16.04 LTS
- OSX 10.12.x (Sierra)

## Install
The following one-liner will setup
initial requirements before running
through a normal install via the [start script](start.sh)

```sh
bash -e "$(curl -fsSL https://raw.githubusercontent.com/JasonYao/dotfiles/master/start)"
```

This will symlink the appropriate
files in `~/.dotfiles` to the home
directory. Everything is configured
and tweaked within `~/.dotfiles`.

## License
This repo is licensed under the terms of the
GNU GPL v3, of which a copy may be found [here](LICENSE).
