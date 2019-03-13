# ZeroCar
Used to deploy a RaspberryPi DLNA server via a hotspot

I use this as a portable server for the kids' iPads while in the car or flying on trips. 
    
- Raspberry Pi Setup:
    - This was built for the Raspberry Pi Zero W 
            
    - "Burn" the Raspbian image of your choice to the SD card with another computer
        - Try Etcher by resin.io -- https://www.balena.io/etcher/
    
    - To allow for SSH access: https://bit.ly/2VUi53V
        - You can add a file to the boot partition called "ssh"
       ```
       touch ssh
       ```
        - OR...Create a blank txt file and save it to the boot partition as ssh.txt

    - have the RPi auto connect to you home router on boot so you can ssh in
        - Create a file in your text editor of choice called "wpa_supplicant.conf" with the below in the file
        ```
        ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
        update_config=1

        network={
            ssid="WIFI_ROUTER_NAME"
            psk="WIFI_ROUTER_PASSWORD"
            proto=RSN
            key_mgmt=WPA-PSK
            pairwise=CCMP
            auth_alg=OPEN
        }
        ```
        - Save the config file in the boot partition 

    - Install the SD card to the RPi and boot
    
    - SSH into the RPi through Putty or Terminal of choice https://bit.ly/2UzWyNA

    - Log in and run -- `sudo raspi-config`
        - Setup the keyboard in internationalization tools so it's configured correctly
    
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
    - After the first reboot go to ``` 10.0.0.1:8989 ``` to access the Droppy interface
    - Drop in files!
    
-------------------------------------------------------------------------------------------------------------------------
Future
- want to harden the OS to make it mostly read only if able to help with SD card corruption



-------------------------------------------------------------------------------------------------------------------------


