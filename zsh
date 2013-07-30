#!/bin/sh

case $(uname) in
	Linux)
		SHELL=$HOME/.zsh/zsh-5.0.0-linux exec $HOME/.zsh/zsh-5.0.0-linux $*;;
	AIX)
		SHELL=$HOME/.zsh/zsh-5.0.0-aix exec $HOME/.zsh/zsh-5.0.0-aix $*;;
	*)
		echo "I don't have a zsh built for this platform" ;;
esac
