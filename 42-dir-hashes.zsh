#
# Hashed directory shortcuts
#
# To use, prepend a ~ to their name. Ex:
#   cd ~vlp
#   mv README.md ~tutor

# Anon function for namespace hygiene
function {

# These were originally defined as assoc arrays, but Zsh's for loop can take
# items from an ordinary array N at a time.  Syntactically, this doesn't change
# the array declarations, but makes the loop at the bottom cleaner.
local system=(
	# +,/)/-1sort
	cups /etc/cups
	dict /usr/share/dict
	distfiles /usr/sbo/distfiles
	lib64 /usr/lib64
	nm /etc/NetworkManager/system-connections
	rc.d /etc/rc.d
	sbodist /usr/sbo/distfiles
	sborepo /usr/sbo/repo
	slackpkg /etc/slackpkg
	ssh /etc/ssh
	stow /usr/local/stow
	ub /usr/bin
	ul /usr/lib
	ulb /usr/local/bin
	um /usr/man
	usl /usr/src/linux
	vcp /var/cache/packages
	vl /var/log
	vlp /var/log/packages
	x11 /etc/X11
	drep /etc/drep
	)


local home=(
	# +,/)/-1sort
	build $HOME/build
	cache $HOME/.cache
	config $HOME/.config
	devel $HOME/devel
	docs $HOME/docs
	down $HOME/downloads
	dwm $HOME/.dwm
	home $HOME
	local $HOME/.local
	localbin $HOME/.local/bin
	pyenv $HOME/.pyenv
	school $HOME/school
	tutor $HOME/school/shell-tutor-dev
	vim $HOME/.vim
	zsh $HOME/.zsh
	)


local devel=(
	# +,/)/-1sort
	bfl $HOME/devel/BugFixLogs
	c $HOME/devel/c
	devel $HOME/devel
	homedir $HOME/devel/homedir
	perl $HOME/devel/perl
	python $HOME/devel/python
	rust $HOME/devel/rust
	rustlings $HOME/devel/rust/rustlings
	sbo $HOME/devel/SBOoverride
	scheme $HOME/devel/scheme
	shell $HOME/devel/shell
	)


local school=(
	1400 $HOME/1400
	1410 $HOME/1410
	1440 $HOME/1440
	3450 $HOME/3450
	abet $HOME/school/ABET_Chair
	auto $HOME/school/course_automation
	automation $HOME/school/course_automation
	ca $HOME/school/course_automation
	canvas $HOME/school/CanvasAPI
	dm $HOME/school/digital_measures
	emails $HOME/school/emails
	gitlab $HOME/school/GitLab
	lecnotes $HOME/school/lecnotes-test
	lor $HOME/school/letters_of_recommendation
	navigation $HOME/school/navigation
	rec $HOME/school/letters_of_recommendation
	scanner $HOME/school/scanner
	school $HOME/school
	videos $HOME/school/videos
	)

for key value in $system $home $devel $school; do
	if [[ -d $value ]]; then
		hash -d $key=$value
	# else print -P "%B%F{red}$value is not a directory%f%b"
	fi
done

}
# vim:set foldenable foldmethod=indent filetype=zsh tabstop=4 noexpandtab:
