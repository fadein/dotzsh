# Timestamp in RPROMPT updates when command is run
# Inspired by https://stackoverflow.com/questions/13125825/zsh-update-prompt-with-current-time-when-a-command-is-started
#
# Setting then unsetting `psvar` causes the time stamp to appear only
# after accepting the command line
WHEN="%F{white}%D{%T} "
function _reset-prompt-and-accept-line {
    psvar=(1)
    zle reset-prompt
    psvar=()
    zle .accept-line     # Note the . meaning the built-in accept-line.
}
zle -N accept-line _reset-prompt-and-accept-line


#Choose color for host and username #{
if ! functions hostcolor >/dev/null; then
    case $OSTYPE in
        aix*)
            function hostcolor { print "%F{cyan}$1%f"; } ;;
        linux*)
            case $HOST in
                apollo)
                    function hostcolor { print "%B%F{yellow}$1%f%b"; } ;;
                gemini)
                    function hostcolor { print "%B%F{cyan}$1%f%b"; } ;;
                voyager?)
                    function hostcolor { print "%B%F{white}$1%f%b"; } ;;
                explorer)
                    function hostcolor { print "%B%F{blue}$1%f%b"; } ;;
                viking*)
                    function hostcolor { print "%B%F{magenta}$1%f%b"; } ;;
                endeavour*)
                    function hostcolor { print "%F{red}$1%f"; } ;;
                columbia*)
                    function hostcolor { print "%B%F{yellow}$1%f%b"; } ;;
                mariner)
                    function hostcolor { print "%F{magenta}%K{black}$1%k%f"; } ;;
                atlantis*)
                    function hostcolor { print "%F{green}$1%f"; } ;;
                *)
                    function hostcolor { print "%F{yellow}%K{black}$1%k%f"; } ;;
            esac ;;
        cygwin*)
            function hostcolor { print "%B%F{blue}$1%f%b"; } ;;
        *)
            function hostcolor { print "%B%F{red}$1%f%b"; } ;;
    esac
fi

# Make the color of typed text be green for a regular user and red for root
case $UID in
    "0")
        _UTEXT="%B%F{red}"
        _UEND='%f%b'
        function usercolor { print "%B%F{red}$1%f%b"; } ;;
    *)
        _UTEXT="%B%F{green}"
        _UEND='%f%b'
        function usercolor { print "%B%F{green}$1%f%b"; } ;;
esac
#}


setopt prompt_subst
function dim {
    print "${COLUMNS}x${LINES} "
}


# Render the window title for virtual terminals
function set-terminal-title {
    local ROOT=
    [[ $UID == 0 ]] && ROOT="* "
    builtin print -n "\e]0;${ROOT}$@\a"
    [[ $TERM == screen* ]] && builtin print -n "\ek${ROOT}$2\e\\"
}


# Set the XTerm window title property
# The default value appears as "[host] zsh tty cwd"
function precmd {
    set-terminal-title "[${HOST%%.*}] " "zsh" "$PWD ${TTY#/dev/}"
}


# Helper to set the terminal window's title to the running command,
# even if that command is a job that has been returned to the
# foreground.
function preexec() {
    emulate -L zsh
    # reset console video attribs to null
    print -nP "\e[0;0m"

    # Re-parse the command line
    local -a cmd;
    cmd=(${(z)1})

    # Construct a command that will output the desired job number.
    case $cmd[1] in
        fg)
            if (( $#cmd == 1 )); then
                # No arguments, must find the current job
                cmd=(builtin jobs -l %+)
            else
                # Replace the command name, ignore extra args.
                cmd=(builtin jobs -l ${(Q)cmd[2]})
            fi
            ;;

        %*)
            cmd=(builtin jobs -l ${(Q)cmd[1]}) # Same as "else" above
            ;;

        exec)
            shift cmd    # If the command is 'exec', drop that, because
            ;&           # we'd rather just see the command that is being
                         # exec'd.
                         #
                         # Note the ;& case terminator to fall
                         # through to the next case

        *)
            set-terminal-title "[$HOSTNAME] " $cmd[1]:t $cmd[2,-1]    # Not resuming a job,
            return                                       # so we're all done
            ;;
    esac

    local -A jt; jt=(${(kv)jobtexts})       # Copy jobtexts for subshell

    # Run the command, read its output, and look up the jobtext.
    # Could parse $rest here, but $jobtexts (via $jt) is easier.
    $cmd >>(read num rest
        cmd=(${(z)${(e):-\$jt$num}})
        set-terminal-title '[%m] ' $cmd[1]:t $cmd[2,-1]) 2>/dev/null
}


