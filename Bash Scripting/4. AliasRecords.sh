#!/bin/bash
#Alias records

#moet als root gerunt worden
if [ "$(id -u)" -ne 0 ]; then
  printf "dit script moet gerunt worden door de root!\n\n"
  exit 1
fi

apt update
apt install apache2 bind9 bind9utils bind9-doc -y

# /etc/default/bind9 backup en aanpassen

printf "Backup file maken voor bind9\n\n"
CMD_BAK_BIND9="cp /etc/default/bind9 /etc/default/bind9.bak"
eval "$CMD_BAK_BIND9"

echo "#\n# run resolv.conf?\nRESOLVCONF=no\n\n# startup options for the server\nOPTIONS='-4 -u bind'" >/etc/default/bind9

# /etc/bind/named.conf.local backup en aanpassen

printf "Backupfile maken voor named.conf.local\n\n"
CMD_BAK_NAMED="cp /etc/bind/named.conf.local /etc/bind/named.conf.local.bak"
eval "$CMD_BAK_NAMED"

printf "zone \" mctlabo.be\" {\n type master;\nfile \"/etc/bind/zones/mctlabo.be\";\n};\n\n" >> /etc/bind/named.conf.local
printf "zone \"1.168.192.in-addr.arpa\" {\ntype master;\n file \"/etc/bind/zones/reverse/1.168.192.in-addr.arpa\";\n};" >> /etc/bind/named.conf.local

printf "" >> /etc/bind/named.conf.local


# ZONE DIRECTORY AANMAKEN

CMD_MKDIR_ZONES="mkdir -p /etc/bind/zones/reverse"
eval "$CMD_MKDIR_ZONES
ZONEPATH='/etc/bind/zones/mctlabo.be'
touch ${ZONEPATH}

echo ";" >>${ZONEPATH}
echo "; BIND data for mctlabo.be" >>${ZONEPATH}
echo ";" >>${ZONEPATH}
printf "\$TTL 3h\n" >>${ZONEPATH}
echo "@       IN      SOA     ns1.mctlabo.be. admin.mctlabo.be. (" >>${ZONEPATH}
echo "                        1       ; serial" >>${ZONEPATH}
echo "                        3h      ; refresh" >>${ZONEPATH}
echo "                        1h      ; retry" >>${ZONEPATH}
echo "                        1w      ; expire" >>${ZONEPATH}
echo "                        1h )    ; minimum" >>${ZONEPATH}
echo ";" >>${ZONEPATH}
echo "@       IN      NS      ns1.mctlabo.be." >>${ZONEPATH}
echo "" >>${ZONEPATH}
echo "www                     IN      CNAME   mctlabo.be." >>${ZONEPATH}

printf "Creating file 1.168.192.in-addr.arpa in /etc/bind/zones/reverse/\n\n"
REVERSE_ARPA='/etc/bind/zones/reverse/1.168.192.in-addr.arpa'
touch ${REVERSE_ARPA}

echo ";" >>${REVERSE_ARPA}
echo "; BIND reverse file for 1.168.192.in-addr.arpa" >>${REVERSE_ARPA}
echo ";" >>${REVERSE_ARPA}
printf "\$TTL    604800\n" >>${REVERSE_ARPA}
echo "@       IN      SOA     ns1.mctlabo.be. admin.mctlabo.be. (" >>${REVERSE_ARPA}
echo "                                1       ; serial" >>${REVERSE_ARPA}
echo "                                3h      ; refresh" >>${REVERSE_ARPA}
echo "                                1h      ; retry" >>${REVERSE_ARPA}
echo "                                1w      ; expire" >>${REVERSE_ARPA}
echo "                                1h )    ; minimum" >>${REVERSE_ARPA}
echo ";" >>${REVERSE_ARPA}
echo "@       IN      NS      ns1.mctlabo.be." >>${REVERSE_ARPA}


systemctl restart bind9