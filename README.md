# Lazy Dotfiles: Why do work when you can be lazy
By [Jason Yao](https://github.com/JasonYao/)

## Description
The following are my personal dotfiles,
created in order to unify the experience
across all `OSX` and `*nix` systems.

## Supported Platforms
- Ubuntu 16.04 LTS
- OSX 10.12.x (Sierra)

## Global key commands
- To toggle show/hide terminal:
<kbd>⌘</kbd> + <kbd>↓</kbd>

- To update + upgrade the dotfiles:
```sh
upgrade
```

- To uninstall the dotfiles:
```sh
uninstall
```

## Install
The following one-liner will setup
initial requirements before running
through a normal install via the [start script](start.sh)

```sh
bash -e "$(curl -fsSL https://raw.githubusercontent.com/JasonYao/dotfiles/master/start)"
```

## License
This repo is licensed under the terms of the
GNU GPL v3, of which a copy may be found [here](LICENSE).
