#
# User-specific aliases
#
alias clipi="xclip -sel clip -i"
alias clipin="xclip -sel clip -i"
alias clipo="xclip -sel clip -o"
alias clipout="xclip -sel clip -o"
alias cp='cp -i'
alias csi=csi\ -q
alias ctags='ctags --fields=+iaS --extra=+fq'
alias curl='curl -A "Mozilla/4.0"'
alias date='date +"%a, %b %e %Y  %R %Z"'
alias diff='diff --color=auto'
alias diffu='diff --color=auto -u'
alias df='df -h'
alias dmesg="dmesg -H"
alias du='du -h'
alias feh='feh --scale-down'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias findd='find . -type d -name'
alias findf='find . -type f -name'
alias free='free -m'
alias gdb='gdb -q'
alias grep='grep -n --color=auto'
alias grepi='grep -i -n --color=auto'
alias grev='grep -vn --color=auto'
alias l='ls --color=auto -F'
alias la='ls --color=auto -Fa'
alias ll='ls --color=auto -Flh'
alias lla='ls --color=auto -Flha'
alias lld='ls --color=auto -Flhd'
alias ls='ls --color=auto -F'
alias lsd='ls --color=auto -Fd'
alias lsq='ls --quoting-style=shell-escape'
alias lt='ls --color=auto --full-time -Ft'
alias ltr='ls --color=auto -Fltr'
alias lynx='lynx -use_mouse'
alias mplayer='mplayer -af scaletempo'
alias mv='mv -i'
alias niceme='renice -n 10 -p $$'
alias nl='nl -ba'
alias pd=pushd
alias perld='perl -de0'
alias pgrep='pgrep -l'
alias pwd='pwd -P'
alias rm='rm -i'
alias topu="top -u $USER"
alias vimdiff='vim -d'
alias which="which -p"

#
# because I can't spell...
#
alias cs=cd
alias ecoh=echo
alias ehco=echo
alias fiel=file
alias grpe=grep
alias got=git
alias gti=git
alias igt=git
alias ivm=vim
alias jods=jobs
alias les=less
alias lss=less
alias maek=make
alias mak=make
alias mor=more
alias mplayre=mplayer
alias mroe=more
alias pgerp='pgrep -l'
alias pyhton=python
alias scd=cd
alias sl=ls
alias sls=ls

#
# vi commands
#
alias :close='echo Cannot close last window'
alias :e=vim
alias :q!=exit
alias :q=exit
alias :qa=exit
alias :r='<'
alias :w="echo Th15 1Sn\'7 vi, 5Uc\|\<4\!"
alias :wq=exit
alias :x=exit

#
# 1337 h4X0r 4L14535
#
alias bye=exit
alias copy='cp -i'
alias del='rm -i'
alias deltree='rm -rf'
alias epoch='strftime %c'
alias move='mv -i'
alias screen-r=screen\ -r
alias screenr=screen\ -r
alias screern=screen\ -r
alias epoch='strftime %c'
alias gcc-defines='gcc -dM -E -x c - </dev/null | sort'

#
# suffix aliases
#
alias -s com=lynx
alias -s conf=vim
alias -s net=lynx
alias -s org=lynx
alias -s txt=vim
alias -s docx=lowriter
alias -s doc=lowriter
alias -s odt=lowriter
alias -s ods=localc
alias -s xlsx=localc
alias -s xls=localc
alias -s odp=loimpress
alias -s pptx=loimpress
alias -s ppt=loimpress
