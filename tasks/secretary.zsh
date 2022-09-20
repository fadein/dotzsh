#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.10.17"
   DATE="Wed Aug 24 20:08:24 MDT 2022"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r
# suppress launch of browser by prefixing command with BROWSER=
BROWSER=${BROWSER-firefox}
CHURCH=~/Documents/Church

BISHOPRIC=(
	"Jeff King"
	"Greg Nichols"
	"Jacob Hunsaker"
	)

CLERK="Justin Campbell"

SEC_CLERK=(
	"Erik Falor"
	$CLERK
	)

HIGH_COUNCIL=(
	"Mark Anderson"
	)


WARD_COUNCIL=(
	$SEC_CLERK
	$HIGH_COUNCIL
	$BISHOPRIC
	"Elder's Quorum President (Gustavo Flores)"
	"Relief Society President (Shannon Eliason)"
	"Sunday School President (James Fritzler)"
	"Young Women's President (Eva Conde)"
	"Primary President (Jennifer Parker)"
	"Ward Mission Leader (Derald Clark)"
	)


YOUTH_COUNCIL=(
	$BISHOPRIC
	"Priest Quorum 1st Assistant (Andy Decker)"
	"Teacher's & Deacon's Quorum Presidents (Jack Decker, Conner Chesley)"
	"Young Women Class Presidents (Tess Hoglund, Kate Gunnell)"
	"Young Women President"
	)


_bishopric_email() {
	cat <<-EM > $CHURCH/bishopric_email
	Bishopric Meeting Sunday @ 6:30am
	To: ${(j:, :)BISHOPRIC}, ${(j:, :)SEC_CLERK}, ${(j:, :)HIGH_COUNCIL}

	Handbook Training: Bro. ~~~~~~~
	Meeting Agenda:
	~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}


_ward_council_email() {
	cat <<-EM > $CHURCH/ward_council_email
	Ward Council Meeting Sunday @ 7:30am
	To:  ${(j:, :)WARD_COUNCIL}

	Spiritual Thought & Song: ~~~~~~~

	Meeting Agenda:
	~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}


_youth_council_email() {
	cat <<-EM > $CHURCH/youth_council_email
	Youth Council Meeting Sunday @ 8:00am
	To: ${(j:, :)YOUTH_COUNCIL}

	Spiritual Thought & Song: ~~~~~~~

	Agenda: ~~~~~~~

	See you Sunday morning!
	-- Erik
	EM
}


setup() {
	if [[ -n $BROWSER ]]; then
		$BROWSER \
			https://docs.google.com/document/d/1_IaASzBuJGxxLkk58LpNGUdSdCyYXuS0p5gEADiwNVw/edit \
			https://docs.google.com/spreadsheets/d/1SRNa8kKWCzNE_VRsf-m5KQm-ky9y3dMYtpsamF1mMOM/edit \
			https://drive.google.com/drive/folders/1gGZF3WEEe2mB_DIAZdbdA9SbWXKyWeo7 \
			"https://lcr.churchofjesuschrist.org/messaging?lang=eng" \
			https://calendar.google.com/calendar/u/0/r/week \
			>/dev/null 2>&1 &
	fi

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
	)

	# if next Sunday is a 4th Sunday
	case $( command date -d 'next sunday' +%d ) in
		<22-28>) # Fourth Sunday = Bishopric Youth Committee
			_TODO+=(
				"Remind bishop to contact BYC conductor (YM=odd months, YW=even)"
				"Text bishopric youth committee members"
				"Email adults involved with bishopric youth committee"
			)
			;;
		<29-31>) # Fifth Sunday = Whatever
			_TODO+=(
				"If we are holding a 2nd meeting, who has spiritual thought in the 2nd meeting?"
				"If we are holding a 2nd meeting, make an agenda"
				"If we are holding a 2nd meeting, email attendees")
			;;
		<1-7>|<15-21>)  # 1st & 3rd Sunday = Ward Council
			_TODO+=(
				"Who has spiritual thought in Ward Council?"
				"Make a Ward Council agenda"
				"Email Ward Council attendees")
			;;
	esac

	_TODO+=(
        "Check sacrament hymns"
        "Copy sacrament agenda from last time"
		"Get conductor & speakers from Bishopric agenda"
		"Get prayers from ${${=CLERK}[1]}"  # ${=VAR} splits str->array on whitespace
    )

	cal $(command date -d 'next sunday' +'%d %m %Y')
	printf "%14.8s\n\n" $(command date -d 'next sunday' +%D)

	case $(command date -d 'next sunday' +%d) in
		<1-7>|<15-21>)  # 1st & 3rd Sunday
			print "This Sunday will be Sunday School"
			print "Ward Council is held this week"
			;;
		<8-14>)  # 2nd Sunday
			print "This Sunday will be Priesthood/Relief Society"
			case $(command date -d 'next sunday' +%m) in
				01|04|07|10) print "Bishop has a quarterly interview with the Primary President" ;;
				02|05|08|11) print "Bishop has a quarterly interview with the Relief Society President" ;;
				03|06|09|12) print "Bishop has a quarterly interview with the Young Women President" ;;
			esac
			;;
		<22-28>)  # 4th Sunday
			print "This Sunday will be Priesthood/Relief Society"
			print "Bishop Youth Council is held this week"
			case $(command date -d 'next sunday' +%m) in
				01|04|07|10) print "Bishop has a quarterly interview with the Sunday School President" ;;
				02|05|08|11) print "Bishop has a quarterly interview with the Elder's Quorum President" ;;
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
