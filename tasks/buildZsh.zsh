#!/bin/env zsh

 PURPOSE="Build Zsh like a boss"
 VERSION="1.2"
    DATE="Thu Mar  5 09:53:23 MST 2015"
  AUTHOR="efalor@spillman.com"
PROGNAME=$0
TASKNAME=$0:t:r

env() {

	# GLOBAL FOR HELP FUNCTION
	typeset -gA _HELP

	_HELP+=('configZsh' 'Configure Zsh for this OS')
	configZsh() {
		[[ -x configure ]] && \
			case $(uname) in
				AIX|Linux)
					./configure --disable-dynamic --disable-restricted-r --disable-pcre --disable-cap --disable-gdbm ;;
				*)
					print "I cannae configure your Zsh on this God-forsaken OS!" ;;
			esac
	}

	_HELP+=('modulesZsh' 'Hack config.modules to enable the correct features')
	modulesZsh() {
		if [[ -f config.modules ]]; then
			>config.modules <<-'CONFIG_MODULES'
			# Edit this file to change the way modules are loaded.
			# The format is strict; do not break lines or add extra spaces.
			# Run `make prep' if you change anything here after compiling
			# (there is no need if you change this just after the first time
			# you run `configure').
			#
			# Values of `link' are `static', `dynamic' or `no' to compile the
			# module into the shell, link it in at run time, or not use it at all.
			# In the final case, no attempt will be made to compile it.
			# Use `static' or `no' if you do not have dynamic loading.
			#
			# Values of `load' are `yes' or `no'; if yes, any builtins etc.
			# provided by the module will be autoloaded by the main shell
			# (so long as `link' is not set to `no').
			#
			# Values of `auto' are `yes' or `no'. configure sets the value to
			# `yes'.  If you set it by hand to `no', the line will be retained
			# when the file is regenerated in future.
			#
			# Note that the `functions' entry extends to the end of the line.
			# It should not be quoted; it is used verbatim to find files to install.
			#
			# You will need to run `config.status --recheck' if you add a new
			# module.
			#
			# You should not change the values for the pseudo-module zsh/main,
			# which is the main shell (apart from the functions entry).
			name=zsh/main modfile=Src/zsh.mdd link=static auto=yes load=yes functions=Functions/Chpwd/* Functions/Exceptions/* Functions/Misc/* Functions/MIME/* Functions/Prompts/* Functions/VCS_Info/* Functions/VCS_Info/Backends/*
			name=zsh/rlimits modfile=Src/Builtins/rlimits.mdd link=static auto=yes load=yes
			name=zsh/sched modfile=Src/Builtins/sched.mdd link=static auto=yes load=yes
			name=zsh/attr modfile=Src/Modules/attr.mdd link=no auto=yes load=no
			name=zsh/cap modfile=Src/Modules/cap.mdd link=no auto=yes load=no
			name=zsh/clone modfile=Src/Modules/clone.mdd link=no auto=yes load=no
			name=zsh/curses modfile=Src/Modules/curses.mdd link=no auto=yes load=no
			name=zsh/datetime modfile=Src/Modules/datetime.mdd link=static auto=yes load=yes functions=Functions/Calendar/*
			name=zsh/db/gdbm modfile=Src/Modules/db_gdbm.mdd link=no auto=yes load=no
			name=zsh/example modfile=Src/Modules/example.mdd link=no auto=yes load=no
			name=zsh/files modfile=Src/Modules/files.mdd link=no auto=yes load=no
			name=zsh/langinfo modfile=Src/Modules/langinfo.mdd link=static auto=yes load=no
			name=zsh/mapfile modfile=Src/Modules/mapfile.mdd link=static auto=yes load=yes
			name=zsh/mathfunc modfile=Src/Modules/mathfunc.mdd link=no auto=yes load=no
			name=zsh/newuser modfile=Src/Modules/newuser.mdd link=no auto=yes load=no functions=Scripts/newuser Functions/Newuser/*
			name=zsh/parameter modfile=Src/Modules/parameter.mdd link=static auto=yes load=yes
			name=zsh/pcre modfile=Src/Modules/pcre.mdd link=no auto=yes load=no
			name=zsh/regex modfile=Src/Modules/regex.mdd link=static auto=yes load=yes
			name=zsh/net/socket modfile=Src/Modules/socket.mdd link=no auto=yes load=no
			name=zsh/stat modfile=Src/Modules/stat.mdd link=static auto=yes load=yes
			name=zsh/system modfile=Src/Modules/system.mdd link=no auto=yes load=no
			name=zsh/net/tcp modfile=Src/Modules/tcp.mdd link=no auto=yes load=no functions=Functions/TCP/*
			name=zsh/termcap modfile=Src/Modules/termcap.mdd link=static auto=yes load=yes
			name=zsh/terminfo modfile=Src/Modules/terminfo.mdd link=static auto=yes load=yes
			name=zsh/zftp modfile=Src/Modules/zftp.mdd link=no auto=yes load=no functions=Functions/Zftp/*
			name=zsh/zprof modfile=Src/Modules/zprof.mdd link=no auto=yes load=no
			name=zsh/zpty modfile=Src/Modules/zpty.mdd link=no auto=yes load=no
			name=zsh/zselect modfile=Src/Modules/zselect.mdd link=no auto=yes load=no
			name=zsh/zutil modfile=Src/Modules/zutil.mdd link=static auto=yes load=yes
			name=zsh/compctl modfile=Src/Zle/compctl.mdd link=static auto=yes load=yes
			name=zsh/complete modfile=Src/Zle/complete.mdd link=static auto=yes load=yes functions=Completion/*comp* Completion/AIX/*/* Completion/BSD/*/* Completion/Base/*/* Completion/Cygwin/*/* Completion/Darwin/*/* Completion/Debian/*/* Completion/Linux/*/* Completion/Mandriva/*/* Completion/Redhat/*/* Completion/Solaris/*/* Completion/openSUSE/*/* Completion/Unix/*/* Completion/X/*/* Completion/Zsh/*/*
			name=zsh/complist modfile=Src/Zle/complist.mdd link=static auto=yes load=yes
			name=zsh/computil modfile=Src/Zle/computil.mdd link=static auto=yes load=yes
			name=zsh/deltochar modfile=Src/Zle/deltochar.mdd link=no auto=yes load=no
			name=zsh/zle modfile=Src/Zle/zle.mdd link=static auto=yes load=yes functions=Functions/Zle/*
			name=zsh/zleparameter modfile=Src/Zle/zleparameter.mdd link=static auto=yes load=yes
			CONFIG_MODULES
		else
			print "I couldn't find the file config.modules in the cwd"
		fi
	}

	_HELP+=('makeZsh' 'Build Zsh; pass an integer arg to indicate number of make jobs')
	makeZsh() {
		local JORBS
		[[ "$1" -gt 1 ]] && JORBS=-j$1

		[[ -f Makefile ]] && \
			case $(uname) in
				AIX)
					LDFLAGS='-static -lcrypt' make $JORBS;;
				Linux)
					make $JORBS;;
				*)
					print "I cannae build you your Zsh on this God-forsaken OS!" ;;
			esac
	}

	_HELP+=('pluginsZsh' 'Copy appropriate plugins from build area to bundle')
	pluginsZsh() {
		if [[ ! -d $BUNDLE ]]; then
			return $( warn "Bundle area '$BUNDLE' is not present or is not a dir" )
		fi

		# Cleanup & install Completion plugins
		if [[ ! -d Completion ]]; then 
			return $( warn "Completion/ plugins dir not found!" )
		else
			print Replacing Completion plugins...
			( cd $BUNDLE; rm -rf Completion; mkdir Completion )
			cp Completion/{AIX,Base,Linux,Redhat,Unix,Zsh}/**/* $BUNDLE/Completion
			cp Completion/{README,bashcompinit,compaudit,compdump,compinit,compinstall} $BUNDLE/Completion
		fi

		# Cleanup & install Functions
		if [[ ! -d Functions ]]; then
			return $( warn "Functions/ dir not found!" )
		else
			print Replacing Functions...
			( cd $BUNDLE; rm -rf Functions ; mkdir Functions )
			cp Functions/{Calendar,Chpwd,Compctl,Example,Exceptions,MIME,Misc,Prompts,Zle}/**/* $BUNDLE/Functions
		fi
	}

	_HELP+=('installZsh' 'Copy binary Src/zsh into bundle, naming it for the platform and version')
	installZsh() {
		# the version number is found in Src/version.h
		if [[ -z "$NEWVER" ]]; then
			if ! getNewVer; then
				warn "I can't install Zsh w/o knowing the version"
				retunr
			fi
		fi
		case $(uname) in
			AIX)   OS=aix ;;
			Linux) OS=linux ;;
		esac
		cp Src/zsh $BUNDLE/zsh-${NEWVER}-${OS}

		print "Be sure to update the version in $BUNDLE/zsh"
	}

	_HELP+=('getNewVer' 'Get the vesion number of this build of Zsh from version.h')
	getNewVer() {
		if [[ -f Src/version.h ]]; then
			NEWVER=$( sed -ne 's/#define ZSH_VERSION "\([^"]*\)"/\1/p' Src/version.h)
		else
			warn "I can't find Src/version.h. Am I in the base Zsh directory?"
			NEWVER=
		fi
	}

	_TODO=(
		"$ configZsh"
		"$ modulesZsh"
		"$ makeZsh"
		"$ pluginsZsh"
		"$ installZsh")

	# Print a useful message to remind the user what to do next
	>&1 <<-MESSAGE
	###
	############
	########################
	##########################################

	Get the latest Zsh sources from 
	http://zsh.sourceforge.net/Arc/source.html

	News
	http://zsh.sourceforge.net/News/

	Release notes
	http://zsh.sourceforge.net/releases.html

	Run 'help' for information about convenience functions

	##########################################
	########################
	############
	###
	MESSAGE

	_KEEP_FUNCTIONS=(warn)

	BUNDLE=/opt/debug/efalor/zsh_bundle/.zsh
	NEWVER=

	[[ -d ~/build ]] && SHUSH=1 cd ~/build
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
