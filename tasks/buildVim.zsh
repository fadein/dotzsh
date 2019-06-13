#!/bin/zsh

PURPOSE='Rebuild Vim from GitHub'
VERSION="1.8"
   DATE="Thu Jun 13 08:32:35 MDT 2019"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

TASKNAME=$0:t:r

env() {
	zmodload zsh/regex

	# Directory of Vim repository
	BUILDDIR=~/build/vim.git

	SHUSH=1
	if command -v sudo &>/dev/null; then
		SUDO=$(command -v sudo)
	else
		SUDO=
	fi
	DEST=/usr
	EMERGENCY_DEST=/bin
	NPROC=/usr/bin/nproc

	OPTS_EMERGENCY="--with-features=small --disable-gui --disable-gpm --disable-acl"
	OPTS_REGULAR="--with-features=huge --enable-perlinterp --enable-pythoninterp --enable-termtruecolor"

	#Count number of CPUs in this system and add one
	MAKE_JOBS=-j$(( $(nproc) + 1 ))
	_TODO=(
		'$ git pull'
		'run makeVim() to build vim & gvim'
		'run `sudo make install` to install the suite of runtime files'
		'run emergencyVim() to build a minimal /bin/vi'
		)

	_KEEP_FUNCTIONS+=warn

	#Build emergency Vim (only requires glibc and ncurses)
	function emergencyVim() {
		local STRIP=$1
		trap return SIGTERM SIGINT

		[[ -n $SUDO ]] && $SUDO -v

		(
		cd $BUILDDIR/src

		if ! nice make distclean; then rm -f auto/config.cache; fi

		if ! nice ./configure --prefix=$DEST $OPTS_EMERGENCY; then return; fi

		if nice make auto/osdef.h && ! [[ -f auto/osdef.h ]]; then
			warn "Failed to generate auto/osdef.h" "Bailing out"
			return
		fi

		if ! nice make $MAKE_JOBS; then return; fi

		echo
		if [[ -n $STRIP ]] && $STRIP -regex-match '^(strip|1)$'; then
			echo Stripping output binary
			if ! nice strip vim; then
				warn FAILED to strip vim
				return
			fi
		else
			echo Not stripping output binary
		fi

		echo
		echo "Installing vi binary to $EMERGENCY_DEST"
		if ! $SUDO cp vim $EMERGENCY_DEST/vi; then
			warn FAILED to copy vim to $EMERGENCY_DEST/vi
		fi
		)
	}

	#Build regular Vim this way:
	function makeVim() {
		local STRIP=$1
		trap return SIGTERM SIGINT

		[[ -n $SUDO ]] && $SUDO -v

		(
		cd $BUILDDIR/src

		if ! nice make distclean; then rm -f auto/config.cache; fi

		if ! nice ./configure --prefix=$DEST $OPTS_REGULAR; then return; fi

		if nice make auto/osdef.h && ! [[ -f auto/osdef.h ]]; then
			warn "Failed to generate auto/osdef.h" "Bailing out"
			return
		fi

		if ! nice make $MAKE_JOBS; then return; fi

		echo
		echo "Installing Vim binary to $DEST"
		if [[ -n $STRIP ]] && $STRIP -regex-match '^(strip|1)$'; then
			if ! nice $SUDO make STRIP=strip installvimbin; then return; fi
			echo "${DEST}/bin/vim is not stripped"
		else
			echo Not stripping output binary
			STRIP=true
			if ! nice $SUDO make STRIP=true installvimbin; then return; fi
			echo "${DEST}/bin/vim is not stripped"
		fi
		echo
		echo 'Run `sudo make install` if you want to install the entire'
		echo 'updated Vim suite of runtime files.'
		)
	}

	>&1 <<-MESSAGE
	###
	######
	############
	########################
	BuildVim functions defined:
	    makeVim( STRIP=0 )
	    emergencyVim( STRIP=0 )
	########################
	############
	######
	###
	MESSAGE

	cd $BUILDDIR
	if ! git status --branch --porcelain 2>&1 | grep -q '## master'; then
		>&1 <<-MESSAGE
		[1;31m
		     !!! The current branch is not '[32mmaster[31m' !!!
		Please checkout the master branch before continuing
		[0m
		MESSAGE
	fi
}

source $0:h/__TASKS.zsh
