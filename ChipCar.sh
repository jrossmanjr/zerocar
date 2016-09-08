#!/usr/bin/env bash
# ChipCar Install Script
# (c) 2016 by jrossmanjr
# Use a C.H.I.P. as a WiFi hotspot to serve up files
# RaspiCar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# shoutout to the folks making PiHole, Adafruit, & PIRATEBOX for showing me the way and essentially teaching me to code for the Pi...
# alot of help came from the CHIP BBS and this post -- https://slack-files.com/T02GVC9G6-F0H7G3WCT-25e7dfb781

# Run this script as root or under sudo
echo ":::
 ██████╗██╗  ██╗██╗██████╗  ██████╗ █████╗ ██████╗ 
██╔════╝██║  ██║██║██╔══██╗██╔════╝██╔══██╗██╔══██╗
██║     ███████║██║██████╔╝██║     ███████║██████╔╝
██║     ██╔══██║██║██╔═══╝ ██║     ██╔══██║██╔══██╗
╚██████╗██║  ██║██║██║     ╚██████╗██║  ██║██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝╚═╝      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝
                                                   

    
    By - jrossmanjr   //   https://github.com/jrossmnajr/ZeroCar             "
if [[ $EUID -eq 0 ]];then
	echo "::: You are root."
else
	echo "::: sudo will be used."
  # Check if it is actually installed
  # If it isn't, exit because the install cannot complete
  if [[ $(dpkg-query -s sudo) ]];then
		export SUDO="sudo"
  else
		echo "::: Please install sudo or run this script as root."
    exit 1
  fi
fi

function update_yo_shit() {
	#updating the distro...
	echo ":::"
	echo "::: Running an update to your distro"
	$SUDO apt update
	echo "::: DONE!"
}

function upgrade_yo_shit() {
	#updating the distro...
	echo ":::"
	echo "::: Running upgrades"
	$SUDO apt -y upgrade
	echo "::: DONE!"
}

function install_samba() {	
	# installing samba server so you can connect and add files easily
	echo ":::"
	echo "::: Installing Samba"
	$SUDO apt install -y samba samba-common-bin
	echo "::: DONE!"
}

function edit_samba() {	
	# editing Samba
	echo ":::"
	echo "::: Editing Samba... "
	echo "::: You will enter a password for your Folder Share next."
	$SUDO smbpasswd -a chip
	$SUDO cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp

	echo '
  [Mediadrive]
   comment = Public Storage
   path = /home/chip/
   valid users = @users
   force group = users
   create mask = 0775
   directory mask = 0775
   read only = no
   browsable = yes
   guest ok = yes' | sudo tee --append /etc/samba/smb.conf > /dev/null
  	$SUDO /etc/init.d/samba restart
	echo "::: DONE!"
}

function install_minidlna() {	
	# installing minidlna to serve up your shit nicely
	echo ":::"
	echo -n "::: Installing minidlna"
	$SUDO apt install -y minidlna
	echo "::: DONE!"
}

function edit_minidlna() {	
	# editing minidlna
	echo ":::"
	echo -n "::: Editing minidlna"
	$SUDO cp /etc/minidlna.conf /etc/minidlna.conf.bkp
	$SUDO echo 'user=minidlna 
		media_dir=/home/chip/Videos/
		db_dir=/home/chip/.minidlna
		log_dir=/var/log
		port=8200
		inotify=yes
		enable_tivo=no
		strict_dlna=no
		album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg/movie.tbn/movie.jpg
		notify_interval=900
		serial=12345678
		model_number=1
		root_container=B' > /etc/minidlna.conf
	echo "::: Name the DLNA server: "
	read var1
	echo "model_name=$var1" | sudo tee --append /etc/minidlna.conf > /dev/null
	echo "::: You entered $var1"
	$SUDO mkdir /home/chip/.minidlna
	$SUDO chmod 777 /home/chip/.minidlna
	$SUDO update-rc.d minidlna defaults
	echo "::: DONE!"
}

function install_hostapd() {	
	# installing hostapd so it makes the wifi adaper into an access point
	echo ":::"
	echo "::: Installing hostapd"
	$SUDO apt install -y hostapd
	echo "::: DONE!"
}

function edit_hostapd() {	
	# editing hostapd and associated properties
	echo ":::"
	echo "::: Editing hostapd"
	$SUDO cp /etc/default/hostapd /etc/default/hostapd.bkp
	echo '
DAEMON_CONF="/etc/hostapd/hostapd.conf"' | sudo tee --append /etc/default/hostapd > /dev/null
  	
	$SUDO cp /etc/network/interfaces /etc/network/interfaces.bkp
  	$SUDO echo '
auto lo
iface lo inet loopback

auto wlan1
iface wlan1 inet static
  address 10.0.0.1
  netmask 255.255.255.0' > /etc/network/interfaces
	$SUDO echo 'interface=wlan1
driver=nl80211
ctrl_interface=/var/run/Hostapd
ctrl_interface_group=0
hw_mode=g
channel=1
#ieee80211d=1
#country_code=US
ieee80211n=1
wmm_enabled=1
beacon_int=100
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP' > /etc/hostapd.conf
	echo ":::"
	echo "::: Give your WiFi a name: "
	read var2
	echo "::: The WiFi will be called:  $var2"
	echo "::: Set a Password: "
	read var3
	echo "::: Password:  $var3"
	echo "ssid=$var2" | sudo tee --append /etc/hostapd.conf > /dev/null
	echo "wpa_passphrase=$var3" | sudo tee --append /etc/hostapd.conf > /dev/null
	$SUDO echo '[Unit]
Description=hostapd service
Wants=network-manager.service
After=network-manager.service
Wants=module-init-tools.service
After=module-init-tools.service
ConditionPathExists=/etc/hostapd.conf

[Service]
ExecStart=/usr/sbin/hostapd /etc/hostapd.conf

[Install]
WantedBy=multi-user.target' > /lib/systemd/system/hostapd-systemd.service
	echo "::: DONE!"
}

function install_dnsmasq() {	
	# installing dnsmasq so it can serve up your wifiz
	echo ":::"
	echo "::: Installing dnsmasq"
	$SUDO apt install -y dnsmasq
	echo "::: DONE!"
}

function edit_dnsmasq() {	
	# editing dnsmasq so it can serve up your wifiz
	echo ":::"
	echo "::: Editing dnsmasq"
	$SUDO echo '	
interface=wlan1
except-interface=wlan0
dhcp-range=10.0.0.2,10.0.0.250,12h' | sudo tee --append /etc/dnsmasq.d/access_point.conf > /dev/null
	echo "::: DONE!"
}

function install_exfat() {	
	# installing dnsmasq so it can serve up your wifiz
	echo ":::"
	echo "::: Installing exfat"
	$SUDO apt-get install -y exfat-fuse exfat-utils
	echo "::: DONE!"
}

function restart_CHIP() {
	# restarting
	echo ":::"
	echo "::: It is finished... restarting."
	$SUDO sudo update-rc.d hostapd disable 
	$SUDO systemctl daemon-reload  
	$SUDO systemctl enable hostapd-systemd
	$SUDO /etc/init.d/dnsmasq restart
	$SUDO shutdown -r now
}



update_yo_shit
upgrade_yo_shit
install_samba
edit_samba
install_minidlna
edit_minidlna
install_hostapd
edit_hostapd
install_dnsmasq
edit_dnsmasq
install_exfat
restart_CHIP
