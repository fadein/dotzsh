#!/bin/zsh

PURPOSE='Rebuild Vim from GitHub'
VERSION="1.5"
   DATE="Wed Aug  3 10:01:22 MDT 2016"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

TASKNAME=$0:t:r

env() {
	SHUSH=1
	if command -v sudo &>/dev/null; then
		SUDO=$(command -v sudo)
	else
		SUDO=:
	fi
	DEST=/usr
	EMERGENCY_DEST=/bin
	NPROC=/usr/bin/nproc

	OPTS_EMERGENCY="--with-features=small --disable-gui --disable-gpm --disable-acl"
	OPTS_REGULAR="--with-features=huge --enable-perlinterp --enable-pythoninterp --enable-termtruecolor"

	#Count number of CPUs in this system and add one
	MAKE_JOBS=-j$(( $(nproc) + 1 ))

	#Set up a TODO list
	_TODO=(
		'$ git pull'
		'$ cd src/'
		'run emergencyVim() to build a minimal /bin/vi'
		'run makeVim() to build vim & gvim'
		'run `sudo make install` to install the suite of runtime files'
		)

	#Build emergency Vim (only requires glibc and ncurses)
	function emergencyVim() {
		trap return SIGTERM SIGINT

		$SUDO -v

		if ! nice make distclean; then rm -f auto/config.cache; fi

		if ! nice ./configure --prefix=$DEST $OPTS_EMERGENCY; then return; fi

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

	#Build regular Vim this way:
	function makeVim() {
		trap return SIGTERM SIGINT

		$SUDO -v

		if ! nice make distclean; then rm -f auto/config.cache; fi

		if ! nice ./configure --prefix=$DEST $OPTS_REGULAR; then return; fi

		if ! nice make $MAKE_JOBS; then return; fi

		echo "Installing Vim binary to $DEST"
		if ! nice $SUDO make installvimbin; then return; fi
		echo "${DEST}/bin/vim is not stripped"
		echo
		echo 'Run `sudo make install` if you want to install the entire'
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

	cd ~/build/vim.git
}

source $0:h/__TASKS.zsh
