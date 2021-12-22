#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then

  printf "dit script moet gerunt worden door de root!\n\n"

  exit 1

fi

#hostname=

input="/home/lukas/Documenten/Examen/LVL-2-POE-config.txt"
#Wanneer een trunk gevonden is zal hij de VLAN's aanmaken anders zal hij gewoon verder doen
while IFS= read -r line
do
	if [ $line ?? 'switchport trunk allowed vlan' ]; then
	  echo "Trunk gevonden..."
	  echo "Vlan's Aanmaken!"
	  sed $line "switchport trunk allowed vlan "
	  
	else
		printf "$line\n" >> /home/lukas/Documenten/Examen/debian-test.txt
	fi
  #printf "$line\n" >> $hostname"-"$ipvlan1.txt
done < "$input"
