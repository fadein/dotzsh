#!/bin/env zsh

PURPOSE="Recording a screencast with Vokoscreen + Flowblade w/ custom MLT"
VERSION="2.1"
   DATE="Fri Jul 11 2025"
 AUTHOR="Erik Falor"

PROGNAME=$0
TASKNAME=$0:t:r

VIDEOS=$HOME/docs/videos
PICS=$HOME/docs/pictures

case $HOSTNAME in
    atlantis)
        output=eDP
        resolution=2880x1920
		dpi=220
        ;;
    columbia|endeavour)
        output=eDP-1 
        resolution=3840x2160
		dpi=200
        ;;
esac


setup() {
	killall picom

	# Set the DPI for Firefox in 1080p mode
	print Xft.dpi: 132 | xrdb -quiet -override

	# Set my screen to 1080p
	xrandr --output $output --mode 1920x1080

	# Assert my default settings
	if [[ -f ~/.config/vokoscreenNG/vokoscreenNG.ini ]]; then
		sed -i \
			-e "s#VideoPath=.*#VideoPath=$VIDEOS#" \
			-e "s#ImagePath=.*#ImagePath=$PICS#" \
			-e "s#comboBoxAudioCodec=.*#comboBoxAudioCodec=vorbis#" \
			-e "s#comboBoxFormat=.*#comboBoxFormat=webm#" \
			-e "s#checkBoxShowInSystray=.*#checkBoxShowInSystray=false#" \
			-e "s#checkBoxShowInSystrayAlternative=.*#checkBoxShowInSystrayAlternative=false#" \
			-e "s#sliderScreencastCountDown=.*#sliderScreencastCountDown=3#" \
			$HOME/.config/vokoscreenNG/vokoscreenNG.ini
	fi

	[[ -d $VIDEOS ]] || mkdir -p $VIDEOS
	[[ -d $PICS ]] || mkdir -p $PICS

	# create Flowblade render args file
	if ! [[ -f $VIDEOS/webm.rargs ]]; then
		cat <<-WEBM_RARGS > $VIDEOS/webm.rargs
		f=webm
		acodec=libvorbis
		ab=128k
		vcodec=libvpx
		g=120
		rc_lookahead=16
		quality=good
		speed=0
		vprofile=0
		qmax=51
		qmin=11
		slices=4
		vb=8000k
		maxrate=24M
		minrate=100k
		arnr_max_frames=7
		arnr_strength=5
		arnr_type=3
		auto-alt-ref=0
		mlt_image_format=rgb24a
		pix_fmt=yuv420p
		WEBM_RARGS
	fi

	urxvt -geometry 88x19 -fn xft:hack:pixelsize=14:antialias=true -bg midnightblue -e sh -c "cd Videos; vokoscreenNG" &
	if [[ $TERM == rxvt-unicode* ]]; then
		print "\033]710;xft:hack:pixelsize=14:antialias=true\007"
	fi
	sleep .25

	VOKOPID=$!
	disown
}


usage() {
	>&1 <<-MESSAGE
	# Using vokoscreen

	1.  *Display* Record fullscreen on eDP1: 1920x1080
	    *   Disable magnification
	    *   Set a countdown of 3 seconds, wait until the countdown screen completely disappears before speaking

	2.  *Audio*
	    *   Select _Yeti Stereo Microphone Analog Stereo_
	    *   Deselect all *Monitor* inputs, including _Monitor of Yeti ..._

	3.  *Video*
	    *   Keep the defaults:
	        - 25 fps
	        - Format: webm
	        - Videocodec: VP8
	        - Audiocodec: vorbis
	    *   These defaults (especially Vorbis) enable Canvas to auto-caption the video


	# Uploading to Canvas

	Upload a video in .webm format as a file.

	Embed it into a page as an ordinary file using the sidebar on the right.
	Canvas will replace the link with a thumbnail that expands to a video player
	when clicked.


	# Captioning videos

	Once the video is live email <captions@usu.edu> with the URL so they can caption it

	MESSAGE
}


env() {
	quickavi() {
		if [[ $# -lt 1 ]]; then
			print "Usage: quickavi INPUT"
			return 1
		fi

		if [[ $1:e == avi ]]; then
			print "$1 is already in AVI format"
			return 2
		fi

		ffmpeg -hide_banner -i $1 -bsf:v h264_mp4toannexb -c:v copy -c:a copy $1:r.avi
	}

	shrink() {
		if [[ $# -lt 2 ]]; then
			print "Usage: shrink INPUT OUTPUT"
			return 1
		fi

		if [[ $1:e != $2:e ]]; then
			print "The file extension of INPUT should match OUTPUT"
			return 2
		fi

		case $2:e in
			mkv)
				ffmpeg -i $1 -b:v 400k -c:v mpeg4 -acodec copy $2
				;;
			mp4)
				ffmpeg -i $1 -b:v 4000k -c:v mpeg4 -acodec copy $2
				;;
			*)
				print Unknown format $2:e
				return 3
				;;
		esac
	}

	flowblade () {
		OLD_DPI=$(xrdb -q | \grep Xft.dpi) 
		echo "Xft.dpi: 232" | xrdb -override
		echo "Xft.dpi: 96" | xrdb -override
		# wip: find my custom build of MLT
		PYTHONPATH=/usr/local/lib64/python3.9/site-packages ~/build/flowblade/flowblade-trunk/flowblade
		echo "$OLD_DPI" | xrdb -override
	}


	typeset -gA _HELP
	_HELP+=(quickavi "DEPRECATED: quickly convert MKV into AVI"
		shrink "DEPRECATED: re-encode an MP4 or MKV into a lower bitrate"
		usage "Display a helpful usage message"
		flowblade "Run flowblade (Git version) out of ~/build"
	)

	alias mplayer='mplayer -osdlevel 3 -speed 1.5 -af scaletempo'

	cd $VIDEOS
	usage
}


cleanup() {
	kill $VOKOPID
	if [[ $TERM == rxvt-unicode* ]]; then
		print "\033]710;xft:hack:pixelsize=32:antialias=true\007"
	fi
	print Xft.dpi: $dpi | xrdb -quiet -override
	xrandr --output $output --mode $resolution

	sleep .25
	picom& disown
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