function plain() {
    PS1='%n@%m %~ %# '
}


#The jobcount is colored red if non-zero.
function colorful() {
    PROMPT="$ZSH_VERSION %(?..%F{white}%K{red}%?%k%f %S)$(usercolor %n)@$(hostcolor %M)%(?..%s) %~ %# $_UTEXT"
    RPROMPT="${_UEND}%B%(1V.$WHEN.)%F{yellow}${TASK:+$TASK${class+*} }${TTYRECLOG:+$TTYRECLOG:t }%f%b%F{cyan}%f%F{yellow}!%!%f %F{cyan}%y%f%1(j. %F{red}%%%j%f.)"
}


#If this shell is spawned within GNU Screen, prepend "$WINDOW." to
#the jobcount.  The jobcount is colored red if non-zero.
function screen() {
    PROMPT="$ZSH_VERSION %(?..%F{white}%K{red}%?%k%f %S)$(usercolor %n)@$(hostcolor %m)%(?..%s) %~ %# $_UTEXT"
    RPROMPT="${_UEND}%B%(1V.$WHEN.)%F{yellow}${TASK:+$TASK${class+*} }${TTYRECLOG:+$TTYRECLOG:t }%f%b%F{cyan}${WINDOW:+$WINDOW }%f%F{yellow}!%!%f %F{cyan}%y%f%1(j. %F{red}%%%j%f.)"
}


