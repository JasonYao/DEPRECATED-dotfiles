# Lazy Dotfiles: Why do work when you can be lazy
By Jason Yao

## Description
The following are my personal dotfiles, created in order to unify the experience 
across all `OSX` and `*nix` systems.

Specifically, this repo sets sane defaults that are used daily in `OSX` settings, 
along with basic server setup that would otherwise be tedious to setup, including:
- Non-root user creation
- Dotfile installation for user
- Setup of user's SSH key
- Changes the default SSH settings to more secure defaults (non-standard port, non-root access, etc.)
- Package auto-update setup
- `ufw` (server firewall) & `fail2ban` (ip-ban) setup

## Install
The following one-liner will setup initial requirements before running through a normal install via the [start script](start.sh)

### OSX
```sh
curl -O https://raw.githubusercontent.com/JasonYao/dotfiles/master/start.sh &> /dev/null && bash start.sh; rm -rf start.sh
```

### Unix
For a unix server environment
```sh
wget https://raw.githubusercontent.com/JasonYao/dotfiles/master/start.sh &> /dev/null && \
username="jason" password="YOUR PASSWORD HERE" isServer=true bash start.sh; rm -rf start.sh
```

For a unix personal environment
```sh
wget https://raw.githubusercontent.com/JasonYao/dotfiles/master/start.sh &> /dev/null && bash start.sh; rm -rf start.sh
```

To override values, you can do so by putting it in front of `bash start.sh`

Values available for being overwritten:
- Username: `username="YOUR USERNAME HERE"`
- Password: `password="YOUR PASSWORD HERE"`
- IsServer: `isServer=true` || `isServer=false` *
- Default Shell: `defaultShell="bash"` || `defaultShell="zsh"`
- Dotfiles Directory: `dotfilesDirectory="ABSOLUTE/PATH/TO/FOLDER/YOU'D/LIKE/TO/STORE/THE/DOTFILES/IN"`
- SSH Public Key: `sshPublicKey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGEB2lB73L2NmzRIfFuQCRvfSyi1Imy8KK/b5mjus44O Jason@Jasons-MacBook-Pro.local"`

* NOTE: The default is that isServer is false, so no real need to pass this flag in entirely if it is not a server environment

This will symlink the appropriate files in `.dotfiles` to the home directory.
Everything is configured and tweaked within `~/.dotfiles`.

## Thanks
This based on a few select things from [Holman's repo](https://github.com/holman/dotfiles),
so props to him for doing the legwork.

## License
This repo is licensed under the terms of the GNU GPL, of which a copy may be found [here](LICENSE)
