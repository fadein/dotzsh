# prompts.zsh

#Choose color for host and username #{
case $OSTYPE in
    hpux*)
        function hostcolor {echo "%F{magenta}$1%f"} ;;
    aix*)
        function hostcolor {echo "%F{cyan}$1%f"} ;;
    solaris*)
        function hostcolor {echo "%F{yellow}$1%f"} ;;
    linux*)
        case $HOST in
            gemini)
                function hostcolor {echo "%B%F{cyan}$1%f%b"} ;;
            voyager)
                function hostcolor {echo "%B%F{white}$1%f%b"} ;;
            explorer)
                function hostcolor {echo "%B%F{blue}$1%f%b"} ;;
            viking)
                function hostcolor {echo "%B%F{magenta}$1%f%b"} ;;
            *)
                function hostcolor {echo "%B%F{black}$1%f%b"} ;;
        esac ;;
    cygwin*)
        function hostcolor {echo "%B%F{blue}$1%f%b"} ;;
    *)
        function hostcolor {echo "%B%F{red}$1%f%b"} ;;
esac

case $UID in
    "0")
        _UTEXT="%B%F{red}"
        _UEND='%f%b'
        function usercolor {echo "%B%F{red}$1%f%b"} ;;
    *)
        _UTEXT="%B%F{green}"
        _UEND='%f%b'
        function usercolor {echo "%B%F{green}$1%f%b"} ;;
esac
#}

# Render the window title for virtual terminals
function title {
    local ROOT=
    if [[ "$UID" = 0 ]]; then
        ROOT="* "
    fi
    case $TERM in
        screen)
            # Use these two for GNU Screen:
            print -nP $'\ek'${ROOT}$2$'\e'\\
            print -nP $'\e]0;'${ROOT}$*$'\a'
            ;;
        *xterm*|rxvt*)
            # Use this one instead for XTerms:
            print -nP $'\e]0;'${ROOT}$*$'\a'
            ;;
        screen.rxvt)
            print -nR $'\ek'${ROOT}$2$'\e'\\
            print -nP $'\e]0;'${ROOT}$*$'\a'
            ;;
    esac
}

# Window title: "[host] zsh tty cwd"
function precmd {
    title '[%M] ' 'zsh' '%l %~'
}

# Get hub's version number if we're shelled out of Spillman
function hubver() {
	if [[ -n "$FORCEDIR" ]]; then
		print "$(hostcolor ${${(z)$(hub -v 2>&1)}[2]}) "
	fi
}

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
            fi ;;

        %*) cmd=(builtin jobs -l ${(Q)cmd[1]}) ;; # Same as "else" above

        exec) shift cmd;& # If the command is 'exec', drop that, because
                          # we'd rather just see the command that is being
                          # exec'd. Note the ;& to fall through.
                          #
        *)  title '[%m] ' $cmd[1]:t $cmd[2,-1]    # Not resuming a job,
            return ;;                        # so we're all done
    esac

    local -A jt; jt=(${(kv)jobtexts})       # Copy jobtexts for subshell

    # Run the command, read its output, and look up the jobtext.
    # Could parse $rest here, but $jobtexts (via $jt) is easier.
    $cmd >>(read num rest
        cmd=(${(z)${(e):-\$jt$num}})
        title '[%m] ' $cmd[1]:t $cmd[2,-1]) 2>/dev/null
}

function plain() {
    PS1='%n@%M %~ %# '
}

#The jobcount is colored red if non-zero.
function colorful() {
    PROMPT="[%(?..%F{red}%?%f )$(usercolor %n)@$(hostcolor %M) %~]%# $_UTEXT"
    RPROMPT="${_UEND}[$(hubver)%B%F{yellow}${TASK:+$TASK }%f%b%F{cyan}%f%F{yellow}!%!%f %F{cyan}%y%f%1(j. %F{red}%%%j%f.)]"
}

#If this shell is spawned within GNU Screen, prepend "$WINDOW." to
#the jobcount.  The jobcount is colored red if non-zero.
function screen() {
    PROMPT="[%(?..%F{red}%?%f )$(usercolor %n)@$(hostcolor %M) %~]%# $_UTEXT"
    RPROMPT="${_UEND}[$(hubver)%B%F{yellow}${TASK:+$TASK }%f%b%F{cyan}${WINDOW:+$WINDOW }%f%F{yellow}!%!%f %F{cyan}%y%f%1(j. %F{red}%%%j%f.)]"
}

