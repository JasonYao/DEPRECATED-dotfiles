#!/usr/bin/env bash

# Sets up the development environments

set -e

# Python env stuff
	python_versions=(3.5.2 2.7.12)

# Java env stuff
	declare -A java_version
	java_version[1.8]=8u102
	java_version[1.7]=7u80

	# We do this because oracle is a bitch and their java 7 download with b14 is corrupted
	declare -A java_bin
	java_bin[1.8]=b14
	java_bin[1.7]=b15

# Ruby env stuff
	ruby_versions=(2.3.1)

# Python check and set
	if [[ $(which pyenv) == "" ]] && [[ $(uname -s) == "Linux" ]]; then
		export PYENV_ROOT=/home/$username/.pyenv
		export PATH="$PYENV_ROOT/bin:$PATH"
	fi

	for version in "${python_versions[@]}"; do
		if [[ $(pyenv versions | grep "${version}") == "" ]]; then
			info "Pyenv: Python version ${version} is not installed yet, installing now"

			# Checks if pyenv has the correct version first
			info "Pyenv: Checking for python version ${version}"
			if [[ $(pyenv install --list | grep "${version}") == "" ]]; then
				fail "Pyenv: Python version ${version} was not found, please check it is valid and pyenv is up to date"
			else
				success "Pyenv: Python version ${version} was found"
			fi

			# Runs through normal install if possible, using CFlag if not
			info "Pyenv: Attempting normal install"
			if pyenv install "${version}" &> /dev/null ; then
				success "Pyenv: Python version ${version} is now installed"
			else
				warn "Pyenv: Python version ${version} failed to install, attempting to run with CFlags"
				if CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install "${version}" &> /dev/null ; then
					success "Pyenv: Python version ${version} is now installed"
				else
					fail "Pyenv: Python version ${version} failed to install"
				fi
			fi
		else
			success "Pyenv: Python version ${version} is already installed"
		fi
	done

# Java check and set
	if [[ $(uname -s) == "Darwin" ]]; then
		for key in "${!java_version[@]}"; do
			# First checks for whether the JDK is installed
			if [[ $(echo /Library/Java/JavaVirtualMachines/* | grep ${key}) == "" ]]; then
				info "JDK: Version ${key} is not installed, installing now"
				info "JDK: Checking for cached JDK installations"
				if [[ ! -d $HOME/.dotfiles_cache ]]; then
					mkdir "$HOME"/.dotfiles_cache
				fi

				# Now checks the cache for an old version
				if [[ ! -f $HOME/.dotfiles_cache/jdk-${java_version[${key}]}-macosx-x64.dmg ]]; then
					info "JDK: Unable to find version ${key} in cache, downloading now"
					wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
					download.oracle.com/otn-pub/java/jdk/${java_version[${key}]}-${java_bin[${key}]}/jdk-${java_version[${key}]}-macosx-x64.dmg -O \
					"$HOME"/.dotfiles_cache/jdk-${java_version[${key}]}-macosx-x64.dmg -q --show-progress
				else
					success "JDK: Version ${key} is in cache"
				fi

				# Now validates the cached version with a checksum
				info "JDK: Validating cached JDK version ${java_version[${key}]}"

				# Checks if the checksum is already downloaded
				if [[ -f $HOME/.dotfiles_cache/jdk-checksum-${java_version[${key}]} ]]; then
					success "JDK: ${java_version[${key}]} checksum file already downloaded"
				else
					info "JDK: Downloading ${java_version[${key}]} checksum now"
					if	wget https://www.oracle.com/webfolder/s/digest/${java_version[${key}]}checksum.html \
						-O "$HOME"/.dotfiles_cache/jdk-checksum-${java_version[${key}]} -q --show-progress; then
						success "JDK: ${java_version[${key}]} checksum is now downloaded"
					else
						fail "JDK: ${java_version[${key}]} checksum failed to download"
					fi
				fi

				# Validates cached version
				if [[ $(grep "$(md5 "$HOME"/.dotfiles_cache/jdk-${java_version[${key}]}-macosx-x64.dmg | awk '{ print $4 }')" "$HOME"/.dotfiles_cache/jdk-checksum-${java_version[${key}]}) == "" ]]; then
					fail "JDK: Cache file integrity verification failed"
				else
					success "JDK: Cache file integrity validation successful"
				fi

				# Mounts the JDK package
				info "JDK: Mounting version ${key}"
				hdiutil mount "$HOME"/.dotfiles_cache/jdk-${java_version[${key}]}-macosx-x64.dmg &> /dev/null

				# Isolates the JDK volume
				info "JDK: Version ${key} is now mounted, isolating JDK package"
				jdk_volume_name="/Volumes/$(ls /Volumes/ | grep "JDK")"
				jdk_pkg_file="$jdk_volume_name/"$(ls "$jdk_volume_name"/ | grep JDK)
				info "JDK: JDK package is isolated to $jdk_pkg_file"

				# Runs the JDK installer
				info "JDK: Version ${key} is now mounted, running JDK installer now from $jdk_pkg_file"
				sudo installer -pkg "$jdk_pkg_file" -target / &> /dev/null
				hdiutil unmount "$jdk_volume_name" &> /dev/null
				success "JDK: Version ${key} is now installed"
			else
				success "JDK: Version ${key} is already installed"
			fi

			# Checks for whether Jenv is aware of the installed JDK
			if [[ $(jenv versions | grep ${key}) == "" ]]; then
				info "Jenv: Java version ${key} is not installed yet, installing now"
				jdk="/Library/Java/JavaVirtualMachines/$(echo /Library/Java/JavaVirtualMachines/* | grep ${key})/Contents/Home/"
				jenv add "$jdk" &>/dev/null
				success "Jenv: Java version ${key} is now installed"
			else
				success "Jenv: Java version ${key} is already installed"
			fi
		done
	else
		if [[ $(which javac) == "" ]]; then
			info "Java: Version 8 JDK was not installed, installing now"
			# Installs Java for unix
			sudo apt-get install -y default-jdk &> /dev/null # Ain't shit just dandy
			success "Java: Version 8 JDK is now installed"
		else
			success "Java: Version 8 JDK is already installed"
		fi
	fi

# Ruby check and set
	# Checks to see rbenv is in the correct PATH
	if [[ $(which rbenv) == "" ]] && [[ $(uname -s) == "Linux" ]]; then
		export PATH="/home/$username/.rbenv/bin:$PATH"
		export RBENV_ROOT=/home/$username/.rbenv
	fi

	# Checks to see if rbenv is initialised
	if which rbenv > /dev/null; then
		eval "$(rbenv init -)"
	fi

	for version in "${ruby_versions[@]}"; do
		if [[ $(rbenv versions | grep "${version}") == "" ]]; then
			info "Rbenv: Ruby version ${version} is not installed yet, installing now"

			# Checks if pyenv has the correct version first
			info "Rbenv: Checking for ruby version ${version}"
			if [[ $(rbenv install --list | grep "${version}") == "" ]]; then
				fail "Rbenv: Ruby version ${version} was not found, please check it is valid and rbenv is up to date"
			else
				success "Rbenv: Ruby version ${version} was found"
			fi

			# Tries a normal install
			info "Rbenv: Attempting normal install now"
			if rbenv install "${version}" &> /dev/null ; then
				success "Rbenv: Ruby version ${version} is now installed"
			else
				fail "Rbenv: Ruby version ${version} failed to install"
			fi
		else
			success "Rbenv: Ruby version ${version} is already installed"
		fi
	done
