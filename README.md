# ZeroCar
Used to deploy a RaspberryPi Zero DLNA server for in the car
    
- Raspberry Pi Setup:
    - So how I set this up is to have a Raspberry Pi Zero hooked up to a USB hub
        - I like the UUGear one http://www.uugear.com/product/zero4u/ or https://www.adafruit.com/products/3298
        - On that hub have: 
            - WiFi dongle you are attempting to use - I usually use a TPLINK TL-WN725N
            - USB Ethernet adapter
            - Keyboard
            - HDMI Monitor -- not necessairly needed (you can SSH in if you want)
            
    - "Burn" the raspbian image of your choice to the SD card with another computer
        - Try Etcher by resin.io -- www.etcher.io
    
    - Install the SD card to the pi and boot
    
    - At this point run -- `sudo raspi-config`
        - setup the keyboard in internationalization tools 
    
    - Run -- 
        ```
        git clone https://github.com/jrossmanjr/ZeroCar.git
        cd ZeroCar/
        chmod +x ZeroCar.sh
        sudo ./ZeroCar.sh
        ```
        - Fill in data for the prompts!
    
    
- C.H.I.P. Setup:
    - Use a powered USB hub and Flash the C.H.I.P. 
        - TO FLASH -- `http://flash.getchip.com/`
        - On that hub have: 
            - Keyboard
            - VGA/HDMI Monitor
            
    - Boot in and connect to your Local WiFi 

    - Run -- 
        ```
        git clone https://github.com/jrossmanjr/ZeroCar.git
        cd ZeroCar/
        chmod +x ChipCar.sh
        sudo ./ChipCar.sh
        ```
        
- The installer for Pi or C.H.I.P. will prompt you for:
    - SMB Password - so you can connect thru SMB to drop files
    - DLNA Server Name - so you can have a cool name in the DLNA browser of choice
    - SSID Name - Name your WiFi hotspot
    - SSID Password - give it a password to keep jerks out of your shit

- Access Droppy
    - after the first reboot go to ``` 10.0.0.1:8989 ``` to access the Droppy interface
    - drop in files!
    
-------------------------------------------------------------------------------------------------------------------------

Raspberry Pi PARTS LIST!
- Raspberry Pi Zero ```https://www.adafruit.com/product/2885 ```
- Zero4U ``` https://www.adafruit.com/product/3298 or http://www.uugear.com/product/zero4u/ ```
- Micro SD - 8gb or bigger if you want the files directly on the server
- WiFi module TPLINK TL-WN725N ``` https://www.amazon.com/TP-Link-N150-Wireless-Adapter-TL-WN725N/dp/B008IFXQFU ```
- USB Drives - if you want to use the thumb drive technique - just get a big one for all your shows and movies (~128 GB)

C.H.I.P. PARTS LIST!
- Next Thing Co C.H.I.P. ```https://getchip.com/ ```
- USB Drives - just get a big one for all your shows and movies (~128 GB)

EXTRA - for setup
- Keyboard
- Monitor 
- Mini HDMI adapter ``` https://www.amazon.com/Cablelera-Female-Adapter-Black-ZA5100FM/dp/B011ESUXZI/ ```
- USB Ethernet ``` https://www.amazon.com/AmazonBasics-USB-Ethernet-Network-Adapter/dp/B00M77HLII/ ```
