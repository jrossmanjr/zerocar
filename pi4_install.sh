#!/usr/bin/env bash
# ZeroCar Install Script
# by jrossmanjr -- https://github.com/jrossmnajr/zerocar
# Use a RaspberryPi as a WiFi hotspot to serve up files
#--------------------------------------------------------------------------------------------------------------------#
# Shoutout to the folks making PiHole, Adafruit, & PIRATEBOX for showing me the way and essentially teaching me BASH

# Thanks to MrEngman for making the wifi installer!! more info: https://www.raspberrypi.org/forums/viewtopic.php?p=462982
# A lot of help came from ADAFRUIT:
# https://learn.adafruit.com/setting-up-a-raspberry-pi-as-a-wifi-access-point/install-software

# Thanks to SDESALAS who made a schweet node install script: https://github.com/sdesalas/node-pi-zero

# Huge thanks to silverwind who made Droppy...makes managing the files much easier thru the web:
# https://github.com/silverwind/droppy

# Thanks to RaspberryConnect.com for some refinement of the setup code

# RaspiAP by billz is the shit -- https://github.com/billz/raspap-webgui
#--------------------------------------------------------------------------------------------------------------------#
# MIT License
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
#documentation files (the "Software"), to deal in the Software without restriction, including without limitation
#the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
#and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
#THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
#OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
#OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#--------------------------------------------------------------------------------------------------------------------#
echo ":::
███████╗███████╗██████╗  ██████╗  ██████╗ █████╗ ██████╗
╚══███╔╝██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔══██╗
  ███╔╝ █████╗  ██████╔╝██║   ██║██║     ███████║██████╔╝
 ███╔╝  ██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║██╔══██╗
███████╗███████╗██║  ██║╚██████╔╝╚██████╗██║  ██║██║  ██║
╚══════╝╚══════╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝
    By - jrossmanjr   //   https://github.com/jrossmnajr/zerocar             "

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
var3=$(whiptail --passwordbox "Please enter a password for the WiFi hotspot" ${r} ${c} --title "HotSpot Password" 3>&1 1>&2 2>&3)
whiptail --msgbox --title "ZeroCar automated installer" "\n\nOk all the data has been entered...The install will now complete!" ${r} ${c}

#--------------------------------------------------------------------------------------------------------------------#
# Functions to setup the rest of the server
#--------------------------------------------------------------------------------------------------------------------#

function instal_raspiap() {
  echo ":::"
  echo "::: Installing Access Pont Software..."
  echo "************************"
  echo "*** DO NOT RESTART!! ***"
  echo "************************"
  wget -q https://git.io/voEUQ -O /tmp/raspap && bash /tmp/raspap
}

function delete_junk() {
# delete all the junk that has nothing to do with being a lightweight server
  echo ":::"
  echo "::: Removing JUNK...from the trunk"
  $SUDO apt-get -y purge dns-root-data minecraft-pi python-minecraftpi wolfram-engine sonic-pi libreoffice scratch
  $SUDO apt-get autoremove
  echo "::: DONE!"
}

function install_wifi() {
# installing wifi drivers for rtl8188eu chipset
  echo ":::"
  echo "::: Installing wifi drivers"
  $SUDO wget http://downloads.fars-robotics.net/wifi-drivers/install-wifi -O /usr/bin/install-wifi
  $SUDO chmod +x /usr/bin/install-wifi
  $SUDO install-wifi
  echo "::: DONE!"
}

function install_the_things() {
  # installing samba server so you can connect and add files easily
  # installing minidlna to serve up your shit nicely
  echo ":::"
  echo "::: Installing Samba, Minidlna, Hostapd & DNSmasq"
  $SUDO apt install -y wget samba samba-common-bin minidlna
  echo "::: DONE installing all the things!"
}

function edit_minidlna() {
  # editing minidlna
  echo ":::"
  echo -n "::: Editing minidlna"
  $SUDO mkdir /home/pi/minidlna
  $SUDO cp /etc/minidlna.conf /etc/minidlna.conf.bkp
  $SUDO echo "user=root
  media_dir=/home/pi/
  db_dir=/home/pi/minidlna/
  log_dir=/var/log
  port=8200
  inotify=yes
  enable_tivo=no
  strict_dlna=no
  album_art_names=Folder.jpg/folder.jpg/Thumb.jpg/thumb.jpg/movie.tbn/movie.jpg/Poster.jpg/poster.jpg
  notify_interval=900
  serial=12345678
  model_number=1
  root_container=B" > /etc/minidlna.conf
  echo "model_name=$var1" | sudo tee --append /etc/minidlna.conf > /dev/null
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
  $SUDO update-rc.d minidlna defaults
  echo "::: DONE!"
}

