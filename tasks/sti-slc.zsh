#!/bin/env zsh

 PURPOSE="Connect to Spillman WiFi"
 VERSION="1.1"
    DATE="Wed Oct 15 10:51:23 MDT 2014"
  AUTHOR="Erik Falor <ewfalor@gmail.com>"
PROGNAME=$0
TASKNAME=$0:t:r

# The host name I'd like to request from the DNS server
HOST_NAME=voyager.spillman.com
INTERFACE=wlan0

#
# I like to refer to programs by absolute path for security.  You
# can do this too, or not.
DHCPCD=/sbin/dhcpcd
GREP=/usr/bin/grep
IFCONFIG=/sbin/ifconfig
KILLALL=/bin/killall
SLEEP=/usr/bin/sleep
WPA_SUPPLICANT=/usr/sbin/wpa_supplicant

setup() {
	raisePrivs

	/etc/rc.d/rc.wicd stop

    $WPA_SUPPLICANT -B -Dwext -i$INTERFACE -c/etc/wpa_supplicant.conf \
        || die "Couldn't start wpa_supplicant"

    print please wait for dhcpcd...
    $SLEEP 3
    $DHCPCD --waitip -h $HOST_NAME

    $SLEEP 4
    if ! $IFCONFIG $INTERFACE | $GREP -q "inet 10.240"
    then
        print "connect failed"
        print "(is your password correct?)"
    else
        print YOU WIN
    fi
}

spawn() {
    dropPrivsAndSpawn $ZSH_NAME
}

cleanup() {
    while $KILLALL dhcpcd wpa_supplicant
    do
        print killing dhcpcd, wpa_supplicant...
        $SLEEP 1
    done
    print dhcpcd, wpa_supplicant are shut down
	/etc/rc.d/rc.wicd start
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
