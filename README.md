# WebInterface-Persist-IP

This simple program will ensure the ReMarkable Tablet's web interface is internally accessible at 10.11.99.1:80 after disconnecting the usb cable. Disconnecting the usb cable will remove the ip address from the usb0 network interface, but does not stop the web interface from running. This means that if we give usb0 an ip address, the web interface can still be used for file uploads/downloads. Useful for clients that leverage the web interface for file operations, namely access over [wifi](https://github.com/rM-self-serve/webinterface-wifi). 

This program will not start the web interface, it will only ensure internal accessibility after the web interface has been started. If you want to start the web interface, use the following program.

https://github.com/rM-self-serve/webinterface-onboot


### Type the following commands after ssh'ing into the ReMarkable Tablet

## Install

`$ wget https://raw.githubusercontent.com/rM-self-serve/webinterface-persist-ip/master/install-webint-prstip.sh && bash install-webint-prstip.sh`

## Remove

`$ wget https://raw.githubusercontent.com/rM-self-serve/webinterface-persist-ip/master/remove-webint-prstip.sh && bash remove-webint-prstip.sh`

## Use

### To use webinterface-persist-ip, run:

`$ systemctl enable --now webinterface-persist-ip`


### To stop using webinterface-persist-ip, run:

`$ systemctl disable --now webinterface-persist-ip`


## How Does it Work?

We first wait for systemd-networkd-wait-online to wait for the usb0 network interface to be online, meaning the usb cable was connected.

Then, we use systemd-networkd-wait-online but this time use polling to wait for the connection to be interrupted, meaning the usb cable was disconnected.

Finally we add the 10.11.99.1 ip address to the usb0 network interface and begin again.