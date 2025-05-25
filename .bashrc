#!/bin/bash

#########################################################
# This is how I customize Bash to make it more beautiful.
#########################################################

# Initial order. Its elements must be defined as a function name.
_ps1_order=(__cwd __time __repo __venv)

# Characters to control the prompt appearance.
_ps1_left=""
_ps1_right=""
_ps1_sep=""
_ps1_top="┌─"
_ps1_bottom="└─"

# Colors. They must follow this format
# \e[CODEm
_ps1_reset_fg="\e[39m"
_ps1_reset_bg="\e[49m"

# Optional settings.
_ps1_cwd_trim=4
_ps1_time_fmt="%H:%M"

# Optional elements. They must output text in this format
# CURRENT_BG\]SEPARATOR\[RESET_FG\] TEXT \[CURRENT_FG
__cwd() {
	local _ps1_cwd_fg="\e[97m"
	local _ps1_cwd_bg="\e[40m"
	[ ! -v _ps1_cwd_trim ] && local _ps1_cwd_trim=3
	[[ $PWD =~ $HOME* ]] && local _cwd="$(pwd | sed "s/^${HOME//\//\\/}/~/")" || local _cwd="${PWD/\//}"
	if [ -z "$_cwd" ] ; then
		local _out="  (root)"
	else
		local _out=" "
		local -a _dirs="(\"${_cwd//'/'/'" "'}\")"
		if [ ${#_dirs[@]} -gt $_ps1_cwd_trim ] ; then
			_out+='...'
			for (( i=-$_ps1_cwd_trim ; i<=-1 ; i++ )) ; do _out+="/${_dirs[$i]}" ; done
		else
			_out+="$_cwd"
		fi
	fi
	echo -ne "$_ps1_cwd_bg\]$_ps1_sep\[$_ps1_reset_fg\] ${_out//\//'  '} \[$_ps1_cwd_fg"
}

__time() {
	local _ps1_time_fg="\e[35m"
	local _ps1_time_bg="\e[45m"
	echo -ne "$_ps1_time_bg\]$_ps1_sep\[$_ps1_reset_fg\] $(printf " %($_ps1_time_fmt)T" -1) \[$_ps1_time_fg"
}

__repo() {
	if git rev-parse --is-inside-work-tree &>/dev/null ; then
		local _out=" $(git branch --show-current || git symbolic-ref --short HEAD)"
		if [ $(git rev-parse --is-inside-git-dir 2>/dev/null) = false ] ; then
			local _ps1_git_fg="\e[31m"
			local _ps1_git_bg="\e[41m"
			git update-index --really-refresh -q &>/dev/null
			git diff --quiet --ignore-submodules --staged || _out+=' +'
			[ -n $(git ls-files --others --exclude-standard) ] && _out+=' ?'
			git rev-parse --verify refs/stash &>/dev/null && _out+=' !'
		else
			local _ps1_git_fg="\e[90m"
			local _ps1_git_bg="\e[100m"
		fi
		echo -ne "$_ps1_git_bg\]$_ps1_sep\[$_ps1_reset_fg\] $_out \[$_ps1_git_fg"
	fi
}

__venv() {
	if [[ $(which python) =~ $VIRTUAL_ENV* ]] ; then
		local _out=" venv $(python -V | tr -d 'Python ')"
		if [[ $PWD =~ $VIRTUAL_ENV* ]] ; then
			local _ps1_venv_fg="\e[90m"
			local _ps1_venv_bg="\e[100m"
		else
			local _ps1_venv_fg="\e[32m"
			local _ps1_venv_bg="\e[42m"
		fi
		echo -ne "$_ps1_venv_bg\]$_ps1_sep\[$_ps1_reset_fg\] $_out \[$_ps1_venv_fg"
	fi
}

# Script implementation. DO NOT edit this.
[ ${#_ps1_order[@]} -eq 0 ] && _ps1_order=(__cwd __time __repo __venv)

case $OSTYPE in
	( cygwin | msys )
		[ -z "$_ps1_os_fg" ] && _ps1_os_fg="\e[34m"
		[ -z "$_ps1_os_bg" ] && _ps1_os_bg="\e[44m"
		[ -z "$_ps1_os_icon" ] && _ps1_os_icon=" "
		[ -z "$_ps1_os_col" ] && _ps1_os_col="\e[37m"
	;;
	( darwin )
		[ -z "$_ps1_os_fg" ] && _ps1_os_fg="\e[97m"
		[ -z "$_ps1_os_bg" ] && _ps1_os_bg="\e[100m"
		[ -z "$_ps1_os_icon" ] && _ps1_os_icon=" "
		[ -z "$_ps1_os_col" ] && _ps1_os_col="\e[30m"
	;;
	( linux* )
		[ -z "$_ps1_os_fg" ] && _ps1_os_fg="\e[31m"
		[ -z "$_ps1_os_bg" ] && _ps1_os_bg="\e[41m"
		[ -z "$_ps1_os_icon" ] && _ps1_os_icon=" "
		[ -z "$_ps1_os_col" ] && _ps1_os_col="\e[30m"
	;;
	( * )
		[ -z "$_ps1_os_fg" ] && _ps1_os_fg="\e[33m"
		[ -z "$_ps1_os_bg" ] && _ps1_os_bg="\e[43m"
		[ -z "$_ps1_os_icon" ] && _ps1_os_icon="? "
		[ -z "$_ps1_os_col" ] && _ps1_os_col="\e[37m"
	;;
esac

__update_prompt() {
	PS1="\e]0;$(pwd | sed "s/^${HOME//\//\\/}/~/")\a\n$_ps1_top\[$_ps1_os_fg$_ps1_reset_bg\]$_ps1_left\[$_ps1_reset_fg$_ps1_os_bg\] \[$_ps1_os_col\]$_ps1_os_icon\[$_ps1_reset_fg\]  \u\[\e[90m\]@\H\[\e[39m\] \[$_ps1_os_fg$(for i in ${_ps1_order[@]} ; do eval $i 2>/dev/null ; done)$_ps1_reset_bg\]$_ps1_right\[$_ps1_reset_fg\]\[$(tput sgr0)\]\n$_ps1_bottom\[\e[90m\]\$\[\e[39m\] "
}

PROMPT_COMMAND="__update_prompt"
PS2="\[\e[90m\]...\[\e[39m\] "
PS3="Enter a number: "
PS4="+ \e[90m[$0:$LINENO]\e[39m "
