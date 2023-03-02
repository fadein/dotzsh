#!/bin/zsh

PURPOSE='Rebuild Vim from GitHub'
VERSION="1.10"
   DATE="Thu Mar 31 09:07:18 MDT 2022"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

TASKNAME=$0:t:r

# Directory of Vim code repository
export BUILDDIR=~/build/vim.git

setup() {
    if ! [[ -d $BUILDDIR/.git ]]; then
        git clone https://github.com/vim/vim $BUILDDIR
        return $!
    fi
}

env() {
	zmodload zsh/regex


	SHUSH=1
	if command -v sudo &>/dev/null; then
		SUDO=$(command -v sudo)
	else
		SUDO=
	fi
	DEST=/usr
	EMERGENCY_DEST=/bin
	NPROC=/usr/bin/nproc

	OPTS_EMERGENCY=(--with-features=small --disable-gui --disable-gpm --disable-acl)
	OPTS_REGULAR=(--with-features=huge
        --enable-termtruecolor
        --disable-perlinterp
        --disable-pythoninterp
        --disable-terminal
        --disable-balloon_eval
        --disable-browse
        --disable-libcall
        --disable-netbeans
        )

	#Count number of CPUs in this system and add one
	MAKE_JOBS=-j$(( $(nproc) + 1 ))
	_TODO=(
		'$ git pull'
		'$ makeVim'
		'$ sudo make install'
		'$ emergencyVi'
		)

	_KEEP_FUNCTIONS+=warn
    typeset -gA _HELP

    _HELP[emergencyVi]="Statically-linked emergency Vi (requires only glibc and ncurses; give a param to not strip)"
	function emergencyVi() {
		local NOSTRIP=$1
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

		print
		if [[ -z $NOSTRIP ]]; then
			print Stripping output binary
			if ! nice strip vim; then
				warn FAILED to strip vim
				return
			fi
		else
			print Not stripping output binary
		fi

		print
		print "Installing vi binary to $EMERGENCY_DEST"
		if ! $SUDO cp vim $EMERGENCY_DEST/vi; then
			warn FAILED to copy vim to $EMERGENCY_DEST/vi
		fi
		)
	}

    _HELP[makeVim]="Build Vim for everyday use (give a param to not strip)"
	function makeVim() {
		local NOSTRIP=$1
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

		print
		print "Installing Vim binary to $DEST"
		if [[ -z $NOSTRIP ]]; then
			if ! nice $SUDO make STRIP=strip installvimbin; then return; fi
			print "${DEST}/bin/vim is not stripped"
		else
			print Not stripping output binary
			if ! nice $SUDO make STRIP=true installvimbin; then return; fi
			print "${DEST}/bin/vim is not stripped"
		fi
		)
	}

	>&1 <<-'MESSAGE'
	[1;36m   __        _ __   ___   ___                __ 
	  / /  __ __(_) /__/ / | / (_)_ _   ___ ___ / / 
	 / _ \/ // / / / _  /| |/ / /  ' \_/_ /(_-</ _ \
	/_.__/\_,_/_/_/\_,_/ |___/_/_/_/_(_)__/___/_//_/
	[1;37m
	BuildVim.zsh functions defined:
	  [1;35mmakeVim[1;36m([1;33m NOSTRIP= [1;36m)
	  [1;35memergencyVi[1;36m([1;33m NOSTRIP= [1;36m)
	  [1;35mhelp[1;36m()
	[0m
	MESSAGE

	cd $BUILDDIR
	if ! git status --branch --porcelain 2>&1 | grep -q '## master'; then
		>&1 <<-MESSAGE
		[1;31m
		    !!! The current branch is not '[32mmaster[31m' !!!
		Please checkout the master branch before continuing
		[0m
		MESSAGE

        _TODO=(
            "$ git checkout master"
            $_TODO
            )
	fi
}

source $0:h/__TASKS.zsh
