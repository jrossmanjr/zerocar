#!/usr/bin/env bash
# ChipCar Install Script
# (c) 2016 by jrossmanjr
# Use a C.H.I.P. as a WiFi hotspot to serve up files
# ChipCar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# shoutout to the folks making PiHole, Adafruit, & PIRATEBOX for showing me the way and essentially teaching me to code for the Pi...
# alot of help came from the CHIP BBS and this post -- https://slack-files.com/T02GVC9G6-F0H7G3WCT-25e7dfb781
# huge thanks to silverwind who made Droppy...makes managing the files much easier thru the web : https://github.com/silverwind/droppy

# Run this script as root or under sudo
echo ":::
 ██████╗██╗  ██╗██╗██████╗  ██████╗ █████╗ ██████╗ 
██╔════╝██║  ██║██║██╔══██╗██╔════╝██╔══██╗██╔══██╗
██║     ███████║██║██████╔╝██║     ███████║██████╔╝
██║     ██╔══██║██║██╔═══╝ ██║     ██╔══██║██╔══██╗
╚██████╗██║  ██║██║██║     ╚██████╗██║  ██║██║  ██║
 ╚═════╝╚═╝  ╚═╝╚═╝╚═╝      ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝
                                                   

    
    By - jrossmanjr   //   https://github.com/jrossmnajr/ZeroCar             "
# Find the rows and columns will default to 80x24 is it can not be detected
screen_size=$(stty size 2>/dev/null || echo 24 80) 
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')

# Divide by two so the dialogs take up half of the screen, which looks nice.
r=$(( rows / 2 ))
c=$(( columns / 2 ))
# Unless the screen is tiny
r=$(( r < 20 ? 20 : r ))
c=$(( c < 70 ? 70 : c ))

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

whiptail --msgbox --title "ZeroCar automated installer" "\nThis installer turns your C.H.I.P. into \nan awesome WiFi router and media streamer!" ${r} ${c}

whiptail --msgbox --title "ZeroCar automated installer" "\n\nFirst things first... Lets setup some variables!" ${r} ${c}

var1=$(whiptail --inputbox "Name the DLNA Server" ${r} ${c} ZeroCar --title "DLNA Name" 3>&1 1>&2 2>&3)

var2=$(whiptail --inputbox "Name the WiFi" ${r} ${c} ZeroCar --title "Wifi Name" 3>&1 1>&2 2>&3)

var3=$(whiptail --passwordbox "Please enter a password for the WiFi" ${r} ${c} --title "WiFi Password" 3>&1 1>&2 2>&3)

whiptail --msgbox --title "ZeroCar automated installer" "\n\nOk all the data has been entered...The install will now complete!" ${r} ${c}

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
   create mask = 0777
   directory mask = 0777
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
		db_dir=/home/chip/minidlna
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
	echo "model_name=$var1" | sudo tee --append /etc/minidlna.conf > /dev/null
	$SUDO mkdir /home/chip/minidlna
	$SUDO mkdir /home/chip/Videos
	$SUDO chmod -R 777 /home/chip/
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

function install_usbmount() {	
	# installing usb automount, and simlinking a usb drive to 'Videos' folder
	echo ":::"
	echo "::: Installing usbmount and simlinking"
	$SUDO apt-get -y install usbmount cryptsetup 
	$SUDO cp usbmount_CHIP.conf /etc/usbmount/usbmount.conf
	$SUDO ln -s /media/usb0 /home/chip/Videos
	echo "::: DONE!"
}

function stop_ipv6() {	
	# stopping ipv6 
	echo ":::"
	echo "::: Installing stoping ipv6"
	$SUDO sysctl -w net.ipv6.conf.all.disable_ipv6=1
	$SUDO sysctl -w net.ipv6.conf.default.disable_ipv6=1
	echo "::: DONE!"
}

function install_droppy() {
  # update Node.js, NPM and install droppy to allow for web file serving
  echo ":::"
  echo "::: Installing NODE, NPM, N and Droppy"
  $SUDO apt-get install -y node npm
  $SUDO npm cache clean -f && sudo npm install -g n
  $SUDO n stable
  $SUDO npm install -g droppy
}

function fix_startup() {
  # restart the wifi as last function on startup
  echo ":::"
  echo "::: Fixing the wifi at startup"
  $SUDO cp chip.local /etc/rc.local
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
install_usbmount
stop_ipv6
install_droppy
fix_startup
restart_CHIP
