#!/bin/bash

#Gebruik voorbeeld: ./DHCPtoggle.sh DHCP

RESTART="systemctl restart networking.service"
IPA="ip a"

if [[ "$1" == "DHCP" ]];
then
	echo "Instellen als DHCP"
	echo "source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

auto ens33
allow-hotplug ens33
iface ens33 inet dhcp" > /etc/network/interfaces

	sleep 5
	eval $RESTART
	eval $IPA

elif [[ "$1" == "STATIC" ]];
then
	echo "instellen als STATIC"
	echo "source /etc/network/interfaces.d/*
auto lo
iface lo inet loopback

auto ens33
allow-hotplug ens33
iface ens33 inet static
	address 192.168.17.15
	netmask 255.255.255.0
	gateway 192.168.17.1" > /etc/network/interfaces

	sleep 5 
	eval $RESTART
	eval $IPA


elif [[ -z "$1" ]];
then
	echo "Parameter is leeg"
else
	echo "Verkeerde parameter"
fi
