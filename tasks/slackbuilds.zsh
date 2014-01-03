#!/bin/env zsh

PURPOSE="Set up environment to work on SlackBuilds"
VERSION=1.0
   DATE="Fri Feb 15 14:36:37 MST 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SUDO=/usr/bin/sudo
NICE=/usr/bin/nice

#spawn a (nice) child root shell
spawn() {
	exec $SUDO TASK=$TASKNAME $NICE $ZSH_NAME
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

        ## if the package is already here, don't re-download it!
        if [[ -f ${PKG:t} ]]; then
            SUM=$(md5sum ${PKG:t} | cut -d' ' -f1)
        else
            SUM=$(wget -O - $PKG | tee ${PKG:t} | md5sum | cut -d' ' -f1)
        fi

		[[ "$MD5" = "$SUM" ]] || { echo 1>&2 "Checksum of ${PKG:t} does not match that specified in $INFO"; return 1 }

		SB=${INFO%.info}.SlackBuild
		[[ -f $SB ]] || { echo 1>&2 ohai u can haz $SB; return 1 }
		chmod +x $SB
		if ./$SB ; then
            echo -e "\a"
        else
            echo -e "\a\a\a"
        fi
	}

    # run slackbuild() in a loop, scanning its output looking for the name
    # of the package
    #
    # then run upgradepkg --install-new --reinstall $PACKAGENAME
    slackinstall() {
        local RX_CREATED="^Slackware package (.+) created"
        local IFS=$'\x0A'$'\x0D'
        local LINE=
        local PACKAGE=
        for LINE in $( slackbuild 2>&1 )
        do
            if [[ ${LINE} =~ ${RX_CREATED} ]]; then
                PACKAGE=$match[1]
            fi
            print $LINE
        done

        if [[ -n "$PACKAGE" && -f "$PACKAGE" ]]; then
            upgradepkg --install-new --reinstall $PACKAGE
        fi

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

slackinstall

do the above and install the new package

#########################################
########################
############
######
###
MESSAGE

}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
