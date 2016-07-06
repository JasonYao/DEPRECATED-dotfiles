#!/usr/bin/env bash

# Sets up basic server settings from scratch - NOTE: run before installing dotfiles

set -e

: "${username:="jason"}"
: "${password:="f%@nKc5K9kfgMdWHdCLsgvDjTuJXsc3H"}"
: "${isServer:=false}"
: "${defaultShell:="bash"}"
: "${dotfilesDirectory:="/home/$(whoami)/.dotfiles"}"
: "${sshPublicKey:="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPhNCsxxzqX4c0mKcEmuiDdjnaHg2eQtmaTR3RWolf8F Jason@Jasons-MacBook-Pro.local"}"

###
# Helper functions
##
function info () {
	printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}
function user () {
	printf "\r  [ \033[0;33m??\033[0m ] %s " "$1"
}
function success () {
	printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}
function warn () {
	printf "\r\033[2K  [\033[0;31mWARN\033[0m] %s\n" "$1"
}
function fail () {
	printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
	echo ''
	exit 1
}

function checkAndInstallPackage ()
{
	info "Checking for $1"
	if dpkg -s "$1" > /dev/null 2>&1 ; then
		success "$1 is already installed"
	else
		info "$1 not found, installing now"
		if sudo apt-get install "$1" -y > /dev/null ; then
			success "$1 successfully installed"
		else
			fail "$1 failed to install"
		fi
	fi
}

function change_substring ()
{
	search=$1
	replace=$2
	file=$3
	sed -i "s/${search}/${replace}/g" "${file}"
}

function checkAndSetAutoSettings ()
{
	change_substring "$1" "$2" /etc/apt/apt.conf.d/50unattended-upgrades
}

function checkAndAppendSettings ()
{
	if [[ $(grep "$1" "/etc/apt/apt.conf.d/20auto-upgrades") == "" ]]; then
		echo "$1" >> /etc/apt/apt.conf.d/20auto-upgrades
	fi
}

function updateAndUpgrade
{
	# Updates & upgrades
	info "Updating packages"
	if sudo apt-get update -y > /dev/null ; then
		success "Packages were updated"
	else
		fail "Packages were unable to be updated"
	fi

	info "Upgrading packages"
	if sudo apt-get dist-upgrade -y > /dev/null ; then
		success "Packages were upgraded"
	else
		fail "Packages were unable to be upgraded"
	fi
}

function autoRemove
{
	# Auto removes any unnecessary packages
	info "Auto removing any unnecessary packages"
	if sudo apt-get autoremove -y > /dev/null ; then
		success "All unnecessary packages removed"
	else
		fail "Unable to remove unnecessary packages"
	fi
}

function setupUserBaseline
{
	# Adds a new user if it doesn't exist
	if [[ $(grep "$username" $(cut -d: -f1 < /etc/passwd)) == "" ]]; then
		# Checks for input password for user, otherwise goes with default
		if [[ $password == "f%@nKc5K9kfgMdWHdCLsgvDjTuJXsc3H" ]]; then
			warn "Warning: Default password was used, please change user password to something else via \`sudo passwd $username\`"
		fi

		useradd -m -p "$password" -s "$(which "$defaultShell")" "$username"
		echo "$username:$password" | chpasswd
		success "Created user $username"
	else
		success "User $username already created"
	fi

	# Adds the user to the sudo group if it hasn't been done already
	if [[ $(grep root /etc/group | grep "$username") == "" ]]; then
		gpasswd -a "$username" sudo > /dev/null
		success "User $username has been added to the sudo group"
	else
		success "User $username has already been added to the sudo group"
	fi
}

function setupSSH
{
	# Secures SSH daemon
	# Makes a backup
	if [[ ! -d "/etc/ssh/sshd_config.backup" ]]; then
		info "SSHD: Creating a backup of /etc/ssh/sshd_config"
		cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
	fi

	# Sets it to a non-standard port
	change_substring "Port 22" "Port 30000" /etc/ssh/sshd_config
	success "SSHD: SSH Port is set to 30000"

	# Disallows root access
	change_substring "PermitRootLogin yes" "PermitRootLogin no" /etc/ssh/sshd_config
	success "SSHD: SSH root login is denied"

	# Allows ssh access for the user
	if [[ ! $(grep "AllowUsers $username" "/etc/ssh/sshd_config") ]]; then
		if [[ $(grep "AllowUsers" "/etc/ssh/sshd_config") == "" ]]; then
			echo "AllowUsers $username" >> /etc/ssh/sshd_config
		else
			change_substring "AllowUsers" "AllowUsers $username" /etc/ssh/sshd_config
		fi
			success "SSHD: $username has been added to the SSH access list"
	else
		success "SSHD: $username has already been added to the SSH access list"
	fi

	# Restarts ssh daemon
	service ssh restart
}

