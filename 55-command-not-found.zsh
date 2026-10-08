# ykutwidntimwytim.zsh: suggest typo aliases when a command is not found.
#
# The name is short for "You Keep Using That Word, I Do Not Think It Means What You Think It Means"
#
# Source this from .zshrc, along with the alias file it helps you build:
#
#   source /path/to/ykutwidntimwytim.zsh
#   [[ -r ${YKUTWIDNTIMWYTIM_ALIASES:-~/.zsh_typo_aliases} ]] && source ${YKUTWIDNTIMWYTIM_ALIASES:-~/.zsh_typo_aliases}
#
# Candidate lookup uses a SymSpell-style delete index: two words are within
# edit distance 2 only if they share a string after deleting <= 2 characters
# from each. The index is cached on disk and built on the first miss, so there
# is no shell startup cost and no scan of every command per typo.

# where to store aliases
if [[ -z $YKUTWIDNTIMWYTIM_ALIASES ]]; then
    YKUTWIDNTIMWYTIM_ALIASES=~/.zsh_typo_aliases
fi

# consider typos within this levenshtein distance of real command names
if [[ -z $YKUTWIDNTIMWYTIM_MAX_DIST ]]; then
    YKUTWIDNTIMWYTIM_MAX_DIST=2
fi

# offer an alias after this many occurrences of the same typo
if [[ -z $YKUTWIDNTIMWYTIM_THRESHOLD ]]; then
    YKUTWIDNTIMWYTIM_THRESHOLD=3
fi

