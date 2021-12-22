$hostnamefile="/etc/hostname"


$Directory="C:\Scripts\Test"
$WPA_config = "country=BE
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
ap_scan=1

update_config=1
network={
	ssid="Howest-IoT"
	psk=a2ad90c72dd23d4fb7daed24ec566fa2311abb84904035d4dea7f4500240f0b9
}

WPAEOF"
$NewPath="C:\Scripts\Test\NewPath"
Get-ChildItem $Directory -Filter "*.txt" | foreach {$TextToAdd+"`r`n" + (get-content $_) | Out-File $_;  Move-Item -Path $_ -Destination $NewPath}