function phosphor() {
    unset RPROMPT
    PROMPT='[%n@%M %~]%# '
}

function _git_branch_details() {
    _GITS=
    local branch=
    local IFS=$'\x0A'$'\x0D'
    local staged=
    local dirty=
    local state=
    local unmerged=
    local untracked=

    local rx_branch="^# On branch (.+)"
    local rx_changed="^#[[:space:]]+(new file|both modified|modified|deleted|renamed)"
    local rx_inIndex="^# Changes to be committed:"
    local rx_inWork="^# Changed but not updated:|^# Changes not staged for commit:" #prior to v1.7.4
    local rx_fatal="^fatal:"
    local rx_unmerged="^# Unmerged paths:"
    local rx_untracked="^# Untracked files:"
    local rx_filename="^#[[:blank:]][[:alnum:]_#.]+"

    local LINE=
    for LINE in $( git status 2>&1 )
    do
        if [[ ${LINE} =~ ${rx_branch} ]]; then
            branch=$match[1]
        elif [[ ${LINE} =~ ${rx_inIndex} ]]; then
            state=index
        elif [[ ${LINE} =~ ${rx_inWork} ]]; then
            state=work
        elif [[ ${LINE} =~ ${rx_untracked} ]]; then
            state=untracked
        elif [[ ${LINE} =~ ${rx_unmerged} ]]; then
            state=unmerge
        elif [[ ${LINE} =~ ${rx_changed} ]]; then
            case $state in
                index)
                    let staged++;;
                work)
                    let dirty++;;
                unmerge)
                    let unmerged++;;
            esac
        elif [[ $state == 'untracked' ]]; then
            if [[ ${LINE} =~ ${rx_filename} ]]; then
                let untracked++
            fi
        elif [[ ${LINE} =~ ${rx_fatal} ]]; then
            return
        fi
    done

    # get SHA1 of current commit when in detached HEAD state
    # indicate detached head by prepending with *
    if [[ -z "${branch}" ]]; then
        branch="*"$(git rev-parse --short HEAD 2>/dev/null)
    fi

    # show number of non-indexed changes in red
    # and number of indexed changes in green
    if [[ -n "${staged}${dirty}${unmerged}${untracked}" ]]; then
        echo " %F{green}${staged}%F{red}${dirty}%U${unmerged}%u%F{yellow}${untracked}%F{red} ${branch}%f"
    else
        echo " %F{green}${branch}%f"
    fi
}

# git prompt main entry point
function git() {
    #TODO: see if I can re-write this to not rely on the embedded $()
    #and thereby not need to `setopt prompt_subst`
    #maybe add _git_branch_details as a precmd, and delete it when
    #switching to another prompt?
    PROMPT="[%(?..%F{red}%?%f )$(hostcolor %4~)\$(_git_branch_details)]$(usercolor '%#') ${_UTEXT}"
    #If this shell is spawned within GNU Screen, prepend "$WINDOW." to
    #the jobcount.  The jobcount is colored red if non-zero.
    RPROMPT="${_UEND}[$(hubver)%B%F{yellow}${TASK:+$TASK }%f%b%F{cyan}${WINDOW:+$WINDOW }%f%F{yellow}!%!%f %F{cyan}%y%f%1(j. %F{red}%%%j%f.)]"
}


# functions to quickly change between my prompts
eval "gitprompt() {
    source $0 git
    setopt prompt_subst
}"

eval "plainprompt() {
    source $0 plain
    unsetopt prompt_subst
}"

eval "colorfulprompt() {
    source $0 colorful
    setopt prompt_subst
}"

eval "screenprompt() {
    source $0 screen
    unsetopt prompt_subst
}"

eval "phosphorprompt() {
    source $0 phosphor
    unsetopt prompt_subst
}"

if [[ $TERM = 'vt100' ]]; then
    #just playin'
    phosphor
elif [[ $# -gt 0 ]]; then
    eval "$1"
else
    plain
fi

# Try to keep environment pollution down, EPA loves us.
unfunction plain screen colorful 2>/dev/null
unfunction git 2>/dev/null
unset _UTEXT _UEND

# excerpt from man zshmisc
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
