# vim: set ft=zsh expandtab:
SEMESTYR=Fa22
BASE=/home/fadein/school

refresh() {
    for REPO in $BASE/$SEMESTYR/*/.git; do
        (
            SHUSH=1 cd $REPO/..
            # This Zsh construct returns 'false' when this repo has uncommitted changes
            # The following print command prints the repo's name red in that case
            [[ -z $(git status --porcelain) ]]
            print -P "%f${REPO//[[:print:]]/=}\n%(?.%F{green}.%F{red})$REPO%f%b\n${REPO//[[:print:]]/=}"

            # put myself back on the master branch so the pull will cleanly
            # apply if/when I'm working on a topic branch
            git checkout master
            git pull --recurse-submodules=on-demand
            (
                cd Notes
                git checkout master
                if ! git pull publish master && git pull origin master; then
                    print
                    print "Pulling Notes/ failed; You must manually address this"
                    print
                    return 1
                fi
                if ! git push origin master && git push publish master; then
                    print
                    print "Pushing Notes/ failed; You must manually address this"
                    print
                    return 1
                fi
            )
            git push
            print
        )
    done
    ding
}


clown () {
    zmodload zsh/regex
    if [[ -z $1 ]]; then
        print "Usage: $0 <HTTPS git url> [DEST_NAME]"
        return 1
    fi

    local URL
    # convert https:// git repo URLs into SSH URLs
    if [[ $1 -regex-match ^(git@[^:]+:[^/]+/[^/]+) ]]; then
        # SSH-style URL
        URL=$MATCH
    else
        # https-style URL
        URL=${1/http*:\/\//}
        URL=${URL#*@}
        URL=${URL/\//:}
        if [[ $URL -regex-match ^([^:]+:[^/]+/[^/]+) ]]; then
            URL=git@$MATCH
        else
            URL=git@$URL
        fi
    fi

    # If $2 is unset and the URL looks like an assignment
    # (i.e. matches .*/cs[0-9]{4}-last-first-assn[0-9](.git)?)
    # set $DEST to "last-first-a[0-9]"
    local DEST
    if [[ -n $2 ]]; then
        DEST=$2
    elif [[ $URL -regex-match git@gitlab.cs.usu.edu:[^/]+/cs[0-9]{4}-(.*)-assn([0-9])(.git)?$ ]]; then
        DEST="${match[1]}-a${match[2]}"
    fi

    print "Cloning $URL..."
    git clone $URL $DEST
}


# This version of `find-student` searches all courses' rosters in the current semester
find-student() {
    if [[ -z $1 ]]; then
        print "Locate a student in a course"
        print "Usage: $0 'Student Name'"
        return 1
    fi
    grep -i $1 $BASE/$SEMESTYR/*/Roster/{roster,email}*.csv | sort
}

# This version of `find-student` searches all courses' rosters across all semesters
find-student+() {
    setopt LOCAL_OPTIONS NULL_GLOB
    local BASE=/home/fadein/school

    if [[ -z $1 ]]; then
        print "Locate a student in a course"
        print "Usage: $0 'Student Name'"
        return 1
    fi
    grep -i $1 $BASE/{Fa,Sp,Su}??/cs*/Roster/{roster,email}*.csv | sort
}