function _git_branch_details() {
    # split input on newlines
    local IFS=$'\n'

    #branch status
    local branch=
    local upstream=
    local diverged=

    # branch status patterns
    local  rx_detached="^## HEAD \(no branch\)"
    local    rx_branch="^## ([^.[:space:]]+)(\.\.\.(([^[:space:]]+)( \[(ahead|behind) [0-9]+\])))?"
    local rx_brand_new="^## No commits yet on master"

    # file status counters
    local    staged=""
    local     dirty=""
    local untracked=""
    local  unmerged=""

    local                rx_notUpdated="^ [MD]"
    local                rx_updatedIdx="^M[ MD]"
    local                rx_addedToIdx="^A[ MD]"
    local            rx_deletedFromIdx="^D[ M]"
    local              rx_renamedInIdx="^R[ MD]"
    local               rx_copiedInIdx="^C[ MD]"
    local      rx_indexWorkTreeMatches="^[MARC] "
    local rx_workTreeChangedSinceIndex="^[ MARC]M"
    local         rx_deletedInWorkTree="^[ MARC]D"
    local       rx_unmergedBothDeleted="^DD"
    local         rx_unmergedAddedByUs="^AU"
    local     rx_unmergedDeletedByThem="^UD"
    local       rx_unmergedAddedByThem="^UA"
    local       rx_unmergedDeletedByUs="^DU"
    local         rx_unmergedBothAdded="^AA"
    local      rx_unmergedBothModified="^UU"
    local                 rx_untracked="^\?\?"
    local        rx_changedAndUnstaged="^[MADRC]M"
    local                     rx_fatal="^fatal:"
    local rx_inIndex="${rx_updatedIdx}|${rx_addedToIdx}|${rx_deletedFromIdx}|${rx_renamedInIdx}|${rx_copiedInIdx}"
    local rx_inWork=${rx_notUpdated}
    local rx_unmerged="${rx_unmergedBothDeleted}|${rx_unmergedAddedByUs}|${rx_unmergedDeletedByThem}|${rx_unmergedAddedByThem}|${rx_unmergedDeletedByUs}|${rx_unmergedBothAdded}|${rx_unmergedBothModified}"

    local LINE=
    for LINE in $( git status --branch --porcelain 2>&1 )
    do
        if [[ ${LINE} =~ ${rx_brand_new} ]]; then
            branch="Initial"

        elif [[ ${LINE} =~ ${rx_detached} ]]; then
            # get SHA1 of current commit when in detached HEAD state
            # indicate detached head by prepending with *
            branch="*"$(git rev-parse --short HEAD 2>/dev/null)

        elif [[ ${LINE} =~ ${rx_branch} ]]; then
            branch=$match[1] upstream=$match[4] diverged=$match[5]
            if [[ ! -z $match[6] ]]; then
                if [[ $match[6] = 'ahead' ]]; then
                    diverged=+
                else
                    diverged=-
                fi
            fi
            #print "\nmatch[1]='$match[1]' match[2]='$match[2]' match[3]='$match[3]' match[4]='$match[4]' match[5]='$match[5]' match[6]='$match[6]'\n"

        elif [[ ${LINE} =~ ${rx_changedAndUnstaged} ]]; then
            let staged++
            let dirty++

        elif [[ ${LINE} =~ ${rx_inIndex} ]]; then
            let staged++

        elif [[ ${LINE} =~ ${rx_inWork} ]]; then
            let dirty++

        elif [[ ${LINE} =~ ${rx_untracked} ]]; then
            let untracked++

        elif [[ ${LINE} =~ ${rx_unmerged} ]]; then
            let unmerged++

        elif [[ ${LINE} =~ ${rx_fatal} ]]; then
            return
        fi
    done

    # show number of non-indexed changes in red
    # and number of indexed changes in green
    if [[ -n "${staged}${dirty}${unmerged}${untracked}" ]]; then
        print "%(?..%s) (%(?..%S)%F{green}${staged}%F{red}${dirty}%F{yellow}${untracked}%F{red}%U${unmerged}%u%s %(?..%S)${branch}%s${upstream:+ }%(?..%S)${diverged+%F{red\}$diverged}${upstream}%f%(?..%s))"
    else
        print "%(?..%s) (%(?..%S)%F{green}${branch}${upstream:+ }${diverged+%F{red\}$diverged}${upstream}%f%(?..%s))"
    fi
}


# git prompt main entry point
function git() {
    #TODO: see if I can re-write this to not rely on the embedded $()
    #and thereby not need to `setopt prompt_subst`
    #maybe add _git_branch_details as a precmd, and delete it when
    #switching to another prompt?
    PROMPT="$ZSH_VERSION %(?..%F{white}%K{red}%?%k%f %S)$(hostcolor %4~)\$(_git_branch_details)%(?..%s) $(usercolor '%#') ${_UTEXT}"
    #If this shell is spawned within GNU Screen, prepend "$WINDOW." to
    #the jobcount.  The jobcount is colored red if non-zero.
    RPROMPT="${_UEND}%B%(1V.$WHEN.)%F{yellow}${TASK:+$TASK${class+*} }${TTYRECLOG:+$TTYRECLOG:t }%f%b%F{cyan}${WINDOW:+$WINDOW }%f%F{yellow}!%!%f %F{cyan}%y%f%1(j. %F{red}%%%j%f.)"
}


###############################################
## MinGW prompt - borrowed from Git For Windows
###############################################
__git_eread ()
{
    test -r "$1" && IFS='
' read "$2" < "$1"
}



