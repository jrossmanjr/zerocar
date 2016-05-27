#!/usr/bin/env bash
# RaspiCar Install Script
# (c) 2016 by Load
# Use a RaspberryPi as a WiFi hotspot to serve up files
# RaspiCar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# shoutout to the folks making PiHole for showing me the way and essentially teaching me to code for the Pi...

# Run this script as root or under sudo
echo ":::"
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
	echo -n "::: Running an update to your distro"
	$SUDO apt-get update
	echo " done!"
}

function delete_crap() {
	# delete all the junk that has nothing to do with being a lightweight server
	echo ":::"
	echo -n "::: Removing JUNK...from the trunk"
	$SUDO apt-get -y purge minecraft-pi python-minecraftpi wolfram-engine sonic-pi libreoffice scratch
	$SUDO apt-get -y autoremove
	$SUDO apt-get purge
	echo " done!"
}

function install_samba() {	
	# installing samba server so you can connect and add files easily
	echo ":::"
	echo -n "::: Installing Samba"
	$SUDO apt-get install -y samba samba-common-bin
	echo " done!"

}

function edit_samba() {	
	# editing Samba
	echo ":::"
	echo -n "::: Editing Samba"
	$SUDO cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp

	echo '
  [Mediadrive]
   comment = Public Storage
   path = /
   valid users = @users
   force group = users
   create mask = 0775
   directory mask = 0775
   read only = no
   browsable = yes
   guest ok = yes' | sudo tee --append /etc/samba/smb.conf > /dev/null
  	$SUDO /etc/init.d/samba restart
	echo " done!"
}

function install_minidlna() {	
	# installing minidlna to serve up your shit nicely
	echo ":::"
	echo -n "::: Installing minidlna"
	$SUDO apt-get install -y minidlna
	echo " done!"

}

function edit_minidlna() {	
	# editing minidlna
	echo ":::"
	echo -n "::: Editing minidlna"
	$SUDO cp /etc/minidlna.conf /etc/minidlna.conf.bkp
	$SUDO echo 'user=minidlna 
		media_dir=/home/pi/Videos/
		db_dir=/home/pi/.minidlna
		log_dir=/var/log
		port=8200
		model_name=RaspiCar
		inotify=yes
		enable_tivo=no
		strict_dlna=no
		album_art_names=Cover.jpg/cover.jpg/AlbumArtSmall.jpg/albumartsmall.jpg/AlbumArt.jpg/albumart.jpg/Album.jpg/album.jpg/Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg/movie.tbn/movie.jpg
		notify_interval=900
		serial=12345678
		model_number=1
		root_container=B' > /etc/minidlna.conf
	$SUDO mkdir /home/pi/.minidlna
	$SUDO chmod 777 /home/pi/.minidlna
	$SUDO update-rc.d minidlna defaults
	echo " done!"

}

function install_hostapd() {	
	# installing hostapd so it makes the wifi adaper into an access point
	echo ":::"
	echo -n "::: Installing hostapd"
	$SUDO apt-get install -y hostapd
	echo " done!"

}

function edit_hostapd() {	
	# editing hostapd and associated properties
	echo ":::"
	echo -n "::: Editing hostapd"
	$SUDO cp /etc/default/hostapd /etc/default/hostapd.bkp
	echo '
DAEMON_CONF="/etc/hostapd/hostapd.conf"' | sudo tee --append /etc/default/hostapd > /dev/null
  	
	$SUDO cp /etc/network/interfaces /etc/network/interfaces.bkp
  	$SUDO echo 'source-directory /etc/network/interfaces.d

	auto lo
	iface lo inet loopback

	iface eth0 inet manual

	iface wlan0 inet static
  		address 10.0.0.1
  		netmask 255.255.255.0' > /etc/network/interfaces
	$SUDO echo 'interface=wlan0
	#driver=rtl871xdrv
	driver=nl80211
	ssid=Raspicar
	hw_mode=g
	ieee80211n=1
	channel=1
	wpa=2
	wpa_passphrase=RaspiCar1
	wpa_key_mgmt=WPA-PSK
	wpa_pairwise=CCMP
	rsn_pairwise=CCMP
	beacon_int=100
	auth_algs=3
	wme_enabled=1' > /etc/hostapd/hostapd.conf
	echo " done!"
}

function install_dnsmasq() {	
	# installing dnsmasq so it can serve up your wifiz
	echo ":::"
	echo -n "::: Installing dnsmasq"
	$SUDO apt-get install -y dnsmasq
	echo " done!"

}

function edit_dnsmasq() {	
	# editing dnsmasq so it can serve up your wifiz
	echo ":::"
	echo -n "::: Editing dnsmasq"
	$SUDO echo '	
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.9,255.255.255.0,12h' | sudo tee --append /etc/dnsmasq.conf > /dev/null
	echo " done!"

}

function fix_startup() {
	# restart the wifi as last function on startup
	echo ":::"
	echo -n "::: fixing the wifi at startup"
	$SUDO cp rc.local /etc/rc.local
	echo " DONE!"
}

}

function restart_Pi() {
	# restarting
	echo ":::"
	echo -n "::: it is finished... I will now restart!!"
	$SUDO service hostapd restart && sudo /etc/init.d/dnsmasq restart
	$SUDO shutdown -r now
	echo " DONE!"
}



update_yo_shit
delete_crap
install_samba
edit_samba
install_minidlna
edit_minidlna
install_hostapd
edit_hostapd
install_dnsmasq
edit_dnsmasq
fix_startup
restart_Pi
