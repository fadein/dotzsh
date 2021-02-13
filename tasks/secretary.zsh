#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.1"
   DATE="Fri Feb 12 23:06:11 MST 2021"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r
BROWSER=firefox
CHURCH=~/Documents/Church

_bishopric_email() {
	cat <<-EM > $CHURCH/bishopric_email
	To:  Falor, Erik; Hunsaker, Jacob; King, Jeff; Nichols, Greg; Parker, Lance 
	Bishopric Meeting Tomorrow @ 7:30am

	Handbook Training: Bro. ~~~~~~~

	See you tomorrow morning!
	EM
}

setup() {
	$BROWSER \
		https://docs.google.com/document/d/1_IaASzBuJGxxLkk58LpNGUdSdCyYXuS0p5gEADiwNVw/edit \
		https://docs.google.com/spreadsheets/d/1SRNa8kKWCzNE_VRsf-m5KQm-ky9y3dMYtpsamF1mMOM/edit \
		"https://lcr.churchofjesuschrist.org/messaging?lang=eng" \
		https://drive.google.com/drive/folders/1gGZF3WEEe2mB_DIAZdbdA9SbWXKyWeo7 \
		https://calendar.google.com/calendar/u/0/r/week \
		"https://lcr.churchofjesuschrist.org/?lang=eng"


	[[ ! -d $CHURCH ]] && mkdir -p $CHURCH
	[[ ! -f $CHURCH/bishopric_email ]] && _bishopric_email
	cd $CHURCH
}


env() {
    _TODO=(
        "check what weekly meetings happen this Sunday"
        "who has handbook training in bishopric meeting?"
        "make a new bishopric agenda"
        "email the bishopric, alert whoever has the training"
        "who has spiritual thought in the 2nd meeting?"
        "make a new 2nd meeting agenda with Zoom link"
        "email 2nd meeting attendees"
        "check sacrament hymns"
        "copy sacrament agenda from last time"
		"get conductor & speaker from Bishopric agenda"
    )
}


cleanup() {
	print You worked on that for $( prettySeconds $SECONDS )
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
