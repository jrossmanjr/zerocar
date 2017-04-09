#!/usr/bin/env bash
# ZeroCar Install Script
# (c) 2016 by jrossmanjr
# Use a RaspberryPi as a WiFi hotspot to serve up files
# RaspiCar is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.
# shoutout to the folks making PiHole, Adafruit, & PIRATEBOX for showing me the way and essentially teaching me to code for the Pi...
# thanks to MrEngman for making the wifi installer!! more info: https://www.raspberrypi.org/forums/viewtopic.php?p=462982
# alot of help came from ADAFRUIT: https://learn.adafruit.com/setting-up-a-raspberry-pi-as-a-wifi-access-point/install-software
# huge thanks to silverwind who made Droppy...makes managing the files much easier thru the web : https://github.com/silverwind/droppy


# Run this script as root or under sudo
echo ":::
███████╗███████╗██████╗  ██████╗  ██████╗ █████╗ ██████╗ 
╚══███╔╝██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔══██╗
  ███╔╝ █████╗  ██████╔╝██║   ██║██║     ███████║██████╔╝
 ███╔╝  ██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║██╔══██╗
███████╗███████╗██║  ██║╚██████╔╝╚██████╗██║  ██║██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝
                                                         
    
    By - jrossmanjr   //   https://github.com/jrossmnajr/ZeroCar             "

# Find the rows and columns will default to 80x24 is it can not be detected
screen_size=$(stty size 2>/dev/null || echo 24 80) 
rows=$(echo $screen_size | awk '{print $1}')
columns=$(echo $screen_size | awk '{print $2}')

# Divide by two so the dialogues take up half of the screen, which looks nice.
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

whiptail --msgbox --title "ZeroCar automated installer" "\nThis installer turns your Raspberry Pi and Wifi Dongle into \nan awesome WiFi router and media streamer!" ${r} ${c}

whiptail --msgbox --title "ZeroCar automated installer" "\n\nFirst things first... Lets set up some variables!" ${r} ${c}

var1=$(whiptail --inputbox "Name the DLNA Server" ${r} ${c} ZeroCar --title "DLNA Name" 3>&1 1>&2 2>&3)

var9=$(whiptail --title "What you rocking under the hood?" --radiolist "How many WiFi adapters are you running?" ${r} ${c} 2 \
"One" "One Adapter" ON \
"Two" "Two Adapters" OFF 3>&1 1>&2 2>&3)

exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "The chosen distro is:" $var9
else
    echo "You chose Cancel."
fi


if [ $var9 = Two ]; then
	var2=$(whiptail --inputbox "Name the WiFi Hotspot" ${r} ${c} ZeroCar --title "Wifi Name" 3>&1 1>&2 2>&3)
	var3=$(whiptail --passwordbox "Please enter a password for the WiFi hotspot" ${r} ${c} --title "WiFi Password" 3>&1 1>&2 2>&3)
	var4=$(whiptail --inputbox "What WiFi to connect to" ${r} ${c} HomeRouter --title "Router Name" 3>&1 1>&2 2>&3)
	var5=$(whiptail --passwordbox "Please enter a password for your Home Router" ${r} ${c} --title "Router Password" 3>&1 1>&2 2>&3)
else
	var2=$(whiptail --inputbox "Name the WiFi Hotspot" ${r} ${c} ZeroCar --title "Wifi Name" 3>&1 1>&2 2>&3)
	var3=$(whiptail --passwordbox "Please enter a password for the WiFi Hotspot" ${r} ${c} --title "WiFi Password" 3>&1 1>&2 2>&3)
fi

whiptail --msgbox --title "ZeroCar automated installer" "\n\nOk all the data has been entered...The install will now complete!" ${r} ${c}
 

function update_yo_shit() {
  #updating the distro...
  echo ":::"
  echo "::: Running an update to your distro"
  $SUDO apt update
  echo "::: DONE!"
}

function delete_crap() {
  # delete all the junk that has nothing to do with being a lightweight server
  echo ":::"
  echo "::: Removing JUNK...from the trunk"
  $SUDO apt -y purge minecraft-pi python-minecraftpi wolfram-engine sonic-pi libreoffice scratch
  $SUDO apt-get autoremove
  $SUDO apt-get purge
  echo "::: DONE!"
}

function upgrade_yo_shit() {
  #updating the distro...
  echo ":::"
  echo "::: Running upgrades"
  $SUDO apt -y upgrade
  echo "::: DONE!"
}

function install_wifi() { 
  # installing wifi drivers
  echo ":::"
  echo "::: Installing wifi drivers"
  $SUDO chmod -R 777 /home/pi/
  $SUDO wget http://www.fars-robotics.net/install-wifi -O /usr/bin/install-wifi
  $SUDO chmod +x /usr/bin/install-wifi
  $SUDO install-wifi
  echo "::: DONE!"
}