# Print word and every variant of it with up to 2 characters deleted, one per line.
_ykutwidntimwytim_deletes() {
    local w=$1 v d
    local -i i
    local -A seen
    local -a level next
    seen[$w]=1
    level=($w)
    repeat 2; do
        next=()
        for v in $level; do
            for (( i=1; i<=${#v}; i++ )); do
                d=${v[1,i-1]}${v[i+1,-1]}
                if [[ -n $d && -z ${seen[$d]} ]]; then
                    seen[$d]=1
                    next+=($d)
                fi
            done
        done
        level=($next)
    done
    print -rl -- ${(k)seen}
}

# Damerau-Levenshtein distance (optimal string alignment) of $1 and $2.
_ykutwidntimwytim_distance() {
    local a=$1 b=$2
    local -i m=${#1} n=${#2} i j cost best
    local -i w=$(( n + 1 ))
    local -a d
    for (( i=0; i<=m; i++ )); do d[i*w+1]=$i; done
    for (( j=0; j<=n; j++ )); do d[j+1]=$j; done
    for (( i=1; i<=m; i++ )); do
        for (( j=1; j<=n; j++ )); do
            [[ ${a[i]} == "${b[j]}" ]] && cost=0 || cost=1
            (( best = d[(i-1)*w+j+1] + 1 ))                      # deletion
            (( d[i*w+j] + 1 < best )) && (( best = d[i*w+j] + 1 )) # insertion
            (( d[(i-1)*w+j] + cost < best )) && (( best = d[(i-1)*w+j] + cost ))
            if (( i > 1 && j > 1 )) && [[ ${a[i]} == "${b[j-1]}" && ${a[i-1]} == "${b[j]}" ]]; then
                (( d[(i-2)*w+j-1] + 1 < best )) && (( best = d[(i-2)*w+j-1] + 1 ))
            fi
            d[i*w+j+1]=$best
        done
    done
    print -r -- ${d[m*w+n+1]}
}

# True if $1 is one of the remaining arguments. Avoids associative-array subscripts,
# which break on names like "[".
_ykutwidntimwytim_in() {
    local n=$1
    shift
    [[ -n ${(M)@:#${(b)n}} ]]
}

# Rebuild the delete index if the set of commands has changed. Echoes its path.
_ykutwidntimwytim_index() {
    local dir=${XDG_CACHE_HOME:-~/.cache}/ykutwidntimwytim
    local file=$dir/deletes
    local key="$PATH|${#commands}|${#builtins}"
    if [[ ! -r $file || $(head -n1 $file) != "# $key" ]]; then
        mkdir -p $dir || return 1
        print -u2 -r -- "ykutwidntimwytim: building the command index (one-time, may take a few seconds)..."
        local w v
        {
            print -r -- "# $key"
            for w in ${(k)commands} ${(k)builtins} ${(k)reswords}; do
                for v in ${(f)"$(_ykutwidntimwytim_deletes $w)"}; do
                    print -r -- "$v	$w"
                done
            done
        } >| $file.$$ && command mv $file.$$ $file
    fi
    print -r -- $file
}

# Print "distance<TAB>rank<TAB>length<TAB>name" lines for plausible intended commands.
_ykutwidntimwytim_candidates() {
    local typo=$1 file name dist rank
    local -a names
    file=$(_ykutwidntimwytim_index) || return 1
    names=(${(f)"$(awk -F'\t' -v list="${(j:\n:)${(f)"$(_ykutwidntimwytim_deletes $typo)"}}" '
        BEGIN { n = split(list, a, "\n"); for (i = 1; i <= n; i++) want[a[i]] = 1 }
        $1 in want { print $2 }' $file | sort -u)"})
    # Aliases and functions change often, so check them directly (cheap length filter first).
    for name in ${(k)aliases} ${(k)functions}; do
        [[ $name == _* ]] && continue
        (( ${#name} - ${#typo} <= YKUTWIDNTIMWYTIM_MAX_DIST && ${#typo} - ${#name} <= YKUTWIDNTIMWYTIM_MAX_DIST )) && names+=($name)
    done
    for name in ${(u)names}; do
        [[ $name == $typo ]] && continue
        dist=$(_ykutwidntimwytim_distance $typo $name)
        (( dist > YKUTWIDNTIMWYTIM_MAX_DIST )) && continue
        if _ykutwidntimwytim_in $name ${(k)aliases} ${(k)functions}; then rank=0
        elif _ykutwidntimwytim_in $name ${(k)builtins} ${(k)reswords}; then rank=1
        else rank=2; fi
        print -r -- "$dist	$rank	${#name}	$name"
    done
}

# Record one more occurrence of $1 and print its new total. The handler runs in a
# subshell, so counts live in a file (tab-separated "count<TAB>typo" lines).
_ykutwidntimwytim_count() {
    local typo=$1 dir=${XDG_STATE_HOME:-~/.local/state}/ykutwidntimwytim
    local file=$dir/counts line
    local -i n=0
    mkdir -p $dir || { print 1; return; }
    [[ -r $file ]] && for line in ${(f)"$(<$file)"}; do
        [[ ${line#*	} == $typo ]] && n=${line%%	*}
    done
    (( n++ ))
    {
        [[ -r $file ]] && command grep -vxF -- "$(print -r -- "$((n-1))	$typo")" $file
        print -r -- "$n	$typo"
    } >| $file.$$ && command mv $file.$$ $file
    print -r -- $n
}

# Typos the user asked never to be prompted about, one per line in the state dir.
_ykutwidntimwytim_ignore_file() {
    print -r -- ${XDG_STATE_HOME:-~/.local/state}/ykutwidntimwytim/ignored
}

_ykutwidntimwytim_is_ignored() {
    local file=$(_ykutwidntimwytim_ignore_file)
    [[ -r $file ]] && grep -qxF -- "$1" $file
}

_ykutwidntimwytim_ignore() {
    local file=$(_ykutwidntimwytim_ignore_file)
    mkdir -p ${file:h} && print -r -- "$1" >> $file
}

# Re-source the alias file so newly saved aliases take effect in this shell.
reload-aliases() {
    if [[ -r $YKUTWIDNTIMWYTIM_ALIASES ]]; then
        source $YKUTWIDNTIMWYTIM_ALIASES && print -u2 -r -- "ykutwidntimwytim: reloaded $YKUTWIDNTIMWYTIM_ALIASES"
    else
        print -u2 -r -- "ykutwidntimwytim: no alias file at $YKUTWIDNTIMWYTIM_ALIASES"
        return 1
    fi
}

# Main entry point - this function is invoked automatically by Zsh when the user submits a non-existant command
command_not_found_handler() {
    local typo=$1
    print -u2 -r -- "ykutwidntimwytim: command not found: $typo"

    # Nothing sensible to suggest for very short words or paths, or for ignored typos.
    if (( ${#typo} >= 2 )) && [[ $typo != */* ]] && ! _ykutwidntimwytim_is_ignored $typo \
            && (( $(_ykutwidntimwytim_count $typo) >= YKUTWIDNTIMWYTIM_THRESHOLD )); then
        local -a ranked
        ranked=(${(f)"$(_ykutwidntimwytim_candidates $typo | sort -t$'\t' -k1,1n -k2,2n -k3,3n -k4,4)"})
        if (( ${#ranked} )); then
            local best=${${(ps:\t:)ranked[1]}[4]}
            local line="alias ${(q)typo}=${(q)best}"
            print -u2 -r -- "Did you mean '$best'?"
            if (( ${#ranked} > 1 )); then
                local -a others
                local r
                for r in ${ranked[2,4]}; do others+=(${${(ps:\t:)r}[4]}); done
                print -u2 -r -- "Other candidates: ${(j:, :)others}"
            fi
            # Ask on the terminal; with no terminal, just show the line.
            local reply
            print -u2 -rn -- "Append '$line' to $YKUTWIDNTIMWYTIM_ALIASES? [yes/No/ignore] "
            if read -r reply </dev/tty 2>/dev/null; then
                case ${(L)reply} in
                    y|yes)
                        print -r -- $line >> $YKUTWIDNTIMWYTIM_ALIASES \
                            && print -u2 -r -- "Saved. Run reload-aliases to use it in this shell."
                        ;;
                    i|ignore)
                        _ykutwidntimwytim_ignore $typo
                        print -u2 -r -- "Ignoring '$typo' from now on."
                        ;;
                esac
            else
                print -u2
                print -u2 -r -- "  $line"
            fi
        fi
    fi
    return 127
}
