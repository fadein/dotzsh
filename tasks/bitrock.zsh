#!/usr/local/bin/zsh

PURPOSE="Build BitRock installers"
VERSION="1.0"
   DATE="Thu May 16 13:42:37 MDT 2013"
 AUTHOR="Erik Falor <efalor@spillman.com>"

TASKNAME=$0:t:r

env() {
	#hack PATH
	PATH=/home/efalor/optdbg/tools/org.apache.ant_1.7.1.v20100518-1145/bin:/usr/java6/bin:/home/efalor/.storm-dev/bin:/usr/local/bin:/usr/bin:/etc:/usr/sbin:/usr/ucb:/home/efalor/bin:/usr/bin/X11:/sbin:/home/efalor/.zsh:/home/efalor/scripts

	makeInstaller() {
		local BRPATH=~/optdbg/rel63/bitrock
		(
		cd $BRPATH
		if ant -verbose "Build Ctree Module BitRock Installer"; then
			print Find your installer at $BRPATH/modules/ctree/output/ctree-installer.run
		else
			print The installer at $BRPATH/modules/ctree/output/ctree-installer.run is teh old
		fi
		)
	}

	print "use makeInstaller() to make the BitRock installer"
}

#
# Tie it all together
source $0:h/__TASKS.zsh
