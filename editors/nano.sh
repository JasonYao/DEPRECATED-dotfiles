#!/usr/bin/env bash

set -e

nanorc_configs=(html css javascript json asm c cmake sh nanorc java python tex go ruby)

if [[ $(uname -s | grep "Linux") == "" ]]; then
	# OSX's nano config location
	config_path="/usr/local/share/nano"
else
	# Linux's nano config location
	config_path="/usr/share/nano"
fi

if [[ -f $HOME/.nanorc ]]; then
	success "Nano: Editor settings have already been set"
else
	info "Nano: Editor settings have not ben applied yet, applying now"
	echo "# Nano editor configuration files" > "$HOME"/.nanorc

	{
  	echo "set const"
		echo "set tabsize 4"
		echo ""
		echo "# Included syntax highlighting:"

		for config in "${nanorc_configs[@]}"; do
			printf "\tinclude %s/%s.nanorc\n" "$config_path" "${config}"
		done
	} >> "$HOME"/.nanorc

	success "Nano: Editor settings are now applied"
fi