__git_ps1 ()
{
    local exit=$?;
    local pcmode=no;
    local detached=no;
    local ps1pc_start='\u@\h:\w ';
    local ps1pc_end='\$ ';
    local printf_format=' (%s)';
    case "$#" in
        2 | 3)
            pcmode=yes;
            ps1pc_start="$1";
            ps1pc_end="$2";
            printf_format="${3:-$printf_format}";
            PS1="$ps1pc_start$ps1pc_end"
        ;;
        0 | 1)
            printf_format="${1:-$printf_format}"
        ;;
        *)
            return $exit
        ;;
    esac;
    local ps1_expanded=yes;
    [ -z "${ZSH_VERSION-}" ] || [[ -o PROMPT_SUBST ]] || ps1_expanded=no;
    [ -z "${BASH_VERSION-}" ] || shopt -q promptvars || ps1_expanded=no;
    local repo_info rev_parse_exit_code;
    repo_info="$(git rev-parse --git-dir --is-inside-git-dir            --is-bare-repository --is-inside-work-tree              --short HEAD 2>/dev/null)";
    rev_parse_exit_code="$?";
    if [ -z "$repo_info" ]; then
        return $exit;
    fi;
    local short_sha="";
    if [ "$rev_parse_exit_code" = "0" ]; then
        short_sha="${repo_info##*
}";
        repo_info="${repo_info%
*}";
    fi;
    local inside_worktree="${repo_info##*
}";
    repo_info="${repo_info%
*}";
    local bare_repo="${repo_info##*
}";
    repo_info="${repo_info%
*}";
    local inside_gitdir="${repo_info##*
}";
    local g="${repo_info%
