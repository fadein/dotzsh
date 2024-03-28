#!/bin/env zsh

PURPOSE="Temporarily inhibit suspend on laptop lid close"
VERSION=1.1
   DATE="Mon Oct 30 10:59:50 MDT 2023"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

setup() {
	raisePrivs
	cat <<-: > /etc/elogind/logind.conf.d/inhibit-lid.conf
	[Login]
	HandleLidSwitch=ignore
	HandleLidSwitchExternalPower=ignore
	:
	loginctl reload

	CLEANUP_TRAPS=(HUP)
	cat <<-':'
	 _                                     _           
	| |_____ ___ _ __   _ _ _  _ _ _  _ _ (_)_ _  __ _ 
	| / / -_) -_) '_ \ | '_| || | ' \| ' \| | ' \/ _` |
	|_\_\___\___| .__/ |_|  \_,_|_||_|_||_|_|_||_\__, |
	            |_|                              |___/ 
	        _               _ _    _      _                _ 
	__ __ _| |_  ___ _ _   | (_)__| |  __| |___ ___ ___ __| |
	\ V  V / ' \/ -_) ' \  | | / _` | / _| / _ (_-</ -_) _` |
	 \_/\_/|_||_\___|_||_| |_|_\__,_| \__|_\___/__/\___\__,_|
	
	:
}

spawn() {
    dropPrivsAndSpawn $ZSH_NAME
}

cleanup() {
	rm -f /etc/elogind/logind.conf.d/inhibit-lid.conf
	loginctl reload

	cat <<-':'
	                              _          _             
	 ____  _ ____ __  ___ _ _  __| | __ __ _| |_  ___ _ _  
	(_-< || (_-< '_ \/ -_) ' \/ _` | \ V  V / ' \/ -_) ' \ 
	/__/\_,_/__/ .__/\___|_||_\__,_|  \_/\_/|_||_\___|_||_|
	           |_|                                         
	 _ _    _      _                _ 
	| (_)__| |  __| |___ ___ ___ __| |
	| | / _` | / _| / _ (_-</ -_) _` |
	|_|_\__,_| \__|_\___/__/\___\__,_|
	
	:
}

source $0:h/__TASKS.zsh
# vim: set noexpandtab filetype=sh:
