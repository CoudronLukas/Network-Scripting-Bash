#!/bin/bash

set +e

CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
echo TDCsPi >/etc/hostname
sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\tTDCsPi/g" /etc/hosts
FIRSTUSER=`getent passwd 1000 | cut -d: -f1`
FIRSTUSERHOME=`getent passwd 1000 | cut -d: -f6`
echo "$FIRSTUSER:"'$5$bJs6KciFNd$aiF/zJ80bXISxpNlFg6t2nD5SdscP97/SOuYEkSHmF6' | chpasswd -e
systemctl enable ssh
cat >/etc/wpa_supplicant/wpa_supplicant.conf <<'WPAEOF'
country=BE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Howest-IoT"
	psk=a2ad90c72dd23d4fb7daed24ec566fa2311abb84904035d4dea7f4500240f0b9
}

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
cat >/etc/default/keyboard <<'KBEOF'
XKBMODEL="pc105"
XKBLAYOUT="us"
XKBVARIANT=""
XKBOPTIONS=""
KBEOF
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
exit 0