*}";
    if [ "true" = "$inside_worktree" ] && [ -n "${GIT_PS1_HIDE_IF_PWD_IGNORED-}" ] && [ "$(git config --bool bash.hideIfPwdIgnored)" != "false" ] && git check-ignore -q .; then
        return $exit;
    fi;
    local r="";
    local b="";
    local step="";
    local total="";
    if [ -d "$g/rebase-merge" ]; then
        __git_eread "$g/rebase-merge/head-name" b;
        __git_eread "$g/rebase-merge/msgnum" step;
        __git_eread "$g/rebase-merge/end" total;
        if [ -f "$g/rebase-merge/interactive" ]; then
            r="|REBASE-i";
        else
            r="|REBASE-m";
        fi;
    else
        if [ -d "$g/rebase-apply" ]; then
            __git_eread "$g/rebase-apply/next" step;
            __git_eread "$g/rebase-apply/last" total;
            if [ -f "$g/rebase-apply/rebasing" ]; then
                __git_eread "$g/rebase-apply/head-name" b;
                r="|REBASE";
            else
                if [ -f "$g/rebase-apply/applying" ]; then
                    r="|AM";
                else
                    r="|AM/REBASE";
                fi;
            fi;
        else
            if [ -f "$g/MERGE_HEAD" ]; then
                r="|MERGING";
            else
                if [ -f "$g/CHERRY_PICK_HEAD" ]; then
                    r="|CHERRY-PICKING";
                else
                    if [ -f "$g/REVERT_HEAD" ]; then
                        r="|REVERTING";
                    else
                        if [ -f "$g/BISECT_LOG" ]; then
                            r="|BISECTING";
                        fi;
                    fi;
                fi;
            fi;
        fi;
        if [ -n "$b" ]; then
            :;
        else
            if [ -h "$g/HEAD" ]; then
                b="$(git symbolic-ref HEAD 2>/dev/null)";
            else
                local head="";
                if ! __git_eread "$g/HEAD" head; then
                    return $exit;
                fi;
                b="${head#ref: }";
                if [ "$head" = "$b" ]; then
                    detached=yes;
                    b="$(
                                case "${GIT_PS1_DESCRIBE_STYLE-}" in
                                (contains)
                                        git describe --contains HEAD ;;
                                (branch)
                                        git describe --contains --all HEAD ;;
                                (tag)
                                        git describe --tags HEAD ;;
                                (describe)
                                        git describe HEAD ;;
                                (* | default)
                                        git describe --tags --exact-match HEAD ;;
                                esac 2>/dev/null)" || b="$short_sha...";
                    b="($b)";
                fi;
            fi;
        fi;
    fi;
    if [ -n "$step" ] && [ -n "$total" ]; then
        r="$r $step/$total";
    fi;
    local w="";
    local i="";
    local s="";
    local u="";
    local c="";
    local p="";
    if [ "true" = "$inside_gitdir" ]; then
        if [ "true" = "$bare_repo" ]; then
            c="BARE:";
        else
            b="GIT_DIR!";
        fi;
    else
        if [ "true" = "$inside_worktree" ]; then
            if [ -n "${GIT_PS1_SHOWDIRTYSTATE-}" ] && [ "$(git config --bool bash.showDirtyState)" != "false" ]; then
                git diff --no-ext-diff --quiet || w="*";
                git diff --no-ext-diff --cached --quiet || i="+";
                if [ -z "$short_sha" ] && [ -z "$i" ]; then
                    i="#";
                fi;
            fi;
            if [ -n "${GIT_PS1_SHOWSTASHSTATE-}" ] && git rev-parse --verify --quiet refs/stash > /dev/null; then
                s="$";
            fi;
            if [ -n "${GIT_PS1_SHOWUNTRACKEDFILES-}" ] && [ "$(git config --bool bash.showUntrackedFiles)" != "false" ] && git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' > /dev/null 2> /dev/null; then
                u="%${ZSH_VERSION+%}";
            fi;
            if [ -n "${GIT_PS1_SHOWUPSTREAM-}" ]; then
                __git_ps1_show_upstream;
            fi;
        fi;
    fi;
    local z="${GIT_PS1_STATESEPARATOR-" "}";
    if [ $pcmode = yes ] && [ -n "${GIT_PS1_SHOWCOLORHINTS-}" ]; then
        __git_ps1_colorize_gitstring;
    fi;
    b=${b##refs/heads/};
    if [ $pcmode = yes ] && [ $ps1_expanded = yes ]; then
        __git_ps1_branch_name=$b;
        b="\${__git_ps1_branch_name}";
    fi;
    local f="$w$i$s$u";
    local gitstring="$c$b${f:+$z$f}$r$p";
    if [ $pcmode = yes ]; then
        if [ "${__git_printf_supports_v-}" != yes ]; then
            gitstring=$(printf -- "$printf_format" "$gitstring");
        else
            printf -v gitstring -- "$printf_format" "$gitstring";
        fi;
        PS1="$ps1pc_start$gitstring$ps1pc_end";
    else
        printf -- "$printf_format" "$gitstring";
    fi;
    return $exit
}


# mingw prompt main entry point
function mingw() {
    local UNAME NL
    UNAME=$(uname)
    NL=$'\n'
    [[ -n $COURSE_NUM ]] && RPROMPT="[%F{cyan}$SUBJECT:u$COURSE_NUM${class+*}%f]"
    PROMPT="$NL%F{green}%n@%m %F{magenta}$UNAME %F{yellow}%~%F{cyan}\$(__git_ps1)%f$NL%(!.#.$%  "
}
###############################################
## /end MinGW prompt
###############################################


# functions to quickly change between my prompts
eval "gitprompt() {
    source '$0' git
    setopt prompt_subst
}"

eval "mingwprompt() {
    source '$0' mingw
    setopt prompt_subst
}"

eval "plainprompt() {
    source '$0' plain
    unsetopt prompt_subst
}"

eval "colorfulprompt() {
    source '$0' colorful
    setopt prompt_subst
}"

eval "screenprompt() {
    source '$0' screen
    unsetopt prompt_subst
}"

eval "phosphorprompt() {
    source $0 phosphor
    unsetopt prompt_subst
}"

