#!/bin/env zsh

PURPOSE="Connect to Spillman WiFi"
VERSION="1.0"
   DATE="Tue Aug  6 10:13:56 MDT 2013"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

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
SUDO=/usr/bin/sudo
WPA_SUPPLICANT=/usr/sbin/wpa_supplicant


setup() {
	$SUDO /etc/rc.d/rc.wicd stop

    $SUDO $WPA_SUPPLICANT -B -Dwext -i$INTERFACE -c/etc/wpa_supplicant.conf \
        || die "Couldn't start wpa_supplicant"

    print please wait for dhcpcd...
    $SLEEP 3
    $SUDO $DHCPCD --waitip -h $HOST_NAME

    $SLEEP 4
    if ! $SUDO $IFCONFIG $INTERFACE | $GREP -q "inet 10.240"
    then
        print "connect failed"
        print "(is your password correct?)"
    else
        print YOU WIN
    fi
}

spawn() {
	TASK=$TASKNAME $ZSH_NAME
}

cleanup() {
    while $SUDO $KILLALL dhcpcd wpa_supplicant
    do
        print killing dhcpcd, wpa_supplicant...
        $SLEEP 1
    done
    print dhcpcd, wpa_supplicant are shut down
	$SUDO /etc/rc.d/rc.wicd start
}

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
