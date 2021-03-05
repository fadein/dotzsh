#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.3"
   DATE="Thu Mar  4 21:37:40 MST 2021"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r
BROWSER=firefox
CHURCH=~/Documents/Church

BISHOPRIC=(
	"King, Jeff"
	"Nichols, Greg"
	"Hunsaker, Jacob"
	"Falor, Erik"
	"Parker, Lance" 
	)

WARD_COUNCIL=(
	$BISHOPRIC
	"Thomsen, George"
	"Eliason, Shannon"
	"Fritzler, James"
	"Conde, Eva"
	"Edvalson, Amy"
	"Clark, Derald"
	)


_bishopric_email() {
	cat <<-EM > $CHURCH/bishopric_email
	To: $BISHOPRIC
	Bishopric Meeting Sunday @ 7:30am

	Handbook Training: Bro. ~~~~~~~

	  See you Sunday morning!
	-- Erik
	EM
}

_ward_council_email() {
	cat <<-EM > $CHURCH/ward_council_email
	To:  $WARD_COUNCIL
	Ward Council Meeting Sunday @ 8:45am

	https://zoom.us/j/95220863203?pwd=SkpQVW9UckxuMk9wYnRNd3g4V1Nadz09

	Spiritual Thought & Song: ~~~~~~~

	  See you Sunday morning!
	-- Erik
	EM
}

setup() {
	$BROWSER \
		https://docs.google.com/document/d/1_IaASzBuJGxxLkk58LpNGUdSdCyYXuS0p5gEADiwNVw/edit \
		https://docs.google.com/spreadsheets/d/1SRNa8kKWCzNE_VRsf-m5KQm-ky9y3dMYtpsamF1mMOM/edit \
		"https://lcr.churchofjesuschrist.org/messaging?lang=eng" \
		https://drive.google.com/drive/folders/1gGZF3WEEe2mB_DIAZdbdA9SbWXKyWeo7 \
		https://calendar.google.com/calendar/u/0/r/week


	[[ ! -d $CHURCH ]] && mkdir -p $CHURCH
	[[ ! -f $CHURCH/bishopric_email ]] && _bishopric_email
	[[ ! -f $CHURCH/ward_council_email ]] && _ward_council_email
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
		"get prayers from Lance"
    )
}


cleanup() {
	print You worked on that for $( prettySeconds $SECONDS )
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