if [[ $TERM = 'vt100' ]]; then
    #just playin'
    phosphor
elif [[ $# -gt 0 && $1 != 'ESC-P' ]]; then
    eval "$1"
else
    screen
fi

# if we're rockin' MidnightCommander, drop the precmd() and preexec()
# functionss as they screw the GNU Screen window title up.  Also drop
# the RPROMPT, since it doesn't look right in there.
if [[ -n "$MC_SID" ]]; then
    unfunction precmd preexec
    unset RPROMPT
fi

# Try to keep environment pollution down, EPA loves us.
unfunction plain screen colorful 2>/dev/null
unfunction git 2>/dev/null
unset _UTEXT _UEND






# Excerpt on Prompt expansion from 'man zshmisc', reproduced for convenience
: <<'{'
EXPANSION OF PROMPT SEQUENCES
 Prompt sequences undergo a special form of expansion. This type of
 expansion is also available using the -P option to the print builtin.

 If the PROMPT_SUBST option is set, the prompt string is first subjected
 to parameter expansion, command substitution and arithmetic expansion.
 See zshexpn(1).

 Certain escape sequences may be recognised in the prompt string.

 If the PROMPT_BANG option is set, a `!' in the prompt is replaced by
 the current history event number. A literal `!' may then be repre-
 sented as `!!'.

 If the PROMPT_PERCENT option is set, certain escape sequences that
 start with `%' are expanded. Many escapes are followed by a single
 character, although some of these take an optional integer argument
 that should appear between the `%' and the next character of the
 sequence. More complicated escape sequences are available to provide
 conditional expansion.

SIMPLE PROMPT ESCAPES
   Special characters
       %%     A `%'.

       %)     A `)'.

   Login information
       %l     The line (tty) the user is logged in on, without `/dev/' prefix.
              If the name starts with `/dev/tty', that prefix is stripped.

       %M     The full machine hostname.

       %m     The hostname up to the first `.'.  An integer may follow the `%'
              to specify how many components  of  the  hostname  are  desired.
              With a negative integer, trailing components of the hostname are
              shown.

       %n     $USERNAME.

       %y     The line (tty) the user is logged in on, without `/dev/' prefix.
              This does not treat `/dev/tty' names specially.

   Shell state
       %#     A  `#'  if  the  shell is running with privileges, a `%' if not.
              Equivalent to `%(!.#.%%)'.  The definition of `privileged',  for
              these  purposes,  is  that either the effective user ID is zero,
              or, if POSIX.1e capabilities are supported, that  at  least  one
              capability  is  raised  in  either  the Effective or Inheritable
              capability vectors.

       %?     The return status of the last command executed just  before  the
              prompt.

       %_     The  status  of the parser, i.e. the shell constructs (like `if'
              and `for') that have been started on the command line. If  given
              an  integer  number  that  many strings will be printed; zero or
              negative or no integer means print as many as there  are.   This
              is most useful in prompts PS2 for continuation lines and PS4 for
              debugging with the XTRACE option; in the  latter  case  it  will
              also work non-interactively.

       %d
       %/     Present  working  directory  ($PWD).   If an integer follows the
              `%', it specifies a number of trailing  components  of  $PWD  to
              show;  zero  means the whole path.  A negative integer specifies
              leading components, i.e. %-1d specifies the first component.

       %~     As %d and %/, but if $PWD has a named directory as  its  prefix,
              that  part  is  replaced  by  a  `~' followed by the name of the
              directory.  If it starts with $HOME, that part is replaced by  a
              `~'.

       %h
       %!     Current history event number.

       %i     The  line number currently being executed in the script, sourced
              file, or shell function given by %N.  This is  most  useful  for
              debugging as part of $PS4.

       %I     The  line  number currently being executed in the file %x.  This
              is similar to %i, but the line number is always a line number in
              the file where the code was defined, even if the code is a shell
              function.

       %j     The number of jobs.

       %L     The current value of $SHLVL.

       %N     The name of the script, sourced file, or shell function that zsh
              is currently executing, whichever was started most recently.  If
              there is none, this is equivalent to the parameter $0.  An inte-
              ger may follow the `%' to specify a number of trailing path com-
              ponents to show; zero means the full path.  A  negative  integer
              specifies leading components.

       %x     The  name of the file containing the source code currently being
              executed.  This behaves as %N except that function and eval com-
              mand  names  are  not  shown,  instead  the file where they were
              defined.

       %c
       %.
       %C     Trailing component of $PWD.  An integer may follow  the  `%'  to
              get  more  than  one component.  Unless `%C' is used, tilde con-
              traction is performed first.  These are deprecated as %c and  %C
              are equivalent to %1~ and %1/, respectively, while explicit pos-
              itive integers have the  same  effect  as  for  the  latter  two
              sequences.

   Date and time
       %D     The date in yy-mm-dd format.

       %T     Current time of day, in 24-hour format.

       %t
       %@     Current time of day, in 12-hour, am/pm format.

       %*     Current time of day in 24-hour format, with seconds.

       %w     The date in day-dd format.

       %W     The date in mm/dd/yy format.

       %D{string}
              string  is  formatted  using  the  strftime function.  See strf-
              time(3) for more details.  Various zsh extensions  provide  num-
              bers  with  no  leading  zero or space if the number is a single
              digit:

              %f     a day of the month
              %K     the hour of the day on the 24-hour clock
              %L     the hour of the day on the 12-hour clock

              The GNU extension that a `-' between the % and the format  char-
              acter  causes  a leading zero or space to be stripped is handled
              directly by the shell for the format characters d, f, H,  k,  l,
              m, M, S and y; any other format characters are provided to strf-
              time() with any leading `-', present, so the handling is  system
              dependent.  Further GNU extensions are not supported at present.

   Visual effects
       %B (%b)
              Start (stop) boldface mode.

       %E     Clear to end of line.

       %U (%u)
              Start (stop) underline mode.

       %S (%s)
              Start (stop) standout mode.

       %F (%f)
              Start  (stop)  using a different foreground colour, if supported
              by the terminal.  The colour may be specified two  ways:  either
              as  a  numeric  argument,  as normal, or by a sequence in braces
              following the %F, for example %F{red}.  In the latter  case  the
              values  allowed  are  as  described  for  the  fg  zle_highlight
              attribute; see Character Highlighting in zshzle(1).  This  means
              that numeric colours are allowed in the second format also.

       %K (%k)
              Start (stop) using a different bacKground colour.  The syntax is
              identical to that for %F and %f.

       %{...%}
              Include a string as  a  literal  escape  sequence.   The  string
              within  the braces should not change the cursor position.  Brace
              pairs can nest.

              A positive numeric argument between the % and the {  is  treated
              as described for %G below.

       %G     Within  a  %{...%} sequence, include a `glitch': that is, assume
              that a single character width will be output.   This  is  useful
              when  outputting  characters  that otherwise cannot be correctly
              handled by the shell, such as the  alternate  character  set  on
              some  terminals.   The  characters  in  question can be included
              within a %{...%} sequence together with the  appropriate  number
              of  %G  sequences  to  indicate  the  correct width.  An integer
              between the `%' and `G' indicates a character width  other  than
              one.   Hence  %{seq%2G%} outputs seq and assumes it takes up the
              width of two standard characters.

              Multiple uses of %G accumulate in the obvious fashion; the posi-
              tion  of  the %G is unimportant.  Negative integers are not han-
              dled.

              Note that when prompt truncation is in use it  is  advisable  to
              divide  up  output  into  single  characters within each %{...%}
              group so that the correct truncation point can be found.

CONDITIONAL SUBSTRINGS IN PROMPTS
       %v     The value of the first element of  the  psvar  array  parameter.
              Following  the  `%'  with  an  integer gives that element of the
              array.  Negative integers count from the end of the array.

       %(x.true-text.false-text)
              Specifies a ternary expression.  The character following  the  x
              is  arbitrary;  the  same character is used to separate the text
              for the `true' result from that for the  `false'  result.   This
              separator  may  not appear in the true-text, except as part of a
              %-escape sequence.  A `)' may appear in the false-text as  `%)'.
              true-text  and  false-text  may  both contain arbitrarily-nested
              escape sequences, including further ternary expressions.

              The left parenthesis may be preceded or followed by  a  positive
              integer  n,  which defaults to zero.  A negative integer will be
              multiplied by -1.  The test character x may be any of  the  fol-
              lowing:

              !      True if the shell is running with privileges.
              #      True if the effective uid of the current process is n.
              ?      True if the exit status of the last command was n.
              _      True if at least n shell constructs were started.
              C
              /      True if the current absolute path has at least n elements
                     relative to the root directory, hence / is counted  as  0
                     elements.
              c
              .
              ~      True if the current path, with prefix replacement, has at
                     least n elements relative to the root directory, hence  /
                     is counted as 0 elements.
              D      True if the month is equal to n (January = 0).
              d      True if the day of the month is equal to n.
              g      True if the effective gid of the current process is n.
              j      True if the number of jobs is at least n.
              L      True if the SHLVL parameter is at least n.
              l      True  if  at least n characters have already been printed
                     on the current line.
              S      True if the SECONDS parameter is at least n.
              T      True if the time in hours is equal to n.
              t      True if the time in minutes is equal to n.
              v      True if the array psvar has at least n elements.
              V      True  if  element  n  of  the  array  psvar  is  set  and
                     non-empty.
              w      True if the day of the week is equal to n (Sunday = 0).

       %<string<
       %>string>
       %[xstring]
              Specifies  truncation  behaviour for the remainder of the prompt
              string.   The  third,  deprecated,   form   is   equivalent   to
              `%xstringx',  i.e.  x  may be `<' or `>'.  The numeric argument,
              which in the third form may appear immediately  after  the  `[',
              specifies  the  maximum  permitted length of the various strings
              that can be displayed in the prompt.  The string  will  be  dis-
              played  in  place  of  the truncated portion of any string; note
              this does not undergo prompt expansion.

              The forms with `<' truncate at the left of the string,  and  the
              forms  with  `>' truncate at the right of the string.  For exam-
              ple, if  the  current  directory  is  `/home/pike',  the  prompt
              `%8<..<%/'  will expand to `..e/pike'.  In this string, the ter-
              minating character (`<', `>' or `]'), or in fact any  character,
              may be quoted by a preceding `\'; note when using print -P, how-
              ever, that this must be doubled as the string is also subject to
              standard  print  processing,  in  addition  to  any  backslashes
              removed by a double quoted string:  the worst case is  therefore
              `print -P "%<\\\\<<..."'.

              If the string is longer than the specified truncation length, it
              will appear in full, completely replacing the truncated string.

              The part of the prompt string to be truncated runs to the end of
              the  string,  or  to  the end of the next enclosing group of the
              `%(' construct, or to the next  truncation  encountered  at  the
              same  grouping  level  (i.e. truncations inside a `%(' are sepa-
              rate), which ever comes first.  In particular, a truncation with
              argument  zero  (e.g.  `%<<')  marks the end of the range of the
              string to be truncated while turning off truncation  from  there
              on.  For  example,  the  prompt  '%10<...<%~%<<%# ' will print a
              truncated representation of the current directory, followed by a
              `%'  or  `#', followed by a space.  Without the `%<<', those two
              characters would be included in the string to be truncated.

}


# vim:set textwidth=70 foldmarker={,} foldenable foldmethod=marker filetype=zsh tabstop=4 expandtab:
