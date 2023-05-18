#!/bin/zsh

 PURPOSE="GitLab server update task"
 VERSION="1.8.1"
    DATE="Fri 05 May 2023 10:23:26 AM MDT"
  AUTHOR="Erik Falor"
PROGNAME=$0
TASKNAME=$0:t:r

setup() {
    [[ -z $STY && -z $TMUX ]] && die "Not using a terminal muxer?  That's just too risky for me."
    raisePrivs || true
}

env() {
    _KEEP_FUNCTIONS=(prettySeconds echodo)

    local HOURS=4
    if [[ $(stat --format=%Y /var/log/apt/history.log) -le $(( $(=date +%s) - $HOURS * 3600 )) ]]; then
        apt update
    else
        printf "'apt update' has been run within the past $HOURS hours, skipping...\n\n"
    fi

    _TODO=(
        '$ apt list --upgradable'
        '$ gitlab-ctl status'
        '$ apt upgrade -y'
        '$ gitlab-ctl status'
        "Make sure the post-receive.pl hook still works by pushing a commit"
        "Retire the webpage broadcast message"
        '$ check-logfile-permissions'
        '$ if [[ -f /var/run/reboot-required ]]; then print Reboot is required; else print Reboot is NOT required; fi'
    )

    typeset -gA _HELP
    _HELP[help]="This function"

    _HELP[check-logfile-permissions]="Verify permissions of important log files"
    check-logfile-permissions() {
        EXPECTED="git:git 644"
        for F in /var/log/gitlab/{huge_repos,errors,pushes}.log; do
            STAT="$(stat -c '%U:%G %a' $F)"
            if [[ $? == 0 && $STAT != $EXPECTED ]]; then
                1>&2 print "Ownership/perms were '$STAT'\n instead of expected '$EXPECTED'\n for file $F\n"
            fi
        done
    }

    BACKUPSDIR=/var/opt/gitlab/backups
	BACKUPSDEST=viking-dyn:/mnt/rasp/fadein/backups/GitLab
    _HELP[backup-gitlab]="Back up GitLab's PostgreSQL database to $BACKUPSDIR"
    backup-gitlab() {
        ding gitlab-backup create
        printf "\nBackup created in $BACKUPSDIR\nNow run 'xfer BACKUP_NAME_STEM to send it to $BACKUPSDEST\n"
    }

	_HELP[xfer]="Transfer the backup to viking-dyn"
	xfer() {
		if [[ -z $1 ]]; then
			1>&2 print "Usage: xfer BACKUPFILENAME"
			1>&2 print "  Just the stem of the filename, no dirs and without _gitlab_backup.tar"
			return 1
		elif [[ ! -f $BACKUPSDIR/${1}_gitlab_backup.tar ]]; then
			1>&2 print "Error: the file '${1}_gitlab_backup.tar' does not exist in $BACKUPSDIR"
			return 2
		fi

		echodo rsync -av /etc/gitlab/config_backup $BACKUPSDEST
		RSYNC_R=$?

		echodo scp $BACKUPSDIR/${1}_gitlab_backup.tar $BACKUPSDEST
		SCP_R=$?

		if [[ $SCP_R == $RSYNC_R && $RSYNC_R == 0 ]]; then
			echo -e "\a"
		else
			for ding in {0..2}; do
				echo -ne "\a"
				sleep 1
			done
		fi
	}

    # Miscellaneous hints and commands
    _HELP["ls /var/log/apt/"]="APT log files; history GitLab upgrades"
    _HELP["/opt/gitlab/embedded/service/gitlab-shell/hooks"]="Location of server hook scripts"
    _HELP['curl -s "https://packages.gitlab.com/gpg.key" | apt-key add -']="Update GitLab's package GPG signing key"
    _HELP["/var/opt/gitlab/gitlab-rails/uploads"]="Location where GitLab stores uploaded files/artifacts"

    print "Run 'help' to learn about other tools you can run in this task"
}


# Report on time spent on this task
cleanup() {
    echo This upgrade took $( prettySeconds ) to complete
}


source $0:h/__TASKS.zsh
