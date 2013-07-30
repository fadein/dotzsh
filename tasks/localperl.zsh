#!/bin/env zsh

PURPOSE="support building local Perl modules"
VERSION="1.0"
   DATE="Thu Feb  7 22:17:15 MST 2013"
 AUTHOR="Erik Falor"

PROGNAME=$0:t
TASKNAME=$0:t:r

env() {

    #TODO list of modules to build
    MODS=('Proc::Background'
        'XML::Simple'
        'Sort::External'
        'File::ReadBackwards'
        'Date::Calc'
        'DateTime'
        'DateTime::Duration'
        'Date::Parse'
        'Date::Format')

	L_PERLLIB=~/perl5/lib/perl5
	PERL5LIB=~/perl5/lib/perl5
	[[ -n "$PERL5LIB" ]] \
			&& export PERL5LIB="${L_PERLLIB}/lib/perl5:${PERL5LIB}" \
			|| export PERL5LIB=${L_PERLLIB}/lib/perl5

	[[ -n "$PERL_MM_OPT" ]] \
			&& export PERL_MM_OPT="INSTALL_BASE=${L_PERLLIB} ${PERL_MM_OPT}" \
			|| export PERL_MM_OPT=INSTALL_BASE=${L_PERLLIB}

	[[ -n "$PERL_MB_OPT" ]] \
			&& export PERL_MB_OPT="--install_base=${L_PERLLIB} ${PERL_MB_OPT}" \
			|| export PERL_MB_OPT=--install_base=${L_PERLLIB}


    if ! [[ -d $L_PERLLIB ]]; then
        mkdir -p $L_PERLLIB
        echo "Created directory $L_PERLLIB"
    fi

	unset L_PERLLIB

    PATH=/sti/development/aix.v6.1.32bit/perl/V5.16.3/bin:$PATH
    alias perl=perl5.16.3\ -m-lib=/usr/local/lib/perl5/site_perl/5.8.0

	if declare -F uniquify >/dev/null; then
			PERL5LIB=$(uniquify "$PERL5LIB")
			PERL_MM_OPT=$(uniquify "$PERL_MM_OPT" ' ')
			PERL_MB_OPT=$(uniquify "$PERL_MB_OPT" ' ')
	fi
}

#
# Tie it all together
source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
