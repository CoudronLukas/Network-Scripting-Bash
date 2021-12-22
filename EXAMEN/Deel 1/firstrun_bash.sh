#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
CURRENT_USER=`whoami`

#controleert of de USB verbonden is
if [[ -f "/media/${CURRENT_USER}/boot" ]]
then
    echo "The USB is connected!"
	echo "Writing to USB..."
	echo "---------------------"
	
	#standaard code
	echo TDCsPi >/etc/hostname
	sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tTDCsPi/g" /etc/hosts
	FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
	FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
	echo "$FIRSTUSER:"'$5$bJs6KciFNd$aiF/zJ80bXISxpNlFg6t2nD5SdscP97/SOuYEkSHmF6' | chpasswd -e
	systemctl enable ssh
	#cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
	echo "country=BE" >>/etc/wpa_supplicant/wpa_supplicant.conf
	echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev" >/etc/wpa_supplicant/wpa_supplicant.conf
	echo "ap_scan=1" >/etc/wpa_supplicant/wpa_supplicant.conf
	echo "" >/etc/wpa_supplicant/wpa_supplicant.conf
	echo "update_config=1" >/etc/wpa_supplicant/wpa_supplicant.conf
	echo "network={" >/etc/wpa_supplicant/wpa_supplicant.conf
	echo 'ssid="Howest-IoT"' >/etc/wpa_supplicant/wpa_supplicant.conf
	echo 'psk=a2ad90c72dd23d4fb7daed24ec566fa2311abb84904035d4dea7f4500240f0b9' >/etc/wpa_supplicant/wpa_supplicant.conf
	echo '}' >/etc/wpa_supplicant/wpa_supplicant.conf

	WPAEOF
	chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf
	rfkill unblock wifi
	for filename in /var/lib/systemd/rfkill/*:wlan ; do
	  echo 0 > $filename
	done
	rm -f /etc/xdg/autostart/piwiz.desktop
	rm -f /etc/localtime
	echo "Europe/Brussels" >/etc/timezone
	dpkg-reconfigure -f noninteractive tzdata
	#cat >/etc/default/keyboard <<'KBEOF'
	echo 'XKBMODEL="pc105"' >>/etc/default/keyboard
	echo 'XKBLAYOUT="us"' >>/etc/default/keyboard
	echo 'XKBVARIANT=""' >>/etc/default/keyboard
	echo 'XKBOPTIONS=""' >>/etc/default/keyboard
	echo 'KBEOF' >>/etc/default/keyboard
	dpkg-reconfigure -f noninteractive keyboard-configuration

	# als deze string niet in de file staat zal hij de configuratie in dhcp.conf plakken
	if [[ grep -q '# MCT - Computer Networks section' /etc/dhcpcd.conf ]]; then
		echo 'Het dhcp.conf file werd reeds aangepast!'
	else
		#cat >>/etc/dhcpcd.conf <<'DHCPCDEOF'
		echo "#" >>/etc/dhcpcd.conf
		echo "# MCT - Computer Networks section" >>/etc/dhcpcd.conf
		echo "#" >>/etc/dhcpcd.conf
		echo "# DHCP fallback profile" >>/etc/dhcpcd.conf
		echo "profile static_eth0" >>/etc/dhcpcd.conf
		echo "static ip_address=192.168.168.168/24" >>/etc/dhcpcd.conf
		echo "# The primary network interface" >>/etc/dhcpcd.conf
		echo "interface eth0" >>/etc/dhcpcd.conf
		echo "arping 192.168.99.99" >>/etc/dhcpcd.conf
		echo "fallback static_eth0" >>/etc/dhcpcd.conf
		echo "DHCPCDEOF" >>/etc/dhcpcd.conf
	fi

	rm -f /boot/firstrun.sh
	sed -i 's| systemd.run.*||g' /boot/cmdline.txt
	
	
else
	echo "USB not connected!"
	echo "Shutting down!"
	exit 0
fi


exit 0
