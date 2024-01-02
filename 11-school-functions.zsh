# vim: set ft=zsh expandtab:
SEMESTYR=Sp24
BASE=/home/fadein/school

refresh() {
    for REPO in $BASE/$SEMESTYR/*/.git; do
        (
            # Show a command and then run it
            # When the environment variable DRYRUN is non-empty, do not
            # actually make any changes, but only show what would be done
            echodo() {
                print -P "\n%B%~ %% %b%F{green}$@%f"
                if [[ -z $DRYRUN ]]; then
                    $@
                else
                    true
                fi
            }

            SHUSH=1 cd $REPO/..
            # This Zsh construct returns 'false' when this repo has uncommitted changes
            # The following print command prints the repo's name red in that case
            [[ -z $(git status --porcelain) ]]
            print -P "%f${REPO//[[:print:]]/=}\n%(?.%F{green}.%F{red})$REPO%f%b\n${REPO//[[:print:]]/=}"

            if [[ -a Notes/.git ]]; then
                (
                    echodo cd Notes
                    echodo git checkout master

                    if ! echodo git pull publish master; then
                        print -P "\n%F{yellow}%BPulling%b%f Notes/ from %F{green}%Bpublish%b%f failed; You must manually address this\n"
                        return 1
                    fi

                    if ! echodo git pull origin master; then
                        print -P "\n%F{yellow}%BPulling%b%f Notes/ from %F%B{cyan}origin%b%f failed; You must manually address this\n"
                        return 1
                    fi

                    if ! echodo git push publish master; then
                        print "\n%F{red}%BPushing%b%f Notes/ to %F{green}%Bpublish%b%f failed; You must manually address this\n"
                        return 1
                    fi

                    if ! echodo git push origin master; then
                        print "\n%F{red}%BPushing%b%f Notes/ to %F{cyan}%Borigin%b%f failed; You must manually address this\n"
                        return 1
                    fi
                )
            fi

            # put myself back on the master branch so the pull will cleanly
            # apply if/when I'm working on a topic branch
            echodo git checkout master
            echodo git pull --recurse-submodules=on-demand origin master
            echodo git push origin master
            print
        )
    done
    ding true
}


clown () {
    zmodload zsh/regex
    if [[ -z $1 ]]; then
        print 1>&2 "Usage: $0 <HTTPS git url> [DEST_NAME]"
        return 1
    fi

    local URL
    # convert https:// git repo URLs into SSH URLs
    if [[ $1 -regex-match ^(git@[^:]+:[^/]+/[^/]+) ]]; then
        # SSH-style URL
        URL=$MATCH
    elif [[ $1 -regex-match ^http ]]; then
        # https-style URL
        URL=${1/http*:\/\//}
        URL=${URL#*@}
        URL=${URL/\//:}
        if [[ $URL -regex-match ^([^:]+:[^/]+/[^/]+) ]]; then
            URL=git@$MATCH
        else
            URL=git@$URL
        fi
    elif [[ $1 -regex-match [^/]+/[^/]+ ]]; then
        # URL is a path like username/cs1440-last-first-assn#
        # Prepend the GitLab SSH URL
        URL=git@gitlab.cs.usu.edu:$1
    else
        print 1>&2 Invalid URL
        return 1
    fi

    # If $2 is unset and the URL looks like an assignment
    # (i.e. matches .*/cs[0-9]{4}-last-first-assn[0-9](.git)?)
    # set $DEST to "last-first-a[0-9]"
    local DEST
    if [[ -n $2 ]]; then
        DEST=$2
        print "Cloning $URL into $DEST..."
    elif [[ $URL -regex-match git@gitlab.cs.usu.edu:[^/]+/cs[0-9]{4}-(.*)-assn([0-9])(.git)?$ ]]; then
        DEST="${match[1]}-a${match[2]}"
        print "Cloning $URL into $DEST..."
    else
        print "Cloning $URL..."
    fi

    git clone $URL $DEST
}


# This version of `find-student` searches all courses' rosters in the current semester
find-student() {
    if [[ -z $1 ]]; then
        print "Locate a student in a course"
        print "Usage: $0 Student Name"
        return 1
    fi
    grep -i "$*" $BASE/$SEMESTYR/*/Roster/{roster,email}*.csv | sort
}

# This version of `find-student` searches all courses' rosters across all semesters
find-student+() {
    setopt LOCAL_OPTIONS NULL_GLOB
    local BASE=/home/fadein/school

    if [[ -z $1 ]]; then
        print "Locate a student in a course"
        print "Usage: $0 Student Name"
        return 1
    fi
    grep -i "$*" $BASE/{Fa,Sp,Su}??/cs*/Roster/{roster,email}*.csv | sort
}

# Open a repo's HTTPS GitLab page from its "origin" (or $1) remote
gitlab() {
	local URL
	if git status > /dev/null 2>&1
	then
		URL=$(git remote get-url ${1:-origin})
		if [[ $URL == git@* ]]
		then
			URL=${URL/:/\/}
			URL=${URL/git@/https:\/\/}
		elif [[ $URL = https://* ]]
		then
			:
		else
			echo "Unrecognized URL '$URL'" >&2
			return 2
		fi
		if [[ -z $BROWSER ]]
		then
			echo Browse to $URL
		else
			$BROWSER $URL
		fi
	else
		echo This is not a Git repository >&2
		return 1
	fi
}
