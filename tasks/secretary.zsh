#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.9"
   DATE="Wed Jun 23 16:38:12 MDT 2021"
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
	"Priest Quorum 1st Assistant (Chase Chesley)"
	"Teacher's & Deacon's Quorum Presidents (Tai Falor, Jack Decker)"
	"Young Women Class Presidents (Avery Anderson, Sydney Haynie)"
	"Young Women President"
	)


_bishopric_email() {
	cat <<-EM > $CHURCH/bishopric_email
	Bishopric Meeting Sunday @ 8:30am
	To: ${(j:, :)BISHOPRIC}, ${(j:, :)HIGH_COUNCIL}

	Handbook Training: Bro. ~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}


_ward_council_email() {
	cat <<-EM > $CHURCH/ward_council_email
	Ward Council Meeting Sunday @ 9:45am
	To:  ${(j:, :)WARD_COUNCIL}

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
	Youth Council Meeting Sunday @ 9:45am
	To: ${(j:, :)YOUTH_COUNCIL}

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
	cd $CHURCH

	# Update the email templates
	_bishopric_email
	_ward_council_email
	_youth_council_email
}


env() {
    _TODO=(
        "check which weekly/quarterly meetings happen this Sunday"
        "who has handbook training in bishopric meeting?"
        "make a new bishopric agenda"
        "email the bishopric, alert whoever has the training"
        "who has spiritual thought in the 2nd meeting?"
		"make a new 2nd meeting agenda with Zoom link")

	# if next Sunday is a 4th Sunday
	case $( command date -d 'next sunday' +%d ) in
		<22-28>) # Fourth Sunday = Bishopric Youth Committee
			_TODO+=(
				"remind bishop to contact conductor (YM=even months, YW=odd)"
				"text bishopric youth committee members"
				"email adults involved with bishopric youth committee"
			)
			;;
		<29-31>) # Fifth Sunday = Whatever
			_TODO+=("if we are holding a 2nd meeting, email attendees")
			;;
		*)
			_TODO+=("email 2nd meeting attendees")
			;;
	esac

	_TODO+=(
        "check sacrament hymns"
        "copy sacrament agenda from last time"
		"get conductor & speaker from Bishopric agenda"
		"get prayers from Lance"
    )

	cal $(\date -d 'next sunday' +'%d %m %Y')
	print
	case $( command date -d 'next sunday' +%d ) in
		<1-7>|<15-21>)
			print "This Sunday will be Sunday School"
			;;
		<8-14>|<22-28>)
			print "This Sunday will be Priesthood/Relief Society"
			;;
		<29-31>)
			print "This is a 5th Sunday; the 2nd meeting will be combined"
			;;
	esac
}


cleanup() {
	print You worked on that for $( prettySeconds $SECONDS )
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
