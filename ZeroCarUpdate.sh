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
if [[ $EUID -eq 0 ]];then
  echo "::: You are root. Upgrading your Pi"
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

function install_wifi() { 
  # installing wifi drivers
  echo ":::"
  echo "::: Installing wifi drivers"
  wget https://dl.dropboxusercontent.com/u/80256631/install-wifi.tar.gz
  tar xzf install-wifi.tar.gz
  $SUDO ./install-wifi
  $SUDO ln -s /etc/hostapd/hostapd.conf /home/pi/hostapd.conf
  echo "::: DONE!"
}

function install_droppy() {
  # update Node.js, NPM and install droppy to allow for web file serving
  echo ":::"
  echo "::: Installing NODE, NPM, N and Droppy"
  $SUDO chmod -R 777 /home/pi/
  $SUDO apt-get install -y node npm
  $SUDO npm cache clean -f && sudo npm install -g n
  $SUDO n stable
  $SUDO npm install -g droppy
}

function fix_startup() {
  # restart the wifi as last function on startup
  echo ":::"
  echo "::: Fixing the wifi at startup"
  $SUDO cp rc.local /etc/rc.local
  echo "::: DONE!"
}

function restart_Pi() {
  # restarting
  echo ":::"
  echo "::: It is finished..."
  $SUDO service hostapd start && sudo /etc/init.d/dnsmasq restart
  echo "::: please restart the Pi. -- suggest sudo shutdown -r now"
  
}



update_yo_shit
upgrade_yo_shit
install_wifi
install_droppy
fix_startup
restart_Pi
