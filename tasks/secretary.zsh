#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.10.1"
   DATE="Thu Jul  8 17:02:25 MDT 2021"
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
        "Note which weekly/quarterly interviews happen this Sunday"
        "Who has handbook training in bishopric meeting?"
        "Make a new bishopric agenda"
        "Email the bishopric, alert whoever has the training"
        "Who has spiritual thought in the 2nd meeting?"
		"Make a new 2nd meeting agenda with Zoom link")

	# if next Sunday is a 4th Sunday
	case $( command date -d 'next sunday' +%d ) in
		<22-28>) # Fourth Sunday = Bishopric Youth Committee
			_TODO+=(
				"Remind bishop to contact conductor (YM=even months, YW=odd)"
				"Text bishopric youth committee members"
				"Email adults involved with bishopric youth committee"
			)
			;;
		<29-31>) # Fifth Sunday = Whatever
			_TODO+=("If we are holding a 2nd meeting, email attendees")
			;;
		*)
			_TODO+=("Email 2nd meeting attendees")
			;;
	esac

	_TODO+=(
        "Check sacrament hymns"
        "Copy sacrament agenda from last time"
		"Get conductor & speaker from Bishopric agenda"
		"Get prayers from Lance"
    )

	cal $(\date -d 'next sunday' +'%d %m %Y')
	print
	case $( command date -d 'next sunday' +%d ) in
		<1-7>|<15-21>)  # 1st & 3rd Sunday
			print "This Sunday will be Sunday School"
			print "Ward Council is held this week"
			;;
		<8-14>)  # 2nd Sunday
			print "This Sunday will be Priesthood/Relief Society"
			case $(cal $(\date -d 'next sunday' +%m)) in
				1|4|7|10) print "Bishop has an interview with the Primary President" ;;
				2|5|8|11) print "Bishop has an interview with the Relief Society President" ;;
				3|6|9|12) print "Bishop has an interview with the Young Women President" ;;
			esac
			;;
		<22-28>)  # 4th Sunday
			print "This Sunday will be Priesthood/Relief Society"
			print "Bishop Youth Council is held this week"
			case $(cal $(\date -d 'next sunday' +%m)) in
				1|4|7|10) print "Bishop has an interview with the Sunday School President" ;;
				2|5|8|11) print "Bishop has an interview with the Elder's Quorum President" ;;
			esac
			;;
		<29-31>)
			print "This is a 5th Sunday; the 2nd meeting will be combined"
			print "Check with Bishop what kind of meeting to hold"
			;;
	esac
}


cleanup() {
	print You worked on that for $( prettySeconds $SECONDS )
}


source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
