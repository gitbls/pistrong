#!/bin/bash
#
# Basic script to keep VPN tunnel always up
#
# $1: Name of tunnel (e.g., otherhost-Tunnel)
#
vpntunup() {
    #
    # $1 has tunnel name
    #
    sas=$(swanctl --list-sas | grep $1)
    [[ "$sas" =~ "ESTABLISHED" ]] && return 0 || return 1
}

vpnup() {
    #
    # $1 has tunnel name
    #
    if [ "$VPNMONPINGIP" != "" ]
    then
	if (ping -c 1 -W 1 $VPNMONPINGIP > /dev/null 2>&1)
	then
	    return 0
	else
	    return 2
	fi
    fi
    vpntunup $1
    return $?
    #sas=$(swanctl --list-sas | grep $1)
    #[[ "$sas" =~ "ESTABLISHED" ]] && return 0 || return 1
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
vpntunnel=$1
# /etc/default/pistrong-vpnmon-$vpntunnel: VPNMONPINGIP="ip.ad.dd.rs" # to monitor specific IP accessibility
# and force tunnel down if that IP is not accesible
[ -f /etc/default/pistrong-vpnmon-$vpntunnel ] && source /etc/default/pistrong-vpnmon-$vpntunnel

[ "$1" == "" ] && logger "VPNmon: No VPN name specified" && exit

while [ 1 ]
do
    vpnup $vpntunnel
    if [ $? -eq 2 ]
    then
	logger "VPNmon: Tunnel $vpntunnel remote IP $VPNMONPINGIP is not accessible; stopping tunnel so it can be restarted"
	pistrong client stop $vpntunnel
	sleep 5
    fi
    ! vpntunup $vpntunnel && tryreconnect $vpntunnel
    sleep 10
done
