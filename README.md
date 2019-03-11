# ZeroCar
Used to deploy a RaspberryPi DLNA server via a hotspot

I use this as a portable server for the kids' iPads while in the car or flying on trips. 
    
- Raspberry Pi Setup:
    - So how I set this up is to have a Raspberry Pi Zero / Zero W / or Pi 3 variants hooked up to a USB hub
        - I like the UUGear one http://www.uugear.com/product/zero4u/ or https://www.adafruit.com/products/3298
        - On that hub have: 
            - WiFi dongle you are attempting to use - I usually use a TPLINK TL-WN725N (not needed if you have the wireless zero)
            - USB Ethernet adapter
            - Keyboard
            - HDMI Monitor -- not necessairly needed (you can SSH in if you want)
            
    - "Burn" the raspbian image of your choice to the SD card with another computer
        - Try Etcher by resin.io -- https://www.balena.io/etcher/
    
    - Install the SD card to the pi and boot
    
    - At this point run -- `sudo raspi-config`
        - setup the keyboard in internationalization tools 
    
    - Run -- 
        ```
        sudo apt update
        sudo apt upgrade
        sudo apt install git
        git clone https://github.com/jrossmanjr/zerocar.git
        cd zerocar/
        chmod +x zerocar.sh
        sudo ./zerocar.sh
        ```
        - Fill in data for the prompts!
    
     
- The installer will prompt you for:
    - SMB Password - so you can connect thru SMB to drop files in 
    - DLNA Server Name - so you can have a cool name in the DLNA browser of choice
    - SSID Name - Name your WiFi hotspot
    - Hotspot Password - give the hotspot a password to keep jerks out of your stuff
    - SSID Name of Home Router - this is so when you turn it on at your house it connects to tyour home wifi for updates over ssh or to drop files in 
    - Home Router Password

- Access Droppy (Droppy info: https://github.com/silverwind/droppy )
    - after the first reboot go to ``` 10.0.0.1:8989 ``` to access the Droppy interface
    - drop in files!
    
-------------------------------------------------------------------------------------------------------------------------
Future
- want to harden the OS to make it mostly read only if able to help with SD card corruption



-------------------------------------------------------------------------------------------------------------------------
Raspberry Pi PARTS LIST!
- Raspberry Pi Zero ```https://www.adafruit.com/product/2885 ```
- Zero4U ``` https://www.adafruit.com/product/3298 or http://www.uugear.com/product/zero4u/ ```
- Micro SD - 8gb or bigger if you want the files directly on the server
- WiFi module TPLINK TL-WN725N ``` https://www.amazon.com/TP-Link-N150-Wireless-Adapter-TL-WN725N/dp/B008IFXQFU ```
- USB Drives - if you want to use the thumb drive technique - just get a big one for all your shows and movies (~128 GB)

EXTRA - for setup
- Keyboard
- Monitor 
- Mini HDMI adapter ``` https://www.amazon.com/Cablelera-Female-Adapter-Black-ZA5100FM/dp/B011ESUXZI/ ```
- USB Ethernet ``` https://www.amazon.com/AmazonBasics-USB-Ethernet-Network-Adapter/dp/B00M77HLII/ ```
