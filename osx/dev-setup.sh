#!/usr/bin/env bash

# Sets up the development environments

set -e

python_versions=(3.5.1 2.7.11)

declare -A java_version
java_version[1.8]=8u92
java_version[1.7]=7u80

ruby_versions=(2.3.1)

# Python check and set
	for version in ${python_versions[@]}; do
		if [[ $(pyenv versions | grep ${version}) == "" ]]; then
			info "Pyenv: Python version ${version} is not installed yet, installing now"
			if [[ $(echo $CFLAGS) == "" ]]; then
				info "Pyenv: CFLAGS not yet set, running now"
				if CFLAGS="-I$(xcrun --show-sdk-path)/usr/include" pyenv install ${version} &> /dev/null ; then
					success "Pyenv: Python version ${version} is now installed"
				else
					fail "Pyenv: Python version ${version} failed to install"
				fi
			elif pyenv install ${version} &> /dev/null ; then
				success "Pyenv: Python version ${version} is now installed"
			else
				fail "Pyenv: Python version ${version} failed to install"
			fi
		else
			success "Pyenv: Python version ${version} is already installed"
		fi
	done

# Java check and set
	for key in ${!java_version[@]}; do
		# First checks for whether the JDK is installed
		if [[ $(ls /Library/Java/JavaVirtualMachines | grep ${key}) == "" ]]; then
			info "JDK: Version ${key} is not installed, installing now"
			info "JDK: Checking for cached JDK installations"
			if [[ ! -d /Users/$(whoami)/.cached_jdk ]]; then
				mkdir /Users/$(whoami)/.cached_jdk
			fi

			# Now checks the cache for an old version
			if [[ ! -f /Users/$(whoami)/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg ]]; then
				info "JDK: Unable to find version ${key} in cache, downloading now"
				wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" \
					download.oracle.com/otn-pub/java/jdk/${java_version[${key}]}-b14/jdk-${java_version[${key}]}-macosx-x64.dmg -O \
					/Users/$(whoami)/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg &> /dev/null
			else
				success "JDK: Version ${key} is in cache"
			fi
			info "JDK: Mounting version ${key}"
			hdiutil mount /Users/$(whoami)/.cached_jdk/jdk-${java_version[${key}]}-macosx-x64.dmg &> /dev/null
			jdk_volume_name="/Volumes/$(ls /Volumes | grep JDK)"
			jdk_pkg_file="$jdk_volume_name/"$(ls "$jdk_volume_name" | grep JDK)
			sudo installer -pkg "$jdk_pkg_file" -target / &> /dev/null
			hdiutil unmount "$jdk_volume_name" &> /dev/null
			success "JDK: Version ${key} is now installed"
		else
			success "JDK: Version ${key} is already installed"
		fi

		# Checks for whether Jenv is aware of the installed JDK
		if [[ $(jenv versions | grep ${key}) == "" ]]; then
			info "Jenv: Java version ${key} is not installed yet, installing now"
			jdk="/Library/Java/JavaVirtualMachines/"$(ls /Library/Java/JavaVirtualMachines/ | grep ${key})"/Contents/Home/"
			jenv add "$jdk" &>/dev/null
			success "Jenv: Java version ${key} is now installed"
		else
			success "Jenv: Java version ${key} is already installed"
		fi
	done

# Ruby check and set
	for version in ${ruby_versions[@]}; do
		if [[ $(rbenv versions | grep ${version}) == "" ]]; then
			info "Rbenv: Ruby version ${version} is no installed yet, installing now"
			if rbenv install ${version} &> /dev/null ; then
				success "Rbenv: Ruby version ${version} is now installed"
			else
				fail "Rbenv: Ruby version ${version} failed to install"
			fi
		else
			success "Rbenv: Ruby version ${version} is already installed"
		fi
	done
