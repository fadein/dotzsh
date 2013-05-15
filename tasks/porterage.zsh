#!/bin/zsh

#Program: porterage.sh
PURPOSE='Shell into an environment where all Portage areas are re-mounted as ramdisks.'
VERSION=1.3
   DATE="Wed Oct 10 10:51:59 MDT 2012"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

#external program paths should go here
RAMDIR=/usr/local/bin/ramdir.sh
SUDO=/usr/bin/sudo
NICE=/usr/bin/nice

AREAS=(/var/tmp/portage /usr/portage)

#set up areas
setup() {
	for AREA in $AREAS; do
		if ! [[ -d $AREA ]]; then
			mkdir $AREA;
		fi
		if ! $RAMDIR mount $AREA; then
			exit $(die "failed to mount $AREA as ramfs")
		fi
	done
}

#spawn a (nice) child root shell
spawn() {
	$SUDO TASK=$TASKNAME $NICE -n 10 $ZSH
}

#sync areas back to disk
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
	alias remerge='emerge -r'
	alias depclean='emerge --depclean --ask'

	_TODO=(
		'$ eix-sync'
		'$ emerge -DNauv @system'
		'$ emerge -DNauv @world'
		'$ emerge --depclean'
		'$ revdep-rebuild')
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
