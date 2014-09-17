#!/bin/env zsh

#TODO: adjust oom_score_adj before shelling out...
#      how best to do this?  in env?  I'd like to be able to do it in setup(), but
#      I don't think that'll be possible
PURPOSE="Set up environment to work on SlackBuilds"
VERSION=1.1
   DATE="Wed Mar 12 21:46:02 MDT 2014"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0
TASKNAME=$0:t:r

CHMOD=/usr/bin/chmod
CUT=/usr/bin/cut
GIT=/usr/bin/git
MD5SUM=/usr/bin/md5sum
NICE=/usr/bin/nice
TEE=/usr/bin/tee
UPGRADEPKG=/sbin/upgradepkg
WGET=/usr/bin/wget

setup() {
    raisePrivs
}

#spawn a (nice) child root shell
spawn() {
	TASK=$TASKNAME $NICE $ZSH_NAME
}

env() {
	export OUTPUT=/mnt/rasp/build/SBo/install/
    export SBODIR=/mnt/rasp/build/SBo/slackbuilds.git
    cd $SBODIR
    gitprompt

    #
    # fetch the package (if needed), return true if the MD5 checksum matches
	slackfetch() {
		# look for the 1st .info in the CWD
		INFO=( *.info ) || return

		# Determine which package to download from the .info
		ARCH=$( uname -m )

        # set BASH_RE_MATCH for the duration of this function only
        setopt LOCAL_OPTIONS BASH_RE_MATCH

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
            SUM=$($MD5SUM ${PKG:t} | $CUT -d' ' -f1)
        else
            SUM=$($WGET -O - $PKG | $TEE ${PKG:t} | $MD5SUM | $CUT -d' ' -f1)
        fi
        [[ "$MD5" = "$SUM" ]] || { echo 1>&2 "Checksum of ${PKG:t} does not match that specified in $INFO"; return 1 }

    }

    #
    # execute the SlackBuild script
    slackbuild() {
        if slackfetch; then
            SB=${INFO%.info}.SlackBuild
            [[ -f $SB ]] || { echo 1>&2 "'$SB' not present or not a regular file"; return 1 }
            $CHMOD +x $SB
            if ./$SB "$@"; then
                echo -e "\a"
            else
                local R=$?
                echo -e "\a\a\a"
                return $R
            fi
        fi
    }

    #
    # run slackbuild() in a loop, scanning its output looking for the name
    # of the package
    #
    # then run upgradepkg --install-new --reinstall $PACKAGENAME
    slackinstall() {
        local RX_CREATED="^Slackware package (.+) created"
        local IFS=$'\x0A'$'\x0D'
        local LN=
        local PACKAGE=

        slackbuild 2>&1 | while read LN; do
            echo $LN
            if [[ ${LN} =~ ${RX_CREATED} ]]; then
                PACKAGE=$match[1]
            fi
        done

        if [[ -n "$PACKAGE" && -f "$PACKAGE" ]]; then
            $UPGRADEPKG --install-new --reinstall $PACKAGE
        fi
    }

    #
    # git update the slackbuilds repository
    sbo.git() {
        cd $SBODIR
        if $GIT checkout master; then
            $GIT pull
        fi
    }

    #
    # create a new slackbuild directory and copy template files over
    slackcreate() {
        local SBNAME=$1
        if [[ -z "$1" ]]; then
            read "SBNAME?What will you call this SlackBuild? "
        fi

        echo $SBNAME  #DELETE ME
        if [[ -d $SBODIR/$SBNAME ]]; then
            echo "Warning: directory $SBNAME already exists!"
        else
            echo "Creating directory '$SBNAME'"
            mkdir -p $SBODIR/$SBNAME
        fi

        if ! cd $SBODIR/$SBNAME; then
            die "Couldn't cd into '$SBNAME'"
        fi

        # Copy template files from $SBODIR/../templates.git
        cp $SBODIR/../templates.git/README . || echo "Failed to copy template README"
        cp $SBODIR/../templates.git/template.info ${SBNAME#*/}.info || echo "Failed to copy template template.info"
        cp $SBODIR/../templates.git/autotools-template.SlackBuild ${SBNAME#*/}.SlackBuild || echo "Failed to copy template autotools-template.SlackBuild"
        cp $SBODIR/../templates.git/doinst.sh . || echo "Failed to copy template doinst.sh"
        cp $SBODIR/../templates.git/slack-desc . || echo "Failed to copy template slack-desc"
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
    # slackbuild
    to download, verify checksum and build it

    # slackinstall
    does the above and installs the new package

    # slackfetch
    just downloads the package's source code

    # sbo.git
    git updates the slackbuilds

    # slackcreate [category/package]
    create a directory for a new SlackBuild and
    copies template files over

    #########################################
    ########################
    ############
    ######
    ###
MESSAGE

}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 expandtab:
