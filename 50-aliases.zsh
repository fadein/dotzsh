#
# User-specific aliases
# +,/^\(#.*\)\?$/-1sort
alias -- +r='chmod +r'
alias -- +w='chmod +w'
alias -- +x='chmod +x'
alias -- -r='chmod -r'
alias -- -w='chmod -w'
alias -- -x='chmod -x'
alias backlighter='noglob backlighter'
alias clipi='xclip -sel clip -i'
alias clipin='xclip -sel clip -i'
alias clipo='xclip -sel clip -o'
alias clipout='xclip -sel clip -o'
alias commit='git show'
alias copy='cp -i'
alias cp='cp -i'
alias csi='csi -wq'
alias ctags='ctags --fields=+iaS --extra=+fq'
alias date='date +"%a, %b %e %Y  %R %Z"'
alias del='rm -i'
alias deltree='rm -rf'
alias df='df -h'
alias diff='diff --color=auto'
alias diffu='diff --color=auto -u'
alias dmesg='dmesg -H'
alias du='du -h'
alias epoch='strftime %c'
alias feh='feh --scale-down'
alias ffmpeg='ffmpeg -hide_banner'
alias ffplay='ffplay -hide_banner'
alias ffprobe='ffprobe -hide_banner'
alias findd='find . -type d -name'
alias findf='find . -type f -name'
alias free='free -m'
alias gcc-defines='gcc -dM -E -x c - </dev/null | sort'
alias gdb='gdb -q'
alias grep='grep -n --color=auto'
alias grepi='grep -i -n --color=auto'
alias grev='grep -vn --color=auto'
alias ip='ip -color=auto'
alias lolcat='lolcat -v .85'
alias lynx='lynx -use_mouse'
alias mcp='mcp -i'
alias mmv='mmv -i'
alias move='mv -i'
alias mplayer='mplayer -af scaletempo'
alias mv='mv -i'
alias niceme='renice -n 10 -p $$'
alias nl='nl -ba'
alias pd=pushd
alias perld='perl -de0'
alias pgrep='pgrep -l'
alias pseudo=sudo
alias pwd='pwd -P'
alias python=python3
alias rl=readlink
alias rm='rm -i'
alias screen-r='screen -r'
alias screenr='screen -r'
alias screern='screen -r'
alias topu="htop -u $USER"
alias vimdiff='vim -d'
alias which='which -p'

#
# because I can't spell...
# +,/^\(#.*\)\?$/-1sort
alias cdx=cd
alias cs=cd
alias ecoh=echo
alias ehco=echo
alias fiel=file
alias gerp=grep
alias gitlog='git log'
alias got=git
alias grpe=grep
alias gti=git alias igt=git
alias ivm=vim
alias jbos=jobs
alias gi=git
alias gitc=git
alias jods=jobs
alias jorbs=jobs
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
alias vm=vim
alias vmi=vim

#
# vi commands
# +,/^\(#.*\)\?$/-1sort
alias /=ack
alias :close='echo E444: Cannot close last window'
alias :e=vim
alias :ex=vim
alias :ls=ls
alias :q!=exit
alias :q=exit
alias :qa=exit
alias :r=cat
alias :r=less
alias :split=vim
alias :w!='echo E503: is not a file or writable device'
alias :w='echo "E505: is read-only (add ! to override)"'
alias :wq=exit
alias :x!=exit
alias :x=exit
alias ZQ=exit
alias ZZ=exit

#
# suffix aliases
# +,/^\(#.*\)\?$/-1sort
alias -s beat=vim
alias -s com=lynx
alias -s doc=lowriter
alias -s docx=lowriter
alias -s frag=vim
alias -s ig=vim
alias -s md=vim
alias -s net=lynx
alias -s odp=loimpress
alias -s ods=localc
alias -s odt=lowriter
alias -s org=lynx
alias -s ppt=loimpress
alias -s pptx=loimpress
alias -s txt=vim
alias -s xls=localc
alias -s xlsx=localc

#
# OS-specific
#
case $OSTYPE in
    darwin*)
        # +,/;;$/-1sort
        alias l='ls -F --color=yes'
        alias la='ls -Fa --color=yes'
        alias ll='ls -Flh --color=yes'
        alias lla='ls -Flha --color=yes'
        alias lld='ls -Flhd --color=yes'
        alias ls='ls -F --color=yes'
        alias lsd='ls -Fd --color=yes'
        alias ltr='ls -Fltr --color=yes'
        ;;
    linux*|*)
        # +,/;;$/-1sort
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
        ;;
esac
