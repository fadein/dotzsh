#
# Hashed directory shortcuts
#
# To use, prepend a ~ to their name. Ex:
#   cd ~vlp
#

# system destinations
hash -d nm=/etc/NetworkManager/system-connections
hash -d x11=/etc/X11
hash -d cups=/etc/cups
hash -d rc.d=/etc/rcd
hash -d slackpkg=/etc/slackpkg
hash -d ssh=/etc/ssh
hash -d vl=/var/log
hash -d vlp=/var/log/packages

hash -d ulb=/usr/local/bin
hash -d stow=/usr/local/bin/stow

hash -d dict=/usr/share/dict
hash -d distfiles=/usr/sbo/distfiles
hash -d lib64=/usr/lib64
hash -d sborepo=/usr/sbo/repo
hash -d ub=/usr/bin
hash -d ul=/usr/lib
hash -d um=/usr/man
hash -d usl=/usr/src/linux

# home destinations
hash -d home=$HOME
hash -d cache=~home/.cache
hash -d config=~home/.config
hash -d down=~home/downloads
hash -d dwm=~home/.dwm
hash -d local=~home/.local
hash -d localbin=~home/.local/bin
hash -d pyenv=~home/.pyenv
hash -d tutor=~home/school/shell-tutor-dev
hash -d vim=~home/.vim
hash -d zsh=~home/.zsh

# development
hash -d devel=~home/devel
hash -d bfl=~devel/BugFixLogs
hash -d c=~devel/c
hash -d homedir=~devel/homedir
hash -d perl=~devel/perl
hash -d python=~devel/python
hash -d sbo=~devel/SBOoverride
hash -d scheme=~devel/scheme
hash -d shell=~devel/shell

# school destinations
hash -d school=~home/school
hash -d 1400=~home/1400
hash -d 1440=~home/1440
hash -d 3450=~home/3450
hash -d abet=~school/ABET_Chair
hash -d automation=~school/course-automation
hash -d canvas=~school/CanvasAPI
hash -d dm=~school/digital_measures
hash -d emails=~school/emails
hash -d gitlab=~school/GitLab
hash -d lecnotes=~school/lecnotes-test
hash -d lor=~school/letters_of_recommendation
hash -d navigation=~school/navigation
hash -d rec=~school/letters_of_recommendation
hash -d scanner=~school/scanner
hash -d videos=~school/videos
