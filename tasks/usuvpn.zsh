#!/bin/zsh

PURPOSE='bring up VPN Tunnel to USU'
VERSION=1.2
   DATE="Wed Sep 24 23:56:27 MDT 2014"
 AUTHOR="Erik Falor <ewfalor@gmail.com>"

PROGNAME=$0
TASKNAME=$0:t:r

ROUTE=/bin/route
IPTABLES=/sbin/iptables
OPENCONNECT=/usr/sbin/openconnect

BGPID=
setup() {
    raisePrivs
    echo 'yo@aBkeE/j4Gleys' | $OPENCONNECT -u A00319537 --passwd-on-stdin sslvpn.usu.edu &
    BGPID=$!

    until grep -q @VPNC_GENERATED@ /etc/resolv.conf; do
        sleep 2
    done

    sed -i -e '/resolv.conf.head/ a\
domain falor \
nameserver 192.168.1.1
' /etc/resolv.conf
}

spawn() {
    dropPrivsAndSpawn
}

# env() {
#     $SUDO $ROUTE add -host 129.123.67.252 gw 192.168.1.1 dev enp2s0
#     $SUDO $ROUTE add -net 129.123.0.0 netmask 255.255.0.0 dev tun0
#     $SUDO $IPTABLES -A INPUT -i tun0 -j ACCEPT
# }

cleanup() {
    if [[ -n "$BGPID" ]]; then
        until kill $!; do
            print -n .
            sleep 1
        done
    fi
}

#  # spawn a root shell
#  spawn() {
#  	$SUDO TASK=$TASKNAME $ZSH_NAME
#  }
#  
#  env() {
#      # '$ for S in /etc/init.d/{ipsec,xl2tpd}; do $S start; done'
#      # '$ ipsec auto --up L2TP-PSK'
#      # '$ echo "c L2TPserver" > /var/run/xl2tpd/l2tp-control'
#  	_TODO=(
#  		'$ route add -host 129.123.67.252 gw 192.168.1.1 dev enp2s0'
#  		'$ route add -net 129.123.0.0 netmask 255.255.0.0 dev tun0'
#  		'$ iptables -A INPUT -i tun0 -j ACCEPT' )
#  
#  	cd /root/usuvpn
#  }

source $0:h/__TASKS.zsh

# vim:set foldenable foldmethod=indent filetype=sh tabstop=4 expandtab:
