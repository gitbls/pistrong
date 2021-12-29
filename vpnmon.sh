#!/bin/bash
#
# Basic script to keep VPN tunnel always up
#
# $1: Name of tunnel (e.g., otherhost-Tunnel)
#
vpnup() {
    #
    # $1 has tunnel name
    #
    sas=$(swanctl --list-sas | grep $1)
    [[ "$sas" =~ "ESTABLISHED" ]] && return 0 || return 1
}

tryreconnect() {
    #
    # $1 has tunnel name
    #
    for (( mins=0; mins<10; mins++ ))
    do
	for (( secs=0; secs<6; secs++ ))
	do
	    logger "VPNmon: (Re)Starting VPN $1"
	    pistrong client start $1
	    vpnup $1 && return 0
	    sleep 10
	done
    done
}
#
# Main
#
if [ "$2" == "" ]
then
    $0 $1 fork &
    exit
fi
#
# Running in the fork
#

[ "$1" == "" ] && logger "VPNmon: No VPN name specified" && exit

while [ 1 ]
do
    ! vpnup $1 && tryreconnect $1
    sleep 10
done
