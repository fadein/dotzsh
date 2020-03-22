#!/bin/env zsh

PURPOSE="Recording a screencast"
VERSION="1.2"
   DATE="Sat Mar 21 21:06:36 MDT 2020"
 AUTHOR="Erik Falor"

PROGNAME=$0
TASKNAME=$0:t:r

VIDEOS=~/Videos/

setup() {
	case $HOSTNAME in
		endeavour)
			# Set the DPI for Firefox
			print Xft.dpi: 132 | xrdb -quiet -override

			# Set my screen to 1080p
			xrandr --output eDP1 --mode 1920x1080
			;;
	esac


	xset s off -dpms
	killall compton
	if ! [[ -d $VIDEOS ]]; then
		mkdir -p $VIDEOS
	fi

	urxvt -geometry 88x19 -fn xft:hack:pixelsize=24:antialias=true -bg midnightblue -e sh -c "cd Videos; vokoscreen" &

	VOKOPID=$!
	sleep .25
	disown
}


help() {
	>&1 <<-MESSAGE
	# Using vokoscreen

	0.  Put DWM in floating mode

	1.  *Display* Record fullscreen on Display #2: 1920x1080
		*   Set a countdown of 3 seconds, wait until the countdown screen completely disappears before speaking

	2.  *Audio*
		*   Select _Alsa_, and _Yeti Stereo Microphone_

	3.  *Video*
		*   Keep the defaults:
			- 25 fps
			- Format: mkv
			- Videocodec: mpeg4
			- Audiocodec: libmp3lame


	# Uploading to Canvas

	Upload a video converted to .avi (or .mp4) format as a file.

	Embed it into a page as an ordinary file using the sidebar on the right.
	Canvas will replace the link with a thumbnail that expands to a video player
	when clicked.


	# Uploading to Kaltura

	Upload the .mkv file to Kaltura's media gallery.  It'll become available after they do their processing

	# Captioning videos

	Once the video is live email <captions@usu.edu> with the URL so they can caption it


	# Converting Vokoscreen recordings to AVI format

	Canvas will auto-embed AVI files into an online player.  MKV is not supported.

	In order to just copy the video and audio bitstream, thus without quality loss
	run this command.  This is *fast*:

		ffmpeg -i filename.mkv -c:v copy -c:a copy output.avi


	When that doesn't work, FFmpeg can convert video and audio into the new format:

		ffmpeg -i filename.mkv output.avi


	# Reducing file size
	
	I tried this on a file that Flowblade inflated to >1GB (sources were
	~600MB) and it reduced it down to ~60MB.

		ffmpeg -i $VIDEO -r 15 -filter minterpolate ${VIDEO%mpg}mkv
	MESSAGE
}


env() {
	cd $VIDEOS
	help
}


cleanup() {
	kill $VOKOPID
	xset s on +dpms
	compton& disown
	case $HOSTNAME in
		endeavour)
			print Xft.dpi: 200 | xrdb -quiet -override
			xrandr --output eDP1 --mode 3840x2160
			;;
	esac

}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
