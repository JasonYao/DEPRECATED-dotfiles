#!/usr/bin/env bash

# Sets up the development environments

set -e

# Python env stuff
python_versions=(3.5.1 2.7.11)

# Java env stuff
declare -A java_version
java_version[1.8]=8u92
java_version[1.7]=7u80

# Ruby env stuff
ruby_versions=(2.3.1)

# Python check and set
	for version in "${python_versions[@]}"; do
		if [[ $(pyenv versions | grep "${version}") == "" ]]; then
			info "Pyenv: Python version ${version} is not installed yet, installing now"
			if [[ $CFLAGS == "" ]]; then
				info "Pyenv: CFLAGS not yet set, running now"
				if CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install "${version}" &> /dev/null ; then
					success "Pyenv: Python version ${version} is now installed"
				else
					fail "Pyenv: Python version ${version} failed to install"
				fi
			elif pyenv install "${version}" &> /dev/null ; then
				success "Pyenv: Python version ${version} is now installed"
			else
				fail "Pyenv: Python version ${version} failed to install"
			fi
		else
			success "Pyenv: Python version ${version} is already installed"
		fi
	done

# Java check and set
	for key in "${!java_version[@]}"; do
		# First checks for whether the JDK is installed
		if [[ $(echo /Library/Java/JavaVirtualMachines/* | grep ${key}) == "" ]]; then
			info "JDK: Version ${key} is not installed, installing now"
			info "JDK: Checking for cached JDK installations"
			if [[ ! -d $HOME/.cached_jdk ]]; then
				mkdir "$HOME"/.cached_jdk
			fi

			# Now checks the cache for an old version
			if [[ ! -f $HOME/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg ]]; then
				info "JDK: Unable to find version ${key} in cache, downloading now"
				wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
					download.oracle.com/otn-pub/java/jdk/${java_version[${key}]}-b14/jdk-${java_version[${key}]}-macosx-x64.dmg -O \
					"$HOME"/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg -q --show-progress
			else
				success "JDK: Version ${key} is in cache"
			fi

			# Now validates the cached version with a checksum
			info "JDK: Validating cached JDK version ${java_version[${key}]}"

			# Checks if the checksum is already downloaded
			if [[ -f $HOME/.cached_jdk/jdk-checksum-${java_version[${key}]} ]]; then
				success "JDK: ${java_version[${key}]} checksum file already downloaded"
			else
				info "JDK: Downloading ${java_version[${key}]} checksum now"
				if	wget https://www.oracle.com/webfolder/s/digest/${java_version[${key}]}checksum.html \
					-O "$HOME"/.cached_jdk/jdk-checksum-${java_version[${key}]} -q --show-progress; then
					success "JDK: ${java_version[${key}]} checksum is now downloaded"
				else
					fail "JDK: ${java_version[${key}]} checksum failed to download"
				fi
			fi

			# Validates cached version
			if [[ $(grep "$(md5 "$HOME"/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg | awk '{ print $4 }')" "$HOME"/.cached_jdk/jdk-checksum-${java_version[${key}]}) == "" ]]; then
				fail "JDK: Cache file integrity verification failed"
			else
				success "JDK: Cache file integrity validation successfull"
			fi

			info "JDK: Mounting version ${key}"
			hdiutil mount "$HOME"/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg &> /dev/null
			jdk_volume_name="/Volumes/$(echo /Volumes/* | grep JDK)"
			jdk_pkg_file="$jdk_volume_name/"$(echo "$jdk_volume_name"/* | grep JDK)
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

# Ruby check and set
	for version in "${ruby_versions[@]}"; do
		if [[ $(rbenv versions | grep "${version}") == "" ]]; then
			info "Rbenv: Ruby version ${version} is not installed yet, installing now"
			if rbenv install "${version}" &> /dev/null ; then
				success "Rbenv: Ruby version ${version} is now installed"
			else
				fail "Rbenv: Ruby version ${version} failed to install"
			fi
		else
			success "Rbenv: Ruby version ${version} is already installed"
		fi
	done
