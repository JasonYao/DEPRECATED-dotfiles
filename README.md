# Lazy Dotfiles: Why do work when you can be lazy
By [Jason Yao](https://github.com/JasonYao/)

## Description
The following are my personal dotfiles,
created in order to unify the experience
across all `macOS` and `*nix` systems.

## Features
- Sets sane defaults
- Downloads a bunch of useful commandline tools (GNU tools, wget, bash v4+, vim, node, etc.)
- [macOS only] Downloads a bunch of useful applications ([Firefox](https://www.mozilla.org/en-US/firefox/),  [smcFanControl](https://www.eidac.de/), [JetBrains Toolbox](https://www.jetbrains.com/toolbox/), [vlc](https://www.videolan.org/vlc/index.html), etc.)

- Secures and locks down the system via proper firewalling
- Sets up proper dev environments (Python, Java, Ruby, Golang)
- Sets up proper git environment with a better [diff](https://github.com/so-fancy/diff-so-fancy)
- [macOS only] Adds iTerm 2 [shell integrations](https://www.iterm2.com/documentation-shell-integration.html)

## Supported Platforms
- macOS 10.12.x+ (Sierra+)
- Ubuntu 16.04 LTS

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

## Install Instructions
The following one-liner will setup
initial requirements before running
through a normal install via the [start script](start.sh)

```sh
curl -s https://raw.githubusercontent.com/JasonYao/dotfiles/master/start | bash
```

## License
This repo is licensed under the terms of the
GNU GPL v3, of which a copy may be found [here](LICENSE).
