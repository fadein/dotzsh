#!/bin/env zsh

PURPOSE="Weekly Secretary Duties"
VERSION="0.12.2"
   DATE="Thu Jul 18 2024"
 AUTHOR="erik"

PROGNAME=$0
TASKNAME=$0:t:r
# suppress launch of browser by prefixing command with BROWSER=
BROWSER=${BROWSER-firefox}

if [[ -x =xdg-user-dir ]]; then
	CHURCH=$(xdg-user-dir DOCUMENTS)/Church
else
	CHURCH=~/Documents/Church
fi

setup() {
	if [[ -n $BROWSER ]]; then
		$BROWSER \
			https://docs.google.com/document/d/1_IaASzBuJGxxLkk58LpNGUdSdCyYXuS0p5gEADiwNVw/edit \
			https://docs.google.com/spreadsheets/d/1SRNa8kKWCzNE_VRsf-m5KQm-ky9y3dMYtpsamF1mMOM/edit \
			https://drive.google.com/drive/folders/1gGZF3WEEe2mB_DIAZdbdA9SbWXKyWeo7 \
			"https://lcr.churchofjesuschrist.org/messaging?lang=eng" \
			https://calendar.google.com/calendar/u/0/r/week \
			https://tinyurl.com \
			>/dev/null 2>&1 &
	fi

	[[ ! -d $CHURCH ]] && mkdir -p $CHURCH
	cd $CHURCH
}


env() {
    _TODO=(
        "Note which weekly/quarterly interviews happen this Sunday"
        "Who has handbook training in bishopric meeting?"
        "Make a new bishopric agenda"
        "Text the bishopric, alert whoever has the training"
	)

	# if next Sunday is a 4th Sunday
	case $( command date -d 'next sunday' +%d ) in
		<22-28>) # Fourth Sunday = Bishopric Youth Committee
			_TODO+=(
				"Remind bishop to contact BYC conductor (YM=odd months, YW=even)"
				"Make a BYC agenda"
				"Shorten agenda URL and test it"
				"Text bishopric youth committee members"
			)
			;;
		<29-31>) # Fifth Sunday = Whatever
			_TODO+=(
				"If we are holding a 2nd meeting, who has spiritual thought in the 2nd meeting?"
				"If we are holding a 2nd meeting, make an agenda"
				"Shorten agenda URL"
				"If we are holding a 2nd meeting, contact attendees")
			;;
		<1-7>|<15-21>)  # 1st & 3rd Sunday = Ward Council
			_TODO+=(
				"Who has spiritual thought in Ward Council?"
				"Make a Ward Council agenda"
				"Shorten agenda URL"
				"Contact Ward Council attendees")
			;;
	esac

	_TODO+=(
        "Check sacrament hymns"
        "Copy sacrament agenda from last time"
		"Get conductor & speakers from Bishopric agenda"
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
