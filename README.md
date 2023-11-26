# WebInterface-Persist-IP

This simple program will ensure the ReMarkable Tablet's web interface is internally accessible at 10.11.99.1:80 after disconnecting the usb cable. Disconnecting the usb cable will remove the ip address from the usb0 network interface, but does not stop the web interface from running. This means that if we give usb0 an ip address, the web interface can still be used for file uploads/downloads. Useful for clients that leverage the web interface for file operations, namely access over [wifi](https://github.com/rM-self-serve/webinterface-wifi). 

This program will not start the web interface, it will only ensure internal accessibility after the web interface has been started. If you want to start the web interface, use the following program.

https://github.com/rM-self-serve/webinterface-onboot


### Type the following commands after ssh'ing into the ReMarkable Tablet

## Install

`$ wget https://raw.githubusercontent.com/rM-self-serve/webinterface-persist-ip/master/install-webint-prstip.sh && bash install-webint-prstip.sh`

## Remove

`$ wget https://raw.githubusercontent.com/rM-self-serve/webinterface-persist-ip/master/remove-webint-prstip.sh && bash remove-webint-prstip.sh`

## Usage

Enable webinterface-persist-ip:

`$ webint-prstip apply`

Disable webinterface-persist-ip:

`$ webint-prstip revert`

## How Does it Work?

We modify a script that runs every time the cord disconnects:

```/etc/ifplugd/ifplugd.action```

To give usb0 the ip address:

```ip addr change 10.11.99.1/32 dev usb0```


```
# Before

if [ -z "$1" ] || [ -z "$2" ] ; then
    echo "Wrong arguments" > /dev/stderr
    exit 1
fi

if [ "$2" = "up" ]
then
    systemctl start "busybox-udhcpd@$1.service"
fi

if [ "$2" = "down" ]
then
    systemctl stop "busybox-udhcpd@$1.service"
fi
```
```
# After

if [ -z "$1" ] || [ -z "$2" ] ; then
    echo "Wrong arguments" > /dev/stderr
    exit 1
fi

if [ "$2" = "up" ]
then
    systemctl start "busybox-udhcpd@$1.service"
fi

if [ "$2" = "down" ]
then
    systemctl stop "busybox-udhcpd@$1.service"
    ip addr change 10.11.99.1/32 dev usb0
fi
```