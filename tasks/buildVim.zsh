#!/bin/zsh

PURPOSE='Rebuild Vim from Mercurial repos'
VERSION="1.0"
   DATE="Wed Oct 24 10:59:04 MDT 2012"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

spawn() {
	TASK=$TASKNAME $ZSH
}

env() {
	SHUSH=1
	SUDO=/usr/bin/sudo
	DEST=/usr/local
	EMERGENCY_DEST=/bin
	GREP=/bin/grep

	#Count number of CPUs in this system and add
	MAKE_JOBS=-j$(( $($GREP processor /proc/cpuinfo | wc -l) + 1 ))

	#Set up a TODO list
	_TODO=(
		'$ hg pull'
		'$ hg update'
		'$ cd src/'
		'run emergencyVim() to build a minimal /bin/vi'
		'run makeVim() to build vim & gvim')

	#Build emergency vim (only requires glibc and ncurses)
	function emergencyVim() {
		trap return SIGTERM SIGINT

		$SUDO -v

		if ! nice make distclean; then rm -f auto/config.cache; fi

		if ! nice ./configure --prefix=$DEST --with-features=small --disable-gui --disable-gpm --disable-acl; then return; fi

		if ! nice make $MAKE_JOBS; then return; fi

		#TODO: conditionally run `strip` based on presence of some $VAR
		if ! nice strip vim; then return; fi

		echo "Installing vi binary to $EMERGENCY_DEST"
		if ! $SUDO cp vim $EMERGENCY_DEST/vi; then
			echo FAILED to copy ./vim to $EMERGENCY_DEST/vi
		else
			echo $EMERGENCY_DEST/vi is stripped
		fi
	}

	#Build regular vim this way:
	function makeVim() {
		trap return SIGTERM SIGINT

		$SUDO -v

		if ! nice make distclean; then rm -f auto/config.cache; fi

		if ! nice ./configure --prefix=$DEST --with-features=huge --enable-perlinterp --enable-pythoninterp; then return; fi

		if ! nice make $MAKE_JOBS; then return; fi

		echo "Installing Vim binary to $DEST"
		if ! nice $SUDO make installvimbin; then return; fi
		echo "${DEST}/bin/vim is not stripped"
		echo
		echo 'Run `make install` if you want to install the entire'
		echo 'updated Vim suite of runtime files.'
	}

	>&1 <<-MESSAGE
	###
	######
	############
	########################
	BuildVim functions defined:
		makeVim()
		emergencyVim()
	########################
	############
	######
	###
	MESSAGE

	cd ~fadein/build/vim.hg
}

source $0:h/__TASKS.zsh
