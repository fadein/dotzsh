#!/bin/zsh

PURPOSE="Set up environment to work on SlackBuilds"
VERSION="0.2"
   DATE="Sat Jan 12 00:12:29 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SUDO=/usr/bin/sudo
NICE=/usr/bin/nice

#spawn a (nice) child root shell
spawn() {
	exec $SUDO TASK=$TASKNAME $NICE -n 10 $ZSH
}

# Set output directory to preserve completed SlackBuilds
env() {
	export OUTPUT=/root/pkg/SBo/install/
	cd /root/pkg/SBo

	slackbuild() {
		setopt BASH_RE_MATCH
		# look for the 1st .info in the CWD
		INFO=( *.info ) || return

		# Determine which package to download from the .info
		ARCH=$( uname -m )

		# parse out the DOWNLOAD lines
		local RX_DOWNLOAD="^DOWNLOAD_?(x86_64)?=\"([^\"]+)\""
		local RX_MD5SUM="^MD5SUM_?(x86_64)?=\"([^\"]+)\""
		local LINE=
		local PKG=
		local MD5=
		for LINE in $(< $INFO )
		do
			if [[ ${LINE} =~ ${RX_DOWNLOAD} ]]; then
				if [[ "$ARCH" = 'x86_64' && "${BASH_REMATCH[2]}" = 'x86_64' ]]; then
					PKG=${BASH_REMATCH[-1]}
				elif [[ "${BASH_REMATCH[2]}" != x86_64 ]]; then
					PKG=${BASH_REMATCH[-1]}
				fi
			elif [[ ${LINE} =~ ${RX_MD5SUM} ]]; then
				if [[ "$ARCH" = 'x86_64' && "${BASH_REMATCH[2]}" = 'x86_64' ]]; then
					MD5=${BASH_REMATCH[-1]}
				elif [[ "${BASH_REMATCH[2]}" != x86_64 ]]; then
					MD5=${BASH_REMATCH[-1]}
				fi
			fi
		done

		SUM=$(wget -O - $PKG | tee ${PKG:t} | md5sum | cut -d' ' -f1)

		[[ "$MD5" = "$SUM" ]] || { echo 1>&2 "Checksum of ${PKG:t} does not match that specified in $INFO"; return 1 }

		SB=${INFO%.info}.SlackBuild
		[[ -f $SB ]] || { echo 1>&2 ohai u can haz $SB; return 1 }
		chmod +x $SB
		./$SB
	}

	# Print a useful message to help this old fogie remember what
	# to do next
	>&1 <<MESSAGE
###
######
############
########################
#########################################
chdir into a slackbuild directory and run

slackbuild

to download, verify checksum and build it

#########################################
########################
############
######
###
MESSAGE

}

# Tie it all together
source $0:h/__TASKS.zsh
