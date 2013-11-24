#!/bin/env zsh

PURPOSE='Shell into an environment where all Portage areas are re-mounted as ramdisks.'
VERSION=1.5
   DATE="Sat Nov 23 22:51:32 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

# external program paths should go here
RAMDIR=/usr/local/bin/ramdir.sh
SUDO=/usr/bin/sudo
NICE=/usr/bin/nice
IONICE=/usr/bin/ionice

AREAS=(/var/tmp/portage /usr/portage)

# copy contents of AREAS into ramdisk
setup() {
	for AREA in $AREAS; do
		if ! [[ -d $AREA ]]; then
			mkdir $AREA;
		fi
		if ! $RAMDIR mount $AREA; then
			exit $(die "failed to mount $AREA as ramfs")
		fi
	done
    $SUDO eix-sync
}

# spawn a nice child root shell
spawn() {
	$SUDO TASK=$TASKNAME $IONICE $NICE $ZSH_NAME
}

# sync areas back to disk
cleanup() {
	echo "Please wait while the Portage areas are synced back to disk..."
	for AREA in $AREAS; do
		if ! $RAMDIR umount $AREA; then
			exit $(die "\nfailed to sync $AREA back to disk" \
				"You should make sure each of the following are synced back:" \
				$AREAS)
		fi
	done

	echo "Done"
}

# Add portage aliases to environment,
# chdir into portage workspace
env() {
	alias unmerge='emerge -Cva'
	alias remerge='emerge -rva'
	alias depclean='emerge --depclean --ask'

	_TODO=(
		'$ emerge -DNauv --keep-going --tree --unordered-display @system'
		'$ emerge -DNauv --keep-going --tree --unordered-display @world'
		'$ dispatch-conf'
		'$ emerge --depclean'
		'$ revdep-rebuild -ip')

	cd /root/portage

	>&1 <<MESSAGE
###
######
############
########################
Portage aliases engaged:
	unmerge
	remerge
	depclean
########################
############
######
###
MESSAGE
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