function setupAutoUpdate
{
	# Sets up automatic updating
	checkAndInstallPackage unattended-upgrades
	checkAndInstallPackage update-notifier-common

	if [[ ! -f "/etc/apt/apt.conf.d/20auto-upgrades" ]]; then
		# Creates an empty file
		> /etc/apt/apt.conf.d/20auto-upgrades
	fi

	checkAndAppendSettings "APT::Periodic::Update-Package-Lists \"1\";"
	checkAndAppendSettings "APT::Periodic::Unattended-Upgrade \"1\";"
	checkAndAppendSettings "APT::Periodic::AutocleanInterval \"7\";"

	checkAndSetAutoSettings "\/\/   \"\${distro_id}:\${distro_codename}-updates\";" "   \"\${distro_id}:\${distro_codename}-updates\";"
	checkAndSetAutoSettings "\/\/Unattended-Upgrade::Automatic-Reboot \"false\";" "Unattended-Upgrade::Automatic-Reboot \"true\";"
	checkAndSetAutoSettings "\/\/Unattended-Upgrade::Automatic-Reboot-Time \"02:00\";" "Unattended-Upgrade::Automatic-Reboot-Time \"02:00\";"
	success "Auto Updates: All configurations have been set"
}

function setupUFW
{
	# Sets up ufw (firewall)
	checkAndInstallPackage ufw

	# Alters the SSH default port that the ufw application uses
	change_substring "ports=22" "ports=30000" /etc/ufw/applications.d/openssh-server

	# Checks to make sure that the ssh port is setup
	if [[ $(ufw show added | grep "ufw limit OpenSSH") == "" ]]; then
		if ufw limit OpenSSH > /dev/null; then
			success "UFW: SSH port has been rate-limited"
		else
			fail "UFW: SSH port could not be rate-limited"
		fi
	fi

	# Checks that it's online and functioning
	if [[ $(ufw status | grep "inactive") != "" ]]; then
		echo "y" | ufw enable > /dev/null

		if [[ $(ufw status | grep "inactive") == "" ]]; then
			success "UFW: Firewall is now active"
		else
			fail "UFW: Unable to activate firewall"
		fi
	fi

	# Checks for sane defaults
	if [[ $(ufw status verbose | grep "deny (incoming)") == "" ]]; then
		if ufw default deny incoming > /dev/null ; then
			success "UFW: Default has been set, all incoming traffic is being denied"
		else
			fail "UFW: Default could not be set, all incoming traffic is allowed"
		fi
	fi

	if [[ $(ufw status verbose | grep "allow (outgoing)") == "" ]]; then
		if ufw default allow outgoing > /dev/null ; then
			success "UFW: Default has been set, all outgoing traffic is allowed"
		else
			fail "UFW: Default could not be set, all outgoing traffic is being denied"
		fi
	fi
}

function setupFail2Ban
{
	checkAndInstallPackage fail2ban				# Used in ip-banning on both nginx and ufw

	# Creates a local jail to use ufw
	if [ ! -f "/etc/fail2ban/jail.local" ]; then
		info "Fail2Ban: Creating local jail"
		{
			echo "[DEFAULT]"
			echo "ignoreip = 127.0.0.1/8"
			echo "banaction = ufw"
			echo "maxRetry = 5"
			echo "findtime = 600"
			echo "bantime = 7200"
		} >> /etc/fail2ban/jail.local
		success "Fail2Ban: Local jail created"
	fi

	service fail2ban restart
}

if [ "$isServer" == "true" ]; then
	# Does server setup
	updateAndUpgrade

	# Checks for dependency packages
	checkAndInstallPackage wget			# Used in general downloading
	checkAndInstallPackage git			# Used in general project upkeep
	checkAndInstallPackage unzip			# Used with dealing with cached dotfile files
	checkAndInstallPackages build-essential		# Used in pre-compiling rbenv

	# Checks for pyenv dependencies
	checkAndInstallPackages make
	checkAndInstallPackages libssl-dev
	checkAndInstallPackages zlib1g-dev
	checkAndInstallPackages libbz2-dev
	checkAndInstallPackages libreadline-dev
	checkAndInstallPackages libsqlite3-dev
	checkAndInstallPackages curl
	checkAndInstallPackages llvm
	checkAndInstallPackages libncurses5-dev
	checkAndInstallPackages xz-utils
	autoRemove

	setupUserBaseline
	setupSSH
	setupAutoUpdate
	setupUFW
	setupFail2Ban
fi

# Downloads and installs the dotfiles to the newly created user's directory
if [[ ! -d "$dotfilesDirectory" ]]; then
	info "Dotfiles: Downloading missing dotfiles"

	# Checks for git installation before using command
	if [[ $(which git) == "" ]]; then
		info "Downloading git dependency now"
		if sudo apt-get install git &> /dev/null; then
			success "Git dependency is now installed"
		else
			fail "Git dependency failed to install"
		fi
	else
		success "Git dependency is already installed"
	fi

	# Downloads the actual dotfiles
	if git clone --recursive https://github.com/JasonYao/dotfiles.git "$dotfilesDirectory" &> /dev/null ; then
		success "Dotfiles: Successfully downloaded dotfiles"
	else
		fail "Dotfiles: Unable to download dotfiles"
	fi
else
	info "Dotfiles: Updating prior downloaded dotfiles now"
	if git -C "$dotfilesDirectory" pull &> /dev/null ; then
		success "Dotfiles: Successfully updated dotfiles"
	else
		fail "Dotfiles: Unable to update dotfiles"
	fi
fi

# Sets up SSH key access for the user
	if [[ ! -d "$HOME/.ssh" ]]; then
		mkdir "$HOME"/.ssh
		chmod 700 "$HOME"/.ssh
		echo "$sshPublicKey" >> "$HOME"/.ssh/authorized_keys
		chmod 600 "$HOME"/.ssh/authorized_keys
		chown -R "$username":"$username" "$HOME"/.ssh
		success "Installed SSH key access for $username"
	fi
