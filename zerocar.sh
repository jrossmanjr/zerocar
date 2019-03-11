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
# tahnkyou to SDESALAS who made a schweet node script -- https://github.com/sdesalas/node-pi-zero
# huge thanks to silverwind who made Droppy...makes managing the files much easier thru the web : https://github.com/silverwind/droppy
# used code from RaspberryConnect.com to setup auto hotspot or home wifi connect to allow for ease of loading files over wifi. http://www.raspberryconnect.com/network/item/331-raspberry-pi-auto-wifi-hotspot-switch-direct-connection

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


# Run this script as root or under sudo
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

# Into popups and variable setup
whiptail --msgbox --title "ZeroCar automated installer" "\nThis installer turns your Raspberry Pi and Wifi Dongle into \nan awesome WiFi router and media streamer!" ${r} ${c}
whiptail --msgbox --title "ZeroCar automated installer" "\n\nFirst things first... Lets set up some variables!" ${r} ${c}
var1=$(whiptail --inputbox "Name the DLNA Server" ${r} ${c} ZeroCar --title "DLNA Name" 3>&1 1>&2 2>&3)
var2=$(whiptail --inputbox "Name the WiFi Hotspot" ${r} ${c} ZeroCar --title "Wifi Name" 3>&1 1>&2 2>&3)
var3=$(whiptail --passwordbox "Please enter a password for the WiFi hotspot" ${r} ${c} --title "WiFi Password" 3>&1 1>&2 2>&3)
var4=$(whiptail --inputbox "What WiFi to connect to" ${r} ${c} HomeRouter --title "Home Router Name" 3>&1 1>&2 2>&3)
var5=$(whiptail --passwordbox "Please enter a password for your Home Router" ${r} ${c} --title "Home Router Password" 3>&1 1>&2 2>&3)
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
  $SUDO apt-get -y purge minecraft-pi python-minecraftpi wolfram-engine sonic-pi libreoffice scratch
  $SUDO apt-get purge dns-root-data
  $SUDO apt-get autoremove
  $SUDO apt-get purge
  echo "::: DONE!"
}

function upgrade_yo_shit() {
#updating the distro...
  echo ":::"
  echo "::: Running upgrades"
  $SUDO apt upgrade -y
  echo "::: DONE!"
}

function install_wifi() {
# installing wifi drivers for rtl8188eu chipset
  echo ":::"
  echo "::: Installing wifi drivers"
  $SUDO wget http://www.fars-robotics.net/install-wifi -O /usr/bin/install-wifi
  $SUDO chmod +x /usr/bin/install-wifi
  $SUDO install-wifi
  echo "::: DONE!"
}

function install_the_things() {
  # installing samba server so you can connect and add files easily
  # installing minidlna to serve up your shit nicely
  # installing hostapd so it makes the wifi adaper into an access point
  # installing dnsmasq so it can serve up your wifiz
  # installing iw so it has the tools for the autoselect script
  echo ":::"
  echo "::: Installing Samba, Minidlna, Hostapd & DNSmasq"
  $SUDO apt-get install -y samba samba-common-bin minidlna hostapd dnsmasq iw > /dev/null
  $SUDO systemctl disable hostapd
  $SUDO systemctl disable dnsmasq
  echo "::: DONE installing all the things!"
}

function edit_samba() {
  # editing Samba
  echo ":::"
  echo "::: Editing Samba... "
  echo "::: You will enter a password for your Folder Share next."
  $SUDO chmod -R 777 /home/pi/
  $SUDO smbpasswd -a $var1
  $SUDO cp /etc/samba/smb.conf /etc/samba/smb.conf.bkp
  $SUDO mkdir ~/videos

  echo '[Mediadrive]
        comment = Public Storage
        path = /home/
        create mask = 0775
        directory mask = 0775
        read only = no
        browsable = yes
        writable = yes
        guest ok = yes
        guest only = yes' | sudo tee --append /etc/samba/smb.conf > /dev/null
  $SUDO /etc/init.d/samba restart
  echo "::: DONE!"
}