function edit_hostapd() {
  # editing hostapd and associated properties
  echo ":::"
  echo "::: Editing hostapd"
  $SUDO echo 'driver=nl80211
ctrl_interface=/var/run/hostapd
ctrl_interface_group=0
interface=wlan0       # the interface used by the AP
hw_mode=a             # a simply means 5GHz
channel=0             # the channel to use, 0 means the AP will search for the channel with the least interferences
ieee80211d=1          # limit the frequencies used to those allowed in the country
country_code=US       # the country code
ieee80211n=1          # 802.11n support
ieee80211ac=1         # 802.11ac support
wmm_enabled=1         # QoS support
auth_algs=1           # 1=wpa, 2=wep, 3=both
wpa=2                 # WPA2 only
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_pairwise=CCMP
macaddr_acl=0
ignore_broadcast_ssid=0
### SSID AND PASSWORD ###
' > /etc/hostapd/hostapd.conf
  echo "ssid=$var2" | sudo tee --append /etc/hostapd/hostapd.conf > /dev/null
  echo "wpa_passphrase=$var3" | sudo tee --append /etc/hostapd/hostapd.conf > /dev/null
  echo "::: DONE!"
}

function edit_dhcpdconf() {
  # editing dhcpcd to stop it from starting the wifi network so the autostart script can
  echo ":::"
  echo "::: Editing dhcpd.conf"
  $SUDO echo '#Defaults from Raspberry Pi configuration
hostname
clientid
persistent
option rapid_commit
option domain_name_servers, domain_name, domain_search, host_name
option classless_static_routes
option ntp_servers
require dhcp_server_identifier
slaac private
nohook lookup-hostname
nohook wpa_supplicant
interface wlan0
static ip_address=10.0.0.1/24
static routers=10.0.0.1
static domain_name_server=1.1.1.1 8.8.8.8' > /etc/dhcpcd.conf
  echo "::: DONE!"
}

function edit_dnsmasq() {
  # editing dnsmasq
  echo ":::"
  echo "::: Editing dnsmasq.conf"
  echo "domain-needed
interface=wlan0
dhcp-range=10.0.0.2,10.0.0.245,255.255.255.0,24h" > /etc/dnsmasq.conf
  echo "::: DONE"
}

function install_docker() {
  # update Node.js, NPM and install Droppy to allow for web file serving
  echo ":::"
  echo "::: Installing Docker"
  curl -sSL https://get.docker.com | sh
  $SUDO usermod -aG docker Pi
  echo "::: Installing Portainer --- Access at 10.0.0.1:9000"
  docker volume create portainer_data
  docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
  echo "::: Installing Jellyfin"
  mkdir config
  mkdir tv
  mkdir movies
  docker create \
    --name=jellyfin \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=America/New_York \
    -e UMASK_SET=022 \
    -p 8096:8096 \
    -v /home/pi/config:/config \
    -v /home/pi/tv:/data/tvshows \
    -v /home/pi/movies:/data/movies \
    -v /opt/vc/lib:/opt/vc/lib \
    --device /dev/vcsm:/dev/vcsm \
    --device /dev/vchiq:/dev/vchiq \
    --device /dev/video10:/dev/video10 \
    --device /dev/video11:/dev/video11 \
    --device /dev/video12:/dev/video12 \
    --restart unless-stopped \
    linuxserver/jellyfin

  echo ":::"
  echo "::: DONE!"
}

function finishing_touches() {
  # restarting
  echo "::: Finishing touches..."
  $SUDO chmod -R 777 /home/pi
  $SUDO sysctl -p
  #echo "::: PLEASE RESTART THE PI!!! :::"
  echo "~~~~~REBOOTING!~~~~~"
  $SUDO reboot

}


delete_junk
install_the_things
install_docker
instal_raspiap
edit_minidlna
install_wifi
edit_hostapd
edit_dhcpdconf
edit_dnsmasq
finishing_touches