function install_the_things() {
  # installing samba server so you can connect and add files easily
  echo ":::"
  echo "::: Installing Samba"
  $SUDO apt-get install -y samba samba-common-bin > /dev/null
  echo "::: DONE!"
  # installing minidlna to serve up your shit nicely
  echo ":::"
  echo "::: Installing minidlna"
  $SUDO apt-get install -y minidlna > /dev/null
  echo "::: DONE!"
  # installing hostapd so it makes the wifi adaper into an access point
  echo ":::"
  echo "::: Installing hostapd"
  $SUDO apt-get install -y hostapd > /dev/null
  echo "::: DONE!"
  # installing dnsmasq so it can serve up your wifiz
  echo ":::"
  echo "::: Installing dnsmasq"
  $SUDO apt-get install -y dnsmasq > /dev/null
  echo "::: DONE!"
  # update Node.js, NPM and install Droppy to allow for web file serving
  echo ":::"
  echo "::: Installing NODE, NPM, N and Droppy"
  $SUDO apt install -y node npm
  $SUDO npm cache clean -f && sudo npm install -g n
  $SUDO n stable
  $SUDO npm install -g droppy
  echo ":::"
  echo "::: DONE installing all the things!"
}

function edit_samba() { 
  # editing Samba
  echo ":::"
  echo "::: Editing Samba... "
  echo "::: You will enter a password for your Folder Share next."
  $SUDO smbpasswd -a pi
  $SUDO cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp
  $SUDO mkdir /home/pi/Videos

  echo '
  [Mediadrive]
   comment = Public Storage
   path = /home/pi/
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

function edit_minidlna() {  
  # editing minidlna
  echo ":::"
  echo -n "::: Editing minidlna"
  $SUDO cp /etc/minidlna.conf /etc/minidlna.conf.bkp
  $SUDO echo 'user=minidlna 
    media_dir=/home/pi/Videos/
    db_dir=/home/pi/minidlna
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
  $SUDO mkdir /home/pi/minidlna
  $SUDO update-rc.d minidlna defaults
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
  
if [ $var9 = Two ]; then
  $SUDO echo 'source-directory /etc/network/interfaces.d
auto lo
iface lo inet loopback

iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet static
address 10.0.0.1
netmask 255.255.255.0

allow-hotplug wlan1
iface wlan1 inet dhcp
wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
' > /etc/network/interfaces

	$SUDO echo 'network={
ssid=$var4
psk=$var5
proto=RSN
key_mgmt=WPA-PSK
pairwise=CCMP
auth_alg=OPEN
}
' > /etc/wpa_supplicant/wpa_supplicant.conf
else
	$SUDO echo 'source-directory /etc/network/interfaces.d
auto lo
iface lo inet loopback

iface eth0 inet dhcp

allow-hotplug wlan0
iface wlan0 inet static
address 10.0.0.1
netmask 255.255.255.0' > /etc/network/interfaces
fi
 
 $SUDO echo 'interface=wlan0
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
rsn_pairwise=CCMP' > /etc/hostapd/hostapd.conf
  echo "ssid=$var2" | sudo tee --append /etc/hostapd/hostapd.conf > /dev/null
  echo "wpa_passphrase=$var3" | sudo tee --append /etc/hostapd/hostapd.conf > /dev/null
  $SUDO ln -s /etc/hostapd/hostapd.conf /home/pi/hostapd.conf
  echo "::: DONE!"
}

function edit_dnsmasq() { 
  # editing dnsmasq so it can serve up your wifiz
  echo ":::"
  echo "::: Editing dnsmasq"
  $SUDO echo '  
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.9,255.255.255.0,12h' | sudo tee --append /etc/dnsmasq.conf > /dev/null
  echo "::: DONE!"
}

function install_exfat() {	
	# installing exfat (to allow for larger file support), automount, and simlinking a usb drive to 'Videos' folder
	echo ":::"
	echo "::: Installing exfat, ntfs, usbmount, and simlinking Videos"
	$SUDO apt-get install -y usbmount
	$SUDO apt-get install -y ntfs-3g exfat-fuse exfat-utils cryptsetup hfsprogs
	$SUDO cp usbmount_Pi.conf /etc/usbmount/usbmount.conf
	$SUDO ln -s /media/usb0 /home/pi/Videos
	echo "::: DONE!"
}

function fix_startup() {
  # restart the wifi as last function on startup
  echo ":::"
  echo "::: Fixing the wifi at startup"
  $SUDO cp rc.local /etc/rc.local
  $SUDO chmod +x /etc/rc.local
  echo "::: DONE!"
}

function restart_Pi() {
  # restarting
  echo ":::"
  echo "::: It is finished..."
  $SUDO service hostapd start && sudo /etc/init.d/dnsmasq restart
  echo "::: please restart the Pi. -- suggest sudo reboot"
  
}



update_yo_shit
delete_crap
upgrade_yo_shit
install_the_things
edit_samba
edit_minidlna
edit_hostapd
edit_dnsmasq
#install_exfat
fix_startup
install_wifi
restart_Pi