function edit_minidlna() {
  # editing minidlna
  echo ":::"
  echo -n "::: Editing minidlna"
  $SUDO cp /etc/minidlna.conf /etc/minidlna.conf.bkp
  $SUDO echo 'user=minidlna
    media_dir=~/videos/
    db_dir=~/minidlna
    log_dir=/var/log
    port=8200
    inotify=yes
    enable_tivo=no
    strict_dlna=no
    album_art_names=Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg/movie.tbn/movie.jpg
    notify_interval=900
    serial=12345678
    model_number=1
    root_container=B' > /etc/minidlna.conf
  echo "model_name=$var1" | sudo tee --append /etc/minidlna.conf > /dev/null
  $SUDO mkdir ~/minidlna
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
  $SUDO echo 'network={
ssid=$var4
psk=$var5
proto=RSN
key_mgmt=WPA-PSK
pairwise=CCMP
auth_alg=OPEN
}
' > /etc/wpa_supplicant/wpa_supplicant.conf

  $SUDO echo '
# set the interface
interface=wlan0

# this is the driver that must be used for ath9k and other similar chipset devices
driver=nl80211

# add the controll interface for hostapd
ctrl_interface=/var/run/Hostapd
ctrl_interface_group=0

# yes, it says 802.11g, but the n-speeds get layered on top of it
hw_mode=g
macaddr_acl=0

# this enables the 802.11n speeds and capabilities ...  You will also need to enable WMM for full HT functionality.
ieee80211n=1
ieee80211d=1
wmm_enabled=1

# self-explanatory, but not all channels may be enabled for you - check /var/log/messages for details
channel=6

# adjust to fit your location
country_code=US

# settings for security
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_pairwise=CCMP TKIP
rsn_pairwise=CCMP

# these have to be set in agreement w/ channel and some other values... read hostapd.conf docs
#ht_capab=[HT20][SHORT-GI-20][DSSS_CCK-40]

# makes the SSID visible and broadcasted
ignore_broadcast_ssid=0


' > /etc/hostapd/hostapd.conf
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
#stop DNSmasq from using resolv.conf
no-resolv
#Interface to use
interface=wlan0
bind-interfaces
dhcp-range=10.0.0.10,10.0.0.150,255.255.255.0,12h' | sudo tee --append /etc/dnsmasq.conf > /dev/null
  echo "::: DONE!"
}

function edit_dhcpdconf() {
  # editing dhcpcd to stop it from starting the wifi network so the autostart script can
  echo ":::"
  echo "::: Editing dhcpd.conf"
  $SUDO echo '
nohook wpa_supplicant' | sudo tee --append /etc/dhcpcd.conf > /dev/null
  echo "::: DONE!"
}

function edit_autostart() {
  # editing dnsmasq so it can serve up your wifiz
  echo ":::"
  echo "::: Editing autostart service"
  $SUDO echo '
[Unit]
Description=Automatically generates a Hotspot when a valid SSID is in range
After=multi-user.target
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/usr/bin/autohotspot
[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/autohotspot.service
  $SUDO systemctl enable autohotspot.service
  echo "::: DONE!"
}

function fix_startup() {
  # move autoscript, rc.local, and make both executable 
  echo ":::"
  echo "::: Moving scripts for startup"
  $SUDO cp autohotspot.sh /usr/bin/autohotspot
  $SUDO chmod +x /usr/bin/autohotspot

  $SUDO cp rc.local /etc/rc.local
  $SUDO chmod +x /etc/rc.local
  echo "::: DONE!"
}

function restart_Pi() {
  # restarting
  echo ":::"
  echo "::: It is finished..."
  echo "::: please restart the Pi. -- suggest sudo reboot"

}

function install_node() {
  # update Node.js, NPM and install Droppy to allow for web file serving
  echo ":::"
  echo "::: Installing NODE, NPM, N and Droppy"
  wget -O - https://raw.githubusercontent.com/sdesalas/node-pi-zero/master/install-node-v.last.sh | bash
  $SUDO npm install -g n
  $SUDO npm install -g droppy
  echo ":::"
  echo "::: DONE!"
}


update_yo_shit
delete_crap
upgrade_yo_shit
install_the_things
install_node
edit_samba
edit_minidlna
edit_hostapd
edit_dnsmasq
edit_dhcpdconf
edit_autostart
fix_startup
install_wifi
restart_Pi
