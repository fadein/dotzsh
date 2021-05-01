#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.6"
   DATE="Sun Apr 25 09:52:16 MDT 2021"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r
BROWSER=firefox
CHURCH=~/Documents/Church

BISHOPRIC=(
	"Jeff King"
	"Greg Nichols"
	"Jacob Hunsaker"
	"Erik Falor"
	"Lance Parker"
	)

HIGH_COUNCIL=(
	"Mark Anderson"
	)

WARD_COUNCIL=(
	$BISHOPRIC
	"George Thomsen"
	"Shannon Eliason"
	"James Fritzler"
	"Eva Conde"
	"Amy Edvalson"
	"Derald Clark"
	)


YOUTH_COUNCIL=(
	$BISHOPRIC
	"Priest Quorum 1st Assistant"
	"Teacher's & Deacon's Quorum Presidents"
	"Young Women Class Presidents"
	"Young Women President"
	)


_bishopric_email() {
	cat <<-EM > $CHURCH/bishopric_email
	To: ${(j:, :)BISHOPRIC}, ${(j:, :)HIGH_COUNCIL}
	Bishopric Meeting Sunday @ 8:30am

	Handbook Training: Bro. ~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}

_ward_council_email() {
	cat <<-EM > $CHURCH/ward_council_email
	To:  ${(j:, :)WARD_COUNCIL}
	Ward Council Meeting Sunday @ 9:45am

	Zoom Link:
	https://zoom.us/j/95220863203?pwd=SkpQVW9UckxuMk9wYnRNd3g4V1Nadz09

	Spiritual Thought & Song: ~~~~~~~

	Meeting Agenda:
	~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}


_youth_council_email() {
	cat <<-EM > $CHURCH/youth_council_email
	To: ${(j:, :)YOUTH_COUNCIL}
	Youth Council Meeting Sunday @ 9:45am

	https://zoom.us/j/95018696863?pwd=WFZhTjNFcTNTNDNZSUh6dHdtSHk5Zz09
	Meeting ID: 952 2086 3203
	Passcode: 425441

	Spiritual Thought & Song: ~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}

setup() {
	$BROWSER \
		https://docs.google.com/document/d/1_IaASzBuJGxxLkk58LpNGUdSdCyYXuS0p5gEADiwNVw/edit \
		https://docs.google.com/spreadsheets/d/1SRNa8kKWCzNE_VRsf-m5KQm-ky9y3dMYtpsamF1mMOM/edit \
		https://drive.google.com/drive/folders/1gGZF3WEEe2mB_DIAZdbdA9SbWXKyWeo7 \
		"https://lcr.churchofjesuschrist.org/messaging?lang=eng" \
		https://calendar.google.com/calendar/u/0/r/week \
		>/dev/null 2>&1 &

	[[ ! -d $CHURCH ]] && mkdir -p $CHURCH
	# Restore the email templates
	_bishopric_email
	_ward_council_email
	_youth_council_email
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

	cal
}


cleanup() {
	print You worked on that for $( prettySeconds $SECONDS )
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
