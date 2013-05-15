#!/bin/zsh

PURPOSE='Assist to bring up VPN Tunnel to USU'
VERSION="1.0"
   DATE="Tue Oct  9 16:28:42 MDT 2012"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0:t
TASKNAME=$0:t:r

SUDO=/usr/bin/sudo

spawn() {
	$SUDO TASK=$TASKNAME $ZSH
}

env() {
	_TODO=(
		'$ for S in /etc/init.d/{ipsec,xl2tpd}; do $S start; done'
		'$ ipsec auto --up L2TP-PSK'
		'$ echo "c L2TPserver" > /var/run/xl2tpd/l2tp-control'
		'$ route add -host 129.123.67.252 gw 192.168.1.1 dev eth0'
		'$ route add -net 129.123.0.0 netmask 255.255.0.0 dev ppp0'
		'$ iptables -I INPUT 3 -i ppp0 -j ACCEPT')

	cd /root/usuvpn
}

source $0:h/__TASKS.zsh
